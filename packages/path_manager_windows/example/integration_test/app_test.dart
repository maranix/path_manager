import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:path_manager_platform_interface/path_manager_platform_interface.dart';
import 'package:path_manager_windows/path_manager_windows.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('can register and access WindowsPathManager', (tester) async {
    WindowsPathManager.registerWith();
    expect(PlatformPathManager.instance, isA<WindowsPathManager>());

    // On Windows host, temp path can be resolved natively
    if (Platform.isWindows) {
      final temp = await PlatformPathManager.instance.getTemporaryPath();
      expect(temp, isNotNull);
      expect(PlatformPathManager.instance.getTemporaryPathSync(), temp);

      expect(PlatformPathManager.instance.getDesktopPathSync(), isNotEmpty);
      expect(PlatformPathManager.instance.getDownloadsPathSync(), isNotEmpty);

      final space = PlatformPathManager.instance.getDiskSpaceSync();
      expect(space, isNotNull);
      expect(space!.totalBytes, greaterThan(0));
    }
  });
}
