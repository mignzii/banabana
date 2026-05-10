import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:banabana_b2b/core/theme/app_colors.dart';
import 'package:banabana_b2b/core/theme/app_text_styles.dart';

class EmptyStateWidget extends StatelessWidget {
  const EmptyStateWidget({
    super.key,
    required this.title,
    required this.subtitle,
    this.icon = Symbols.inbox,
    this.ctaLabel,
    this.onCta,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final String? ctaLabel;
  final VoidCallback? onCta;

  @override
  Widget build(BuildContext context) => Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 64, color: AppColors.gray300),
              const SizedBox(height: 20),
              Text(title,
                  style: AppTextStyles.sectionTitle,
                  textAlign: TextAlign.center),
              const SizedBox(height: 8),
              Text(subtitle,
                  style: AppTextStyles.bodySecondary,
                  textAlign: TextAlign.center),
              if (ctaLabel != null) ...[
                const SizedBox(height: 24),
                FilledButton(onPressed: onCta, child: Text(ctaLabel!)),
              ],
            ],
          ),
        ),
      );
}
