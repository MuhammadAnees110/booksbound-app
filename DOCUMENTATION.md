# BooksBound eProject Final Documentation

## 1. Executive Summary

BooksBound is a Flutter-based bookstore and e-commerce application developed for the Aptech eProject submission. The app delivers a complete customer experience for browsing, searching, reviewing, saving, and purchasing books, while also including an admin area for catalog, user, and order management.

The application uses Flutter for the client interface and Firebase for all backend services, including:

- Firebase Authentication for user registration, login, logout, and password reset
- Cloud Firestore for book catalog, users, orders, reviews, and wishlist records
- Firebase Storage for profile images and uploaded book/media assets
- Firebase App Check and security rules to protect backend resources
- Analytics tracking for product events and store activity

This codebase currently follows the project’s working state using Flutter + Firebase with Provider/ChangeNotifier state management. The app architecture is structured by feature and supports a clean modular extension path for future enhancement.

---

## 2. Architecture Overview

### Architectural approach

BooksBound follows feature-first clean architecture principles:

- Presentation is separated into screens and reusable widgets.
- Business state and mutations are handled by `ChangeNotifier` providers.
- Firebase access and business operations are isolated in services.
- Models provide typed serialization between the app and Firestore.
- `AppConstants` centralizes collection identifiers and `AppRoutes` centralizes navigation.
- Defensive error handling, offline persistence, and connectivity checks provide fault-tolerant behavior.

### Project layers

- `lib/features/` — modular user and admin workflows
- `lib/providers/` — reactive state controllers
- `lib/services/` — Firebase, analytics, order, and connectivity APIs
- `lib/models/` — typed domain models and serialization
- `lib/routes/` — named routes and generated route handling
- `lib/widgets/` — shared reusable UI components
- `lib/core/` — theme and shared application definitions
- `lib/constants/` — collection names and app-wide constants

### Provider state management

The application registers 11 domain-specific Provider `ChangeNotifier` classes at the root:

1. `BookProvider` — catalog, category filtering, and search
2. `UserAuthProvider` — authentication lifecycle and session state
3. `ProfileProvider` — profile data, avatars, and role detection
4. `CartProvider` — cart items, quantities, and totals
5. `WishlistProvider` — Firestore-synchronised saved books
6. `ReviewsProvider` — review loading and submission
7. `RatingsProvider` — star-rating state
8. `CategoryProvider` — bookstore categories
9. `ThemeProvider` — persisted light/dark theme selection
10. `AdminUsersProvider` — administrative user operations
11. `AdminAnalyticsProvider` — administrative metrics

### Firebase backend

- Authentication: email/password sign up, sign in, logout, password reset, and password change
- Firestore: books, categories, users, carts, wishlist data, orders, and reviews
- Storage: profile pictures and catalog cover assets
- App Check: Android Play Integrity and Apple App Attest with DeviceCheck fallback
- Offline support: Firestore persistence with a 50 MB local cache

### Navigation and deep linking

Named routes are defined in `lib/routes/app_routes.dart` and are connected to the global `NavigatorState` key. App Links handles book URLs such as `https://booksbound-app-boka18.web.app/book/{bookId}` on cold start and while the app is running, loads the referenced Firestore book, and opens its details screen.

---

## 3. Functional Requirements Coverage Verification

The app implements the requested eProject modules and their core workflows as follows.

| Requirement                                   | Status                | Evidence in project                                                                                                                                                                                                        |
| --------------------------------------------- | --------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| User Registration & Authentication            | Partially implemented | Email/password registration, login, logout, password reset, and password change are implemented. Social-media sign-in is not included.                                                                                     |
| Book Catalog                                  | Implemented           | `lib/features/home/home_screen.dart`, `lib/features/categories/categories_screen.dart`, `lib/providers/book_provider.dart`, `lib/services/books_service.dart`                                                              |
| Categories, Genres, Bestsellers, New Arrivals | Implemented           | `lib/services/category_service.dart`, `lib/features/categories/category_books_screen.dart`, `lib/providers/category_provider.dart`                                                                                         |
| Search & Advanced Filtering                   | Implemented           | `lib/features/search/search_screen.dart`, `lib/services/books_service.dart`                                                                                                                                                |
| User Profiles                                 | Implemented           | `lib/features/profile/profile_screen.dart`, `lib/features/edit_profile/edit_profile_screen.dart`, `lib/services/user_service.dart`                                                                                         |
| Shipping Address                              | Implemented           | `lib/features/cart/checkout_screen.dart`                                                                                                                                                                                   |
| Payment Methods                               | Not implemented       | Checkout captures a shipping address and creates an order; no saved payment methods or live payment gateway is included.                                                                                                   |
| Shopping Cart                                 | Implemented           | `lib/providers/cart_provider.dart`, `lib/features/cart/cart_screen.dart`                                                                                                                                                   |
| Ratings & Reviews                             | Implemented           | Ratings, written reviews, review display, and review likes are implemented in `lib/providers/reviews_provider.dart`, `lib/features/book_details/widgets/write_review_sheet.dart`, and `lib/services/reviews_service.dart`. |
| Order Management & Tracking                   | Implemented           | `lib/models/order_model.dart`, `lib/services/order_service.dart`, `lib/features/profile/profile_screen.dart`, `lib/features/admin/manage_orders/manage_orders_screen.dart`                                                 |
| Admin Panel                                   | Implemented           | `lib/features/admin/admin_panel_screen.dart`, `lib/features/admin/manage_books/manage_books_screen.dart`, `lib/features/admin/manage_users/manage_users_screen.dart`                                                       |
| Wishlist Management                           | Implemented           | `lib/providers/wishlist_provider.dart`, `lib/services/wishlist_service.dart`, `lib/features/wishlist/wishlist_screen.dart`                                                                                                 |

