# Architecture — Bible Open Main

## Rôle du dépôt

`bible-open-main` est le portail et l’orchestrateur de l’écosystème Bible Open. Il ne doit pas contenir directement toutes les applications métiers. Les applications comme Quizz Biblique et Study Bible peuvent rester dans des dépôts séparés afin d’évoluer indépendamment.

## Composants

- `Frontend/web/` : portail web Vite.
- `Frontend/web/public/config/applications.json` : registre central des applications.
- `Launcher/Web/` : lancement local coordonné sous Windows.
- `Scripts/export/` : génération des suites Web et APK.
- `Backend/` : emplacement réservé aux futurs services centraux.
- `Docs/` : documentation fonctionnelle et technique.
- `Artifacts/` : livrables générés localement, non versionnés dans `Artifacts/exports/`.

## Registre des applications

Le fichier `Frontend/web/public/config/applications.json` est la source de vérité pour :

- les noms des applications ;
- les ports locaux ;
- les URLs locales ;
- les futures URLs publiques ;
- les chemins par défaut des dépôts liés ;
- les variables d’environnement permettant de remplacer ces chemins.

Les scripts PowerShell et le portail doivent lire ce registre au lieu de dupliquer les chemins ou ports.

## Dépôts liés

Par défaut, le dépôt principal suppose que les dépôts liés se trouvent à côté de lui dans le même dossier de travail. Cette convention peut être remplacée sans modifier le code avec :

- `BIBLE_OPEN_QUIZ_ROOT`
- `BIBLE_OPEN_STUDY_ROOT`

Chaque variable doit pointer vers la racine du dépôt concerné.

## Environnements

En environnement local (`localhost`, `127.0.0.1`, `::1`), le portail utilise `localUrl`.

En environnement public, le portail utilise uniquement `productionUrl`. Si aucune URL publique n’est configurée, l’application est affichée comme bientôt disponible et aucun lien `localhost` n’est exposé à l’utilisateur.

## Principes d’évolution

1. Garder les applications métiers découplées du portail.
2. Centraliser la configuration partagée.
3. Éviter les chemins absolus et les secrets dans Git.
4. Passer les changements par une branche et une Pull Request.
5. Faire réussir la CI avant fusion dans `main`.
