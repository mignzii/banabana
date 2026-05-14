import 'package:flutter/material.dart';
import 'package:banabana_b2b/core/theme/app_colors.dart';
import 'package:banabana_b2b/core/theme/app_spacing.dart';
import 'package:banabana_b2b/core/theme/app_text_styles.dart';

enum AppButtonVariant { filled, outlined, text, danger }

class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.variant = AppButtonVariant.filled,
    this.isLoading = false,
    this.leadingIcon,
    this.expand = true,
  });

  final String label;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final bool isLoading;
  final IconData? leadingIcon;
  final bool expand;

  Color _foregroundColor() => switch (variant) {
    AppButtonVariant.outlined => AppColors.primary,
    AppButtonVariant.text => AppColors.primary,
    _ => AppColors.white,
  };

  @override
  Widget build(BuildContext context) {
    final isDisabled = onPressed == null && !isLoading;
    final fgColor = _foregroundColor();

    Widget content = Row(
      mainAxisSize: expand ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (isLoading)
          SizedBox(
            width: 18, height: 18,
            child: CircularProgressIndicator(strokeWidth: 2, color: fgColor),
          )
        else ...[
          if (leadingIcon != null) ...[
            Icon(leadingIcon, size: 18, color: fgColor),
            const SizedBox(width: AppSpacing.s8),
          ],
          Text(label, style: AppTextStyles.button.copyWith(color: fgColor)),
        ],
      ],
    );

    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
    );
    final minSize = expand
        ? const Size(double.infinity, AppSpacing.touchTarget + 4)
        : const Size(0, AppSpacing.touchTarget + 4);

    return Opacity(
      opacity: isDisabled ? 0.4 : 1.0,
      child: switch (variant) {
        AppButtonVariant.filled => FilledButton(
          onPressed: isLoading ? null : onPressed,
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.primary,
            disabledBackgroundColor: AppColors.primary,
            disabledForegroundColor: AppColors.white,
            minimumSize: minSize,
            shape: shape,
          ),
          child: content,
        ),
        AppButtonVariant.outlined => OutlinedButton(
          onPressed: isLoading ? null : onPressed,
          style: OutlinedButton.styleFrom(
            side: const BorderSide(color: AppColors.primary, width: 1.5),
            disabledForegroundColor: AppColors.primary,
            minimumSize: minSize,
            shape: shape,
          ),
          child: content,
        ),
        AppButtonVariant.text => TextButton(
          onPressed: isLoading ? null : onPressed,
          style: TextButton.styleFrom(
            foregroundColor: AppColors.primary,
            disabledForegroundColor: AppColors.primary,
            minimumSize: minSize,
            shape: shape,
          ),
          child: content,
        ),
        AppButtonVariant.danger => FilledButton(
          onPressed: isLoading ? null : onPressed,
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.error,
            disabledBackgroundColor: AppColors.error,
            disabledForegroundColor: AppColors.white,
            minimumSize: minSize,
            shape: shape,
          ),
          child: content,
        ),
      },
    );
  }
}
