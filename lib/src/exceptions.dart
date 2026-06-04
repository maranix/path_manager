/// Exception thrown by [PathManager] when a requested platform directory
/// cannot be resolved or is not supported on the host platform.
class MissingPlatformDirectoryException implements Exception {
  /// A message describing the error.
  final String message;

  /// Creates a new [MissingPlatformDirectoryException] with the given [message].
  MissingPlatformDirectoryException(this.message);

  @override
  String toString() => 'MissingPlatformDirectoryException: $message';
}

/// Exception thrown by [PathManager.getApplicationNoBackupDirectory] when the
/// designated no-backup directory (`__no_backup__`) already exists on the
/// filesystem, but has not been marked with the backup exclusion flag.
///
/// This conflict typically occurs if a user manually creates a file or
/// directory named `__no_backup__` in the application support directory
/// without setting the appropriate backup exclusion flags.
class BackupExclusionConflictException implements Exception {
  /// The absolute path to the directory that caused the conflict.
  final String path;

  /// A detailed message explaining the conflict and remediation steps.
  final String message;

  /// Creates a new [BackupExclusionConflictException] with the given [path] and [message].
  BackupExclusionConflictException(this.path, this.message);

  @override
  String toString() =>
      'BackupExclusionConflictException: $message (path: $path)';
}
