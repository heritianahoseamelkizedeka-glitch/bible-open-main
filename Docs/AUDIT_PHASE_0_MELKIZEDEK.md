<!-- markdownlint-disable MD060 -->

# Audit Phase 0 — Melkizedek

Date de l'audit : 2026-09-05
Périmètre : workspace `bo-bible-open`
Méthode : inspection des manifestes, sources, migrations, launchers et dépôts Git. Aucun fichier n'a été supprimé, déplacé ou réinitialisé.

## A. Workspace

| Dossier | Rôle actuel | Statut observé |
|---|---|---|
| `APK Quizz Biblique BO v2` | Quiz biblique, progression, abonnements et dons | Existant, riche fonctionnellement |
| `bible-open-main` | Portail/catalogue et launcher principal | Existant, frontend statique |
| `Study-bible-open` | Lecture et étude biblique avancée | Existant, riche fonctionnellement |
| `Commun` | Documentation, assets et utilitaire Core partagé | Support partagé, pas une application |
| `communaute-eglise` | Membres, groupes, ministères, présence, annonces | Existant, backend JSON local |
| `communication-eglise` | Communication, messages, annonces, temps réel et médias | Existant, backend NestJS |
| `eglise-core` | Auth, utilisateurs, rôles, permissions, notifications, recherche, audit | Existant, socle transversal en construction |
| `intendance-eglise` | Finance, dons, transactions, budgets et rapports | Existant, frontend local uniquement |
| `vie-pastorale-eglise` | Suivis pastoraux, rendez-vous, prières, cérémonies et documents | Existant, backend NestJS |

## B. Technologies

| Application | Frontend | Backend / données | Tests et build |
|---|---|---|---|
| Quiz | Vite, React 18, TypeScript, React Router, Capacitor, PWA | Supabase, migrations SQL, RLS, Supabase Auth | Vitest, lint, typecheck, builds web/mobile |
| Portail | Vite statique, HTML/CSS/JS | Aucun backend propre | Vite build |
| Study Bible | Next.js 16, React 19, TypeScript, Tailwind 4, Capacitor | Supabase SSR, Prisma/PostgreSQL, migrations | Vitest, Playwright, lint, typecheck, builds |
| Communauté | Vite, React 18, TypeScript, Capacitor, Recharts | Node HTTP, JSON local (`community.json`) | Vitest et smoke tests |
| Communication | Vite, React 18, TypeScript | NestJS, Socket.IO, LiveKit, migrations SQL | Vitest, vérifications et scripts de performance |
| Core | Vite, React 18, TypeScript | NestJS, `pg`, PostgreSQL, migrations SQL | Jest backend, typecheck/build à confirmer |
| Intendance | Vite, React, TypeScript, Zustand, Dexie, Capacitor | IndexedDB local, pas de backend applicatif | Vitest |
| Pastorale | Vite, React 18, TypeScript | NestJS, migrations SQL, accès Core | Tests frontend limités, build/typecheck à renforcer |

Package manager commun observé : npm avec `package-lock.json`. Aucun workspace npm global, package pnpm/yarn, Maven, Gradle, Python, Go ou Rust n'a été identifié.

## C. Ports et lancement

| Application | Frontend | API / service | Source |
|---|---:|---:|---|
| Bible Open Main | 5174 | — | `bible-open-main/Launcher/Web/launch-app.ps1` |
| Quiz Biblique | 5173 | Supabase | launcher principal et script Quiz |
| Study Bible | 9891 | Supabase / Prisma | launcher principal |
| Communauté Église | 5180 | 8084 | launcher et backend communauté |
| Église Core | 5181 | 8085 | décision Phase 1 |
| Communication Église | 5182 | 8082 | launcher et backend communication |
| Vie pastorale | 5183 | 8083 | launcher et backend pastoral |
| Intendance Église | 5190 | — | launcher; stockage navigateur |

### Décision Phase 1 — port Core

- `eglise-core/Backend/scripts/local-db.cjs` écrit `PORT=8085`.
- Le frontend Core et plusieurs clients utilisent `127.0.0.1:8085`.
- Le fallback du serveur Core et les documents principaux sont désormais alignés sur `8085`.
- Le launcher démarre le frontend sur `5181`; l'API Core reste configurable via `PORT`.

Décision : `8085` est le port API Core de développement. Toute configuration cliente historique sur `8081` doit être migrée explicitement.

## D. Git

