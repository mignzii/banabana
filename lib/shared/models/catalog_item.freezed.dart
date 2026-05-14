// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'catalog_item.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

CatalogProducer _$CatalogProducerFromJson(Map<String, dynamic> json) {
  return _CatalogProducer.fromJson(json);
}

/// @nodoc
mixin _$CatalogProducer {
  String get businessName => throw _privateConstructorUsedError;
  String get zone => throw _privateConstructorUsedError;

  /// Serializes this CatalogProducer to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of CatalogProducer
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CatalogProducerCopyWith<CatalogProducer> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CatalogProducerCopyWith<$Res> {
  factory $CatalogProducerCopyWith(
    CatalogProducer value,
    $Res Function(CatalogProducer) then,
  ) = _$CatalogProducerCopyWithImpl<$Res, CatalogProducer>;
  @useResult
  $Res call({String businessName, String zone});
}

/// @nodoc
class _$CatalogProducerCopyWithImpl<$Res, $Val extends CatalogProducer>
    implements $CatalogProducerCopyWith<$Res> {
  _$CatalogProducerCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of CatalogProducer
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? businessName = null, Object? zone = null}) {
    return _then(
      _value.copyWith(
            businessName: null == businessName
                ? _value.businessName
                : businessName // ignore: cast_nullable_to_non_nullable
                      as String,
            zone: null == zone
                ? _value.zone
                : zone // ignore: cast_nullable_to_non_nullable
                      as String,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$CatalogProducerImplCopyWith<$Res>
    implements $CatalogProducerCopyWith<$Res> {
  factory _$$CatalogProducerImplCopyWith(
    _$CatalogProducerImpl value,
    $Res Function(_$CatalogProducerImpl) then,
  ) = __$$CatalogProducerImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String businessName, String zone});
}

/// @nodoc
class __$$CatalogProducerImplCopyWithImpl<$Res>
    extends _$CatalogProducerCopyWithImpl<$Res, _$CatalogProducerImpl>
    implements _$$CatalogProducerImplCopyWith<$Res> {
  __$$CatalogProducerImplCopyWithImpl(
    _$CatalogProducerImpl _value,
    $Res Function(_$CatalogProducerImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of CatalogProducer
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? businessName = null, Object? zone = null}) {
    return _then(
      _$CatalogProducerImpl(
        businessName: null == businessName
            ? _value.businessName
            : businessName // ignore: cast_nullable_to_non_nullable
                  as String,
        zone: null == zone
            ? _value.zone
            : zone // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$CatalogProducerImpl implements _CatalogProducer {
  const _$CatalogProducerImpl({required this.businessName, required this.zone});

  factory _$CatalogProducerImpl.fromJson(Map<String, dynamic> json) =>
      _$$CatalogProducerImplFromJson(json);

  @override
  final String businessName;
  @override
  final String zone;

  @override
  String toString() {
    return 'CatalogProducer(businessName: $businessName, zone: $zone)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CatalogProducerImpl &&
            (identical(other.businessName, businessName) ||
                other.businessName == businessName) &&
            (identical(other.zone, zone) || other.zone == zone));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, businessName, zone);

  /// Create a copy of CatalogProducer
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CatalogProducerImplCopyWith<_$CatalogProducerImpl> get copyWith =>
      __$$CatalogProducerImplCopyWithImpl<_$CatalogProducerImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$CatalogProducerImplToJson(this);
  }
}

abstract class _CatalogProducer implements CatalogProducer {
  const factory _CatalogProducer({
    required final String businessName,
    required final String zone,
  }) = _$CatalogProducerImpl;

  factory _CatalogProducer.fromJson(Map<String, dynamic> json) =
      _$CatalogProducerImpl.fromJson;

  @override
  String get businessName;
  @override
  String get zone;

  /// Create a copy of CatalogProducer
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CatalogProducerImplCopyWith<_$CatalogProducerImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

CatalogItem _$CatalogItemFromJson(Map<String, dynamic> json) {
  return _CatalogItem.fromJson(json);
}

/// @nodoc
mixin _$CatalogItem {
  String get id => throw _privateConstructorUsedError;
  String get title => throw _privateConstructorUsedError;
  String get category => throw _privateConstructorUsedError;
  String? get description => throw _privateConstructorUsedError;
  @JsonKey(fromJson: _parseDouble)
  double get basePrice => throw _privateConstructorUsedError;
  bool get isActive => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  CatalogProducer get producer => throw _privateConstructorUsedError;
  @JsonKey(fromJson: _parseDouble)
  double get minPrice => throw _privateConstructorUsedError;
  @JsonKey(fromJson: _parseDouble)
  double get maxPrice => throw _privateConstructorUsedError;
  @JsonKey(fromJson: _parseInt)
  int get totalStock => throw _privateConstructorUsedError;
  String? get mainImage => throw _privateConstructorUsedError;

  /// Serializes this CatalogItem to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of CatalogItem
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CatalogItemCopyWith<CatalogItem> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CatalogItemCopyWith<$Res> {
  factory $CatalogItemCopyWith(
    CatalogItem value,
    $Res Function(CatalogItem) then,
  ) = _$CatalogItemCopyWithImpl<$Res, CatalogItem>;
  @useResult
  $Res call({
    String id,
    String title,
    String category,
    String? description,
    @JsonKey(fromJson: _parseDouble) double basePrice,
    bool isActive,
    DateTime createdAt,
    CatalogProducer producer,
    @JsonKey(fromJson: _parseDouble) double minPrice,
    @JsonKey(fromJson: _parseDouble) double maxPrice,
    @JsonKey(fromJson: _parseInt) int totalStock,
    String? mainImage,
  });

  $CatalogProducerCopyWith<$Res> get producer;
}

/// @nodoc
class _$CatalogItemCopyWithImpl<$Res, $Val extends CatalogItem>
    implements $CatalogItemCopyWith<$Res> {
  _$CatalogItemCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of CatalogItem
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? category = null,
    Object? description = freezed,
    Object? basePrice = null,
    Object? isActive = null,
    Object? createdAt = null,
    Object? producer = null,
    Object? minPrice = null,
    Object? maxPrice = null,
    Object? totalStock = null,
    Object? mainImage = freezed,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            title: null == title
                ? _value.title
                : title // ignore: cast_nullable_to_non_nullable
                      as String,
            category: null == category
                ? _value.category
                : category // ignore: cast_nullable_to_non_nullable
                      as String,
            description: freezed == description
                ? _value.description
                : description // ignore: cast_nullable_to_non_nullable
                      as String?,
            basePrice: null == basePrice
                ? _value.basePrice
                : basePrice // ignore: cast_nullable_to_non_nullable
                      as double,
            isActive: null == isActive
                ? _value.isActive
                : isActive // ignore: cast_nullable_to_non_nullable
                      as bool,
            createdAt: null == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            producer: null == producer
                ? _value.producer
                : producer // ignore: cast_nullable_to_non_nullable
                      as CatalogProducer,
            minPrice: null == minPrice
                ? _value.minPrice
                : minPrice // ignore: cast_nullable_to_non_nullable
                      as double,
            maxPrice: null == maxPrice
                ? _value.maxPrice
                : maxPrice // ignore: cast_nullable_to_non_nullable
                      as double,
            totalStock: null == totalStock
                ? _value.totalStock
                : totalStock // ignore: cast_nullable_to_non_nullable
                      as int,
            mainImage: freezed == mainImage
                ? _value.mainImage
                : mainImage // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }

  /// Create a copy of CatalogItem
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $CatalogProducerCopyWith<$Res> get producer {
    return $CatalogProducerCopyWith<$Res>(_value.producer, (value) {
      return _then(_value.copyWith(producer: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$CatalogItemImplCopyWith<$Res>
    implements $CatalogItemCopyWith<$Res> {
  factory _$$CatalogItemImplCopyWith(
    _$CatalogItemImpl value,
    $Res Function(_$CatalogItemImpl) then,
  ) = __$$CatalogItemImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String title,
    String category,
    String? description,
    @JsonKey(fromJson: _parseDouble) double basePrice,
    bool isActive,
    DateTime createdAt,
    CatalogProducer producer,
    @JsonKey(fromJson: _parseDouble) double minPrice,
    @JsonKey(fromJson: _parseDouble) double maxPrice,
    @JsonKey(fromJson: _parseInt) int totalStock,
    String? mainImage,
  });

  @override
  $CatalogProducerCopyWith<$Res> get producer;
}

/// @nodoc
class __$$CatalogItemImplCopyWithImpl<$Res>
    extends _$CatalogItemCopyWithImpl<$Res, _$CatalogItemImpl>
    implements _$$CatalogItemImplCopyWith<$Res> {
  __$$CatalogItemImplCopyWithImpl(
    _$CatalogItemImpl _value,
    $Res Function(_$CatalogItemImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of CatalogItem
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? category = null,
    Object? description = freezed,
    Object? basePrice = null,
    Object? isActive = null,
    Object? createdAt = null,
    Object? producer = null,
    Object? minPrice = null,
    Object? maxPrice = null,
    Object? totalStock = null,
    Object? mainImage = freezed,
  }) {
    return _then(
      _$CatalogItemImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        title: null == title
            ? _value.title
            : title // ignore: cast_nullable_to_non_nullable
                  as String,
        category: null == category
            ? _value.category
            : category // ignore: cast_nullable_to_non_nullable
                  as String,
        description: freezed == description
            ? _value.description
            : description // ignore: cast_nullable_to_non_nullable
                  as String?,
        basePrice: null == basePrice
            ? _value.basePrice
            : basePrice // ignore: cast_nullable_to_non_nullable
                  as double,
        isActive: null == isActive
            ? _value.isActive
            : isActive // ignore: cast_nullable_to_non_nullable
                  as bool,
        createdAt: null == createdAt
            ? _value.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        producer: null == producer
            ? _value.producer
            : producer // ignore: cast_nullable_to_non_nullable
                  as CatalogProducer,
        minPrice: null == minPrice
            ? _value.minPrice
            : minPrice // ignore: cast_nullable_to_non_nullable
                  as double,
        maxPrice: null == maxPrice
            ? _value.maxPrice
            : maxPrice // ignore: cast_nullable_to_non_nullable
                  as double,
        totalStock: null == totalStock
            ? _value.totalStock
            : totalStock // ignore: cast_nullable_to_non_nullable
                  as int,
        mainImage: freezed == mainImage
            ? _value.mainImage
            : mainImage // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$CatalogItemImpl implements _CatalogItem {
  const _$CatalogItemImpl({
    required this.id,
    required this.title,
    required this.category,
    this.description,
    @JsonKey(fromJson: _parseDouble) required this.basePrice,
    required this.isActive,
    required this.createdAt,
    required this.producer,
    @JsonKey(fromJson: _parseDouble) required this.minPrice,
    @JsonKey(fromJson: _parseDouble) required this.maxPrice,
    @JsonKey(fromJson: _parseInt) required this.totalStock,
    this.mainImage,
  });

  factory _$CatalogItemImpl.fromJson(Map<String, dynamic> json) =>
      _$$CatalogItemImplFromJson(json);

  @override
  final String id;
  @override
  final String title;
  @override
  final String category;
  @override
  final String? description;
  @override
  @JsonKey(fromJson: _parseDouble)
  final double basePrice;
  @override
  final bool isActive;
  @override
  final DateTime createdAt;
  @override
  final CatalogProducer producer;
  @override
  @JsonKey(fromJson: _parseDouble)
  final double minPrice;
  @override
  @JsonKey(fromJson: _parseDouble)
  final double maxPrice;
  @override
  @JsonKey(fromJson: _parseInt)
  final int totalStock;
  @override
  final String? mainImage;

  @override
  String toString() {
    return 'CatalogItem(id: $id, title: $title, category: $category, description: $description, basePrice: $basePrice, isActive: $isActive, createdAt: $createdAt, producer: $producer, minPrice: $minPrice, maxPrice: $maxPrice, totalStock: $totalStock, mainImage: $mainImage)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CatalogItemImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.category, category) ||
                other.category == category) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.basePrice, basePrice) ||
                other.basePrice == basePrice) &&
            (identical(other.isActive, isActive) ||
                other.isActive == isActive) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.producer, producer) ||
                other.producer == producer) &&
            (identical(other.minPrice, minPrice) ||
                other.minPrice == minPrice) &&
            (identical(other.maxPrice, maxPrice) ||
                other.maxPrice == maxPrice) &&
            (identical(other.totalStock, totalStock) ||
                other.totalStock == totalStock) &&
            (identical(other.mainImage, mainImage) ||
                other.mainImage == mainImage));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    title,
    category,
    description,
    basePrice,
    isActive,
    createdAt,
    producer,
    minPrice,
    maxPrice,
    totalStock,
    mainImage,
  );

  /// Create a copy of CatalogItem
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CatalogItemImplCopyWith<_$CatalogItemImpl> get copyWith =>
      __$$CatalogItemImplCopyWithImpl<_$CatalogItemImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$CatalogItemImplToJson(this);
  }
}

abstract class _CatalogItem implements CatalogItem {
  const factory _CatalogItem({
    required final String id,
    required final String title,
    required final String category,
    final String? description,
    @JsonKey(fromJson: _parseDouble) required final double basePrice,
    required final bool isActive,
    required final DateTime createdAt,
    required final CatalogProducer producer,
    @JsonKey(fromJson: _parseDouble) required final double minPrice,
    @JsonKey(fromJson: _parseDouble) required final double maxPrice,
    @JsonKey(fromJson: _parseInt) required final int totalStock,
    final String? mainImage,
  }) = _$CatalogItemImpl;

  factory _CatalogItem.fromJson(Map<String, dynamic> json) =
      _$CatalogItemImpl.fromJson;

  @override
  String get id;
  @override
  String get title;
  @override
  String get category;
  @override
  String? get description;
  @override
  @JsonKey(fromJson: _parseDouble)
  double get basePrice;
  @override
  bool get isActive;
  @override
  DateTime get createdAt;
  @override
  CatalogProducer get producer;
  @override
  @JsonKey(fromJson: _parseDouble)
  double get minPrice;
  @override
  @JsonKey(fromJson: _parseDouble)
  double get maxPrice;
  @override
  @JsonKey(fromJson: _parseInt)
  int get totalStock;
  @override
  String? get mainImage;

  /// Create a copy of CatalogItem
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CatalogItemImplCopyWith<_$CatalogItemImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

CatalogPagination _$CatalogPaginationFromJson(Map<String, dynamic> json) {
  return _CatalogPagination.fromJson(json);
}

/// @nodoc
mixin _$CatalogPagination {
  @JsonKey(fromJson: _parseInt)
  int get page => throw _privateConstructorUsedError;
  @JsonKey(fromJson: _parseInt)
  int get limit => throw _privateConstructorUsedError;
  @JsonKey(fromJson: _parseInt)
  int get total => throw _privateConstructorUsedError;
  @JsonKey(fromJson: _parseInt)
  int get pages => throw _privateConstructorUsedError;

  /// Serializes this CatalogPagination to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of CatalogPagination
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CatalogPaginationCopyWith<CatalogPagination> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CatalogPaginationCopyWith<$Res> {
  factory $CatalogPaginationCopyWith(
    CatalogPagination value,
    $Res Function(CatalogPagination) then,
  ) = _$CatalogPaginationCopyWithImpl<$Res, CatalogPagination>;
  @useResult
  $Res call({
    @JsonKey(fromJson: _parseInt) int page,
    @JsonKey(fromJson: _parseInt) int limit,
    @JsonKey(fromJson: _parseInt) int total,
    @JsonKey(fromJson: _parseInt) int pages,
  });
}

/// @nodoc
class _$CatalogPaginationCopyWithImpl<$Res, $Val extends CatalogPagination>
    implements $CatalogPaginationCopyWith<$Res> {
  _$CatalogPaginationCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of CatalogPagination
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? page = null,
    Object? limit = null,
    Object? total = null,
    Object? pages = null,
  }) {
    return _then(
      _value.copyWith(
            page: null == page
                ? _value.page
                : page // ignore: cast_nullable_to_non_nullable
                      as int,
            limit: null == limit
                ? _value.limit
                : limit // ignore: cast_nullable_to_non_nullable
                      as int,
            total: null == total
                ? _value.total
                : total // ignore: cast_nullable_to_non_nullable
                      as int,
            pages: null == pages
                ? _value.pages
                : pages // ignore: cast_nullable_to_non_nullable
                      as int,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$CatalogPaginationImplCopyWith<$Res>
    implements $CatalogPaginationCopyWith<$Res> {
  factory _$$CatalogPaginationImplCopyWith(
    _$CatalogPaginationImpl value,
    $Res Function(_$CatalogPaginationImpl) then,
  ) = __$$CatalogPaginationImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    @JsonKey(fromJson: _parseInt) int page,
    @JsonKey(fromJson: _parseInt) int limit,
    @JsonKey(fromJson: _parseInt) int total,
    @JsonKey(fromJson: _parseInt) int pages,
  });
}

/// @nodoc
class __$$CatalogPaginationImplCopyWithImpl<$Res>
    extends _$CatalogPaginationCopyWithImpl<$Res, _$CatalogPaginationImpl>
    implements _$$CatalogPaginationImplCopyWith<$Res> {
  __$$CatalogPaginationImplCopyWithImpl(
    _$CatalogPaginationImpl _value,
    $Res Function(_$CatalogPaginationImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of CatalogPagination
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? page = null,
    Object? limit = null,
    Object? total = null,
    Object? pages = null,
  }) {
    return _then(
      _$CatalogPaginationImpl(
        page: null == page
            ? _value.page
            : page // ignore: cast_nullable_to_non_nullable
                  as int,
        limit: null == limit
            ? _value.limit
            : limit // ignore: cast_nullable_to_non_nullable
                  as int,
        total: null == total
            ? _value.total
            : total // ignore: cast_nullable_to_non_nullable
                  as int,
        pages: null == pages
            ? _value.pages
            : pages // ignore: cast_nullable_to_non_nullable
                  as int,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$CatalogPaginationImpl implements _CatalogPagination {
  const _$CatalogPaginationImpl({
    @JsonKey(fromJson: _parseInt) required this.page,
    @JsonKey(fromJson: _parseInt) required this.limit,
    @JsonKey(fromJson: _parseInt) required this.total,
    @JsonKey(fromJson: _parseInt) required this.pages,
  });

  factory _$CatalogPaginationImpl.fromJson(Map<String, dynamic> json) =>
      _$$CatalogPaginationImplFromJson(json);

  @override
  @JsonKey(fromJson: _parseInt)
  final int page;
  @override
  @JsonKey(fromJson: _parseInt)
  final int limit;
  @override
  @JsonKey(fromJson: _parseInt)
  final int total;
  @override
  @JsonKey(fromJson: _parseInt)
  final int pages;

  @override
  String toString() {
    return 'CatalogPagination(page: $page, limit: $limit, total: $total, pages: $pages)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CatalogPaginationImpl &&
            (identical(other.page, page) || other.page == page) &&
            (identical(other.limit, limit) || other.limit == limit) &&
            (identical(other.total, total) || other.total == total) &&
            (identical(other.pages, pages) || other.pages == pages));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, page, limit, total, pages);

  /// Create a copy of CatalogPagination
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CatalogPaginationImplCopyWith<_$CatalogPaginationImpl> get copyWith =>
      __$$CatalogPaginationImplCopyWithImpl<_$CatalogPaginationImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$CatalogPaginationImplToJson(this);
  }
}

abstract class _CatalogPagination implements CatalogPagination {
  const factory _CatalogPagination({
    @JsonKey(fromJson: _parseInt) required final int page,
    @JsonKey(fromJson: _parseInt) required final int limit,
    @JsonKey(fromJson: _parseInt) required final int total,
    @JsonKey(fromJson: _parseInt) required final int pages,
  }) = _$CatalogPaginationImpl;

  factory _CatalogPagination.fromJson(Map<String, dynamic> json) =
      _$CatalogPaginationImpl.fromJson;

  @override
  @JsonKey(fromJson: _parseInt)
  int get page;
  @override
  @JsonKey(fromJson: _parseInt)
  int get limit;
  @override
  @JsonKey(fromJson: _parseInt)
  int get total;
  @override
  @JsonKey(fromJson: _parseInt)
  int get pages;

  /// Create a copy of CatalogPagination
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CatalogPaginationImplCopyWith<_$CatalogPaginationImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

CatalogResult _$CatalogResultFromJson(Map<String, dynamic> json) {
  return _CatalogResult.fromJson(json);
}

/// @nodoc
mixin _$CatalogResult {
  List<CatalogItem> get data => throw _privateConstructorUsedError;
  CatalogPagination get pagination => throw _privateConstructorUsedError;

  /// Serializes this CatalogResult to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of CatalogResult
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CatalogResultCopyWith<CatalogResult> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CatalogResultCopyWith<$Res> {
  factory $CatalogResultCopyWith(
    CatalogResult value,
    $Res Function(CatalogResult) then,
  ) = _$CatalogResultCopyWithImpl<$Res, CatalogResult>;
  @useResult
  $Res call({List<CatalogItem> data, CatalogPagination pagination});

  $CatalogPaginationCopyWith<$Res> get pagination;
}

/// @nodoc
class _$CatalogResultCopyWithImpl<$Res, $Val extends CatalogResult>
    implements $CatalogResultCopyWith<$Res> {
  _$CatalogResultCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of CatalogResult
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? data = null, Object? pagination = null}) {
    return _then(
      _value.copyWith(
            data: null == data
                ? _value.data
                : data // ignore: cast_nullable_to_non_nullable
                      as List<CatalogItem>,
            pagination: null == pagination
                ? _value.pagination
                : pagination // ignore: cast_nullable_to_non_nullable
                      as CatalogPagination,
          )
          as $Val,
    );
  }

  /// Create a copy of CatalogResult
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $CatalogPaginationCopyWith<$Res> get pagination {
    return $CatalogPaginationCopyWith<$Res>(_value.pagination, (value) {
      return _then(_value.copyWith(pagination: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$CatalogResultImplCopyWith<$Res>
    implements $CatalogResultCopyWith<$Res> {
  factory _$$CatalogResultImplCopyWith(
    _$CatalogResultImpl value,
    $Res Function(_$CatalogResultImpl) then,
  ) = __$$CatalogResultImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({List<CatalogItem> data, CatalogPagination pagination});

  @override
  $CatalogPaginationCopyWith<$Res> get pagination;
}

/// @nodoc
class __$$CatalogResultImplCopyWithImpl<$Res>
    extends _$CatalogResultCopyWithImpl<$Res, _$CatalogResultImpl>
    implements _$$CatalogResultImplCopyWith<$Res> {
  __$$CatalogResultImplCopyWithImpl(
    _$CatalogResultImpl _value,
    $Res Function(_$CatalogResultImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of CatalogResult
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? data = null, Object? pagination = null}) {
    return _then(
      _$CatalogResultImpl(
        data: null == data
            ? _value._data
            : data // ignore: cast_nullable_to_non_nullable
                  as List<CatalogItem>,
        pagination: null == pagination
            ? _value.pagination
            : pagination // ignore: cast_nullable_to_non_nullable
                  as CatalogPagination,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$CatalogResultImpl implements _CatalogResult {
  const _$CatalogResultImpl({
    required final List<CatalogItem> data,
    required this.pagination,
  }) : _data = data;

  factory _$CatalogResultImpl.fromJson(Map<String, dynamic> json) =>
      _$$CatalogResultImplFromJson(json);

  final List<CatalogItem> _data;
  @override
  List<CatalogItem> get data {
    if (_data is EqualUnmodifiableListView) return _data;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_data);
  }

  @override
  final CatalogPagination pagination;

  @override
  String toString() {
    return 'CatalogResult(data: $data, pagination: $pagination)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CatalogResultImpl &&
            const DeepCollectionEquality().equals(other._data, _data) &&
            (identical(other.pagination, pagination) ||
                other.pagination == pagination));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    const DeepCollectionEquality().hash(_data),
    pagination,
  );

  /// Create a copy of CatalogResult
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CatalogResultImplCopyWith<_$CatalogResultImpl> get copyWith =>
      __$$CatalogResultImplCopyWithImpl<_$CatalogResultImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$CatalogResultImplToJson(this);
  }
}

abstract class _CatalogResult implements CatalogResult {
  const factory _CatalogResult({
    required final List<CatalogItem> data,
    required final CatalogPagination pagination,
  }) = _$CatalogResultImpl;

  factory _CatalogResult.fromJson(Map<String, dynamic> json) =
      _$CatalogResultImpl.fromJson;

  @override
  List<CatalogItem> get data;
  @override
  CatalogPagination get pagination;

  /// Create a copy of CatalogResult
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CatalogResultImplCopyWith<_$CatalogResultImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
