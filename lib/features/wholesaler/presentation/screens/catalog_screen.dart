import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:banabana_b2b/core/theme/app_colors.dart';
import 'package:banabana_b2b/core/theme/app_spacing.dart';
import 'package:banabana_b2b/core/theme/app_text_styles.dart';
import 'package:banabana_b2b/features/wholesaler/providers/cart_providers.dart';
import 'package:banabana_b2b/features/wholesaler/providers/catalog_providers.dart';
import 'package:banabana_b2b/features/wholesaler/presentation/widgets/catalog_item_card.dart';
import 'package:banabana_b2b/features/wholesaler/presentation/widgets/filter_sheet.dart';
import 'package:banabana_b2b/shared/widgets/empty_state_widget.dart';
import 'package:banabana_b2b/shared/widgets/error_state_widget.dart';
import 'package:banabana_b2b/shared/widgets/loading_shimmer.dart';

class CatalogScreen extends ConsumerStatefulWidget {
  const CatalogScreen({super.key});

  @override
  ConsumerState<CatalogScreen> createState() => _CatalogScreenState();
}

class _CatalogScreenState extends ConsumerState<CatalogScreen> {
  final _searchCtrl = TextEditingController();

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  void _onSearch(String q) => ref
      .read(catalogSearchParamsProvider.notifier)
      .update((s) => s.copyWith(q: q.isEmpty ? null : q, page: 1));

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cartCount = ref.watch(cartItemCountProvider);
    final resultAsync = ref.watch(catalogResultProvider);
    final params = ref.watch(catalogSearchParamsProvider);
    final hasFilters = params.category != null ||
        params.priceMin != null ||
        params.priceMax != null;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBg : AppColors.gray50,
      appBar: AppBar(
        backgroundColor: isDark ? AppColors.darkBg : AppColors.white,
        title: Text(
          'Catalogue',
          style: AppTextStyles.sectionTitle.copyWith(
            color: isDark ? AppColors.white : AppColors.gray900,
          ),
        ),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Symbols.search, size: 22),
            color: isDark ? AppColors.gray100 : AppColors.gray900,
            onPressed: () => context.push('/shop/search'),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: Stack(
              alignment: Alignment.center,
              children: [
                IconButton(
                  icon: const Icon(Symbols.shopping_cart, size: 22),
                  color: isDark ? AppColors.gray100 : AppColors.gray900,
                  onPressed: () => context.push('/shop/cart'),
                ),
                if (cartCount > 0)
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      width: 16,
                      height: 16,
                      decoration: const BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        cartCount > 9 ? '9+' : '$cartCount',
                        style: const TextStyle(
                          color: AppColors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            color: isDark ? AppColors.darkBg : AppColors.white,
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.s16,
              AppSpacing.s8,
              AppSpacing.s16,
              AppSpacing.s12,
            ),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    height: 44,
                    decoration: BoxDecoration(
                      color: isDark
                          ? AppColors.darkSurface2
                          : AppColors.gray100,
                      borderRadius:
                          BorderRadius.circular(AppSpacing.radiusMedium),
                    ),
                    child: TextField(
                      controller: _searchCtrl,
                      style: AppTextStyles.body.copyWith(
                        color: isDark
                            ? AppColors.gray100
                            : AppColors.gray900,
                        height: 1.0,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Rechercher un produit...',
                        hintStyle: AppTextStyles.bodySecondary.copyWith(
                          color: isDark
                              ? AppColors.gray600
                              : AppColors.gray400,
                        ),
                        prefixIcon: const Icon(
                          Symbols.search,
                          color: AppColors.primary,
                          size: 20,
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: AppSpacing.s12,
                        ),
                        isDense: true,
                      ),
                      onSubmitted: _onSearch,
                      textInputAction: TextInputAction.search,
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.s8),
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () => FilterSheet.show(context),
                    borderRadius:
                        BorderRadius.circular(AppSpacing.radiusMedium),
                    child: Ink(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: hasFilters
                            ? AppColors.primary.withValues(alpha: 0.1)
                            : (isDark
                                ? AppColors.darkSurface2
                                : AppColors.gray100),
                        borderRadius: BorderRadius.circular(
                            AppSpacing.radiusMedium),
                        border: hasFilters
                            ? Border.all(
                                color: AppColors.primary, width: 1.5)
                            : null,
                      ),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Icon(
                            Symbols.tune,
                            color: hasFilters
                                ? AppColors.primary
                                : (isDark
                                    ? AppColors.gray400
                                    : AppColors.gray500),
                            size: 20,
                          ),
                          if (hasFilters)
                            Positioned(
                              top: 6,
                              right: 6,
                              child: Container(
                                width: 8,
                                height: 8,
                                decoration: const BoxDecoration(
                                  color: AppColors.primary,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (params.category != null)
            Container(
              width: double.infinity,
              color: isDark ? AppColors.darkBg : AppColors.white,
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.s16,
                0,
                AppSpacing.s16,
                AppSpacing.s8,
              ),
              child: Chip(
                label: Text(
                  params.category!,
                  style: AppTextStyles.caption
                      .copyWith(color: AppColors.primary),
                ),
                deleteIcon: const Icon(Icons.close,
                    size: 14, color: AppColors.primary),
                onDeleted: () => ref
                    .read(catalogSearchParamsProvider.notifier)
                    .update((s) => s.copyWith(category: null, page: 1)),
                backgroundColor:
                    AppColors.primary.withValues(alpha: 0.10),
                side: const BorderSide(color: AppColors.primary, width: 1),
                padding: EdgeInsets.zero,
              ),
            ),
          Expanded(
            child: resultAsync.when(
              loading: () => GridView.builder(
                padding: const EdgeInsets.all(AppSpacing.s16),
                gridDelegate:
                    const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: AppSpacing.s12,
                  mainAxisSpacing: AppSpacing.s12,
                  childAspectRatio: 0.62,
                ),
                itemCount: 6,
                itemBuilder: (_, __) => const ProductCardShimmer(),
              ),
              error: (e, _) => ErrorStateWidget(
                message: e.toString(),
                onRetry: () => ref.invalidate(catalogResultProvider),
              ),
              data: (result) {
                if (result.data.isEmpty) {
                  return EmptyStateWidget(
                    icon: Symbols.search_off,
                    title: 'Aucun produit trouvé',
                    subtitle:
                        'Essayez d\'autres termes ou modifiez les filtres.',
                    ctaLabel: 'Modifier les filtres',
                    onCta: () => FilterSheet.show(context),
                  );
                }
                return RefreshIndicator(
                  color: AppColors.primary,
                  onRefresh: () async =>
                      ref.invalidate(catalogResultProvider),
                  child: GridView.builder(
                    padding: const EdgeInsets.all(AppSpacing.s16),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: AppSpacing.s12,
                      mainAxisSpacing: AppSpacing.s12,
                      childAspectRatio: 0.62,
                    ),
                    itemCount: result.data.length,
                    itemBuilder: (_, i) => CatalogItemCard(
                      item: result.data[i],
                      onTap: () => context
                          .push('/shop/product/${result.data[i].id}'),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
