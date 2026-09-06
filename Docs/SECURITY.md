# Sécurité — Bible Open Main

## Secrets et configuration locale

Ne jamais versionner :

- fichiers `.env` réels ;
- clés privées et certificats ;
- jetons d’API ;
- mots de passe ;
- APK et exports générés ;
- fichiers de logs contenant des données sensibles.

Le fichier `.env.example` sert uniquement de modèle et ne doit contenir aucun secret.

## Dépendances

La CI exécute :

```bash
npm audit --audit-level=high
```

Toute vulnérabilité élevée ou critique doit être évaluée avant fusion dans `main`.

## Liens d’applications

Le portail n’utilise les URLs `localhost` que lorsqu’il est lui-même exécuté localement. En environnement public, seules les valeurs `productionUrl` du registre d’applications sont autorisées.

## Branches et revue

Les changements fonctionnels doivent être préparés sur une branche dédiée et fusionnés via Pull Request après validation CI.

## Exports

Les manifestes d’export ne doivent pas exposer les chemins absolus locaux. Ils peuvent contenir des identifiants techniques non sensibles tels que les SHA de commits, la date de génération et les versions de build.

## Futur backend

Avant d’ajouter authentification, comptes utilisateurs ou données d’Église, prévoir au minimum :

- validation stricte des entrées ;
- gestion centralisée des secrets ;
- contrôle d’accès par rôles ;
- journalisation des actions sensibles ;
- protection CSRF/XSS selon l’architecture ;
- limitation de débit ;
- sauvegarde et chiffrement des données sensibles ;
- politique de rotation des clés et jetons.
