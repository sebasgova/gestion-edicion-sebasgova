import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sebasgova_edicion/main.dart';

void main() {
  testWidgets('la app inicia y muestra el resumen', (tester) async {
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(const SebasgovaApp());
    await tester.pumpAndSettle();
    expect(find.text('Resumen'), findsWidgets);
    expect(find.byType(Scaffold), findsWidgets);
  });

  testWidgets('se puede navegar a Clientes desde el menú', (tester) async {
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(const SebasgovaApp());
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.menu));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Clientes'));
    await tester.pumpAndSettle();
    expect(find.text('Aún no tienes clientes'), findsOneWidget);
  });
}
