# Lanceur Web

Le launcher principal utilise `Frontend/web/public/config/applications.json` comme source de vérité pour les frontends de la plateforme.

- `launch-app.ps1` démarre le portail et les applications dont le manifeste est présent.
- `launch-app.ps1 -StartApis` démarre aussi les APIs Core, Communication, Vie pastorale et Louange.
- `stop-app.ps1` arrête uniquement les processus enregistrés par le launcher.

## Frontends

| Application | Adresse locale |
| --- | --- |
| Bible Open Main | `http://localhost:5174` |
| Quizz Biblique | `http://localhost:5173` |
| Study Bible | `http://localhost:9891` |
| Communauté Église | `http://localhost:5180` |
| Église Core | `http://localhost:5181` |
| Communication Église | `http://localhost:5182` |
| Vie pastorale Église | `http://localhost:5183` |
| Louange Église | `http://localhost:5184` |
| Intendance Église | `http://localhost:5190` |

## APIs optionnelles

| API | Adresse de contrôle |
| --- | --- |
| Église Core | `http://127.0.0.1:8085/api/v1/ready` |
| Communication Église | `http://127.0.0.1:8082/api/v1/communication/health` |
| Vie pastorale Église | `http://127.0.0.1:8083/api/v1/pastoral/health` |
| Louange Église | `http://127.0.0.1:8086/api/v1/louange/health` |

## Démarrage standard

```powershell
powershell -ExecutionPolicy Bypass -File Launcher/Web/launch-app.ps1
```

Ajouter `-NoBrowser` pour ne pas ouvrir automatiquement le portail.

## Démarrage avec les APIs

Les APIs NestJS nécessitent leur configuration locale, notamment la base de données lorsque le module l'exige.

```powershell
powershell -ExecutionPolicy Bypass -File Launcher/Web/launch-app.ps1 -StartApis -NoBrowser
```

Pour exiger que Core soit prêt :

```powershell
powershell -ExecutionPolicy Bypass -File Launcher/Web/launch-app.ps1 -StartApis -RequireCore -NoBrowser
```

## Diagnostic Core

```powershell
powershell -ExecutionPolicy Bypass -File Launcher/Web/launch-app.ps1 -CheckOnly
```

Le contrôle Core exige `/api/v1/ready` avec une réponse 200 identifiant `eglise-core-api` comme prêt. L'adresse de base peut être remplacée avec `-CoreApiUrl` ou `CORE_API_URL`.

## Inventaire sans démarrage

```powershell
powershell -ExecutionPolicy Bypass -File Launcher/Web/launch-app.ps1 -ListOnly
```

Avec `-StartApis -ListOnly`, le launcher affiche aussi les manifestes des APIs.

## Chemins locaux personnalisés

Les dépôts sont normalement placés à côté de `bible-open-main`. Une autre organisation peut être utilisée avec les variables documentées dans `.env.example`, par exemple `BIBLE_OPEN_WORSHIP_ROOT` ou `BIBLE_OPEN_CORE_ROOT`.

Le registre central doit être mis à jour lorsqu'une nouvelle application rejoint la plateforme ; le portail et le launcher l'utiliseront ensuite sans dupliquer les ports et chemins dans plusieurs fichiers.
