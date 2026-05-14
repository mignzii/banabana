import 'package:dio/dio.dart';
import 'package:banabana_b2b/shared/models/product.dart';

class ProductRepository {
  final Dio _dio;
  ProductRepository(this._dio);

  Future<List<Product>> getMyProducts() async {
    final response = await _dio.get('/products/my-products');
    final List data = response.data as List;
    return data.map((e) => Product.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<Product> getProduct(String id) async {
    final response = await _dio.get('/products/$id');
    return Product.fromJson(response.data as Map<String, dynamic>);
  }

  Future<Product> createProduct({
    required String title,
    required String category,
    String? description,
    required double basePrice,
  }) async {
    final response = await _dio.post('/products', data: {
      'title': title,
      'category': category,
      if (description != null) 'description': description,
      'basePrice': basePrice,
    });
    return Product.fromJson(response.data as Map<String, dynamic>);
  }

  Future<Product> updateProduct(String id, Map<String, dynamic> fields) async {
    final response = await _dio.patch('/products/$id', data: fields);
    return Product.fromJson(response.data as Map<String, dynamic>);
  }

  Future<void> uploadImages(String productId, List<String> filePaths) async {
    final files = await Future.wait(
      filePaths.map((p) => MultipartFile.fromFile(p)),
    );
    final formData = FormData.fromMap({'files': files});
    await _dio.post('/products/$productId/images', data: formData);
  }

  Future<void> deleteImage(String productId, String imageId) async {
    await _dio.delete('/products/$productId/images/$imageId');
  }

  Future<ProductVariant> createVariant(String productId, Map<String, dynamic> data) async {
    final response = await _dio.post('/products/$productId/variants', data: data);
    return ProductVariant.fromJson(response.data as Map<String, dynamic>);
  }

  Future<ProductVariant> updateVariant(String variantId, Map<String, dynamic> data) async {
    final response = await _dio.patch('/products/variants/$variantId', data: data);
    return ProductVariant.fromJson(response.data as Map<String, dynamic>);
  }

  Future<void> deleteVariant(String variantId) async {
    await _dio.delete('/products/variants/$variantId');
  }

  Future<void> activate(String id) => _dio.patch('/products/$id/activate');
  Future<void> deactivate(String id) => _dio.patch('/products/$id/deactivate');
  Future<void> deleteProduct(String id) => _dio.delete('/products/$id');

  Future<void> updateVariantStock(String variantId, int stock) async {
    await _dio.patch('/products/variants/$variantId/stock', data: {'stock': stock});
  }
}
