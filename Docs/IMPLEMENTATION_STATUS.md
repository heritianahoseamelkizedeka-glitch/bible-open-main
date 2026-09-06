<!-- markdownlint-disable MD060 -->

# Melkizedek — Implementation Status

Dernière mise à jour : 2026-09-05

| Module | Statut | Version | Health | Auth | Base de données | Tests | Intégrations | Prochaine action |
|---|---|---|---|---|---|---|---|---|
| Core | IN_PROGRESS | 0.x | API locale 8085; `/health`, `/ready` | Cookie session, CSRF, RBAC | PostgreSQL + migrations | Frontend 3/3; backend 19/19 | Pastorale, Communication, Communauté | Stabiliser le contrat et intégrer les APIs au launcher |
| Membres / ChMS | NOT_STARTED | — | — | À concevoir | À concevoir | — | Fonctions partielles dans Communauté | Extraire l'ownership des personnes |
| Bible | AUDITED | 0.x | Portail 5174 | À intégrer au Core | Aucun backend propre | Build | Quiz, Study via URLs | Clarifier le rôle portail vs moteur Bible |
| Study Bible | AUDITED | 0.x | 9891 | Supabase Auth | Supabase + Prisma/PostgreSQL | Vitest, Playwright | Bible, médias à formaliser | Définir adaptateur d'identité Core |
| Quiz Biblique | AUDITED | 0.x | 5173 | Supabase Auth | Supabase/PostgreSQL + RLS | Vitest | Bible, paiements/dons locaux | Définir adaptateur d'identité Core |
| Formation & Discipulat | NOT_STARTED | — | — | — | — | — | — | Spécifier ownership et modèle LMS |
| Louange & Adoration | IN_PROGRESS | 0.1.0 | 5184 / API 8086 | Core session, SSO intégré au backend | PostgreSQL migration 001; seed fictif frontend | Frontend Vitest 3/3; backend 1/1; typecheck/build OK | Launcher frontend/API | Connecter le frontend aux API et étendre CRUD métier |
| Communauté & Groupes | IN_PROGRESS | 0.x | 5180 / API 8084 | Token local + intégration Core frontend | JSON local | Frontend Vitest 4/4; smoke tests à renforcer | Core, événements, notifications | Définir source de vérité membres/groupes |
| Pastorale | IN_PROGRESS | 0.x | 5183 / API 8083 | Accès Core partagé | Migrations SQL | Frontend 6/6; backend 24/24; builds OK | Core, dossiers sensibles | Préparer intégration API au launcher |
| Communication | IN_PROGRESS | 0.x | 5182 / API 8082 | Accès Core partagé | Migrations SQL | Frontend Vitest 4/4; API build et health runtime OK | Core, temps réel, LiveKit | Formaliser contrats campagnes/messages |
| Événements & Inscriptions | NOT_STARTED | — | — | — | — | — | Fonction partielle Communauté | Décider extraction depuis Communauté |
| Volontaires & Ministères | NOT_STARTED | — | — | — | — | — | Fonction partielle Communauté | Définir planning transverse |
| Enfance & Jeunesse | NOT_STARTED | — | — | — | — | — | — | Concevoir check-in et permissions mineurs |
| Intendance, Dons & Finance | IN_PROGRESS | 0.x | 5190 | Auth backend non démontrée | IndexedDB/Dexie local | Frontend Vitest 7/7 | Export CSV | Concevoir backend persistant et RBAC financier |
| Patrimoine & Locaux | NOT_STARTED | — | — | — | — | — | Aucun | Spécifier assets, maintenance et réservations |
| Media & Sermons | NOT_STARTED | — | — | — | — | — | Fonctions partielles Study/Communication | Définir médiathèque et publication |
| Mission & Action sociale | NOT_STARTED | — | — | — | — | — | Aucun | Définir minimisation et rétention des données |
| Publishing / Site public | NOT_STARTED | — | — | — | — | — | Portail statique actuel | Définir CMS et agrégation de contenus |
| Workflows & Formulaires | NOT_STARTED | — | — | — | — | — | Aucun moteur transverse démontré | Définir contrats de déclencheurs/actions |
| Analytics & Reporting | NOT_STARTED | — | — | — | — | — | Rapports locaux dans plusieurs apps | Définir indicateurs autorisés et exports |
| Shared Contracts | AUDITED | — | — | — | `Commun` non packagé | — | `core-access.cjs` partagé directement | Versionner les contrats et supprimer les imports internes |
| Launcher | IN_PROGRESS | 0.x | URLs locales; APIs optionnelles | — | `.dev-servers.json` état local | Syntaxe et `-ListOnly -StartApis` validés | Démarre 3 APIs optionnelles puis 8 frontends | Extraire config `apps.json` après stabilisation |

## Légende

- `NOT_STARTED` : domaine cible non implémenté comme module autonome.
- `AUDITED` : état observé pendant la Phase 0.
- `IN_PROGRESS` : fonctions existantes mais intégration ou stabilisation incomplète.
- `FUNCTIONAL`, `INTEGRATED`, `TESTED`, `STABLE` : statuts à attribuer après preuves de validation.

## Risques ouverts

1. Les artefacts générés historiques peuvent encore contenir la chaîne `8081`; les configurations source Core sont alignées sur `8085`.
2. Authentification encore fragmentée entre Core, Supabase, tokens locaux et IndexedDB.
3. Plusieurs applications modifient déjà leur dépôt localement; aucun changement n'a été annulé.
4. Les données sensibles pastorales, financières et mineurs nécessitent une validation de permissions et de rétention avant intégration à Search/Analytics.
5. Le launcher démarre désormais les APIs séparées uniquement avec `-StartApis`; Core et Communication ont été validés au runtime, tandis que le scénario complet reste à confirmer.
