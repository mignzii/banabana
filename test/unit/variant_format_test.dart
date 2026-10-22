import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:banabana_b2b/shared/utils/variant_format.dart';

void main() {
  setUpAll(() => initializeDateFormatting('fr_FR'));

  group('variantContentLabel', () {
    test('poids seul, volume seul, les deux', () {
      expect(variantContentLabel(weight: 50), '50 kg');
      expect(variantContentLabel(volume: 20), '20 L');
      expect(variantContentLabel(weight: 25, volume: 1.5), '25 kg · 1,5 L');
    });

    test('rien de renseigné', () {
      expect(variantContentLabel(), isNull);
      expect(variantContentLabel(weight: 0), isNull);
    });
  });

  group('parseDecimal', () {
    test('virgule ou point', () {
      expect(parseDecimal('1,5'), 1.5);
      expect(parseDecimal('2.25'), 2.25);
      expect(parseDecimal(' 50 '), 50);
    });

    test('vide ou invalide', () {
      expect(parseDecimal(''), isNull);
      expect(parseDecimal('abc'), isNull);
    });
  });

  test('formatDecimalInput', () {
    expect(formatDecimalInput(null), '');
    expect(formatDecimalInput(50), '50');
    expect(formatDecimalInput(1.5), '1,5');
  });
}
