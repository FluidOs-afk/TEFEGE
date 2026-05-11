import 'package:flutter_test/flutter_test.dart';

import 'package:app/main.dart';

void main() {
  testWidgets('Outfy app renders the main navigation', (tester) async {
    await tester.pumpWidget(const OutfyApp());

    expect(find.text('Inicio'), findsOneWidget);
    expect(find.text('Armario'), findsOneWidget);
    expect(find.text('Foro'), findsOneWidget);
    expect(find.text('Perfil'), findsOneWidget);
  });
}