| Dossier | Racine Git | Branche | Remote | État |
|---|---|---|---|---|
| `APK Quizz Biblique BO v2` | dépôt indépendant | `main` | GitHub `APK-Quizz-Biblique-BO-v2` | propre lors du contrôle |
| `bible-open-main` | dépôt indépendant | `main` | GitHub `bible-open-main` | modifications locales sur le portail |
| `Study-bible-open` | dépôt indépendant | `main` | GitHub `bo-bible-open` | propre lors du contrôle |
| `communaute-eglise` | dépôt indépendant | `main` | remote non affiché | modifications et fichiers non suivis |
| `communication-eglise` | dépôt indépendant | `main` | remote non affiché | modifications et fichiers non suivis |
| `eglise-core` | dépôt indépendant | `main` | remote non affiché | modifications et fichiers non suivis |
| `intendance-eglise` | dépôt indépendant | `main` | GitHub `intendance-eglise` | propre lors du contrôle |
| `vie-pastorale-eglise` | dépôt indépendant | `main` | remote non affiché | modification locale |
| `Commun` | aucun dépôt Git local | — | — | dossier partagé |
| workspace parent | aucun dépôt Git local | — | — | conteneur de dépôts |

Les changements locaux préexistants ont été conservés. Aucun reset, clean, changement de remote, commit ou push n'a été effectué.

## E. Données et bases

| Application | Persistance | Éléments observés |
|---|---|---|
| Quiz | Supabase/PostgreSQL | profils, questions, sessions, réponses, abonnements, dons, récompenses, recherche de mots, RLS |
| Study Bible | Supabase + Prisma/PostgreSQL | contenu biblique et étude; coexistence Prisma/Supabase à clarifier |
| Communauté | JSON local | `community.json`, synchronisation API locale |
| Communication | base SQL via migrations | schéma communication, permissions, messages/annonces et temps réel |
| Core | PostgreSQL via `pg` | identités, organisations, rôles, permissions, sessions, notifications, recherche, audit |
| Intendance | IndexedDB/Dexie | transactions, comptes/caisses, budgets et seeds locaux |
| Pastorale | base SQL via migrations | suivis, prières, tâches, plans, documents et permissions |

Aucune stratégie de source de vérité commune n'est encore établie pour les personnes, les organisations et les finances.

## F. Authentification et autorisations

- **Core** possède une authentification par cookie de session, CSRF, rôles et permissions, avec `coreUserId` implicite via l'acteur courant.
- **Pastorale** utilise un middleware d'accès Core et des permissions côté backend.
- **Communication** délègue l'accès à `Commun/Backend/core-access.cjs`.
- **Quiz** utilise Supabase Auth, profils et RLS indépendamment du Core.
- **Study Bible** utilise Supabase Auth/SSR indépendamment du Core.
- **Intendance** ne présente pas de backend d'authentification démontré; le rôle de trésorier est local.
- **Communauté** utilise un token Bearer local pour la synchronisation et possède une intégration Core côté frontend.

Conclusion : le SSO Melkizedek n'est pas encore réalisé. La migration doit commencer par un contrat d'identité et une stratégie d'adaptateurs, sans supprimer les authentifications actuelles.

## G. UI et architecture

- Les applications métier utilisent majoritairement Vite + React + TypeScript.
- Study Bible utilise Next.js et son propre système de composants/features.
- Capacitor est présent dans plusieurs applications.
- Le portail principal est un catalogue statique qui pointe vers les ports locaux.
- Aucun package de design system partagé n'a été identifié.
- `Commun` contient surtout documentation, assets et un utilitaire d'accès Core, pas de package publié.

## H. Dépendances inter-applications

1. Le launcher de `bible-open-main` démarre et référence les applications par URL locale.
2. Core fournit auth, RBAC, notifications, recherche et audit pour les modules NestJS intégrés.
3. `communication-eglise` et `vie-pastorale-eglise` importent directement `Commun/Backend/core-access.cjs`.
4. Communauté synchronise ses données via son propre backend JSON.
5. Quiz et Study Bible restent branchés directement à Supabase.
6. Intendance n'expose actuellement aucun contrat backend inter-module.

Le couplage direct à un fichier de `Commun` est une dépendance de workspace à remplacer progressivement par un package ou un contrat versionné.

## I. Duplications et écarts

