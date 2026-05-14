import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:banabana_b2b/core/theme/app_colors.dart';
import 'package:banabana_b2b/core/theme/app_spacing.dart';
import 'package:banabana_b2b/core/theme/app_text_styles.dart';
import 'package:banabana_b2b/features/auth/providers/auth_provider.dart';
import 'package:banabana_b2b/features/auth/providers/theme_provider.dart';
import 'package:banabana_b2b/shared/widgets/app_snack_bar.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  final _emailCtrl = TextEditingController();
  bool _isEditing = false;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final user = ref.read(authProvider).user;
    _emailCtrl.text = user?.email ?? '';
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    setState(() => _saving = true);
    try {
      await ref.read(authProvider.notifier).updateProfile(
            email: _emailCtrl.text.trim(),
          );
      if (mounted) {
        setState(() => _isEditing = false);
        context.showSnack('Profil mis à jour', type: SnackType.success);
      }
    } catch (e) {
      if (mounted) context.showSnack(e.toString(), type: SnackType.error);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  void _cancelEdit() {
    final user = ref.read(authProvider).user;
    _emailCtrl.text = user?.email ?? '';
    setState(() => _isEditing = false);
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authProvider).user;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isDarkMode = ref.watch(themeModeProvider) == ThemeMode.dark;

    final firstName = user?.firstName ?? '';
    final lastName = user?.lastName ?? '';
    final fullName = '$firstName $lastName'.trim();
    final displayName = fullName.isNotEmpty ? fullName : user?.phone ?? '-';
    final initials = firstName.isNotEmpty
        ? '${firstName[0]}${lastName.isNotEmpty ? lastName[0] : ''}'.toUpperCase()
        : null;

    final roleBadgeLabel = switch (user?.role) {
      'producer' => 'Producteur',
      'wholesaler' => 'Grossiste',
      'vendor' => 'Vendeur',
      _ => user?.role ?? '-',
    };

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

    final bg = isDark ? AppColors.darkBg : AppColors.gray50;
    final surface = isDark ? AppColors.darkSurface : AppColors.white;
    final border = isDark ? AppColors.darkBorder : AppColors.gray100;
    final textPrimary = isDark ? AppColors.gray100 : AppColors.gray900;
    final textSecondary = isDark ? AppColors.gray500 : AppColors.gray400;

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: isDark ? AppColors.darkBg : AppColors.white,
        elevation: 0,
        title: Text(
          'Mon profil',
          style: AppTextStyles.sectionTitle.copyWith(color: textPrimary),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Divider(height: 1, color: border),
        ),
        actions: _isEditing
            ? [
                TextButton(
                  onPressed: _saving ? null : _cancelEdit,
                  child: Text(
                    'Annuler',
                    style: AppTextStyles.label.copyWith(
                      color: isDark ? AppColors.gray400 : AppColors.gray500,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(right: AppSpacing.s8),
                  child: FilledButton(
                    onPressed: _saving ? null : _saveProfile,
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s16),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: _saving
                        ? const SizedBox(
                            width: 14,
                            height: 14,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppColors.white,
                            ),
                          )
                        : Text('Enregistrer', style: AppTextStyles.label.copyWith(color: AppColors.white)),
                  ),
                ),
              ]
            : [
                IconButton(
                  icon: const Icon(Symbols.edit, size: 20),
                  color: isDark ? AppColors.gray300 : AppColors.gray600,
                  onPressed: () => setState(() => _isEditing = true),
                  tooltip: 'Modifier',
                ),
              ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.screenPadding),
        children: [
          const SizedBox(height: AppSpacing.s8),

          // Avatar + Name + Role
          Container(
            padding: const EdgeInsets.all(AppSpacing.s24),
            decoration: BoxDecoration(
              color: surface,
              borderRadius: BorderRadius.circular(AppSpacing.radiusLarge),
              border: Border.all(color: border),
            ),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 44,
                  backgroundColor: AppColors.primary.withValues(alpha: 0.15),
                  child: initials != null
                      ? Text(
                          initials,
                          style: AppTextStyles.display.copyWith(
                            color: AppColors.primary,
                          ),
                        )
                      : const Icon(Symbols.person, size: 40, color: AppColors.primary),
                ),
                const SizedBox(height: AppSpacing.s12),
                Text(
                  displayName,
                  style: AppTextStyles.screenTitle.copyWith(color: textPrimary),
                ),
                const SizedBox(height: AppSpacing.s4),
                Text(
                  user?.phone ?? '-',
                  style: AppTextStyles.bodySecondary.copyWith(color: textSecondary),
                ),
                const SizedBox(height: AppSpacing.s8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.s12,
                    vertical: AppSpacing.s4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
                  ),
                  child: Text(
                    roleBadgeLabel,
                    style: AppTextStyles.label.copyWith(color: AppColors.primary),
                  ),
                ),
                if (user?.businessName?.isNotEmpty == true) ...[
                  const SizedBox(height: AppSpacing.s4),
                  Text(
                    user!.businessName!,
                    style: AppTextStyles.bodySecondary.copyWith(color: textSecondary),
                  ),
                ],
              ],
            ),
          ),

          const SizedBox(height: AppSpacing.s16),

          // Informations
          _SectionCard(
            isDark: isDark,
            surface: surface,
            border: border,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Informations',
                  style: AppTextStyles.label.copyWith(
                    color: textSecondary,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: AppSpacing.s16),
                _InfoRow(
                  icon: Symbols.phone,
                  label: 'Téléphone',
                  value: user?.phone ?? '-',
                  isDark: isDark,
                ),
                Divider(height: AppSpacing.s24, color: border),
                // Email — editable in edit mode
                if (_isEditing) ...[
                  Row(
                    children: [
                      Icon(Symbols.email, size: 20, color: textSecondary),
                      const SizedBox(width: AppSpacing.s12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Email',
                              style: AppTextStyles.caption.copyWith(color: textSecondary),
                            ),
                            const SizedBox(height: AppSpacing.s6),
                            TextFormField(
                              controller: _emailCtrl,
                              keyboardType: TextInputType.emailAddress,
                              autocorrect: false,
                              style: AppTextStyles.body.copyWith(color: textPrimary),
                              decoration: InputDecoration(
                                hintText: 'votre@email.com',
                                hintStyle: AppTextStyles.bodySecondary.copyWith(
                                  color: isDark ? AppColors.gray600 : AppColors.gray400,
                                ),
                                filled: true,
                                fillColor: isDark ? AppColors.darkSurface2 : AppColors.gray50,
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: AppSpacing.s14,
                                  vertical: AppSpacing.s10,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
                                  borderSide: BorderSide(color: isDark ? AppColors.darkBorder : AppColors.gray200),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
                                  borderSide: BorderSide(color: isDark ? AppColors.darkBorder : AppColors.gray200),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
                                  borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
                                ),
                                isDense: true,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ] else ...[
                  _InfoRow(
                    icon: Symbols.email,
                    label: 'Email',
                    value: user?.email?.isNotEmpty == true ? user!.email! : 'Non renseigné',
                    isDark: isDark,
                  ),
                ],
                Divider(height: AppSpacing.s24, color: border),
                Row(
                  children: [
                    Icon(Symbols.verified_user, size: 20, color: textSecondary),
                    const SizedBox(width: AppSpacing.s12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Statut KYC',
                            style: AppTextStyles.caption.copyWith(color: textSecondary),
                          ),
                          const SizedBox(height: AppSpacing.s4),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: kycColor.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
                            ),
                            child: Text(
                              kycLabel,
                              style: AppTextStyles.caption.copyWith(
                                color: kycColor,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // KYC action si non approuvé
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

          const SizedBox(height: AppSpacing.s16),

          // Préférences
          _SectionCard(
            isDark: isDark,
            surface: surface,
            border: border,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Préférences',
                  style: AppTextStyles.label.copyWith(
                    color: textSecondary,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: AppSpacing.s8),
                Row(
                  children: [
                    Icon(
                      isDarkMode ? Symbols.dark_mode : Symbols.light_mode,
                      size: 20,
                      color: textSecondary,
                    ),
                    const SizedBox(width: AppSpacing.s12),
                    Expanded(
                      child: Text(
                        'Mode sombre',
                        style: AppTextStyles.body.copyWith(color: textPrimary),
                      ),
                    ),
                    Switch(
                      value: isDarkMode,
                      onChanged: (_) => ref.read(themeModeProvider.notifier).toggle(),
                      activeThumbColor: AppColors.primary,
                      activeTrackColor: AppColors.primary.withValues(alpha: 0.4),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: AppSpacing.s16),

          // Déconnexion
          OutlinedButton.icon(
            onPressed: _isEditing ? null : () => _confirmLogout(context, ref),
            icon: const Icon(Symbols.logout, color: AppColors.error),
            label: const Text('Déconnexion'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.error,
              side: const BorderSide(color: AppColors.error),
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.s16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
              ),
            ),
          ),

          const SizedBox(height: AppSpacing.s24),
        ],
      ),
    );
  }

  void _confirmLogout(BuildContext context, WidgetRef ref) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Déconnexion'),
        content: const Text('Êtes-vous sûr de vouloir vous déconnecter ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(ctx).pop();
              await ref.read(authProvider.notifier).logout();
              if (context.mounted) context.go('/auth/login');
            },
            child: Text(
              'Déconnexion',
              style: AppTextStyles.body.copyWith(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.isDark,
    required this.surface,
    required this.border,
    required this.child,
  });

  final bool isDark;
  final Color surface;
  final Color border;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.s16),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLarge),
        border: Border.all(color: border),
      ),
      child: child,
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.isDark,
  });

  final IconData icon;
  final String label;
  final String value;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final textSecondary = isDark ? AppColors.gray500 : AppColors.gray400;
    final textPrimary = isDark ? AppColors.gray100 : AppColors.gray900;

    return Row(
      children: [
        Icon(icon, size: 20, color: textSecondary),
        const SizedBox(width: AppSpacing.s12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: AppTextStyles.caption.copyWith(color: textSecondary)),
              const SizedBox(height: 2),
              Text(value, style: AppTextStyles.body.copyWith(color: textPrimary)),
            ],
          ),
        ),
      ],
    );
  }
}
