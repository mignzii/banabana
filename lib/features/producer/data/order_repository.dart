import 'package:dio/dio.dart';
import 'package:banabana_b2b/shared/models/order.dart';

class OrderRepository {
  final Dio _dio;
  OrderRepository(this._dio);

  Future<List<Order>> getMyOrders() async {
    final response = await _dio.get('/orders/producer/my-orders');
    final List data = response.data as List;
    return data.map((e) => Order.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<Order> getOrder(String id) async {
    final response = await _dio.get('/orders/producer/$id');
    return Order.fromJson(response.data as Map<String, dynamic>);
  }

  Future<void> accept(String id) => _dio.patch('/orders/producer/$id/accept');

  Future<void> reject(String id, String reason) =>
      _dio.patch('/orders/producer/$id/reject', data: {'reason': reason});

  Future<void> ship(String id, Map<String, dynamic> shipData) =>
      _dio.patch('/orders/producer/$id/ship', data: shipData);
}
