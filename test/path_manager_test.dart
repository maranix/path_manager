import 'dart:ffi';
import 'dart:io';
import 'package:ffi/ffi.dart' as pkg_ffi;
import 'package:objective_c/objective_c.dart';
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

    test(
      'getApplicationDocumentsDirectory returns a valid directory',
      () async {
        final dir = await PathManager.getApplicationDocumentsDirectory();
        expect(dir, isNotNull);
        expect(dir.existsSync(), isTrue);
      },
    );

    test('getCachesDirectory returns a valid directory', () async {
      final dir = await PathManager.getCachesDirectory();
      expect(dir, isNotNull);
      expect(dir.existsSync(), isTrue);
    });

    test(
      'setApplicationPathIsExcludedFromBackup excludes file and directory from backup',
      () async {
        final dir = await PathManager.getApplicationDocumentsDirectory();

        bool getIsExcluded(String path) {
          final nsPath = NSString(path);
          final url = NSURL.fileURLWithPath(nsPath);
          final key = NSString('NSURLIsExcludedFromBackupKey');
          final valPtrPtr = pkg_ffi.calloc<Pointer<ObjCObjectImpl>>();
          try {
            final success = url.getResourceValue(valPtrPtr, forKey: key);
            expect(success, isTrue);
            expect(valPtrPtr.value, isNot(nullptr));
            final getVal = NSNumber.fromPointer(
              valPtrPtr.value,
              retain: true,
              release: true,
            );
            return getVal.boolValue;
          } finally {
            pkg_ffi.calloc.free(valPtrPtr);
          }
        }

        // Test with a temporary file
        final file = File('${dir.path}/test_backup_exclusion.txt');
        await file.writeAsString('test');
        try {
          // Set exclusion to true
          await PathManager.setApplicationPathIsExcludedFromBackup(
            file.path,
            true,
          );
          expect(getIsExcluded(file.path), isTrue);

          // Set exclusion to false
          await PathManager.setApplicationPathIsExcludedFromBackup(
            file.path,
            false,
          );
          expect(getIsExcluded(file.path), isFalse);
        } finally {
          if (await file.exists()) {
            await file.delete();
          }
        }

        // Test with a temporary directory
        final subDir = Directory('${dir.path}/test_backup_exclusion_dir');
        await subDir.create();
        try {
          await PathManager.setApplicationPathIsExcludedFromBackup(
            subDir.path,
            true,
          );
          expect(getIsExcluded(subDir.path), isTrue);
        } finally {
          if (await subDir.exists()) {
            await subDir.delete();
          }
        }
      },
    );

    test(
      'setApplicationPathIsExcludedFromBackup throws FileSystemException on non-existent paths',
      () async {
        expect(
          () => PathManager.setApplicationPathIsExcludedFromBackup(
            'non_existent_file_123_xyz.txt',
            true,
          ),
          throwsA(isA<FileSystemException>()),
        );
      },
    );
  });
}
