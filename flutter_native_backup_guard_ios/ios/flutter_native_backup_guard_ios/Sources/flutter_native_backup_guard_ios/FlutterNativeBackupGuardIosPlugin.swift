import Flutter
import UIKit

public class FlutterNativeBackupGuardIosPlugin: NSObject, FlutterPlugin, BackupGuardApi {
  public static func register(with registrar: FlutterPluginRegistrar) {
    let instance = FlutterNativeBackupGuardIosPlugin()
    BackupGuardApiSetup.setUp(binaryMessenger: registrar.messenger(), api: instance)
  }

  public func excludeFromBackup(path: String) throws -> Bool {
    let fileManager = FileManager.default
    guard fileManager.fileExists(atPath: path) else {
      throw PigeonError(code: "FILE_NOT_FOUND", message: "File or directory does not exist at path: \(path)", details: nil)
    }

    var url = URL(fileURLWithPath: path)
    var resourceValues = URLResourceValues()
    resourceValues.isExcludedFromBackup = true

    do {
      try url.setResourceValues(resourceValues)
      return true
    } catch {
      throw PigeonError(
        code: "EXCLUDE_FAILED",
        message: "Failed to set resource values: \(error.localizedDescription)",
        details: nil
      )
    }
  }

  public func getNoBackupFilesDir() throws -> String {
    let fileManager = FileManager.default
    let appSupportDirs = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask)
    guard let appSupportDir = appSupportDirs.first else {
      throw PigeonError(
        code: "APP_SUPPORT_DIR_NOT_FOUND",
        message: "Failed to find Application Support directory",
        details: nil
      )
    }

    let noBackupDir = appSupportDir.appendingPathComponent("NoBackup")

    do {
      if !fileManager.fileExists(atPath: noBackupDir.path) {
        try fileManager.createDirectory(
          at: noBackupDir,
          withIntermediateDirectories: true,
          attributes: nil
        )
      }

      var url = noBackupDir
      var resourceValues = URLResourceValues()
      resourceValues.isExcludedFromBackup = true
      try url.setResourceValues(resourceValues)

      return noBackupDir.path
    } catch {
      throw PigeonError(
        code: "NO_BACKUP_DIR_CREATION_FAILED",
        message: "Failed to create or exclude NoBackup directory: \(error.localizedDescription)",
        details: nil
      )
    }
  }
}
