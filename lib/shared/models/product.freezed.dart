// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'product.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

ProductImage _$ProductImageFromJson(Map<String, dynamic> json) {
  return _ProductImage.fromJson(json);
}

/// @nodoc
mixin _$ProductImage {
  String get id => throw _privateConstructorUsedError;
  String get productId => throw _privateConstructorUsedError;
  String get url => throw _privateConstructorUsedError;
  @JsonKey(fromJson: _parseInt)
  int get position => throw _privateConstructorUsedError;

  /// Serializes this ProductImage to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ProductImage
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ProductImageCopyWith<ProductImage> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ProductImageCopyWith<$Res> {
  factory $ProductImageCopyWith(
    ProductImage value,
    $Res Function(ProductImage) then,
  ) = _$ProductImageCopyWithImpl<$Res, ProductImage>;
  @useResult
  $Res call({
    String id,
    String productId,
    String url,
    @JsonKey(fromJson: _parseInt) int position,
  });
}

/// @nodoc
class _$ProductImageCopyWithImpl<$Res, $Val extends ProductImage>
    implements $ProductImageCopyWith<$Res> {
  _$ProductImageCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ProductImage
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? productId = null,
    Object? url = null,
    Object? position = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            productId: null == productId
                ? _value.productId
                : productId // ignore: cast_nullable_to_non_nullable
                      as String,
            url: null == url
                ? _value.url
                : url // ignore: cast_nullable_to_non_nullable
                      as String,
            position: null == position
                ? _value.position
                : position // ignore: cast_nullable_to_non_nullable
                      as int,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ProductImageImplCopyWith<$Res>
    implements $ProductImageCopyWith<$Res> {
  factory _$$ProductImageImplCopyWith(
    _$ProductImageImpl value,
    $Res Function(_$ProductImageImpl) then,
  ) = __$$ProductImageImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String productId,
    String url,
    @JsonKey(fromJson: _parseInt) int position,
  });
}

/// @nodoc
class __$$ProductImageImplCopyWithImpl<$Res>
    extends _$ProductImageCopyWithImpl<$Res, _$ProductImageImpl>
    implements _$$ProductImageImplCopyWith<$Res> {
  __$$ProductImageImplCopyWithImpl(
    _$ProductImageImpl _value,
    $Res Function(_$ProductImageImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ProductImage
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? productId = null,
    Object? url = null,
    Object? position = null,
  }) {
    return _then(
      _$ProductImageImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        productId: null == productId
            ? _value.productId
            : productId // ignore: cast_nullable_to_non_nullable
                  as String,
        url: null == url
            ? _value.url
            : url // ignore: cast_nullable_to_non_nullable
                  as String,
        position: null == position
            ? _value.position
            : position // ignore: cast_nullable_to_non_nullable
                  as int,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$ProductImageImpl implements _ProductImage {
  const _$ProductImageImpl({
    required this.id,
    required this.productId,
    required this.url,
    @JsonKey(fromJson: _parseInt) required this.position,
  });

  factory _$ProductImageImpl.fromJson(Map<String, dynamic> json) =>
      _$$ProductImageImplFromJson(json);

  @override
  final String id;
  @override
  final String productId;
  @override
  final String url;
  @override
  @JsonKey(fromJson: _parseInt)
  final int position;

  @override
  String toString() {
    return 'ProductImage(id: $id, productId: $productId, url: $url, position: $position)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ProductImageImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.productId, productId) ||
                other.productId == productId) &&
            (identical(other.url, url) || other.url == url) &&
            (identical(other.position, position) ||
                other.position == position));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, productId, url, position);

  /// Create a copy of ProductImage
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ProductImageImplCopyWith<_$ProductImageImpl> get copyWith =>
      __$$ProductImageImplCopyWithImpl<_$ProductImageImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ProductImageImplToJson(this);
  }
}

abstract class _ProductImage implements ProductImage {
  const factory _ProductImage({
    required final String id,
    required final String productId,
    required final String url,
    @JsonKey(fromJson: _parseInt) required final int position,
  }) = _$ProductImageImpl;

