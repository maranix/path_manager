import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_native_backup_guard_android/flutter_native_backup_guard_android.dart';
import 'package:flutter_native_backup_guard_platform_interface/flutter_native_backup_guard_platform_interface.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('FlutterNativeBackupGuardAndroid', () {
    test('registers instance', () {
      FlutterNativeBackupGuardAndroid.registerWith();
      expect(
        FlutterNativeBackupGuardPlatform.instance,
        isA<FlutterNativeBackupGuardAndroid>(),
      );
    });

    test('excludeFromBackup delegates to platform channel', () async {
      final log = <String>[];
      const codec = StandardMessageCodec();
      const channelName =
          'dev.flutter.pigeon.flutter_native_backup_guard_platform_interface.BackupGuardApi.excludeFromBackup';

      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMessageHandler(channelName, (ByteData? message) async {
            if (message == null) return null;
            final args = codec.decodeMessage(message) as List<Object?>;
            log.add(args[0] as String);
            return codec.encodeMessage([true]);
          });

      final platform = FlutterNativeBackupGuardAndroid();
      final result = await platform.excludeFromBackup('/test/path/android');

      expect(result, isTrue);
      expect(log, <String>['/test/path/android']);

      // Clean up mock handler
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMessageHandler(channelName, null);
    });

    test('getNoBackupFilesDir delegates to platform channel', () async {
      const codec = StandardMessageCodec();
      const channelName =
          'dev.flutter.pigeon.flutter_native_backup_guard_platform_interface.BackupGuardApi.getNoBackupFilesDir';

      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMessageHandler(channelName, (ByteData? message) async {
            return codec.encodeMessage(['/mock/android/no_backup']);
          });

      final platform = FlutterNativeBackupGuardAndroid();
      final result = await platform.getNoBackupFilesDir();

      expect(result, '/mock/android/no_backup');

      // Clean up mock handler
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMessageHandler(channelName, null);
    });
  });
}
