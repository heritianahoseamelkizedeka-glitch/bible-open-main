<!-- markdownlint-disable MD060 -->

# Ownership des données — Melkizedek

Statut : proposition Phase 1
Date : 2026-09-05

## Règle générale

Un domaine possède ses données métier. Les autres modules utilisent ses identifiants publics via API. Aucun module ne copie une fiche complète ou n'accède à la base privée d'un autre module.

## Matrice d'ownership

| Domaine | Entités principales | Références exposées |
|---|---|---|
| Core | `User`, `Organization`, `Role`, `Permission`, `Session`, `Notification`, `AuditLog` | `coreUserId`, `organizationId`, permissions |
| Members | `Person`, `MemberProfile`, `Household`, `Consent`, statut, tags | `personId`, résumé autorisé |
| Pastorale | `PastoralCase`, suivi, rendez-vous, prière, note, document pastoral | `caseId`, résumé filtré |
| Bible | livres, chapitres, versets, traductions autorisées, lecture | `referenceId`, références bibliques |
| Study Bible | commentaires, dictionnaires, références croisées, plans d'étude | `resourceId`, références |
| Quiz | questions, sessions, réponses, progression, badges | `quizId`, résultats autorisés |
| Communauté | groupes, cellules, adhésions, présence de groupe | `groupId`, `membershipId` |
| Communication | conversations, annonces, campagnes, préférences de canal | `messageId`, `campaignId` |
| Events | événements, inscriptions, présence | `eventId`, `registrationId` |
| Volontaires | équipes, compétences, disponibilités, affectations | `assignmentId`, `ministryId` |
| Kids | enfants, tuteurs, check-in/out, urgences | `childId`, informations strictement autorisées |
| Finance | dons, fonds, transactions, budgets, validations | `transactionId`, agrégats autorisés |
| Patrimoine | actifs, locaux, réservations, maintenance, stock | `assetId`, `roomId` |
| Media | sermons, séries, médias, transcriptions, publications | `mediaId`, URL publiée |
| Mission | campagnes, projets, bénéficiaires, actions sociales | `missionId`, résumé anonymisé si possible |
| Publishing | pages, articles, menus, formulaires publics | `contentId`, URL publique |

## Données sensibles

- Les notes pastorales confidentielles restent dans Pastorale et sont exclues de Search global.
- Les données financières détaillées restent dans Finance et sont exclues des profils membres publics.
- Les données d'enfants et informations médicales nécessaires au check-in ont des permissions dédiées et une rétention contrôlée.
- Les bénéficiaires d'action sociale sont minimisés, cloisonnés et non publiés par défaut.
- Les secrets, mots de passe et tokens ne sont jamais des données partagées.

## Identifiants et synchronisation

Les références inter-domaines utilisent des identifiants stables, jamais des chemins de fichiers ou des identifiants internes de base non documentés. Lorsqu'un module a besoin d'un résumé, son API retourne un DTO versionné et filtré par permission.

## Migration progressive

1. Documenter les identifiants actuellement utilisés.
2. Ajouter les champs de référence sans supprimer les anciens champs.
3. Lire la nouvelle référence avec fallback temporaire.
4. Migrer les données et vérifier les doublons.
5. Retirer l'ancien chemin uniquement après validation et période de compatibilité.