  factory _ProductImage.fromJson(Map<String, dynamic> json) =
      _$ProductImageImpl.fromJson;

  @override
  String get id;
  @override
  String get productId;
  @override
  String get url;
  @override
  @JsonKey(fromJson: _parseInt)
  int get position;

  /// Create a copy of ProductImage
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ProductImageImplCopyWith<_$ProductImageImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

ProductVariant _$ProductVariantFromJson(Map<String, dynamic> json) {
  return _ProductVariant.fromJson(json);
}

/// @nodoc
mixin _$ProductVariant {
  String get id => throw _privateConstructorUsedError;
  String get productId => throw _privateConstructorUsedError;
  String get label => throw _privateConstructorUsedError;
  @JsonKey(fromJson: _parseDoubleNullable)
  double? get weight => throw _privateConstructorUsedError;
  String? get pack => throw _privateConstructorUsedError;
  @JsonKey(fromJson: _parseDouble)
  double get price => throw _privateConstructorUsedError;
  @JsonKey(fromJson: _parseInt)
  int get stock => throw _privateConstructorUsedError;
  String? get wholesaleUnit => throw _privateConstructorUsedError;
  @JsonKey(fromJson: _parseIntNullable)
  int? get minOrderQuantity => throw _privateConstructorUsedError;
  @JsonKey(fromJson: _parseIntNullable)
  int? get unitsPerPackage => throw _privateConstructorUsedError;
  @JsonKey(fromJson: _parseIntNullable)
  int? get minStock => throw _privateConstructorUsedError;
  @JsonKey(fromJson: _parseIntNullable)
  int? get maxStock => throw _privateConstructorUsedError;

  /// Serializes this ProductVariant to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ProductVariant
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ProductVariantCopyWith<ProductVariant> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ProductVariantCopyWith<$Res> {
  factory $ProductVariantCopyWith(
    ProductVariant value,
    $Res Function(ProductVariant) then,
  ) = _$ProductVariantCopyWithImpl<$Res, ProductVariant>;
  @useResult
  $Res call({
    String id,
    String productId,
    String label,
    @JsonKey(fromJson: _parseDoubleNullable) double? weight,
    String? pack,
    @JsonKey(fromJson: _parseDouble) double price,
    @JsonKey(fromJson: _parseInt) int stock,
    String? wholesaleUnit,
    @JsonKey(fromJson: _parseIntNullable) int? minOrderQuantity,
    @JsonKey(fromJson: _parseIntNullable) int? unitsPerPackage,
    @JsonKey(fromJson: _parseIntNullable) int? minStock,
    @JsonKey(fromJson: _parseIntNullable) int? maxStock,
  });
}

/// @nodoc
class _$ProductVariantCopyWithImpl<$Res, $Val extends ProductVariant>
    implements $ProductVariantCopyWith<$Res> {
  _$ProductVariantCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ProductVariant
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? productId = null,
    Object? label = null,
    Object? weight = freezed,
    Object? pack = freezed,
    Object? price = null,
    Object? stock = null,
    Object? wholesaleUnit = freezed,
    Object? minOrderQuantity = freezed,
    Object? unitsPerPackage = freezed,
    Object? minStock = freezed,
    Object? maxStock = freezed,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            productId: null == productId
                ? _value.productId
                : productId // ignore: cast_nullable_to_non_nullable
                      as String,
            label: null == label
                ? _value.label
                : label // ignore: cast_nullable_to_non_nullable
                      as String,
            weight: freezed == weight
                ? _value.weight
                : weight // ignore: cast_nullable_to_non_nullable
                      as double?,
            pack: freezed == pack
                ? _value.pack
                : pack // ignore: cast_nullable_to_non_nullable
                      as String?,
            price: null == price
                ? _value.price
                : price // ignore: cast_nullable_to_non_nullable
                      as double,
            stock: null == stock
                ? _value.stock
                : stock // ignore: cast_nullable_to_non_nullable
                      as int,
            wholesaleUnit: freezed == wholesaleUnit
                ? _value.wholesaleUnit
                : wholesaleUnit // ignore: cast_nullable_to_non_nullable
                      as String?,
            minOrderQuantity: freezed == minOrderQuantity
                ? _value.minOrderQuantity
                : minOrderQuantity // ignore: cast_nullable_to_non_nullable
                      as int?,
            unitsPerPackage: freezed == unitsPerPackage
                ? _value.unitsPerPackage
                : unitsPerPackage // ignore: cast_nullable_to_non_nullable
                      as int?,
            minStock: freezed == minStock
                ? _value.minStock
                : minStock // ignore: cast_nullable_to_non_nullable
                      as int?,
            maxStock: freezed == maxStock
                ? _value.maxStock
                : maxStock // ignore: cast_nullable_to_non_nullable
                      as int?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ProductVariantImplCopyWith<$Res>
    implements $ProductVariantCopyWith<$Res> {
  factory _$$ProductVariantImplCopyWith(
    _$ProductVariantImpl value,
    $Res Function(_$ProductVariantImpl) then,
  ) = __$$ProductVariantImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String productId,
    String label,
    @JsonKey(fromJson: _parseDoubleNullable) double? weight,
    String? pack,
    @JsonKey(fromJson: _parseDouble) double price,
    @JsonKey(fromJson: _parseInt) int stock,
    String? wholesaleUnit,
    @JsonKey(fromJson: _parseIntNullable) int? minOrderQuantity,
    @JsonKey(fromJson: _parseIntNullable) int? unitsPerPackage,
    @JsonKey(fromJson: _parseIntNullable) int? minStock,
    @JsonKey(fromJson: _parseIntNullable) int? maxStock,
  });
}

/// @nodoc
class __$$ProductVariantImplCopyWithImpl<$Res>
    extends _$ProductVariantCopyWithImpl<$Res, _$ProductVariantImpl>
    implements _$$ProductVariantImplCopyWith<$Res> {
  __$$ProductVariantImplCopyWithImpl(
    _$ProductVariantImpl _value,
    $Res Function(_$ProductVariantImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ProductVariant
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? productId = null,
    Object? label = null,
    Object? weight = freezed,
    Object? pack = freezed,
    Object? price = null,
    Object? stock = null,
    Object? wholesaleUnit = freezed,
    Object? minOrderQuantity = freezed,
    Object? unitsPerPackage = freezed,
    Object? minStock = freezed,
    Object? maxStock = freezed,
  }) {
    return _then(
      _$ProductVariantImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        productId: null == productId
            ? _value.productId
            : productId // ignore: cast_nullable_to_non_nullable
                  as String,
        label: null == label
            ? _value.label
            : label // ignore: cast_nullable_to_non_nullable
                  as String,
        weight: freezed == weight
            ? _value.weight
            : weight // ignore: cast_nullable_to_non_nullable
                  as double?,
        pack: freezed == pack
            ? _value.pack
            : pack // ignore: cast_nullable_to_non_nullable
                  as String?,
        price: null == price
            ? _value.price
            : price // ignore: cast_nullable_to_non_nullable
                  as double,
        stock: null == stock
            ? _value.stock
            : stock // ignore: cast_nullable_to_non_nullable
                  as int,
        wholesaleUnit: freezed == wholesaleUnit
            ? _value.wholesaleUnit
            : wholesaleUnit // ignore: cast_nullable_to_non_nullable
                  as String?,
        minOrderQuantity: freezed == minOrderQuantity
            ? _value.minOrderQuantity
            : minOrderQuantity // ignore: cast_nullable_to_non_nullable
                  as int?,
        unitsPerPackage: freezed == unitsPerPackage
            ? _value.unitsPerPackage
            : unitsPerPackage // ignore: cast_nullable_to_non_nullable
                  as int?,
        minStock: freezed == minStock
            ? _value.minStock
            : minStock // ignore: cast_nullable_to_non_nullable
                  as int?,
        maxStock: freezed == maxStock
            ? _value.maxStock
            : maxStock // ignore: cast_nullable_to_non_nullable
                  as int?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$ProductVariantImpl implements _ProductVariant {
  const _$ProductVariantImpl({
    required this.id,
    required this.productId,
    required this.label,
    @JsonKey(fromJson: _parseDoubleNullable) this.weight,
    this.pack,
    @JsonKey(fromJson: _parseDouble) required this.price,
    @JsonKey(fromJson: _parseInt) required this.stock,
    this.wholesaleUnit,
    @JsonKey(fromJson: _parseIntNullable) this.minOrderQuantity,
    @JsonKey(fromJson: _parseIntNullable) this.unitsPerPackage,
    @JsonKey(fromJson: _parseIntNullable) this.minStock,
    @JsonKey(fromJson: _parseIntNullable) this.maxStock,
  });

  factory _$ProductVariantImpl.fromJson(Map<String, dynamic> json) =>
      _$$ProductVariantImplFromJson(json);

  @override
  final String id;
  @override
  final String productId;
  @override
  final String label;
  @override
  @JsonKey(fromJson: _parseDoubleNullable)
  final double? weight;
  @override
  final String? pack;
  @override
  @JsonKey(fromJson: _parseDouble)
  final double price;
  @override
  @JsonKey(fromJson: _parseInt)
  final int stock;
  @override
  final String? wholesaleUnit;
  @override
  @JsonKey(fromJson: _parseIntNullable)
  final int? minOrderQuantity;
  @override
  @JsonKey(fromJson: _parseIntNullable)
  final int? unitsPerPackage;
  @override
  @JsonKey(fromJson: _parseIntNullable)
  final int? minStock;
  @override
  @JsonKey(fromJson: _parseIntNullable)
  final int? maxStock;

  @override
  String toString() {
    return 'ProductVariant(id: $id, productId: $productId, label: $label, weight: $weight, pack: $pack, price: $price, stock: $stock, wholesaleUnit: $wholesaleUnit, minOrderQuantity: $minOrderQuantity, unitsPerPackage: $unitsPerPackage, minStock: $minStock, maxStock: $maxStock)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ProductVariantImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.productId, productId) ||
                other.productId == productId) &&
            (identical(other.label, label) || other.label == label) &&
            (identical(other.weight, weight) || other.weight == weight) &&
            (identical(other.pack, pack) || other.pack == pack) &&
            (identical(other.price, price) || other.price == price) &&
            (identical(other.stock, stock) || other.stock == stock) &&
            (identical(other.wholesaleUnit, wholesaleUnit) ||
                other.wholesaleUnit == wholesaleUnit) &&
            (identical(other.minOrderQuantity, minOrderQuantity) ||
                other.minOrderQuantity == minOrderQuantity) &&
            (identical(other.unitsPerPackage, unitsPerPackage) ||
                other.unitsPerPackage == unitsPerPackage) &&
            (identical(other.minStock, minStock) ||
                other.minStock == minStock) &&
            (identical(other.maxStock, maxStock) ||
                other.maxStock == maxStock));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    productId,
    label,
    weight,
    pack,
    price,
    stock,
    wholesaleUnit,
    minOrderQuantity,
    unitsPerPackage,
    minStock,
    maxStock,
  );

  /// Create a copy of ProductVariant
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ProductVariantImplCopyWith<_$ProductVariantImpl> get copyWith =>
      __$$ProductVariantImplCopyWithImpl<_$ProductVariantImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$ProductVariantImplToJson(this);
  }
}

abstract class _ProductVariant implements ProductVariant {
  const factory _ProductVariant({
    required final String id,
    required final String productId,
    required final String label,
    @JsonKey(fromJson: _parseDoubleNullable) final double? weight,
    final String? pack,
    @JsonKey(fromJson: _parseDouble) required final double price,
    @JsonKey(fromJson: _parseInt) required final int stock,
    final String? wholesaleUnit,
    @JsonKey(fromJson: _parseIntNullable) final int? minOrderQuantity,
    @JsonKey(fromJson: _parseIntNullable) final int? unitsPerPackage,
    @JsonKey(fromJson: _parseIntNullable) final int? minStock,
    @JsonKey(fromJson: _parseIntNullable) final int? maxStock,
  }) = _$ProductVariantImpl;

