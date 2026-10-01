const { defineConfig, devices } = require('@playwright/test');

const port = Number(process.env.E2E_WEB_PORT ?? 5181);
const baseURL = `http://127.0.0.1:${port}`;
// E2E_VIDEO=off skips video capture (needs Playwright's ffmpeg download).
const failureVideo = process.env.E2E_VIDEO === 'off' ? 'off' : 'retain-on-failure';

module.exports = defineConfig({
  testDir: './tests/e2e',
  fullyParallel: false,
  workers: 1,
  forbidOnly: Boolean(process.env.CI),
  retries: 0,
  timeout: 60_000,
  expect: { timeout: 12_000 },
  reporter: [
    ['list'],
    ['html', { outputFolder: 'playwright-report', open: 'never' }],
    ['junit', { outputFile: 'test-results/e2e-junit.xml' }],
  ],
  outputDir: 'test-results',

  projects: [
    {
      // ---------------------------------------------------------------------------
      // Default CI suite — CDN requests are stubbed with a 1×1 PNG so tests are
      // deterministic and never depend on external network availability.
      // ---------------------------------------------------------------------------
      name: 'ci',
      use: {
        ...devices['Desktop Chrome'],
        channel: 'chrome',
        baseURL,
        viewport: { width: 1440, height: 900 },
        actionTimeout: 12_000,
        navigationTimeout: 30_000,
        serviceWorkers: 'block',
        screenshot: 'only-on-failure',
        trace: 'retain-on-failure',
        video: failureVideo,
      },
    },
    {
      // ---------------------------------------------------------------------------
      // Live-smoke project — CDN intercepts are DISABLED so real Firebase Storage
      // and CDN asset URLs are fetched.  Use this to verify production asset health
      // independently of the deterministic CI suite.
      //
      // Run with:
      //   BOOKSBOUND_E2E_EMAIL=... BOOKSBOUND_E2E_PASSWORD=... \
      //     npx playwright test --project=live-smoke
      // ---------------------------------------------------------------------------
      name: 'live-smoke',
      testMatch: '**/catalog.spec.js',   // catalog covers all image-rendering paths
      use: {
        ...devices['Desktop Chrome'],
        channel: 'chrome',
        baseURL,
        viewport: { width: 1440, height: 900 },
        actionTimeout: 20_000,
        navigationTimeout: 45_000,
        serviceWorkers: 'block',
        screenshot: 'on',              // always capture for visual review
        trace: 'on',
        video: 'on',
        // No CDN route intercept — real assets are fetched.
        // The fixture in support/fixtures.js checks process.env.LIVE_SMOKE and
        // skips the cdn.jsdelivr.net mock when set.
      },
    },
  ],

  use: {
    ...devices['Desktop Chrome'],
    channel: 'chrome',
    baseURL,
    viewport: { width: 1440, height: 900 },
    actionTimeout: 12_000,
    navigationTimeout: 30_000,
    serviceWorkers: 'block',
    screenshot: 'only-on-failure',
    trace: 'retain-on-failure',
    video: failureVideo,
  },
  webServer: {
    command: 'npm run serve:web',
    url: baseURL,
    reuseExistingServer: false,
    timeout: 30_000,
    stdout: 'pipe',
    stderr: 'pipe',
  },
});
