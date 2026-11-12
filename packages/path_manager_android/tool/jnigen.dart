import 'dart:io';

import 'package:jnigen/jnigen.dart';
import 'package:logging/logging.dart';

const _allowedMethods = {
  'getCacheDir',
  'getFilesDir',
  'getExternalFilesDir',
  'getExternalFilesDirs',
  'getExternalCacheDirs',
  'getAbsolutePath',
};

void main() async {
  final pkgRoot = Platform.script.resolve('../');

  // Configure logging
  Logger.root.level = Level.INFO;
  Logger.root.onRecord.listen((record) {
    stdout.writeln('${record.level.name}: ${record.message}');
  });

  final generator = JniGenerator(
    visitors: [
      Visitor(
        method: (node) {
          if (!_allowedMethods.contains(node.originalName)) {
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
