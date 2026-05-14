# KYC Upload Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Corriger la route `/auth/kyc` inaccessible aux utilisateurs connectés, ajouter la prévisualisation des documents dans le `KycScreen`, et différencier les 4 états KYC (pas soumis / en cours / refusé / approuvé).

**Architecture:** Fix routing (déplacer `/auth/kyc` → `/kyc`), ajout d'un flag `kycSubmittedLocally` en `SharedPreferences` dans `StorageService`, refonte de `_DocUploadTile` avec thumbnail + modal plein écran, mise à jour du `ProfileScreen` pour afficher l'état KYC différencié.

**Tech Stack:** Flutter 3, Riverpod 2 (`StateNotifierProvider`), GoRouter 14, `image_picker`, `shared_preferences`, `flutter_secure_storage`, `material_symbols_icons`

---

## Structure des fichiers

| Fichier | Action | Responsabilité |
|---|---|---|
| `lib/core/router/app_router.dart` | Modifier | Déplacer `/auth/kyc` → `/kyc` hors du bloc auth |
| `lib/core/storage/storage_service.dart` | Modifier | +2 méthodes KYC flag + update `clearAll()` |
| `test/core/storage/storage_service_test.dart` | Créer | Tests unitaires du flag KYC |
| `lib/features/auth/screens/kyc_screen.dart` | Modifier | Thumbnail + modal + états KYC |
| `lib/shared/screens/profile_screen.dart` | Modifier | Chemin `/kyc` + états KYC + import storage |

---

## Task 1 : Fix routing — `/auth/kyc` → `/kyc`

**Files:**
- Modify: `lib/core/router/app_router.dart`

Le redirect actuel (`if (isAuth && isAuthRoute)`) renvoie tout utilisateur connecté qui tente d'accéder à `/auth/*` vers son dashboard. La route `/auth/kyc` est donc inaccessible une fois connecté. On la déplace à `/kyc` (route protégée, hors zone `/auth/`).

- [ ] **Step 1 : Supprimer la route `/auth/kyc` du bloc auth dans `app_router.dart`**

Ligne 111 actuelle :
```dart
GoRoute(path: '/auth/kyc', pageBuilder: (_, __) => _fadePage(const KycScreen())),
```
Supprimer cette ligne entière.

- [ ] **Step 2 : Ajouter la route `/kyc` hors du bloc auth**

Insérer après le bloc wholesaler (après la ligne `path: '/shop/orders/:id'`) et avant le bloc vendor, en utilisant `_rootNavKey` pour qu'elle s'affiche par-dessus tous les shells :

```dart
// KYC — route protégée (accessible uniquement si authentifié)
GoRoute(
  parentNavigatorKey: _rootNavKey,
  path: '/kyc',
  name: 'kyc',
  pageBuilder: (_, __) => _fadePage(const KycScreen()),
),
```

La logique de redirect existante couvre déjà le cas `!isAuthenticated && path != /auth/*` → redirige vers `/auth/login`. Aucun changement dans la fonction `redirect`.

- [ ] **Step 3 : Commit**

```bash
git add lib/core/router/app_router.dart
git commit -m "fix: move /auth/kyc to /kyc to allow access when authenticated"
```

---

## Task 2 : StorageService — flag `kycSubmittedLocally`

**Files:**
- Modify: `lib/core/storage/storage_service.dart`
- Create: `test/core/storage/storage_service_test.dart`

- [ ] **Step 1 : Écrire le test qui échoue**

Créer `test/core/storage/storage_service_test.dart` :

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:banabana_b2b/core/storage/storage_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('StorageService — kycSubmittedLocally', () {
    test('returns false by default', () async {
      final storage = StorageService();
      expect(await storage.getKycSubmittedLocally(), false);
    });

    test('returns true after setting to true', () async {
      final storage = StorageService();
      await storage.setKycSubmittedLocally(true);
      expect(await storage.getKycSubmittedLocally(), true);
    });

    test('can be reset to false', () async {
      final storage = StorageService();
      await storage.setKycSubmittedLocally(true);
      await storage.setKycSubmittedLocally(false);
      expect(await storage.getKycSubmittedLocally(), false);
    });
  });
}
```

- [ ] **Step 2 : Lancer le test pour vérifier qu'il échoue**

```bash
cd /Users/mac/Documents/banabana/banabana_b2b
flutter test test/core/storage/storage_service_test.dart
```

Résultat attendu : erreur `The method 'getKycSubmittedLocally' isn't defined`

