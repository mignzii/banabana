# KYC Upload — Design Spec
Date: 2026-05-14

## Objectif

Améliorer le flux KYC sur deux axes :
1. **Prévisualisation des documents** — thumbnail inline dans la tuile + modal plein écran au tap
2. **États KYC différenciés** — 4 états distincts (pas soumis / en cours / refusé / approuvé)

## Contexte

Le `KycScreen` existant (`lib/features/auth/screens/kyc_screen.dart`) est fonctionnel : il pick une image via galerie, valide la taille (max 5 Mo), et appelle `repo.submitKyc()`. Ce qui manque :
- Aucun aperçu de l'image sélectionnée (juste une coche verte)
- Pas de distinction entre "jamais soumis" et "soumis, en attente de review" (les deux affichent le même message)

## Section 1 — `_DocUploadTile` avec thumbnail + modal

### Comportement sans image (inchangé)
- Icône `Symbols.upload_file` + label + bordure grise

### Comportement avec image
- Thumbnail `56×56` arrondi à gauche (via `Image.file(File(xfile.path), fit: BoxFit.cover)`)
- Label au centre
- Badge "Modifier" cliquable à droite → relance `ImagePicker` directement
- **Tap sur le thumbnail** → ouvre `_DocPreviewDialog`

### `_DocPreviewDialog` (nouveau widget privé dans `kyc_screen.dart`)
- `showDialog` avec fond `Colors.black`
- Image en `BoxFit.contain` centrée
- Bouton "Fermer" (retour) + bouton "Remplacer" (relance ImagePicker, ferme le dialog)
- Pas de Hero animation (XFile n'est pas une URL, pas de réseau)

### Modification de `_DocUploadTile`
Signature inchangée. On ajoute un paramètre optionnel `onReplace: VoidCallback?` (appelé quand l'utilisateur tape "Modifier" ou "Remplacer" dans le dialog). Le parent (`_KycScreenState`) passe `() => _pickImage(isFront)` comme `onReplace`.

## Section 2 — États KYC différenciés

### Nouveau flag dans `StorageService`
Clé : `'kyc_submitted_locally'` (bool, `SharedPreferences`)

Méthodes à ajouter :
```dart
Future<bool> getKycSubmittedLocally() async { ... }
Future<void> setKycSubmittedLocally(bool value) async { ... }
```

### Quand poser le flag
- **`true`** : dans `KycScreen._submit()`, après `repo.submitKyc()` réussit et avant `context.pop()`
- **Reset** : non nécessaire, le serveur prime toujours (voir logique d'affichage ci-dessous)

### Logique d'affichage (partagée entre `KycScreen` et `ProfileScreen`)

| `kycStatus` | `kycSubmittedLocally` | Message | Couleur |
|---|---|---|---|
| `'pending'` | `false` | "Soumettez vos documents d'identité" | `AppColors.warning` (jaune) |
| `'pending'` | `true` | "Documents en cours de vérification (24–48h)" | `AppColors.info` (bleu) |
| `'rejected'` | — | "Documents refusés — veuillez soumettre à nouveau" | `AppColors.error` (rouge) |
| `'approved'` | — | Badge "Identité vérifiée" (déjà géré, aucun changement) | `AppColors.success` |

Note : quand `kycStatus == 'rejected'`, on affiche le formulaire de re-soumission (comportement actuel inchangé).

### Modification de `KycScreen`
- Lire `kycSubmittedLocally` en `initState` via `ref.read(storageServiceProvider)`
- Si `kycStatus == 'pending'` && `submittedLocally == true` → remplacer la bannière warning par une bannière info "En cours de vérification"
- Bouton "Soumettre" reste désactivé si `kycStatus == 'pending' && submittedLocally == true` (déjà soumis)
- À `_submit()` réussi : appeler `storage.setKycSubmittedLocally(true)` avant `context.pop()`

### Modification de `ProfileScreen`
- Lire `kycSubmittedLocally` depuis le provider pour distinguer les deux états `'pending'`
- Le `ListTile` d'action KYC affiche le bon message selon l'état combiné
- Si `kycStatus == 'pending' && submittedLocally == true` : désactiver le tap (ou afficher "En cours de vérification" sans flèche)

## Section 3 — Fix routing : `/auth/kyc` → `/kyc`

### Problème identifié
Le router (`app_router.dart:76-77`) redirige tout utilisateur **authentifié** qui tente d'accéder à une route commençant par `/auth/` vers son dashboard :

```dart
if (isAuth && isAuthRoute) return _roleHome(authState.user?.role);
```

`/auth/kyc` commence par `/auth/` → la page est **inaccessible** pour les utilisateurs connectés. Le `context.push('/auth/kyc')` depuis `ProfileScreen` provoque une redirection silencieuse vers le home.

### Fix
1. Déplacer la route de `/auth/kyc` vers `/kyc` dans `app_router.dart`
2. Ajouter `/kyc` comme route **protégée** (redirect vers `/auth/login` si `!isAuthenticated`)
3. Mettre à jour tous les appels : `context.push('/auth/kyc')` → `context.push('/kyc')`

### Route protégée (hors shell)
```dart
GoRoute(
  parentNavigatorKey: _rootNavKey,
  path: '/kyc',
  name: 'kyc',
  pageBuilder: (_, __) => _fadePage(const KycScreen()),
),
```

La logique de redirect existante couvre déjà le cas `!isAuth && !isAuthRoute` → redirige vers `/auth/login`. Aucun changement supplémentaire nécessaire dans le redirect.

## Fichiers impactés

| Fichier | Modification |
|---|---|
| `lib/core/router/app_router.dart` | Déplacer `/auth/kyc` → `/kyc` hors du bloc auth |
| `lib/core/storage/storage_service.dart` | +2 méthodes (`getKycSubmittedLocally`, `setKycSubmittedLocally`) |
| `lib/features/auth/screens/kyc_screen.dart` | Refonte `_DocUploadTile` + nouveau `_DocPreviewDialog` + logique états |
| `lib/shared/screens/profile_screen.dart` | Mise à jour chemin `/auth/kyc` → `/kyc` + logique états KYC |

## Ce qui ne change pas

- L'API backend (`/users/kyc` POST avec FormData recto/verso) — inchangée
- La validation taille max 5 Mo — inchangée
- Le comportement si `kycStatus == 'approved'` — inchangé

## Hors scope

- Option caméra (galerie uniquement, aligné avec le choix utilisateur)
- Flux post-login KYC obligatoire
- Modification du modèle `User`
