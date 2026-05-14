import 'package:freezed_annotation/freezed_annotation.dart';

part 'user.freezed.dart';
part 'user.g.dart';

@freezed
class User with _$User {
  const factory User({
    required String id,
    required String phone,
    required String role,
    String? firstName,
    String? lastName,
    String? email,
    String? businessName,
    String? businessAddress,
    @Default('pending') String kycStatus,
    String? profileImage,
  }) = _User;

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
}
