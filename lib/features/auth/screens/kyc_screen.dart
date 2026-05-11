import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:banabana_b2b/core/theme/app_colors.dart';
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
  final _picker = ImagePicker();

  Future<void> _submit() async {
    setState(() => _loading = true);
    try {
      final repo = ref.read(authRepositoryProvider);
      await repo.submitKyc(
        frontPath: _frontDoc!.path,
        backPath: _backDoc!.path,
      );
      await ref.read(authProvider.notifier).refreshProfile();
      if (mounted) {
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

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Vérification d\'identité')),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Semantics(
                  label: 'Statut KYC en attente de vérification',
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.warning.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.warning),
                    ),
                    child: Row(children: [
                      const Icon(Symbols.pending, color: AppColors.warning),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Votre compte est en attente de vérification. Soumettez vos documents.',
                          style: AppTextStyles.body.copyWith(color: AppColors.warning),
                        ),
                      ),
                    ]),
                  ),
                ),
                const SizedBox(height: 32),
                _DocUploadTile(
                  label: 'CNI / Passeport — Recto',
                  file: _frontDoc,
                  onTap: () => _pickImage(true),
                ),
                const SizedBox(height: 16),
                _DocUploadTile(
                  label: 'CNI / Passeport — Verso',
                  file: _backDoc,
                  onTap: () => _pickImage(false),
                ),
                const SizedBox(height: 32),
                FilledButton(
                  onPressed: (_frontDoc != null && _backDoc != null && !_loading)
                      ? _submit
                      : null,
                  child: _loading
                      ? const CircularProgressIndicator(color: AppColors.white)
                      : const Text('Soumettre les documents'),
                ),
              ],
            ),
          ),
        ),
      );
}

class _DocUploadTile extends StatelessWidget {
  const _DocUploadTile({required this.label, required this.file, required this.onTap});
  final String label;
  final XFile? file;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Semantics(
        label: '$label, ${file != null ? "document chargé" : "appuyer pour choisir"}',
        button: true,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: file != null ? AppColors.success : AppColors.gray200,
                width: file != null ? 2 : 1,
              ),
            ),
            child: Row(children: [
              Icon(
                file != null ? Symbols.check_circle : Symbols.upload_file,
                color: file != null ? AppColors.success : AppColors.gray400,
              ),
              const SizedBox(width: 12),
              Expanded(child: Text(label, style: AppTextStyles.body)),
              if (file != null)
                Text('✓', style: AppTextStyles.label.copyWith(color: AppColors.success)),
            ]),
          ),
        ),
      );
}
