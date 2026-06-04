import 'package:test/test.dart';
import 'package:path_manager/path_manager.dart';

void main() {
  group('PathManager tests', () {
    test('getTemporaryDirectory returns a valid directory', () async {
      final dir = await PathManager.getTemporaryDirectory();
      expect(dir, isNotNull);
      expect(dir.existsSync(), isTrue);
    });

    test('getApplicationSupportDirectory returns a valid directory', () async {
      final dir = await PathManager.getApplicationSupportDirectory();
      expect(dir, isNotNull);
      // Under sandboxed macOS or command line dart, this dir may or may not exist until created
      expect(dir.path, isNotEmpty);
    });

    test('getApplicationDocumentsDirectory returns a valid directory', () async {
      final dir = await PathManager.getApplicationDocumentsDirectory();
      expect(dir, isNotNull);
      expect(dir.existsSync(), isTrue);
    });

    test('getCachesDirectory returns a valid directory', () async {
      final dir = await PathManager.getCachesDirectory();
      expect(dir, isNotNull);
      expect(dir.existsSync(), isTrue);
    });
  });
}