### PDF requirement gaps and scope notes

The PDF specification is the authoritative requirement source. The implemented application covers the core bookstore, cart, review, order, admin, and wishlist workflows. Three PDF items remain outside the current implementation: social-media authentication, saved payment methods/live payment processing, and a separate FAQ/tutorial module. The video demonstration requirement is covered by the recording outline in this document; an actual recording must be supplied separately with the final submission.

### Non-functional requirements traceability

- Responsiveness and loading time: bounded Firestore reads, loading skeletons, cached images, offline persistence, and connectivity feedback support responsive interaction.
- User interface, accessibility, and usability: consistent Material themes, legible controls, validation messages, clear navigation, and light/dark themes are provided.
- Operability and error handling: service results, Firebase error mapping, loading states, offline guards, and user-facing error messages are implemented.
- Scalability: feature-first separation, service boundaries, pagination, Firebase-managed infrastructure, and bounded queries support future growth.
- Security: Firebase Authentication, Firestore RBAC, Storage ownership rules, App Check, and account deletion controls are implemented.
- User documentation: setup, feature coverage, assessor credentials, demo flow, and packaging guidance are provided in this document and `README.md`.
- Developer documentation: architecture and security details are provided in `docs/architecture.md` and `docs/security.md`.
- Video: the recording outline is included in Section 8; the completed video file should be added to the submission package.

---

## 4. Admin & Test User Credentials for Assessors

The app uses Firebase Authentication with email/password sign-in. For demonstration, assessor accounts can be created directly in Firebase Console or during the local app setup.

### 6.3 Test Accounts

| Account | Email | Password | Role |
| :--- | :--- | :--- | :--- |
| **Admin** | `admin@booksbound.demo` | `Admin@123` | `admin` |
| **Customer** | `customer@booksbound.demo` | `Customer@123` | `user` |
| **Password reset** | `reset@booksbound.demo` | `Reset@123` | |


### How to assign admin access

1. Create the admin user in Firebase Authentication.
2. Add or update the matching Firestore document in the `users` collection with:
   - `email: "admin@booksbound.demo"`
   - `role: "admin"`
   - `name: "Admin User"`
3. Sign in using the admin email and password to access the admin dashboard.

> These credentials are intended as demo/test assessor accounts and should be created once for the verification session.

---

## 5. Setup & Build Instructions

### Prerequisites

- Flutter SDK 3.x
- Dart SDK included with Flutter
- Android Studio / Android SDK (for Android builds)
- Firebase CLI (optional but recommended for deployment and rules sync)
- A Firebase project linked to this app

### Install dependencies

```bash
flutter pub get
```

### Run the app

```bash
flutter run
```

### Run the app on a specific device

```bash
flutter devices
flutter run -d <device-id>
```

### Analyze the project

```bash
flutter analyze
```

### Build Android app bundle

```bash
flutter build appbundle
```

### Optional build with symbols output

```bash
flutter build appbundle --obfuscate --split-debug-info=booksbound-symbols
```

---

## 6. Firebase Setup Notes

Before running the app in a real environment, ensure the project is connected to the Firebase project configured in this repository.

Required files and checks:

- `android/app/google-services.json`
- `lib/firebase_options.dart`
- Firebase project enabled for Authentication, Firestore, and Storage
- Firestore rules deployed
- Storage rules deployed

Rule deployment examples:

```bash
firebase deploy --only firestore:rules
firebase deploy --only storage
```

---

## 7. Security & Spark Plan Quota Compliance Summary

The project has been hardened for a safe assessment and demo environment.

### Authentication and App Check

- Passwords are managed exclusively by Firebase Authentication and are not stored in Firestore as plaintext credentials.
- Firebase session tokens are managed by the Firebase Auth SDK.
- Android uses Play Integrity for App Check; Apple uses App Attest with DeviceCheck fallback.
- App Check startup is guarded so a temporary App Check configuration failure does not crash the client.

### Firestore and Storage authorization

- Books and categories are publicly readable; writes are restricted to administrators.
- User profile updates require ownership or administrator access.
- Cart and wishlist records require an authenticated owner.
- Reviews are publicly readable; authors and administrators control edits/deletes.
- Customers can create/read their own orders; administrators control fulfillment status and deletion.
- Storage access requires authentication and ownership, with image MIME validation and a 5 MB upload limit.

