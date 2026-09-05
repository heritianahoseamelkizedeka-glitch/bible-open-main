<!-- markdownlint-disable MD060 -->

# Melkizedek — Implementation Status

Dernière mise à jour : 2026-09-05

| Module | Statut | Version | Health | Auth | Base de données | Tests | Intégrations | Prochaine action |
|---|---|---|---|---|---|---|---|---|
| Core | IN_PROGRESS | 0.x | API locale 8085 | Cookie session, CSRF, RBAC | PostgreSQL + migrations | Jest partiel | Pastorale, Communication, Communauté | Stabiliser le contrat et ajouter health/ready |
| Membres / ChMS | NOT_STARTED | — | — | À concevoir | À concevoir | — | Fonctions partielles dans Communauté | Extraire l'ownership des personnes |
| Bible | AUDITED | 0.x | Portail 5174 | À intégrer au Core | Aucun backend propre | Build | Quiz, Study via URLs | Clarifier le rôle portail vs moteur Bible |
| Study Bible | AUDITED | 0.x | 9891 | Supabase Auth | Supabase + Prisma/PostgreSQL | Vitest, Playwright | Bible, médias à formaliser | Définir adaptateur d'identité Core |
| Quiz Biblique | AUDITED | 0.x | 5173 | Supabase Auth | Supabase/PostgreSQL + RLS | Vitest | Bible, paiements/dons locaux | Définir adaptateur d'identité Core |
| Formation & Discipulat | NOT_STARTED | — | — | — | — | — | — | Spécifier ownership et modèle LMS |
| Louange & Adoration | NOT_STARTED | — | — | — | — | — | — | Spécifier répertoire, équipes et setlists |
| Communauté & Groupes | IN_PROGRESS | 0.x | 5180 / API 8084 | Token local + intégration Core frontend | JSON local | Vitest, smoke tests | Core, événements, notifications | Définir source de vérité membres/groupes |
| Pastorale | IN_PROGRESS | 0.x | 5183 / API 8083 | Accès Core partagé | Migrations SQL | Frontend/API build OK; tests métier à renforcer | Core, dossiers sensibles | Renforcer tests backend et confidentialité |
| Communication | IN_PROGRESS | 0.x | 5182 / API 8082 | Accès Core partagé | Migrations SQL | Frontend/API build OK; Vitest et intégration à renforcer | Core, temps réel, LiveKit | Formaliser contrats campagnes/messages |
| Événements & Inscriptions | NOT_STARTED | — | — | — | — | — | Fonction partielle Communauté | Décider extraction depuis Communauté |
| Volontaires & Ministères | NOT_STARTED | — | — | — | — | — | Fonction partielle Communauté | Définir planning transverse |
| Enfance & Jeunesse | NOT_STARTED | — | — | — | — | — | — | Concevoir check-in et permissions mineurs |
| Intendance, Dons & Finance | IN_PROGRESS | 0.x | 5190 | Auth backend non démontrée | IndexedDB/Dexie local | Vitest | Export CSV | Concevoir backend persistant et RBAC financier |
| Patrimoine & Locaux | NOT_STARTED | — | — | — | — | — | Aucun | Spécifier assets, maintenance et réservations |
| Media & Sermons | NOT_STARTED | — | — | — | — | — | Fonctions partielles Study/Communication | Définir médiathèque et publication |
| Mission & Action sociale | NOT_STARTED | — | — | — | — | — | Aucun | Définir minimisation et rétention des données |
| Publishing / Site public | NOT_STARTED | — | — | — | — | — | Portail statique actuel | Définir CMS et agrégation de contenus |
| Workflows & Formulaires | NOT_STARTED | — | — | — | — | — | Aucun moteur transverse démontré | Définir contrats de déclencheurs/actions |
| Analytics & Reporting | NOT_STARTED | — | — | — | — | — | Rapports locaux dans plusieurs apps | Définir indicateurs autorisés et exports |
| Shared Contracts | AUDITED | — | — | — | `Commun` non packagé | — | `core-access.cjs` partagé directement | Versionner les contrats et supprimer les imports internes |
| Launcher | IN_PROGRESS | 0.x | URLs locales | — | `.dev-servers.json` état local | Scripts smoke à renforcer | Démarre 8 applications/services | Extraire config `apps.json` après stabilisation |

## Légende

- `NOT_STARTED` : domaine cible non implémenté comme module autonome.
- `AUDITED` : état observé pendant la Phase 0.
- `IN_PROGRESS` : fonctions existantes mais intégration ou stabilisation incomplète.
- `FUNCTIONAL`, `INTEGRATED`, `TESTED`, `STABLE` : statuts à attribuer après preuves de validation.

## Risques ouverts

1. Les clients historiques peuvent encore référencer `8081`; migrer vers `8085` et vérifier les configurations.
2. Authentification encore fragmentée entre Core, Supabase, tokens locaux et IndexedDB.
3. Plusieurs applications modifient déjà leur dépôt localement; aucun changement n'a été annulé.
4. Les données sensibles pastorales, financières et mineurs nécessitent une validation de permissions et de rétention avant intégration à Search/Analytics.
5. Le launcher ne démarre pas encore les APIs séparées; leur ajout dépend d'une configuration runtime explicite, notamment `DATABASE_URL` pour Core.
