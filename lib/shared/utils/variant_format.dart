import 'package:intl/intl.dart';

final _number = NumberFormat('#,##0.###', 'fr_FR');

/// Contenance d'une variante : « 50 kg », « 20 L » ou « 25 kg · 20 L ».
/// Renvoie null quand ni le poids ni le volume ne sont renseignés.
String? variantContentLabel({double? weight, double? volume}) {
  final parts = [
    if (weight != null && weight > 0) '${_number.format(weight)} kg',
    if (volume != null && volume > 0) '${_number.format(volume)} L',
  ];
  return parts.isEmpty ? null : parts.join(' · ');
}

/// Nombre saisi par l'utilisateur, avec virgule ou point décimal.
double? parseDecimal(String input) {
  final value = input.trim().replaceAll(' ', '').replaceAll(',', '.');
  if (value.isEmpty) return null;
  return double.tryParse(value);
}

/// Valeur d'un champ décimal pré-rempli (sans « .0 » inutile).
String formatDecimalInput(double? value) {
  if (value == null) return '';
  return value == value.roundToDouble()
      ? value.toStringAsFixed(0)
      : value.toString().replaceAll('.', ',');
}
