import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:banabana_b2b/core/api/api_client.dart';
import 'package:banabana_b2b/core/theme/app_colors.dart';
import 'package:banabana_b2b/core/theme/app_spacing.dart';
import 'package:banabana_b2b/core/theme/app_text_styles.dart';
import 'package:banabana_b2b/features/wholesaler/providers/cart_providers.dart';
import 'package:banabana_b2b/shared/models/catalog_item.dart';
import 'package:banabana_b2b/shared/widgets/loading_shimmer.dart';

class CatalogItemCard extends ConsumerStatefulWidget {
  const CatalogItemCard({
    super.key,
    required this.item,
    this.onTap,
  });

  final CatalogItem item;
  final VoidCallback? onTap;

  @override
  ConsumerState<CatalogItemCard> createState() => _CatalogItemCardState();
}

class _CatalogItemCardState extends ConsumerState<CatalogItemCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _scaleCtrl;
  late final Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _scaleCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
      lowerBound: 0.9,
      upperBound: 1.0,
      value: 1.0,
    );
    _scaleAnim = _scaleCtrl;
  }

  @override
  void dispose() {
    _scaleCtrl.dispose();
    super.dispose();
  }

  Future<void> _onAddToCart() async {
    HapticFeedback.lightImpact();
    await _scaleCtrl.reverse();
    if (!mounted) return;
    await _scaleCtrl.forward();
    if (!mounted) return;
    ref.read(cartProvider.notifier).add(
      variantId: widget.item.id,
      productId: widget.item.id,
      productTitle: widget.item.title,
      variantLabel: widget.item.category,
      unitPrice: widget.item.minPrice,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final item = widget.item;
    final imageUrl = (item.mainImage != null && item.mainImage!.isNotEmpty)
        ? resolveImageUrl(item.mainImage!)
        : null;

    final stockStatus = _stockStatus(item);
    final isOutOfStock = stockStatus == _StockStatus.outOfStock;

    return Opacity(
      opacity: isOutOfStock ? 0.5 : 1.0,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: widget.onTap,
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
                            errorWidget: (_, __, ___) => _Placeholder(isDark: isDark),
                          )
                        else
                          _Placeholder(isDark: isDark),
                        // Badge stock
                        Positioned(
                          top: AppSpacing.s8,
                          right: AppSpacing.s8,
                          child: _StockBadge(status: stockStatus),
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
                        item.title,
                        style: AppTextStyles.label.copyWith(
                          color: isDark ? AppColors.gray100 : AppColors.gray900,
                          fontWeight: FontWeight.w700,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        item.producer.businessName,
                        style: AppTextStyles.caption.copyWith(
                          color: isDark ? AppColors.gray500 : AppColors.gray400,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: AppSpacing.s8),
                      Row(
                        children: [
                          Expanded(
                            child: RichText(
                              text: TextSpan(
                                children: [
                                  TextSpan(
                                    text: item.minPrice.toStringAsFixed(0),
                                    style: AppTextStyles.price.copyWith(fontSize: 14),
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
                          // Bouton + avec ScaleTransition
                          ScaleTransition(
                            scale: _scaleAnim,
                            child: GestureDetector(
                              onTap: isOutOfStock ? null : _onAddToCart,
                              child: Container(
                                width: 28,
                                height: 28,
                                decoration: BoxDecoration(
                                  color: isOutOfStock
                                      ? (isDark ? AppColors.darkSurface2 : AppColors.gray200)
                                      : AppColors.primary,
                                  borderRadius: BorderRadius.circular(AppSpacing.radiusSmall),
                                ),
                                child: Icon(
                                  Symbols.add,
                                  size: 16,
                                  color: isOutOfStock
                                      ? AppColors.gray500
                                      : AppColors.white,
                                ),
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

enum _StockStatus { inStock, lowStock, outOfStock }

_StockStatus _stockStatus(CatalogItem item) {
  if (item.totalStock <= 0) return _StockStatus.outOfStock;
  if (item.totalStock <= 10) return _StockStatus.lowStock;
  return _StockStatus.inStock;
}

class _StockBadge extends StatelessWidget {
  const _StockBadge({required this.status});
  final _StockStatus status;

  @override
  Widget build(BuildContext context) {
    final (bgColor, textColor, label) = switch (status) {
      _StockStatus.inStock => (
        AppColors.success.withValues(alpha: 0.15),
        AppColors.success,
        'En stock',
      ),
      _StockStatus.lowStock => (
        AppColors.warning.withValues(alpha: 0.15),
        AppColors.warning,
        'Stock faible',
      ),
      _StockStatus.outOfStock => (
        AppColors.error.withValues(alpha: 0.10),
        AppColors.error,
        'Rupture',
      ),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s8, vertical: 3),
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

class _Placeholder extends StatelessWidget {
  const _Placeholder({required this.isDark});
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
