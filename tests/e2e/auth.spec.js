const { test, expect } = require('./support/fixtures');
const {
    fillFlutterField,
    login,
    openLogin,
    userEmail,
    userPassword,
} = require('./support/app');

test.describe('Authentication', () => {
    test('unauthenticated startup shows Login and validates empty and malformed input', async ({ page }) => {
        await openLogin(page);
        await expect(page.getByRole('button', { name: 'Login' }).last()).toBeVisible();

        await page.getByRole('button', { name: 'Login' }).last().click();
        await expect(page.getByText('Please enter an Email Address').last()).toBeVisible();
        await expect(page.getByText('Please enter a Password').last()).toBeVisible();

        await fillFlutterField(page.getByRole('textbox', { name: 'Email' }), 'not-an-email');
        await fillFlutterField(
            page.getByRole('textbox', { name: 'Password', exact: true }),
            'not-empty',
        );
        await page.getByRole('button', { name: 'Login' }).last().click();
        await expect(page.getByText('Please enter a valid Email Address').last()).toBeVisible();
    });

    test('invalid credentials are rejected without entering the store', async ({ page }, testInfo) => {
        test.skip(!userEmail, 'Set BOOKSBOUND_E2E_EMAIL for authenticated flows.');
        await openLogin(page);
        await fillFlutterField(page.getByRole('textbox', { name: 'Email' }), userEmail);
        await fillFlutterField(
            page.getByRole('textbox', { name: 'Password', exact: true }),
            'invalid-e2e-password',
        );
        const authResponse = page.waitForResponse(
            (response) =>
                response.url().includes('identitytoolkit.googleapis.com') &&
                response.request().method() === 'POST',
        );
        await page.getByRole('button', { name: 'Login' }).last().click();
        expect((await authResponse).status()).toBe(400);
        testInfo.annotations.push({ type: 'expected-firebase-auth-400' });
        await expect(page.getByText('Incorrect email or password.').last()).toBeVisible();
        await expect(page.getByText('Bestsellers', { exact: true })).toHaveCount(0);
    });

    test('registration validates required fields and password confirmation', async ({ page }) => {
        await openLogin(page);
        await page.getByRole('button', { name: 'Sign-up' }).click();
        await expect(page.getByText('Get Started!', { exact: true })).toBeVisible();

        await page.getByRole('button', { name: 'Create Account' }).last().click();
        await expect(page.getByText('Please enter a Name').last()).toBeVisible();
        await expect(page.getByText('Please enter an Email Address').last()).toBeVisible();
        await expect(page.getByText('Please enter a Password').last()).toBeVisible();
        await expect(page.getByText('Please enter Confirm Password').last()).toBeVisible();

        await fillFlutterField(page.getByRole('textbox', { name: 'Name' }), 'Playwright Check');
        await fillFlutterField(page.getByRole('textbox', { name: 'Email' }), 'playwright.invalid');
        await fillFlutterField(
            page.getByRole('textbox', { name: 'Password', exact: true }),
            'valid-pass-1',
        );
        await fillFlutterField(
            page.getByRole('textbox', { name: 'Confirm Password' }),
            'different-pass-2',
        );
        await page.getByRole('button', { name: 'Create Account' }).last().click();
        await expect(page.getByText('Please enter a valid Email Address').last()).toBeVisible();
        await expect(page.getByText('Confirm Password should match the Password').last()).toBeVisible();
    });

    test('registration rejects an existing email without creating another account', async ({ page }, testInfo) => {
        test.skip(!userEmail || !userPassword, 'Set the dedicated E2E account environment variables.');
        await openLogin(page);
        await page.getByRole('button', { name: 'Sign-up' }).click();
        await fillFlutterField(page.getByRole('textbox', { name: 'Name' }), 'Existing Account Check');
        await fillFlutterField(page.getByRole('textbox', { name: 'Email' }), userEmail);
        await fillFlutterField(
            page.getByRole('textbox', { name: 'Password', exact: true }),
            userPassword,
        );
        await fillFlutterField(
            page.getByRole('textbox', { name: 'Confirm Password' }),
            userPassword,
        );
        const authResponse = page.waitForResponse(
            (response) =>
                response.url().includes('identitytoolkit.googleapis.com') &&
                response.request().method() === 'POST',
        );
        await page.getByRole('button', { name: 'Create Account' }).last().click();
        expect((await authResponse).status()).toBe(400);
        testInfo.annotations.push({ type: 'expected-firebase-auth-400' });
        await expect(page.getByText(/already exists with this email/i).last()).toBeVisible({ timeout: 20_000 });
        await expect(page.getByText('Get Started!', { exact: true })).toBeVisible();
    });

    test('password reset rejects malformed email without sending a real email', async ({ page }) => {
        await openLogin(page);
        await page.getByRole('button', { name: 'Forgot Password?' }).click();
        await expect(page.getByText('Reset Your Password')).toBeVisible();
        await fillFlutterField(
            page.getByRole('textbox', { name: 'Email Address' }),
            'invalid-address',
        );
        await page.getByRole('button', { name: 'Send Reset Link' }).click();
        await expect(page.getByText('Please enter a valid Email Address').last()).toBeVisible();
        await expect(page.getByRole('button', { name: 'Back to Login' })).toBeVisible();
    });

    test('login persists across refresh and logout returns to Login', async ({ page }) => {
        test.skip(!userEmail || !userPassword, 'Set the dedicated E2E account environment variables.');
        await login(page);
        await expect(page.getByText('Bestsellers', { exact: true })).toBeVisible();

        await page.reload();
        await page.locator('flutter-view').waitFor({ state: 'attached' });
        const accessibilityPrompt = page.locator('flt-semantics-placeholder');
        if (await accessibilityPrompt.count()) {
            await accessibilityPrompt.evaluate((element) => element.click());
        }
        await expect(page.getByText('Bestsellers', { exact: true })).toBeVisible({ timeout: 45_000 });

        await page.getByRole('button', { name: 'Profile tab' }).click();
        await expect(page.getByText(userEmail, { exact: true })).toBeVisible();
        await page.getByRole('button', { name: 'Logout' }).last().click();
        await expect(page.getByText('Welcome Back!', { exact: true })).toBeVisible();
    });
});
