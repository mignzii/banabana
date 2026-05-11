import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:banabana_b2b/core/theme/app_colors.dart';
import 'package:banabana_b2b/features/wholesaler/providers/catalog_providers.dart';
import 'package:banabana_b2b/features/wholesaler/presentation/widgets/catalog_item_card.dart';
import 'package:banabana_b2b/features/wholesaler/presentation/widgets/filter_sheet.dart';
import 'package:banabana_b2b/features/wholesaler/presentation/widgets/cart_badge.dart';
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

  @override
  Widget build(BuildContext context) {
    final resultAsync = ref.watch(catalogResultProvider);
    final params = ref.watch(catalogSearchParamsProvider);

    return Scaffold(
      backgroundColor: AppColors.gray50,
      appBar: AppBar(
        title: const Text('Catalogue'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        actions: [
          CartBadge(
            child: IconButton(
              icon: const Icon(Icons.shopping_cart_outlined),
              onPressed: () => context.push('/shop/cart'),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchCtrl,
                    decoration: InputDecoration(
                      hintText: 'Rechercher un produit...',
                      prefixIcon: const Icon(Icons.search, color: AppColors.gray400),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    onSubmitted: (q) => ref
                        .read(catalogSearchParamsProvider.notifier)
                        .update((s) => s.copyWith(q: q, page: 1)),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: () => FilterSheet.show(context),
                  icon: Stack(
                    children: [
                      const Icon(Icons.tune, color: AppColors.primary),
                      if (params.category != null ||
                          params.priceMin != null ||
                          params.priceMax != null)
                        Positioned(
                          top: 0,
                          right: 0,
                          child: Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: AppColors.secondary,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (params.category != null)
            Padding(
              padding: const EdgeInsets.only(left: 12, bottom: 4),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Chip(
                  label: Text(params.category!),
                  deleteIcon: const Icon(Icons.close, size: 14),
                  onDeleted: () => ref
                      .read(catalogSearchParamsProvider.notifier)
                      .update((s) => s.copyWith(category: null, page: 1)),
                  backgroundColor: AppColors.primary.withValues(alpha: 0.12),
                ),
              ),
            ),
          Expanded(
            child: resultAsync.when(
              loading: () => GridView.builder(
                padding: const EdgeInsets.all(12),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 0.72,
                ),
                itemCount: 6,
                itemBuilder: (_, __) => const ShimmerBox(height: 200),
              ),
              error: (e, _) => ErrorStateWidget(
                message: e.toString(),
                onRetry: () => ref.invalidate(catalogResultProvider),
              ),
              data: (result) {
                if (result.data.isEmpty) {
                  return const EmptyStateWidget(
                    title: 'Aucun produit',
                    subtitle: 'Essayez d\'autres filtres.',
                  );
                }
                return RefreshIndicator(
                  color: AppColors.primary,
                  onRefresh: () async => ref.invalidate(catalogResultProvider),
                  child: GridView.builder(
                    padding: const EdgeInsets.all(12),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 0.72,
                    ),
                    itemCount: result.data.length,
                    itemBuilder: (_, i) {
                      final item = result.data[i];
                      return CatalogItemCard(
                        item: item,
                        onTap: () => context.push('/shop/product/${item.id}'),
                      );
                    },
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
