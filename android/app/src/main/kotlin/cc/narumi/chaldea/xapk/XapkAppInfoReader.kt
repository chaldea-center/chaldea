package cc.narumi.chaldea.xapk

import android.content.pm.PackageManager
import android.graphics.Bitmap
import android.graphics.Canvas
import android.graphics.drawable.BitmapDrawable
import android.util.Base64
import java.io.ByteArrayOutputStream

/**
 * Reads an uninstalled APK's label and icon as a fallback for missing XAPK metadata.
 */
object XapkAppInfoReader {

    /**
     * @return label and PNG base64 icon; unavailable values are null.
     */
    fun readLabelAndIcon(pm: PackageManager, apkPath: String): Pair<String?, String?> {
        val appInfo = runCatching {
            pm.getPackageArchiveInfo(apkPath, PackageManager.GET_META_DATA)?.applicationInfo
        }.getOrNull() ?: return null to null

        // Resolve resources from the archive rather than an installed package.
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
                    // Render non-bitmap drawables, including adaptive icons.
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
