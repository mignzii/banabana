// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$UserImpl _$$UserImplFromJson(Map<String, dynamic> json) => _$UserImpl(
  id: json['id'] as String,
  phone: json['phone'] as String,
  role: json['role'] as String,
  firstName: json['firstName'] as String?,
  lastName: json['lastName'] as String?,
  email: json['email'] as String?,
  businessName: json['businessName'] as String?,
  businessAddress: json['businessAddress'] as String?,
  kycStatus: json['kycStatus'] as String? ?? 'pending',
  profileImage: json['profileImage'] as String?,
);

Map<String, dynamic> _$$UserImplToJson(_$UserImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'phone': instance.phone,
      'role': instance.role,
      'firstName': instance.firstName,
      'lastName': instance.lastName,
      'email': instance.email,
      'businessName': instance.businessName,
      'businessAddress': instance.businessAddress,
      'kycStatus': instance.kycStatus,
      'profileImage': instance.profileImage,
    };
