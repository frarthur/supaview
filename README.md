# SupaView

> Mobile admin for Supabase — manage your Supabase projects directly from your phone.

[![Version](https://img.shields.io/badge/version-1.0.0-blue.svg)](https://github.com/frarthur/supaview/releases)
[![Flutter](https://img.shields.io/badge/Flutter-3.38+-02569B?logo=flutter)](https://flutter.dev)
[![License](https://img.shields.io/badge/license-MIT-green.svg)](LICENSE)

---

SupaView is a **phpMyAdmin-like mobile app for Supabase**.  
It communicates **directly between your phone and Supabase via HTTPS** — no intermediate server, no telemetry, no ads, no subscriptions.

## ✨ Features

| | Feature | Version |
|---|---|---|
| ✅ | Secure connection (URL + Anon Key + Service Role Key) | v1.0.0 |
| ✅ | Project dashboard with live stats | v1.0.0 |
| ✅ | Project management (add, edit, delete) | v1.0.0 |
| ✅ | Tab navigation (Dashboard, Tables, SQL, Storage) | v1.0.0 |
| ✅ | Table browser (CRUD, sort, filter, pagination) | v1.0.0 |
| ✅ | SQL editor (SELECT queries) | v1.0.0 |
| ✅ | Storage browser (buckets, files, delete) | v1.0.0 |
| ✅ | Auth user management | v1.0.0 |
| ✅ | Edge Functions (list, logs, invoke) | v1.0.0 |
| ✅ | Material 3 theme (light/dark) | v1.0.0 |
| 🔜 | CSV/JSON export | Upcoming |
| 🔜 | Offline mode | Upcoming |

## 📥 Download

**Latest stable release:** [v1.0.0](https://github.com/frarthur/supaview/releases/tag/v1.0.0)

[<img src="https://img.shields.io/badge/APK-Download%20v1.0.0-brightgreen?logo=android" height="40">](https://github.com/frarthur/supaview/releases/download/v1.0.0/supaview-v1.0.0.apk)

> Enable **"Install from unknown sources"** in Android settings to install the APK.

## 🚀 Getting started

1. Create a Supabase project at [database.new](https://database.new)
2. Go to **Settings → API Keys** in your project dashboard
3. Copy your **Project URL** and **Anon Key** (or **Publishable Key**)
4. Open SupaView, add a project, test the connection
5. For advanced features (stats, SQL), add the **Service Role Key**

## 🏗️ Architecture

```
lib/
├── core/           # Services, constants, utilities
├── features/       # Clean Architecture
│   ├── authentication/
│   ├── projects/
│   ├── tables/
│   ├── sql/
│   ├── storage/
│   ├── functions/
│   └── settings/
├── widgets/        # Shared widgets
├── theme/          # Material 3 theme
├── app.dart
└── main.dart
```

**Tech stack:**
- **Flutter 3.38+** • Dart 3.10
- **Riverpod** — state management
- **GoRouter** — navigation
- **Supabase Flutter SDK** — API client
- **Hive** — local storage
- **Flutter Secure Storage** — encrypted API keys

## 🔧 Development

```bash
git clone https://github.com/frarthur/supaview.git
cd supaview
flutter pub get
dart run build_runner build
flutter run
```

## 🗺️ Roadmap

See [ROADMAP.md](ROADMAP.md) for the full development plan.

## 📄 License

MIT License. See [LICENSE](LICENSE).

---

*SupaView is not affiliated with Supabase Inc.*
