import 'package:flutter_test/flutter_test.dart';
import 'package:banabana_b2b/shared/utils/seller_name.dart';

void main() {
  group('sellerDisplayName', () {
    test('garde un vrai nom d\'entreprise', () {
      expect(sellerDisplayName(businessName: 'Fermebioschool'), 'Fermebioschool');
      expect(sellerDisplayName(businessName: '124 North Foire'), '124 North Foire');
    });

    test('ne montre jamais un nom généré à partir du téléphone', () {
      expect(sellerDisplayName(businessName: 'Producer +221763001234'), 'Producteur');
      expect(sellerDisplayName(businessName: 'Wholesaler +221770000002'), 'Grossiste');
      expect(sellerDisplayName(businessName: '+221 77 123 45 67'), 'Vendeur');
    });

    test('préfère le nom de la personne au nom généré', () {
      expect(
        sellerDisplayName(
          businessName: 'Producer +2250700000013',
          firstName: 'Kofi',
          lastName: 'Asante',
        ),
        'Kofi Asante',
      );
    });

    test('le nom calculé par le serveur passe en premier', () {
      expect(
        sellerDisplayName(displayName: 'Kemet', businessName: 'Producer +221700000000'),
        'Kemet',
      );
    });

    test('valeurs vides : libellé de repli', () {
      expect(sellerDisplayName(businessName: '  '), 'Vendeur');
      expect(sellerDisplayName(fallback: 'Grossiste'), 'Grossiste');
    });
  });
}
