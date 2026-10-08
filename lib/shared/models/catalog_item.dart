import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:banabana_b2b/shared/utils/seller_name.dart';

part 'catalog_item.freezed.dart';
part 'catalog_item.g.dart';

double _parseDouble(dynamic v) =>
    v is String ? double.parse(v) : (v as num).toDouble();

int _parseInt(dynamic v) =>
    v is String ? int.parse(v) : (v as num).toInt();

@freezed
class CatalogProducer with _$CatalogProducer {
  const factory CatalogProducer({
    required String businessName,
    required String zone,
    // Nom à afficher calculé par le serveur, et nom de la personne : utilisés
    // à la place d'un nom d'entreprise généré (« Producer +221… »).
    String? displayName,
    String? firstName,
    String? lastName,
  }) = _CatalogProducer;

  factory CatalogProducer.fromJson(Map<String, dynamic> json) =>
      _$CatalogProducerFromJson(json);
}

extension CatalogProducerName on CatalogProducer {
  String get name => sellerDisplayName(
        displayName: displayName,
        businessName: businessName,
        firstName: firstName,
        lastName: lastName,
      );
}

@freezed
class CatalogItem with _$CatalogItem {
  const factory CatalogItem({
    required String id,
    required String title,
    required String category,
    String? description,
    @JsonKey(fromJson: _parseDouble) required double basePrice,
    required bool isActive,
    required DateTime createdAt,
    required CatalogProducer producer,
    @JsonKey(fromJson: _parseDouble) required double minPrice,
    @JsonKey(fromJson: _parseDouble) required double maxPrice,
    @JsonKey(fromJson: _parseInt) required int totalStock,
    String? mainImage,
  }) = _CatalogItem;

  factory CatalogItem.fromJson(Map<String, dynamic> json) =>
      _$CatalogItemFromJson(json);
}

@freezed
class CatalogPagination with _$CatalogPagination {
  const factory CatalogPagination({
    @JsonKey(fromJson: _parseInt) required int page,
    @JsonKey(fromJson: _parseInt) required int limit,
    @JsonKey(fromJson: _parseInt) required int total,
    @JsonKey(fromJson: _parseInt) required int pages,
  }) = _CatalogPagination;

  factory CatalogPagination.fromJson(Map<String, dynamic> json) =>
      _$CatalogPaginationFromJson(json);
}

@freezed
class CatalogResult with _$CatalogResult {
  const factory CatalogResult({
    required List<CatalogItem> data,
    required CatalogPagination pagination,
  }) = _CatalogResult;

  factory CatalogResult.fromJson(Map<String, dynamic> json) =>
      _$CatalogResultFromJson(json);
}
