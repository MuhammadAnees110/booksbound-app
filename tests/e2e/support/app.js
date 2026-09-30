const { expect } = require('./fixtures');

const userEmail = process.env.BOOKSBOUND_E2E_EMAIL;
const userPassword = process.env.BOOKSBOUND_E2E_PASSWORD;

async function fillFlutterField(locator, value) {
    await locator.click();
    await locator.press('Control+A');
    if (value.length > 0) {
        await locator.pressSequentially(value);
    } else {
        await locator.press('Backspace');
    }
    await locator.press('Tab');
    await expect(locator).toHaveValue(value);
}

async function openFlutterApp(page, route = '/') {
    await page.goto(route);
    await page.locator('flutter-view').waitFor({ state: 'attached' });
    const accessibilityPrompt = page.locator('flt-semantics-placeholder');
    if (await accessibilityPrompt.count()) {
        await accessibilityPrompt.evaluate((element) => element.click());
    }
}

async function openLogin(page) {
    await openFlutterApp(page, '/');
    await expect(page.getByText('Welcome Back!', { exact: true })).toBeVisible();
    await expect(page.getByRole('textbox', { name: 'Email' })).toBeVisible();
}

async function login(page) {
    if (!userEmail || !userPassword) {
        throw new Error(
            'Set BOOKSBOUND_E2E_EMAIL and BOOKSBOUND_E2E_PASSWORD to run authenticated E2E tests.',
        );
    }

    await openFlutterApp(page, '/');
    const loginOrStore = page
        .getByText('Welcome Back!', { exact: true })
        .or(page.getByText('Bestsellers', { exact: true }));
    await expect(loginOrStore).toBeVisible({ timeout: 45_000 });
    if (await page.getByText('Bestsellers', { exact: true }).count()) return;
    await expect(page.getByText('Welcome Back!', { exact: true })).toBeVisible();
    await fillFlutterField(page.getByRole('textbox', { name: 'Email' }), userEmail);
    await fillFlutterField(
        page.getByRole('textbox', { name: 'Password', exact: true }),
        userPassword,
    );
    await page.getByRole('button', { name: 'Login' }).last().click();
    await expect(page.getByText('Bestsellers', { exact: true })).toBeVisible({
        timeout: 45_000,
    });
}

async function openProfile(page) {
    await page.getByRole('button', { name: 'Profile tab' }).last().click();
    await expect(page.getByText('Profile', { exact: true })).toBeVisible();
    await expect(page.getByText(userEmail, { exact: true })).toBeVisible();
}

async function openSearch(page) {
    await page.getByRole('button', { name: 'Search tab' }).click();
    return page.getByRole('textbox', { name: 'Search Title, Author, ISBN no' });
}

async function openCart(page) {
    await page.getByRole('button', { name: 'Cart tab' }).click();
    await expect(page.getByText('My Cart', { exact: true })).toBeVisible();
}

async function openBookFromHome(page, title) {
    await page.getByRole('button', { name: 'Home tab' }).click();
    await expect(page.getByText('Bestsellers', { exact: true })).toBeVisible();
    await page.getByRole('button', { name: new RegExp(title) }).first().click();
    await expect(page.getByRole('heading', { name: title, exact: true })).toBeVisible();
}

module.exports = {
    login,
    fillFlutterField,
    openBookFromHome,
    openCart,
    openFlutterApp,
    openLogin,
    openProfile,
    openSearch,
    userEmail,
    userPassword,
};
