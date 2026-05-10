import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:banabana_b2b/core/theme/app_colors.dart';
import 'package:banabana_b2b/core/theme/app_text_styles.dart';

class ErrorStateWidget extends StatelessWidget {
  const ErrorStateWidget({
    super.key,
    required this.message,
    required this.onRetry,
  });

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) => Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Symbols.wifi_off, size: 56, color: AppColors.error),
              const SizedBox(height: 20),
              Text('Impossible de charger les données',
                  style: AppTextStyles.sectionTitle,
                  textAlign: TextAlign.center),
              const SizedBox(height: 8),
              Text(message,
                  style: AppTextStyles.bodySecondary,
                  textAlign: TextAlign.center),
              const SizedBox(height: 24),
              OutlinedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Symbols.refresh),
                label: const Text('Réessayer'),
              ),
            ],
          ),
        ),
      );
}
