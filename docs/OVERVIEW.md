# System Overview: BooksBound Flutter Application

## 1. Project Summary

BooksBound is an e-commerce mobile bookstore application engineered with Flutter and Google Firebase. The application is built to provide a fast, responsive shopping experience across Android and iOS devices, backed by real-time cloud data storage and a distributed content delivery network (CDN) for media assets.

The application serves two distinct user profiles:
- **Customers**: Browse the catalog, filter titles by genre, read synopsis details, manage cart and wishlist items, submit book ratings and reviews, and place orders.
- **Store Administrators**: Manage the live inventory (add, edit, and delete books), monitor catalog metrics, moderate user-submitted reviews, and oversee registered customer accounts.

---

## 2. Core Tech Stack

| Technology Layer | Tool / Library | Version / Baseline | Operational Purpose |
| :--- | :--- | :--- | :--- |
| **Client Framework** | Flutter SDK | `^3.x` | Cross-platform UI toolkit targeting Android and iOS from a single Dart codebase. |
| **Language** | Dart | `^3.9.2` | Strong-mode, sound null-safe programming language with Ahead-of-Time (AOT) compilation. |
| **State Management** | `provider` | `^6.1.5` | Pragmatic dependency injection and reactive state notification (`ChangeNotifier`). |
| **Backend Database** | Cloud Firestore | `cloud_firestore: ^6.1.2` | NoSQL document database providing real-time data streaming and offline persistence. |
| **Authentication** | Firebase Auth | `firebase_auth: ^6.1.4` | Email/password credential verification, user session tokens, and security rule claims. |
| **Cloud Storage** | Firebase Storage | `firebase_storage: ^13.0.4` | Blob storage for user profile avatars and uploaded book covers. |
| **Media Delivery (CDN)** | jsDelivr CDN | Global Edge Network | Distributes static book cover artwork and category thumbnails from GitHub releases. |
| **Database Tooling** | Node.js + Firebase Admin | Node `>= 18.x` | Automated script environment (`scripts/seed_firestore.js`) for catalog hydration. |
| **Image Caching** | `cached_network_image` | `^4.0.0` | Dual-layer memory/disk image cache preventing redundant network roundtrips. |

---

## 3. Key System Capabilities

### 3.1 Catalog Browsing and Search
- **Home Feed**: Displays promotional banners, genre-based horizontal carousels, and a curated list of bestsellers queried from Firestore (`isBestseller == true`).
- **Live Search**: Performs prefix-based substring queries on book titles and authors with deduplication logic across multiple Firestore queries.
- **Book Details**: Shows full publication metadata, pricing, synopsis, average review rating, and real-time user reviews.

### 3.2 Category-Based Discovery
- Eight core genres: Fiction, Non-Fiction, Children, Academic, Science, History, Biography, and Religion.
- Category listings load from Firestore with an in-memory fallback list (`CategoryService.defaultCategories`) if the network is unavailable or the collection is unseeded.
- Case-insensitive genre filtering using a normalized `category_lowercase` compound index query.

### 3.3 Shopping Cart and Wishlist
- **Cart Management**: Add, update quantity, or remove items. Total cost, subtotal, and tax calculations are handled in the local `CartProvider`.
- **Wishlist**: Per-user bookmarking stored in Firestore subcollections, allowing persistence across user sessions and devices.

### 3.4 Administrative Control Panel
- **Book Management**: Direct CRUD operations on the `books` collection. Administrators can upload cover photos directly from device storage or specify external URLs.
- **Review Moderation**: Admins can inspect customer feedback, review flags, and delete abusive reviews directly from `manage_reviews`.
- **User Auditing**: Displays registered users, account creation timestamps, and privilege levels.

### 3.5 Offline-Capable Image Caching
- All book covers and category icons load through a unified `CachedImage` component.
- Images downloaded from the CDN are stored in device storage cache. Subsequent app launches render book cards instantly from disk without hitting the network.
- Handles slow connections gracefully with shimmer skeleton placeholders and falls back to local assets on network dropouts.
