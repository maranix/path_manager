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
      expect(PlatformPathManager.instance.getTemporaryPathSync(), temp);

      final support = await PlatformPathManager.instance
          .getApplicationSupportPath();
      expect(
        PlatformPathManager.instance.getApplicationSupportPathSync(),
        support,
      );

      final space = PlatformPathManager.instance.getDiskSpaceSync();
      expect(space, isNotNull);
      expect(space!.totalBytes, greaterThan(0));

      if (Platform.isMacOS) {
        expect(PlatformPathManager.instance.getDesktopPathSync(), isNotEmpty);
        expect(PlatformPathManager.instance.getVideosPathSync(), isNotEmpty);
      } else {
        expect(
          () => PlatformPathManager.instance.getDesktopPathSync(),
          throwsA(isA<UnsupportedError>()),
        );
      }
    }
  });
}
