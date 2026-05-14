import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:banabana_b2b/core/api/api_client.dart';
import 'package:banabana_b2b/features/producer/data/category_repository.dart';
import 'package:banabana_b2b/features/wholesaler/data/catalog_repository.dart';
import 'package:banabana_b2b/shared/models/catalog_item.dart';
import 'package:banabana_b2b/shared/models/category.dart';

/// Global categories from /v1/categories for shop display and filtering.
final shopCategoriesProvider = FutureProvider<List<Category>>((ref) async {
  try {
    final repo = CategoryRepository(ref.watch(apiClientProvider));
    final cats = await repo.getAll();
    if (cats.isNotEmpty) return cats;
  } catch (_) {}
  return [];
});

final catalogRepositoryProvider = Provider<CatalogRepository>((ref) {
  return CatalogRepository(ref.watch(apiClientProvider));
});

final catalogCategoriesProvider = FutureProvider<List<String>>((ref) {
  return ref.watch(catalogRepositoryProvider).getCategories();
});

class CatalogSearchParams {
  final String q;
  final String? category;
  final double? priceMin;
  final double? priceMax;
  final bool inStockOnly;
  final String? sortBy;
  final int page;

  const CatalogSearchParams({
    this.q = '',
    this.category,
    this.priceMin,
    this.priceMax,
    this.inStockOnly = false,
    this.sortBy,
    this.page = 1,
  });

  CatalogSearchParams copyWith({
    String? q,
    Object? category = const _Sentinel(),
    Object? priceMin = const _Sentinel(),
    Object? priceMax = const _Sentinel(),
    bool? inStockOnly,
    Object? sortBy = const _Sentinel(),
    int? page,
  }) {
    return CatalogSearchParams(
      q: q ?? this.q,
      category: category is _Sentinel ? this.category : category as String?,
      priceMin: priceMin is _Sentinel ? this.priceMin : priceMin as double?,
      priceMax: priceMax is _Sentinel ? this.priceMax : priceMax as double?,
      inStockOnly: inStockOnly ?? this.inStockOnly,
      sortBy: sortBy is _Sentinel ? this.sortBy : sortBy as String?,
      page: page ?? this.page,
    );
  }
}

class _Sentinel {
  const _Sentinel();
}

final catalogSearchParamsProvider =
    StateProvider<CatalogSearchParams>((ref) => const CatalogSearchParams());

/// Maps a [sortBy] string from the filter sheet to repository sort/order args.
(String sort, String order) _mapSortBy(String? sortBy) {
  switch (sortBy) {
    case 'price_asc':
      return ('price', 'asc');
    case 'price_desc':
      return ('price', 'desc');
    case 'newest':
      return ('createdAt', 'desc');
    default:
      return ('createdAt', 'desc');
  }
}

final catalogResultProvider = FutureProvider<CatalogResult>((ref) {
  final params = ref.watch(catalogSearchParamsProvider);
  final (sort, order) = _mapSortBy(params.sortBy);
  return ref.watch(catalogRepositoryProvider).search(
        q: params.q,
        category: params.category,
        priceMin: params.priceMin,
        priceMax: params.priceMax,
        availability: params.inStockOnly ? true : null,
        page: params.page,
        sort: sort,
        order: order,
      );
});

/// Dedicated search — used by the search screen only.
/// FutureProvider.family keyed by query string, bypasses the shared params state.
final catalogSearchProvider =
    FutureProvider.family<CatalogResult, String>((ref, q) async {
  if (q.trim().isEmpty) {
    return CatalogResult(
      data: const [],
      pagination: CatalogPagination(page: 1, limit: 20, total: 0, pages: 1),
    );
  }
  return ref.watch(catalogRepositoryProvider).search(
        q: q,
        page: 1,
        sort: 'createdAt',
        order: 'desc',
      );
});
