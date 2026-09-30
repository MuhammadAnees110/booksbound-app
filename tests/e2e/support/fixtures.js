const { test: base, expect } = require('@playwright/test');

const test = base.extend({
    page: async ({ page }, use, testInfo) => {
        const diagnostics = {
            pageErrors: [],
            consoleErrors: [],
            failedRequests: [],
            badAssets: [],
            clientErrors: [],
            serverErrors: [],
        };

        // Stub CDN requests with a 1×1 PNG unless this is the live-smoke run.
        // The live-smoke Playwright project sets LIVE_SMOKE=1 so real asset URLs
        // are fetched and their load success can be asserted.
        if (!process.env.LIVE_SMOKE) {
            const testCover = Buffer.from(
                'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mP8/x8AAwMCAO+/f2sAAAAASUVORK5CYII=',
                'base64',
            );
            await page.route('https://cdn.jsdelivr.net/**', (route) =>
                route.fulfill({
                    status: 200,
                    contentType: 'image/png',
                    body: testCover,
                }),
            );
        }

        page.on('pageerror', (error) => diagnostics.pageErrors.push(error.stack || error.message));
        page.on('console', (message) => {
            if (message.type() === 'error') diagnostics.consoleErrors.push(message.text());
        });
        page.on('requestfailed', (request) => {
            const failure = request.failure();
            const item = { url: request.url(), error: failure?.errorText ?? 'unknown' };
            diagnostics.failedRequests.push(item);
            if (request.resourceType() === 'image') diagnostics.badAssets.push(item);
        });
        page.on('response', (response) => {
            if (response.status() >= 400 && response.status() < 500) {
                diagnostics.clientErrors.push({ url: response.url(), status: response.status() });
            }
            if (response.status() >= 500) {
                diagnostics.serverErrors.push({ url: response.url(), status: response.status() });
            }
            if (response.request().resourceType() === 'image' && response.status() >= 400) {
                diagnostics.badAssets.push({ url: response.url(), status: response.status() });
            }
        });

        await use(page);

        await testInfo.attach('browser-diagnostics.json', {
            body: Buffer.from(JSON.stringify(diagnostics, null, 2)),
            contentType: 'application/json',
        });

        const nonAbortFailures = diagnostics.failedRequests.filter(
            (request) => request.error !== 'net::ERR_ABORTED',
        );
        const expectedAuth400 =
            testInfo.annotations.some((annotation) => annotation.type === 'expected-firebase-auth-400') &&
            diagnostics.clientErrors.some(
                (response) =>
                    response.status === 400 &&
                    response.url.includes('identitytoolkit.googleapis.com'),
            );
        const unexpectedConsoleErrors = diagnostics.consoleErrors.filter(
            (message) => !(expectedAuth400 && /status of 400/.test(message)),
        );
        expect(diagnostics.pageErrors, 'uncaught browser exceptions').toEqual([]);
        expect(unexpectedConsoleErrors, 'unexpected browser console errors').toEqual([]);
        expect(nonAbortFailures, 'unexpected failed network requests').toEqual([]);
        expect(diagnostics.badAssets, 'failed image assets').toEqual([]);
        expect(diagnostics.serverErrors, 'HTTP 5xx responses').toEqual([]);
    },
});

module.exports = { test, expect };
