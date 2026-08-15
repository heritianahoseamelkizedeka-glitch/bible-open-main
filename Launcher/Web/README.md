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

Pour afficher les applications et leur disponibilité sans rien démarrer :

```powershell
powershell -ExecutionPolicy Bypass -File Launcher/Web/launch-app.ps1 -ListOnly
```
