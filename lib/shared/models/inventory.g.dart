// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'inventory.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$InventoryImpl _$$InventoryImplFromJson(Map<String, dynamic> json) =>
    _$InventoryImpl(
      id: json['id'] as String,
      variantId: json['variantId'] as String,
      userId: json['userId'] as String,
      location: json['location'] as String?,
      warehouse: json['warehouse'] as String?,
      zone: json['zone'] as String?,
      shelf: json['shelf'] as String?,
      costPrice: _parseDoubleNullable(json['costPrice']),
      totalValue: _parseDoubleNullable(json['totalValue']),
      lastCountDate: json['lastCountDate'] == null
          ? null
          : DateTime.parse(json['lastCountDate'] as String),
      notes: json['notes'] as String?,
    );

Map<String, dynamic> _$$InventoryImplToJson(_$InventoryImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'variantId': instance.variantId,
      'userId': instance.userId,
      'location': instance.location,
      'warehouse': instance.warehouse,
      'zone': instance.zone,
      'shelf': instance.shelf,
      'costPrice': instance.costPrice,
      'totalValue': instance.totalValue,
      'lastCountDate': instance.lastCountDate?.toIso8601String(),
      'notes': instance.notes,
    };

_$StockMovementImpl _$$StockMovementImplFromJson(Map<String, dynamic> json) =>
    _$StockMovementImpl(
      id: json['id'] as String,
      variantId: json['variantId'] as String,
      type: $enumDecode(_$MovementTypeEnumMap, json['type']),
      quantity: _parseInt(json['quantity']),
      previousStock: _parseInt(json['previousStock']),
      newStock: _parseInt(json['newStock']),
      reason: json['reason'] as String?,
      notes: json['notes'] as String?,
      userId: json['userId'] as String?,
      orderId: json['orderId'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$$StockMovementImplToJson(_$StockMovementImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'variantId': instance.variantId,
      'type': _$MovementTypeEnumMap[instance.type]!,
      'quantity': instance.quantity,
      'previousStock': instance.previousStock,
      'newStock': instance.newStock,
      'reason': instance.reason,
      'notes': instance.notes,
      'userId': instance.userId,
      'orderId': instance.orderId,
      'createdAt': instance.createdAt.toIso8601String(),
    };

const _$MovementTypeEnumMap = {
  MovementType.stockIn: 'in',
  MovementType.stockOut: 'out',
  MovementType.adjustment: 'adjustment',
  MovementType.damage: 'damage',
  MovementType.stockReturn: 'return',
};
