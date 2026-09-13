# BooksBound — Security & Compliance Architecture

## 1. Authentication & Password Protection

- **No Plaintext Passwords**: User passwords are encrypted, hashed, and managed exclusively by Firebase Authentication. Passwords never touch application memory or Firestore documents.
- **Session Tokens**: Handled via secure OAuth/JWT tokens managed by Google Play Services and Firebase Auth.

---

## 2. Firebase App Check & API Protection

- **Play Integrity Provider**: Android production builds register with Google Play Integrity attestation to verify that requests originate from an authentic, untampered BooksBound binary.
- **App Attest / DeviceCheck Fallback**: Apple devices authenticate requests via Apple App Attest.
- **Fail-Safe Startup**: App Check initialization is guarded in a `try/catch` block to ensure that temporary console connectivity lapses never crash the client application.

---

## 3. Firestore Security Rules (RBAC)

The Cloud Firestore database is locked down with declarative security rules in `firestore.rules`:
- **Books & Categories**: Public read access. Writes and deletes are strictly restricted to verified administrators (`data.role == 'admin'`).
- **User Profiles**: Only the owning user (`request.auth.uid == userId`) or an admin can modify profile details.
- **Cart & Wishlist**: Only authenticated owning users can read, write, or delete items tied to their `userId`.
- **Reviews**: Public read access. Only authenticated authors or administrators can edit or delete a review.
- **Orders**: Customers can read and create their own orders. Only administrators can mutate order fulfillment status or delete orders.

---

## 4. Google Cloud API Key Restrictions

API keys used by the app are restricted in the Google Cloud Console:
- **Application Restriction**: Limited strictly to Android package name `com.example.e_project` matching the SHA-1 and SHA-256 certificate fingerprints of `booksbound-upload.jks`.
- **API Scope Restriction**: Keys are scoped strictly to required services:
  - Firebase Installations API
  - Cloud Firestore API
  - Firebase Cloud Messaging API
  - Identity Toolkit API
  - Firebase Rules API

---

## 5. Google Play Legal & Data Deletion Compliance

- **Account Deletion Flow**: In-app account deletion is accessible via **Profile ➔ Delete Account**, requiring explicit typed confirmation (`DELETE`).
- **Data Purge Lifecycle**:
  - Cart and wishlist records are deleted immediately.
  - Profile photos are deleted from Firebase Storage.
  - Firestore user documents are removed.
  - Order history and reviews are anonymized (`userId: 'deleted_user'`) for accounting and regulatory retention without personally identifiable information (PII).
  - Firebase Auth user account is permanently deleted.
- **Hosted Legal Documents**: Privacy Policy and Terms of Service are documented in `/legal` and linked in-app via `url_launcher`.
