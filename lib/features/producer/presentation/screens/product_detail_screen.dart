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
import 'package:banabana_b2b/shared/models/product.dart';
import 'package:banabana_b2b/shared/widgets/app_snack_bar.dart';
import 'package:banabana_b2b/shared/widgets/loading_shimmer.dart';

class ProductDetailScreen extends ConsumerWidget {
  const ProductDetailScreen({
    super.key,
    required this.productId,
    this.routePrefix = '/producer/products',
    this.showRestockAction = false,
  });
  final String productId;
  final String routePrefix;
  final bool showRestockAction;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final productAsync = ref.watch(productDetailProvider(productId));
    final textPrimary = isDark ? AppColors.gray100 : AppColors.gray900;
    final border = isDark ? AppColors.darkBorder : AppColors.gray100;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBg : AppColors.gray50,
      appBar: AppBar(
        backgroundColor: isDark ? AppColors.darkBg : AppColors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Symbols.arrow_back, color: textPrimary),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Détail produit',
          style: AppTextStyles.sectionTitle.copyWith(color: textPrimary),
        ),
        actions: [
          IconButton(
            icon: Icon(Symbols.edit, color: AppColors.primary, size: 20),
            onPressed: () => context.push('$routePrefix/$productId/edit'),
            tooltip: 'Modifier',
          ),
          productAsync.maybeWhen(
            data: (product) => _MoreMenu(product: product, isDark: isDark),
            orElse: () => const SizedBox.shrink(),
          ),
          const SizedBox(width: AppSpacing.s4),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Divider(height: 1, color: border),
        ),
      ),
      body: productAsync.when(
        loading: () => _LoadingDetail(isDark: isDark),
        error: (e, _) => _ErrorView(
          isDark: isDark,
          message: e.toString(),
          onRetry: () => ref.invalidate(productDetailProvider(productId)),
        ),
        data: (product) => _ProductDetail(product: product, isDark: isDark, routePrefix: routePrefix, showRestockAction: showRestockAction),
      ),
    );
  }
}

// ─── Vue principale ───────────────────────────────────────────────────────────

class _ProductDetail extends ConsumerStatefulWidget {
  const _ProductDetail({required this.product, required this.isDark, required this.routePrefix, this.showRestockAction = false});
  final Product product;
  final bool isDark;
  final String routePrefix;
  final bool showRestockAction;

  @override
  ConsumerState<_ProductDetail> createState() => _ProductDetailState();
}

class _ProductDetailState extends ConsumerState<_ProductDetail> {
  final _pageCtrl = PageController();
  int _currentPage = 0;
  bool _descExpanded = false;

  @override
  void dispose() {
    _pageCtrl.dispose();
    super.dispose();
  }

  int get _totalStock => widget.product.variants.fold(0, (s, v) => s + v.stock);

