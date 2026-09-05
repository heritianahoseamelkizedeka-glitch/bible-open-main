# Architecture cible — Melkizedek

Statut : proposition Phase 1
Date : 2026-09-05

## Principes

- Les applications métier restent des dépôts indépendants.
- Core possède l'identité technique, les organisations, les rôles, les permissions, les notifications, la recherche et l'audit.
- Une application ne lit jamais les fichiers privés d'une autre application.
- Les échanges passent par des API ou des contrats versionnés.
- Les migrations sont progressives et rétrocompatibles.
- Les données sensibles restent dans leur domaine et ne sont pas indexées globalement sans autorisation.

## Cartographie cible

```text
Melkizedek
├── Core                         eglise-core
├── Members / ChMS               à extraire de Communauté puis compléter
├── Pastorale                    vie-pastorale-eglise
├── Bible / portail              bible-open-main
├── Study Bible                  Study-bible-open
├── Quiz                         APK Quizz Biblique BO v2
├── Communauté & Groupes         communaute-eglise
├── Communication               communication-eglise
├── Intendance & Finance         intendance-eglise
├── Formation                    à créer après le socle
├── Louange                     à créer après le socle
├── Événements                  à extraire ou créer après ownership
├── Volontaires                 à extraire ou créer après ownership
├── Enfance & Jeunesse          à créer avec modèle de sécurité dédié
├── Patrimoine & Locaux         à créer après contrat Finance
├── Media & Sermons             à créer après contrat Publishing
├── Mission & Action sociale    à créer avec politique de confidentialité
└── Publishing                  à créer comme couche de publication
```

## Frontières

### Core

Core est l'autorité pour `User`, `Organization`, `Role`, `Permission`, `Session`, `Notification`, `AuditLog` et l'orchestration Search. Il ne possède pas les détails métier des chants, dossiers pastoraux, dons ou événements.

### Membres

Members possèdera les personnes, foyers, profils de membre, statuts, tags, consentements et affectations générales. Les autres domaines référencent `personId` ou `coreUserId` et ne recopient pas le profil complet.

### Applications métier

Chaque domaine possède ses entités et règles : Pastorale possède les dossiers pastoraux, Finance les transactions, Louange les chants et setlists, Media les sermons et fichiers publiables.

## Flux d'intégration

1. L'utilisateur s'authentifie auprès de Core.
2. Core fournit une session et les permissions de l'acteur.
3. Le frontend ouvre un module via le launcher ou une URL publique configurée.
4. Le module appelle son backend avec le contexte d'identité Core.
5. Les opérations sensibles sont autorisées dans le backend propriétaire.
6. Les notifications, recherches et publications passent par des contrats dédiés.

## Configuration et launcher

La configuration cible doit centraliser `name`, `directory`, `command`, `port`, `apiUrl`, `healthUrl`, `required` et `startupOrder` dans un fichier de configuration du launcher. La conversion de `launch-app.ps1` vers ce modèle est une tâche ultérieure, après résolution du port API Core.

## Décisions en attente

- ~~Choisir `8081` ou `8085` comme port API Core de développement.~~ Décidé : `8085` en développement local, configurable via `PORT`.
- Déterminer si Study Bible conserve Prisma et Supabase ou choisit une source de vérité.
- Définir la stratégie de migration des identités Supabase vers Core.
- Définir le stockage persistant d'Intendance.
- Décider si Events et Members deviennent des dépôts autonomes ou des domaines extraits progressivement.
