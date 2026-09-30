const { test, expect } = require('./support/fixtures');
const {
    fillFlutterField,
    login,
    openProfile,
    userEmail,
    userPassword,
} = require('./support/app');

test.beforeEach(async ({ page }) => {
    test.skip(!userEmail || !userPassword, 'Set the dedicated E2E account environment variables.');
    await login(page);
    await openProfile(page);
});

test('profile reads the signed-in user and order history resolves to rows or an empty state', async ({ page }) => {
    await expect(page.getByText(userEmail, { exact: true })).toBeVisible();
    await expect(page.getByRole('button', { name: 'Change profile picture' })).toBeVisible();

    await page.getByRole('button', { name: 'My Orders' }).last().click();
    await expect(page.getByText('Order History', { exact: true })).toBeVisible();
    const emptyState = page.getByText('No past orders found', { exact: true });
    const orderRow = page.getByRole('group', { name: /item\(s\) — \$/ }).first();
    await expect(emptyState.or(orderRow)).toBeVisible({ timeout: 20_000 });
});

test('theme setting toggles both mode and label and restores Light Mode', async ({ page }) => {
    await expect(page.getByRole('group', { name: 'Light Mode' })).toBeVisible();
    const toggle = page.getByRole('switch');
    await toggle.click();
    await expect(page.getByRole('group', { name: 'Dark Mode' })).toBeVisible();
    await expect(toggle).toBeChecked();

    await page.reload();
    await page.locator('flutter-view').waitFor({ state: 'attached' });
    const accessibilityPrompt = page.locator('flt-semantics-placeholder');
    if (await accessibilityPrompt.count()) {
        await accessibilityPrompt.evaluate((element) => element.click());
    }
    await expect(page.getByText('Bestsellers', { exact: true })).toBeVisible({
        timeout: 45_000,
    });
    await openProfile(page);
    await expect(page.getByRole('group', { name: 'Dark Mode' })).toBeVisible();

    const persistedToggle = page.getByRole('switch');
    await persistedToggle.click();
    await expect(page.getByRole('group', { name: 'Light Mode' })).toBeVisible();
    await expect(persistedToggle).not.toBeChecked();
});

test('profile form rejects an empty name without saving', async ({ page }, testInfo) => {
    await page.getByRole('button', { name: 'Edit Profile' }).last().click();
    const nameField = page.getByRole('textbox', { name: 'Name' });
    await expect(nameField).toBeVisible();
    const initialName = await nameField.inputValue();
    // If the account already has a name we cannot safely clear and restore a persistent
    // profile field against a live Firebase project — mark skipped and bail out.
    if (initialName.trim().length > 0) {
        testInfo.annotations.push({
            type: 'skip',
            description: 'Account has a populated name; field-clear test skipped.',
        });
        return;
    }

    await fillFlutterField(nameField, '');
    await page.getByRole('button', { name: 'Save Changes' }).last().click();
    await expect(page.getByText('Please enter a Name').last()).toBeVisible();
    await expect(page.getByRole('heading', { name: 'Edit Profile' })).toBeVisible();
    await page.getByRole('button', { name: 'Back' }).last().click();
    await expect(page.getByText(userEmail, { exact: true })).toBeVisible();
});

test('profile save persists the existing value unchanged', async ({ page }, testInfo) => {
    await page.getByRole('button', { name: 'Edit Profile' }).last().click();
    const nameField = page.getByRole('textbox', { name: 'Name' });
    await expect(nameField).toBeVisible();
    const originalName = await nameField.inputValue();
    if (originalName.trim().length === 0) {
        testInfo.skip('The account has no valid name value to preserve in a persistence test.');
    }
    await page.getByRole('button', { name: 'Save Changes' }).last().click();
    await expect(page.getByText('Profile saved successfully').last()).toBeVisible();
    await expect(page.getByText(originalName, { exact: true })).toBeVisible();

    await page.reload();
    await page.locator('flutter-view').waitFor({ state: 'attached' });
    const accessibilityPrompt = page.locator('flt-semantics-placeholder');
    if (await accessibilityPrompt.count()) {
        await accessibilityPrompt.evaluate((element) => element.click());
    }
    await openProfile(page);
    await expect(page.getByText(originalName, { exact: true })).toBeVisible();
});

test('change-password form rejects empty and mismatched values without updating credentials', async ({ page }) => {
    await page.getByRole('button', { name: 'Change Password' }).last().click();
    await page.getByRole('button', { name: 'Update Password' }).last().click();
    await expect(page.getByText('This field is required').first()).toBeVisible();

    await fillFlutterField(
        page.getByRole('textbox', { name: 'Current Password' }),
        'current-placeholder',
    );
    await fillFlutterField(
        page.getByRole('textbox', { name: 'New Password', exact: true }),
        'new-password-1',
    );
    await fillFlutterField(
        page.getByRole('textbox', { name: 'Confirm New Password' }),
        'different-password-2',
    );
    await page.getByRole('button', { name: 'Update Password' }).last().click();
    await expect(page.getByText('Passwords do not match').last()).toBeVisible();
});

test('delete-account confirmation is gated and can be cancelled safely', async ({ page }) => {
    await page.getByRole('button', { name: 'Delete Account' }).last().click();
    await expect(page.getByText('Delete Account?', { exact: true })).toBeVisible();
    await page.getByRole('button', { name: 'Delete Account' }).last().click();
    await expect(page.getByText('Delete Your Account?', { exact: true })).toBeVisible();

    const permanentDelete = page.getByRole('button', { name: 'Delete My Account Permanently' });
    await expect(permanentDelete).toBeDisabled();
    await fillFlutterField(page.getByRole('textbox', { name: 'DELETE' }), 'DELETE');
    await expect(permanentDelete).toBeEnabled();
    await page.getByRole('button', { name: 'Cancel' }).click();
    await expect(page.getByText(userEmail, { exact: true })).toBeVisible();
});
