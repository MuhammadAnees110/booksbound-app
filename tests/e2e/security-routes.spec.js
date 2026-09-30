const { test, expect } = require('./support/fixtures');
const { login, openFlutterApp, userEmail, userPassword } = require('./support/app');

test('admin URLs redirect an unauthenticated browser to Login', async ({ page }) => {
  await openFlutterApp(page, '/#/admin-panel/manage-books');
  await expect(page.getByText('Welcome Back!', { exact: true })).toBeVisible({ timeout: 30_000 });
  await expect(page.getByRole('textbox', { name: 'Email' })).toBeVisible();
});

test('regular users are denied every directly-addressable admin screen', async ({ page }) => {
  test.skip(!userEmail || !userPassword, 'Set the dedicated E2E account environment variables.');
  await login(page);

  const adminRoutes = [
    '/#/admin-panel',
    '/#/admin-panel/manage-books',
    '/#/admin-panel/manage-orders',
    '/#/admin-panel/manage-reviews-books',
    '/#/admin-panel/manage-users',
    '/#/admin-panel/analytics',
  ];
  for (const route of adminRoutes) {
    await page.goto(route);
    await expect(page.getByText('Access Denied', { exact: true }), route).toBeVisible();
    await expect(page.getByText('Add New Book', { exact: true })).toHaveCount(0);
  }
});

test('unknown and parameter-dependent direct URLs render not-found instead of crashing', async ({ page }) => {
  const invalidRoutes = [
    '/#/not-a-real-route',
    '/#/book/book-details',
    '/#/categories/books',
    '/#/admin-panel/manage-reviews-books/manage-reviews',
    '/#/checkout/order-success',
  ];

  for (const route of invalidRoutes) {
    await page.goto(route);
    await page.locator('flutter-view').waitFor({ state: 'attached' });
    const accessibilityPrompt = page.locator('flt-semantics-placeholder');
    if (await accessibilityPrompt.count()) {
      await accessibilityPrompt.evaluate((element) => element.click());
    }
    await expect(page.getByText('Route not found', { exact: true }), route).toBeVisible();
  }
});

test('login page remains usable without horizontal overflow at desktop, tablet, and mobile widths', async ({ page }) => {
  await openFlutterApp(page, '/');
  for (const viewport of [
    { width: 1440, height: 900 },
    { width: 768, height: 1024 },
    { width: 375, height: 812 },
  ]) {
    await page.setViewportSize(viewport);
    await expect(page.getByRole('button', { name: 'Login' }).last()).toBeVisible();
    const dimensions = await page.evaluate(() => ({
      viewportWidth: window.innerWidth,
      documentWidth: document.documentElement.scrollWidth,
    }));
    expect(dimensions.documentWidth).toBeLessThanOrEqual(dimensions.viewportWidth);
  }
});

test('authenticated home navigation remains usable at desktop, tablet, and mobile widths', async ({ page }) => {
  test.skip(!userEmail || !userPassword, 'Set the dedicated E2E account environment variables.');
  await login(page);
  for (const viewport of [
    { width: 1440, height: 900 },
    { width: 768, height: 1024 },
    { width: 375, height: 812 },
  ]) {
    await page.setViewportSize(viewport);
    await expect(page.getByText('Bestsellers', { exact: true })).toBeVisible();
    for (const tab of ['Home tab', 'Search tab', 'Cart tab', 'Profile tab']) {
      await expect(page.getByRole('button', { name: tab })).toBeVisible();
    }
    const dimensions = await page.evaluate(() => ({
      viewportWidth: window.innerWidth,
      documentWidth: document.documentElement.scrollWidth,
    }));
    expect(dimensions.documentWidth).toBeLessThanOrEqual(dimensions.viewportWidth);
  }
});
