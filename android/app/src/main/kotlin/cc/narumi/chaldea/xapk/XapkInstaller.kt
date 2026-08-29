package cc.narumi.chaldea.xapk

import android.app.PendingIntent
import android.content.ActivityNotFoundException
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.content.pm.PackageInstaller
import android.os.Build
import android.os.Handler
import android.os.Looper
import androidx.core.content.ContextCompat
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodChannel
import java.io.File
import java.util.concurrent.CountDownLatch
import java.util.concurrent.Executors
import java.util.concurrent.TimeUnit
import java.util.zip.ZipException
import java.util.zip.ZipFile

/**
 * Native XAPK installer (ADR 0004): streams the base + selected
 * config splits from the XAPK ZIP directly into a
 * PackageInstaller.Session — no intermediate extraction, ZIP64-safe,
 * CRC verified while streaming. States are pushed to Dart through the
 * `chaldea.narumi.cc/xapk` EventChannel as
 * `{phase, progress, bytes, totalBytes, error, message}` maps.
 */
class XapkInstaller(private val context: Context) : EventChannel.StreamHandler {

    companion object {
        private const val EMIT_PROGRESS_STEP = 512L * 1024 // emit ~every 512 KB
        private const val STATUS_TIMEOUT_MINUTES = 10L
    }

    private val mainHandler = Handler(Looper.getMainLooper())
    private val executor = Executors.newSingleThreadExecutor()

    @Volatile
    private var running = false

    @Volatile
    private var lastEvent: Map<String, Any?>? = null

    private var sink: EventChannel.EventSink? = null

    // ---- EventChannel ------------------------------------------------------

    override fun onListen(args: Any?, events: EventChannel.EventSink?) {
        sink = events
        // replay current state so a re-subscribed page (e.g. after
        // navigation) sees where the flow is
        lastEvent?.let { state -> events?.success(state) }
    }

    override fun onCancel(args: Any?) {
        sink = null
    }

    private fun emit(event: Map<String, Any?>) {
        lastEvent = event
        val s = sink
        mainHandler.post { s?.success(event) }
    }

    private fun event(
        phase: String,
        progress: Double? = null,
        bytes: Long? = null,
        totalBytes: Long? = null,
        error: String? = null,
        message: String? = null,
    ): Map<String, Any?> = buildMap {
        put("phase", phase)
        progress?.let { put("progress", it) }
        bytes?.let { put("bytes", it) }
        totalBytes?.let { put("totalBytes", it) }
        error?.let { put("error", it) }
        message?.let { put("message", it) }
    }

    // ---- public API (MethodChannel entry points, called on main thread) ----

    fun parseAsync(path: String, result: MethodChannel.Result) {
        executor.execute {
            try {
                val manifest = parse(path)
                val selected = XapkCore.selectSplits(manifest.splits, Build.SUPPORTED_ABIS.toList())
                val (appName, appIcon) = readAppInfo(path, manifest)
                val map = manifest.toMap() + mapOf(
                    "selectedFiles" to selected.map { it.file },
                    "deviceAbis" to Build.SUPPORTED_ABIS.toList(),
                    "appName" to appName,
                    "appIcon" to appIcon,
                )
                mainHandler.post { result.success(map) }
            } catch (e: XapkException) {
                mainHandler.post { result.error(e.code, e.message, null) }
            } catch (e: Exception) {
                mainHandler.post { result.error("PARSE_FAILED", e.message ?: e.javaClass.simpleName, null) }
            }
        }
    }

    fun installAsync(path: String, result: MethodChannel.Result) {
        if (running) {
            result.error("BUSY", "an XAPK install is already in progress", null)
            return
        }
        running = true
        // ack immediately; the flow reports through the event channel
        result.success(true)
        executor.execute {
            try {
                install(path)
            } catch (e: XapkException) {
                emit(event("failed", error = e.code, message = e.message))
            } catch (e: Exception) {
                emit(event("failed", error = "INSTALL_FAILED", message = e.message ?: e.javaClass.simpleName))
            } finally {
                running = false
            }
        }
    }

    // ---- internals ----------------------------------------------------------

