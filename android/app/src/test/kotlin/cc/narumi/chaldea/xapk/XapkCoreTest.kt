package cc.narumi.chaldea.xapk

import org.junit.Assert.assertArrayEquals
import org.junit.Assert.assertEquals
import org.junit.Assert.assertFalse
import org.junit.Assert.assertNull
import org.junit.Assert.assertThrows
import org.junit.Assert.assertTrue
import org.junit.Test
import java.io.File
import java.io.FileOutputStream
import java.util.Base64
import java.util.zip.ZipEntry
import java.util.zip.ZipFile
import java.util.zip.ZipOutputStream

/**
 * JVM unit tests for the pure XAPK core: manifest parsing and ABI
 * split selection (see docs/xapk-install.md §6).
 *
 * Manifest fixtures mirror the verified FGO artifacts in temp/xapk:
 * JP 2.138.1 (base + arm64_v8a / combined) and KR 8.0.1 (with an
 * empty expansions array).
 */
class XapkCoreTest {

    private val jpEntrySizes = mapOf(
        "com.aniplex.fategrandorder.apk" to 44244064L,
        "config.arm64_v8a.apk" to 40072820L,
        "config.armeabi_v7a.apk" to 38332052L,
        "icon.png" to 79436L,
        "manifest.json" to 1083L,
    )

    private val jpManifestJson = """
        {
          "xapk_version": "2",
          "package_name": "com.aniplex.fategrandorder",
          "name": "Fate/Grand Order",
          "version_code": "497",
          "version_name": "2.138.1",
          "min_sdk_version": "24",
          "total_size": 122648936,
          "split_apks": [
            {"file": "com.aniplex.fategrandorder.apk", "id": "base"},
            {"file": "config.arm64_v8a.apk", "id": "config.arm64_v8a"},
            {"file": "config.armeabi_v7a.apk", "id": "config.armeabi_v7a"}
          ]
        }
    """.trimIndent()

    // ---- parseManifest -----------------------------------------------------

    @Test
    fun parsesCombinedJpManifest() {
        val m = XapkCore.parseManifest(jpManifestJson, jpEntrySizes)
        assertEquals("com.aniplex.fategrandorder", m.packageName)
        assertEquals("Fate/Grand Order", m.appName)
        assertEquals("2.138.1", m.versionName)
        assertEquals(497L, m.versionCode)
        assertEquals(24, m.minSdk)
        // total_size == sum of ALL splits (verified against real artifacts)
        assertEquals(122648936L, m.totalSize)
        assertEquals(3, m.splits.size)
        assertFalse(m.hasObb)
        assertEquals("base", m.splits[0].id)
    }

    @Test
    fun emptyExpansionsMeansNoObb() {
        val json = jpManifestJson.replace("\"split_apks\"", "\"expansions\": [],\n\"split_apks\"")
        val m = XapkCore.parseManifest(json, jpEntrySizes)
        assertFalse(m.hasObb)
    }

    @Test
    fun nonEmptyExpansionsFlagsObb() {
        val json = jpManifestJson.replace("\"split_apks\"", "\"expansions\": [{\"file\": \"main.obb\"}],\n\"split_apks\"")
        val m = XapkCore.parseManifest(json, jpEntrySizes)
        assertTrue(m.hasObb)
    }

    @Test
    fun missingManifestThrows() {
        assertThrows(XapkException::class.java) {
            XapkCore.parseManifest("not json at all", jpEntrySizes)
        }
        assertThrows(XapkException::class.java) {
            XapkCore.parseManifest("{\"version_name\": \"1.0\"}", jpEntrySizes)
        }
    }

    @Test
    fun noBaseSplitThrows() {
        val json = """
            {"package_name": "a.b.c", "version_name": "1.0",
             "split_apks": [{"file": "config.arm64_v8a.apk", "id": "config.arm64_v8a"}]}
        """.trimIndent()
        assertThrows(XapkException::class.java) {
            XapkCore.parseManifest(json, jpEntrySizes)
        }
    }

    @Test
    fun splitMissingFromArchiveThrows() {
        val sizes = jpEntrySizes - "config.armeabi_v7a.apk"
        assertThrows(XapkException::class.java) {
            XapkCore.parseManifest(jpManifestJson, sizes)
        }
    }

    @Test
    fun totalSizeMismatchThrows() {
        val json = jpManifestJson.replace("122648936", "1")
        assertThrows(XapkException::class.java) {
            XapkCore.parseManifest(json, jpEntrySizes)
        }
    }

    // ---- abiOfSplitId ------------------------------------------------------

