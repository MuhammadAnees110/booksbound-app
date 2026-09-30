# Environment Setup & Release Build Guide

## 1. Development Environment Setup

### 1.1 Prerequisites & Tooling Matrix

| Tool | Minimum Version | Recommended Version | Verification Command |
| :--- | :--- | :--- | :--- |
| **Flutter SDK** | `3.22.x` | `3.24.x` or later | `flutter --version` |
| **Dart SDK** | `3.4.x` | `3.9.x` / `3.13.x` | `dart --version` |
| **Java Development Kit (JDK)** | OpenJDK 17 | Eclipse Temurin 17 | `java -version` |
| **Android Studio / Command Line Tools** | Hedgehog / 2023.1.1 | Ladybug / 2024.2.1 | `sdkmanager --list` |
| **Gradle** | `8.0+` | `8.7` (configured in project) | `./gradlew -v` |
| **Node.js** (Optional for DB seed) | `18.0.0` | `20.x LTS` | `node -v` |

### 1.2 System Diagnosis
Run Flutter's built-in diagnosis tool to verify toolchain alignment:
```bash
flutter doctor -v
```
Ensure there are no issues with the Android toolchain licenses. If prompted, accept licenses via:
```bash
flutter doctor --android-licenses
```

### 1.3 Installing Project Dependencies
Fetch Dart packages defined in `pubspec.yaml`:
```bash
flutter pub get
```

---

## 2. Security Guidelines: Managing Credential Files

To maintain strict security standards and prevent private keys or client IDs from being leaked on public Git hosts, sensitive files must **never** be committed to source control.

### 2.1 Untracked Credential Files

The project's [`.gitignore`](file:///d:/PR2-202408B/anees--project/Flutter-Book-Store-App-main/.gitignore) explicitly excludes the following credential targets:

```gitignore
# Android Firebase client credentials
android/app/google-services.json

# iOS Firebase client credentials
ios/Runner/GoogleService-Info.plist

# Local Android keystores and signing configs
android/key.properties
*.jks
*.keystore

# Backend service account credentials
serviceAccountKey*.json
```

### 2.2 Adding Firebase Credentials to a Fresh Clone

When cloning the repository on a new development workstation:

1. **Android**:
   - Download `google-services.json` from the Firebase Console (Android App Settings).
   - Copy it into: `android/app/google-services.json`.
2. **iOS**:
   - Download `GoogleService-Info.plist` from the Firebase Console (iOS App Settings).
   - Copy it into: `ios/Runner/GoogleService-Info.plist` (or link via Xcode).
3. **Database Seeding**:
   - Download a Firebase Admin private key and place it at the project root as `serviceAccountKey.json`.

### 2.3 Accidental Staging Verification
Before pushing commits to remote branches, run:
```bash
git status
```
Confirm that none of the credential files listed above appear under `Changes to be committed`. If a credential file was previously tracked, untrack it without removing the local disk copy:
```bash
git rm --cached android/app/google-services.json
git rm --cached ios/Runner/GoogleService-Info.plist
```

---

## 3. Binaries Management

Compiled binaries, release APKs, and distribution ZIP archives must not be tracked in Git. These files bloat the Git index, break shallow clones, and should be managed via GitHub Releases or CI/CD artifact storage.

The following rules in `.gitignore` ensure clean repository hygiene:
```gitignore
*.apk
*.zip
build/
```

If an APK was previously tracked in Git, untrack it locally:
```bash
git rm --cached BookStore_App.apk
git rm --cached BATCH-2026_GROUP-A_BookStore_App.zip
```

---

## 4. Release Build Procedure

### 4.1 Static Analysis & Quality Gate
Always run Flutter's static analyzer before compiling release binaries:
```bash
flutter analyze
```
Confirm that output displays: `No issues found!`.

### 4.2 Building the Android Release APK
Compile an optimized, tree-shaken Android Application Package (APK):
```bash
flutter build apk --release
```

#### What this command executes:
1. Ahead-Of-Time (AOT) compiles Dart code into native ARM64 / ARMv7 machine instructions.
2. Strips debug symbols and disables Dart VM assertions.
3. R8 / ProGuard minifies Java and Kotlin bytecode.
4. Bundles optimized assets and generates the final output at:
   ```
   build/app/outputs/flutter-apk/app-release.apk
   ```

### 4.3 Building Split APKs (Per-ABI Architecture)
To produce smaller APK binaries optimized for specific CPU architectures (reducing download size from ~30MB to ~10MB per architecture):
```bash
flutter build apk --split-per-abi --release
```
This produces three architecture-specific APKs in `build/app/outputs/flutter-apk/`:
- `app-armeabi-v7a-release.apk` (32-bit devices)
- `app-arm64-v8a-release.apk` (Modern 64-bit devices)
- `app-x86_64-release.apk` (Emulators and tablets)

### 4.4 Building Android App Bundle (AAB) for Google Play
For store distribution on Google Play:
```bash
flutter build appbundle --release
```
Output path: `build/app/outputs/bundle/release/app-release.aab`.

### 4.5 Testing Release Builds Locally
Install and run the release build directly on a USB-connected Android device:
```bash
flutter run --release
```

---

## 5. Demonstration & Assessor Accounts

### 6.3 Test Accounts

| Account | Email | Password | Role |
| :--- | :--- | :--- | :--- |
| **Admin** | `admin@booksbound.demo` | `Admin@123` | `admin` |
| **Customer** | `customer@booksbound.demo` | `Customer@123` | `user` |
| **Password reset** | `reset@booksbound.demo` | `Reset@123` | |

#### Assigning Admin Privileges:
1. Create the user `admin@booksbound.demo` in **Firebase Authentication**.
2. Create or update the matching Firestore document in the `users` collection:
   - `email`: `"admin@booksbound.demo"`
   - `role`: `"admin"`
   - `name`: `"Admin User"`
3. Log in with `admin@booksbound.demo` to access administrative inventory and review moderation screens.
