import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:path_manager_android/path_manager_android.dart';
import 'package:path_manager_platform_interface/path_manager_platform_interface.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('can register and access AndroidPathManager', (tester) async {
    AndroidPathManager.registerWith();
    expect(PlatformPathManager.instance, isA<AndroidPathManager>());
  });
}
