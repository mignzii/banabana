import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:banabana_b2b/core/api/api_client.dart';
import 'package:banabana_b2b/core/theme/app_colors.dart';
import 'package:banabana_b2b/core/theme/app_spacing.dart';
import 'package:banabana_b2b/core/theme/app_text_styles.dart';
import 'package:banabana_b2b/shared/models/product.dart';
import 'package:banabana_b2b/shared/widgets/loading_shimmer.dart';

class ProductCard extends StatelessWidget {
  const ProductCard({
    super.key,
    required this.product,
    this.onTap,
    this.onEdit,
  });

  final Product product;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final imageUrl = product.images.isNotEmpty
        ? resolveImageUrl(product.images.first.url)
        : null;
    final isInactive = !product.isActive;

    return Opacity(
      opacity: isInactive ? 0.55 : 1.0,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppSpacing.radiusLarge),
          splashColor: AppColors.primary.withValues(alpha: 0.08),
          highlightColor: AppColors.primary.withValues(alpha: 0.04),
          child: Ink(
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkSurface : AppColors.white,
              borderRadius: BorderRadius.circular(AppSpacing.radiusLarge),
              border: isDark
                  ? Border.all(color: AppColors.darkBorder)
                  : null,
              boxShadow: isDark
                  ? null
                  : [
                      BoxShadow(
                        color: AppColors.black.withValues(alpha: 0.06),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Image 1:1
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(AppSpacing.radiusLarge),
                  ),
                  child: AspectRatio(
                    aspectRatio: 1,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        if (imageUrl != null)
                          CachedNetworkImage(
                            imageUrl: imageUrl,
                            fit: BoxFit.cover,
                            placeholder: (_, __) => const ProductCardShimmer(),
                            errorWidget: (_, __, ___) => _ImagePlaceholder(isDark: isDark),
                          )
                        else
                          _ImagePlaceholder(isDark: isDark),
                        // Badge statut
                        Positioned(
                          top: AppSpacing.s8,
                          right: AppSpacing.s8,
                          child: _StatusBadge(isActive: product.isActive),
                        ),
                      ],
                    ),
                  ),
                ),
                // Infos
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.s12, AppSpacing.s8,
                    AppSpacing.s12, AppSpacing.s8,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product.title,
                        style: AppTextStyles.label.copyWith(
                          color: isDark ? AppColors.gray100 : AppColors.gray900,
                          fontWeight: FontWeight.w700,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: AppSpacing.s4),
                      Row(
                        children: [
                          Expanded(
                            child: RichText(
                              text: TextSpan(
                                children: [
                                  TextSpan(
                                    text: product.basePrice.toStringAsFixed(0),
                                    style: AppTextStyles.price.copyWith(
                                      fontSize: 14,
                                    ),
                                  ),
                                  TextSpan(
                                    text: ' F',
                                    style: AppTextStyles.caption.copyWith(
                                      color: isDark ? AppColors.gray500 : AppColors.gray400,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          if (onEdit != null)
                            GestureDetector(
                              onTap: onEdit,
                              child: Container(
                                width: 28,
                                height: 28,
                                decoration: BoxDecoration(
                                  color: isDark
                                      ? AppColors.darkSurface2
                                      : AppColors.gray100,
                                  borderRadius: BorderRadius.circular(AppSpacing.radiusSmall),
                                ),
                                child: Icon(
                                  Symbols.edit,
                                  size: 14,
                                  color: isDark ? AppColors.gray400 : AppColors.gray500,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ImagePlaceholder extends StatelessWidget {
  const _ImagePlaceholder({required this.isDark});
  final bool isDark;

  @override
  Widget build(BuildContext context) => Container(
    color: isDark ? AppColors.darkSurface2 : AppColors.gray100,
    child: Icon(
      Symbols.image,
      color: isDark ? AppColors.gray700 : AppColors.gray300,
      size: 40,
    ),
  );
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.isActive});
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    final (bgColor, textColor, label) = isActive
        ? (AppColors.success.withValues(alpha: 0.15), AppColors.success, 'Actif')
        : (AppColors.gray500.withValues(alpha: 0.15), AppColors.gray400, 'Inactif');

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.s8,
        vertical: 3,
      ),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
      ),
      child: Text(
        label,
        style: AppTextStyles.badge.copyWith(color: textColor, fontSize: 9),
      ),
    );
  }
}
