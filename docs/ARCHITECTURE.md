# Architecture & Technical Design: BooksBound

## 1. High-Level Architecture

The BooksBound application follows a clean layered design separating user interaction, business state management, data access abstractions, and external cloud infrastructure.

```
┌────────────────────────────────────────────────────────┐
│                      UI Layer                          │
│  Widgets, Screens (Home, Details, Cart, Admin Panels)   │
│  State Consumer: Provider `context.watch / read`       │
└──────────────────────────▲─────────────────────────────┘
                           │ Dispatches UI events / Listens to streams
┌──────────────────────────▼─────────────────────────────┐
│                 State / Logic Layer                    │
│  Providers: BookProvider, CategoryProvider, Auth...     │
│  State: Holds mutable lists, loading flags, error state │
└──────────────────────────▲─────────────────────────────┘
                           │ Invokes asynchronous service methods
┌──────────────────────────▼─────────────────────────────┐
│               Service / Repository Layer               │
│  Services: BooksService, CategoryService, UserService   │
│  Data Mapping: `Book.fromMap`, `CategoryModel.fromMap`  │
│  Encapsulates Firestore SDK & ErrorMapper conversions   │
└──────────────────────────▲─────────────────────────────┘
                           │ Calls Firebase SDK / HTTP CDN
┌──────────────────────────▼─────────────────────────────┐
│               External Cloud Services                  │
│  Cloud Firestore  │  Firebase Auth  │  jsDelivr CDN    │
└────────────────────────────────────────────────────────┘
```

### 1.1 Layer Responsibilities

1. **Presentation (UI Layer)**:
   - Contains pure Flutter widgets (`StatelessWidget`, `StatefulWidget`).
   - Does not invoke Firestore or HTTP APIs directly. All data access occurs by triggering provider methods or consuming provider state streams.
   - Standardizes user feedback via reusable visual primitives (e.g., `CachedImage`, `ErrorSnackbar`, `Skeleton`).

2. **State / Business Logic (Provider Layer)**:
   - Manages UI-reactive data models using the `provider` package and `ChangeNotifier`.
   - Handles optimistic UI updates where applicable (e.g., cart increments) and exposes immutable getters to the view layer.
   - Translates `Result<T>` envelopes received from services into local error messages or active loading states.

3. **Data Access (Service Layer)**:
   - Direct interface to `FirebaseFirestore`, `FirebaseAuth`, and `FirebaseStorage`.
   - Wraps asynchronous calls inside `try/on FirebaseException/catch` blocks and maps exceptions into typed `Result<T>` objects (using `ResultStatus.serverError`, `notFound`, etc.).
   - Contains pagination limits and composite query logic (`Filter.or(...)`) to keep cloud read consumption bounded.

4. **Persistence & External Services**:
   - Firestore houses persistent records.
   - jsDelivr CDN delivers static media.
   - Device disk storage caches media via the image cache manager.

---

## 2. Asset Delivery Pipeline (jsDelivr CDN)

### 2.1 The Problem
Storing high-resolution book cover images and category banners directly inside:
- **Git repositories**: Causes severe repository bloat, slow clone operations, and large merge conflicts over time.
- **Firestore documents (as Base64 strings)**: Drastically inflates document sizes, violates Firestore's 1 MB per document quota, and causes massive read billing overhead.
- **Firebase Storage exclusively**: Incurred high bandwidth and download egress fees on free/Spark tier Firebase plans.

### 2.2 The Solution
All static assets are decoupled into an open GitHub media repository:
- Repository: `https://github.com/chotabahi/book-app-assets`
- Branch: `main`
- Directories: `/covers/` and `/categories/`

These assets are fronted by the jsDelivr open-source CDN:
- Fast global distribution via Cloudflare/Fastly points of presence (PoPs).
- Built-in HTTP caching (`Cache-Control: public, max-age=31536000`).
- Predictable URL slug generation for both batch seed scripts and runtime fallback lists.

```
[Developer / Admin]
        │
        ▼ Push image files (.jpg)
[GitHub Repository: chotabahi/book-app-assets]
        │
        ▼ Mirrored automatically on commit
[jsDelivr CDN Edge Cache]
        │
        ▼ HTTP GET (Cached on Edge)
[BooksBound App: CachedImage Widget]
        │
        ▼ Saved to local flash memory
[Device Disk Storage (sqflite / file cache)]
```

---

## 3. Image Rendering & Caching Strategy

The application enforces a single entry point for all remote and Base64 images: the `CachedImage` widget ([`lib/widgets/cached_image.dart`](../lib/widgets/cached_image.dart)).

