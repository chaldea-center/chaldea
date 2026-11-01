"""Contract checks for the App declaration catalog; no SDKs or builds required."""

import contextlib
import copy
import hashlib
import importlib.util
import io
import json
from pathlib import Path
import sys
import tempfile
import unittest
from unittest.mock import patch


SPEC = importlib.util.spec_from_file_location("list_permissions", Path(__file__).with_name("list_permissions.py"))
audit = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(audit)


def android(flavor="github"):
    return {
        "platform": "android", "flavor": flavor, "status": "inspected", "application_id": "cc.example.app",
        "versionName": "1.2.3", "versionCode": "42", "sdk": {"targetSdkVersion": "36"},
        "permissions": [
            {"kind": "uses-permission", "name": "android.permission.READ_EXTERNAL_STORAGE", "maxSdkVersion": "32"},
            {"kind": "permission", "name": "cc.example.INTERNAL", "protectionLevel": "0x2"},
            {"kind": "uses-permission", "name": "vendor.permission.NOT_IN_UI_MAPPING"},
        ],
    }


class CatalogTests(unittest.TestCase):
    def test_unknown_permissions_and_definitions_survive_without_private_metadata(self):
        item = android()
        item.update(artifact="/Users/private/build/app.apk", error="secret log", granted=True)
        catalog = audit.app_catalog({"artifacts": [item]})
        text = json.dumps(catalog)
        self.assertIn("vendor.permission.NOT_IN_UI_MAPPING", text)
        self.assertIn('"maxSdkVersion": "32"', text)
        self.assertIn('"kind": "permission"', text)
        for private in ("/Users/private", "secret log", '"granted"'):
            self.assertNotIn(private, text)
        self.assertFalse(catalog["runtime_authorization_verified"])
        absent = next(t for t in catalog["targets"] if t["platform"] == "android" and t["flavor"] == "play")
        self.assertEqual(absent["status"], "unverified")
        self.assertEqual(absent["limitations"], ["no_artifact"])

    def test_aab_modules_preserve_different_bounds_and_identity(self):
        base = android("play")
        feature = copy.deepcopy(base)
        feature["permissions"][0]["maxSdkVersion"] = "28"
        result = audit.catalog_target({"platform": "android", "flavor": "play", "status": "inspected",
                                       "modules": {"base": base, "feature": feature}})
        storage = [r for r in result["declarations"] if r["name"].endswith("READ_EXTERNAL_STORAGE")]
        self.assertEqual({(r["module"], r["maxSdkVersion"]) for r in storage}, {("base", "32"), ("feature", "28")})
        self.assertEqual(result["build_number"], "42")

    def test_flavor_is_not_guessed_from_filename_or_package_id(self):
        item = android(None)
        item.update(artifact="app-play-release.apk", application_id="cc.example.fdroid")
        with self.assertRaisesRegex(audit.AuditError, "explicit flavor"):
            audit.app_catalog({"artifacts": [item]})

    def test_conflicting_releases_cannot_silently_overwrite_a_target(self):
        other = android()
        other["permissions"].append({"kind": "uses-permission", "name": "android.permission.CAMERA"})
        with self.assertRaisesRegex(audit.AuditError, "Conflicting"):
            audit.app_catalog({"artifacts": [android(), other]})
        one = audit.app_catalog({"artifacts": [android()]})
        self.assertEqual(one, audit.app_catalog({"artifacts": [android(), android()]}))

    def test_partial_rebuild_keeps_previously_inspected_platforms(self):
        with tempfile.TemporaryDirectory() as tmp:
            path = Path(tmp) / "catalog.json"
            path.write_text(json.dumps(audit.app_catalog({"artifacts": [{
                "platform": "ios", "status": "partial", "info": {
                    "CFBundleIdentifier": "cc.example.app", "CFBundleShortVersionString": "1.2.3",
                    "CFBundleVersion": "42", "NSPhotoLibraryAddUsageDescription": "Save selected images",
                },
            }]})))
            merged = audit.app_catalog({"artifacts": [android()]}, path)
        targets = {(target["platform"], target["flavor"]): target for target in merged["targets"]}
        self.assertEqual(targets["ios", None]["status"], "partial")
        self.assertIn("android.permission.READ_EXTERNAL_STORAGE", json.dumps(targets["android", "github"]))

    def test_apple_declarations_do_not_become_a_distribution_or_grant_claim(self):
        result = audit.catalog_target({
            "platform": "ios", "status": "partial", "info": {
                "CFBundleIdentifier": "cc.example.app", "CFBundleShortVersionString": "1.2.3", "CFBundleVersion": "42",
                "NSPhotoLibraryAddUsageDescription": "Save selected images", "UIBackgroundModes": ["fetch"],
            }, "signed_entitlements": {"status": "inspected", "values": {"get-task-allow": True}},
        })
        self.assertEqual(result["status"], "partial")
        self.assertEqual(result["checks"]["distribution_signature"], "unverified")
        self.assertIn("development_debugging_entitlement", result["limitations"])
        self.assertEqual({r["kind"] for r in result["declarations"]}, {"usage-description", "background-mode", "entitlement"})

    def test_web_and_missing_platforms_remain_unverified(self):
        catalog = audit.app_catalog({"artifacts": [{"platform": "web", "status": "partial", "manifest": {"name": "App"}}]})
        for platform in ("web", "windows", "linux"):
            target = next(t for t in catalog["targets"] if t["platform"] == platform)
            self.assertEqual(target["status"], "unverified")
            self.assertEqual(target["declarations"], [])
        web = next(t for t in catalog["targets"] if t["platform"] == "web")
        self.assertEqual(web["limitations"], ["browser_permissions_not_inspected"])

    def test_missing_apple_signature_does_not_claim_no_capabilities(self):
        target = audit.catalog_target({
            "platform": "macos", "status": "partial", "info": {
                "CFBundleIdentifier": "cc.example.app", "CFBundleShortVersionString": "1.2.3", "CFBundleVersion": "42",
            }, "signed_entitlements": {"status": "unverified", "reason": "tool unavailable"},
        })
        self.assertEqual(target["declarations"], [])
        self.assertEqual(target["status"], "partial")
        self.assertEqual(target["checks"]["signed_entitlements"], "unverified")
        self.assertIn("signed_entitlements_not_inspected", target["limitations"])

    def test_catalog_is_independent_of_report_time_paths_and_input_order(self):
        left = {"artifacts": [android("play"), android()], "generated_at_utc": "old", "auditor_sha256": "old"}
        right = {"artifacts": [android(), android("play")], "generated_at_utc": "new", "source_report": "/elsewhere"}
        self.assertEqual(audit.app_catalog(left), audit.app_catalog(right))

    def test_outputs_cannot_alias_each_other_or_modify_inputs(self):
        with tempfile.TemporaryDirectory() as folder:
            root = Path(folder)
            package = root / "App.app"
            package.mkdir()
            for outputs in ([root / "out.json", root / "out.json"], [package / "report.json"]):
                with self.assertRaises(audit.AuditError):
                    audit.validate_outputs(outputs, [package])

    def test_import_fingerprint_mismatch_preserves_existing_catalog(self):
        with tempfile.TemporaryDirectory() as folder:
            root = Path(folder)
            package = root / "app.apk"
            package.write_bytes(b"changed package")
            source = root / "source.json"
            previous = {**android(), "artifact": str(package), "sha256": hashlib.sha256(b"old package").hexdigest()}
            source.write_text(json.dumps({"schema_version": 1, "artifacts": [previous]}))
            catalog = root / "catalog.json"
            catalog.write_text("existing catalog\n")
            report = root / "audit.json"
            current = {**android(), "artifact": str(package), "sha256": audit.digest(package)}
            argv = ["list_permissions.py", "--from-report", str(source), "--catalog-output", str(catalog), "--output", str(report)]
            with patch.object(sys, "argv", argv), patch.object(audit, "inspect_artifact", return_value=current), contextlib.redirect_stderr(io.StringIO()):
                self.assertEqual(audit.main(), 1)
            self.assertEqual(catalog.read_text(), "existing catalog\n")
            failed = json.loads(report.read_text())
            self.assertEqual(failed["artifacts"][0]["status"], "unverified")
            self.assertIn("could not be verified", failed["catalog_error"])

    def test_write_skips_identical_content(self):
        with tempfile.TemporaryDirectory() as folder:
            path = Path(folder) / "catalog.json"
            audit.write_output(path, "stable\n")
            before = path.stat().st_mtime_ns
            audit.write_output(path, "stable\n")
            self.assertEqual(path.stat().st_mtime_ns, before)

    def test_snapshot_includes_generated_catalog_without_unrelated_untracked_files(self):
        with tempfile.TemporaryDirectory() as folder:
            root = Path(folder)
            repo = root / "repo"
            asset = repo / "res/assets/privacy_permissions.json"
            asset.parent.mkdir(parents=True)
            asset.write_text('{"schema_version": 1}\n')
            (repo / "pubspec.yaml").write_text("name: audit_fixture\n")
            (repo / "unrelated.env").write_text("fixture only\n")
            destination = root / "snapshot"
            with patch.object(audit, "command", return_value=b"pubspec.yaml\0"):
                audit.snapshot(repo, destination)
            self.assertEqual((destination / asset.relative_to(repo)).read_bytes(), asset.read_bytes())
            self.assertFalse((destination / "unrelated.env").exists())

    def test_snapshot_explicit_inputs_are_source_files_within_the_repo(self):
        with tempfile.TemporaryDirectory() as folder:
            root = Path(folder)
            repo = root / "repo"
            source = repo / "lib/new_page.dart"
            source.parent.mkdir(parents=True)
            source.write_text("class Fixture {}\n")
            external = root / "outside.dart"
            external.write_text("fixture only\n")
            with patch.object(audit, "command", return_value=b""):
                audit.snapshot(repo, root / "good", extra_inputs=(Path("lib/new_page.dart"),))
            self.assertEqual((root / "good/lib/new_page.dart").read_bytes(), source.read_bytes())
            for index, invalid in enumerate((Path("../outside.dart"), external, Path(".env"), Path("lib/missing.dart"))):
                with self.assertRaises(audit.AuditError):
                    audit.snapshot(repo, root / str(index), extra_inputs=(invalid,))

    def test_snapshot_follows_referenced_untracked_dart_sources_only(self):
        with tempfile.TemporaryDirectory() as folder:
            root = Path(folder)
            repo = root / "repo"
            lib = repo / "lib"
            lib.mkdir(parents=True)
            (repo / "pubspec.yaml").write_text("name: fixture\n")
            (lib / "main.dart").write_text("import 'alias.dart' if (dart.library.io) 'io.dart';\n")
            (lib / "alias.dart").symlink_to("page.dart")
            (lib / "page.dart").write_text("export 'package:fixture/model.dart';\n")
            (lib / "model.dart").write_text("part 'part.dart';\n")
            (lib / "part.dart").write_text("part of 'model.dart';\n")
            (lib / "io.dart").write_text("class IO {}\n")
            (lib / "unrelated.dart").write_text("class Unused {}\n")
            destination = root / "snapshot"
            with patch.object(audit, "command", return_value=b"pubspec.yaml\0lib/main.dart\0"):
                audit.snapshot(repo, destination)
            for name in ("main.dart", "alias.dart", "model.dart", "part.dart", "io.dart"):
                self.assertTrue((destination / "lib" / name).is_file(), name)
            self.assertFalse((destination / "lib/unrelated.dart").exists())