- Authentification et modèles utilisateur sont dupliqués entre Core, Quiz et Study Bible.
- Les rôles/permissions ne suivent pas encore une nomenclature unique entre les applications.
- Notifications et communication existent à plusieurs niveaux.
- Événements, membres et groupes apparaissent dans Communauté, Communication et Pastorale sans ownership global formalisé.
- Finance existe dans Intendance mais reste locale au navigateur, donc non adaptée à un usage multi-utilisateur.
- Port et configuration Core sont incohérents.
- Les tests backend de Pastorale et les tests d'intégration inter-applications sont insuffisants ou non démontrés.

## J. Risques prioritaires

| Priorité | Risque | Action recommandée |
|---|---|---|
| P0 | Secrets potentiels dans `.runtime` ou fichiers locaux | Vérifier les fichiers suivis, rotation si exposés, conserver uniquement des exemples sans secrets |
| P1 | Clients historiques Core sur 8081 | Migrer explicitement vers 8085 et vérifier les configurations |
| P1 | Plusieurs identités utilisateur | Définir Core comme autorité cible et construire des adaptateurs progressifs |
| P1 | Finance uniquement IndexedDB | Concevoir une API/backend persistante avant usage partagé ou production |
| P1 | Données pastorales et enfants sensibles | Vérifier permissions backend, audit, rétention et non-indexation globale |
| P2 | Couplage direct à `Commun/Backend/core-access.cjs` | Publier un contrat d'accès versionné |
| P2 | Absence de tests d'intégration globaux | Ajouter smoke tests Core ↔ modules prioritaires |
| P2 | Launcher avec URLs/ports codés en dur | Introduire une configuration `apps.json` après stabilisation |

## K. Mapping cible

| Actuel | Cible Melkizedek |
|---|---|
| `eglise-core` | Core |
| `communaute-eglise` | Communauté & Groupes; une application Members/ChMS reste à extraire ou créer |
| `vie-pastorale-eglise` | Vie Pastorale |
| `bible-open-main` | Bible / portail public actuel; rôle exact à clarifier |
| `Study-bible-open` | Study Bible |
| `APK Quizz Biblique BO v2` | Quiz Biblique |
| `communication-eglise` | Communication |
| `intendance-eglise` | Intendance, Dons & Finance |
| `Commun` | Shared Contracts / documentation / assets, après audit complémentaire |

## L. Applications manquantes par rapport à l'architecture cible

Non présentes comme applications autonomes :

- Membres / ChMS
- Formation & Discipulat
- Louange & Adoration
- Événements & Inscriptions dédié
- Volontaires & Ministères dédié
- Enfance & Jeunesse / Check-in
- Patrimoine, Matériel & Locaux
- Média, Sermons & Livestream dédié
- Mission, Évangélisation & Action sociale
- Publishing / CMS public
- Workflows & Formulaires transverse
- Analytics & Reporting transverse

Certaines fonctions existent partiellement dans Communauté, Communication, Pastorale, Study Bible ou Intendance. Il faut éviter de créer des applications autonomes avant d'avoir défini leur ownership et vérifié les fonctionnalités réutilisables.

## M. Plan recommandé

1. **Phase 0 — Audit** : ce rapport et le suivi d'implémentation sont créés; aucun module métier nouveau n'est créé.
2. **Phase 1 — Architecture** : décider ownership, contrat Core, port API, stratégie de données et frontières de `Commun`.
3. **Phase 2 — Core** : stabiliser health check, configuration, migrations, session, RBAC, audit et notifications.
4. **Phase 3 — Identity/RBAC** : introduire les adaptateurs pour Quiz, Study Bible, Communauté, Communication et Pastorale.
5. **Phase 4 — Members** : créer le ChMS à partir des fonctions membres déjà présentes, sans dupliquer les mots de passe.
6. **Phase 5 — Intégration existante** : connecter progressivement les applications prioritaires au Core.
7. **Phase 6 — Search/Notifications** : centraliser avec filtrage par permission et exclusion des données sensibles.
8. **Phase 7+ — Nouveaux domaines** : Formation, Louange, Events, Volontaires, Kids, Patrimoine, Media, Mission, Publishing.
9. **Dernières phases** : workflows, analytics, launcher indépendant, sécurité renforcée, E2E et documentation finale.

## Conclusion

L'écosystème est déjà substantiel mais hétérogène. La priorité n'est pas de créer immédiatement les douze applications manquantes : elle est de stabiliser Core, l'identité, la configuration et les propriétaires de données. Les modules existants peuvent évoluer indépendamment, mais ils ne partagent pas encore un contrat d'intégration suffisamment cohérent pour une migration Big Bang sûre.
