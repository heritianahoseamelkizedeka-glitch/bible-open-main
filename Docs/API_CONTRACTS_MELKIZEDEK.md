<!-- markdownlint-disable MD060 -->

# Contrats API — Melkizedek

Statut : proposition Phase 1
Date : 2026-09-05

## Principes

- Les API sont versionnées sous `/api/v1`.
- Un module expose ses DTO publics; ses tables et fichiers internes restent privés.
- Les clients utilisent une URL de configuration, jamais une URL codée dans le métier.
- Les réponses d'erreur ont un format commun.
- Les endpoints sensibles vérifient session, organisation, permission et ownership.

## Contexte d'identité

Les modules intégrés à Core reçoivent une session Core par cookie sécurisé ou un mécanisme d'adaptateur documenté. Le serveur reconstruit l'acteur; il ne fait pas confiance à `userId`, `role` ou `permissions` fournis uniquement par le navigateur.

```text
GET /api/v1/auth/me

{
  "user": { "id": "core-user-id", "name": "..." },
  "organization": { "id": "organization-id", "name": "..." },
  "roles": ["MEMBER"],
  "permissions": ["member.view"]
}
```

## Contrats transverses proposés

### Health

```text
GET /health
GET /ready

{ "status": "ok", "service": "core", "version": "0.x" }
```

`/health` indique que le processus répond; `/ready` vérifie les dépendances nécessaires. Les secrets et détails de connexion ne sont jamais retournés.

### Erreur

```json
{
  "error": {
    "code": "PERMISSION_DENIED",
    "message": "Accès refusé.",
    "details": {}
  }
}
```

Codes minimaux : `VALIDATION_ERROR`, `UNAUTHENTICATED`, `PERMISSION_DENIED`, `NOT_FOUND`, `CONFLICT`, `PAYLOAD_TOO_LARGE`, `RATE_LIMITED`, `INTERNAL_ERROR`.

### Search

```text
GET /api/v1/search?q=...&module=...&page=1&pageSize=20
```

```text
SearchResult {
  id: string
  module: string
  type: string
  title: string
  excerpt?: string
  targetUrl: string
  metadata?: object
}
```

Chaque provider filtre avant retour selon le contexte Core. Pastorale confidentielle, finance privée, enfants restreints et bénéficiaires sensibles sont exclus par défaut.

### Notifications

```text
GET /api/v1/notifications?page=1&pageSize=20
PATCH /api/v1/notifications/:id/read
```

Les notifications portent `sourceModule`, `title`, `message`, `targetUrl`, `status`, `createdAt` et `readAt`. Les modules créent une notification via Core ou un événement documenté, sans réimplémenter toute l'infrastructure.

## Contrats de domaine prioritaires

| Module | Base API cible | Contrats initiaux |
|---|---|---|
| Core | `/api/v1` | auth, users, roles, permissions, health, search, notifications, audit |
| Pastorale | `/api/v1/pastoral` | cases, appointments, prayers, tasks, documents |
| Communication | `/api/v1/communication` | posts, messages, campaigns, preferences |
| Communauté | `/api/v1/community` | people summary, groups, memberships, attendance |
| Finance | `/api/v1/finance` | accounts, transactions, funds, budgets, approvals |
| Events | `/api/v1/events` | events, registrations, attendance |
| Media | `/api/v1/media` | sermons, series, assets, publications |

Ces bases sont des contrats de cadrage; elles ne justifient pas encore la création de tous les modules.

## Configuration locale

Le port API Core de développement est `8085`, avec surcharge par `PORT`. Cette valeur doit être documentée dans un `.env.example` et consommée par :

- `eglise-core` frontend et backend;
- `Commun/Backend/core-access.cjs`;
- Communication;
- Pastorale;
- Communauté;
- le launcher.

Le launcher et les clients doivent utiliser cette configuration plutôt que coder une autre valeur.

## Compatibilité

- Ajouter les nouveaux champs avant de retirer les anciens.
- Conserver une version `/v1` pendant la migration des clients.
- Retourner des erreurs explicites et stables.
- Documenter toute modification de DTO dans un ADR.
- Tester chaque contrat avec un client réel ou un smoke test ciblé.
