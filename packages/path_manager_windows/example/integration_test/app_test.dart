import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:path_manager_platform_interface/path_manager_platform_interface.dart';
import 'package:path_manager_windows/path_manager_windows.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('can register and access WindowsPathManager', (tester) async {
    WindowsPathManager.registerWith();
    expect(PlatformPathManager.instance, isA<WindowsPathManager>());

    // On Windows, temp path can be resolved
    final temp = await PlatformPathManager.instance.getTemporaryPath();
    expect(temp, isNotNull);
  });
}