  factory _ProductVariant.fromJson(Map<String, dynamic> json) =
      _$ProductVariantImpl.fromJson;

  @override
  String get id;
  @override
  String get productId;
  @override
  String get label;
  @override
  @JsonKey(fromJson: _parseDoubleNullable)
  double? get weight;
  @override
  String? get pack;
  @override
  @JsonKey(fromJson: _parseDouble)
  double get price;
  @override
  @JsonKey(fromJson: _parseInt)
  int get stock;
  @override
  String? get wholesaleUnit;
  @override
  @JsonKey(fromJson: _parseIntNullable)
  int? get minOrderQuantity;
  @override
  @JsonKey(fromJson: _parseIntNullable)
  int? get unitsPerPackage;
  @override
  @JsonKey(fromJson: _parseIntNullable)
  int? get minStock;
  @override
  @JsonKey(fromJson: _parseIntNullable)
  int? get maxStock;

  /// Create a copy of ProductVariant
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ProductVariantImplCopyWith<_$ProductVariantImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

ProductProducer _$ProductProducerFromJson(Map<String, dynamic> json) {
  return _ProductProducer.fromJson(json);
}

/// @nodoc
mixin _$ProductProducer {
  String get businessName => throw _privateConstructorUsedError;
  String get zone => throw _privateConstructorUsedError;

  /// Serializes this ProductProducer to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ProductProducer
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ProductProducerCopyWith<ProductProducer> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ProductProducerCopyWith<$Res> {
  factory $ProductProducerCopyWith(
    ProductProducer value,
    $Res Function(ProductProducer) then,
  ) = _$ProductProducerCopyWithImpl<$Res, ProductProducer>;
  @useResult
  $Res call({String businessName, String zone});
}

/// @nodoc
class _$ProductProducerCopyWithImpl<$Res, $Val extends ProductProducer>
    implements $ProductProducerCopyWith<$Res> {
  _$ProductProducerCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ProductProducer
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
abstract class _$$ProductProducerImplCopyWith<$Res>
    implements $ProductProducerCopyWith<$Res> {
  factory _$$ProductProducerImplCopyWith(
    _$ProductProducerImpl value,
    $Res Function(_$ProductProducerImpl) then,
  ) = __$$ProductProducerImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String businessName, String zone});
}

/// @nodoc
class __$$ProductProducerImplCopyWithImpl<$Res>
    extends _$ProductProducerCopyWithImpl<$Res, _$ProductProducerImpl>
    implements _$$ProductProducerImplCopyWith<$Res> {
  __$$ProductProducerImplCopyWithImpl(
    _$ProductProducerImpl _value,
    $Res Function(_$ProductProducerImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ProductProducer
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? businessName = null, Object? zone = null}) {
    return _then(
      _$ProductProducerImpl(
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
class _$ProductProducerImpl implements _ProductProducer {
  const _$ProductProducerImpl({required this.businessName, required this.zone});

  factory _$ProductProducerImpl.fromJson(Map<String, dynamic> json) =>
      _$$ProductProducerImplFromJson(json);

  @override
  final String businessName;
  @override
  final String zone;

  @override
  String toString() {
    return 'ProductProducer(businessName: $businessName, zone: $zone)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ProductProducerImpl &&
            (identical(other.businessName, businessName) ||
                other.businessName == businessName) &&
            (identical(other.zone, zone) || other.zone == zone));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, businessName, zone);

  /// Create a copy of ProductProducer
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ProductProducerImplCopyWith<_$ProductProducerImpl> get copyWith =>
      __$$ProductProducerImplCopyWithImpl<_$ProductProducerImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$ProductProducerImplToJson(this);
  }
}

abstract class _ProductProducer implements ProductProducer {
  const factory _ProductProducer({
    required final String businessName,
    required final String zone,
  }) = _$ProductProducerImpl;

  factory _ProductProducer.fromJson(Map<String, dynamic> json) =
      _$ProductProducerImpl.fromJson;

  @override
  String get businessName;
  @override
  String get zone;

  /// Create a copy of ProductProducer
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ProductProducerImplCopyWith<_$ProductProducerImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

Product _$ProductFromJson(Map<String, dynamic> json) {
  return _Product.fromJson(json);
}

/// @nodoc
mixin _$Product {
  String get id => throw _privateConstructorUsedError;
  String get producerId => throw _privateConstructorUsedError;
  String get title => throw _privateConstructorUsedError;
  String get category => throw _privateConstructorUsedError;
  String? get description => throw _privateConstructorUsedError;
  @JsonKey(fromJson: _parseDouble)
  double get basePrice => throw _privateConstructorUsedError;
  bool get isActive => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  DateTime get updatedAt => throw _privateConstructorUsedError;
  List<ProductImage> get images => throw _privateConstructorUsedError;
  List<ProductVariant> get variants => throw _privateConstructorUsedError;
  ProductProducer? get producer => throw _privateConstructorUsedError;

  /// Serializes this Product to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Product
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ProductCopyWith<Product> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ProductCopyWith<$Res> {
  factory $ProductCopyWith(Product value, $Res Function(Product) then) =
      _$ProductCopyWithImpl<$Res, Product>;
  @useResult
  $Res call({
    String id,
    String producerId,
    String title,
    String category,
    String? description,
    @JsonKey(fromJson: _parseDouble) double basePrice,
    bool isActive,
    DateTime createdAt,
    DateTime updatedAt,
    List<ProductImage> images,
    List<ProductVariant> variants,
    ProductProducer? producer,
  });

  $ProductProducerCopyWith<$Res>? get producer;
}

/// @nodoc
class _$ProductCopyWithImpl<$Res, $Val extends Product>
    implements $ProductCopyWith<$Res> {
  _$ProductCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Product
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? producerId = null,
    Object? title = null,
    Object? category = null,
    Object? description = freezed,
    Object? basePrice = null,
    Object? isActive = null,
    Object? createdAt = null,
    Object? updatedAt = null,
    Object? images = null,
    Object? variants = null,
    Object? producer = freezed,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            producerId: null == producerId
                ? _value.producerId
                : producerId // ignore: cast_nullable_to_non_nullable
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
            updatedAt: null == updatedAt
                ? _value.updatedAt
                : updatedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            images: null == images
                ? _value.images
                : images // ignore: cast_nullable_to_non_nullable
                      as List<ProductImage>,
            variants: null == variants
                ? _value.variants
                : variants // ignore: cast_nullable_to_non_nullable
                      as List<ProductVariant>,
            producer: freezed == producer
                ? _value.producer
                : producer // ignore: cast_nullable_to_non_nullable
                      as ProductProducer?,
          )
          as $Val,
    );
  }

  /// Create a copy of Product
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $ProductProducerCopyWith<$Res>? get producer {
    if (_value.producer == null) {
      return null;
    }

    return $ProductProducerCopyWith<$Res>(_value.producer!, (value) {
      return _then(_value.copyWith(producer: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$ProductImplCopyWith<$Res> implements $ProductCopyWith<$Res> {
  factory _$$ProductImplCopyWith(
    _$ProductImpl value,
    $Res Function(_$ProductImpl) then,
  ) = __$$ProductImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String producerId,
    String title,
    String category,
    String? description,
    @JsonKey(fromJson: _parseDouble) double basePrice,
    bool isActive,
    DateTime createdAt,
    DateTime updatedAt,
    List<ProductImage> images,
    List<ProductVariant> variants,
    ProductProducer? producer,
  });

  @override
  $ProductProducerCopyWith<$Res>? get producer;
}

/// @nodoc
class __$$ProductImplCopyWithImpl<$Res>
    extends _$ProductCopyWithImpl<$Res, _$ProductImpl>
    implements _$$ProductImplCopyWith<$Res> {
  __$$ProductImplCopyWithImpl(
    _$ProductImpl _value,
    $Res Function(_$ProductImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of Product
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? producerId = null,
    Object? title = null,
    Object? category = null,
    Object? description = freezed,
    Object? basePrice = null,
    Object? isActive = null,
    Object? createdAt = null,
    Object? updatedAt = null,
    Object? images = null,
    Object? variants = null,
    Object? producer = freezed,
  }) {
    return _then(
      _$ProductImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        producerId: null == producerId
            ? _value.producerId
            : producerId // ignore: cast_nullable_to_non_nullable
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
        updatedAt: null == updatedAt
            ? _value.updatedAt
            : updatedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        images: null == images
            ? _value._images
            : images // ignore: cast_nullable_to_non_nullable
                  as List<ProductImage>,
        variants: null == variants
            ? _value._variants
            : variants // ignore: cast_nullable_to_non_nullable
                  as List<ProductVariant>,
        producer: freezed == producer
            ? _value.producer
            : producer // ignore: cast_nullable_to_non_nullable
                  as ProductProducer?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$ProductImpl implements _Product {
  const _$ProductImpl({
    required this.id,
    required this.producerId,
    required this.title,
    required this.category,
    this.description,
    @JsonKey(fromJson: _parseDouble) required this.basePrice,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
    final List<ProductImage> images = const [],
    final List<ProductVariant> variants = const [],
    this.producer,
  }) : _images = images,
       _variants = variants;

  factory _$ProductImpl.fromJson(Map<String, dynamic> json) =>
      _$$ProductImplFromJson(json);

  @override
  final String id;
  @override
  final String producerId;
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
  final DateTime updatedAt;
  final List<ProductImage> _images;
  @override
  @JsonKey()
  List<ProductImage> get images {
    if (_images is EqualUnmodifiableListView) return _images;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_images);
  }

  final List<ProductVariant> _variants;
  @override
  @JsonKey()
  List<ProductVariant> get variants {
    if (_variants is EqualUnmodifiableListView) return _variants;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_variants);
  }

  @override
  final ProductProducer? producer;

  @override
  String toString() {
    return 'Product(id: $id, producerId: $producerId, title: $title, category: $category, description: $description, basePrice: $basePrice, isActive: $isActive, createdAt: $createdAt, updatedAt: $updatedAt, images: $images, variants: $variants, producer: $producer)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ProductImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.producerId, producerId) ||
                other.producerId == producerId) &&
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
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt) &&
            const DeepCollectionEquality().equals(other._images, _images) &&
            const DeepCollectionEquality().equals(other._variants, _variants) &&
            (identical(other.producer, producer) ||
                other.producer == producer));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    producerId,
    title,
    category,
    description,
    basePrice,
    isActive,
    createdAt,
    updatedAt,
    const DeepCollectionEquality().hash(_images),
    const DeepCollectionEquality().hash(_variants),
    producer,
  );

  /// Create a copy of Product
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ProductImplCopyWith<_$ProductImpl> get copyWith =>
      __$$ProductImplCopyWithImpl<_$ProductImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ProductImplToJson(this);
  }
}

abstract class _Product implements Product {
  const factory _Product({
    required final String id,
    required final String producerId,
    required final String title,
    required final String category,
    final String? description,
    @JsonKey(fromJson: _parseDouble) required final double basePrice,
    required final bool isActive,
    required final DateTime createdAt,
    required final DateTime updatedAt,
    final List<ProductImage> images,
    final List<ProductVariant> variants,
    final ProductProducer? producer,
  }) = _$ProductImpl;

  factory _Product.fromJson(Map<String, dynamic> json) = _$ProductImpl.fromJson;

  @override
  String get id;
  @override
  String get producerId;
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
  DateTime get updatedAt;
  @override
  List<ProductImage> get images;
  @override
  List<ProductVariant> get variants;
  @override
  ProductProducer? get producer;

  /// Create a copy of Product
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ProductImplCopyWith<_$ProductImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
