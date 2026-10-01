# Project Submission: BookStore App

## Submission Metadata

| Attribute | Details |
| :--- | :--- |
| **Project Name** | BookStore App (BooksBound) |
| **Program / Course** | Advanced Diploma in Software Engineering |
| **Repository URL** | https://github.com/MuhammadAnees110/booksbound-app |
| **Target Platforms** | Android (API level 21+), iOS |
| **Core Stack** | Flutter, Dart, Firebase Cloud Firestore, Firebase Auth, jsDelivr CDN, Node.js Admin SDK |

---

## Technical Highlights

1. **Decoupled Media Storage & CDN Architecture**:
   - 24 book covers and 8 category images are decoupled from the core application repository and hosted on an external Git CDN repository (`chotabahi/book-app-assets`).
   - Media is delivered globally via jsDelivr CDN edge caches. This keeps the application source lightweight, eliminates heavy binary bloat in Git history, and prevents Firestore document size and read quota exhaustion.

2. **Offline-First Image Pipeline**:
   - Standardized on a centralized `CachedImage` component built on `cached_network_image`.
   - Dual-tier memory and disk caching allows books to render instantly on repeated views even without active internet connectivity.
   - Prevents memory pressure (OOM) on resource-constrained devices via dynamic `memCacheWidth`/`memCacheHeight` constraints.
   - Includes shimmer skeleton loaders during network transit and automatic asset fallbacks on network dropouts.

3. **Defensive Model Deserialization**:
   - All data parsing logic (`Book.fromMap`, `CategoryModel.fromMap`, `fromJson`) enforces strict null-aware type casting (`(data['coverUrl'] as String?) ?? ''`).
   - Prevents runtime fatal `TypeError` and `NullCheck` crashes from missing or malformed remote database fields.

---

## Instructions for Evaluators

### 1. Firebase Credentials Setup
Due to security best practices, live Firebase client keys and service account tokens are excluded from this repository and ZIP archive.

To run the application against your own Firebase project:
1. Obtain your Android configuration file (`google-services.json`) from the Firebase Console.
2. Place it in the Android application directory:
   ```
   android/app/google-services.json
   ```
*(For iOS evaluation, place `GoogleService-Info.plist` inside `ios/Runner/`)*.

### 2. Dependency Installation & Execution
Open a terminal in the project root directory and execute:

```bash
# 1. Fetch Flutter packages
flutter pub get

# 2. Run static analyzer to confirm code quality
flutter analyze

# 3. Launch application on a connected device or emulator
flutter run
```

To run a production-optimized release build on an Android device:
```bash
flutter run --release
```

### 3. Test Accounts

| Account | Email | Password | Role |
| :--- | :--- | :--- | :--- |
| **Admin** | `admin@booksbound.demo` | `Admin@123` | `admin` |
| **Customer** | `customer@booksbound.demo` | `Customer@123` | `user` |
| **Password reset** | `reset@booksbound.demo` | `Reset@123` | |

- **Admin Account**: Has elevated privileges to access role-protected catalog management (CRUD operations on books) and review moderation.
- **Customer Account**: Standard shopping account for browsing, adding to cart/wishlist, placing orders, and leaving reviews.
- **Password Reset**: Dedicated account configured for testing email password recovery flows.

### 4. Pre-Compiled Release Binary
A pre-compiled standalone release APK is provided alongside this source archive:
- File: `Executable_APK/BookStore_App.apk`
- You can install it directly to an Android test device via ADB:
  ```bash
  adb install BookStore_App.apk
  ```
- The APK is signed with the Android debug key (certificate SHA-1 `79:86:2C:A6:F4:8C:86:C7:07:92:CC:F5:4A:23:E6:58:6D:9C:5F:75`). Release builds use the upload key from `android/key.properties` when that keystore is present and fall back to the debug key otherwise. For "Continue with Google" on Android, this SHA-1 must be registered in Firebase Console → Project settings → Android app.

### Screenshots
Screens captured from the running app are in `Media_and_Assets/Screenshots/`: login with Google sign-in, home (categories, authors, bestsellers), book details, books by author, profile, shipping addresses, payment methods, add-card form, cart, checkout with saved address and payment choice, order confirmation, live order tracking (Shipped and Delivered), admin order management, and Help & FAQ. Files prefixed `android_` were captured from the release APK running on an Android emulator.

### 5. Technical Documentation
Full technical documentation is located in the [`docs/`](docs/README.md) directory:
- [docs/README.md](docs/README.md) — Master documentation index
- [docs/OVERVIEW.md](docs/OVERVIEW.md) — System features and capabilities
- [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md) — Architectural layers, image pipeline, and model safety
- [docs/DATABASE_AND_CDN.md](docs/DATABASE_AND_CDN.md) — Firestore collections, schema specs, CDN path conventions, and database seeding instructions
- [docs/SETUP_AND_BUILD.md](docs/SETUP_AND_BUILD.md) — Development setup, build commands, and security practices
- [docs/PRESENTATION_NOTES.md](docs/PRESENTATION_NOTES.md) — Technical talking points for code walkthroughs
- [docs/USER_GUIDE.md](docs/USER_GUIDE.md) — End-user guide, tutorials and FAQ (also in the app under Profile → Help & FAQ)
