package cc.narumi.chaldea.xapk

import android.content.pm.PackageManager
import android.graphics.Bitmap
import android.graphics.Canvas
import android.graphics.drawable.BitmapDrawable
import android.util.Base64
import java.io.ByteArrayOutputStream

/**
 * Reads the display label and default icon out of a standalone APK
 * (the XAPK base split) without installing it. The archive is parsed
 * with PackageManager.getPackageArchiveInfo, then its ApplicationInfo
 * is pointed back at the archive so the public
 * getResourcesForApplication resolves labelRes/icon — the classic
 * "icon of an uninstalled APK" trick. Android-only; the fallback used
 * when the XAPK carries no root icon.png (ADR 0004).
 */
object XapkAppInfoReader {

    /**
     * @return (displayLabel, pngBase64Icon); either may be null when
     *   the APK cannot be parsed or lacks the corresponding resource.
     *   Never throws: failures degrade to nulls.
     */
    fun readLabelAndIcon(pm: PackageManager, apkPath: String): Pair<String?, String?> {
        val appInfo = runCatching {
            pm.getPackageArchiveInfo(apkPath, PackageManager.GET_META_DATA)?.applicationInfo
        }.getOrNull() ?: return null to null

        // getResourcesForApplication builds its AssetManager from these
        // paths, so pointing them at the archive makes its resources
        // (label, icon) resolvable without installing the app.
        appInfo.sourceDir = apkPath
        appInfo.publicSourceDir = apkPath
        val res = runCatching { pm.getResourcesForApplication(appInfo) }.getOrNull()

        val label = when {
            res == null -> null
            appInfo.labelRes != 0 -> runCatching { res.getString(appInfo.labelRes) }.getOrNull()
            else -> appInfo.nonLocalizedLabel?.toString()
        }

        val icon = if (res == null || appInfo.icon == 0) {
            null
        } else {
            runCatching {
                val drawable = res.getDrawable(appInfo.icon, null) ?: return@runCatching null
                val bmp = when (drawable) {
                    is BitmapDrawable -> drawable.bitmap
                    // adaptive icons (API 26+) and other composite drawables
                    // have no direct bitmap — render them onto a canvas
                    else -> {
                        val w = drawable.intrinsicWidth.coerceAtLeast(1)
                        val h = drawable.intrinsicHeight.coerceAtLeast(1)
                        Bitmap.createBitmap(w, h, Bitmap.Config.ARGB_8888).also { b ->
                            drawable.setBounds(0, 0, w, h)
                            drawable.draw(Canvas(b))
                        }
                    }
                }
                val out = ByteArrayOutputStream()
                bmp.compress(Bitmap.CompressFormat.PNG, 100, out)
                Base64.encodeToString(out.toByteArray(), Base64.NO_WRAP)
            }.getOrNull()
        }
        return label to icon
    }
}
