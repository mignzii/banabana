import 'package:dio/dio.dart';
import 'package:banabana_b2b/shared/models/category.dart';

class CategoryRepository {
  final Dio _dio;
  CategoryRepository(this._dio);

  Future<List<Category>> getAll() async {
    final response = await _dio.get('/categories');
    final List data = response.data as List;
    return data
        .map((e) => Category.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<List<Category>> getMyCategories() async {
    final response = await _dio.get('/categories/my-categories');
    final List data = response.data as List;
    return data
        .map((e) => Category.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<Category> create({
    required String name,
    required String slug,
    String? icon,
    int order = 0,
  }) async {
    final response = await _dio.post('/categories', data: {
      'name': name,
      'slug': slug,
      if (icon != null) 'icon': icon,
      'order': order,
    });
    return Category.fromJson(response.data as Map<String, dynamic>);
  }

  Future<Category> update(
    String id, {
    required String name,
    required String slug,
    String? icon,
    int? order,
  }) async {
    final response = await _dio.patch('/categories/$id', data: {
      'name': name,
      'slug': slug,
      if (icon != null) 'icon': icon,
      if (order != null) 'order': order,
    });
    return Category.fromJson(response.data as Map<String, dynamic>);
  }

  Future<void> delete(String id) async {
    await _dio.delete('/categories/$id');
  }
}
