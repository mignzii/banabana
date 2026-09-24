import 'package:dio/dio.dart';

/// Message lisible pour l'utilisateur à partir d'une erreur réseau/API.
String apiErrorMessage(Object error) {
  if (error is! DioException) return 'Une erreur est survenue, réessayez';
  switch (error.type) {
    case DioExceptionType.connectionTimeout:
    case DioExceptionType.sendTimeout:
    case DioExceptionType.receiveTimeout:
    case DioExceptionType.connectionError:
      return 'Connexion impossible, vérifiez votre réseau et réessayez';
    default:
      break;
  }
  final status = error.response?.statusCode;
  if (status == 413) {
    return 'Photos trop lourdes : réessayez avec moins de photos';
  }
  final data = error.response?.data;
  if (data is Map) {
    final message = data['message'];
    if (message is String && message.isNotEmpty) return message;
    if (message is List && message.isNotEmpty) return message.join('\n');
  }
  if (status != null && status >= 500) {
    return 'Le serveur rencontre un problème, réessayez plus tard';
  }
  return 'Une erreur est survenue, réessayez';
}
