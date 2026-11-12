import 'dart:io';

import 'package:ffigen/ffigen.dart';
import 'package:logging/logging.dart';

const _allowedNSFileManagerMembers = {
  'temporaryDirectory',
  'defaultManager',
  'createDirectoryAtURL:withIntermediateDirectories:attributes:error:',
  'URLForDirectory:inDomain:appropriateForURL:create:error:',
  'attributesOfFileSystemForPath:error:',
};

void main() async {
  final pkgRoot = Platform.script.resolve('../');

  Logger.root.level = Level.INFO;
  Logger.root.onRecord.listen((r) {
    stdout.writeln('${r.level.name} ${r.message}');
  });

  final generator = FfiGenerator(
    objectiveC: const ObjectiveC(),
    input: Input(
      entryPoints: [
        macSdkUri.resolve(
          'System/Library/Frameworks/Foundation.framework/Headers/NSFileManager.h',
        ),
      ],
    ),
    visitors: [
      Visitor(
        objCInterface: (node) {
          node.isIncluded = node.name == 'NSFileManager';
        },
        objCMethod: (node) {
          final parent = node.parent;
          if (parent is ObjCInterface && parent.name == 'NSFileManager') {
            node.isIncluded = _allowedNSFileManagerMembers.contains(
              node.selector,
            );
          }
        },
        enumClass: (node) {
          node.silenceWarning = true;
        },
      ),
    ],
    output: Output(
      dart: DartOutput(
        path: pkgRoot.resolve('lib/bindings/foundation.g.dart'),
      ),
    ),
  );

  await generator.generate(logger: Logger.root);
}
