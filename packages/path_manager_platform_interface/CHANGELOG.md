## 1.0.0

- Added synchronous path contracts for temporary, application support, documents, cache, and downloads directories.
- Added `getDesktopPath()`, `getPicturesPath()`, `getMusicPath()`, and `getVideosPath()` with synchronous counterparts.
- Added `getDiskSpace()` and `getDiskSpaceSync()` for querying the capacity of the volume containing a path.
- Added the `DiskSpace` model with `freeBytes`, `totalBytes`, and `usedBytes`, exported from the package.
- New methods provide throwing defaults so existing platform implementations remain source compatible.

## 0.9.0

* Initial release of `path_manager_platform_interface`.
* Defines `PlatformPathManager` extending `PlatformInterface`.
* Defines `StorageDirectory` enum and exceptions `MissingPlatformDirectoryException` and `BackupExclusionConflictException`.
