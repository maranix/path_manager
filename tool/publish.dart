import 'dart:io';

/// Topological publish order: dependencies first, facade last.
const List<String> kPublishOrder = [
  'path_manager_platform_interface',
  'path_manager_android',
  'path_manager_foundation',
  'path_manager_linux',
  'path_manager_windows',
  'path_manager',
];

void main(List<String> args) async {
  if (args.contains('-h') || args.contains('--help')) {
    _printUsage();
    exit(0);
  }

  final isDryRun =
      !args.contains('--publish') && !args.contains('--no-dry-run');
  final force = args.contains('--force') || args.contains('-f');

  // Filter out flags to find the target argument
  final nonFlags = args.where((arg) => !arg.startsWith('-')).toList();

  String target = 'all';
  if (nonFlags.isNotEmpty) {
    target = nonFlags.first;
  }

  List<String> toPublish = [];
  if (target == 'all') {
    toPublish = List.from(kPublishOrder);
  } else {
    if (!kPublishOrder.contains(target)) {
      stderr.writeln(
        'Unknown package "$target". Valid packages are:\n  - all\n  - ${kPublishOrder.join('\n  - ')}',
      );
      exit(1);
    }
    toPublish = [target];
  }

  stdout.writeln('========================================================');
  stdout.writeln(' PathManager Federated Plugin Publishing Tool');
  stdout.writeln(
    ' Mode: ${isDryRun ? "DRY-RUN (Safe)" : "LIVE PUBLISH (pub.dev)"}',
  );
  stdout.writeln(' Targets: ${toPublish.join(", ")}');
  stdout.writeln('========================================================\n');

  if (!isDryRun && !force) {
    stdout.write(
      'Are you sure you want to proceed with LIVE publication to pub.dev? [y/N]: ',
    );
    final input = stdin.readLineSync()?.trim().toLowerCase();
    if (input != 'y' && input != 'yes') {
      stdout.writeln('Aborted.');
      exit(0);
    }
    stdout.writeln();
  }

  final rootDir = Directory.current.path;

  for (final pkg in toPublish) {
    final pkgDir = Directory('$rootDir/packages/$pkg');
    if (!pkgDir.existsSync()) {
      stderr.writeln('Error: Directory not found: ${pkgDir.path}');
      exit(1);
    }

    stdout.writeln('--> Processing "$pkg"...');

    // 1. Always run dry-run first
    stdout.writeln('    Validating dry-run...');
    final dryRunProcess = await Process.run(
      'dart',
      ['pub', 'publish', '--dry-run'],
      workingDirectory: pkgDir.path,
    );

    if (dryRunProcess.exitCode != 0) {
      stderr.writeln('❌ Dry-run validation failed for "$pkg":');
      stderr.writeln(dryRunProcess.stdout);
      stderr.writeln(dryRunProcess.stderr);
      exit(1);
    }
    stdout.writeln('    ✓ Dry-run validation passed (0 warnings).');

    // 2. Perform actual publish if requested
    if (!isDryRun) {
      stdout.writeln('    🚀 Publishing to pub.dev...');
      final publishArgs = ['pub', 'publish'];
      if (force) {
        publishArgs.add('--force');
      }

      final publishProcess = await Process.start(
        'dart',
        publishArgs,
        workingDirectory: pkgDir.path,
        mode: ProcessStartMode.inheritStdio,
      );

      final code = await publishProcess.exitCode;
      if (code != 0) {
        stderr.writeln('❌ Failed to publish "$pkg" (exit code $code).');
        exit(code);
      }
      stdout.writeln('    ✓ Successfully published "$pkg".\n');
    } else {
      stdout.writeln('    [Dry-run completed for "$pkg"]\n');
    }
  }

  stdout.writeln('========================================================');
  if (isDryRun) {
    stdout.writeln(
      '✓ All selected packages validated successfully in dry-run mode.',
    );
    stdout.writeln('To publish live to pub.dev, re-run with:');
    stdout.writeln(
      '  dart run tool/publish.dart ${target == "all" ? "all" : target} --publish',
    );
  } else {
    stdout.writeln('🎉 All selected packages have been published to pub.dev!');
  }
  stdout.writeln('========================================================');
}

void _printUsage() {
  stdout.writeln('''
Usage:
  dart run tool/publish.dart [package_name | all] [options]

Packages:
  all (default)                     Publish all federated packages in dependency order
  path_manager_platform_interface   Publish only the platform interface
  path_manager_android              Publish only Android package
  path_manager_foundation           Publish only iOS/macOS Foundation package
  path_manager_linux                Publish only Linux package
  path_manager_windows              Publish only Windows package
  path_manager                      Publish only the main app-facing package

Options:
  --dry-run                         Run in validation mode without publishing (default)
  --publish                         Perform actual publication to pub.dev
  -f, --force                       Bypass interactive prompts
  -h, --help                        Show this help message

Examples:
  # Validate all packages with dry-run
  dart run tool/publish.dart all

  # Validate a single package
  dart run tool/publish.dart path_manager_windows

  # Publish all packages to pub.dev
  dart run tool/publish.dart all --publish

  # Publish a single package to pub.dev
  dart run tool/publish.dart path_manager_platform_interface --publish
''');
}
