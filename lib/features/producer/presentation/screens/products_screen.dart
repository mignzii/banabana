import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:banabana_b2b/core/theme/app_colors.dart';
import 'package:banabana_b2b/core/theme/app_spacing.dart';
import 'package:banabana_b2b/core/theme/app_text_styles.dart';
import 'package:banabana_b2b/features/producer/providers/product_providers.dart';
import 'package:banabana_b2b/shared/models/product.dart';
import 'package:banabana_b2b/shared/widgets/product_card.dart';
import 'package:banabana_b2b/shared/widgets/loading_shimmer.dart';

enum _Filter { all, active, inactive }

class ProductsScreen extends ConsumerStatefulWidget {
  const ProductsScreen({super.key});

  @override
  ConsumerState<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends ConsumerState<ProductsScreen>
    with SingleTickerProviderStateMixin {
  final _searchController = TextEditingController();
  final _searchFocus = FocusNode();
  bool _showSearch = false;
  _Filter _filter = _Filter.all;
  String _query = '';

  late final AnimationController _searchAnim;
  late final Animation<double> _searchHeight;

  @override
  void initState() {
    super.initState();
    _searchAnim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 220),
    );
    _searchHeight = CurvedAnimation(parent: _searchAnim, curve: Curves.easeOut);
    _searchController.addListener(() {
      setState(() => _query = _searchController.text.trim().toLowerCase());
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocus.dispose();
    _searchAnim.dispose();
    super.dispose();
  }

  void _toggleSearch() {
    setState(() => _showSearch = !_showSearch);
    if (_showSearch) {
      _searchAnim.forward();
      Future.delayed(const Duration(milliseconds: 100), () {
        if (mounted) _searchFocus.requestFocus();
      });
    } else {
      _searchAnim.reverse();
      _searchController.clear();
      _searchFocus.unfocus();
    }
  }

  List<Product> _applyFilters(List<Product> all) {
    var list = all;
    if (_filter == _Filter.active) list = list.where((p) => p.isActive).toList();
    if (_filter == _Filter.inactive) list = list.where((p) => !p.isActive).toList();
    if (_query.isNotEmpty) {
      list = list.where((p) => p.title.toLowerCase().contains(_query)).toList();
    }
    return list;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final productsAsync = ref.watch(productsNotifierProvider);

    final bg = isDark ? AppColors.darkBg : AppColors.gray50;
    final surface = isDark ? AppColors.darkSurface : AppColors.white;
    final border = isDark ? AppColors.darkBorder : AppColors.gray100;
    final textPrimary = isDark ? AppColors.gray100 : AppColors.gray900;
    final textSecondary = isDark ? AppColors.gray500 : AppColors.gray400;

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: isDark ? AppColors.darkBg : AppColors.white,
        elevation: 0,
        titleSpacing: AppSpacing.s16,
        title: productsAsync.maybeWhen(
          data: (products) => Row(
            children: [
              Text(
                'Mes produits',
                style: AppTextStyles.sectionTitle.copyWith(color: textPrimary),
              ),
              const SizedBox(width: AppSpacing.s8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.s8,
                  vertical: 2,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
                ),
                child: Text(
                  '${products.length}',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          orElse: () => Text(
            'Mes produits',
            style: AppTextStyles.sectionTitle.copyWith(color: textPrimary),
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              _showSearch ? Symbols.search_off : Symbols.search,
              color: _showSearch ? AppColors.primary : textSecondary,
            ),
            onPressed: _toggleSearch,
          ),
          IconButton(
            icon: const Icon(Symbols.add_circle, color: AppColors.primary),
            onPressed: () => context.push('/producer/products/new'),
          ),
          const SizedBox(width: AppSpacing.s4),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Divider(height: 1, color: border),
        ),
      ),
      body: Column(
        children: [
          // Search bar animée
          SizeTransition(
            sizeFactor: _searchHeight,
            child: _SearchBar(
              controller: _searchController,
              focusNode: _searchFocus,
              isDark: isDark,
              border: border,
              onClear: () {
                _searchController.clear();
                _searchFocus.requestFocus();
              },
            ),
          ),

          // Contenu principal
          Expanded(
            child: productsAsync.when(
              loading: () => _LoadingGrid(isDark: isDark),
              error: (e, _) => _ErrorView(
                isDark: isDark,
                message: e.toString(),
                onRetry: () => ref.read(productsNotifierProvider.notifier).load(),
              ),
              data: (allProducts) {
                final activeCount = allProducts.where((p) => p.isActive).length;
                final inactiveCount = allProducts.length - activeCount;
                final filtered = _applyFilters(allProducts);

                return Column(
                  children: [
                    // Stats + filtres
                    _FiltersBar(
                      isDark: isDark,
                      surface: surface,
                      border: border,
                      textPrimary: textPrimary,
                      textSecondary: textSecondary,
                      total: allProducts.length,
                      activeCount: activeCount,
                      inactiveCount: inactiveCount,
                      selected: _filter,
                      onSelect: (f) => setState(() => _filter = f),
                    ),

                    // Grille produits
                    Expanded(
                      child: filtered.isEmpty
                          ? _EmptyView(
                              isDark: isDark,
                              textPrimary: textPrimary,
                              textSecondary: textSecondary,
                              isFiltered: _query.isNotEmpty || _filter != _Filter.all,
                              onAdd: () => context.push('/producer/products/new'),
                              onReset: () {
                                setState(() {
                                  _filter = _Filter.all;
                                  _searchController.clear();
                                });
                              },
                            )
                          : GridView.builder(
                              padding: const EdgeInsets.fromLTRB(
                                AppSpacing.s16,
                                AppSpacing.s16,
                                AppSpacing.s16,
                                AppSpacing.s96,
                              ),
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                crossAxisSpacing: AppSpacing.s12,
                                mainAxisSpacing: AppSpacing.s12,
                                childAspectRatio: 0.68,
                              ),
                              itemCount: filtered.length,
                              itemBuilder: (context, i) {
                                final p = filtered[i];
                                return ProductCard(
                                  key: ValueKey(p.id),
                                  product: p,
                                  onTap: () =>
                                      context.push('/producer/products/${p.id}'),
                                  onEdit: () => context
                                      .push('/producer/products/${p.id}/edit'),
                                );
                              },
                            ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/producer/products/new'),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
        elevation: 3,
        icon: const Icon(Symbols.add, size: 20),
        label: Text(
          'Nouveau produit',
          style: AppTextStyles.label.copyWith(
            color: AppColors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

// ─── Barre de recherche animée ───────────────────────────────────────────────

class _SearchBar extends StatelessWidget {
  const _SearchBar({
    required this.controller,
    required this.focusNode,
    required this.isDark,
    required this.border,
    required this.onClear,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final bool isDark;
  final Color border;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: isDark ? AppColors.darkBg : AppColors.white,
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.s16,
        AppSpacing.s8,
        AppSpacing.s16,
        AppSpacing.s12,
      ),
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        style: AppTextStyles.body.copyWith(
          color: isDark ? AppColors.gray100 : AppColors.gray900,
        ),
        decoration: InputDecoration(
          hintText: 'Rechercher un produit…',
          hintStyle: AppTextStyles.body.copyWith(
            color: isDark ? AppColors.gray600 : AppColors.gray400,
          ),
          prefixIcon: Icon(
            Symbols.search,
            size: 18,
            color: isDark ? AppColors.gray500 : AppColors.gray400,
          ),
          suffixIcon: controller.text.isNotEmpty
              ? IconButton(
                  icon: Icon(
                    Symbols.close,
                    size: 16,
                    color: isDark ? AppColors.gray500 : AppColors.gray400,
                  ),
                  onPressed: onClear,
                )
              : null,
          filled: true,
          fillColor: isDark ? AppColors.darkSurface : AppColors.gray50,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
            borderSide: BorderSide(color: border),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
            borderSide: BorderSide(color: border),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
            borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
          ),
          contentPadding: const EdgeInsets.symmetric(vertical: AppSpacing.s12),
          isDense: true,
        ),
      ),
    );
  }
}

// ─── Filtres + stats ─────────────────────────────────────────────────────────

class _FiltersBar extends StatelessWidget {
  const _FiltersBar({
    required this.isDark,
    required this.surface,
    required this.border,
    required this.textPrimary,
    required this.textSecondary,
    required this.total,
    required this.activeCount,
    required this.inactiveCount,
    required this.selected,
    required this.onSelect,
  });

  final bool isDark;
  final Color surface;
  final Color border;
  final Color textPrimary;
  final Color textSecondary;
  final int total;
  final int activeCount;
  final int inactiveCount;
  final _Filter selected;
  final ValueChanged<_Filter> onSelect;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: isDark ? AppColors.darkBg : AppColors.white,
      child: Column(
        children: [
          // Chips filtres
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.s16,
              AppSpacing.s12,
              AppSpacing.s16,
              AppSpacing.s4,
            ),
            child: Row(
              children: [
                _FilterChip(
                  label: 'Tous',
                  count: total,
                  isSelected: selected == _Filter.all,
                  isDark: isDark,
                  color: AppColors.primary,
                  onTap: () => onSelect(_Filter.all),
                ),
                const SizedBox(width: AppSpacing.s8),
                _FilterChip(
                  label: 'Actifs',
                  count: activeCount,
                  isSelected: selected == _Filter.active,
                  isDark: isDark,
                  color: AppColors.success,
                  onTap: () => onSelect(_Filter.active),
                ),
                const SizedBox(width: AppSpacing.s8),
                _FilterChip(
                  label: 'Inactifs',
                  count: inactiveCount,
                  isSelected: selected == _Filter.inactive,
                  isDark: isDark,
                  color: AppColors.gray400,
                  onTap: () => onSelect(_Filter.inactive),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.s8),
          Divider(height: 1, color: border),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.count,
    required this.isSelected,
    required this.isDark,
    required this.color,
    required this.onTap,
  });

  final String label;
  final int count;
  final bool isSelected;
  final bool isDark;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final bg = isSelected
        ? color.withValues(alpha: 0.15)
        : (isDark ? AppColors.darkSurface : AppColors.gray50);
    final fg = isSelected ? color : (isDark ? AppColors.gray400 : AppColors.gray500);
    final borderColor = isSelected
        ? color.withValues(alpha: 0.4)
        : (isDark ? AppColors.darkBorder : AppColors.gray200);

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.s12,
          vertical: AppSpacing.s6,
        ),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
          border: Border.all(color: borderColor),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: AppTextStyles.label.copyWith(
                color: fg,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
            const SizedBox(width: AppSpacing.s6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
              decoration: BoxDecoration(
                color: isSelected ? color.withValues(alpha: 0.2) : fg.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
              ),
              child: Text(
                '$count',
                style: AppTextStyles.caption.copyWith(
                  color: fg,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Loading grid ─────────────────────────────────────────────────────────────

class _LoadingGrid extends StatelessWidget {
  const _LoadingGrid({required this.isDark});
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.all(AppSpacing.s16),
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: AppSpacing.s12,
        mainAxisSpacing: AppSpacing.s12,
        childAspectRatio: 0.68,
      ),
      itemCount: 6,
      itemBuilder: (_, __) => const ProductCardShimmer(),
    );
  }
}

// ─── Empty state ──────────────────────────────────────────────────────────────

class _EmptyView extends StatelessWidget {
  const _EmptyView({
    required this.isDark,
    required this.textPrimary,
    required this.textSecondary,
    required this.isFiltered,
    required this.onAdd,
    required this.onReset,
  });

  final bool isDark;
  final Color textPrimary;
  final Color textSecondary;
  final bool isFiltered;
  final VoidCallback onAdd;
  final VoidCallback onReset;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.s32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                isFiltered ? Symbols.search_off : Symbols.inventory_2,
                size: 32,
                color: AppColors.primary.withValues(alpha: 0.7),
              ),
            ),
            const SizedBox(height: AppSpacing.s16),
            Text(
              isFiltered ? 'Aucun résultat' : 'Aucun produit',
              style: AppTextStyles.screenTitle.copyWith(color: textPrimary),
            ),
            const SizedBox(height: AppSpacing.s8),
            Text(
              isFiltered
                  ? 'Aucun produit ne correspond à votre recherche.'
                  : 'Ajoutez votre premier produit pour commencer à vendre.',
              style: AppTextStyles.bodySecondary.copyWith(color: textSecondary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.s24),
            if (isFiltered)
              OutlinedButton.icon(
                onPressed: onReset,
                icon: const Icon(Symbols.filter_alt_off, size: 16),
                label: const Text('Réinitialiser les filtres'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  side: const BorderSide(color: AppColors.primary),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
                  ),
                ),
              )
            else
              FilledButton.icon(
                onPressed: onAdd,
                icon: const Icon(Symbols.add, size: 16),
                label: const Text('Ajouter un produit'),
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ─── Error state ──────────────────────────────────────────────────────────────

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
            Icon(Symbols.error_outline, size: 48, color: AppColors.error.withValues(alpha: 0.6)),
            const SizedBox(height: AppSpacing.s16),
            Text(
              'Une erreur est survenue',
              style: AppTextStyles.sectionTitle.copyWith(
                color: isDark ? AppColors.gray100 : AppColors.gray900,
              ),
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
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
