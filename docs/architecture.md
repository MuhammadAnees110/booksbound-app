# BooksBound — Architecture Overview

## 1. Architectural Philosophy

BooksBound is built according to **Feature-First Clean Architecture** principles in Flutter. The codebase emphasizes:
- **Separation of Concerns**: Decoupled presentation (widgets and screens), business logic (ChangeNotifier providers), and data layers (services and models).
- **Single Source of Truth**: Centralized collection names in `AppConstants` and uniform route declarations in `AppRoutes`.
- **Fault-Tolerant Resilience**: Safe offline fallbacks, persistence caching, and defensive error boundaries preventing unhandled application crashes.

---

## 2. Directory Layout & Layer Responsibilities

```text
lib/
├── constants/
│   └── app_constants.dart          # Central Firestore collection IDs and configurations
├── core/
│   └── theme/
│       └── app_theme.dart          # Unified light and dark Material 3 themes
├── features/                       # Modular business features
│   ├── admin/                      # Administrative management submodules
│   ├── auth/                       # Login, registration, and password recovery
│   ├── book_details/               # Detail views, review forms, ratings
│   ├── cart/                       # Shopping cart state & checkout
│   ├── categories/                 # Category discovery and filtered lists
│   ├── home/                       # Storefront and bestsellers
│   ├── layout/                     # Persistent bottom navigation shell & offline banner
│   ├── profile/                    # User profile, order history & account deletion
│   ├── search/                     # Real-time book search
│   └── wishlist/                   # Wishlist management and cart transfer
├── models/                         # Immutable serialization models with toMap/fromMap
├── providers/                      # Reactive ChangeNotifier state controllers
├── routes/                         # Route generation and deep-link routing
├── services/                       # Low-level Firebase, Analytics, and connectivity APIs
├── utils/                          # Number/currency formatters & regex validators
└── widgets/                        # Shared reusable UI components
```

---

## 3. State Management Flow

State in BooksBound is managed via the **Provider** package with 11 domain-specific `ChangeNotifier` classes registered at the application root:

1. **`BookProvider`**: Manages the catalog, category-based filtering, and search queries.
2. **`UserAuthProvider`**: Manages auth lifecycle and session credentials.
3. **`ProfileProvider`**: Manages user profile data, avatars, and role detection.
4. **`CartProvider`**: Manages cart line items, quantity mutations, and order preparation.
5. **`WishlistProvider`**: Manages saved book IDs synced with Cloud Firestore.
6. **`ReviewsProvider`**: Loads and synchronizes book reviews.
7. **`RatingsProvider`**: Tracks book star ratings.
8. **`CategoryProvider`**: Supplies bookstore categories.
9. **`ThemeProvider`**: Persists and broadcasts light/dark mode changes.
10. **`AdminUsersProvider`**: Administrative user listing and role management.
11. **`AdminAnalyticsProvider`**: Computes administrative analytics and stats.

---

## 4. Navigation & Deep Linking

Navigation is orchestrated using declarative named routes in `AppRoutes` with a global `GlobalKey<NavigatorState>` registered on `MaterialApp`. Deep links matching `https://booksbound-app-boka18.web.app/book/{bookId}` are captured on cold starts and during background execution via `AppLinks`, fetching the book metadata and pushing `BookDetailsScreen` seamlessly.
