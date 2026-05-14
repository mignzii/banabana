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
              InkWell(
                onTap: onReplace ?? onTap,
                borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
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
