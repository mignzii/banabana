import 'package:flutter/material.dart';
import 'package:banabana_b2b/core/theme/app_colors.dart';
import 'package:banabana_b2b/core/theme/app_text_styles.dart';

enum SnackType { success, error, warning, info }

extension AppSnackBar on BuildContext {
  void showSnack(
    String message, {
    SnackType type = SnackType.info,
    String? actionLabel,
    VoidCallback? onAction,
    Duration duration = const Duration(seconds: 3),
  }) {
    final (color, icon) = switch (type) {
      SnackType.success => (AppColors.success, Icons.check_circle_outline),
      SnackType.error   => (AppColors.error, Icons.error_outline),
      SnackType.warning => (AppColors.warning, Icons.warning_amber_outlined),
      SnackType.info    => (AppColors.primary, Icons.info_outline),
    };

    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        duration: type == SnackType.error
            ? const Duration(seconds: 5)
            : duration,
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 80),
        content: Row(children: [
          Icon(icon, color: AppColors.white, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(message,
                style: AppTextStyles.body.copyWith(color: AppColors.white)),
          ),
        ]),
        action: actionLabel != null
            ? SnackBarAction(
                label: actionLabel,
                textColor: AppColors.white,
                onPressed: onAction ?? () {},
              )
            : null,
      ),
    );
  }
}
