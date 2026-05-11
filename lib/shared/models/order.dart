import 'package:freezed_annotation/freezed_annotation.dart';

part 'order.freezed.dart';
part 'order.g.dart';

double _parseDouble(dynamic v) =>
    v is String ? double.parse(v) : (v as num).toDouble();

int _parseInt(dynamic v) =>
    v is String ? int.parse(v) : (v as num).toInt();

enum OrderStatus {
  @JsonValue('created') created,
  @JsonValue('preparing') preparing,
  @JsonValue('shipped') shipped,
  @JsonValue('delivered') delivered,
  @JsonValue('cancelled') cancelled,
}

@freezed
class OrderItem with _$OrderItem {
  const factory OrderItem({
    required String id,
    required String orderId,
    required String productId,
    required String variantId,
    required String producerId,
    @JsonKey(fromJson: _parseInt) required int quantity,
    @JsonKey(fromJson: _parseDouble) required double unitPrice,
  }) = _OrderItem;

  factory OrderItem.fromJson(Map<String, dynamic> json) =>
      _$OrderItemFromJson(json);
}

@freezed
class Order with _$Order {
  const factory Order({
    required String id,
    required String wholesalerId,
    required OrderStatus status,
    @JsonKey(fromJson: _parseDouble) required double totalAmount,
    required DateTime createdAt,
    @Default([]) List<OrderItem> items,
  }) = _Order;

  factory Order.fromJson(Map<String, dynamic> json) =>
      _$OrderFromJson(json);
}
