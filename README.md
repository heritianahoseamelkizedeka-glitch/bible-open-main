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

Les cartes ouvrent directement les pages d’accueil locales :

- Quizz Biblique : `http://localhost:5173/`
- Study Bible : `http://localhost:9891/`

## Développement

```bash
npm install
npm run dev
```

Pour générer la version de production :

```bash
npm run build
```

Sous Windows, le lanceur démarre le portail, Quizz Biblique et Study Bible, puis ouvre le portail sur le port `5174` :

```powershell
powershell -ExecutionPolicy Bypass -File Launcher/Web/launch-app.ps1
```
