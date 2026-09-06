# Architecture — Bible Open Main

## Rôle du dépôt

`bible-open-main` est le portail et l’orchestrateur de l’écosystème Bible Open. Les applications métiers restent dans des dépôts séparés afin de pouvoir être développées, testées et livrées indépendamment.

## Workspace de référence

Le workspace local peut contenir les dépôts suivants côte à côte :

- `bible-open-main`
- `APK Quizz Biblique BO v2`
- `Study-bible-open`
- `communaute-eglise`
- `eglise-core`
- `communication-eglise`
- `intendance-eglise`
- `vie-pastorale-eglise`
- `louange-eglise`
- `Commun` pour les composants, contrats ou adaptateurs transversaux partagés

`Commun` n’est pas une application lancée par le portail et ne reçoit donc pas de port frontend.

## Composants du dépôt principal

- `Frontend/web/` : portail web Vite.
- `Frontend/web/public/config/applications.json` : registre central des applications.
- `Frontend/web/application-registry.js` : validation et résolution des URLs du registre.
- `Launcher/Web/` : lancement local coordonné sous Windows.
- `Scripts/export/` : génération des suites Web et APK.
- `Backend/` : emplacement réservé aux futurs services centraux spécifiques au portail.
- `Tests/` : tests de contrat du registre.
- `Docs/` : documentation fonctionnelle et technique.
- `Artifacts/` : livrables générés localement, non versionnés dans `Artifacts/exports/`.

## Registre des applications

Le fichier `Frontend/web/public/config/applications.json` est la source de vérité pour :

- les identifiants techniques des applications ;
- les noms affichés ;
- les ports locaux ;
- les URLs locales ;
- les futures URLs publiques ;
- les chemins par défaut des dépôts liés ;
- les variables d’environnement permettant de remplacer ces chemins ;
- le caractère requis ou optionnel de chaque application pour le launcher.

Le portail et le launcher lisent ce même registre afin d’éviter de dupliquer les ports et les chemins.

## Applications enregistrées

| Identifiant | Application | Port local | Dépôt / chemin web |
| --- | --- | ---: | --- |
| `quiz` | Quizz Biblique | 5173 | `APK Quizz Biblique BO v2/Frontend/web` |
| `portal` | Bible Open Main | 5174 | `bible-open-main/Frontend/web` |
| `community` | Communauté Église | 5180 | `communaute-eglise/Frontend/web` |
| `core` | Église Core | 5181 | `eglise-core/Frontend/web` |
| `communication` | Communication Église | 5182 | `communication-eglise/Frontend/web` |
| `pastoral` | Vie pastorale Église | 5183 | `vie-pastorale-eglise/Frontend/web` |
| `worship` | Louange Église | 5184 | racine de `louange-eglise` |
| `stewardship` | Intendance Église | 5190 | `intendance-eglise/Frontend/web` |
| `study` | Study Bible | 9891 | `Study-bible-open/Frontend/web` |

Louange est actuellement le seul frontend dont le `package.json` se trouve directement à la racine de son dépôt ; le registre prend explicitement en charge ce cas avec `webPath: "."`.

## Chemins locaux personnalisés

Par défaut, le dépôt principal suppose que les dépôts liés se trouvent à côté de lui dans le même dossier de travail. Cette convention peut être remplacée sans modifier le code avec :

- `BIBLE_OPEN_QUIZ_ROOT`
- `BIBLE_OPEN_STUDY_ROOT`
- `BIBLE_OPEN_COMMUNITY_ROOT`
- `BIBLE_OPEN_CORE_ROOT`
- `BIBLE_OPEN_COMMUNICATION_ROOT`
- `BIBLE_OPEN_STEWARDSHIP_ROOT`
- `BIBLE_OPEN_PASTORAL_ROOT`
- `BIBLE_OPEN_WORSHIP_ROOT`

Chaque variable doit pointer vers la racine du dépôt concerné.

## Environnements

En environnement local (`localhost`, `127.0.0.1`, `::1`), le portail utilise `localUrl`.

En environnement public, le portail utilise uniquement `productionUrl`. Si aucune URL publique n’est configurée, l’application est affichée comme bientôt disponible et aucun lien `localhost` n’est exposé à l’utilisateur.

## APIs transversales actuellement reconnues par le launcher

Avec `-StartApis`, le launcher peut démarrer les APIs suivantes lorsqu’elles sont présentes et correctement configurées :

- Église Core : port 8085 ;
- Communication Église : port 8082 ;
- Vie pastorale Église : port 8083 ;
- Louange Église : port 8086.

Ces APIs conservent leurs propres responsabilités et leur propre configuration dans leurs dépôts respectifs.

## Principes d’évolution

1. Garder les applications métiers découplées du portail.
2. Utiliser `Commun` uniquement pour les contrats et composants réellement partagés, pas comme dépendance fourre-tout.
3. Centraliser les métadonnées d’intégration dans le registre.
4. Éviter les chemins absolus, secrets et URLs locales codées en dur dans les interfaces publiques.
5. Passer les changements par une branche et une Pull Request.
6. Faire réussir les tests, la validation PowerShell, le build et l’audit avant fusion dans `main`.
7. Ajouter toute nouvelle application au registre, aux tests et à la documentation dans le même changement.
