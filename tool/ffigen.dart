import 'dart:io';

import 'package:ffigen/ffigen.dart' as fg;
import 'package:logging/logging.dart';

void main(List<String> args) {
  final pkgRoot = Platform.script.resolve('../');
  final logger = Logger.root;

  logger.onRecord
      .map((r) => '${r.level.name} ${r.message}')
      .listen(stdout.writeln);

  fg.FfiGenerator(
    output: fg.Output(
      dartFile: pkgRoot.resolve('lib/bindings/foundation/bindings.g.dart'),
      objectiveCFile: pkgRoot.resolve('lib/bindings/foundation/bindings.m'),
      style: const fg.DynamicLibraryBindings(
        wrapperName: 'FoundationFFI',
        wrapperDocComment: 'Bindings for NSFileManager & URLResolve.',
      ),
    ),
    headers: fg.Headers(
      entryPoints: <Uri>[
        Uri.file(
          '${fg.macSdkPath}/System/Library/Frameworks/Foundation.framework/Headers/NSFileManager.h',
        ),
        Uri.file(
          '${fg.macSdkPath}/System/Library/Frameworks/Foundation.framework/Headers/NSURL.h',
        ),
      ],
    ),
    objectiveC: fg.ObjectiveC(
      interfaces: fg.Interfaces(
        include: (decl) => <String>{
          'NSFileManager',
        }.contains(decl.originalName),
        includeMember: (decl, member) => switch (decl.originalName) {
          'NSFileManager' => <String>{
            'temporaryDirectory',
            'defaultManager',
            'createDirectoryAtURL:withIntermediateDirectories:attributes:error:',
            'URLForDirectory:inDomain:appropriateForURL:create:error:',
          }.contains(member),
          _ => false,
        },
      ),
      // categories: fg.Categories(
      //   include: (decl) => <String>{
      //     // For URLByAppendingPathComponent:
      //     'NSURLPathUtilities',
      //   }.contains(decl.originalName),
      //   includeTransitive: false,
      // ),
    ),
    functions: fg.Functions.includeSet(<String>{
      'NSSearchPathForDirectoriesInDomains',
    }),
  ).generate(logger: logger);
}
