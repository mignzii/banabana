import 'package:dio/dio.dart';
import 'package:banabana_b2b/shared/models/inventory.dart';

class InventoryRepository {
  final Dio _dio;
  InventoryRepository(this._dio);

  Future<List<Inventory>> getAll() async {
    final response = await _dio.get('/inventory');
    final List data = response.data as List;
    return data.map((e) => Inventory.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<List<StockMovement>> getMovements({String? startDate, String? endDate}) async {
    final response = await _dio.get('/inventory/movements', queryParameters: {
      if (startDate != null) 'startDate': startDate,
      if (endDate != null) 'endDate': endDate,
    });
    final List data = response.data as List;
    return data.map((e) => StockMovement.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<void> recordMovement({
    required String variantId,
    required MovementType type,
    required int quantity,
    String? reason,
    String? notes,
  }) async {
    await _dio.post('/inventory/movements', data: {
      'variantId': variantId,
      'type': type.name,
      'quantity': quantity,
      if (reason != null) 'reason': reason,
      if (notes != null) 'notes': notes,
    });
  }

  Future<List<Map<String, dynamic>>> getAlerts() async {
    final response = await _dio.get('/inventory/alerts');
    return List<Map<String, dynamic>>.from(response.data as List);
  }

  Future<void> acknowledgeAlert(String alertId) async {
    await _dio.patch('/inventory/alerts/$alertId/acknowledge');
  }
}
