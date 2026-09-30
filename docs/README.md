# BooksBound Engineering Documentation

This directory contains the technical documentation, architecture specifications, operational guides, and setup procedures for the BooksBound Flutter application.

## Documentation Index

| Document | Purpose | Audience |
| :--- | :--- | :--- |
| **[OVERVIEW.md](file:///d:/PR2-202408B/anees--project/Flutter-Book-Store-App-main/docs/OVERVIEW.md)** | High-level system summary, business capabilities, core tech stack, and state management model. | All developers, reviewers, technical leads |
| **[ARCHITECTURE.md](file:///d:/PR2-202408B/anees--project/Flutter-Book-Store-App-main/docs/ARCHITECTURE.md)** | Layered software design (UI -> Service/Provider -> Firestore), CDN asset delivery pipeline, defensive deserialization, and image caching strategy. | Frontend & backend engineers, architects |
| **[DATABASE_AND_CDN.md](file:///d:/PR2-202408B/anees--project/Flutter-Book-Store-App-main/docs/DATABASE_AND_CDN.md)** | Firestore schema definitions for `books` and `categories`, jsDelivr CDN asset pathing conventions, and seeding instructions via Node.js script. | Database administrators, platform engineers |
| **[SETUP_AND_BUILD.md](file:///d:/PR2-202408B/anees--project/Flutter-Book-Store-App-main/docs/SETUP_AND_BUILD.md)** | Local environment requirements (Flutter 3.x, Dart 3.x, JDK 17), secret credential handling, release build instructions, and git artifact hygiene. | DevOps engineers, local contributors |
| **[PRESENTATION_NOTES.md](file:///d:/PR2-202408B/anees--project/Flutter-Book-Store-App-main/docs/PRESENTATION_NOTES.md)** | Concise technical talking points, architecture rationale, cost/performance trade-offs, and demo flow for code walkthroughs. | Presenters, code reviewers, stakeholders |

## Key Technical Decisions at a Glance

1. **Decoupled Heavy Media via CDN**: Book cover images and category assets are hosted in an external Git asset repository (`chotabahi/book-app-assets`) and delivered via jsDelivr CDN rather than being bundled in app assets or stored directly in Firestore documents.
2. **Defensive Model Deserialization**: All Firestore-to-Dart conversions enforce strict type casting (`(data['field'] as String?) ?? ''`) with fallbacks to avoid unhandled runtime `TypeError` crashes on missing or null fields.
3. **Centralized Image Pipeline**: UI components rely on a custom `CachedImage` abstraction built on `cached_network_image`, providing memory/disk caching, shimmer skeleton loading, and automatic asset error fallback widgets.
4. **Zero Secrets in Source Control**: Firebase client credentials (`google-services.json`, `GoogleService-Info.plist`) and service account private keys (`serviceAccountKey*.json`) are gitignored and omitted from commits.