class CacheTests(unittest.TestCase):
    def repo(self, folder):
        repo = Path(folder) / "repo"
        repo.mkdir()
        (repo / "pubspec.yaml").write_text("name: fixture\nversion: 1.2.3+42\n")
        return repo

    def seed(self, repo, flavor="github", version=("1.2.3", "42")):
        root = audit.cache_root(repo) / ("seed-" + flavor)
        root.mkdir(parents=True)
        package = root / (flavor + ".apk")
        package.write_bytes(b"fixture package")
        record = {"artifact": package.name, "platform": "android", "flavor": flavor, "status": "inspected",
                  "sha256": audit.digest(package), "cache_version_name": version[0],
                  "cache_build_number": version[1], "cached_at_utc": "2026-01-01T00:00:00Z"}
        index = root / "index.json"
        index.write_text(json.dumps({"schema_version": 1, "artifacts": [record]}))
        return package, index

    def inspect(self, path, repo, bundletool, env):
        return {**android(), "artifact": str(path), "sha256": audit.digest(path), "provenance": "fixture"}

    def build(self, repo, platform, flavor, run, env, *args):
        package = run / "workspaces" / flavor / (flavor + ".apk")
        package.parent.mkdir(parents=True)
        package.write_bytes(b"new fixture package")
        return {"platform": platform, "flavor": flavor, "status": "built", "artifacts": [str(package)],
                "input_sha256": "fixture", "recipe": "release", "commands": []}

    def invoke(self, repo, *args):
        output = repo / "result.json"
        argv = ["list_permissions.py", "--repo", str(repo), "--output", str(output), *args]
        with patch.object(sys, "argv", argv), contextlib.redirect_stderr(io.StringIO()):
            code = audit.main()
        return code, json.loads(output.read_text())

    def test_cache_hit_reparses_without_building_or_copying(self):
        with tempfile.TemporaryDirectory() as folder:
            repo = self.repo(folder)
            package, index = self.seed(repo)
            with patch.object(audit, "inspect_artifact", side_effect=self.inspect) as inspect, patch.object(audit, "build_artifacts") as build:
                code, result = self.invoke(repo, "--platform", "android", "--flavor", "github")
            self.assertEqual(code, 0)
            build.assert_not_called()
            inspect.assert_called_once()
            self.assertEqual(result["cache_hits"], 1)
            self.assertEqual(result["artifacts"][0]["provenance"], "cache_reparsed")
            self.assertEqual(Path(result["artifacts"][0]["artifact"]), package)
            self.assertEqual(result["mode"], "cache_first")

    def test_only_missing_target_builds_then_retains_and_removes_its_workspace(self):
        with tempfile.TemporaryDirectory() as folder:
            repo = self.repo(folder)
            old, _ = self.seed(repo)
            with patch.object(audit, "inspect_artifact", side_effect=self.inspect), patch.object(audit, "build_artifacts", side_effect=self.build) as build:
                code, result = self.invoke(repo, "--platform", "android", "--flavor", "github", "--flavor", "play")
            self.assertEqual(code, 0)
            self.assertEqual([(c.args[1], c.args[2]) for c in build.call_args_list], [("android", "play")])
            self.assertTrue(old.exists())
            self.assertFalse(Path(result["run_directory"]).exists())
            self.assertTrue(Path(result["retained_index"]).exists())
            for record in result["artifacts"]:
                self.assertTrue(Path(record["artifact"]).is_file())
            _, missing, _ = audit.cached_artifacts(repo, [("android", "github"), ("android", "play")])
            self.assertEqual(missing, [])

    def test_changed_or_wrong_version_cache_is_not_reused(self):
        for mismatch in ("hash", "version"):
            with self.subTest(mismatch=mismatch), tempfile.TemporaryDirectory() as folder:
                repo = self.repo(folder)
                package, _ = self.seed(repo, version=("1.2.2", "41") if mismatch == "version" else ("1.2.3", "42"))
                if mismatch == "hash":
                    package.write_bytes(b"changed")
                found, missing, _ = audit.cached_artifacts(repo, [("android", "github")])
                self.assertEqual(found, [])
                self.assertEqual(missing, [("android", "github")])

    def test_force_build_ignores_valid_cache(self):
        with tempfile.TemporaryDirectory() as folder:
            repo = self.repo(folder)
            old, _ = self.seed(repo)
            with patch.object(audit, "inspect_artifact", side_effect=self.inspect), patch.object(audit, "build_artifacts", side_effect=self.build) as build:
                code, result = self.invoke(repo, "--build", "android", "--flavor", "github")
            self.assertEqual(code, 0)
            self.assertEqual(build.call_count, 1)
            self.assertEqual(result["mode"], "force_build")
            self.assertTrue(old.exists())

    def test_invalid_newer_entry_does_not_hide_an_older_valid_package(self):
        with tempfile.TemporaryDirectory() as folder:
            repo = self.repo(folder)
            package, index = self.seed(repo)
            newer = index.parent.parent / "newer"
            newer.mkdir()
            record = json.loads(index.read_text())["artifacts"][0]
            record.update(artifact="missing.apk", cached_at_utc="2026-02-01T00:00:00Z")
            (newer / "index.json").write_text(json.dumps({"schema_version": 1, "artifacts": [record]}))
            found, missing, _ = audit.cached_artifacts(repo, [("android", "github")])
            self.assertEqual(missing, [])
            self.assertEqual(Path(found[0]["artifact"]), package)

    def test_parse_failure_does_not_rebuild_a_valid_cached_package(self):
        with tempfile.TemporaryDirectory() as folder:
            repo = self.repo(folder)
            package, _ = self.seed(repo)
            failed = {"artifact": str(package), "platform": "android", "status": "unverified", "sha256": audit.digest(package), "error": "missing parser"}
            with patch.object(audit, "inspect_artifact", return_value=failed), patch.object(audit, "build_artifacts") as build:
                code, result = self.invoke(repo, "--platform", "android", "--flavor", "github")
            self.assertEqual(code, 1)
            build.assert_not_called()
            self.assertTrue(package.exists())

    def test_explicit_missing_artifact_does_not_build(self):
        with tempfile.TemporaryDirectory() as folder:
            repo = self.repo(folder)
            with patch.object(audit, "build_artifacts") as build:
                code, result = self.invoke(repo, "--artifact", str(repo / "missing.apk"))
            self.assertEqual(code, 1)
            self.assertEqual(result["mode"], "explicit_read")
            build.assert_not_called()

    def test_failed_build_keeps_evidence_and_existing_archive(self):
        with tempfile.TemporaryDirectory() as folder:
            repo = self.repo(folder)
            old, _ = self.seed(repo)
            failed = {"platform": "android", "flavor": "github", "status": "unverified", "artifacts": [], "error": "fixture failure"}
            with patch.object(audit, "build_artifacts", return_value=failed), patch.object(audit, "retain_artifacts") as retain:
                code, result = self.invoke(repo, "--build", "android", "--flavor", "github")
            self.assertEqual(code, 1)
            retain.assert_not_called()
            self.assertTrue(Path(result["run_directory"]).exists())
            self.assertTrue(old.exists())

    def test_cleanup_never_removes_a_non_run_or_a_requested_output(self):
        with tempfile.TemporaryDirectory() as folder:
            repo = self.repo(folder)
            other = repo / "build/app"
            other.mkdir(parents=True)
            with self.assertRaises(audit.AuditError):
                audit.remove_completed_run(repo, other, [])
            self.assertTrue(other.exists())
            run = repo / "build/privacy-audit/run-fixture"
            run.mkdir(parents=True)
            self.assertFalse(audit.remove_completed_run(repo, run, [run / "output.json"]))
            self.assertTrue(run.exists())

    def test_cached_tool_fingerprint_is_checked_before_execution(self):
        with tempfile.TemporaryDirectory() as folder:
            repo = self.repo(folder)
            tool = repo / "bundletool.jar"
            tool.write_bytes(b"tool fixture")
            audit.retain_tool(repo, tool)
            cached = audit.cached_tool(repo)
            self.assertEqual(cached.read_bytes(), tool.read_bytes())
            cached.write_bytes(b"changed tool")
            with self.assertRaises(audit.AuditError):
                audit.cached_tool(repo)


if __name__ == "__main__":
    unittest.main()
