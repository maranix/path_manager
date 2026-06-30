# 0.6.1

* Export `PlatformPathManager` publicly to enable custom overrides and mocking in tests.
* Add comprehensive unit tests and documentation for testing and mocking path resolution.

# 0.6.0

* Rename `getApplicationNoBackupPath` to `getApplicationNoBackupDirectory`.
* Update `getApplicationNoBackupDirectory` to return `Future<Directory>` instead of `Future<String>` for consistency with other directory methods.

# 0.5.0

* initial release
