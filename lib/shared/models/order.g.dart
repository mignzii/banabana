// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'order.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$OrderItemImpl _$$OrderItemImplFromJson(Map<String, dynamic> json) =>
    _$OrderItemImpl(
      id: json['id'] as String,
      orderId: json['orderId'] as String,
      productId: json['productId'] as String,
      variantId: json['variantId'] as String,
      producerId: json['producerId'] as String,
      quantity: _parseInt(json['quantity']),
      unitPrice: _parseDouble(json['unitPrice']),
    );

Map<String, dynamic> _$$OrderItemImplToJson(_$OrderItemImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'orderId': instance.orderId,
      'productId': instance.productId,
      'variantId': instance.variantId,
      'producerId': instance.producerId,
      'quantity': instance.quantity,
      'unitPrice': instance.unitPrice,
    };

_$OrderImpl _$$OrderImplFromJson(Map<String, dynamic> json) => _$OrderImpl(
      id: json['id'] as String,
      wholesalerId: json['wholesalerId'] as String,
      status: $enumDecode(_$OrderStatusEnumMap, json['status']),
      totalAmount: _parseDouble(json['totalAmount']),
      createdAt: DateTime.parse(json['createdAt'] as String),
      items: (json['items'] as List<dynamic>?)
              ?.map((e) => OrderItem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );

Map<String, dynamic> _$$OrderImplToJson(_$OrderImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'wholesalerId': instance.wholesalerId,
      'status': _$OrderStatusEnumMap[instance.status]!,
      'totalAmount': instance.totalAmount,
      'createdAt': instance.createdAt.toIso8601String(),
      'items': instance.items,
    };

const _$OrderStatusEnumMap = {
  OrderStatus.created: 'created',
  OrderStatus.preparing: 'preparing',
  OrderStatus.shipped: 'shipped',
  OrderStatus.delivered: 'delivered',
  OrderStatus.cancelled: 'cancelled',
};
