import 'package:flutter/material.dart';
import 'package:banabana_b2b/core/theme/app_colors.dart';

abstract final class AppTextStyles {
  static const _base = TextStyle(fontFamily: null); // police système

  static final screenTitle = _base.copyWith(
    fontSize: 22, fontWeight: FontWeight.w700, height: 1.3,
    color: AppColors.gray900,
  );
  static final sectionTitle = _base.copyWith(
    fontSize: 18, fontWeight: FontWeight.w600, height: 1.4,
    color: AppColors.gray900,
  );
  static final body = _base.copyWith(
    fontSize: 15, fontWeight: FontWeight.w400, height: 1.6,
    color: AppColors.gray900,
  );
  static final bodySecondary = _base.copyWith(
    fontSize: 13, fontWeight: FontWeight.w400, height: 1.5,
    color: AppColors.gray500,
  );
  static final label = _base.copyWith(
    fontSize: 13, fontWeight: FontWeight.w500, height: 1.4,
    color: AppColors.gray700,
  );
  static final caption = _base.copyWith(
    fontSize: 11, fontWeight: FontWeight.w400, height: 1.4,
    color: AppColors.gray400,
  );
  static final button = _base.copyWith(
    fontSize: 15, fontWeight: FontWeight.w600, height: 1.0,
    color: AppColors.white,
  );
  static final badge = _base.copyWith(
    fontSize: 10, fontWeight: FontWeight.w700, height: 1.0,
    color: AppColors.white,
  );
}
