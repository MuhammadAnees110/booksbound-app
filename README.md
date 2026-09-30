# Flutter BookStore Application

An e-commerce mobile application developed with Flutter, Riverpod, and Firebase for the Aptech eProject curriculum.

## 📖 Project Overview

The BookStore Application provides a complete digital storefront for browsing, searching, purchasing, and reviewing books. Built using modern Flutter architecture and Firebase backends, it enforces security, offline performance, and real-time database sync.

## ✨ Key Features

- **Authentication & Profiles:** Secure email/password login, registration, password reset, profile customization, and shipping address management.
- **Book Catalog:** Genre-based categories, bestseller feeds, new arrivals, and book detail views.
- **Search & Filters:** Search by title, author, or genre, with price, release date, and popularity sorting.
- **Cart & Orders:** Interactive cart with live total price calculations, order placement history, and step-by-step delivery tracking.
- **Ratings & Reviews:** Interactive star ratings, written reviews, and review likes.
- **Admin Panel:** Role-protected catalog management (CRUD operations for books) and order status updates.
- **Wishlist:** Save-for-later management per user account.

## 🛠️ Tech Stack & Architecture

- **Frontend:** Flutter (Dart)
- **State Management:** Riverpod & StateNotifier
- **Backend:** Firebase Authentication & Cloud Firestore
- **Storage:** Firebase Cloud Storage (optimized download URLs)
- **Local Persistence:** Hive / SharedPreferences

## 🚀 How to Run the App

1. Install dependencies:
   `flutter pub get`
2. Run application:
   `flutter run`

## 🔐 Credentials for Testing

- **Admin Account:** admin@bookstore.com / Admin@12345
- **Test User Account:** user@bookstore.com / User@12345

## 📋 Security & Compliance

- **Database Security:** `firestore.rules` and `storage.rules` enforce authenticated user access and 5 MB image upload bounds.
- **Code Quality:** Verified clean using `flutter analyze` with 0 warnings or errors.
