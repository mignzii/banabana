import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:banabana_b2b/core/api/api_client.dart';
import 'package:banabana_b2b/features/wholesaler/data/catalog_repository.dart';
import 'package:banabana_b2b/shared/models/catalog_item.dart';

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
  final int page;

  const CatalogSearchParams({
    this.q = '',
    this.category,
    this.priceMin,
    this.priceMax,
    this.page = 1,
  });

  CatalogSearchParams copyWith({
    String? q,
    Object? category = const _Sentinel(),
    Object? priceMin = const _Sentinel(),
    Object? priceMax = const _Sentinel(),
    int? page,
  }) {
    return CatalogSearchParams(
      q: q ?? this.q,
      category: category is _Sentinel ? this.category : category as String?,
      priceMin: priceMin is _Sentinel ? this.priceMin : priceMin as double?,
      priceMax: priceMax is _Sentinel ? this.priceMax : priceMax as double?,
      page: page ?? this.page,
    );
  }
}

class _Sentinel {
  const _Sentinel();
}

final catalogSearchParamsProvider =
    StateProvider<CatalogSearchParams>((ref) => const CatalogSearchParams());

final catalogResultProvider = FutureProvider<CatalogResult>((ref) {
  final params = ref.watch(catalogSearchParamsProvider);
  return ref.watch(catalogRepositoryProvider).search(
        q: params.q,
        category: params.category,
        priceMin: params.priceMin,
        priceMax: params.priceMax,
        page: params.page,
      );
});
