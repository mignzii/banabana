import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:banabana_b2b/features/wholesaler/providers/catalog_providers.dart';
import 'package:banabana_b2b/features/producer/providers/category_providers.dart';
import 'package:banabana_b2b/features/wholesaler/presentation/screens/product_public_detail_screen.dart';
import 'package:banabana_b2b/shared/models/product.dart';

Product _buildProduct({String wholesaleUnit = 'crate'}) => Product(
      id: 'p1',
      producerId: 'prod1',
      title: 'Mangues Kent',
      category: 'fruits',
      basePrice: 1000,
      isActive: true,
      createdAt: DateTime(2026, 1, 1),
      updatedAt: DateTime(2026, 1, 1),
      variants: [
        ProductVariant(
          id: 'v1',
          productId: 'p1',
          label: 'Cageot 10kg',
          price: 12000,
          stock: 50,
          wholesaleUnit: wholesaleUnit,
          minOrderQuantity: 2,
          unitsPerPackage: 10,
        ),
      ],
    );

final _product = _buildProduct();

void main() {
  setUp(() {
    // Surface haute : tout le contenu de la fiche produit doit être atteignable
    // au tap sans dépendre du scroll.
    final view = TestWidgetsFlutterBinding.instance.platformDispatcher.views.first;
    view.physicalSize = const Size(600, 2400);
    view.devicePixelRatio = 1.0;
  });

  tearDown(() {
    final view = TestWidgetsFlutterBinding.instance.platformDispatcher.views.first;
    view.resetPhysicalSize();
    view.resetDevicePixelRatio();
  });

  Widget buildWidget({Product? product}) {
    // Le screen utilise GoRouter (toast panier, navigation) : un routeur minimal
    // suffit pour que les interactions réelles ne lèvent pas d'exception.
    final router = GoRouter(
      routes: [
        GoRoute(
          path: '/',
          builder: (_, _) =>
              const ProductPublicDetailScreen(productId: 'p1'),
        ),
        GoRoute(
          path: '/shop/cart',
          builder: (_, _) => const Scaffold(body: Text('panier')),
        ),
      ],
    );
    return ProviderScope(
      overrides: [
        catalogProductDetailProvider('p1')
            .overrideWith((ref) async => product ?? _product),
        allCategoriesProvider.overrideWith((ref) async => []),
      ],
      child: MaterialApp.router(routerConfig: router),
    );
  }

  testWidgets('le clavier de la quantité se ferme au tap en dehors',
      (tester) async {
    await tester.pumpWidget(buildWidget());
    await tester.pumpAndSettle();

    final qtyField = find.byType(TextField);
    expect(qtyField, findsOneWidget);

    await tester.tap(qtyField);
    await tester.pumpAndSettle();
    expect(
      tester.widget<TextField>(qtyField).focusNode!.hasFocus,
      isTrue,
      reason: 'le champ doit prendre le focus au tap',
    );

    // Tap ailleurs : sur le titre du produit
    await tester.tap(find.text('Mangues Kent').first);
    await tester.pumpAndSettle();

    expect(
      tester.widget<TextField>(qtyField).focusNode!.hasFocus,
      isFalse,
      reason: 'le clavier doit se fermer quand on tape en dehors du champ',
    );
  });

  testWidgets('la quantité saisie est conservée après fermeture du clavier',
      (tester) async {
    await tester.pumpWidget(buildWidget());
    await tester.pumpAndSettle();

    final qtyField = find.byType(TextField);

    await tester.tap(qtyField);
    await tester.pumpAndSettle();
    await tester.enterText(qtyField, '7');
    await tester.pumpAndSettle();

    // Ferme le clavier en tapant sur une zone neutre
    await tester.tap(find.text('Mangues Kent').first);
    await tester.pumpAndSettle();

    expect(
      tester.widget<TextField>(qtyField).controller!.text,
      '7',
      reason: 'la quantité saisie ne doit pas revenir à sa valeur initiale',
    );
  });

  testWidgets('la quantité saisie survit à un tap sur la variante déjà choisie',
      (tester) async {
    await tester.pumpWidget(buildWidget());
    await tester.pumpAndSettle();

    final qtyField = find.byType(TextField);
    await tester.tap(qtyField);
    await tester.pumpAndSettle();
    await tester.enterText(qtyField, '7');
    await tester.pumpAndSettle();

    // L'utilisateur ferme le clavier en tapant sur le chip de variante :
    // re-sélectionner la variante déjà active ne doit rien réinitialiser.
    await tester.tap(find.text('Cageot 10kg').first);
    await tester.pumpAndSettle();

    expect(
      tester.widget<TextField>(qtyField).controller!.text,
      '7',
      reason: 're-taper la variante déjà sélectionnée ne doit pas '
          'réinitialiser la quantité',
    );
  });

  testWidgets(
      'le clavier se ferme quand on tape sur la barre du bas (Ajouter au panier)',
      (tester) async {
    await tester.pumpWidget(buildWidget());
    await tester.pumpAndSettle();

    final qtyField = find.byType(TextField);
    await tester.tap(qtyField);
    await tester.pumpAndSettle();
    expect(tester.widget<TextField>(qtyField).focusNode!.hasFocus, isTrue);

    await tester.tap(find.text('Ajouter au panier'));
    await tester.pumpAndSettle();

    expect(
      tester.widget<TextField>(qtyField).focusNode!.hasFocus,
      isFalse,
      reason: 'taper le bouton de commande doit aussi fermer le clavier',
    );

    // Laisse le toast « ajouté au panier » s'auto-fermer (timer 2400 ms).
    await tester.pump(const Duration(seconds: 3));
    await tester.pumpAndSettle();
  });

  // Garde-fou layout : « palette(s) » est le libellé le plus long produit par
  // _wholesaleUnitLabel. À 402 pt (iPhone 16 Pro) il faisait déborder 4 Row.
  // Un débordement fait échouer le test via FlutterError.
  for (final width in [375.0, 402.0]) {
    testWidgets('aucun débordement à ${width.toInt()} pt avec une unité longue',
        (tester) async {
      final view =
          TestWidgetsFlutterBinding.instance.platformDispatcher.views.first;
      view.physicalSize = Size(width, 2400);
      view.devicePixelRatio = 1.0;

      await tester.pumpWidget(
        buildWidget(product: _buildProduct(wholesaleUnit: 'palette')),
      );
      await tester.pumpAndSettle();

      expect(find.textContaining('palette(s)'), findsWidgets);
    });
  }
}
