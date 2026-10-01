// Covers the eProject requirements added for submission: social sign-in,
// browse by author, saved addresses/payment methods, order tracking entry
// point, and in-app user documentation (Help & FAQ).
const { test, expect } = require('./support/fixtures');
const {
    fillFlutterField,
    login,
    openBookFromHome,
    openLogin,
    openProfile,
    userEmail,
    userPassword,
} = require('./support/app');

async function scrollUntilVisible(page, locator, maxScrolls = 10) {
    for (let i = 0; i < maxScrolls; i++) {
        if (await locator.count()) return;
        await page.mouse.move(640, 500);
        await page.mouse.wheel(0, 400);
        await page.waitForTimeout(250);
    }
}

test('login offers social sign-in with Google', async ({ page }) => {
    await openLogin(page);
    await expect(
        page.getByRole('button', { name: 'Continue with Google' }).last(),
    ).toBeVisible();
});

test.describe('signed-in requirements', () => {
    test.beforeEach(async ({ page }) => {
        test.skip(!userEmail || !userPassword, 'Set the dedicated E2E account environment variables.');
        await login(page);
    });

    test('book author links to that author\'s books', async ({ page }) => {
        await openBookFromHome(page, 'Steve Jobs');
        await page.getByText('by Walter Isaacson', { exact: true }).last().click();
        await expect(page.getByText('Walter Isaacson', { exact: true }).first()).toBeVisible();
        await expect(page.getByRole('button', { name: /Steve Jobs/ }).first()).toBeVisible();
    });

    test('shipping address form validates required fields', async ({ page }) => {
        await openProfile(page);
        await page.getByRole('button', { name: 'Shipping Addresses' }).last().click();
        await expect(page.getByText('Shipping Addresses', { exact: true }).first()).toBeVisible();
        const empty = page.getByText('No saved addresses', { exact: true });
        const list = page.getByText('Default', { exact: true });
        await expect(empty.or(list).first()).toBeVisible({ timeout: 20_000 });

        await page.getByRole('button', { name: 'Add Address' }).last().click();
        await expect(page.getByText('Add Address', { exact: true }).last()).toBeVisible();
        await page.getByRole('button', { name: 'Save Address' }).last().click();
        await expect(page.getByText('Please enter Full Name').last()).toBeVisible();
    });

    test('payment methods offer Cash on Delivery and reject invalid cards', async ({ page }) => {
        await openProfile(page);
        await page.getByRole('button', { name: 'Payment Methods' }).last().click();
        await expect(page.getByText(/Cash on Delivery/).first()).toBeVisible({
            timeout: 20_000,
        });

        await page.getByRole('button', { name: 'Add Card' }).last().click();
        await fillFlutterField(
            page.getByRole('textbox', { name: 'Cardholder Name' }),
            'Test User',
        );
        await fillFlutterField(
            page.getByRole('textbox', { name: 'Card Number' }),
            '4242 4242 4242 4241',
        );
        await fillFlutterField(page.getByRole('textbox', { name: 'Expiry (MM/YY)' }), '01/20');
        await page.getByRole('button', { name: 'Save Card' }).last().click();
        await expect(page.getByText('Enter a valid card number').last()).toBeVisible();
        await expect(page.getByText('Enter a valid, unexpired date (MM/YY)').last()).toBeVisible();
    });

    test('help screen provides user guide and FAQs', async ({ page }) => {
        await openProfile(page);
        const help = page.getByRole('button', { name: 'Help & FAQ' });
        await scrollUntilVisible(page, help);
        await help.last().click();
        await expect(page.getByText('User Guide', { exact: true })).toBeVisible();
        await page.getByRole('button', { name: /Track an order/ }).last().click();
        await expect(page.getByText(/Profile → My Orders/).first()).toBeVisible();
    });
});
