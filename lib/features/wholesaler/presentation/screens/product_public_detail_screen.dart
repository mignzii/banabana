import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:banabana_b2b/core/api/api_client.dart';
import 'package:banabana_b2b/core/theme/app_colors.dart';
import 'package:banabana_b2b/core/theme/app_spacing.dart';
import 'package:banabana_b2b/core/theme/app_text_styles.dart';
import 'package:banabana_b2b/features/producer/providers/product_providers.dart';
import 'package:banabana_b2b/features/producer/providers/category_providers.dart';
import 'package:banabana_b2b/features/wholesaler/providers/cart_providers.dart';
import 'package:banabana_b2b/shared/models/product.dart';
import 'package:banabana_b2b/shared/widgets/app_snack_bar.dart';
import 'package:banabana_b2b/shared/widgets/loading_shimmer.dart';

class ProductPublicDetailScreen extends ConsumerStatefulWidget {
  final String productId;
  const ProductPublicDetailScreen({super.key, required this.productId});

  @override
  ConsumerState<ProductPublicDetailScreen> createState() =>
      _ProductPublicDetailScreenState();
}

class _ProductPublicDetailScreenState
    extends ConsumerState<ProductPublicDetailScreen> {
  ProductVariant? _selectedVariant;
  int _quantity = 1;
  int _pageIndex = 0;
  bool _descriptionExpanded = false;

  void _addToCart(Product product) {
    if (_selectedVariant == null) return;
    ref.read(cartProvider.notifier).add(
          variantId: _selectedVariant!.id,
          productId: product.id,
          productTitle: product.title,
          variantLabel: _selectedVariant!.label,
          unitPrice: _selectedVariant!.price,
          quantity: _quantity,
        );
    context.showSnack(
      'Ajouté au panier ✓',
      type: SnackType.success,
      actionLabel: 'Voir',
      onAction: () => context.push('/shop/cart'),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final productAsync = ref.watch(productDetailProvider(widget.productId));

    return Scaffold(
      backgroundColor:
          isDark ? AppColors.darkBg : AppColors.gray50,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: Padding(
          padding: const EdgeInsets.all(AppSpacing.s8),
          child: _CircleButton(
            icon: Symbols.arrow_back,
            isDark: isDark,
            onTap: () => context.pop(),
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: AppSpacing.s12),
            child: _CircleButton(
              icon: Symbols.shopping_cart,
              isDark: isDark,
              onTap: () => context.push('/shop/cart'),
            ),
          ),
        ],
      ),
      bottomNavigationBar: productAsync.valueOrNull != null
          ? _buildBottomBar(productAsync.valueOrNull!, isDark)
          : null,
      body: productAsync.when(
        loading: () => _buildSkeleton(isDark),
        error: (e, _) => _buildError(e, isDark),
        data: (product) {
          _selectedVariant ??=
              product.variants.isNotEmpty ? product.variants.first : null;
          return _buildScrollContent(product, isDark);
        },
      ),
    );
  }

  // ── Skeleton ──────────────────────────────────────────────────────────────

  Widget _buildSkeleton(bool isDark) {
    return Column(
      children: [
        ShimmerBox(
          height: 280,
          borderRadius: 0,
          width: double.infinity,
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.s20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: AppSpacing.s16),
                ShimmerBox(
                    height: 24, width: 220, borderRadius: AppSpacing.s4),
                const SizedBox(height: AppSpacing.s12),
                ShimmerBox(
                    height: 14, width: 100, borderRadius: AppSpacing.s4),
                const SizedBox(height: AppSpacing.s20),
                ShimmerBox(
                    height: 14, width: double.infinity, borderRadius: AppSpacing.s4),
                const SizedBox(height: AppSpacing.s8),
                ShimmerBox(
                    height: 14, width: 180, borderRadius: AppSpacing.s4),
                const SizedBox(height: AppSpacing.s32),
                ShimmerBox(
                    height: 16, width: 140, borderRadius: AppSpacing.s4),
                const SizedBox(height: AppSpacing.s12),
                Row(
                  children: [
                    ShimmerBox(
                        height: 52, width: 90, borderRadius: AppSpacing.radiusMedium),
                    const SizedBox(width: AppSpacing.s10),
                    ShimmerBox(
                        height: 52, width: 90, borderRadius: AppSpacing.radiusMedium),
                    const SizedBox(width: AppSpacing.s10),
                    ShimmerBox(
                        height: 52, width: 90, borderRadius: AppSpacing.radiusMedium),
                  ],
                ),
              ],
            ),
          ),
        ),
        // Bottom bar skeleton
        Container(
          height: 90,
          padding: const EdgeInsets.all(AppSpacing.s16),
          color: isDark ? AppColors.darkSurface : AppColors.white,
          child: Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ShimmerBox(
                      height: 11, width: 40, borderRadius: AppSpacing.s4),
                  const SizedBox(height: AppSpacing.s6),
                  ShimmerBox(
                      height: 22, width: 100, borderRadius: AppSpacing.s4),
                ],
              ),
              const Spacer(),
              ShimmerBox(
                  height: 50, width: 160, borderRadius: AppSpacing.radiusLarge),
            ],
          ),
        ),
      ],
    );
  }

  // ── Error ─────────────────────────────────────────────────────────────────

  Widget _buildError(Object error, bool isDark) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.s32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Symbols.error_circle_rounded,
              size: 56,
              color: AppColors.error.withValues(alpha: 0.8),
            ),
            const SizedBox(height: AppSpacing.s16),
            Text(
              'Une erreur est survenue',
              style: AppTextStyles.sectionTitle.copyWith(
                color: isDark ? AppColors.white : AppColors.gray800,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.s8),
            Text(
              error.toString(),
              style: AppTextStyles.bodySecondary.copyWith(
                color: isDark ? AppColors.gray400 : AppColors.gray500,
              ),
              textAlign: TextAlign.center,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: AppSpacing.s24),
            FilledButton.icon(
              onPressed: () =>
                  ref.invalidate(productDetailProvider(widget.productId)),
              icon: const Icon(Symbols.refresh),
              label: const Text('Réessayer'),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.white,
                padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.s24, vertical: AppSpacing.s14),
                shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(AppSpacing.radiusLarge)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Main Content ──────────────────────────────────────────────────────────

  Widget _buildScrollContent(Product product, bool isDark) {
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(child: _buildImageCarousel(product, isDark)),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.s20, vertical: AppSpacing.s20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTitleSection(product, isDark),
                if (product.producer != null) ...[
                  const SizedBox(height: AppSpacing.s12),
                  _buildProducerInfo(product.producer!, isDark),
                ],
                const SizedBox(height: AppSpacing.s16),
                if (product.description != null &&
                    product.description!.isNotEmpty) ...[
                  _buildDescription(product.description!, isDark),
                  const SizedBox(height: AppSpacing.s20),
                ],
                Divider(
                  color: isDark ? AppColors.darkBorder2 : AppColors.gray200,
                  thickness: 1,
                ),
                const SizedBox(height: AppSpacing.s20),
                _buildVariantsSection(product, isDark),
                const SizedBox(height: AppSpacing.s24),
                if (_hasWholesaleInfo(_selectedVariant)) ...[
                  const SizedBox(height: AppSpacing.s16),
                  _buildWholesaleInfoCard(isDark),
                ],
                Divider(
                  color: isDark ? AppColors.darkBorder2 : AppColors.gray200,
                  thickness: 1,
                ),
                const SizedBox(height: AppSpacing.s20),
                _buildQuantityStepper(isDark),
                const SizedBox(height: AppSpacing.s32),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ── Image Carousel ────────────────────────────────────────────────────────

  Widget _buildImageCarousel(Product product, bool isDark) {
    if (product.images.isEmpty) {
      return Container(
        height: 280,
        color: isDark ? AppColors.darkSurface2 : AppColors.gray100,
        child: Center(
          child: Icon(
            Symbols.image,
            size: 64,
            color: isDark ? AppColors.gray700 : AppColors.gray300,
          ),
        ),
      );
    }

    return SizedBox(
      height: 280,
      child: Stack(
        children: [
          // PageView — ExcludeSemantics prevents nested-Viewport semantics assertion
          ExcludeSemantics(
            child: PageView.builder(
            itemCount: product.images.length,
            onPageChanged: (i) => setState(() => _pageIndex = i),
            itemBuilder: (_, i) => CachedNetworkImage(
              imageUrl: resolveImageUrl(product.images[i].url),
              fit: BoxFit.cover,
              width: double.infinity,
              placeholder: (_, __) => Container(
                color: isDark ? AppColors.darkSurface2 : AppColors.gray200,
              ),
              errorWidget: (_, __, ___) => Container(
                color: isDark ? AppColors.darkSurface2 : AppColors.gray200,
                child: Center(
                  child: Icon(
                    Symbols.broken_image,
                    size: 48,
                    color: isDark ? AppColors.gray700 : AppColors.gray400,
                  ),
                ),
              ),
            ),
          ),
          ),

          // Gradient overlay (bottom)
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            height: 80,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.5),
                  ],
                ),
              ),
            ),
          ),

          // Counter badge (top-right)
          if (product.images.length > 1)
            Positioned(
              top: 60,
              right: AppSpacing.s16,
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.s10, vertical: AppSpacing.s4),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.55),
                  borderRadius:
                      BorderRadius.circular(AppSpacing.radiusPill),
                ),
                child: Text(
                  '${_pageIndex + 1} / ${product.images.length}',
                  style: AppTextStyles.badge,
                ),
              ),
            ),

          // Dots indicator (bottom-center)
          if (product.images.length > 1)
            Positioned(
              bottom: AppSpacing.s12,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(product.images.length, (i) {
                  final active = i == _pageIndex;
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 220),
                    curve: Curves.easeInOut,
                    margin: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.s4),
                    width: active ? 20 : 6,
                    height: 6,
                    decoration: BoxDecoration(
                      borderRadius:
                          BorderRadius.circular(AppSpacing.radiusPill),
                      color: active
                          ? AppColors.white
                          : AppColors.white.withValues(alpha: 0.45),
                    ),
                  );
                }),
              ),
            ),
        ],
      ),
    );
  }

  // ── Title Section ─────────────────────────────────────────────────────────

  Widget _buildTitleSection(Product product, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Category chip
        Container(
          padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.s10, vertical: AppSpacing.s4),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: isDark ? 0.18 : 0.10),
            borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
          ),
          child: Text(
            resolveCategory(
                product.category,
                ref.watch(allCategoriesProvider).valueOrNull ?? []),
            style: AppTextStyles.caption.copyWith(
              color: isDark ? AppColors.primaryLight : AppColors.primaryDark,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.s10),
        // Product title
        Text(
          product.title,
          style: AppTextStyles.screenTitle.copyWith(
            color: isDark ? AppColors.white : AppColors.gray900,
          ),
        ),
        // Selected variant price (prominent)
        if (_selectedVariant != null) ...[
          const SizedBox(height: AppSpacing.s8),
          Text(
            '${_selectedVariant!.price.toStringAsFixed(0)} FCFA',
            style: AppTextStyles.price.copyWith(
              fontSize: 22,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ],
    );
  }

  // ── Description ───────────────────────────────────────────────────────────

  Widget _buildDescription(String description, bool isDark) {
    final isLong = description.length > 140;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AnimatedCrossFade(
          firstChild: Text(
            description,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.bodySecondary.copyWith(
              color: isDark ? AppColors.gray400 : AppColors.gray600,
              height: 1.6,
            ),
          ),
          secondChild: Text(
            description,
            style: AppTextStyles.bodySecondary.copyWith(
              color: isDark ? AppColors.gray400 : AppColors.gray600,
              height: 1.6,
            ),
          ),
          crossFadeState: _descriptionExpanded
              ? CrossFadeState.showSecond
              : CrossFadeState.showFirst,
          duration: const Duration(milliseconds: 250),
        ),
        if (isLong) ...[
          const SizedBox(height: AppSpacing.s6),
          GestureDetector(
            onTap: () =>
                setState(() => _descriptionExpanded = !_descriptionExpanded),
            child: Text(
              _descriptionExpanded ? 'Voir moins' : 'Voir plus',
              style: AppTextStyles.label.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ],
    );
  }

  // ── Variants ──────────────────────────────────────────────────────────────

  Widget _buildVariantsSection(Product product, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Choisir une variante',
          style: AppTextStyles.sectionTitle.copyWith(
            fontSize: 16,
            color: isDark ? AppColors.white : AppColors.gray900,
          ),
        ),
        const SizedBox(height: AppSpacing.s12),
        Wrap(
          spacing: AppSpacing.s10,
          runSpacing: AppSpacing.s10,
          children: product.variants.map((v) {
            final selected = _selectedVariant?.id == v.id;
            return _VariantChip(
              variant: v,
              selected: selected,
              isDark: isDark,
              onTap: () => setState(() {
                _selectedVariant = v;
                _quantity = v.minOrderQuantity ?? 1;
              }),
            );
          }).toList(),
        ),
      ],
    );
  }

  // ── Quantity Stepper ──────────────────────────────────────────────────────

  Widget _buildQuantityStepper(bool isDark) {
    final minQty = _selectedVariant?.minOrderQuantity ?? 1;
    final wholesaleUnit = _selectedVariant?.wholesaleUnit;
    final quantityLabel = wholesaleUnit != null
        ? 'Quantité (${_wholesaleUnitLabel(wholesaleUnit)})'
        : 'Quantité';
    return Row(
      children: [
        Text(
          quantityLabel,
          style: AppTextStyles.sectionTitle.copyWith(
            fontSize: 16,
            color: isDark ? AppColors.white : AppColors.gray900,
          ),
        ),
        const Spacer(),
        // Stepper container
        Container(
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkSurface2 : AppColors.white,
            borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
            border: Border.all(
              color: isDark ? AppColors.darkBorder2 : AppColors.gray200,
            ),
          ),
          child: Row(
            children: [
              // Decrease button
              _StepperButton(
                icon: Symbols.remove_circle,
                enabled: _quantity > minQty,
                onTap: () {
                  if (_quantity > minQty) setState(() => _quantity--);
                },
              ),
              // Count
              SizedBox(
                width: 44,
                child: Text(
                  '$_quantity',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.sectionTitle.copyWith(
                    fontSize: 18,
                    color: isDark ? AppColors.white : AppColors.gray900,
                  ),
                ),
              ),
              // Increase button
              _StepperButton(
                icon: Symbols.add_circle,
                enabled: true,
                onTap: () => setState(() => _quantity++),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ── Wholesale helpers ─────────────────────────────────────────────────────

  bool _hasWholesaleInfo(ProductVariant? v) {
    if (v == null) return false;
    return v.wholesaleUnit != null ||
        v.minOrderQuantity != null ||
        v.unitsPerPackage != null;
  }

  String _wholesaleUnitLabel(String? unit) {
    return switch (unit) {
      'sac' => 'sac(s)',
      'kg' => 'kg',
      'tonne' => 'tonne(s)',
      'carton' => 'carton(s)',
      'caisse' => 'caisse(s)',
      'palette' => 'palette(s)',
      'piece' => 'pièce(s)',
      'litre' => 'litre(s)',
      _ => unit ?? 'unité(s)',
    };
  }

  Widget _buildProducerInfo(ProductProducer producer, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.s12, vertical: AppSpacing.s10),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface2 : AppColors.gray50,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
        border: Border.all(
            color: isDark ? AppColors.darkBorder2 : AppColors.gray200),
      ),
      child: Row(
        children: [
          Icon(Symbols.store, size: 18,
              color: isDark ? AppColors.gray400 : AppColors.gray500),
          const SizedBox(width: AppSpacing.s8),
          Expanded(
            child: Text(
              producer.businessName,
              style: AppTextStyles.label.copyWith(
                color: isDark ? AppColors.gray300 : AppColors.gray700,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.s8),
          Icon(Symbols.location_on, size: 14,
              color: isDark ? AppColors.gray500 : AppColors.gray400),
          const SizedBox(width: AppSpacing.s4),
          Text(
            producer.zone,
            style: AppTextStyles.caption.copyWith(
              color: isDark ? AppColors.gray500 : AppColors.gray500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWholesaleInfoCard(bool isDark) {
    final v = _selectedVariant!;
    final unitLabel = _wholesaleUnitLabel(v.wholesaleUnit);
    return Container(
      padding: const EdgeInsets.all(AppSpacing.s14),
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.primary.withValues(alpha: 0.08)
            : AppColors.primary.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
        border: Border.all(
            color: AppColors.primary.withValues(alpha: isDark ? 0.25 : 0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Symbols.info, size: 16, color: AppColors.primary),
              const SizedBox(width: AppSpacing.s6),
              Text(
                'Conditions grossiste',
                style: AppTextStyles.label.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.s10),
          _WholesaleRow(
            label: 'Unité de vente',
            value: unitLabel,
            isDark: isDark,
          ),
          if (v.minOrderQuantity != null) ...[
            const SizedBox(height: AppSpacing.s6),
            _WholesaleRow(
              label: 'Commande minimum',
              value: '${v.minOrderQuantity} $unitLabel',
              isDark: isDark,
              highlight: true,
            ),
          ],
          if (v.unitsPerPackage != null) ...[
            const SizedBox(height: AppSpacing.s6),
            _WholesaleRow(
              label: 'Unités / conditionnement',
              value: '${v.unitsPerPackage} unités',
              isDark: isDark,
            ),
          ],
          if (v.stock > 0) ...[
            const SizedBox(height: AppSpacing.s6),
            _WholesaleRow(
              label: 'Stock disponible',
              value: '${v.stock} $unitLabel',
              isDark: isDark,
            ),
          ],
        ],
      ),
    );
  }

  // ── Bottom Bar ────────────────────────────────────────────────────────────

  Widget _buildBottomBar(Product product, bool isDark) {
    final total = _selectedVariant != null
        ? _selectedVariant!.price * _quantity
        : 0.0;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.white,
        border: Border(
          top: BorderSide(
            color: isDark ? AppColors.darkBorder : AppColors.gray200,
            width: 1,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.07),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
              AppSpacing.s20, AppSpacing.s16, AppSpacing.s20, AppSpacing.s16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Total price section
              if (_selectedVariant != null) ...[
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Total',
                      style: AppTextStyles.caption.copyWith(
                        color: isDark ? AppColors.gray500 : AppColors.gray500,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.s4),
                    Text(
                      '${total.toStringAsFixed(0)} FCFA',
                      style: AppTextStyles.price.copyWith(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: AppSpacing.s16),
              ],
              const Spacer(),
              // Add to cart button
              FilledButton.icon(
                onPressed: _selectedVariant != null
                    ? () => _addToCart(product)
                    : null,
                icon: const Icon(Symbols.add_shopping_cart, size: 20),
                label: const Text('Ajouter au panier'),
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  disabledBackgroundColor:
                      isDark ? AppColors.darkSurface2 : AppColors.gray200,
                  foregroundColor: AppColors.white,
                  textStyle: AppTextStyles.button,
                  padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.s20, vertical: AppSpacing.s16),
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(AppSpacing.radiusLarge),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Supporting Widgets ────────────────────────────────────────────────────────

class _CircleButton extends StatelessWidget {
  final IconData icon;
  final bool isDark;
  final VoidCallback onTap;

  const _CircleButton({
    required this.icon,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: AppSpacing.s48,
        height: AppSpacing.s48,
        decoration: BoxDecoration(
          color: isDark
              ? AppColors.darkSurface2.withValues(alpha: 0.85)
              : AppColors.white.withValues(alpha: 0.9),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.4 : 0.12),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(
          icon,
          size: 22,
          color: isDark ? AppColors.white : AppColors.gray800,
        ),
      ),
    );
  }
}

class _VariantChip extends StatelessWidget {
  final ProductVariant variant;
  final bool selected;
  final bool isDark;
  final VoidCallback onTap;

  const _VariantChip({
    required this.variant,
    required this.selected,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeInOut,
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeInOut,
          padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.s16, vertical: AppSpacing.s10),
          decoration: BoxDecoration(
            color: selected
                ? AppColors.primary
                : isDark
                    ? AppColors.darkSurface2
                    : AppColors.white,
            borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
            border: Border.all(
              color: selected
                  ? AppColors.primary
                  : isDark
                      ? AppColors.darkBorder2
                      : AppColors.gray300,
              width: selected ? 1.5 : 1,
            ),
            boxShadow: selected
                ? [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Column(
            children: [
              Text(
                variant.label,
                style: AppTextStyles.label.copyWith(
                  fontWeight: FontWeight.w700,
                  color: selected
                      ? AppColors.white
                      : isDark
                          ? AppColors.gray200
                          : AppColors.gray800,
                ),
              ),
              const SizedBox(height: AppSpacing.s4),
              Text(
                '${variant.price.toStringAsFixed(0)} FCFA',
                style: AppTextStyles.caption.copyWith(
                  fontSize: 11,
                  color: selected
                      ? AppColors.white.withValues(alpha: 0.8)
                      : AppColors.primary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StepperButton extends StatelessWidget {
  final IconData icon;
  final bool enabled;
  final VoidCallback onTap;

  const _StepperButton({
    required this.icon,
    required this.enabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Padding(
        padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.s12, vertical: AppSpacing.s12),
        child: Icon(
          icon,
          size: 28,
          color: enabled
              ? AppColors.primary
              : AppColors.gray300,
        ),
      ),
    );
  }
}

class _WholesaleRow extends StatelessWidget {
  const _WholesaleRow({
    required this.label,
    required this.value,
    required this.isDark,
    this.highlight = false,
  });

  final String label;
  final String value;
  final bool isDark;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: AppTextStyles.caption.copyWith(
            color: isDark ? AppColors.gray400 : AppColors.gray500,
          ),
        ),
        Text(
          value,
          style: AppTextStyles.label.copyWith(
            color: highlight
                ? AppColors.primary
                : (isDark ? AppColors.gray200 : AppColors.gray800),
            fontWeight: highlight ? FontWeight.w700 : FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
