## 1.0.0

- Added synchronous path resolution for temporary, support, documents, cache, downloads, and XDG user directories.
- Added desktop, pictures, music, and videos directory getters backed by XDG user directories with `$HOME` fallbacks.
- Added `getDiskSpace()` and `getDiskSpaceSync()` using `statvfs`, with an injectable resolver for testing.
- Added a direct `ffi` dependency for `statvfs` interop.

## 0.9.0

* Initial federated release of `path_manager_linux` implementing `path_manager_platform_interface` adhering to the XDG Base Directory specification.