- [ ] **Step 3 : Implémenter le flag dans `StorageService`**

Dans `lib/core/storage/storage_service.dart`, ajouter la constante en haut avec les autres :

```dart
const _kKycSubmitted = 'kyc_submitted_locally';
```

Ajouter les deux méthodes après `isBiometricEnabled()` :

```dart
Future<bool> getKycSubmittedLocally() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getBool(_kKycSubmitted) ?? false;
}

Future<void> setKycSubmittedLocally(bool value) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setBool(_kKycSubmitted, value);
}
```

Mettre à jour `clearAll()` pour inclure la suppression du flag :

```dart
Future<void> clearAll() async {
  await _secure.delete(key: _kAccessToken);
  await _secure.delete(key: _kRefreshToken);
  final prefs = await SharedPreferences.getInstance();
  await prefs.remove(_kUser);
  await prefs.remove(_kLastPhone);
  await prefs.remove(_kBiometric);
  await prefs.remove(_kKycSubmitted);
}
```

- [ ] **Step 4 : Lancer le test pour vérifier qu'il passe**

```bash
flutter test test/core/storage/storage_service_test.dart
```

Résultat attendu :
```
00:00 +3: All tests passed!
```

- [ ] **Step 5 : Commit**

```bash
git add lib/core/storage/storage_service.dart test/core/storage/storage_service_test.dart
git commit -m "feat: add kycSubmittedLocally flag to StorageService"
```

---

## Task 3 : Refonte de `KycScreen`

**Files:**
- Modify: `lib/features/auth/screens/kyc_screen.dart`

Trois changements dans ce fichier :
1. `_DocUploadTile` : affiche un thumbnail 56×56 quand un fichier est sélectionné + bouton "Modifier"
2. `_showPreviewDialog` : fonction de dialogue plein écran avec l'image + bouton "Remplacer"
3. `_KycStatusBanner` : widget dédié aux 4 états KYC
4. `_KycScreenState` : chargement du flag local, mise à jour à la soumission

- [ ] **Step 1 : Remplacer le contenu complet de `kyc_screen.dart`**

```dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:banabana_b2b/core/storage/storage_service.dart';
import 'package:banabana_b2b/core/theme/app_colors.dart';
import 'package:banabana_b2b/core/theme/app_spacing.dart';
import 'package:banabana_b2b/core/theme/app_text_styles.dart';
import 'package:banabana_b2b/features/auth/data/auth_repository.dart';
import 'package:banabana_b2b/features/auth/providers/auth_provider.dart';
import 'package:banabana_b2b/shared/widgets/app_snack_bar.dart';

class KycScreen extends ConsumerStatefulWidget {
  const KycScreen({super.key});

  @override
  ConsumerState<KycScreen> createState() => _KycScreenState();
}

class _KycScreenState extends ConsumerState<KycScreen> {
  XFile? _frontDoc;
  XFile? _backDoc;
  bool _loading = false;
  bool _submittedLocally = false;
  final _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _loadLocalFlag();
  }

  Future<void> _loadLocalFlag() async {
    final submitted = await ref.read(storageServiceProvider).getKycSubmittedLocally();
    if (mounted) setState(() => _submittedLocally = submitted);
  }

  Future<void> _pickImage(bool isFront) async {
    final file = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1920,
      imageQuality: 80,
    );
    if (file == null) return;
    final size = await file.length();
    if (size > 5 * 1024 * 1024) {
      if (mounted) context.showSnack('Image trop lourde (max 5 Mo)', type: SnackType.error);
      return;
    }
    setState(() => isFront ? _frontDoc = file : _backDoc = file);
  }

  Future<void> _submit() async {
    setState(() => _loading = true);
    try {
      await ref.read(authRepositoryProvider).submitKyc(
        frontPath: _frontDoc!.path,
        backPath: _backDoc!.path,
      );
      await ref.read(storageServiceProvider).setKycSubmittedLocally(true);
      await ref.read(authProvider.notifier).refreshProfile();
      if (mounted) {
        setState(() => _submittedLocally = true);
        context.showSnack(
          'Documents soumis. Vérification sous 24–48h.',
          type: SnackType.success,
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) context.showSnack(e.toString(), type: SnackType.error);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final kycStatus = ref.watch(authProvider).user?.kycStatus ?? 'pending';
    final alreadySubmitted = _submittedLocally && kycStatus == 'pending';

    return Scaffold(
      appBar: AppBar(title: const Text('Vérification d\'identité')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.s20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _KycStatusBanner(
                kycStatus: kycStatus,
                submittedLocally: _submittedLocally,
              ),
              const SizedBox(height: AppSpacing.s32),
              _DocUploadTile(
                label: 'CNI / Passeport — Recto',
                file: _frontDoc,
                onTap: () => _pickImage(true),
                onReplace: () => _pickImage(true),
              ),
              const SizedBox(height: AppSpacing.s16),
              _DocUploadTile(
                label: 'CNI / Passeport — Verso',
                file: _backDoc,
                onTap: () => _pickImage(false),
                onReplace: () => _pickImage(false),
              ),
              const SizedBox(height: AppSpacing.s32),
              FilledButton(
                onPressed: (_frontDoc != null && _backDoc != null && !_loading && !alreadySubmitted)
                    ? _submit
                    : null,
                child: _loading
                    ? const CircularProgressIndicator(color: AppColors.white)
                    : Text(alreadySubmitted ? 'Déjà soumis' : 'Soumettre les documents'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Bannière d'état KYC ────────────────────────────────────────────────────────

class _KycStatusBanner extends StatelessWidget {
  const _KycStatusBanner({
    required this.kycStatus,
    required this.submittedLocally,
  });

  final String kycStatus;
  final bool submittedLocally;

  @override
  Widget build(BuildContext context) {
    final (icon, message, color) = switch (kycStatus) {
      'rejected' => (
          Symbols.cancel,
          'Documents refusés — veuillez soumettre à nouveau.',
          AppColors.error,
        ),
      'approved' => (
          Symbols.verified,
          'Identité vérifiée.',
          AppColors.success,
        ),
      _ => submittedLocally
          ? (
              Symbols.schedule,
              'Documents en cours de vérification (24–48h).',
              AppColors.info,
            )
          : (
              Symbols.pending,
              'Votre compte est en attente. Soumettez vos documents.',
              AppColors.warning,
            ),
    };

    return Semantics(
      label: message,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.s16),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
          border: Border.all(color: color),
        ),
        child: Row(children: [
          Icon(icon, color: color),
          const SizedBox(width: AppSpacing.s12),
          Expanded(
            child: Text(
              message,
              style: AppTextStyles.body.copyWith(color: color),
            ),
          ),
        ]),
      ),
    );
  }
}

// ── Tuile d'upload document ────────────────────────────────────────────────────

class _DocUploadTile extends StatelessWidget {
  const _DocUploadTile({
    required this.label,
    required this.file,
    required this.onTap,
    this.onReplace,
  });

  final String label;
  final XFile? file;
  final VoidCallback onTap;
  final VoidCallback? onReplace;

  @override
  Widget build(BuildContext context) {
    if (file != null) {
      return Semantics(
        label: '$label, document chargé. Appuyer pour prévisualiser.',
        button: true,
        child: InkWell(
          onTap: () => _showPreviewDialog(context, file!, onReplace ?? onTap),
          borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
          child: Container(
            padding: const EdgeInsets.all(AppSpacing.s12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
              border: Border.all(color: AppColors.success, width: 2),
            ),
            child: Row(children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(AppSpacing.s6),
                child: Image.file(
                  File(file!.path),
                  width: 56,
                  height: 56,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(width: AppSpacing.s12),
              Expanded(child: Text(label, style: AppTextStyles.body)),
              GestureDetector(
                onTap: onReplace ?? onTap,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.s10,
                    vertical: AppSpacing.s6,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.gray100,
                    borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
                  ),
                  child: Text(
                    'Modifier',
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.gray700,
                    ),
                  ),
                ),
              ),
            ]),
          ),
        ),
      );
    }

    // État vide (aucun fichier sélectionné)
    return Semantics(
      label: '$label, appuyer pour choisir un document',
      button: true,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.s16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
            border: Border.all(color: AppColors.gray200),
          ),
          child: Row(children: [
            const Icon(Symbols.upload_file, color: AppColors.gray400),
            const SizedBox(width: AppSpacing.s12),
            Expanded(child: Text(label, style: AppTextStyles.body)),
          ]),
        ),
      ),
    );
  }
}

// ── Dialog de prévisualisation plein écran ────────────────────────────────────

Future<void> _showPreviewDialog(
  BuildContext context,
  XFile file,
  VoidCallback onReplace,
) {
  return showDialog<void>(
    context: context,
    builder: (ctx) => Dialog.fullscreen(
      backgroundColor: Colors.black,
      child: Stack(
        fit: StackFit.expand,
        children: [
          InteractiveViewer(
            child: Center(
              child: Image.file(File(file.path), fit: BoxFit.contain),
            ),
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.s16,
                  vertical: AppSpacing.s8,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      onPressed: () => Navigator.of(ctx).pop(),
                      icon: const Icon(Symbols.close, color: Colors.white),
                      tooltip: 'Fermer',
                    ),
                    FilledButton.tonal(
                      onPressed: () {
                        Navigator.of(ctx).pop();
                        onReplace();
                      },
                      child: const Text('Remplacer'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}
```

