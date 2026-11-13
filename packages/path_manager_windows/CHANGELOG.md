## 1.0.0

- Application support and cache directories are now scoped to the executable's `CompanyName\ProductName` metadata, falling back to the executable name.
- Added synchronous path resolution for temporary, support, documents, cache, and downloads directories.
- Added desktop, pictures, music, and videos directory getters backed by Win32 Known Folders.
- Added `getDiskSpace()` and `getDiskSpaceSync()` using `GetDiskFreeSpaceExW`, with an injectable resolver for testing.

## 0.9.0

* Initial federated release of `path_manager_windows` implementing `path_manager_platform_interface` using Win32 Shell Known Folders (`SHGetKnownFolderPath`) and `GetTempPath2W` via FFI.
