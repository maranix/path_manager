import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:path_manager_foundation_example/main.dart';

void main() {
  testWidgets('Renders path_manager_foundation example app', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());
    expect(find.byType(MaterialApp), findsOneWidget);
    expect(find.text('path_manager_foundation example'), findsOneWidget);
  });
}
