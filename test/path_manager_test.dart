import 'dart:io';
import 'package:test/test.dart';
import 'package:path_manager/path_manager.dart';

void main() {
  group('PathManager tests', () {
    test('getTemporaryPath returns a valid path', () async {
      final path = await PathManager.getTemporaryPath();
      expect(path, isNotNull);
      expect(Directory(path!).existsSync(), isTrue);
    });

    test('getApplicationSupportPath returns a valid path', () async {
      final path = await PathManager.getApplicationSupportPath();
      expect(path, isNotNull);
      // Under sandboxed macOS or command line dart, this dir may or may not exist until created
      expect(path, isNotEmpty);
    });

    test('getDocumentsPath returns a valid path', () async {
      final path = await PathManager.getDocumentsPath();
      expect(path, isNotNull);
      expect(Directory(path!).existsSync(), isTrue);
    });

    test('getCachesPath returns a valid path', () async {
      final path = await PathManager.getCachesPath();
      expect(path, isNotNull);
      expect(Directory(path!).existsSync(), isTrue);
    });
  });
}
