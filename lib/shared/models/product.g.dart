// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'product.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ProductImageImpl _$$ProductImageImplFromJson(Map<String, dynamic> json) =>
    _$ProductImageImpl(
      id: json['id'] as String,
      productId: json['productId'] as String,
      url: json['url'] as String,
      position: _parseInt(json['position']),
    );

Map<String, dynamic> _$$ProductImageImplToJson(_$ProductImageImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'productId': instance.productId,
      'url': instance.url,
      'position': instance.position,
    };

_$ProductVariantImpl _$$ProductVariantImplFromJson(Map<String, dynamic> json) =>
    _$ProductVariantImpl(
      id: json['id'] as String,
      productId: json['productId'] as String,
      label: json['label'] as String,
      weight: _parseDoubleNullable(json['weight']),
      pack: json['pack'] as String?,
      price: _parseDouble(json['price']),
      stock: _parseInt(json['stock']),
      wholesaleUnit: json['wholesaleUnit'] as String?,
      minOrderQuantity: _parseIntNullable(json['minOrderQuantity']),
      unitsPerPackage: _parseIntNullable(json['unitsPerPackage']),
      minStock: _parseIntNullable(json['minStock']),
      maxStock: _parseIntNullable(json['maxStock']),
    );

Map<String, dynamic> _$$ProductVariantImplToJson(
  _$ProductVariantImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'productId': instance.productId,
  'label': instance.label,
  'weight': instance.weight,
  'pack': instance.pack,
  'price': instance.price,
  'stock': instance.stock,
  'wholesaleUnit': instance.wholesaleUnit,
  'minOrderQuantity': instance.minOrderQuantity,
  'unitsPerPackage': instance.unitsPerPackage,
  'minStock': instance.minStock,
  'maxStock': instance.maxStock,
};

_$ProductProducerImpl _$$ProductProducerImplFromJson(
  Map<String, dynamic> json,
) => _$ProductProducerImpl(
  businessName: json['businessName'] as String,
  zone: json['zone'] as String,
);

Map<String, dynamic> _$$ProductProducerImplToJson(
  _$ProductProducerImpl instance,
) => <String, dynamic>{
  'businessName': instance.businessName,
  'zone': instance.zone,
};

_$ProductImpl _$$ProductImplFromJson(Map<String, dynamic> json) =>
    _$ProductImpl(
      id: json['id'] as String,
      producerId: json['producerId'] as String,
      title: json['title'] as String,
      category: json['category'] as String,
      description: json['description'] as String?,
      basePrice: _parseDouble(json['basePrice']),
      isActive: json['isActive'] as bool,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      images:
          (json['images'] as List<dynamic>?)
              ?.map((e) => ProductImage.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      variants:
          (json['variants'] as List<dynamic>?)
              ?.map((e) => ProductVariant.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      producer: json['producer'] == null
          ? null
          : ProductProducer.fromJson(json['producer'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$$ProductImplToJson(_$ProductImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'producerId': instance.producerId,
      'title': instance.title,
      'category': instance.category,
      'description': instance.description,
      'basePrice': instance.basePrice,
      'isActive': instance.isActive,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
      'images': instance.images,
      'variants': instance.variants,
      'producer': instance.producer,
    };
