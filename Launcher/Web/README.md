# Lanceur Web

- `launch-app.ps1` démarre le portail et toutes les applications construites de l'écosystème.
- `stop-app.ps1` arrête proprement tous les processus créés par ce lanceur.

| Application | Adresse locale |
| --- | --- |
| Bible Open Main | `http://localhost:5174` |
| Quizz Biblique | `http://localhost:5173` |
| Study Bible | `http://localhost:9891` |
| Communauté Église | `http://localhost:5180` |
| Église Core | `http://localhost:5181` |
| Communication Église | `http://localhost:5182` |
| Vie pastorale Église | `http://localhost:5183` |
| Intendance Église | `http://localhost:5190` |

Les dépôts dont le frontend n'est pas encore construit sont signalés puis ignorés. Ils seront automatiquement intégrés dès qu'un fichier `Frontend/web/package.json` sera présent.

```powershell
powershell -ExecutionPolicy Bypass -File Launcher/Web/launch-app.ps1
```

Ajoutez `-NoBrowser` pour ne pas ouvrir automatiquement le navigateur.

## Disponibilité de Core

Avant le démarrage, le launcher vérifie `/api/v1/ready` et exige une réponse 200
avec `status=ready` et `service=eglise-core-api`. Une page HTML, une redirection
ou le simple endpoint `/health` ne sont pas considérés comme Core prêt.
Ce contrôle initial ne constitue pas une surveillance continue.

Par défaut, Core indisponible produit un avertissement de mode dégradé et permet
le démarrage des frontends. `-RequireCore` annule le démarrage avant tout arrêt
ou lancement de processus si Core n'est pas prêt.

```powershell
powershell -ExecutionPolicy Bypass -File Launcher/Web/launch-app.ps1 -CheckOnly
powershell -ExecutionPolicy Bypass -File Launcher/Web/launch-app.ps1 -RequireCore -NoBrowser
```

`-CheckOnly` effectue uniquement le diagnostic Core : code de sortie 0 si prêt,
1 sinon. Il ne requiert pas npm et ne touche pas au fichier d'état des processus.
L'adresse de base est choisie par `-CoreApiUrl`, puis `CORE_API_URL`, puis
`http://127.0.0.1:8085/api/v1`. Aucun identifiant, query ou fragment n'est accepté
dans cette URL. Les APIs et les migrations ne sont pas démarrées automatiquement.

Tests du contrôle : `powershell -ExecutionPolicy Bypass -File Launcher/Web/test-core-readiness.ps1`.

Pour afficher les applications et la présence de leurs manifestes sans rien démarrer
ni interroger Core (`-ListOnly` ne prouve pas leur disponibilité HTTP) :

```powershell
powershell -ExecutionPolicy Bypass -File Launcher/Web/launch-app.ps1 -ListOnly
```
