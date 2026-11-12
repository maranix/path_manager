/// Categories for public or app-specific external storage subdirectories.
enum StorageDirectory(
  /// The corresponding Android `android.os.Environment` directory name string.
  final String dirName,
) {
  /// Directory for user music files (e.g. `Music`).
  music('Music'),

  /// Directory for user podcasts (e.g. `Podcasts`).
  podcasts('Podcasts'),

  /// Directory for rich text format files (e.g. `Rtf`).
  rtf('Rtf'),

  /// Directory for user alarm sounds (e.g. `Alarms`).
  alarms('Alarms'),

  /// Directory for user notification sounds (e.g. `Notifications`).
  notifications('Notifications'),

  /// Directory for user images and pictures (e.g. `Pictures`).
  pictures('Pictures'),

  /// Directory for user movies and videos (e.g. `Movies`).
  movies('Movies'),

  /// Directory for user downloaded files (e.g. `Download`).
  downloads('Download'),

  /// Directory for photos and videos taken by the camera (e.g. `DCIM`).
  dcim('DCIM'),

  /// Directory for user documents (e.g. `Documents`).
  documents('Documents'),
}
