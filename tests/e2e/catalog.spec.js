const { test, expect } = require('./support/fixtures');
const {
    fillFlutterField,
    login,
    openBookFromHome,
    openSearch,
    userEmail,
    userPassword,
} = require('./support/app');

const authenticated = test.extend({});

authenticated.beforeEach(async ({ page }, testInfo) => {
    testInfo.skip(!userEmail || !userPassword, 'Set the dedicated E2E account environment variables.');
    await login(page);
});

authenticated('search matches title, author, and category without unrelated results', async ({ page }) => {
    const search = await openSearch(page);
    await fillFlutterField(search, 'ste');

    await expect(page.getByRole('button', { name: /Steve Jobs/ }).last()).toBeVisible();
    await expect(page.getByRole('button', { name: /Stephen Hawking/ }).last()).toBeVisible();
    await expect(page.getByRole('button', { name: /Big Little Lies/ })).toHaveCount(0);
    await expect(page.getByRole('button', { name: /Gone Girl/ })).toHaveCount(0);
});

authenticated('search shows an empty state and category prefix results', async ({ page }) => {
    const search = await openSearch(page);
    await fillFlutterField(search, 'zzzx-no-match');
    await expect(page.getByText('No books found')).toBeVisible();

    await fillFlutterField(search, 'mys');
    await expect(page.getByRole('button', { name: /Big Little Lies/ }).last()).toBeVisible();
    await expect(page.getByRole('button', { name: /Gone Girl/ }).last()).toBeVisible();
});

authenticated('category navigation opens a seeded category and its books', async ({ page }) => {
    await page.getByRole('button', { name: 'Categories', exact: true }).first().click();
    await expect(page.getByText('Book Categories', { exact: true })).toBeVisible();
    await page.getByRole('button', { name: /Category: Fantasy/ }).last().click();
    await expect(page.getByRole('button', { name: /The Hobbit/ }).last()).toBeVisible();
    await expect(
        page.getByRole('button', { name: /Harry Potter and the Sorcerers Stone/ }).last(),
    ).toBeVisible();
    await expect(page.getByText('No books found')).toHaveCount(0);
});

authenticated('book details and review form validate without writing a review', async ({ page }) => {
    const search = await openSearch(page);
    await fillFlutterField(search, 'Steve Jobs');
    await page.getByRole('button', { name: /Steve Jobs/ }).last().click();
    await expect(page.getByText('by Walter Isaacson', { exact: true })).toBeVisible();
    await expect(page.getByRole('img', { name: 'Book cover for Steve Jobs' }).first()).toBeVisible();

    await page.getByRole('button', { name: 'Write a Review' }).click();
    await expect(page.getByText('Write a Review', { exact: true })).toBeVisible();
    await page.getByRole('button', { name: 'Submit Review' }).click();
    await expect(page.getByText('Please enter a review comment.').last()).toBeVisible();
});

test('category and book image decode failures use fallbacks without crashing', async ({ page }) => {
    await page.route('https://cdn.jsdelivr.net/gh/chotabahi/book-app-assets@main/**', (route) =>
        route.fulfill({ status: 200, contentType: 'image/jpeg', body: Buffer.from('invalid-image-bytes') }),
    );

    test.skip(!userEmail || !userPassword, 'Set the dedicated E2E account environment variables.');
    await login(page);
    await expect(page.getByText('Bestsellers', { exact: true })).toBeVisible();
    await expect(page.getByText("Couldn't load cover")).toHaveCount(0);

    await page.getByRole('button', { name: 'Categories', exact: true }).first().click();
    await page.getByRole('button', { name: /Category: Fantasy/ }).last().click();
    await expect(page.getByRole('button', { name: /The Hobbit/ }).last()).toBeVisible();
    await expect(page.getByText('Fantasy', { exact: true }).first()).toBeVisible();
    await expect(page.getByText("Couldn't load cover")).toHaveCount(0);
});

authenticated('sort sheet exposes every supported sort order', async ({ page }) => {
    await page.getByRole('button', { name: 'Home tab' }).click();
    await page.getByRole('button', { name: 'Sort books' }).click();
    await expect(page.getByText('Sort by', { exact: true })).toBeVisible();
    for (const option of [
        'Price: Low to High',
        'Price: High to Low',
        'Newest Arrivals',
        'Popularity',
    ]) {
        await expect(page.getByText(option, { exact: true })).toBeVisible();
    }
    await page.getByText('Price: Low to High', { exact: true }).click();
    await expect(page.getByText('Sort by', { exact: true })).toHaveCount(0);
});

authenticated('wishlist screen reads existing items or its empty state', async ({ page }) => {
    await page.getByRole('button', { name: 'Wishlist', exact: true }).first().click();
    await expect(page.getByRole('heading', { name: 'Wishlist', exact: true })).toBeVisible();
    const emptyState = page.getByText('No favorites yet', { exact: true });
    const favorite = page.getByRole('button', { name: 'Remove from wishlist' }).first();
    await expect(emptyState.or(favorite)).toBeVisible();
});

authenticated('wishlist toggle returns to its original state', async ({ page }) => {
    await openBookFromHome(page, 'Steve Jobs');
    const addButton = page.getByRole('button', { name: 'Add to wishlist' }).last();
    const removeButton = page.getByRole('button', { name: 'Remove from wishlist' }).last();
    const initiallySaved = (await removeButton.count()) > 0;

    try {
        if (initiallySaved) {
            await removeButton.click();
            await expect(page.getByRole('button', { name: 'Add to wishlist' }).last()).toBeVisible();
        } else {
            await addButton.click();
            await expect(page.getByRole('button', { name: 'Remove from wishlist' }).last()).toBeVisible();
        }
    } finally {
        if (initiallySaved && (await page.getByRole('button', { name: 'Add to wishlist' }).count())) {
            await page.getByRole('button', { name: 'Add to wishlist' }).last().click();
        } else if (!initiallySaved && (await page.getByRole('button', { name: 'Remove from wishlist' }).count())) {
            await page.getByRole('button', { name: 'Remove from wishlist' }).last().click();
        }
    }
});
