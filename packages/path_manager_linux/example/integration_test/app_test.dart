import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:path_manager_linux/path_manager_linux.dart';
import 'package:path_manager_platform_interface/path_manager_platform_interface.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('can register and access LinuxPathManager', (tester) async {
    LinuxPathManager.registerWith();
    expect(PlatformPathManager.instance, isA<LinuxPathManager>());

    final temp = await PlatformPathManager.instance.getTemporaryPath();
    expect(temp, isNotNull);
  });
}
