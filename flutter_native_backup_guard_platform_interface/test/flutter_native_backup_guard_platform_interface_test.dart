import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_native_backup_guard_platform_interface/flutter_native_backup_guard_platform_interface.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('FlutterNativeBackupGuardPlatform', () {
    test('default instance is MethodChannelFlutterNativeBackupGuard', () {
      expect(
        FlutterNativeBackupGuardPlatform.instance,
        isA<MethodChannelFlutterNativeBackupGuard>(),
      );
    });

    test('excludeFromBackup calls binary messenger with correct path', () async {
      final log = <String>[];
      const codec = StandardMessageCodec();

      const channelName =
          'dev.flutter.pigeon.flutter_native_backup_guard_platform_interface.BackupGuardApi.excludeFromBackup';

      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMessageHandler(channelName, (ByteData? message) async {
            if (message == null) return null;
            final args = codec.decodeMessage(message) as List<Object?>;
            log.add(args[0] as String);
            return codec.encodeMessage([true]); // Pigeon wrapped success result
          });

      final platform = FlutterNativeBackupGuardPlatform.instance;
      final result = await platform.excludeFromBackup('/test/path');

      expect(result, isTrue);
      expect(log, <String>['/test/path']);

      // Clean up mock handler
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMessageHandler(channelName, null);
    });

    test('getNoBackupFilesDir calls binary messenger and returns path', () async {
      const codec = StandardMessageCodec();
      const channelName =
          'dev.flutter.pigeon.flutter_native_backup_guard_platform_interface.BackupGuardApi.getNoBackupFilesDir';

      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMessageHandler(channelName, (ByteData? message) async {
            return codec.encodeMessage([
              '/mock/no_backup_dir',
            ]); // Pigeon wrapped string result
          });

      final platform = FlutterNativeBackupGuardPlatform.instance;
      final result = await platform.getNoBackupFilesDir();

      expect(result, '/mock/no_backup_dir');

      // Clean up mock handler
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMessageHandler(channelName, null);
    });
  });
}