  @override
  Widget build(BuildContext context) {
    final p = widget.product;
    final isDark = widget.isDark;

    final surface = isDark ? AppColors.darkSurface : AppColors.white;
    final border = isDark ? AppColors.darkBorder : AppColors.gray100;
    final textPrimary = isDark ? AppColors.gray100 : AppColors.gray900;
    final textSecondary = isDark ? AppColors.gray500 : AppColors.gray400;

    final categories = ref.watch(allCategoriesProvider).valueOrNull ?? [];
    final categoryName = resolveCategory(p.category, categories);

    return ListView(
      padding: EdgeInsets.zero,
      children: [
        // ── Carousel images ─────────────────────────────────────────────────
        if (p.images.isNotEmpty)
          Stack(
            children: [
              SizedBox(
                height: 280,
                child: PageView.builder(
                  controller: _pageCtrl,
                  itemCount: p.images.length,
                  onPageChanged: (i) => setState(() => _currentPage = i),
                  itemBuilder: (_, i) => CachedNetworkImage(
                    imageUrl: resolveImageUrl(p.images[i].url),
                    fit: BoxFit.cover,
                    placeholder: (_, __) => const ShimmerBox(height: double.infinity),
                    errorWidget: (_, __, ___) => Container(
                      color: isDark ? AppColors.darkSurface2 : AppColors.gray100,
                      child: Icon(
                        Symbols.image,
                        size: 48,
                        color: isDark ? AppColors.gray700 : AppColors.gray300,
                      ),
                    ),
                  ),
                ),
              ),
              // Badge position images
              if (p.images.length > 1)
                Positioned(
                  top: AppSpacing.s12,
                  right: AppSpacing.s12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.s10,
                      vertical: AppSpacing.s4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.black.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
                    ),
                    child: Text(
                      '${_currentPage + 1}/${p.images.length}',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              // Dots indicator
              if (p.images.length > 1)
                Positioned(
                  bottom: AppSpacing.s12,
                  left: 0,
                  right: 0,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      p.images.length,
                      (i) => AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        margin: const EdgeInsets.symmetric(horizontal: 3),
                        width: i == _currentPage ? 20 : 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: i == _currentPage
                              ? AppColors.white
                              : AppColors.white.withValues(alpha: 0.5),
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          )
        else
          Container(
            height: 200,
            color: isDark ? AppColors.darkSurface2 : AppColors.gray100,
            child: Icon(
              Symbols.image,
              size: 56,
              color: isDark ? AppColors.gray700 : AppColors.gray300,
            ),
          ),

        Padding(
          padding: const EdgeInsets.all(AppSpacing.s16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── En-tête produit ──────────────────────────────────────────
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      p.title,
                      style: AppTextStyles.screenTitle.copyWith(color: textPrimary),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.s8),
                  // Badge statut
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.s10,
                      vertical: AppSpacing.s4,
                    ),
                    decoration: BoxDecoration(
                      color: (p.isActive ? AppColors.success : AppColors.gray400)
                          .withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(
                            color: p.isActive ? AppColors.success : AppColors.gray400,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 5),
                        Text(
                          p.isActive ? 'Actif' : 'Inactif',
                          style: AppTextStyles.caption.copyWith(
                            color: p.isActive ? AppColors.success : AppColors.gray400,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.s8),

              // Catégorie + date
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.s8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
                    ),
                    child: Text(
                      categoryName,
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.s8),
                  Text(
                    'Mis à jour ${_formatDate(p.updatedAt)}',
                    style: AppTextStyles.caption.copyWith(color: textSecondary),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.s12),

              // Prix de base
              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: '${p.basePrice.toStringAsFixed(0)} ',
                      style: AppTextStyles.display.copyWith(
                        color: AppColors.primary,
                        fontSize: 28,
                      ),
                    ),
                    TextSpan(
                      text: 'FCFA',
                      style: AppTextStyles.bodySecondary.copyWith(
                        color: AppColors.primary.withValues(alpha: 0.7),
                      ),
                    ),
                    TextSpan(
                      text: '  prix de base',
                      style: AppTextStyles.caption.copyWith(color: textSecondary),
                    ),
                  ],
                ),
              ),

              // ── Description ──────────────────────────────────────────────
              if (p.description != null && p.description!.isNotEmpty) ...[
                const SizedBox(height: AppSpacing.s16),
                _InfoCard(
                  isDark: isDark,
                  surface: surface,
                  border: border,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Symbols.description, size: 14, color: AppColors.primary),
                          const SizedBox(width: AppSpacing.s6),
                          Text(
                            'Description',
                            style: AppTextStyles.label.copyWith(
                              color: textPrimary,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.s8),
                      Text(
                        p.description!,
                        style: AppTextStyles.body.copyWith(color: textSecondary),
                        maxLines: _descExpanded ? null : 3,
                        overflow: _descExpanded ? null : TextOverflow.ellipsis,
                      ),
                      if (p.description!.length > 120) ...[
                        const SizedBox(height: AppSpacing.s4),
                        GestureDetector(
                          onTap: () => setState(() => _descExpanded = !_descExpanded),
                          child: Text(
                            _descExpanded ? 'Voir moins' : 'Voir plus',
                            style: AppTextStyles.caption.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],

              // ── Résumé stock ─────────────────────────────────────────────
              const SizedBox(height: AppSpacing.s16),
              _InfoCard(
                isDark: isDark,
                surface: surface,
                border: border,
                child: Row(
                  children: [
                    _StockStat(
                      isDark: isDark,
                      icon: Symbols.inventory_2,
                      label: 'Stock total',
                      value: '$_totalStock unités',
                      color: _totalStock > 0 ? AppColors.success : AppColors.error,
                    ),
                    Container(width: 1, height: 40, color: border),
                    _StockStat(
                      isDark: isDark,
                      icon: Symbols.package_2,
                      label: 'Variantes',
                      value: '${p.variants.length}',
                      color: AppColors.primary,
                    ),
                    Container(width: 1, height: 40, color: border),
                    _StockStat(
                      isDark: isDark,
                      icon: Symbols.photo_library,
                      label: 'Photos',
                      value: '${p.images.length}',
                      color: AppColors.secondary,
                    ),
                  ],
                ),
              ),

              // ── Variantes ────────────────────────────────────────────────
              const SizedBox(height: AppSpacing.s16),
              Row(
                children: [
                  Icon(Symbols.package_2, size: 16, color: AppColors.primary),
                  const SizedBox(width: AppSpacing.s8),
                  Text(
                    'Variantes',
                    style: AppTextStyles.sectionTitle.copyWith(color: textPrimary),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.s10),

              if (p.variants.isEmpty)
                Container(
                  padding: const EdgeInsets.all(AppSpacing.s16),
                  decoration: BoxDecoration(
                    color: surface,
                    borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
                    border: Border.all(color: border),
                  ),
                  child: Row(
                    children: [
                      Icon(Symbols.info, size: 16, color: textSecondary),
                      const SizedBox(width: AppSpacing.s8),
                      Text(
                        'Aucune variante — prix de base utilisé.',
                        style: AppTextStyles.caption.copyWith(color: textSecondary),
                      ),
                    ],
                  ),
                )
              else
                ...p.variants.map((v) => _VariantDetailCard(
                      v: v,
                      isDark: isDark,
                      surface: surface,
                      border: border,
                      textPrimary: textPrimary,
                      textSecondary: textSecondary,
                    )),

              // ── Actions ──────────────────────────────────────────────────
              const SizedBox(height: AppSpacing.s24),
              _ActionsBar(
                product: p,
                isDark: isDark,
                border: border,
                surface: surface,
                textPrimary: textPrimary,
                routePrefix: widget.routePrefix,
                showRestockAction: widget.showRestockAction,
              ),

              const SizedBox(height: AppSpacing.s32),
            ],
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inDays == 0) return 'aujourd\'hui';
    if (diff.inDays == 1) return 'hier';
    if (diff.inDays < 7) return 'il y a ${diff.inDays}j';
    return '${dt.day}/${dt.month}/${dt.year}';
  }
}

// ─── Carte variante détaillée ─────────────────────────────────────────────────

class _VariantDetailCard extends StatelessWidget {
  const _VariantDetailCard({
    required this.v,
    required this.isDark,
    required this.surface,
    required this.border,
    required this.textPrimary,
    required this.textSecondary,
  });

  final ProductVariant v;
  final bool isDark;
  final Color surface;
  final Color border;
  final Color textPrimary;
  final Color textSecondary;

  Color get _stockColor {
    final min = v.minStock ?? 5;
    if (v.stock <= min) return AppColors.error;
    if (v.stock <= min * 2) return AppColors.warning;
    return AppColors.success;
  }

  String get _stockLabel {
    final min = v.minStock ?? 5;
    if (v.stock <= min) return 'Stock critique';
    if (v.stock <= min * 2) return 'Stock faible';
    return 'Stock OK';
  }

  double get _stockRatio {
    final max = v.maxStock ?? (v.stock * 2).clamp(1, 9999);
    if (max == 0) return 1;
    return (v.stock / max).clamp(0.0, 1.0);
  }

  @override
  Widget build(BuildContext context) {
    final packInfo = [if (v.pack != null) v.pack!, v.label].join(' · ');

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.s10),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLarge),
        border: Border.all(color: border),
      ),
      child: Column(
        children: [
          // En-tête variante
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.s16, AppSpacing.s14,
              AppSpacing.s16, AppSpacing.s10,
            ),
            child: Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
                  ),
                  child: const Icon(Symbols.package_2, size: 18, color: AppColors.primary),
                ),
                const SizedBox(width: AppSpacing.s12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        packInfo,
                        style: AppTextStyles.label.copyWith(
                          color: textPrimary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      if (v.weight != null)
                        Text(
                          '${v.weight} kg',
                          style: AppTextStyles.caption.copyWith(color: textSecondary),
                        ),
                    ],
                  ),
                ),
                // Prix
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.s10,
                    vertical: AppSpacing.s4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
                  ),
                  child: Text(
                    '${v.price.toStringAsFixed(0)} F',
                    style: AppTextStyles.label.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Barre de stock
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: _stockColor,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.s6),
                        Text(
                          _stockLabel,
                          style: AppTextStyles.caption.copyWith(
                            color: _stockColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      '${v.stock} unités',
                      style: AppTextStyles.label.copyWith(
                        color: textPrimary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.s6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
                  child: LinearProgressIndicator(
                    value: _stockRatio,
                    minHeight: 6,
                    backgroundColor: isDark ? AppColors.darkSurface2 : AppColors.gray100,
                    valueColor: AlwaysStoppedAnimation<Color>(_stockColor),
                  ),
                ),
                if (v.minStock != null || v.maxStock != null) ...[
                  const SizedBox(height: AppSpacing.s4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      if (v.minStock != null)
                        Text(
                          'Min: ${v.minStock}',
                          style: AppTextStyles.caption.copyWith(
                            color: textSecondary,
                            fontSize: 10,
                          ),
                        ),
                      if (v.maxStock != null)
                        Text(
                          'Max: ${v.maxStock}',
                          style: AppTextStyles.caption.copyWith(
                            color: textSecondary,
                            fontSize: 10,
                          ),
                        ),
                    ],
                  ),
                ],
              ],
            ),
          ),

          // Infos commerce de gros (si présentes)
          if (v.wholesaleUnit != null || v.minOrderQuantity != null || v.unitsPerPackage != null) ...[
            Divider(
              height: AppSpacing.s24,
              color: border,
              indent: AppSpacing.s16,
              endIndent: AppSpacing.s16,
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.s16, 0, AppSpacing.s16, AppSpacing.s14,
              ),
              child: Wrap(
                spacing: AppSpacing.s12,
                runSpacing: AppSpacing.s8,
                children: [
                  if (v.wholesaleUnit != null)
                    _WholesaleChip(
                      isDark: isDark,
                      icon: Symbols.straighten,
                      label: 'Unité: ${v.wholesaleUnit}',
                    ),
                  if (v.minOrderQuantity != null)
                    _WholesaleChip(
                      isDark: isDark,
                      icon: Symbols.shopping_cart,
                      label: 'MOQ: ${v.minOrderQuantity}',
                    ),
                  if (v.unitsPerPackage != null)
                    _WholesaleChip(
                      isDark: isDark,
                      icon: Symbols.workspaces,
                      label: '${v.unitsPerPackage} u/colis',
                    ),
                ],
              ),
            ),
          ] else
            const SizedBox(height: AppSpacing.s14),
        ],
      ),
    );
  }
}

