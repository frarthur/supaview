# SupaView

> **phpMyAdmin for Supabase, on mobile.**

<p align="center">
  <img src="assets/images/app_icon.png" alt="SupaView" width="128">
</p>

**SupaView** is an open-source mobile client to manage your Supabase databases directly from your phone. No intermediate server, no telemetry, no ads — your data connects straight to your Supabase instance over HTTPS.

[![Version](https://img.shields.io/badge/version-1.0.0-blue.svg)](https://github.com/frarthur/supaview/releases)
[![Flutter](https://img.shields.io/badge/Flutter-3.38+-02569B?logo=flutter)](https://flutter.dev)
[![License](https://img.shields.io/badge/license-MIT-green.svg)](LICENSE)
[![Google Play](https://img.shields.io/badge/Google%20Play-coming%20soon-FF6C37?logo=google-play)](https://play.google.com/store/apps/details?id=com.supaview.supaview)

---

## Why SupaView?

|  | |
|---|---|
| **Direct connection** | Your phone ↔ Supabase. No proxy, no analytics, no third party. |
| **Your keys, your device** | API keys are encrypted and stored locally with Flutter Secure Storage. |
| **Full admin toolkit** | Tables, SQL editor, Storage, Auth users, Edge Functions — all from your pocket. |
| **100% open-source** | MIT license. Audit it, fork it, build it yourself. |
| **Light & dark theme** | Material 3, system-aware. |

---

## Screenshots

<p align="center">
  <em>Coming soon</em>
</p>

---

## Features

### Already shipped (v1.0.0)

| Feature | Description |
|---|---|
| Project management | Add, edit, delete Supabase connections |
| Dashboard | Live stats: tables, storage, users, functions |
| Table browser | Full CRUD: create, read, update, delete rows |
| Filters & sort | Search with debounce, sort by column, pagination |
| SQL editor | Execute SELECT queries, view formatted results |
| Storage browser | Browse buckets and files, delete objects |
| Auth users | View, manage, disable users |
| Edge Functions | List, view logs, invoke |
| Material 3 | Light and dark theme |

### Coming next

| Feature | |
|---|---|
| SQL INSERT / UPDATE / DELETE | Write operations |
| CSV / JSON export | Download query results |
| SQL history & favorites | Save and replay queries |
| Table schema editor | Add/remove columns |
| Offline connections cache | Manage projects without network |

---

## Download

### Google Play

Coming soon — CI/CD deploys automatically on every push to `main`.

### APK (manual install)

[<img src="https://img.shields.io/badge/APK-Download%20v1.0.0-brightgreen?logo=android" height="40">](https://github.com/frarthur/supaview/releases/tag/v1.0.0)

> Enable **"Install from unknown sources"** in Android settings.

---

## Build from source

### Prerequisites

- [Flutter](https://flutter.dev) 3.38+
- Dart 3.10+
- JDK 17
- Android SDK (for Android) / Xcode (for iOS)

```bash
git clone https://github.com/frarthur/supaview.git
cd supaview
flutter pub get
dart run build_runner build
```

### Android

```bash
# Debug
flutter run

# Release APK
flutter build apk --release --split-per-abi

# Release AAB (Play Store)
flutter build appbundle --release
```

> For release builds, you need a keystore. Generate one:
> ```bash
> keytool -genkey -v -keystore upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload
> ```
> Then create `android/key.properties`:
> ```
> storePassword=<your-password>
> keyPassword=<your-password>
> keyAlias=upload
> storeFile=upload-keystore.jks
> ```

### iOS

```bash
flutter run
flutter build ios --release
```

---

## Architecture

```
lib/
├── core/           # Services, constants, utilities
├── features/       # Clean Architecture (domain/data/presentation)
│   ├── projects/   # Project CRUD
│   ├── tables/     # Table browser
│   ├── sql/        # SQL editor
│   ├── storage/    # File browser
│   ├── authentication/  # User management
│   ├── functions/  # Edge Functions
│   └── settings/   # Preferences
├── widgets/        # Shared widgets
├── theme/          # Material 3
├── app.dart
└── main.dart
```

**Stack:** Flutter • Riverpod • GoRouter • Supabase Flutter SDK • Hive • Flutter Secure Storage

---

## Roadmap

See [ROADMAP.md](ROADMAP.md) for the full plan.

---

## License

MIT — see [LICENSE](LICENSE).

SupaView is **not affiliated with Supabase Inc.**
