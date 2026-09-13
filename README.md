# 📚 BooksBound — Online Book Store App (Flutter + Firebase)

A modern, full-featured, and production-hardened **Digital Book Store mobile application** built using **Flutter** and **Firebase**. Developed as an Aptech HDSE final semester eProject by **Muhammad Anees**.

BooksBound provides an end-to-end reading and e-commerce experience — from dynamic catalog discovery, rich reviews, interactive ratings, wishlist curation, and cart management to secure order processing and full administrative oversight.

---

## 🚀 Features

### 👤 Customer Features
- **User Authentication**: Secure Sign-Up, Sign-In, and Forgot Password email resets via Firebase Authentication with real-time field validation.
- **Deep Linking**: Direct Universal/App Link routing (`/book/{bookId}`) to open book details straight from web links or promotional shares.
- **Offline Resilience**: Offline Firestore persistence (50 MB cache), live network monitoring via `ConnectivityService`, and automatic offline warnings preventing order failures when disconnected.
- **Book Discovery & Search**: Browse catalog across 8 categories (Fiction, Non-Fiction, Children, Academic, Science, History, Biography, Religion), explore bestsellers, and perform live keyword searches.
- **Rich Book Details**: Comprehensive book metadata, synopsis, price formatting, author credits, and community feedback.
- **Ratings & Reviews**: Dynamic 5-star rating system with real-time review submissions via interactive bottom sheets.
- **Wishlist**: Cloud-synced personal wishlist with single-tap "Move All to Cart" bulk transfer.
- **Shopping Cart & Checkout**: Real-time quantity controls, instant item removal, and validation-guarded checkout flow.
- **Order History & Tracking**: Live status tracking (`Pending` ➔ `Processing` ➔ `Shipped` ➔ `Delivered` ➔ `Cancelled`) accessible directly from profile.
- **Dark Mode**: System-aware theme toggle with instant persistent preference caching via `SharedPreferences`.
- **Account Control & Privacy**: Direct in-app Account Deletion with complete personal data purging and anonymization in accordance with Google Play store compliance.

---

### 🛠️ Admin Panel Features
- **Role-Based Access Control (RBAC)**: Secure Firestore rules ensuring only accounts with `role: admin` can access administrative tooling.
- **Book Inventory Management**: Add new books with direct **Firebase Storage** cover image uploads, edit existing titles, or delete catalog items.
- **Order Management**: Real-time stream of all customer orders, expandable line items, shipping addresses, and status update controls.
- **Review Moderation**: Full administrative review moderation and cleanup across the entire catalog.
- **User Administration**: View all registered users, toggle user account lock/block statuses, and assign roles.
- **Store Analytics**: Live store metrics tracking total titles, bestseller counts, user registrations, and order counts.

---

## 🧠 Tech Stack & Architecture

| Technology | Purpose |
|---|---|
| **Flutter 3.x / Dart 3.x** | Cross-platform client framework with strict linting (`flutter_lints`) |
| **Firebase Authentication** | Identity management, password resets, and session tokens |
| **Cloud Firestore** | NoSQL database with offline persistence & security rules |
| **Firebase Storage** | Cloud bucket storage for book covers & user avatars |
| **Firebase App Check** | Backend resource protection via Google Play Integrity attestation |
| **Firebase Analytics** | Privacy-conscious user engagement and transaction logging |
| **Provider** | Reactive, decoupled state management across 11 specialized providers |
| **App Links** | Declarative deep linking and intent filter URL resolution |
| **Connectivity Plus** | Real-time network reachability detection |
| **URL Launcher** | External browser launching for hosted legal documentation |

---

## 📂 Project Structure

```text
lib/
├── constants/             # App-wide constants (Firestore collection names, assets)
│   └── app_constants.dart
├── core/                  # Core design tokens and theme data
│   └── theme/
│       └── app_theme.dart
├── features/              # Feature modules (Feature-First Architecture)
│   ├── admin/             # Admin management (books, orders, reviews, users, analytics)
│   ├── auth/              # Authentication screens (Login, Register, Forgot Password)
│   ├── book_details/      # Detailed book view and review submission sheet
│   ├── cart/              # Shopping cart & checkout flow
│   ├── categories/        # Book category grid and category-filtered books
│   ├── change_password/   # Account password changes
│   ├── edit_profile/      # Profile photo and name customization
│   ├── home/              # Main storefront & bestsellers
│   ├── layout/            # Bottom navigation shell with OfflineBanner
│   ├── profile/           # User dashboard, Order History, legal links & Delete Account
│   ├── search/            # Live catalog search
│   ├── splash/            # Entry splash screen and route gateway
│   └── wishlist/          # Saved books with bulk cart transfer
├── models/                # Typed domain models (Book, User, Order, Review, CartItem)
├── providers/             # ChangeNotifier state providers
├── routes/                # Declarative and named route generator
├── services/              # Encapsulated Firebase, Analytics, Order & Connectivity APIs
├── utils/                 # Formatters (currency, dates) and Validators (email, passwords)
└── widgets/               # Reusable UI widgets (Ratings, OfflineBanner, Brand, Dialogs)
```

---

## ⚙️ Setup & Installation

### 1. Prerequisites
- Flutter SDK (version 3.47+ recommended)
- Android SDK with command-line tools & platform-tools (`adb`)
- Java JDK 17 or JDK 21

### 2. Clone and Install Dependencies
```bash
git clone https://github.com/muzammilnadeem121/Flutter-Book-Store-App.git
cd Flutter-Book-Store-App-main
flutter pub get
```

### 3. Firebase Configuration
- Place `google-services.json` inside `android/app/`.
- Verify `lib/firebase_options.dart` matches your Firebase project configuration.
- Deploy security rules:
  ```bash
  firebase deploy --only firestore:rules
  ```

### 4. Verify Static Analysis
Ensure 100% clean analysis before running or building:
```bash
flutter analyze
```

---

## 🏗️ Build Instructions

### Run Debug Build
```bash
flutter run
```

### Build Production Signed & Obfuscated Android App Bundle (AAB)
To create an obfuscated, R8-shrunk release bundle for Google Play Store:
```bash
flutter build appbundle \
  --obfuscate \
  --split-debug-info=.\booksbound-symbols \
  --build-name=1.0.0 \
  --build-number=1
```
The output will be placed in `build/app/outputs/bundle/release/app-release.aab`. Obfuscation symbols are exported to `booksbound-symbols/`.

---

## 📄 Documentation

- [Architecture Overview](docs/architecture.md)
- [Security & Compliance](docs/security.md)
- [Privacy Policy](legal/privacy_policy.md)
- [Terms of Service](legal/terms_of_service.md)
- [Play Store Listing Copy](store_listing/play_store_listing.md)

---

## 👨‍💻 Author

**Muhammad Anees**  
*Aptech Higher Diploma in Software Engineering (HDSE)*

---

## 📜 License

This project is licensed under the [MIT License](LICENSE).

---

## 🙏 Acknowledgments

- **Aptech Computer Education** — Faculty guidance and curriculum evaluation.
- **Flutter & Dart Teams at Google** — Cross-platform UI toolkit.
- **Firebase Team** — Serverless authentication, database, storage, and analytics infrastructure.