    @Test
    fun splitIdAbiMapping() {
        assertEquals("arm64-v8a", XapkCore.abiOfSplitId("config.arm64_v8a"))
        assertEquals("armeabi-v7a", XapkCore.abiOfSplitId("config.armeabi_v7a"))
        assertEquals("x86_64", XapkCore.abiOfSplitId("config.x86_64"))
        assertNull(XapkCore.abiOfSplitId("base"))
        assertNull(XapkCore.abiOfSplitId("config.en"))
        assertNull(XapkCore.abiOfSplitId("config.xxhdpi"))
    }

    // ---- selectSplits ------------------------------------------------------

    private val splits = listOf(
        XapkSplit("com.aniplex.fategrandorder.apk", "base", 44244064L),
        XapkSplit("config.arm64_v8a.apk", "config.arm64_v8a", 40072820L),
        XapkSplit("config.armeabi_v7a.apk", "config.armeabi_v7a", 38332052L),
    )

    @Test
    fun arm64DeviceSelectsOnlyMatchingAbi() {
        val selected = XapkCore.selectSplits(splits, listOf("arm64-v8a"))
        assertEquals(listOf("base", "config.arm64_v8a"), selected.map { it.id })
    }

    @Test
    fun combinedPackageOn64BitDeviceSkipsV7a() {
        val selected = XapkCore.selectSplits(splits, listOf("arm64-v8a", "armeabi-v7a"))
        // SUPPORTED_ABIS ordering: primary ABI first, so arm64 device
        // installing a combined XAPK should still only write arm64-v8a
        assertEquals(listOf("base", "config.arm64_v8a"), selected.map { it.id })
    }

    @Test
    fun fallbackWhenNoAbiMatches() {
        val selected = XapkCore.selectSplits(splits, listOf("x86_64", "x86"))
        assertEquals(3, selected.size) // all ABI splits kept as fallback
    }

    @Test
    fun nonAbiConfigSplitsAlwaysKept() {
        val withLocale = splits + XapkSplit("config.en.apk", "config.en", 1000L)
        val selected = XapkCore.selectSplits(withLocale, listOf("arm64-v8a"))
        assertEquals(listOf("base", "config.en", "config.arm64_v8a"), selected.map { it.id })
    }

    @Test
    fun singleAbiPackageOn32BitDevice() {
        val v7aOnly = listOf(splits[0], splits[2])
        val selected = XapkCore.selectSplits(v7aOnly, listOf("armeabi-v7a", "armeabi"))
        assertEquals(listOf("base", "config.armeabi_v7a"), selected.map { it.id })
    }

    // ---- readRootIconBase64 / extractSplitToFile ---------------------------

    @Test
    fun readRootIconBase64ReturnsEntryWhenPresent() {
        val png = byteArrayOf(0x89.toByte(), 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A)
        val zip = buildZip("icon.png" to png)
        try {
            ZipFile(zip).use { z ->
                assertEquals(Base64.getEncoder().encodeToString(png), XapkCore.readRootIconBase64(z))
            }
        } finally {
            zip.delete()
        }
    }

    @Test
    fun readRootIconBase64NullWhenAbsent() {
        val zip = buildZip("manifest.json" to "{}".toByteArray())
        try {
            ZipFile(zip).use { z -> assertNull(XapkCore.readRootIconBase64(z)) }
        } finally {
            zip.delete()
        }
    }

    @Test
    fun extractSplitToFileCopiesEntry() {
        val data = "base apk bytes".toByteArray()
        val zip = buildZip("com.aniplex.fategrandorder.apk" to data)
        val target = File.createTempFile("chaldea_test_", ".apk")
        try {
            ZipFile(zip).use { z ->
                val out = XapkCore.extractSplitToFile(z, "com.aniplex.fategrandorder.apk", target)
                assertEquals(target, out)
            }
            assertArrayEquals(data, target.readBytes())
        } finally {
            zip.delete()
            target.delete()
        }
    }

    @Test
    fun extractSplitToFileMissingEntryThrows() {
        val zip = buildZip("manifest.json" to "{}".toByteArray())
        val target = File.createTempFile("chaldea_test_", ".apk")
        try {
            ZipFile(zip).use { z ->
                assertThrows(XapkException::class.java) {
                    XapkCore.extractSplitToFile(z, "missing.apk", target)
                }
            }
        } finally {
            zip.delete()
            target.delete()
        }
    }

    private fun buildZip(vararg entries: Pair<String, ByteArray>): File {
        val f = File.createTempFile("chaldea_zip_test_", ".xapk")
        ZipOutputStream(FileOutputStream(f)).use { out ->
            for ((name, data) in entries) {
                out.putNextEntry(ZipEntry(name))
                out.write(data)
                out.closeEntry()
            }
        }
        return f
    }
}
