# Développement local

## Prérequis

- Node.js `^20.19.0` ou `>=22.12.0`
- npm `>=10`
- PowerShell pour les launchers et exports Windows
- Git pour identifier les versions exportées

## Installation du portail

À la racine du dépôt :

```bash
npm ci
npm run dev
```

Le portail utilise le workspace npm `Frontend/web`.

## Dépôts liés

Le registre `Frontend/web/public/config/applications.json` contient les chemins par défaut des applications liées.

Pour utiliser une autre organisation de dossiers, définir les variables d’environnement suivantes :

```text
BIBLE_OPEN_QUIZ_ROOT=C:\chemin\vers\repo-quizz
BIBLE_OPEN_STUDY_ROOT=C:\chemin\vers\repo-study
```

Sous PowerShell pour la session courante :

```powershell
$env:BIBLE_OPEN_QUIZ_ROOT = 'C:\chemin\vers\repo-quizz'
$env:BIBLE_OPEN_STUDY_ROOT = 'C:\chemin\vers\repo-study'
```

## Lancer la suite locale

```powershell
powershell -ExecutionPolicy Bypass -File Launcher/Web/launch-app.ps1
```

Ajouter `-NoBrowser` pour ne pas ouvrir automatiquement le portail.

## Build de validation

```bash
npm run build
npm audit --audit-level=high
```

Ces contrôles sont également exécutés par GitHub Actions.

## Workflow Git recommandé

Créer une branche pour chaque changement :

```text
feature/nom-fonctionnalite
fix/nom-correction
chore/nom-maintenance
```

Puis ouvrir une Pull Request vers `main`. La branche principale ne doit pas servir de branche de développement quotidien.

## URL publiques

Avant un déploiement Web public, renseigner `productionUrl` pour chaque application publiée dans :

```text
Frontend/web/public/config/applications.json
```

Ne jamais mettre une URL `localhost` dans `productionUrl`.
