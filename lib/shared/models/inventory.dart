import 'package:freezed_annotation/freezed_annotation.dart';

part 'inventory.freezed.dart';
part 'inventory.g.dart';

double? _parseDoubleNullable(dynamic v) =>
    v == null ? null : (v is String ? double.parse(v) : (v as num).toDouble());

int _parseInt(dynamic v) =>
    v is String ? int.parse(v) : (v as num).toInt();

enum MovementType {
  @JsonValue('in') stockIn,
  @JsonValue('out') stockOut,
  @JsonValue('adjustment') adjustment,
  @JsonValue('damage') damage,
  @JsonValue('return') stockReturn,
}

@freezed
class Inventory with _$Inventory {
  const factory Inventory({
    required String id,
    required String variantId,
    required String userId,
    String? location,
    String? warehouse,
    String? zone,
    String? shelf,
    @JsonKey(fromJson: _parseDoubleNullable) double? costPrice,
    @JsonKey(fromJson: _parseDoubleNullable) double? totalValue,
    DateTime? lastCountDate,
    String? notes,
  }) = _Inventory;

  factory Inventory.fromJson(Map<String, dynamic> json) =>
      _$InventoryFromJson(json);
}

@freezed
class StockMovement with _$StockMovement {
  const factory StockMovement({
    required String id,
    required String variantId,
    required MovementType type,
    @JsonKey(fromJson: _parseInt) required int quantity,
    @JsonKey(fromJson: _parseInt) required int previousStock,
    @JsonKey(fromJson: _parseInt) required int newStock,
    String? reason,
    String? notes,
    String? userId,
    String? orderId,
    required DateTime createdAt,
  }) = _StockMovement;

  factory StockMovement.fromJson(Map<String, dynamic> json) =>
      _$StockMovementFromJson(json);
}
