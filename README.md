# SupaView

> Admin mobile pour Supabase — gérez vos bases Supabase directement depuis votre téléphone.

[![Version](https://img.shields.io/badge/version-1.0.0-blue.svg)](https://github.com/frarthur/supaview/releases)
[![Flutter](https://img.shields.io/badge/Flutter-3.38+-02569B?logo=flutter)](https://flutter.dev)
[![License](https://img.shields.io/badge/license-MIT-green.svg)](LICENSE)

---

**SupaView** est un véritable phpMyAdmin pour Supabase sur mobile.  
L'application communique **uniquement** entre votre téléphone et Supabase via HTTPS.  
Aucun serveur intermédiaire, aucune télémétrie, aucune publicité.

## ✨ Fonctionnalités

| | Fonctionnalité | Statut |
|---|---|---|
| ✅ | Connexion sécurisée (URL + Anon Key + Service Role Key) | v1.0.0 |
| ✅ | Dashboard avec statistiques du projet | v1.0.0 |
| ✅ | Navigation par projets | v1.0.0 |
| ✅ | Gestion des tables (CRUD, tri, filtre, pagination) | v1.0.0 |
| ✅ | Éditeur SQL (SELECT) | v1.0.0 |
| ✅ | Storage (navigation buckets, fichiers) | v1.0.0 |
| ✅ | Auth (écran utilisateurs) | v1.0.0 |
| ✅ | Edge Functions (écran) | v1.0.0 |
| ✅ | Thème Material 3 (clair/sombre) | v1.0.0 |
| 🔜 | Export CSV/JSON | À venir |
| 🔜 | Mode hors-ligne | À venir |
| 🔜 | Widgets Android | À venir |

## 📥 Téléchargement

**Dernière version stable : [v1.0.0](https://github.com/frarthur/supaview/releases/tag/v1.0.0)**

[<img src="https://img.shields.io/badge/APK-Download%20v1.0.0-brightgreen?logo=android" height="40">](https://github.com/frarthur/supaview/releases/download/v1.0.0/supaview-v1.0.0.apk)

> ⚠️ L'APK est généré automatiquement à chaque release via GitHub Actions.  
> Activez "Installation depuis des sources inconnues" sur votre Android pour installer l'APK.

## 🚀 Pour commencer

1. **Créez un projet Supabase** sur [database.new](https://database.new)
2. Dans votre projet, allez dans **Settings > API Keys**
3. Copiez l'**URL du projet** et l'**Anon Key**
4. Ouvrez SupaView, ajoutez un projet, testez la connexion
5. Pour les fonctionnalités avancées, ajoutez la **Service Role Key**

## 🏗️ Architecture

```
lib/
├── core/           # Services, constantes, utilitaires
├── features/       # Fonctionnalités (Clean Architecture)
│   ├── authentication/
│   ├── projects/
│   ├── tables/
│   ├── sql/
│   ├── storage/
│   ├── functions/
│   └── settings/
├── widgets/        # Widgets partagés
├── theme/          # Thème Material 3
├── app.dart        # Configuration de l'application
└── main.dart       # Point d'entrée
```

**Stack technique :**
- **Flutter 3.38+** avec Dart 3.10
- **Riverpod** pour la gestion d'état
- **GoRouter** pour la navigation
- **Supabase Flutter SDK** pour la communication
- **Hive** pour le stockage local
- **Flutter Secure Storage** pour les clés API

## 🔧 Développement

```bash
# Cloner le projet
git clone https://github.com/frarthur/supaview.git
cd supaview

# Installer les dépendances
flutter pub get

# Générer les fichiers (freezed, json_serializable)
dart run build_runner build

# Lancer l'application
flutter run
```

## 🗺️ Roadmap

Voir [ROADMAP.md](ROADMAP.md) pour le plan de développement détaillé.

## 📄 License

Ce projet est sous licence MIT. Voir le fichier [LICENSE](LICENSE) pour plus de détails.

---

*SupaView n'est pas affilié à Supabase. Supabase est une marque déposée de Supabase Inc.*
