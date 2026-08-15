# Bible Open — Accueil

La vitrine centrale de l’écosystème Bible Open. Elle répertorie les applications actuelles et accueillera les projets à venir.

## Structure

```text
Artifacts/       Livrables générés
Assets/          Ressources partagées
Backend/         Futurs services centraux
Docs/            Documentation
Frontend/web/    Application web Vite
Launcher/Web/    Lanceur local PowerShell
```

## Applications

- Quizz Biblique Bible Open
- Study Bible Open

## Développement

```bash
npm install
npm run dev
```

Pour générer la version de production :

```bash
npm run build
```

Sous Windows, le lanceur démarre directement l’application sur le port `5174` :

```powershell
powershell -ExecutionPolicy Bypass -File Launcher/Web/launch-app.ps1
```
