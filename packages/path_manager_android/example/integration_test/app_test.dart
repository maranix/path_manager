import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:path_manager_android/path_manager_android.dart';
import 'package:path_manager_platform_interface/path_manager_platform_interface.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('can register and access AndroidPathManager', (tester) async {
    AndroidPathManager.registerWith();
    expect(PlatformPathManager.instance, isA<AndroidPathManager>());

    final cache = await PlatformPathManager.instance.getApplicationCachePath();
    expect(cache, isNotNull);
    expect(PlatformPathManager.instance.getApplicationCachePathSync(), cache);

    final space = PlatformPathManager.instance.getDiskSpaceSync();
    expect(space, isNotNull);
    expect(space!.totalBytes, greaterThan(0));

    expect(
      () => PlatformPathManager.instance.getDesktopPathSync(),
      throwsA(isA<UnsupportedError>()),
    );
  });
}
