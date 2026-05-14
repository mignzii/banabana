// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'inventory.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

Inventory _$InventoryFromJson(Map<String, dynamic> json) {
  return _Inventory.fromJson(json);
}

/// @nodoc
mixin _$Inventory {
  String get id => throw _privateConstructorUsedError;
  String get variantId => throw _privateConstructorUsedError;
  String get userId => throw _privateConstructorUsedError;
  String? get location => throw _privateConstructorUsedError;
  String? get warehouse => throw _privateConstructorUsedError;
  String? get zone => throw _privateConstructorUsedError;
  String? get shelf => throw _privateConstructorUsedError;
  @JsonKey(fromJson: _parseDoubleNullable)
  double? get costPrice => throw _privateConstructorUsedError;
  @JsonKey(fromJson: _parseDoubleNullable)
  double? get totalValue => throw _privateConstructorUsedError;
  DateTime? get lastCountDate => throw _privateConstructorUsedError;
  String? get notes => throw _privateConstructorUsedError;

  /// Serializes this Inventory to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Inventory
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $InventoryCopyWith<Inventory> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $InventoryCopyWith<$Res> {
  factory $InventoryCopyWith(Inventory value, $Res Function(Inventory) then) =
      _$InventoryCopyWithImpl<$Res, Inventory>;
  @useResult
  $Res call({
    String id,
    String variantId,
    String userId,
    String? location,
    String? warehouse,
    String? zone,
    String? shelf,
    @JsonKey(fromJson: _parseDoubleNullable) double? costPrice,
    @JsonKey(fromJson: _parseDoubleNullable) double? totalValue,
    DateTime? lastCountDate,
    String? notes,
  });
}

/// @nodoc
class _$InventoryCopyWithImpl<$Res, $Val extends Inventory>
    implements $InventoryCopyWith<$Res> {
  _$InventoryCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Inventory
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? variantId = null,
    Object? userId = null,
    Object? location = freezed,
    Object? warehouse = freezed,
    Object? zone = freezed,
    Object? shelf = freezed,
    Object? costPrice = freezed,
    Object? totalValue = freezed,
    Object? lastCountDate = freezed,
    Object? notes = freezed,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            variantId: null == variantId
                ? _value.variantId
                : variantId // ignore: cast_nullable_to_non_nullable
                      as String,
            userId: null == userId
                ? _value.userId
                : userId // ignore: cast_nullable_to_non_nullable
                      as String,
            location: freezed == location
                ? _value.location
                : location // ignore: cast_nullable_to_non_nullable
                      as String?,
            warehouse: freezed == warehouse
                ? _value.warehouse
                : warehouse // ignore: cast_nullable_to_non_nullable
                      as String?,
            zone: freezed == zone
                ? _value.zone
                : zone // ignore: cast_nullable_to_non_nullable
                      as String?,
            shelf: freezed == shelf
                ? _value.shelf
                : shelf // ignore: cast_nullable_to_non_nullable
                      as String?,
            costPrice: freezed == costPrice
                ? _value.costPrice
                : costPrice // ignore: cast_nullable_to_non_nullable
                      as double?,
            totalValue: freezed == totalValue
                ? _value.totalValue
                : totalValue // ignore: cast_nullable_to_non_nullable
                      as double?,
            lastCountDate: freezed == lastCountDate
                ? _value.lastCountDate
                : lastCountDate // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            notes: freezed == notes
                ? _value.notes
                : notes // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$InventoryImplCopyWith<$Res>
    implements $InventoryCopyWith<$Res> {
  factory _$$InventoryImplCopyWith(
    _$InventoryImpl value,
    $Res Function(_$InventoryImpl) then,
  ) = __$$InventoryImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String variantId,
    String userId,
    String? location,
    String? warehouse,
    String? zone,
    String? shelf,
    @JsonKey(fromJson: _parseDoubleNullable) double? costPrice,
    @JsonKey(fromJson: _parseDoubleNullable) double? totalValue,
    DateTime? lastCountDate,
    String? notes,
  });
}