- [ ] **Step 2 : Vérifier que le code compile**

```bash
flutter analyze lib/features/auth/screens/kyc_screen.dart
```

Résultat attendu : `No issues found!`

- [ ] **Step 3 : Commit**

```bash
git add lib/features/auth/screens/kyc_screen.dart
git commit -m "feat: add document thumbnail, fullscreen preview, and differentiated KYC status banner"
```

---

## Task 4 : Mise à jour de `ProfileScreen`

**Files:**
- Modify: `lib/shared/screens/profile_screen.dart`

Trois changements : ajouter l'import `StorageService`, charger le flag local en `initState`, mettre à jour la couleur/label/tile KYC et le chemin de navigation.

- [ ] **Step 1 : Ajouter l'import `StorageService`**

En haut de `lib/shared/screens/profile_screen.dart`, après les imports existants, ajouter :

```dart
import 'package:banabana_b2b/core/storage/storage_service.dart';
```

- [ ] **Step 2 : Ajouter le champ `_submittedLocally` et la méthode `_loadKycFlag`**

Dans `_ProfileScreenState`, après `bool _saving = false;`, ajouter :

```dart
bool _submittedLocally = false;
```

Après la méthode `_cancelEdit()`, ajouter :

```dart
Future<void> _loadKycFlag() async {
  final submitted = await ref.read(storageServiceProvider).getKycSubmittedLocally();
  if (mounted) setState(() => _submittedLocally = submitted);
}
```

- [ ] **Step 3 : Appeler `_loadKycFlag()` dans `initState`**

Remplacer :
```dart
@override
void initState() {
  super.initState();
  final user = ref.read(authProvider).user;
  _emailCtrl.text = user?.email ?? '';
}
```

Par :
```dart
@override
void initState() {
  super.initState();
  final user = ref.read(authProvider).user;
  _emailCtrl.text = user?.email ?? '';
  _loadKycFlag();
}
```

- [ ] **Step 4 : Mettre à jour `kycColor` et `kycLabel` dans `build`**

Remplacer :
```dart
final kycColor = switch (user?.kycStatus) {
  'approved' => AppColors.success,
  'rejected' => AppColors.error,
  _ => AppColors.warning,
};
final kycLabel = switch (user?.kycStatus) {
  'approved' => 'Approuvé',
  'rejected' => 'Rejeté',
  _ => 'En attente',
};
```

Par :
```dart
final kycColor = switch (user?.kycStatus) {
  'approved' => AppColors.success,
  'rejected' => AppColors.error,
  _ => _submittedLocally ? AppColors.info : AppColors.warning,
};
final kycLabel = switch (user?.kycStatus) {
  'approved' => 'Approuvé',
  'rejected' => 'Rejeté',
  _ => _submittedLocally ? 'En cours de vérification' : 'En attente',
};
```

