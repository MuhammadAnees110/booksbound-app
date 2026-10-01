# Flutter BookStore Application

An e-commerce mobile application developed with Flutter, Riverpod, and Firebase for the Aptech eProject curriculum.

## 📖 Project Overview

The BookStore Application provides a complete digital storefront for browsing, searching, purchasing, and reviewing books. Built using modern Flutter architecture and Firebase backends, it enforces security, offline performance, and real-time database sync.

## ✨ Key Features

- **Authentication & Profiles:** Email/password and Google sign-in, registration, password reset, profile customization, saved shipping addresses and payment methods.
- **Book Catalog:** Browse by genre and by author, bestseller feeds, new arrivals, and book detail views.
- **Search & Filters:** Search by title, author, or genre, with price, release date, and popularity sorting.
- **Cart & Orders:** Interactive cart with live total price calculations, checkout with saved address and card or Cash on Delivery, order history, and a live delivery-tracking timeline.
- **Ratings & Reviews:** Interactive star ratings, written reviews, and review likes.
- **Admin Panel:** Role-protected catalog management (CRUD operations for books) and order status updates.
- **Wishlist:** Save-for-later management per user account.
- **Help & FAQ:** In-app user guide with tutorials and FAQs ([docs/USER_GUIDE.md](docs/USER_GUIDE.md)).

## 🛠️ Tech Stack & Architecture

- **Frontend:** Flutter (Dart)
- **State Management:** Riverpod & StateNotifier
- **Backend:** Firebase Authentication & Cloud Firestore
- **Media:** Book covers and category images served from jsDelivr CDN ([chotabahi/book-app-assets](https://github.com/chotabahi/book-app-assets)), cached on-device via `cached_network_image`
- **Storage:** Firebase Cloud Storage (user avatars and admin-uploaded covers)
- **Local Persistence:** SharedPreferences

## 🚀 How to Run the App

1. Place your Firebase config at `android/app/google-services.json` (not committed; see [SUBMISSION.md](SUBMISSION.md)).
2. Install dependencies:
   `flutter pub get`
3. Run application:
   `flutter run`

Full documentation: [docs/README.md](docs/README.md).

## 🔐 Credentials for Testing

### 6.3 Test Accounts

| Account | Email | Password | Role |
| :--- | :--- | :--- | :--- |
| **Admin** | `admin@booksbound.demo` | `Admin@123` | `admin` |
| **Customer** | `customer@booksbound.demo` | `Customer@123` | `user` |
| **Password reset** | `reset@booksbound.demo` | `Reset@123` | |


## 📋 Security & Compliance

- **Database Security:** `firestore.rules` and `storage.rules` enforce authenticated user access and 5 MB image upload bounds.
- **Code Quality:** Verified clean using `flutter analyze` with 0 warnings or errors.
