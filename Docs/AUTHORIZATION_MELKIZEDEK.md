<!-- markdownlint-disable MD060 -->

# Authentification et autorisations — Melkizedek

Statut : proposition Phase 1
Date : 2026-09-05

## Cible

Core devient l'autorité d'identité de la plateforme. Il fournit une session unique, un `coreUserId`, une organisation et les permissions effectives. Les modules métier ne stockent pas de mot de passe.

La migration ne supprime pas immédiatement Supabase Auth, les tokens locaux ou le rôle local d'Intendance. Chaque application doit d'abord adopter un adaptateur compatible, puis migrer ses données et ses tests.

## Contrat d'acteur

```text
ActorContext {
  coreUserId: string
  organizationId: string
  roles: string[]
  permissions: string[]
  sessionId: string
}
```

Le backend propriétaire doit toujours vérifier l'organisation, la permission et l'accès à la ressource. Les contrôles frontend sont uniquement ergonomiques.

## Permissions minimales par domaine

| Domaine | Lecture | Gestion |
|---|---|---|
| Members | `member.view` | `member.manage` |
| Pastorale | `pastoral.case.view` | `pastoral.case.manage` |
| Bible / Study | `bible.access`, `study_bible.access` | permissions d'administration du contenu |
| Quiz | `quiz.access` | `quiz.manage` |
| Communauté | `community.view` | `community.manage` |
| Communication | `communication.view` | `communication.manage`, `communication.send` |
| Events | `event.view` | `event.manage` |
| Volontaires | `volunteer.view` | `volunteer.manage` |
| Kids | `kids.checkin` | `kids.manage` |
| Finance | `finance.view` | `finance.manage`, `finance.approve` |
| Patrimoine | `asset.view` | `asset.manage` |
| Media | `media.view` | `media.manage`, `media.publish` |
| Mission | `mission.view` | `mission.manage` |
| Administration | `admin.view` | permissions Core dédiées |

Les codes existants doivent être mappés avant d'en introduire de nouveaux; les changements de contrat sont versionnés.

## Niveaux sensibles

- `PASTORAL_PUBLIC` : résumé sans note sensible.
- `PASTORAL_RESTRICTED` : accès aux responsables autorisés.
- `PASTORAL_CONFIDENTIAL` : permission dédiée, non indexé dans Search.
- Finance, Kids et Mission appliquent le même principe de moindre privilège.

## Ordre de migration

1. Stabiliser Core, session, CSRF, RBAC et health check.
2. Publier un `CoreClient` documenté et versionné.
3. Adapter Pastorale et Communication, déjà intégrées à Core.
4. Adapter Communauté et déplacer progressivement son token local.
5. Ajouter un lien d'identité pour Quiz et Study Bible sans supprimer leurs données.
6. Ajouter l'autorisation backend à Intendance avant toute synchronisation distante.
7. Tester les scénarios de refus, changement de rôle, session expirée et isolation d'organisation.

## Interdictions

- Ne pas faire confiance à un rôle envoyé par le frontend.
- Ne pas utiliser un simple rôle `admin` pour contourner les permissions sensibles.
- Ne pas indexer les notes pastorales, données financières détaillées ou données enfants dans Search global.
- Ne pas enregistrer mots de passe, tokens complets ou données sensibles inutiles dans les logs.
