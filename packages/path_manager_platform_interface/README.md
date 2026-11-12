# path_manager_platform_interface

A common platform interface for the [`path_manager`](https://pub.dev/packages/path_manager) plugin.

This package defines the core contract, storage categories, and exceptions that platform implementations must implement.

## Usage

To implement a new platform for `path_manager`, extend `PlatformPathManager`:

```dart
class MyPlatformPathManager extends PlatformPathManager {
  static void registerWith() {
    PlatformPathManager.instance = MyPlatformPathManager();
  }

  @override
  Future<String?> getTemporaryPath() async {
    // Platform-specific resolution
  }
}
```
