import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:path_manager_foundation/path_manager_foundation.dart';
import 'package:path_manager_platform_interface/path_manager_platform_interface.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('can register and access FoundationPathManager', (tester) async {
    FoundationPathManager.registerWith();
    expect(PlatformPathManager.instance, isA<FoundationPathManager>());

    if (Platform.isMacOS || Platform.isIOS) {
      final temp = await PlatformPathManager.instance.getTemporaryPath();
      expect(temp, isNotNull);
    }
  });
}