/// @nodoc
class __$$InventoryImplCopyWithImpl<$Res>
    extends _$InventoryCopyWithImpl<$Res, _$InventoryImpl>
    implements _$$InventoryImplCopyWith<$Res> {
  __$$InventoryImplCopyWithImpl(
    _$InventoryImpl _value,
    $Res Function(_$InventoryImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of Inventory
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? variantId = null,
    Object? userId = null,
    Object? location = freezed,
    Object? warehouse = freezed,
    Object? zone = freezed,
    Object? shelf = freezed,
    Object? costPrice = freezed,
    Object? totalValue = freezed,
    Object? lastCountDate = freezed,
    Object? notes = freezed,
  }) {
    return _then(
      _$InventoryImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        variantId: null == variantId
            ? _value.variantId
            : variantId // ignore: cast_nullable_to_non_nullable
                  as String,
        userId: null == userId
            ? _value.userId
            : userId // ignore: cast_nullable_to_non_nullable
                  as String,
        location: freezed == location
            ? _value.location
            : location // ignore: cast_nullable_to_non_nullable
                  as String?,
        warehouse: freezed == warehouse
            ? _value.warehouse
            : warehouse // ignore: cast_nullable_to_non_nullable
                  as String?,
        zone: freezed == zone
            ? _value.zone
            : zone // ignore: cast_nullable_to_non_nullable
                  as String?,
        shelf: freezed == shelf
            ? _value.shelf
            : shelf // ignore: cast_nullable_to_non_nullable
                  as String?,
        costPrice: freezed == costPrice
            ? _value.costPrice
            : costPrice // ignore: cast_nullable_to_non_nullable
                  as double?,
        totalValue: freezed == totalValue
            ? _value.totalValue
            : totalValue // ignore: cast_nullable_to_non_nullable
                  as double?,
        lastCountDate: freezed == lastCountDate
            ? _value.lastCountDate
            : lastCountDate // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        notes: freezed == notes
            ? _value.notes
            : notes // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$InventoryImpl implements _Inventory {
  const _$InventoryImpl({
    required this.id,
    required this.variantId,
    required this.userId,
    this.location,
    this.warehouse,
    this.zone,
    this.shelf,
    @JsonKey(fromJson: _parseDoubleNullable) this.costPrice,
    @JsonKey(fromJson: _parseDoubleNullable) this.totalValue,
    this.lastCountDate,
    this.notes,
  });

  factory _$InventoryImpl.fromJson(Map<String, dynamic> json) =>
      _$$InventoryImplFromJson(json);

  @override
  final String id;
  @override
  final String variantId;
  @override
  final String userId;
  @override
  final String? location;
  @override
  final String? warehouse;
  @override
  final String? zone;
  @override
  final String? shelf;
  @override
  @JsonKey(fromJson: _parseDoubleNullable)
  final double? costPrice;
  @override
  @JsonKey(fromJson: _parseDoubleNullable)
  final double? totalValue;
  @override
  final DateTime? lastCountDate;
  @override
  final String? notes;

  @override
  String toString() {
    return 'Inventory(id: $id, variantId: $variantId, userId: $userId, location: $location, warehouse: $warehouse, zone: $zone, shelf: $shelf, costPrice: $costPrice, totalValue: $totalValue, lastCountDate: $lastCountDate, notes: $notes)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$InventoryImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.variantId, variantId) ||
                other.variantId == variantId) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.location, location) ||
                other.location == location) &&
            (identical(other.warehouse, warehouse) ||
                other.warehouse == warehouse) &&
            (identical(other.zone, zone) || other.zone == zone) &&
            (identical(other.shelf, shelf) || other.shelf == shelf) &&
            (identical(other.costPrice, costPrice) ||
                other.costPrice == costPrice) &&
            (identical(other.totalValue, totalValue) ||
                other.totalValue == totalValue) &&
            (identical(other.lastCountDate, lastCountDate) ||
                other.lastCountDate == lastCountDate) &&
            (identical(other.notes, notes) || other.notes == notes));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    variantId,
    userId,
    location,
    warehouse,
    zone,
    shelf,
    costPrice,
    totalValue,
    lastCountDate,
    notes,
  );

  /// Create a copy of Inventory
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$InventoryImplCopyWith<_$InventoryImpl> get copyWith =>
      __$$InventoryImplCopyWithImpl<_$InventoryImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$InventoryImplToJson(this);
  }
}

abstract class _Inventory implements Inventory {
  const factory _Inventory({
    required final String id,
    required final String variantId,
    required final String userId,
    final String? location,
    final String? warehouse,
    final String? zone,
    final String? shelf,
    @JsonKey(fromJson: _parseDoubleNullable) final double? costPrice,
    @JsonKey(fromJson: _parseDoubleNullable) final double? totalValue,
    final DateTime? lastCountDate,
    final String? notes,
  }) = _$InventoryImpl;

  factory _Inventory.fromJson(Map<String, dynamic> json) =
      _$InventoryImpl.fromJson;

  @override
  String get id;
  @override
  String get variantId;
  @override
  String get userId;
  @override
  String? get location;
  @override
  String? get warehouse;
  @override
  String? get zone;
  @override
  String? get shelf;
  @override
  @JsonKey(fromJson: _parseDoubleNullable)
  double? get costPrice;
  @override
  @JsonKey(fromJson: _parseDoubleNullable)
  double? get totalValue;
  @override
  DateTime? get lastCountDate;
  @override
  String? get notes;