    private fun parse(path: String): XapkManifest {
        val file = File(path)
        if (!file.exists() || !file.isFile) {
            throw XapkException("FILE_NOT_FOUND", "file not found: $path")
        }
        val zip = try {
            ZipFile(file)
        } catch (e: Exception) {
            throw XapkException("NOT_ZIP", "not a valid zip/xapk archive: ${e.message}")
        }
        zip.use { z ->
            val entry = z.getEntry("manifest.json")
                ?: throw XapkException("NO_MANIFEST", "manifest.json is missing from the archive")
            val json = z.getInputStream(entry).bufferedReader().use { it.readText() }
            val entrySizes = buildMap {
                val entries = z.entries()
                while (entries.hasMoreElements()) {
                    val e = entries.nextElement() as java.util.zip.ZipEntry
                    put(e.name, e.size)
                }
            }
            return XapkCore.parseManifest(json, entrySizes)
        }
    }

    /**
     * Best-effort app display name + default icon for the parse
     * summary. Prefers the XAPK root icon.png (a pure zip read); when
     * absent, extracts the base split APK and reads its real label/icon
     * (XapkAppInfoReader). Never fails the parse: any error just yields
     * the manifest name and no icon.
     */
    private fun readAppInfo(path: String, manifest: XapkManifest): Pair<String, String?> {
        var appName = manifest.appName
        var appIcon: String? = null
        var temp: File? = null
        try {
            ZipFile(File(path)).use { z ->
                appIcon = XapkCore.readRootIconBase64(z)
                if (appIcon == null) {
                    val base = manifest.splits.firstOrNull { it.id == "base" }
                    if (base != null) {
                        temp = XapkCore.extractSplitToFile(
                            z,
                            base.file,
                            File.createTempFile("chaldea_base_", ".apk"),
                        )
                    }
                }
            }
            val t = temp
            if (t != null) {
                val (label, icon) = XapkAppInfoReader.readLabelAndIcon(context.packageManager, t.absolutePath)
                if (!label.isNullOrBlank()) appName = label
                if (icon != null) appIcon = icon
            }
        } catch (e: Exception) {
            // icon/label are cosmetic — keep the manifest name, skip the icon
        } finally {
            temp?.delete()
        }
        return appName to appIcon
    }

    private fun install(path: String) {
        emit(event("parsing"))
        val manifest = parse(path)
        if (manifest.hasObb) {
            throw XapkException(
                "OBB_UNSUPPORTED",
                "this XAPK contains OBB expansion data, which is not supported; use an external installer",
            )
        }
        val selected = XapkCore.selectSplits(manifest.splits, Build.SUPPORTED_ABIS.toList())
        if (selected.isEmpty()) {
            throw XapkException("NO_BASE_SPLIT", "no installable splits selected")
        }
        val totalBytes = selected.sumOf { it.size }.coerceAtLeast(1L)

        val installer = context.packageManager.packageInstaller
        val params = PackageInstaller.SessionParams(PackageInstaller.SessionParams.MODE_FULL_INSTALL)
        val sessionId = try {
            installer.createSession(params)
        } catch (e: Exception) {
            throw XapkException("SESSION_OPEN_FAILED", "failed to open install session: ${e.message}")
        }

        emit(event("installing", progress = 0.0, bytes = 0L, totalBytes = totalBytes))
        val session = installer.openSession(sessionId)
        try {
            var written = 0L
            var nextEmit = 0L
            ZipFile(File(path)).use { zip ->
                for (split in selected) {
                    val entry = zip.getEntry(split.file)
                        ?: throw XapkException("MISSING_SPLIT", "split '${split.file}' not in archive")
                    zip.getInputStream(entry).use { input ->
                        session.openWrite(split.id, 0, split.size).use { out ->
                            val buf = ByteArray(64 * 1024)
                            while (true) {
                                val n = input.read(buf)
                                if (n < 0) break
                                out.write(buf, 0, n)
                                written += n
                                if (written >= nextEmit) {
                                    nextEmit = written + EMIT_PROGRESS_STEP
                                    emit(
                                        event(
                                            "installing",
                                            progress = written.toDouble() / totalBytes,
                                            bytes = written,
                                            totalBytes = totalBytes,
                                        ),
                                    )
                                }
                            }
                            session.fsync(out)
                        }
                    }
                }
            }
        } catch (e: ZipException) {
            abandonQuietly(installer, sessionId)
            throw XapkException("CRC_FAILED", "archive entry failed CRC check: ${e.message}")
        } catch (e: Exception) {
            abandonQuietly(installer, sessionId)
            throw e
        }

        commitAndAwait(installer, session, sessionId)
    }

