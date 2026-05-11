import 'package:flutter/material.dart';
import 'package:banabana_b2b/core/theme/app_colors.dart';
import 'package:banabana_b2b/core/theme/app_spacing.dart';

// Widget de base shimmer — animation opacity
class ShimmerBox extends StatefulWidget {
  const ShimmerBox({
    super.key,
    this.width,
    this.height = 16,
    this.borderRadius = AppSpacing.radiusSmall,
  });
  final double? width;
  final double height;
  final double borderRadius;

  @override
  State<ShimmerBox> createState() => _ShimmerBoxState();
}

class _ShimmerBoxState extends State<ShimmerBox>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);
    _anim = Tween<double>(begin: 0.25, end: 0.6).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final baseColor = isDark ? AppColors.darkSurface2 : AppColors.gray200;

    return AnimatedBuilder(
      animation: _anim,
      builder: (_, __) => Container(
        width: widget.width,
        height: widget.height,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(widget.borderRadius),
          color: baseColor.withValues(alpha: _anim.value + 0.3),
        ),
      ),
    );
  }
}

// Shimmer pour ProductCard (1:1 image + infos)
class ProductCardShimmer extends StatelessWidget {
  const ProductCardShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.white,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLarge),
        border: isDark ? Border.all(color: AppColors.darkBorder) : null,
        boxShadow: isDark
            ? null
            : [
                BoxShadow(
                  color: AppColors.black.withValues(alpha: 0.05),
                  blurRadius: 6,
                ),
              ],
      ),
      child: Column(
        children: [
          // Image placeholder 1:1
          AspectRatio(
            aspectRatio: 1,
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(AppSpacing.radiusLarge),
              ),
              child: ShimmerBox(
                height: double.infinity,
                borderRadius: 0,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(AppSpacing.s12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ShimmerBox(height: 12, borderRadius: AppSpacing.s4),
                const SizedBox(height: AppSpacing.s8),
                ShimmerBox(width: 80, height: 10, borderRadius: AppSpacing.s4),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Shimmer pour StatCard
class StatCardShimmer extends StatelessWidget {
  const StatCardShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.s16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.white,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLarge),
        border: isDark ? Border.all(color: AppColors.darkBorder) : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ShimmerBox(width: 36, height: 36, borderRadius: AppSpacing.radiusMedium),
          const SizedBox(height: AppSpacing.s12),
          ShimmerBox(width: 60, height: 22, borderRadius: AppSpacing.s4),
          const SizedBox(height: AppSpacing.s8),
          ShimmerBox(width: 80, height: 10, borderRadius: AppSpacing.s4),
        ],
      ),
    );
  }
}

// Shimmer pour OrderCard
class OrderCardShimmer extends StatelessWidget {
  const OrderCardShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: AppSpacing.s16,
        vertical: AppSpacing.s8,
      ),
      padding: const EdgeInsets.all(AppSpacing.s16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.white,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLarge),
        border: isDark ? Border.all(color: AppColors.darkBorder) : null,
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ShimmerBox(width: 120, height: 12, borderRadius: AppSpacing.s4),
                const SizedBox(height: AppSpacing.s8),
                ShimmerBox(width: 80, height: 10, borderRadius: AppSpacing.s4),
              ],
            ),
          ),
          ShimmerBox(width: 64, height: 24, borderRadius: AppSpacing.radiusPill),
        ],
      ),
    );
  }
}

// Ancien CardShimmer gardé pour compatibilité
class CardShimmer extends StatelessWidget {
  const CardShimmer({super.key});

  @override
  Widget build(BuildContext context) => const ProductCardShimmer();
}
