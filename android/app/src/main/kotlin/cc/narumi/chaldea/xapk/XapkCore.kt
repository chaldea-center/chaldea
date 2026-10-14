package cc.narumi.chaldea.xapk

import org.json.JSONArray
import org.json.JSONObject
import java.io.File
import java.util.Base64
import java.util.zip.ZipFile

/**
 * XAPK manifest parsing and split selection without Android dependencies.
 */

data class XapkSplit(val file: String, val id: String, val size: Long)

data class XapkManifest(
    val packageName: String,
    val appName: String,
    val versionName: String,
    val versionCode: Long,
    val minSdk: Int,
    val totalSize: Long,
    val splits: List<XapkSplit>,
    val hasObb: Boolean,
) {
    fun toMap(): Map<String, Any?> = mapOf(
        "packageName" to packageName,
        "appName" to appName,
        "versionName" to versionName,
        "versionCode" to versionCode,
        "minSdk" to minSdk,
        "totalSize" to totalSize,
        "hasObb" to hasObb,
        "splits" to splits.map { mapOf("file" to it.file, "id" to it.id, "size" to it.size) },
    )
}

class XapkException(val code: String, message: String) : Exception(message)

object XapkCore {

    /** split id suffix -> platform ABI name (Build.SUPPORTED_ABIS vocabulary) */
    private val SPLIT_ABIS = mapOf(
        "arm64_v8a" to "arm64-v8a",
        "armeabi_v7a" to "armeabi-v7a",
        "armeabi" to "armeabi",
        "x86_64" to "x86_64",
        "x86" to "x86",
        "mips64" to "mips64",
        "mips" to "mips",
    )

    /** ABI platform name for a config split id, or null for base/locale/density splits. */
    fun abiOfSplitId(id: String): String? {
        if (!id.startsWith("config.")) return null
        return SPLIT_ABIS[id.removePrefix("config.")]
    }

    /**
     * Keeps base and non-ABI splits, plus the first supported ABI.
     * If no ABI matches, keeps all ABI splits rather than omitting native libraries.
     */
    fun selectSplits(splits: List<XapkSplit>, supportedAbis: List<String>): List<XapkSplit> {
        val base = splits.filter { it.id == "base" }
        val abiSplits = splits.mapNotNull { s -> abiOfSplitId(s.id)?.let { s } }
        val others = splits.filter { it.id != "base" && abiOfSplitId(it.id) == null }
        val bestAbi = supportedAbis.firstOrNull { abi ->
            abiSplits.any { abiOfSplitId(it.id) == abi }
        }
        val chosenAbi = when {
            bestAbi != null -> abiSplits.filter { abiOfSplitId(it.id) == bestAbi }
            abiSplits.isNotEmpty() -> abiSplits
            else -> emptyList()
        }
        return base + others + chosenAbi
    }

    /**
     * Parses manifest.json and validates split sizes against the ZIP entries.
     * The total size includes split APKs only.
     */
    fun parseManifest(json: String, entrySizes: Map<String, Long>): XapkManifest {
        val obj = try {
            JSONObject(json)
        } catch (e: Exception) {
            throw XapkException("NO_MANIFEST", "manifest.json is not valid JSON: ${e.message}")
        }

        val packageName = obj.optString("package_name")
        if (packageName.isNullOrEmpty()) {
            throw XapkException("NO_MANIFEST", "manifest.json has no package_name")
        }
        val versionName = obj.optString("version_name", "")
        if (versionName.isNullOrEmpty()) {
            throw XapkException("NO_MANIFEST", "manifest.json has no version_name")
        }

        val splitArray: JSONArray = obj.optJSONArray("split_apks")
            ?: throw XapkException("NO_MANIFEST", "manifest.json has no split_apks")
        val splits = buildList {
            for (i in 0 until splitArray.length()) {
                val split = splitArray.getJSONObject(i)
                val file = split.optString("file")
                val id = split.optString("id")
                if (file.isNullOrEmpty() || id.isNullOrEmpty()) continue
                add(XapkSplit(file = file, id = id, size = entrySizes[file] ?: -1L))
            }
        }
        if (splits.none { it.id == "base" }) {
            throw XapkException("NO_BASE_SPLIT", "manifest.json lists no base split")
        }
        val missingFile = splits.firstOrNull { it.size < 0 }
        if (missingFile != null) {
            throw XapkException(
                "MISSING_SPLIT",
                "split '${missingFile.file}' listed in manifest.json is not in the archive",
            )
        }

        val expansions = obj.optJSONArray("expansions")
        val hasObb = expansions != null && expansions.length() > 0

        val manifestTotal = obj.optLong("total_size", -1L)
        val actualTotal = splits.sumOf { it.size }
        if (manifestTotal > 0 && manifestTotal != actualTotal) {
            throw XapkException(
                "SIZE_MISMATCH",
                "manifest total_size $manifestTotal != sum of splits $actualTotal; archive corrupt or mismatched",
            )
        }

        return XapkManifest(
            packageName = packageName,
            appName = obj.optString("name").ifEmpty { packageName },
            versionName = versionName,
            versionCode = obj.optLong("version_code", -1L),
            minSdk = obj.optInt("min_sdk_version", 0),
            totalSize = actualTotal,
            splits = splits,
            hasObb = hasObb,
        )
    }

    /**
     * Returns the root icon.png as base64, or null so callers can try the base APK.
     */
    fun readRootIconBase64(zip: ZipFile): String? {
        val entry = zip.getEntry("icon.png") ?: return null
        val bytes = zip.getInputStream(entry).use { it.readBytes() }
        if (bytes.isEmpty()) return null
        return Base64.getEncoder().encodeToString(bytes)
    }

    /**
     * Extracts a split entry to [target] and returns the file.
     */
    fun extractSplitToFile(zip: ZipFile, entryName: String, target: File): File {
        val entry = zip.getEntry(entryName)
            ?: throw XapkException("MISSING_SPLIT", "split '$entryName' not in archive")
        zip.getInputStream(entry).use { input ->
            target.outputStream().use { out -> input.copyTo(out) }
        }
        return target
    }
}