### 3.1 Architectural Features of `CachedImage`

1. **Protocol Discrimination**:
   - **HTTP / HTTPS**: Routes through `CachedNetworkImage`, pulling from jsDelivr CDN with automated memory and disk cache eviction.
   - **Base64 String**: Detected via string prefix or length checks. Decoded using `base64Decode` and rendered via `Image.memory` (for user-uploaded custom covers and profile photos).
   - **Local Asset / Empty**: Immediately routes to the fallback error builder without firing a network query.

2. **Downsampling via Memory Cache Limits**:
   - Prevents Out-Of-Memory (OOM) crashes on low-end Android devices by providing target memory cache dimensions:
   ```dart
   memCacheWidth: width != null ? (width! * 2.5).toInt() : null,
   memCacheHeight: height != null ? (height! * 2.5).toInt() : null,
   ```

3. **Shimmer Skeleton Loading**:
   - Renders a shimmer placeholder (`Skeleton(width, height, radius)`) while network packets are in transit, eliminating layout jumping (Cumulative Layout Shift).

4. **Fault Tolerance and Fallbacks**:
   - Catches both HTTP 404/500 responses and Base64 decode exceptions:
   ```dart
   errorWidget: (context, url, error) {
     debugPrint('Failed to load image from URL: $url | Error: $error');
     return _buildErrorWidget();
   }
   ```
   - Falls back to `assets/images/cover-error.png` or a generic `Icons.book` vector icon if the fallback image asset is unavailable.

---

## 4. Defensive Model Deserialization

In production, NoSQL document databases like Firestore can contain documents with missing fields, null values, or unexpected types (e.g., an int stored where a double was expected, or an empty string where a URL is required).

To eliminate runtime `NullCheck` or `type 'Null' is not a subtype of type 'String'` crashes, all model factory constructors utilize defensive null-aware casting.

### 4.1 Book Model Pattern ([`lib/models/book_model.dart`](../lib/models/book_model.dart))

```dart
factory Book.fromMap(Map<String, dynamic> data, {String id = ''}) {
  DateTime parsedDate;
  if (data['releaseDate'] is Timestamp) {
    parsedDate = (data['releaseDate'] as Timestamp).toDate();
  } else if (data['releaseDate'] is String) {
    parsedDate = DateTime.tryParse(data['releaseDate']) ?? DateTime.now();
  } else {
    parsedDate = DateTime.now();
  }

  return Book(
    id: id.isNotEmpty ? id : (data['id'] ?? ''),
    title: data['title'] ?? '',
    author: data['author'] ?? '',
    genre: data['genre'] ?? data['category'] ?? '',
    description: data['description'] ?? '',
    coverUrl: (data['coverUrl'] as String?) ?? '', // Defensive cast
    isbn: data['isbn'] ?? '',
    price: (data['price'] as num?)?.toDouble() ?? 0.0, // Handles both int & double
    rating: (data['rating'] as num?)?.toDouble() ?? 0.0,
    isBestseller: data['isBestseller'] ?? false,
    releaseDate: parsedDate,
    reviews: (data['reviews'] as List<dynamic>? ?? [])
        .whereType<Map<String, dynamic>>()
        .map((e) => ReviewModel.fromMap(e))
        .toList(),
  );
}
```

### 4.2 Category Model Pattern ([`lib/models/category_model.dart`](../lib/models/category_model.dart))

```dart
factory CategoryModel.fromMap(Map<String, dynamic> map, {String? id}) {
  return CategoryModel(
    id: id ?? map['id'] ?? '',
    name: map['name'] ?? '',
    imageUrl: (map['imageUrl'] as String?) ?? '', // Defensive cast
    description: map['description'] ?? '',
  );
}

factory CategoryModel.fromJson(Map<String, dynamic> json, {String? id}) =>
    CategoryModel.fromMap(json, id: id);
```

### 4.3 Why This Matters
1. **Zero Runtime Fatalities**: If an admin creates a document in the Firebase Console and leaves `coverUrl` blank, the app assigns an empty string `''` rather than throwing a fatal uncaught exception.
2. **Backward Compatibility**: If legacy records still contain `category` instead of `genre`, the fallback operator (`data['genre'] ?? data['category'] ?? ''`) transparently resolves it.
3. **Numeric Robustness**: Reading numbers via `(data['price'] as num?)?.toDouble() ?? 0.0` prevents crashes when Firestore stores whole numbers as `int` (e.g. `12`) instead of `double` (`12.0`).
