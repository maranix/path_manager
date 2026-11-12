import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:path_manager_example/main.dart';

void main() {
  testWidgets('Renders PathManager example app', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());
    expect(find.byType(MaterialApp), findsOneWidget);
    expect(find.text('PathManager Example'), findsOneWidget);
  });
}
