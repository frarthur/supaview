# SupaView

> Admin mobile pour Supabase — gérez vos bases Supabase directement depuis votre téléphone.

[![Version](https://img.shields.io/badge/version-1.0.0-blue.svg)](https://github.com/frarthur/supaview/releases)
[![Flutter](https://img.shields.io/badge/Flutter-3.38+-02569B?logo=flutter)](https://flutter.dev)
[![Licence](https://img.shields.io/badge/licence-MIT-green.svg)](LICENSE)

---

SupaView est un véritable **phpMyAdmin pour Supabase sur mobile**, moderne et ergonomique.  
L'application communique **uniquement** entre votre téléphone et Supabase via HTTPS.  
Aucun serveur intermédiaire, aucune télémétrie, aucune publicité, aucun abonnement.

## ✨ Fonctionnalités

| | Fonctionnalité | Version |
|---|---|---|
| ✅ | Connexion sécurisée (URL + Anon Key + Service Role Key) | v1.0.0 |
| ✅ | Dashboard avec statistiques du projet | v1.0.0 |
| ✅ | Gestion des projets (ajout, modification, suppression) | v1.0.0 |
| ✅ | Navigation par onglets (Dashboard, Tables, SQL, Storage) | v1.0.0 |
| ✅ | Gestion des tables (CRUD, tri, filtre, pagination) | v1.0.0 |
| ✅ | Éditeur SQL (requêtes SELECT) | v1.0.0 |
| ✅ | Storage (navigation buckets, fichiers, suppression) | v1.0.0 |
| ✅ | Auth (gestion des utilisateurs) | v1.0.0 |
| ✅ | Edge Functions (liste, logs, invocation) | v1.0.0 |
| ✅ | Thème Material 3 (clair/sombre) | v1.0.0 |
| 🔜 | Export CSV/JSON | À venir |
| 🔜 | Mode hors-ligne | À venir |

## 📥 Télécharger

**Dernière version stable :** [v1.0.0](https://github.com/frarthur/supaview/releases/tag/v1.0.0)

[<img src="https://img.shields.io/badge/APK-T%C3%A9l%C3%A9charger%20v1.0.0-brightgreen?logo=android" height="40">](https://github.com/frarthur/supaview/releases/download/v1.0.0/supaview-v1.0.0.apk)

> Activez **"Installation depuis des sources inconnues"** dans les paramètres Android pour installer l'APK.

## 🚀 Pour commencer

1. Créez un projet Supabase sur [database.new](https://database.new)
2. Dans votre projet, allez dans **Settings → API Keys**
3. Copiez l'**URL du projet** et l'**Anon Key** (ou la **Publishable Key**)
4. Ouvrez SupaView, ajoutez un projet, testez la connexion
5. Pour les fonctionnalités avancées (stats, SQL), ajoutez la **Service Role Key**

## 🏗️ Architecture

```
lib/
├── core/           # Services, constantes, utilitaires
├── features/       # Clean Architecture
│   ├── authentication/
│   ├── projects/
│   ├── tables/
│   ├── sql/
│   ├── storage/
│   ├── functions/
│   └── settings/
├── widgets/        # Widgets partagés
├── theme/          # Thème Material 3
├── app.dart
└── main.dart
```

**Stack technique :**
- **Flutter 3.38+** • Dart 3.10
- **Riverpod** — gestion d'état
- **GoRouter** — navigation
- **Supabase Flutter SDK** — API
- **Hive** — stockage local
- **Flutter Secure Storage** — clés API chiffrées

## 🔧 Développement

```bash
git clone https://github.com/frarthur/supaview.git
cd supaview
flutter pub get
dart run build_runner build
flutter run
```

## 🗺️ Roadmap

Voir [ROADMAP.md](ROADMAP.md) pour le plan complet.

## 📄 Licence

Projet sous licence MIT. Voir le fichier [LICENSE](LICENSE).

---

*SupaView n'est pas affilié à Supabase Inc.*
