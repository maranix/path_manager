/// The free and total capacity of a filesystem volume, in bytes.
///
/// This describes the volume that contains a path, not the size of the
/// directory or file at that path. Use `PathManager.getApplicationCacheSize()`
/// to measure the size of a directory tree.
final class const DiskSpace({
  /// The number of bytes available to the current process on the volume.
  required final int freeBytes,

  /// The total number of bytes on the volume.
  required final int totalBytes,
}) {
  /// The number of bytes currently in use on the volume.
  int get usedBytes => totalBytes - freeBytes;

  @override
  bool operator ==(Object other) =>
      other is DiskSpace &&
      other.freeBytes == freeBytes &&
      other.totalBytes == totalBytes;

  @override
  int get hashCode => Object.hash(freeBytes, totalBytes);

  @override
  String toString() =>
      'DiskSpace(freeBytes: $freeBytes, totalBytes: $totalBytes)';
}
