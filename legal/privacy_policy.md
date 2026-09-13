# Privacy Policy for BooksBound

Last updated: September 13, 2026

BooksBound ("we", "our", "the app") is a Flutter-based mobile application developed by Muhammad Anees as an HDSE final semester project at Aptech. This Privacy Policy describes how we collect, use, and protect your information when you use our app.

## Information We Collect

### 1. Account Information
- Email address (used for authentication)
- Display name (optional, set by user)
- Profile picture (optional, stored in Firebase Storage)
- We do NOT collect or store passwords in plaintext. Authentication is handled exclusively by Firebase Authentication.

### 2. Book Store Data
- Cart contents
- Wishlist items
- Order history (items purchased, shipping address, total amount, order status)
- Reviews and ratings you submit

### 3. Usage Analytics
- Anonymous usage data via Firebase Analytics, including:
  - Screen views
  - Add to cart events
  - Checkout events
  - Purchase events
  - Search queries
- Crash reports via Firebase Crashlytics (no PII)

### 4. Device Information
- App version
- Device model and OS version
- Language preference
- Network connectivity status

## How We Use Your Information

- To authenticate you and secure your account
- To process and fulfill your book orders
- To display your reviews and ratings to other users
- To improve app performance and user experience
- To detect and prevent fraud, abuse, and security incidents
- To send order status updates (if push notifications are enabled)

## Data Storage

All data is stored in:
- Firebase Authentication (account credentials)
- Cloud Firestore (user profile, cart, wishlist, orders, reviews)
- Firebase Storage (profile pictures, book cover images)
- All data is stored in us-central1 (United States) and encrypted in transit and at rest.

## Third-Party Services

We use the following third-party services, each with their own privacy policies:
- Firebase (Google LLC) — Authentication, Firestore, Storage, Analytics, Crashlytics
- Google Play Services — App integrity verification
- We do NOT sell or share your data with advertising networks.

## Your Rights

You have the right to:
- **Access** your personal data (export via Profile → My Data)
- **Delete** your account and all associated data (via Profile → Delete Account)
- **Correct** inaccurate information (edit profile)
- **Withdraw consent** for analytics (disable in Profile → Settings)
- **Data portability** — request an export of your data in JSON format

To exercise these rights, contact: anees.booksbound@gmail.com

## Data Retention

- Active account data: retained while account is active
- Deleted account data: permanently removed within 30 days, EXCEPT:
  - Order records are anonymized (userId set to "deleted_user") and retained for 7 years for legal/tax compliance
- Analytics data: aggregated and anonymized after 14 months

## Children's Privacy

This app is not directed to children under 13. We do not knowingly collect personal information from children. If you believe we have collected data from a child, contact us immediately for deletion.

## Security

We implement industry-standard security measures:
- Firebase App Check to prevent unauthorized API access
- Firestore Security Rules enforcing role-based access control
- No plaintext password storage
- API key fingerprinting to prevent quota theft
- Code obfuscation in production builds

## Changes to This Policy

We may update this Privacy Policy from time to time. Users will be notified of material changes via in-app notification. Continued use after changes constitutes acceptance.

## Contact

For privacy questions or data requests:
- Email: anees.booksbound@gmail.com
- Developer: Muhammad Anees
- Organization: Aptech HDSE
