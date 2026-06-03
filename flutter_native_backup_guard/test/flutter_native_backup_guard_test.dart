import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_native_backup_guard/flutter_native_backup_guard.dart';
import 'package:flutter_native_backup_guard_platform_interface/flutter_native_backup_guard_platform_interface.dart';

class FakeFlutterNativeBackupGuardPlatform
    extends FlutterNativeBackupGuardPlatform {
  String? lastPath;
  bool returnVal = true;
  String returnPathVal = '/mock/no_backup';

  @override
  Future<bool> excludeFromBackup(String path) async {
    lastPath = path;
    return returnVal;
  }

  @override
  Future<String> getNoBackupFilesDir() async {
    return returnPathVal;
  }
}

void main() {
  group('FlutterNativeBackupGuard', () {
    test('excludeFromBackup delegates to platform instance', () async {
      final fakePlatform = FakeFlutterNativeBackupGuardPlatform();
      FlutterNativeBackupGuardPlatform.instance = fakePlatform;

      fakePlatform.returnVal = true;
      final result1 = await FlutterNativeBackupGuard.excludeFromBackup(
        '/path/one',
      );
      expect(result1, isTrue);
      expect(fakePlatform.lastPath, '/path/one');

      fakePlatform.returnVal = false;
      final result2 = await FlutterNativeBackupGuard.excludeFromBackup(
        '/path/two',
      );
      expect(result2, isFalse);
      expect(fakePlatform.lastPath, '/path/two');
    });

    test('getNoBackupFilesDir delegates to platform instance', () async {
      final fakePlatform = FakeFlutterNativeBackupGuardPlatform();
      FlutterNativeBackupGuardPlatform.instance = fakePlatform;

      fakePlatform.returnPathVal = '/custom/no_backup';
      final result = await FlutterNativeBackupGuard.getNoBackupFilesDir();
      expect(result, '/custom/no_backup');
    });
  });
}