### Account deletion and legal compliance

The in-app Profile > Delete Account flow requires typed confirmation. It removes cart and wishlist records, deletes profile photos, removes the Firestore user profile, anonymizes retained order/review references as `deleted_user`, and permanently deletes the Firebase Auth account. Privacy Policy and Terms of Service files are stored in `legal/` and linked from the app.

### API key controls

For production deployment, Firebase client API keys should remain restricted in Google Cloud Console by application identity and only the APIs required by the app. Verify the Android package name and signing certificate fingerprints before release.

### Remediation and quota controls

- Base64 profile image payloads were replaced with Firebase Storage URLs.
- Catalog reads use limits and pagination instead of unbounded collection reads.
- Firestore and Storage access is protected by rules.

### Spark plan compliance notes

Firebase Spark Free plan is intentionally suitable for a lightweight demo and student project. To remain within practical limits:

- keep datasets small and curated
- use bounded queries and pagination
- avoid importing large bulk datasets
- limit image sizes and use compressed uploads
- do not run large repeated scripts in production without project upgrade

### Summary

This project maintains a security-conscious and cost-aware design suitable for a student eProject and assessor demo environment, while still demonstrating realistic Firebase app architecture.

---

## 8. Video Demonstration Script / Screen-recording Outline

The following outline is recommended for a clean 5–8 minute project video for assessment.

### Opening (0:00–0:30)

- Show app splash/loading screen
- Introduce the app name: BooksBound
- Show the home screen with categories and book cards

### User registration and login (0:30–1:30)

- Open the register screen
- Create a new user account using a demo email
- Complete sign-in flow
- Show login and password reset flow

### Catalog browsing (1:30–2:30)

- Browse categories and bestseller sections
- Open a book details page
- Demonstrate title/author/genre listing and cover images

### Search, wishlist, and cart (2:30–3:30)

- Search by title or author
- Use filtering / category navigation
- Add a book to wishlist
- Add item to cart
- Adjust quantity and show live recalculation of total

### Reviews and profile (3:30–4:30)

- Open a book and submit a rating/review
- Open profile screen
- Edit profile details and photo
- Show shipping address being entered during checkout

### Checkout and order tracking (4:30–5:30)

- Proceed to checkout
- Enter shipping address
- Place order
- Show order confirmation screen
- View order history and tracking status in profile

### Admin panel (5:30–7:00)

- Login as admin account
- Open admin dashboard
- Manage books (add/edit/delete)
- Open user management screen
- Open orders panel and update order status

### Closing (7:00–8:00)

- Summarize the completed features
- Highlight security and app quality improvements
- Show final home or profile screen

---

## 9. Final Submission Packaging Instructions

The Aptech eProject submission should be packaged as a clean ZIP archive with the project root folder included in the archive.

### Recommended ZIP file name

```text
BooksBound_Final_Submission.zip
```

### Folder structure inside the ZIP

```text
BooksBound_Final_Submission/
├── README.md
├── DOCUMENTATION.md
├── pubspec.yaml
├── pubspec.lock
├── firebase.json
├── firestore.rules
├── storage.rules
├── .firebaserc
├── .gitignore
├── android/
├── ios/
├── web/
├── linux/
├── macos/
├── windows/
├── lib/
├── assets/
├── docs/
├── legal/
├── store_listing/
├── booksbound-symbols/
├── scripts/
└── build/   (only if required by examiner instructions; otherwise exclude generated output)
```

### Recommended EXCLUDE list for ZIP creation

Do not include:

- `.git/`
- `node_modules/`
- `.dart_tool/`
- `build/` unless specifically requested
- IDE local folders such as `.idea/` or `.vscode/` if not required

### PowerShell ZIP command

```powershell
Compress-Archive -Path .\README.md, .\DOCUMENTATION.md, .\pubspec.yaml, .\pubspec.lock, .\firebase.json, .\firestore.rules, .\storage.rules, .\android, .\ios, .\web, .\linux, .\macos, .\windows, .\lib, .\assets, .\docs, .\legal, .\store_listing, .\booksbound-symbols, .\scripts -DestinationPath .\BooksBound_Final_Submission.zip -Force
```

### Alternative ZIP command (folder-based)

```powershell
Compress-Archive -Path .\Flutter-Book-Store-App-main -DestinationPath .\BooksBound_Final_Submission.zip -Force
```

> If the examiner expects the project to be submitted as a clean folder instead of a repo archive, package the project root in a folder named `Flutter-Book-Store-App-main` and zip that folder directly.

---

## 10. Final Submission Summary

BooksBound is a complete bookstore eProject containing the required customer and admin flows for an Aptech assessment. The repository includes the app source, Firebase integration, security hardening, and complete user-facing functionality. With the project analyzed as clean and ready for reporting, this documentation package provides the final assessor handoff, setup instructions, and packaging guidance required for submission.
