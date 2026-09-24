import 'package:flutter/material.dart';
import 'package:banabana_b2b/core/theme/app_colors.dart';
import 'package:banabana_b2b/core/theme/app_text_styles.dart';

abstract final class AppInputDecoration {
  static InputDecoration standard({
    required String label,
    String? hint,
    Widget? prefixIcon,
    Widget? suffixIcon,
    bool isDark = false,
  }) {
    final borderColor = isDark ? AppColors.darkBorder : AppColors.gray200;
    return InputDecoration(
      labelText: label,
      hintText: hint,
      hintStyle: AppTextStyles.bodySecondary.copyWith(
        color: isDark ? AppColors.gray500 : AppColors.gray400,
      ),
      labelStyle: AppTextStyles.label.copyWith(
        color: isDark ? AppColors.gray300 : AppColors.gray700,
      ),
      prefixIcon: prefixIcon,
      suffixIcon: suffixIcon,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: borderColor),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: borderColor),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.primary, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.error),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.error, width: 2),
      ),
      errorStyle: AppTextStyles.caption.copyWith(color: AppColors.error),
      filled: true,
      fillColor: isDark ? AppColors.darkSurface2 : AppColors.gray50,
    );
  }
}
