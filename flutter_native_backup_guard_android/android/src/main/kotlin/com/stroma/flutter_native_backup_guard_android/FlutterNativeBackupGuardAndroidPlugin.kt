package com.stroma.flutter_native_backup_guard_android

import android.content.Context
import android.util.Log
import io.flutter.embedding.engine.plugins.FlutterPlugin
import java.io.File

/** FlutterNativeBackupGuardAndroidPlugin */
class FlutterNativeBackupGuardAndroidPlugin : FlutterPlugin, BackupGuardApi {
    private var context: Context? = null

    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        context = binding.applicationContext
        BackupGuardApi.setUp(binding.binaryMessenger, this)
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        context = null
        BackupGuardApi.setUp(binding.binaryMessenger, null)
    }

    override fun excludeFromBackup(path: String): Boolean {
        val currentContext = context ?: throw FlutterError(
            "NO_CONTEXT",
            "Android context is not available.",
            null
        )

        try {
            val file = File(path)
            if (!file.exists()) {
                throw FlutterError(
                    "FILE_NOT_FOUND",
                    "File or directory does not exist at path: $path",
                    null
                )
            }

            val targetPath = file.canonicalPath
            val noBackupPath = currentContext.noBackupFilesDir.canonicalPath
            val cachePath = currentContext.cacheDir.canonicalPath

            // Check if it's in no_backup or cache
            if (targetPath.startsWith(noBackupPath) || targetPath.startsWith(cachePath)) {
                return true
            }

            // Also check code cache
            val codeCachePath = currentContext.codeCacheDir.canonicalPath
            if (targetPath.startsWith(codeCachePath)) {
                return true
            }

            // If not inside an inherently excluded directory, warn the developer
            Log.w(
                "BackupGuard",
                "Path '$path' is not inside an inherently excluded directory (like noBackupFilesDir or cacheDir). " +
                "On Android, arbitrary path exclusion at runtime is not supported by the OS. " +
                "Please configure static rules in res/xml/backup_rules.xml instead."
            )
            return false
        } catch (e: FlutterError) {
            throw e
        } catch (e: Exception) {
            throw FlutterError(
                "EXCLUDE_FAILED",
                "Failed to verify backup exclusion on Android: ${e.message}",
                null
            )
        }
    }

    override fun getNoBackupFilesDir(): String {
        val currentContext = context ?: throw FlutterError(
            "NO_CONTEXT",
            "Android context is not available.",
            null
        )
        return currentContext.noBackupFilesDir.absolutePath
    }
}
