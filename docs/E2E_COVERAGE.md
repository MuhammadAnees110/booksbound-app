# Playwright E2E Coverage

The E2E suite targets the compiled Flutter web application against the configured Firebase project. Run it with a dedicated test account using `BOOKSBOUND_E2E_EMAIL` and `BOOKSBOUND_E2E_PASSWORD`; credentials are read only from the process environment.

## Routes and Screens

| Route or navigation surface                       | Screen/feature                                     | Coverage policy                                                                                                                       |
| ------------------------------------------------- | -------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------- |
| `/`                                               | Splash and authentication redirect                 | Verify unauthenticated startup reaches Login and authenticated refresh reaches the store.                                             |
| `/login`                                          | Email/password login                               | Empty, invalid email, rejected credentials, successful login, persistence, logout.                                                    |
| `/register`                                       | Account registration                               | Required fields, password confirmation, duplicate existing email. Successful account creation is not run against production Firebase. |
| `/forgot-password`                                | Password reset                                     | Invalid email and navigation back. A real reset email is not sent.                                                                    |
| `/main`                                           | Home/storefront                                    | Bestseller/catalog data, book detail, search, categories, bottom tabs.                                                                |
| Main `Search` tab                                 | Search                                             | Case-insensitive query, exact result inclusion/exclusion, no-result state.                                                            |
| Main `Cart` tab                                   | Cart                                               | Add item, increase to stock ceiling, disabled plus control, snackbar, checkout validation.                                            |
| Main `Profile` tab                                | Profile                                            | Identity display, order history, settings, theme, profile/password validation, logout.                                                |
| Header Categories action / `/categories`          | Categories                                         | Open categories and enter a category.                                                                                                 |
| `/categories/books`                               | Category books                                     | Open a seeded category and verify its books/banner. Direct entry without a category argument returns not found.                       |
| `/book/book-details`                              | Book detail, rating, review, wishlist, add-to-cart | Read product, open review form and test empty validation. Review/rating writes are not submitted.                                     |
| `/wishlist`                                       | Wishlist                                           | Read existing account list and verify navigation. Toggle is not run unless the test can restore the exact initial state.              |
| `/cart/checkout`                                  | Checkout                                           | Verify total and required shipping address validation. Place Order is not submitted.                                                  |
| `/checkout/order-success`                         | Order confirmation                                 | Direct entry without order arguments returns not found. A production order is not created.                                            |
| `/profile/edit-profile`                           | Edit profile                                       | Read current value and required-name validation. Any persistent update must be restored to the original value.                        |
| `/profile/change-password`                        | Change password                                    | Empty and mismatch validation. Password is not changed.                                                                               |
| `/profile/delete-account`                         | Delete account                                     | Confirmation gating and cancel only. Permanent deletion is never submitted.                                                           |
| `/admin-panel`                                    | Admin panel                                        | Direct non-admin access is denied.                                                                                                    |
| Admin books/orders/reviews/users/analytics routes | Admin CRUD and reporting                           | Direct non-admin access is denied; CRUD writes require a dedicated admin test project/account and are not attempted.                  |
| Unknown route and parameter-dependent routes      | Route fallback                                     | Verify malformed direct URLs render the not-found UI rather than a blank page/crash.                                                  |

## Data Safety Boundaries

The suite may authenticate, read catalog/profile/order data, attempt invalid credentials, validate forms, and change ephemeral cart state. It does not create accounts, send password-reset email, change passwords, submit orders, submit reviews/ratings, delete accounts, or mutate admin-managed catalog/user/order records. Admin CRUD requires an isolated Firebase project with seeded admin credentials; the configured production project is not a safe target for those writes.

Order History tests use the configured account's existing order data. The empty-order state is covered by UI logic inspection but cannot be reached for an account that already has orders without a dedicated empty test account.
