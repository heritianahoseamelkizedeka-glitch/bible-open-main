# Lanceur Web

- `launch-app.ps1` démarre la vitrine et les deux applications liées.
- `stop-app.ps1` arrête proprement tous les processus créés par ce lanceur.

| Application | Adresse locale |
| --- | --- |
| Bible Open Main | `http://localhost:5174` |
| Quizz Biblique | `http://localhost:5173` |
| Study Bible | `http://localhost:9891` |

```powershell
powershell -ExecutionPolicy Bypass -File Launcher/Web/launch-app.ps1
```

Ajoutez `-NoBrowser` pour ne pas ouvrir automatiquement le navigateur.