    /**
     * Commit the session and block the worker thread until a terminal
     * status arrives. STATUS_PENDING_USER_ACTION launches the system
     * confirmation activity (the only user-consent layer besides the
     * in-app Install button); the final success/failure broadcast
     * ends the wait.
     */
    private fun commitAndAwait(
        installer: PackageInstaller,
        session: PackageInstaller.Session,
        sessionId: Int,
    ) {
        val statusAction = "cc.narumi.chaldea.xapk.INSTALL_STATUS.$sessionId"
        val done = CountDownLatch(1)

        val receiver = object : BroadcastReceiver() {
            override fun onReceive(ctx: Context, intent: Intent) {
                when (intent.getIntExtra(PackageInstaller.EXTRA_STATUS, PackageInstaller.STATUS_FAILURE)) {
                    PackageInstaller.STATUS_PENDING_USER_ACTION -> {
                        val confirmIntent = getParcelableIntent(intent)
                        if (confirmIntent == null) {
                            emit(event("failed", error = "CONFIRM_ACTIVITY_MISSING", message = "system returned no confirmation intent"))
                            done.countDown()
                            return
                        }
                        confirmIntent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                        try {
                            context.startActivity(confirmIntent)
                            emit(event("confirming"))
                        } catch (e: ActivityNotFoundException) {
                            // MIUI with "MIUI optimization" ON historically ships an
                            // installer that does not implement CONFIRM_INSTALL
                            emit(
                                event(
                                    "failed",
                                    error = "CONFIRM_ACTIVITY_MISSING",
                                    message = "device installer broken: ${e.message}",
                                ),
                            )
                            done.countDown()
                        }
                    }
                    PackageInstaller.STATUS_SUCCESS -> {
                        emit(event("success"))
                        done.countDown()
                    }
                    else -> {
                        val msg = intent.getStringExtra(PackageInstaller.EXTRA_STATUS_MESSAGE) ?: ""
                        emit(event("failed", error = "INSTALL_FAILED", message = msg))
                        done.countDown()
                    }
                }
            }
        }

        val registered = try {
            ContextCompat.registerReceiver(
                context,
                receiver,
                IntentFilter(statusAction),
                ContextCompat.RECEIVER_NOT_EXPORTED,
            )
            true
        } catch (e: Exception) {
            emit(event("failed", error = "SESSION_OPEN_FAILED", message = "failed to register status receiver: ${e.message}"))
            abandonQuietly(installer, sessionId)
            return
        }

        val statusIntent = Intent(statusAction).setPackage(context.packageName)
        // The status receiver MUST be mutable: PackageInstaller fills in
        // the status extras at delivery time, and targeting U+ rejects
        // immutable senders with "The commit() status receiver should
        // come from a mutable PendingIntent".
        val flags = PendingIntent.FLAG_UPDATE_CURRENT or
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
                PendingIntent.FLAG_MUTABLE
            } else {
                0
            }
        val pending = PendingIntent.getBroadcast(context, sessionId, statusIntent, flags)

        try {
            session.commit(pending.intentSender)
        } catch (e: Exception) {
            emit(event("failed", error = "INSTALL_FAILED", message = "commit failed: ${e.message}"))
            done.countDown()
        } finally {
            session.close()
        }

        if (!done.await(STATUS_TIMEOUT_MINUTES, TimeUnit.MINUTES)) {
            emit(
                event(
                    "failed",
                    error = "TIMEOUT",
                    message = "no install status within $STATUS_TIMEOUT_MINUTES minutes",
                ),
            )
            abandonQuietly(installer, sessionId)
        }
        if (registered) {
            try {
                context.unregisterReceiver(receiver)
            } catch (_: Exception) {
            }
        }
    }

    @Suppress("DEPRECATION")
    private fun getParcelableIntent(intent: Intent): Intent? {
        return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
            intent.getParcelableExtra(Intent.EXTRA_INTENT, Intent::class.java)
        } else {
            intent.getParcelableExtra(Intent.EXTRA_INTENT)
        }
    }

    private fun abandonQuietly(installer: PackageInstaller, sessionId: Int) {
        try {
            installer.abandonSession(sessionId)
        } catch (_: Exception) {
        }
    }
}
