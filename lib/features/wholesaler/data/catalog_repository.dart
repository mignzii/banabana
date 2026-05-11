import 'package:dio/dio.dart';
import 'package:banabana_b2b/shared/models/catalog_item.dart';

class CatalogRepository {
  final Dio _dio;
  CatalogRepository(this._dio);

  Future<List<String>> getCategories() async {
    final response = await _dio.get('/catalog/categories');
    return List<String>.from(response.data as List);
  }

  Future<CatalogResult> search({
    String? q,
    String? category,
    double? priceMin,
    double? priceMax,
    bool? availability,
    int page = 1,
    int limit = 20,
    String sort = 'createdAt',
    String order = 'desc',
  }) async {
    final response = await _dio.get('/catalog/search', queryParameters: {
      if (q != null && q.isNotEmpty) 'q': q,
      if (category != null) 'category': category,
      if (priceMin != null) 'priceMin': priceMin,
      if (priceMax != null) 'priceMax': priceMax,
      if (availability != null) 'availability': availability,
      'page': page,
      'limit': limit,
      'sort': sort,
      'order': order,
    });
    return CatalogResult.fromJson(response.data as Map<String, dynamic>);
  }
}
