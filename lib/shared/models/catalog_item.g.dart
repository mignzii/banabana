// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'catalog_item.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$CatalogProducerImpl _$$CatalogProducerImplFromJson(
  Map<String, dynamic> json,
) => _$CatalogProducerImpl(
  businessName: json['businessName'] as String,
  zone: json['zone'] as String,
);

Map<String, dynamic> _$$CatalogProducerImplToJson(
  _$CatalogProducerImpl instance,
) => <String, dynamic>{
  'businessName': instance.businessName,
  'zone': instance.zone,
};

_$CatalogItemImpl _$$CatalogItemImplFromJson(Map<String, dynamic> json) =>
    _$CatalogItemImpl(
      id: json['id'] as String,
      title: json['title'] as String,
      category: json['category'] as String,
      description: json['description'] as String?,
      basePrice: _parseDouble(json['basePrice']),
      isActive: json['isActive'] as bool,
      createdAt: DateTime.parse(json['createdAt'] as String),
      producer: CatalogProducer.fromJson(
        json['producer'] as Map<String, dynamic>,
      ),
      minPrice: _parseDouble(json['minPrice']),
      maxPrice: _parseDouble(json['maxPrice']),
      totalStock: _parseInt(json['totalStock']),
      mainImage: json['mainImage'] as String?,
    );

Map<String, dynamic> _$$CatalogItemImplToJson(_$CatalogItemImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'category': instance.category,
      'description': instance.description,
      'basePrice': instance.basePrice,
      'isActive': instance.isActive,
      'createdAt': instance.createdAt.toIso8601String(),
      'producer': instance.producer,
      'minPrice': instance.minPrice,
      'maxPrice': instance.maxPrice,
      'totalStock': instance.totalStock,
      'mainImage': instance.mainImage,
    };

_$CatalogPaginationImpl _$$CatalogPaginationImplFromJson(
  Map<String, dynamic> json,
) => _$CatalogPaginationImpl(
  page: _parseInt(json['page']),
  limit: _parseInt(json['limit']),
  total: _parseInt(json['total']),
  pages: _parseInt(json['pages']),
);

Map<String, dynamic> _$$CatalogPaginationImplToJson(
  _$CatalogPaginationImpl instance,
) => <String, dynamic>{
  'page': instance.page,
  'limit': instance.limit,
  'total': instance.total,
  'pages': instance.pages,
};

_$CatalogResultImpl _$$CatalogResultImplFromJson(Map<String, dynamic> json) =>
    _$CatalogResultImpl(
      data: (json['data'] as List<dynamic>)
          .map((e) => CatalogItem.fromJson(e as Map<String, dynamic>))
          .toList(),
      pagination: CatalogPagination.fromJson(
        json['pagination'] as Map<String, dynamic>,
      ),
    );

Map<String, dynamic> _$$CatalogResultImplToJson(_$CatalogResultImpl instance) =>
    <String, dynamic>{'data': instance.data, 'pagination': instance.pagination};