  /// Create a copy of Inventory
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$InventoryImplCopyWith<_$InventoryImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

StockMovement _$StockMovementFromJson(Map<String, dynamic> json) {
  return _StockMovement.fromJson(json);
}

/// @nodoc
mixin _$StockMovement {
  String get id => throw _privateConstructorUsedError;
  String get variantId => throw _privateConstructorUsedError;
  MovementType get type => throw _privateConstructorUsedError;
  @JsonKey(fromJson: _parseInt)
  int get quantity => throw _privateConstructorUsedError;
  @JsonKey(fromJson: _parseInt)
  int get previousStock => throw _privateConstructorUsedError;
  @JsonKey(fromJson: _parseInt)
  int get newStock => throw _privateConstructorUsedError;
  String? get reason => throw _privateConstructorUsedError;
  String? get notes => throw _privateConstructorUsedError;
  String? get userId => throw _privateConstructorUsedError;
  String? get orderId => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;

  /// Serializes this StockMovement to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of StockMovement
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $StockMovementCopyWith<StockMovement> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $StockMovementCopyWith<$Res> {
  factory $StockMovementCopyWith(
    StockMovement value,
    $Res Function(StockMovement) then,
  ) = _$StockMovementCopyWithImpl<$Res, StockMovement>;
  @useResult
  $Res call({
    String id,
    String variantId,
    MovementType type,
    @JsonKey(fromJson: _parseInt) int quantity,
    @JsonKey(fromJson: _parseInt) int previousStock,
    @JsonKey(fromJson: _parseInt) int newStock,
    String? reason,
    String? notes,
    String? userId,
    String? orderId,
    DateTime createdAt,
  });
}

/// @nodoc
class _$StockMovementCopyWithImpl<$Res, $Val extends StockMovement>
    implements $StockMovementCopyWith<$Res> {
  _$StockMovementCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of StockMovement
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? variantId = null,
    Object? type = null,
    Object? quantity = null,
    Object? previousStock = null,
    Object? newStock = null,
    Object? reason = freezed,
    Object? notes = freezed,
    Object? userId = freezed,
    Object? orderId = freezed,
    Object? createdAt = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            variantId: null == variantId
                ? _value.variantId
                : variantId // ignore: cast_nullable_to_non_nullable
                      as String,
            type: null == type
                ? _value.type
                : type // ignore: cast_nullable_to_non_nullable
                      as MovementType,
            quantity: null == quantity
                ? _value.quantity
                : quantity // ignore: cast_nullable_to_non_nullable
                      as int,
            previousStock: null == previousStock
                ? _value.previousStock
                : previousStock // ignore: cast_nullable_to_non_nullable
                      as int,
            newStock: null == newStock
                ? _value.newStock
                : newStock // ignore: cast_nullable_to_non_nullable
                      as int,
            reason: freezed == reason
                ? _value.reason
                : reason // ignore: cast_nullable_to_non_nullable
                      as String?,
            notes: freezed == notes
                ? _value.notes
                : notes // ignore: cast_nullable_to_non_nullable
                      as String?,
            userId: freezed == userId
                ? _value.userId
                : userId // ignore: cast_nullable_to_non_nullable
                      as String?,
            orderId: freezed == orderId
                ? _value.orderId
                : orderId // ignore: cast_nullable_to_non_nullable
                      as String?,
            createdAt: null == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$StockMovementImplCopyWith<$Res>
    implements $StockMovementCopyWith<$Res> {
  factory _$$StockMovementImplCopyWith(
    _$StockMovementImpl value,
    $Res Function(_$StockMovementImpl) then,
  ) = __$$StockMovementImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String variantId,
    MovementType type,
    @JsonKey(fromJson: _parseInt) int quantity,
    @JsonKey(fromJson: _parseInt) int previousStock,
    @JsonKey(fromJson: _parseInt) int newStock,
    String? reason,
    String? notes,
    String? userId,
    String? orderId,
    DateTime createdAt,
  });
}

/// @nodoc
class __$$StockMovementImplCopyWithImpl<$Res>
    extends _$StockMovementCopyWithImpl<$Res, _$StockMovementImpl>
    implements _$$StockMovementImplCopyWith<$Res> {
  __$$StockMovementImplCopyWithImpl(
    _$StockMovementImpl _value,
    $Res Function(_$StockMovementImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of StockMovement
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? variantId = null,
    Object? type = null,
    Object? quantity = null,
    Object? previousStock = null,
    Object? newStock = null,
    Object? reason = freezed,
    Object? notes = freezed,
    Object? userId = freezed,
    Object? orderId = freezed,
    Object? createdAt = null,
  }) {
    return _then(
      _$StockMovementImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        variantId: null == variantId
            ? _value.variantId
            : variantId // ignore: cast_nullable_to_non_nullable
                  as String,
        type: null == type
            ? _value.type
            : type // ignore: cast_nullable_to_non_nullable
                  as MovementType,
        quantity: null == quantity
            ? _value.quantity
            : quantity // ignore: cast_nullable_to_non_nullable
                  as int,
        previousStock: null == previousStock
            ? _value.previousStock
            : previousStock // ignore: cast_nullable_to_non_nullable
                  as int,
        newStock: null == newStock
            ? _value.newStock
            : newStock // ignore: cast_nullable_to_non_nullable
                  as int,
        reason: freezed == reason
            ? _value.reason
            : reason // ignore: cast_nullable_to_non_nullable
                  as String?,
        notes: freezed == notes
            ? _value.notes
            : notes // ignore: cast_nullable_to_non_nullable
                  as String?,
        userId: freezed == userId
            ? _value.userId
            : userId // ignore: cast_nullable_to_non_nullable
                  as String?,
        orderId: freezed == orderId
            ? _value.orderId
            : orderId // ignore: cast_nullable_to_non_nullable
                  as String?,
        createdAt: null == createdAt
            ? _value.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$StockMovementImpl implements _StockMovement {
  const _$StockMovementImpl({
    required this.id,
    required this.variantId,
    required this.type,
    @JsonKey(fromJson: _parseInt) required this.quantity,
    @JsonKey(fromJson: _parseInt) required this.previousStock,
    @JsonKey(fromJson: _parseInt) required this.newStock,
    this.reason,
    this.notes,
    this.userId,
    this.orderId,
    required this.createdAt,
  });

  factory _$StockMovementImpl.fromJson(Map<String, dynamic> json) =>
      _$$StockMovementImplFromJson(json);

  @override
  final String id;
  @override
  final String variantId;
  @override
  final MovementType type;
  @override
  @JsonKey(fromJson: _parseInt)
  final int quantity;
  @override
  @JsonKey(fromJson: _parseInt)
  final int previousStock;
  @override
  @JsonKey(fromJson: _parseInt)
  final int newStock;
  @override
  final String? reason;
  @override
  final String? notes;
  @override
  final String? userId;
  @override
  final String? orderId;
  @override
  final DateTime createdAt;

  @override
  String toString() {
    return 'StockMovement(id: $id, variantId: $variantId, type: $type, quantity: $quantity, previousStock: $previousStock, newStock: $newStock, reason: $reason, notes: $notes, userId: $userId, orderId: $orderId, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$StockMovementImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.variantId, variantId) ||
                other.variantId == variantId) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.quantity, quantity) ||
                other.quantity == quantity) &&
            (identical(other.previousStock, previousStock) ||
                other.previousStock == previousStock) &&
            (identical(other.newStock, newStock) ||
                other.newStock == newStock) &&
            (identical(other.reason, reason) || other.reason == reason) &&
            (identical(other.notes, notes) || other.notes == notes) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.orderId, orderId) || other.orderId == orderId) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    variantId,
    type,
    quantity,
    previousStock,
    newStock,
    reason,
    notes,
    userId,
    orderId,
    createdAt,
  );

  /// Create a copy of StockMovement
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$StockMovementImplCopyWith<_$StockMovementImpl> get copyWith =>
      __$$StockMovementImplCopyWithImpl<_$StockMovementImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$StockMovementImplToJson(this);
  }
}

abstract class _StockMovement implements StockMovement {
  const factory _StockMovement({
    required final String id,
    required final String variantId,
    required final MovementType type,
    @JsonKey(fromJson: _parseInt) required final int quantity,
    @JsonKey(fromJson: _parseInt) required final int previousStock,
    @JsonKey(fromJson: _parseInt) required final int newStock,
    final String? reason,
    final String? notes,
    final String? userId,
    final String? orderId,
    required final DateTime createdAt,
  }) = _$StockMovementImpl;

  factory _StockMovement.fromJson(Map<String, dynamic> json) =
      _$StockMovementImpl.fromJson;

  @override
  String get id;
  @override
  String get variantId;
  @override
  MovementType get type;
  @override
  @JsonKey(fromJson: _parseInt)
  int get quantity;
  @override
  @JsonKey(fromJson: _parseInt)
  int get previousStock;
  @override
  @JsonKey(fromJson: _parseInt)
  int get newStock;
  @override
  String? get reason;
  @override
  String? get notes;
  @override
  String? get userId;
  @override
  String? get orderId;
  @override
  DateTime get createdAt;

  /// Create a copy of StockMovement
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$StockMovementImplCopyWith<_$StockMovementImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
