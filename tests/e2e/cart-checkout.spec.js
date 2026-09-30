const { test, expect } = require('./support/fixtures');
const { login, openBookFromHome, openCart, userEmail, userPassword } = require('./support/app');

test.beforeEach(async ({ page }) => {
    test.skip(!userEmail || !userPassword, 'Set the dedicated E2E account environment variables.');
    await login(page);
});

test('cart create, read, stock boundary, update, and delete lifecycle', async ({ page }) => {
    await openBookFromHome(page, 'Steve Jobs');
    await page.getByRole('button', { name: 'Add to Cart' }).last().click();
    await expect(page.getByText('Added to Cart').last()).toBeVisible();

    await openCart(page);
    await expect(page.getByText('$17.99', { exact: true })).toBeVisible();
    const increase = page.getByRole('button', { name: 'Increase quantity' });
    for (let quantity = 1; quantity < 20; quantity += 1) {
        await increase.click();
    }

    const cappedIncrease = page.getByRole('button', { name: 'Maximum stock reached' });
    await expect(cappedIncrease).toBeDisabled();
    await expect(page.getByText('$359.80', { exact: true })).toBeVisible();
    await expect(page.getByText('Maximum stock reached for Steve Jobs.').last()).toBeVisible();

    await page.getByRole('button', { name: 'Decrease quantity' }).click();
    await expect(page.getByText('$341.81', { exact: true })).toBeVisible();
    await expect(page.getByRole('button', { name: 'Increase quantity' })).toBeEnabled();

    await page.getByRole('button', { name: 'Remove from cart' }).click();
    await expect(page.getByText('Your cart is empty')).toBeVisible();
});

test('checkout validates the shipping address without creating an order', async ({ page }) => {
    await openBookFromHome(page, 'Steve Jobs');
    await page.getByRole('button', { name: 'Add to Cart' }).last().click();
    await openCart(page);
    await page.getByRole('button', { name: 'Checkout' }).last().click();

    await expect(page.getByText('Total: $17.99')).toBeVisible();
    await page.getByRole('button', { name: 'Place Order' }).last().click();
    await expect(page.getByText('Please enter Shipping Address').last()).toBeVisible();
    await expect(page.getByText('Order Placed!', { exact: true })).toHaveCount(0);
});
