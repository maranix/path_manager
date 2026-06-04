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

  final config = Config(
    outputConfig: OutputConfig(
      dartConfig: DartCodeOutputConfig(
        path: pkgRoot.resolve('lib/bindings/android/bindings.g.dart'),
        structure: OutputStructure.singleFile,
      ),
    ),
    classes: [
      'android.content.Context',
      'java.io.File',
    ],
    androidSdkConfig: AndroidSdkConfig(
      addGradleDeps: true,
      androidExample: 'example/',
    ),
  );

  await generateJniBindings(config);
}
