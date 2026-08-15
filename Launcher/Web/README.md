# Lanceur Web

- `launch-app.ps1` démarre la vitrine Vite sur `http://localhost:5174`.
- `stop-app.ps1` arrête uniquement le processus créé par ce lanceur.

```powershell
powershell -ExecutionPolicy Bypass -File Launcher/Web/launch-app.ps1
```

Ajoutez `-NoBrowser` pour ne pas ouvrir automatiquement le navigateur.
