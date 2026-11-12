import 'dart:io';

import 'package:jnigen/jnigen.dart';
import 'package:logging/logging.dart';

void main() async {
  final pkgRoot = Platform.script.resolve('../');

  // Configure logging
  Logger.root.level = Level.INFO;
  Logger.root.onRecord.listen((record) {
    stdout.writeln('${record.level.name}: ${record.message}');
  });

  final generator = JniGenerator(
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
