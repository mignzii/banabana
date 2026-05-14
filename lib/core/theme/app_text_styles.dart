import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:banabana_b2b/core/theme/app_colors.dart';

abstract final class AppTextStyles {
  static TextStyle get display => GoogleFonts.inter(
    fontSize: 28, fontWeight: FontWeight.w800, height: 1.2,
    color: AppColors.gray900,
  );
  static TextStyle get screenTitle => GoogleFonts.inter(
    fontSize: 22, fontWeight: FontWeight.w700, height: 1.3,
    color: AppColors.gray900,
  );
  static TextStyle get sectionTitle => GoogleFonts.inter(
    fontSize: 18, fontWeight: FontWeight.w600, height: 1.4,
    color: AppColors.gray900,
  );
  static TextStyle get body => GoogleFonts.inter(
    fontSize: 15, fontWeight: FontWeight.w400, height: 1.6,
    color: AppColors.gray900,
  );
  static TextStyle get bodySecondary => GoogleFonts.inter(
    fontSize: 13, fontWeight: FontWeight.w400, height: 1.5,
    color: AppColors.gray500,
  );
  static TextStyle get label => GoogleFonts.inter(
    fontSize: 13, fontWeight: FontWeight.w500, height: 1.4,
    color: AppColors.gray700,
  );
  static TextStyle get caption => GoogleFonts.inter(
    fontSize: 11, fontWeight: FontWeight.w400, height: 1.4,
    color: AppColors.gray400,
  );
  static TextStyle get button => GoogleFonts.inter(
    fontSize: 15, fontWeight: FontWeight.w600, height: 1.0,
    color: AppColors.white,
  );
  static TextStyle get badge => GoogleFonts.inter(
    fontSize: 10, fontWeight: FontWeight.w700, height: 1.0,
    color: AppColors.white,
  );
  static TextStyle get price => GoogleFonts.inter(
    fontSize: 16, fontWeight: FontWeight.w800, height: 1.0,
    color: AppColors.primary,
  );
}
