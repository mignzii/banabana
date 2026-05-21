import 'package:dio/dio.dart';
import 'package:banabana_b2b/shared/models/order.dart';

class WholesalerOrderRepository {
  final Dio _dio;
  WholesalerOrderRepository(this._dio);

  Future<List<Order>> getMyOrders() async {
    final response = await _dio.get('/orders/my-orders');
    final List data = response.data as List;
    return data.map((e) => Order.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<Order> getOrder(String id) async {
    final response = await _dio.get('/orders/$id');
    return Order.fromJson(response.data as Map<String, dynamic>);
  }

  Future<List<Order>> createOrder(
    List<Map<String, dynamic>> items, {
    String? deliveryAddress,
    String? deliveryName,
    String? deliveryPhone,
    String? notes,
    String? paymentMethod,
  }) async {
    final response = await _dio.post('/orders', data: {
      'items': items,
      if (deliveryAddress != null) 'deliveryAddress': deliveryAddress,
      if (deliveryName != null) 'deliveryName': deliveryName,
      if (deliveryPhone != null) 'deliveryPhone': deliveryPhone,
      if (notes != null && notes.isNotEmpty) 'notes': notes,
      if (paymentMethod != null) 'paymentMethod': paymentMethod,
    });
    final List data = response.data as List;
    return data.map((e) => Order.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<void> cancel(String id) => _dio.patch('/orders/$id/cancel');
}
