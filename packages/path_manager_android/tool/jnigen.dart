import 'dart:io';

import 'package:jnigen/jnigen.dart';
import 'package:logging/logging.dart';

const _allowedMethodsByClass = <String, Set<String>>{
  'android.content.Context': {
    'getCacheDir',
    'getFilesDir',
    'getExternalFilesDir',
    'getExternalFilesDirs',
    'getExternalCacheDirs',
  },
  'java.io.File': {'getAbsolutePath'},
  'android.os.StatFs': {'<init>', 'getAvailableBytes', 'getTotalBytes'},
};

void main() async {
  final pkgRoot = Platform.script.resolve('../');

  // Configure logging
  Logger.root.level = Level.INFO;
  Logger.root.onRecord.listen((record) {
    stdout.writeln('${record.level.name}: ${record.message}');
  });

  String? currentClass;
  final generator = JniGenerator(
    visitors: [
      Visitor(
        classDecl: (node) {
          currentClass = node.binaryName;
        },
        method: (node) {
          final allowed = _allowedMethodsByClass[currentClass];
          if (allowed == null || !allowed.contains(node.originalName)) {
            node.isIncluded = false;
          }
        },
        field: (node) {
          node.isIncluded = false;
        },
      ),
    ],
    input: Input(
      classes: [
        'android.content.Context',
        'android.os.StatFs',
        'java.io.File',
      ],
      androidSdk: AndroidSdk(
        addGradleDeps: true,
        androidExample: pkgRoot.resolve('example/'),
      ),
    ),
    output: Output(
      dart: DartOutput(
        path: pkgRoot.resolve('lib/bindings/android.g.dart'),
        structure: .singleFile,
      ),
    ),
  );

  await generator.generate(logger: Logger.root);
}
