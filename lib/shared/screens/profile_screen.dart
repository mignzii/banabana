import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:banabana_b2b/core/theme/app_colors.dart';
import 'package:banabana_b2b/core/theme/app_text_styles.dart';
import 'package:banabana_b2b/features/auth/providers/auth_provider.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider).user;

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

    return Scaffold(
      backgroundColor: AppColors.gray50,
      appBar: AppBar(
        title: const Text('Mon profil'),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Avatar + Name + Role
          Center(
            child: Column(
              children: [
                CircleAvatar(
                  radius: 44,
                  backgroundColor: AppColors.primary,
                  child: initials != null
                      ? Text(
                          initials,
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: AppColors.white,
                          ),
                        )
                      : const Icon(Symbols.person, size: 40, color: AppColors.white),
                ),
                const SizedBox(height: 12),
                Text(displayName, style: AppTextStyles.screenTitle),
                const SizedBox(height: 4),
                Text(user?.phone ?? '-', style: AppTextStyles.bodySecondary),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    roleBadgeLabel,
                    style: AppTextStyles.label.copyWith(color: AppColors.primary),
                  ),
                ),
                if (user?.businessName?.isNotEmpty == true) ...[
                  const SizedBox(height: 4),
                  Text(
                    user!.businessName!,
                    style: AppTextStyles.bodySecondary,
                  ),
                ],
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Informations card
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            elevation: 1,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Informations', style: AppTextStyles.sectionTitle),
                  const Divider(height: 24),
                  _InfoRow(
                    icon: Symbols.phone,
                    label: 'Téléphone',
                    value: user?.phone ?? '-',
                  ),
                  const SizedBox(height: 12),
                  _InfoRow(
                    icon: Symbols.email,
                    label: 'Email',
                    value: user?.email?.isNotEmpty == true
                        ? user!.email!
                        : 'Non renseigné',
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Icon(Symbols.verified_user, size: 20, color: AppColors.gray500),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Statut KYC', style: AppTextStyles.label),
                            const SizedBox(height: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 3),
                              decoration: BoxDecoration(
                                color: kycColor.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                kycLabel,
                                style: AppTextStyles.caption.copyWith(
                                    color: kycColor,
                                    fontWeight: FontWeight.w600),
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
          ),

          // KYC action si non approuvé
          if (user?.kycStatus != 'approved') ...[
            const SizedBox(height: 12),
            ListTile(
              tileColor: kycColor.withValues(alpha: 0.08),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: kycColor.withValues(alpha: 0.3)),
              ),
              leading: Icon(Symbols.upload_file, color: kycColor),
              title: Text(
                user?.kycStatus == 'rejected'
                    ? 'Documents refusés — soumettre à nouveau'
                    : 'Vérification d\'identité en attente',
                style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: kycColor),
              ),
              trailing: Icon(Icons.arrow_forward_ios,
                  size: 14, color: kycColor),
              onTap: () => context.push('/auth/kyc'),
            ),
          ],

          const SizedBox(height: 24),

          // Logout button
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => _confirmLogout(context, ref),
              icon: const Icon(Symbols.logout, color: AppColors.error),
              label: const Text(
                'Déconnexion',
                style: TextStyle(color: AppColors.error),
              ),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppColors.error),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
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
            child: const Text(
              'Déconnexion',
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 20, color: AppColors.gray500),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: AppTextStyles.label),
              const SizedBox(height: 2),
              Text(value, style: AppTextStyles.body),
            ],
          ),
        ),
      ],
    );
  }
}