class _WholesaleChip extends StatelessWidget {
  const _WholesaleChip({
    required this.isDark,
    required this.icon,
    required this.label,
  });

  final bool isDark;
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.s8,
        vertical: AppSpacing.s4,
      ),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface2 : AppColors.gray50,
        borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
        border: Border.all(
          color: isDark ? AppColors.darkBorder2 : AppColors.gray200,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: AppColors.primary),
          const SizedBox(width: 4),
          Text(
            label,
            style: AppTextStyles.caption.copyWith(
              color: isDark ? AppColors.gray400 : AppColors.gray600,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Barre d'actions ──────────────────────────────────────────────────────────

class _ActionsBar extends ConsumerStatefulWidget {
  const _ActionsBar({
    required this.product,
    required this.isDark,
    required this.border,
    required this.surface,
    required this.textPrimary,
    required this.routePrefix,
    this.showRestockAction = false,
  });

  final Product product;
  final bool isDark;
  final Color border;
  final Color surface;
  final Color textPrimary;
  final String routePrefix;
  final bool showRestockAction;

  @override
  ConsumerState<_ActionsBar> createState() => _ActionsBarState();
}

class _ActionsBarState extends ConsumerState<_ActionsBar> {
  bool _toggling = false;

  Future<void> _toggleActive() async {
    setState(() => _toggling = true);
    try {
      final repo = ref.read(productRepositoryProvider);
      if (widget.product.isActive) {
        await repo.deactivate(widget.product.id);
      } else {
        await repo.activate(widget.product.id);
      }
      ref.invalidate(productDetailProvider(widget.product.id));
      ref.invalidate(productsNotifierProvider);
      if (mounted) {
        context.showSnack(
          widget.product.isActive ? 'Produit désactivé' : 'Produit activé',
          type: SnackType.success,
        );
      }
    } catch (e) {
      if (mounted) context.showSnack(e.toString(), type: SnackType.error);
    } finally {
      if (mounted) setState(() => _toggling = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isActive = widget.product.isActive;
    final toggleColor = isActive ? AppColors.warning : AppColors.success;
    final toggleLabel = isActive ? 'Désactiver' : 'Activer';
    final toggleIcon = isActive ? Symbols.visibility_off : Symbols.visibility;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Divider(height: 1, color: widget.border),
        const SizedBox(height: AppSpacing.s16),
        Text(
          'Actions',
          style: AppTextStyles.label.copyWith(
            color: widget.textPrimary,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: AppSpacing.s10),
        Row(
          children: [
            // Modifier
            Expanded(
              child: FilledButton.icon(
                onPressed: () =>
                    context.push('${widget.routePrefix}/${widget.product.id}/edit'),
                icon: const Icon(Symbols.edit, size: 16),
                label: const Text('Modifier'),
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.white,
                  minimumSize: const Size(0, 48),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
                  ),
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.s10),
            // Activer/Désactiver
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _toggling ? null : _toggleActive,
                icon: _toggling
                    ? SizedBox(
                        width: 14,
                        height: 14,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: toggleColor,
                        ),
                      )
                    : Icon(toggleIcon, size: 16),
                label: Text(toggleLabel),
                style: OutlinedButton.styleFrom(
                  foregroundColor: toggleColor,
                  side: BorderSide(color: toggleColor.withValues(alpha: 0.6)),
                  minimumSize: const Size(0, 48),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
                  ),
                ),
              ),
            ),
          ],
        ),
        if (widget.showRestockAction) ...[
          const SizedBox(height: AppSpacing.s10),
          FilledButton.tonal(
            onPressed: () => context.push(
              '/shop/search',
              extra: {'query': widget.product.title},
            ),
            style: FilledButton.styleFrom(
              minimumSize: const Size(double.infinity, 48),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
              ),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Symbols.shopping_cart, size: 16),
                SizedBox(width: AppSpacing.s8),
                Text('Réapprovisionner chez un producteur'),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

// ─── Menu "..." (supprimer) ───────────────────────────────────────────────────

class _MoreMenu extends ConsumerWidget {
  const _MoreMenu({required this.product, required this.isDark});
  final Product product;
  final bool isDark;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return PopupMenuButton<String>(
      icon: Icon(
        Symbols.more_vert,
        color: isDark ? AppColors.gray400 : AppColors.gray600,
      ),
      color: isDark ? AppColors.darkSurface : AppColors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
        side: BorderSide(color: isDark ? AppColors.darkBorder : AppColors.gray200),
      ),
      onSelected: (value) async {
        if (value == 'delete') {
          final confirm = await showDialog<bool>(
            context: context,
            builder: (ctx) => AlertDialog(
              backgroundColor: isDark ? AppColors.darkSurface : AppColors.white,
              title: const Text('Supprimer le produit'),
              content: Text(
                'Supprimer "${product.title}" ? Cette action est irréversible.',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(ctx).pop(false),
                  child: const Text('Annuler'),
                ),
                TextButton(
                  onPressed: () => Navigator.of(ctx).pop(true),
                  style: TextButton.styleFrom(foregroundColor: AppColors.error),
                  child: const Text('Supprimer'),
                ),
              ],
            ),
          );
          if (confirm == true) {
            try {
              await ref.read(productRepositoryProvider).deleteProduct(product.id);
              ref.invalidate(productsNotifierProvider);
              if (context.mounted) {
                context.showSnack('Produit supprimé', type: SnackType.success);
                context.pop();
              }
            } catch (e) {
              if (context.mounted) {
                context.showSnack(e.toString(), type: SnackType.error);
              }
            }
          }
        }
      },
      itemBuilder: (_) => [
        PopupMenuItem(
          value: 'delete',
          child: Row(
            children: [
              const Icon(Symbols.delete_outline, size: 18, color: AppColors.error),
              const SizedBox(width: AppSpacing.s8),
              Text(
                'Supprimer',
                style: AppTextStyles.body.copyWith(color: AppColors.error),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ─── Carte info générique ─────────────────────────────────────────────────────

class _InfoCard extends StatelessWidget {
  const _InfoCard({
    required this.isDark,
    required this.surface,
    required this.border,
    required this.child,
  });

  final bool isDark;
  final Color surface;
  final Color border;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.s16),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLarge),
        border: Border.all(color: border),
      ),
      child: child,
    );
  }
}

// ─── Stat stock ───────────────────────────────────────────────────────────────

class _StockStat extends StatelessWidget {
  const _StockStat({
    required this.isDark,
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  final bool isDark;
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final textPrimary = isDark ? AppColors.gray100 : AppColors.gray900;
    final textSecondary = isDark ? AppColors.gray500 : AppColors.gray400;

    return Expanded(
      child: Column(
        children: [
          Icon(icon, size: 20, color: color),
          const SizedBox(height: AppSpacing.s4),
          Text(
            value,
            style: AppTextStyles.label.copyWith(
              color: textPrimary,
              fontWeight: FontWeight.w700,
            ),
            textAlign: TextAlign.center,
          ),
          Text(
            label,
            style: AppTextStyles.caption.copyWith(color: textSecondary, fontSize: 10),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

// ─── Loading ──────────────────────────────────────────────────────────────────

class _LoadingDetail extends StatelessWidget {
  const _LoadingDetail({required this.isDark});
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.zero,
      children: [
        const ShimmerBox(height: 280, borderRadius: 0),
        Padding(
          padding: const EdgeInsets.all(AppSpacing.s16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              ShimmerBox(height: 28, borderRadius: AppSpacing.radiusMedium),
              SizedBox(height: AppSpacing.s12),
              ShimmerBox(width: 120, height: 20, borderRadius: AppSpacing.radiusPill),
              SizedBox(height: AppSpacing.s16),
              ShimmerBox(height: 80, borderRadius: AppSpacing.radiusLarge),
              SizedBox(height: AppSpacing.s16),
              ShimmerBox(height: 120, borderRadius: AppSpacing.radiusLarge),
              SizedBox(height: AppSpacing.s16),
              ShimmerBox(height: 160, borderRadius: AppSpacing.radiusLarge),
            ],
          ),
        ),
      ],
    );
  }
}

// ─── Erreur ───────────────────────────────────────────────────────────────────

class _ErrorView extends StatelessWidget {
  const _ErrorView({
    required this.isDark,
    required this.message,
    required this.onRetry,
  });

  final bool isDark;
  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final textSecondary = isDark ? AppColors.gray500 : AppColors.gray400;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.s32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Symbols.error_outline,
              size: 48,
              color: AppColors.error.withValues(alpha: 0.6),
            ),
            const SizedBox(height: AppSpacing.s16),
            Text(
              'Impossible de charger ce produit',
              style: AppTextStyles.sectionTitle.copyWith(
                color: isDark ? AppColors.gray100 : AppColors.gray900,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.s8),
            Text(
              message,
              style: AppTextStyles.caption.copyWith(color: textSecondary),
              textAlign: TextAlign.center,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: AppSpacing.s24),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Symbols.refresh, size: 16),
              label: const Text('Réessayer'),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
