## 1.0.0

- Added synchronous Foundation path resolution for temporary, support, documents, cache, and downloads directories.
- Added desktop, pictures, music, and videos directory getters on macOS. Global media directories throw `UnsupportedError` on iOS.
- Added `getDiskSpace()` and `getDiskSpaceSync()` using `attributesOfFileSystemForPath:error:` with `NSFileSystemFreeSize` and `NSFileSystemSize`.
- Regenerated Objective-C bindings to include the new filesystem-attributes selector.

## 0.9.0

* Initial federated release of `path_manager_foundation` implementing `path_manager_platform_interface` for iOS and macOS via Objective-C FFI.
