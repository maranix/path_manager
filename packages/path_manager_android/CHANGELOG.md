## 1.0.0

- Added synchronous path resolution through JNI for temporary, support, documents, cache, and downloads directories.
- Added global media directory getters that throw `UnsupportedError` under Android scoped storage.
- Added `getDiskSpace()` and `getDiskSpaceSync()` using `android.os.StatFs`, with `availableBytes` and `totalBytes`.
- Regenerated JNI bindings with a class-aware `jnigen` method allowlist that includes `android.os.StatFs`.

## 0.9.0

* Initial federated release of `path_manager_android` implementing `path_manager_platform_interface` via JNI FFI.
