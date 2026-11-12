import 'package:flutter_test/flutter_test.dart';
import 'package:path_manager_android/path_manager_android.dart';
import 'package:path_manager_platform_interface/path_manager_platform_interface.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AndroidPathManager registration & interface compliance', () {
    test('registers as default instance on registerWith', () {
      AndroidPathManager.registerWith();
      expect(PlatformPathManager.instance, isA<AndroidPathManager>());
    });

    test('can set instance directly without token verification failure', () {
      final manager = AndroidPathManager();
      PlatformPathManager.instance = manager;
      expect(PlatformPathManager.instance, same(manager));
    });

    test('setApplicationPathIsExcludedFromBackup throws UnsupportedError', () {
      final manager = AndroidPathManager();
      expect(
        () => manager.setApplicationPathIsExcludedFromBackup('/fake/path', true),
        throwsA(isA<UnsupportedError>()),
      );
    });
  });
}
