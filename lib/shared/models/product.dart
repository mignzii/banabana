import 'package:freezed_annotation/freezed_annotation.dart';

part 'product.freezed.dart';
part 'product.g.dart';

double _parseDouble(dynamic v) =>
    v is String ? double.parse(v) : (v as num).toDouble();

double? _parseDoubleNullable(dynamic v) =>
    v == null ? null : (v is String ? double.parse(v) : (v as num).toDouble());

int _parseInt(dynamic v) =>
    v is String ? int.parse(v) : (v as num).toInt();

int? _parseIntNullable(dynamic v) =>
    v == null ? null : (v is String ? int.parse(v) : (v as num).toInt());

@freezed
class ProductImage with _$ProductImage {
  const factory ProductImage({
    required String id,
    required String productId,
    required String url,
    @JsonKey(fromJson: _parseInt) required int position,
  }) = _ProductImage;

  factory ProductImage.fromJson(Map<String, dynamic> json) =>
      _$ProductImageFromJson(json);
}

@freezed
class ProductVariant with _$ProductVariant {
  const factory ProductVariant({
    required String id,
    required String productId,
    required String label,
    @JsonKey(fromJson: _parseDoubleNullable) double? weight,
    String? pack,
    @JsonKey(fromJson: _parseDouble) required double price,
    @JsonKey(fromJson: _parseInt) required int stock,
    String? wholesaleUnit,
    @JsonKey(fromJson: _parseIntNullable) int? minOrderQuantity,
    @JsonKey(fromJson: _parseIntNullable) int? unitsPerPackage,
    @JsonKey(fromJson: _parseIntNullable) int? minStock,
    @JsonKey(fromJson: _parseIntNullable) int? maxStock,
  }) = _ProductVariant;

  factory ProductVariant.fromJson(Map<String, dynamic> json) =>
      _$ProductVariantFromJson(json);
}

@freezed
class ProductProducer with _$ProductProducer {
  const factory ProductProducer({
    required String businessName,
    required String zone,
  }) = _ProductProducer;

  factory ProductProducer.fromJson(Map<String, dynamic> json) =>
      _$ProductProducerFromJson(json);
}

@freezed
class Product with _$Product {
  const factory Product({
    required String id,
    required String producerId,
    required String title,
    required String category,
    String? description,
    @JsonKey(fromJson: _parseDouble) required double basePrice,
    required bool isActive,
    required DateTime createdAt,
    required DateTime updatedAt,
    @Default([]) List<ProductImage> images,
    @Default([]) List<ProductVariant> variants,
    ProductProducer? producer,
  }) = _Product;

  factory Product.fromJson(Map<String, dynamic> json) =>
      _$ProductFromJson(json);
}
