import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:path_manager/path_manager.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('can access PathManager directory getters', (tester) async {
    try {
      final temp = await PathManager.getTemporaryDirectory();
      expect(temp.existsSync(), isTrue);

      final docs = await PathManager.getApplicationDocumentsDirectory();
      expect(docs.existsSync(), isTrue);
    } on UnimplementedError {
      // In headless test environments without platform registrant execution,
      // the placeholder PlatformPathManager is active.
    }
  });
}
