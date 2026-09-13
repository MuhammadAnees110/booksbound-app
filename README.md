# 📚 BooksBound — Online Book Store App (Flutter + Firebase)

A full-featured, production-ready **Online Book Store mobile application** built using **Flutter** and **Firebase**, developed as an Aptech HDSE eProject by **Muhammad Anees**. The project includes complete customer shopping & checkout flows and a robust **Admin Panel** for managing books, orders, users, reviews, and store analytics.

Built following Clean Architecture & Feature-First principles with **Provider** for reactive state management.

---

## 🚀 Features

### 👤 Customer Features
- **User Authentication**: Secure Sign-Up and Sign-In via Firebase Authentication with real-time email & password validation.
- **Profile Management**: View and edit user details, upload profile photos, and change passwords securely.
- **Book Discovery**: Browse catalog by genre/category, view bestsellers, and real-time live search with deduplication.
- **Book Details**: Comprehensive book metadata, author details, synopsis, ratings, and customer reviews.
- **Ratings & Reviews**: Real-time review posting, interactive like toggles, and individual rating system.
- **Wishlist**: Cloud Firestore-synced personal wishlist with instant add/remove actions.
- **Shopping Cart**: Real-time quantity adjustment, item removal, and live total price calculation.
- **Checkout & Orders**: Full shipping address checkout flow, automated order placement, and live Order History tracking in user profile.

---

### 🛠️ Admin Panel Features
- **Role-Based Access Control**: Strict access verification ensuring only accounts with the `admin` role can access administrative tools.
- **Book Management**: Add new books with direct **Firebase Storage** cover image uploads, edit existing titles, and delete books.
- **Order Management**: Real-time stream of all customer orders, expandable line-item views, shipping details, and instant order status transitions (`Pending` ➔ `Processing` ➔ `Shipped` ➔ `Delivered` ➔ `Cancelled`).
- **Review Moderation**: Full administrative review moderation and cleanup across the entire catalog.
- **User Management**: View all registered users, toggle user account lock/block statuses, and promote/demote user roles.
- **Analytics Dashboard**: Live store metrics tracking total books, bestseller counts, user registrations, and review statistics.

---

## 🧠 Tech Stack & Dependencies

| Technology | Role |
|---|---|
| **Flutter 3.x / Dart 3.x** | Cross-platform mobile client framework |
| **Firebase Core** | Core Firebase initialization |
| **Firebase Authentication** | Identity management & session authentication |
| **Cloud Firestore** | NoSQL cloud database for real-time reactive sync |
| **Firebase Storage** | Cloud bucket storage for book cover images |
| **Provider** | State management (9 specialized `ChangeNotifier` providers) |
| **Image Picker** | Device gallery image selection for covers and avatars |

---

## 📂 Project Structure

Feature-first architecture with strict snake_case naming conventions:

```
lib/
├── constants/             # App-wide constants (Firestore collection names)
│   └── app_constants.dart
├── features/              # Feature modules (Feature-First architecture)
│   ├── admin/             # Admin management (books, orders, reviews, users, analytics)
│   │   ├── admin_panel_screen.dart
│   │   ├── analytics/
│   │   ├── manage_books/
│   │   ├── manage_orders/
│   │   ├── manage_reviews/
│   │   └── manage_users/
│   ├── auth/              # Authentication screens (Login, Register)
│   ├── book_details/      # Detailed book view and review interactions
│   ├── cart/              # Shopping cart & checkout flow
│   ├── change_password/   # Account security
│   ├── edit_profile/      # Profile customization
│   ├── home/              # Main storefront & bestsellers
│   ├── layout/            # Bottom navigation bar shell
│   ├── profile/           # User dashboard & Order History
│   ├── search/            # Live book catalog search
│   ├── splash/            # App entrypoint and session router
│   └── wishlist/          # Saved books
├── models/                # Typed domain models (Book, User, Order, Review, CartItem)
├── providers/             # ChangeNotifier state providers
├── routes/                # Declarative and named route configuration
├── services/              # Encapsulated Firebase and Firestore APIs
├── utils/                 # Formatters (currency, dates) and Validators (email, forms)
└── widgets/               # Reusable UI widgets
```

---

## 🔐 Security & Database Rules

- **Zero Plaintext Passwords**: Passwords are handled exclusively by Firebase Authentication; never stored in Firestore documents.
- **Role-Based Security Rules**: Firestore security rules restrict catalog writes and user modifications strictly to administrative accounts.
- **Data Encapsulation**: Single source of truth collection names defined centrally in `AppConstants`.

---

## ⚙️ Setup & Installation

1. **Clone the repository**:
   ```bash
   git clone https://github.com/muzammilnadeem121/Flutter-Book-Store-App.git
   cd Flutter-Book-Store-App-main
   ```

2. **Install Flutter dependencies**:
   ```bash
   flutter pub get
   ```

3. **Configure Firebase**:
   - Register your Android/iOS apps in the Firebase Console.
   - Place `google-services.json` in `android/app/`.
   - Run `flutterfire configure` if regenerating `firebase_options.dart`.

4. **Verify Static Analysis**:
   ```bash
   flutter analyze
   ```

5. **Run Application**:
   ```bash
   flutter run
   ```

---

## 👨‍💻 Author

**Muhammad Anees**  
*Aptech Higher Diploma in Software Engineering (HDSE) Candidate*