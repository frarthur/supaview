# SupaView — Roadmap Projet

## Vision

Application mobile Flutter permettant d'administrer une base **Supabase** directement depuis son téléphone.

L'application communique **uniquement** entre le téléphone et Supabase via HTTPS.

Aucun serveur intermédiaire, aucune télémétrie, aucune publicité, aucun abonnement.

L'objectif est d'offrir un véritable **phpMyAdmin pour Supabase sur mobile**, moderne et ergonomique.

---

## Choix Techniques

| Aspect           | Choix                         | Justification                       |
| ---------------- | ----------------------------- | ----------------------------------- |
| **Langage**      | Dart 3                        | Flutter natif                       |
| **Framework**    | Flutter                       | Android + iOS                       |
| **Architecture** | Clean Architecture + Riverpod | Maintenable et scalable             |
| **Base locale**  | Hive / Isar                   | Sauvegarde des connexions           |
| **Connexion**    | supabase_flutter              | SDK officiel                        |
| **Sécurité**     | Chiffrement Secure Storage    | Stockage sécurisé des clés          |
| **Analytics**    | Aucun                         | Respect de la vie privée            |
| **Backend**      | Aucun                         | Communication directe avec Supabase |

---

# Structure du projet

```text
SupaView/

lib/

 ├── core/
 │     ├── services/
 │     ├── models/
 │     ├── utils/
 │     └── constants/
 │
 ├── features/
 │
 │     ├── authentication/
 │
 │     ├── projects/
 │
 │     ├── tables/
 │
 │     ├── sql/
 │
 │     ├── storage/
 │
 │     ├── functions/
 │
 │     └── settings/
 │
 ├── widgets/
 │
 ├── theme/
 │
 └── main.dart
```

---

# Fonctionnalités principales

## Gestion des projets

* ajout d'un projet
* modification
* suppression

Chaque projet contient :

* URL Supabase
* Anon Key
* Service Role Key (optionnelle)
* Nom personnalisé
* Couleur
* Icône

---

## Dashboard

Après connexion :

```
Projet

🟢 connecté

Tables : 24

Storage : 8

Users : 157

Functions : 5

Dernière activité
```

---

## Tables

Comme phpMyAdmin :

```
products

id

name

price

stock
```

Possibilité de :

* rechercher
* filtrer
* trier
* masquer des colonnes
* pagination
* modifier une cellule
* supprimer une ligne
* créer une ligne
* dupliquer une ligne

---

## Éditeur de ligne

```
id

154

name

Hypocaps

price

15€

stock

25
```

Validation automatique selon le type.

---

## Éditeur SQL

```sql
SELECT *

FROM products

LIMIT 100;
```

* coloration syntaxique
* historique
* favoris
* export CSV/JSON
* affichage formaté

---

## Storage

Navigation façon explorateur :

```
📂 images

📂 users

📄 logo.png
```

Actions :

* upload
* download
* suppression
* renommage
* aperçu image
* partage de lien

---

## Auth

Visualisation :

```
email

created_at

last_login
```

Actions :

* supprimer utilisateur
* désactiver
* reset password
* créer utilisateur

(si les permissions du projet le permettent)

---

## Edge Functions

* liste
* logs
* statut
* invocation
* copie URL

---

## Paramètres

* thème clair/sombre
* langue
* timeout réseau
* biométrie
* verrouillage automatique
* export/import des connexions

---

## Sécurité

* stockage des clés dans Secure Storage
* verrouillage par empreinte digitale
* chiffrement des données locales
* aucune donnée envoyée à un serveur tiers
* aucun tracking
* fonctionnement hors ligne pour les configurations enregistrées

---

# Phases

## Phase 1 — Fondations

* [ ] Créer le projet Flutter
* [ ] Configurer Riverpod
* [ ] Configurer GoRouter
* [ ] Mettre en place les thèmes
* [ ] Écrire le ROADMAP.md

---

## Phase 2 — Gestion des connexions ✅

* [x] Ajouter un projet
* [x] Modifier un projet
* [x] Supprimer un projet
* [x] Stockage sécurisé des clés
* [x] Test de connexion

---

## Phase 3 — Dashboard ✅

* [x] Informations générales (header avec statut connexion)
* [x] Statistiques du projet (tables, storage, users)
* [x] Navigation (shell + bottom nav + drawer sections)
* [x] Rafraîchissement automatique (pull-to-refresh)

---

## Phase 4 — Gestion des tables ✅

* [x] Liste des tables avec schéma (colonnes, PK)
* [x] Consultation des données (DataTable scrollable)
* [x] Recherche avec debounce + colonne cible
* [x] Tri par colonne
* [x] Pagination (pages)
* [x] Création de ligne (formulaire typé)
* [x] Modification de ligne (double-tap)
* [x] Suppression de ligne

---

## Phase 5 — Éditeur SQL

* [ ] Exécution de requêtes
* [ ] Historique
* [ ] Favoris
* [ ] Export CSV
* [ ] Export JSON

---

## Phase 6 — Storage

* [ ] Navigation
* [ ] Upload
* [ ] Download
* [ ] Suppression
* [ ] Prévisualisation

---

## Phase 7 — Auth & Edge Functions

* [ ] Gestion des utilisateurs
* [ ] Gestion des fonctions
* [ ] Consultation des logs

---

## Phase 8 — Expérience utilisateur

* [ ] Animations
* [ ] Widgets Material 3
* [ ] Recherche globale
* [ ] Pull-to-refresh
* [ ] Mode tablette
* [ ] Optimisations de performances

---

## Phase 9 — Publication

* [ ] Icône
* [ ] Splash screen
* [ ] Captures Play Store
* [ ] README GitHub
* [ ] Site web
* [ ] Politique de confidentialité ("Aucune donnée collectée")
* [ ] Génération du fichier AAB
* [ ] Publication sur Google Play
* [ ] Publication sur GitHub

---

## Fonctionnalités "premium" qui peuvent faire la différence

* ⭐ Visualisation des relations entre tables (ERD)
* ⭐ Générateur CRUD à partir d'une table
* ⭐ Éditeur de politiques RLS
* ⭐ Exécution de migrations SQL
* ⭐ Historique des modifications locales
* ⭐ Sauvegarde/restauration de requêtes favorites
* ⭐ Multi-projets avec changement en un clic
* ⭐ Dashboard personnalisable
* ⭐ Widgets Android affichant les statistiques d'un projet
* ⭐ IA locale pour expliquer une erreur SQL (en utilisant une clé API personnelle de l'utilisateur, sans passer par tes serveurs)

---

## 🗺️ Feuille de route actuelle

1. Choisir le nom définitif du projet et vérifier la disponibilité
2. Créer le dépôt GitHub et le `ROADMAP.md`
3. Initialiser le projet Flutter
4. Concevoir l'architecture (Clean Architecture + Riverpod)
5. Implémenter la gestion sécurisée des connexions Supabase
6. Développer le dashboard du projet
7. Ajouter la gestion complète des tables (CRUD)
8. Ajouter l'éditeur SQL avec historique et favoris
9. Intégrer la gestion du Storage et des utilisateurs
10. Finaliser l'UX, les animations et les optimisations
11. Rédiger le README et le site web
12. Générer l'AAB et publier sur Google Play
13. Publier le projet sur GitHub
14. Étudier une publication sur F-Droid si l'application reste totalement libre et sans dépendances propriétaires.
