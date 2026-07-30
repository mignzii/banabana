import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:banabana_b2b/shared/widgets/loading_shimmer.dart';

/// Le placeholder image de CatalogItemCard vit dans un slot carré (179×179 sur
/// iPhone 16 Pro). Ce test vérifie qu'un widget de remplacement y tient, et
/// documente pourquoi ProductCardShimmer — squelette de carte complet — n'y
/// tenait pas (débordement de 46 px observé à l'exécution).
Widget _inImageSlot(Widget child) => MaterialApp(
      home: Scaffold(
        body: Center(
          child: SizedBox(
            width: 179,
            height: 179,
            child: child,
          ),
        ),
      ),
    );

void main() {
  testWidgets('ShimmerBox pleine hauteur tient dans le slot image',
      (tester) async {
    await tester.pumpWidget(
      _inImageSlot(const ShimmerBox(height: double.infinity, borderRadius: 0)),
    );
    await tester.pump();

    expect(tester.takeException(), isNull);
    expect(tester.getSize(find.byType(ShimmerBox)), const Size(179, 179));
  });

  testWidgets('ProductCardShimmer déborde du slot image (régression)',
      (tester) async {
    await tester.pumpWidget(_inImageSlot(const ProductCardShimmer()));
    await tester.pump();

    final err = tester.takeException();
    expect(
      err,
      isNotNull,
      reason: 'le squelette de carte complet ne tient pas dans la zone image — '
          "c'est pourquoi il ne doit pas servir de placeholder",
    );
    expect(err.toString(), contains('overflowed'));
  });
}