- [ ] **Step 5 : Mettre à jour le tile d'action KYC**

Remplacer le bloc entier (dans la section `// KYC action si non approuvé`) :

```dart
if (user?.kycStatus != 'approved') ...[
  const SizedBox(height: AppSpacing.s8),
  Container(
    decoration: BoxDecoration(
      color: kycColor.withValues(alpha: 0.08),
      borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
      border: Border.all(color: kycColor.withValues(alpha: 0.3)),
    ),
    child: ListTile(
      leading: Icon(Symbols.upload_file, color: kycColor),
      title: Text(
        user?.kycStatus == 'rejected'
            ? 'Documents refusés — soumettre à nouveau'
            : 'Vérification d\'identité en attente',
        style: AppTextStyles.label.copyWith(color: kycColor),
      ),
      trailing: Icon(Symbols.arrow_forward_ios, size: 14, color: kycColor),
      onTap: () => context.push('/auth/kyc'),
    ),
  ),
],
```

Par :

```dart
if (user?.kycStatus != 'approved') ...[
  const SizedBox(height: AppSpacing.s8),
  Container(
    decoration: BoxDecoration(
      color: kycColor.withValues(alpha: 0.08),
      borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
      border: Border.all(color: kycColor.withValues(alpha: 0.3)),
    ),
    child: ListTile(
      leading: Icon(
        _submittedLocally && user?.kycStatus == 'pending'
            ? Symbols.schedule
            : Symbols.upload_file,
        color: kycColor,
      ),
      title: Text(
        switch ((user?.kycStatus, _submittedLocally)) {
          ('rejected', _) => 'Documents refusés — soumettre à nouveau',
          (_, true)       => 'Documents en cours de vérification',
          _               => 'Vérification d\'identité en attente',
        },
        style: AppTextStyles.label.copyWith(color: kycColor),
      ),
      trailing: _submittedLocally && user?.kycStatus == 'pending'
          ? null
          : Icon(Symbols.arrow_forward_ios, size: 14, color: kycColor),
      onTap: _submittedLocally && user?.kycStatus == 'pending'
          ? null
          : () => context.push('/kyc'),
    ),
  ),
],
```

- [ ] **Step 6 : Vérifier que le code compile**

```bash
flutter analyze lib/shared/screens/profile_screen.dart
```

Résultat attendu : `No issues found!`

- [ ] **Step 7 : Vérifier l'ensemble du projet**

```bash
flutter analyze
```

Résultat attendu : `No issues found!`

- [ ] **Step 8 : Commit final**

```bash
git add lib/shared/screens/profile_screen.dart
git commit -m "feat: differentiate KYC states in ProfileScreen and fix /kyc navigation path"
```

---

## Self-review

**Spec coverage :**
- ✅ Fix routing `/auth/kyc` → `/kyc` — Task 1
- ✅ Thumbnail 56×56 dans `_DocUploadTile` — Task 3
- ✅ Modal plein écran `_showPreviewDialog` — Task 3
- ✅ Bouton "Modifier" dans la tuile — Task 3
- ✅ 4 états KYC dans `KycScreen` (`_KycStatusBanner`) — Task 3
- ✅ Flag `kycSubmittedLocally` dans `StorageService` + `clearAll()` — Task 2
- ✅ Posé à `true` au `_submit()` réussi — Task 3
- ✅ 4 états KYC dans `ProfileScreen` — Task 4
- ✅ Tile non-tappable si en cours de vérification — Task 4

**Placeholder scan :** aucun TBD, aucun "implement later", tous les steps ont du code complet.

**Type consistency :**
- `getKycSubmittedLocally()` → `Future<bool>` définie en Task 2, utilisée en Task 3 et 4 ✅
- `setKycSubmittedLocally(bool)` → définie en Task 2, appelée en Task 3 ✅
- `storageServiceProvider` → déjà existant dans `storage_service.dart` ✅
- `AppColors.info` → `Color(0xFF3B82F6)` définie dans `app_colors.dart` ✅
- `AppSpacing.s6`, `s10`, `s12`, `s16`, `s20`, `s32` → tous définis dans `app_spacing.dart` ✅
