package cc.narumi.chaldea
import android.content.Intent
import android.content.pm.PackageManager
import android.net.Uri
import android.os.Build
import androidx.annotation.NonNull
import androidx.core.content.FileProvider
import io.flutter.plugins.GeneratedPluginRegistrant


import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.File

class MainActivity: FlutterActivity() {
    private val _channel = "chaldea.narumi.cc/chaldea"
    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, _channel).apply {
            setMethodCallHandler { methodCall, result ->
                if (methodCall.method == "sendBackground") {
                    moveTaskToBack(false)
                    result.success(true)
                } else if (methodCall.method == "getUserAgent") {
                    result.success(System.getProperty("http.agent"))
                } else if (methodCall.method == "installCapability") {
                    result.success(installCapability())
                } else if (methodCall.method == "openInstallPermissionSettings") {
                    openInstallPermissionSettings()
                    result.success(true)
                } else if (methodCall.method == "installApk") {
                    val path = methodCall.arguments as? String
                    if (path == null) {
                        result.error("INVALID_ARGS", "installApk requires a file path argument", null)
                    } else {
                        installApk(path, result)
                    }
                } else {
                    result.notImplemented()
                }
            }
        }
    }

    // Install capability for direct installs (docs/adr/0003):
    // [declared] — the merged manifest requests REQUEST_INSTALL_PACKAGES. This is
    // the UI gate, probed at runtime so build flavors (or a build server stripping
    // the permission) need no channel-specific Dart code.
    // [granted] — the user allowed "install unknown apps" for this app. Always
    // true below Android 8, where the app-op does not exist.
    private fun installCapability(): Map<String, Any> {
        val declared = try {
            val info = packageManager.getPackageInfo(packageName, PackageManager.GET_PERMISSIONS)
            info.requestedPermissions?.contains(android.Manifest.permission.REQUEST_INSTALL_PACKAGES) == true
        } catch (_: Exception) {
            false
        }
        val granted = Build.VERSION.SDK_INT < Build.VERSION_CODES.O || packageManager.canRequestPackageInstalls()
        return mapOf("declared" to declared, "granted" to granted)
    }

    // The "install unknown apps" grant can only be given in system settings,
    // so deep-link to this app's page there. The user re-taps Install after
    // returning (permission-first flow, see docs/adr/0003).
    private fun openInstallPermissionSettings() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            startActivity(
                Intent(
                    android.provider.Settings.ACTION_MANAGE_UNKNOWN_APP_SOURCES,
                    Uri.parse("package:$packageName")
                )
            )
        }
    }

    private fun installApk(path: String, result: MethodChannel.Result) {
        val file = File(path)
        if (!file.exists()) {
            result.error("FILE_NOT_FOUND", "apk file not found: $path", null)
            return
        }
        try {
            val uri = FileProvider.getUriForFile(this, "$packageName.provider", file)
            startActivity(
                Intent(Intent.ACTION_VIEW).apply {
                    setDataAndType(uri, "application/vnd.android.package-archive")
                    addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION)
                    addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                }
            )
            result.success(true)
        } catch (e: Exception) {
            result.error("INSTALL_FAILED", e.message ?: e.javaClass.simpleName, null)
        }
    }
}
