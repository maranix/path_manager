## 1.0.0

- Added synchronous directory getters for temporary, application support, documents, cache, and downloads directories.
- Added `getDesktopDirectory()`, `getPicturesDirectory()`, `getMusicDirectory()`, and `getVideosDirectory()` with synchronous counterparts.
- Added `getDiskSpace()` and `getDiskSpaceSync()`, reporting the free and total capacity of the volume containing a path, in bytes. Failures throw `FileSystemException`.
- Added `getApplicationCacheSize()` (returns bytes), `clearApplicationCache()`, and `formatBytes()`.
- Added `getApplicationSupportSubdirectory()`, `getApplicationCacheSubdirectory()`, and `getApplicationDocumentsSubdirectory()` with hardened path validation.
- Added `path` as a direct dependency for subdirectory normalization.

## 0.9.0

- Converted to federated plugin architecture.
- Added Linux desktop support via `path_manager_linux` (XDG Base Directory specification).
- Added Windows desktop support via `path_manager_windows` (Win32 Known Folders).
- Endorsed `path_manager_android`, `path_manager_foundation`, `path_manager_linux`, and `path_manager_windows`.
