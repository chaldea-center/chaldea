#!/usr/bin/env python3
r"""Inspect final release-package permission declarations (Python 3.10+, standard library only).

Run from the repository root; --repo selects another checkout. Examples:

  # Reparse cached targets; build and archive only missing supported targets.
  python3 scripts/list_permissions.py --output /tmp/permissions.json \
      --markdown-output /tmp/permissions.md \
      --catalog-output res/assets/privacy_permissions.json

  # Limit cache-first inspection, or force a rebuild after App/SDK/permission changes.
  python3 scripts/list_permissions.py --platform android --flavor play
  python3 scripts/list_permissions.py --build android --flavor play

  # Inspect existing inputs without building or archiving; inputs are not modified.
  python3 scripts/list_permissions.py --artifact /path/to/app.apk --artifact-flavor github
  python3 scripts/list_permissions.py --from-report /path/to/permissions.json

Default mode reads fingerprint-verified artifacts indexed under
.build/permission-artifacts/, matching the pubspec version, platform and flavor.
Source changes without a version change require --build to refresh that cache.
Android flavors: github, play, fdroid. Build targets: android, ios, macos, web;
actual build availability depends on the host and installed Flutter/native tools.
Android inspection requires SDK tools; AAB also needs Java and an official
bundletool JAR (--bundletool or the retained tool index). Apple inspection uses
Xcode command-line tools; iOS signing can be skipped with --unsigned-ios.

Reports default to JSON on stdout (--format markdown for text). --output and
--markdown-output write audit reports; --catalog-output explicitly writes the
compact App catalog. A catalog covers only the supplied/selected artifacts, so
include the full target matrix when replacing the bundled App catalog. Outputs
must not overwrite source artifacts or imported reports.

Successful builds retain complete artifacts and reports under .build, then
remove their isolated build directory; failed build directories remain for
inspection. No App permission/source changes or CI integration are performed.
This audits package declarations, not runtime requests, user grants or actual
data collection. Apple signature evidence may be partial; unsupported or missing
platforms are reported as unverified. Run with --help for all options.
"""

from __future__ import annotations

import argparse
import datetime as dt
import hashlib
import json
import os
from pathlib import Path, PurePosixPath
import plistlib
import re
import shutil
import subprocess
import sys
import tempfile
import xml.etree.ElementTree as ET
import zipfile


ANDROID = "{http://schemas.android.com/apk/res/android}"
FLAVORS = ("github", "play", "fdroid")
PLATFORMS = ("android", "ios", "macos", "windows", "linux", "web")
BUILD_PLATFORMS = ("android", "ios", "macos", "web")


class AuditError(Exception):
    pass


def digest(path: Path) -> str:
    result = hashlib.sha256()
    with path.open("rb") as stream:
        for block in iter(lambda: stream.read(1024 * 1024), b""):
            result.update(block)
    return result.hexdigest()


def command(args: list[str], *, env: dict | None = None) -> bytes:
    try:
        result = subprocess.run(args, capture_output=True, env=env, check=False)
    except OSError as error:
        raise AuditError(f"Cannot run {args[0]}: {error}") from error
    if result.returncode:
        # Build logs are saved separately; do not dump arbitrary tool output.
        raise AuditError(f"{Path(args[0]).name} exited with {result.returncode}")
    return result.stdout


def sdk_path(repo: Path) -> Path | None:
    properties = repo / "android/local.properties"
    if properties.exists():
        for line in properties.read_text().splitlines():
            if line.startswith("sdk.dir="):
                return Path(line.split("=", 1)[1].replace("\\ ", " "))
    for name in ("ANDROID_HOME", "ANDROID_SDK_ROOT"):
        if os.environ.get(name):
            return Path(os.environ[name])
    candidate = Path.home() / "Library/Android/sdk"
    return candidate if candidate.exists() else None


def tool_environment() -> dict:
    env = os.environ.copy()
    if not env.get("JAVA_HOME"):
        for home in (
            str(Path.home() / "Applications/Android Studio.app/Contents/jbr/Contents/Home"),
            "/Applications/Android Studio.app/Contents/jbr/Contents/Home",
            "/Applications/Android Studio Preview.app/Contents/jbr/Contents/Home",
        ):
            if (Path(home) / "bin/java").exists():
                env["JAVA_HOME"] = home
                break
    if env.get("JAVA_HOME"):
        env["PATH"] = str(Path(env["JAVA_HOME"]) / "bin") + os.pathsep + env.get("PATH", "")
    return env


def android_manifest(xml: bytes) -> dict:
    root = ET.fromstring(xml)
    result: dict = {"application_id": root.get("package"), "permissions": [], "features": []}
    for key in ("versionCode", "versionName"):
        if root.get(ANDROID + key) is not None:
            result[key] = root.get(ANDROID + key)
    for child in root:
        if child.tag in ("uses-permission", "uses-permission-sdk-23", "permission"):
            result["permissions"].append({
                "kind": child.tag,
                **{key: child.get(ANDROID + key) for key in (
                    "name", "maxSdkVersion", "minSdkVersion", "protectionLevel", "usesPermissionFlags"
                ) if child.get(ANDROID + key) is not None},
            })
        elif child.tag == "uses-feature":
            result["features"].append({
                key: child.get(ANDROID + key) for key in ("name", "required", "glEsVersion")
                if child.get(ANDROID + key) is not None
            })
        elif child.tag == "uses-sdk":
            result["sdk"] = {
                key: child.get(ANDROID + key) for key in ("minSdkVersion", "targetSdkVersion", "maxSdkVersion")
                if child.get(ANDROID + key) is not None
            }
    return result


def apk_details(path: Path, repo: Path, env: dict) -> dict:
    sdk = sdk_path(repo)
    candidates = [shutil.which("apkanalyzer", path=env.get("PATH"))]
    if sdk:
        candidates.extend(str(p) for p in sorted(sdk.glob("cmdline-tools/*/bin/apkanalyzer"), reverse=True))
    analyzer = next((p for p in candidates if p and Path(p).is_file()), None)
    if not analyzer:
        raise AuditError("APK requires Android SDK apkanalyzer; source manifests are not a fallback")
    result = android_manifest(command([analyzer, "manifest", "print", str(path)], env=env))
    result.update(platform="android", evidence="packaged_artifact", tool=analyzer)
    # Library presence is separate from initialization or data collection.
    with zipfile.ZipFile(path) as archive:
        result["native_libraries"] = sorted(name for name in archive.namelist()
                                              if name.startswith("lib/") and name.endswith(".so"))
    return result


def aab_details(path: Path, bundletool: Path | None, env: dict) -> dict:
    if bundletool is None:
        raise AuditError("AAB requires --bundletool <official bundletool jar>; no source-only substitution")
    java = str(Path(env["JAVA_HOME"]) / "bin/java") if env.get("JAVA_HOME") else "java"
    with zipfile.ZipFile(path) as archive:
        modules = sorted({name.split("/", 1)[0] for name in archive.namelist()
                          if name.endswith("/manifest/AndroidManifest.xml")})
    if not modules:
        raise AuditError("AAB has no module manifests")
    results = {}
    for module in modules:
        xml = command([java, "-jar", str(bundletool), "dump", "manifest",
                       f"--bundle={path}", f"--module={module}"], env=env)
        results[module] = android_manifest(xml)
    return {"platform": "android", "evidence": "packaged_artifact", "modules": results,
            "tool": str(bundletool), "tool_sha256": digest(bundletool)}


def apple_info(data: dict) -> dict:
    keys = ("CFBundleIdentifier", "CFBundleShortVersionString", "CFBundleVersion", "UIBackgroundModes")
    return {key: value for key, value in data.items() if key in keys or key.endswith("UsageDescription")}


def signed_entitlements(path: Path, env: dict) -> dict:
    try:
        value = command(["codesign", "-d", "--entitlements", ":-", str(path)], env=env)
        if not value.strip():
            return {"status": "unverified", "reason": "No signed entitlement plist returned"}
        return {"status": "inspected", "values": plistlib.loads(value)}
    except (AuditError, plistlib.InvalidFileException, ValueError) as error:
        return {"status": "unverified", "reason": str(error)}


def apple_details(path: Path, env: dict) -> dict:
    if path.suffix == ".ipa":
        with zipfile.ZipFile(path) as archive:
            roots = [n for n in archive.namelist()
                     if len(PurePosixPath(n).parts) == 3 and n.startswith("Payload/")
                     and n.endswith(".app/Info.plist")]
            if len(roots) != 1:
                raise AuditError("IPA must contain exactly one primary Payload app")
            name = roots[0]
            info = plistlib.loads(archive.read(name))
            prefix = name.removesuffix("Info.plist")
            manifests = {n: plistlib.loads(archive.read(n)) for n in archive.namelist()
                         if n.startswith(prefix) and n.endswith("/PrivacyInfo.xcprivacy")}
            executable = info.get("CFBundleExecutable", "")
            if not executable or PurePosixPath(executable).name != executable:
                raise AuditError("IPA has an invalid primary executable name")
            # Only materialize the main executable for codesign inspection.
            with tempfile.TemporaryDirectory(prefix="chaldea-permissions-") as directory:
                binary = Path(directory) / "executable"
                binary.write_bytes(archive.read(prefix + executable))
                entitlements = signed_entitlements(binary, env)
        return {"platform": "ios", "evidence": "packaged_artifact", "info": apple_info(info),
                "privacy_manifests": manifests, "signed_entitlements": entitlements}
    if path.suffix == ".xcarchive":
        apps = list((path / "Products/Applications").glob("*.app"))
        if len(apps) != 1:
            raise AuditError("Archive must contain exactly one primary application")
        path = apps[0]
    info_path = path / "Contents/Info.plist" if (path / "Contents/Info.plist").exists() else path / "Info.plist"
    if not info_path.exists():
        raise AuditError("No built application Info.plist found")
    info = plistlib.loads(info_path.read_bytes())
    manifests = {str(p.relative_to(path)): plistlib.loads(p.read_bytes())
                 for p in sorted(path.rglob("PrivacyInfo.xcprivacy"))}
    return {"platform": "macos" if info_path.parent.name == "Contents" else "ios",
            "evidence": "built_application", "info": apple_info(info), "privacy_manifests": manifests,
            "signed_entitlements": signed_entitlements(path, env)}


def artifact_fingerprint(path: Path) -> dict:
    if path.is_file():
        return {"sha256": digest(path)}
    elif path.is_dir():
        tree = hashlib.sha256()
        for child in sorted(path.rglob("*")):
            if child.is_symlink():
                value = "symlink:" + os.readlink(child)
            elif child.is_file():
                value = digest(child)
            else:
                continue
            tree.update((str(child.relative_to(path)) + "\0" + value + "\n").encode())
        return {"sha256_tree": tree.hexdigest()}
    raise AuditError("Artifact does not exist")


def inspect_artifact(path: Path, repo: Path, bundletool: Path | None, env: dict) -> dict:
    path = path.expanduser().resolve()
    record = {"artifact": str(path), "status": "inspected"}
    try:
        record.update(artifact_fingerprint(path))
        record["mtime_utc"] = dt.datetime.fromtimestamp(path.stat().st_mtime, dt.timezone.utc).isoformat()
        if path.suffix == ".apk":
            record.update(apk_details(path, repo, env))
        elif path.suffix == ".aab":
            record.update(aab_details(path, bundletool, env))
        elif path.suffix in (".app", ".ipa", ".xcarchive"):
            record.update(apple_details(path, env))
            signed = record["signed_entitlements"]
            if signed["status"] == "unverified":
                record["status"] = "partial"
            elif any(signed.get("values", {}).get(key) for key in (
                "get-task-allow", "com.apple.security.get-task-allow"
            )):
                record.update(status="partial", limitation=(
                    "Development debugging entitlement is enabled; these built-app declarations "
                    "do not verify exported App Store/distribution entitlements"
                ))
        elif path.is_dir() and (path / "flutter_bootstrap.js").exists():
            manifest = path / "manifest.json"
            record.update(platform="web", evidence="built_web", status="partial",
                          manifest=json.loads(manifest.read_text()) if manifest.exists() else {},
                          limitation="PWA metadata does not prove browser permission requests or grants")
        else:
            raise AuditError("Unsupported artifact; native Windows/Linux packages need platform-specific inspection")
    except (AuditError, ET.ParseError, plistlib.InvalidFileException, OSError, ValueError,
            zipfile.BadZipFile, KeyError) as error:
        record.update(status="unverified", error=str(error))
    return record


def snapshot(repo: Path, destination: Path, *, android_signing: bool = False,
             extra_inputs: tuple[Path, ...] = ()) -> str:
    repo = repo.resolve()
    if destination.exists():
        raise AuditError(f"Audit workspace already exists: {destination}")
    for relative in extra_inputs:
        if (relative.is_absolute() or not relative.parts or ".." in relative.parts
                or relative.parts[0] not in ("lib", "res", "scripts", "test")
                or not (repo / relative).resolve().is_relative_to(repo.resolve())
                or not (repo / relative).is_file()):
            raise AuditError("Extra inputs must be existing repo-relative source files under lib/res/scripts/test")
    files = command(["git", "-C", str(repo), "ls-files", "-z"]).decode().split("\0")
    destination.mkdir(parents=True)
    hashes = {}
    for relative in sorted(filter(None, files)):
        parts = PurePosixPath(relative).parts
        if parts[0] in (".git", "build", ".build", ".dart_tool", ".workbuddy", "docs", "data"):
            continue
        source = repo / relative
        if not source.is_file():
            continue
        target = destination / relative
        target.parent.mkdir(parents=True, exist_ok=True)
        shutil.copy2(source, target, follow_symlinks=False)
        hashes[relative] = digest(source)
    # Some generated build inputs are intentionally ignored by Git.
    for relative in (Path("lib/generated/git.g.dart"), Path("lib/generated/git_info.dart"),
                     Path("android/local.properties"), Path("res/assets/privacy_permissions.json"), *extra_inputs):
        source = repo / relative
        if source.is_file():
            target = destination / relative
            target.parent.mkdir(parents=True, exist_ok=True)
            shutil.copy2(source, target)
            hashes[str(relative)] = digest(source)
    # Follow source directives so newly added, referenced Dart files need no git add.
    pubspec = repo / "pubspec.yaml"
    package = re.search(r"^name:\s*([\w]+)", pubspec.read_text(), re.MULTILINE) if pubspec.exists() else None
    prefix = f"package:{package.group(1)}/" if package else "package:chaldea/"
    pending = list((destination / "lib").rglob("*.dart"))
    seen = set()
    while pending:
        copied = pending.pop()
        if copied in seen:
            continue
        seen.add(copied)
        for directive in re.findall(r"^\s*(?:import|export|part)\s+([^;]+);", copied.read_text(), re.MULTILINE):
            for uri in re.findall(r"['\"]([^'\"]+\.dart)['\"]", directive):
                if uri.startswith(prefix):
                    source = repo / "lib" / uri[len(prefix):]
                elif ":" not in uri and not Path(uri).is_absolute():
                    source = repo / copied.relative_to(destination).parent / uri
                else:
                    continue
                source = Path(os.path.abspath(source))
                if (not source.is_relative_to(repo.resolve() / "lib")
                        or not source.resolve().is_relative_to((repo / "lib").resolve()) or not source.is_file()):
                    continue
                relative = source.relative_to(repo.resolve())
                target = destination / relative
                if not target.exists():
                    target.parent.mkdir(parents=True, exist_ok=True)
                    shutil.copy2(source, target)
                    hashes[str(relative)] = digest(target)
                    pending.append(target)
    # Reuse signing through symlinks; do not copy or print credential/key contents.
    signing_files = [repo / "android/key.properties"] if android_signing else []
    if android_signing:
        for extension in ("*.jks", "*.keystore"):
            signing_files.extend((repo / "android").rglob(extension))
    for source in signing_files:
        if source.is_file():
            target = destination / source.relative_to(repo)
            if not target.exists():
                target.parent.mkdir(parents=True, exist_ok=True)
                target.symlink_to(source.resolve())
    identifier = hashlib.sha256(json.dumps(hashes, sort_keys=True).encode()).hexdigest()
    (destination.parent / (destination.name + "-inputs.json")).write_text(
        json.dumps({"sha256": identifier, "files": hashes}, indent=2) + "\n")
    return identifier


def permission_origins(text: str) -> dict:
    """Read AGP decision nodes without depending on blank-line separators."""
    result: dict = {}
    current = None
    actions = ("ADDED ", "MERGED ", "INJECTED ", "REMOVED ", "REJECTED ", "IMPLIED ")
    for line in text.splitlines():
        if line.startswith(("uses-permission#", "uses-permission-sdk-23#", "permission#", "uses-feature#")):
            current = line.strip()
            result.setdefault(current, [])
        elif current and line:
            if line[0].isspace() or line.startswith(actions):
                if len(result[current]) < 40:
                    result[current].append(line.strip())
            else:
                current = None
    return result


def build_artifacts(repo: Path, platform: str, flavor: str | None, run_dir: Path, env: dict,
                    unsigned_ios: bool = False, extra_inputs: tuple[Path, ...] = ()) -> dict:
    name = flavor if platform == "android" else platform
    workspace = run_dir / "workspaces" / str(name)
    result = {"platform": platform, "flavor": flavor, "workspace": str(workspace),
              "commands": [], "artifacts": [], "status": "unverified"}
    if platform in ("ios", "macos") and sys.platform != "darwin":
        return {**result, "error": "Apple build requires a macOS host"}
    result["input_sha256"] = snapshot(repo, workspace, android_signing=platform == "android", extra_inputs=extra_inputs)
    flutter = shutil.which("flutter", path=env.get("PATH"))
    dart = shutil.which("dart", path=env.get("PATH"))
    if not flutter or not dart:
        return {**result, "error": "Flutter/Dart executables were not found"}
    steps = [[flutter, "pub", "get"]]
    if platform == "android" and flavor in ("play", "fdroid"):
        target = "android-play" if flavor == "play" else "fdroid"
        steps.append([dart, "scripts/patch_before_build.dart", target])
    if platform == "web":
        steps.append([dart, "scripts/patch_before_build.dart", "web"])
    target = "appbundle" if flavor == "play" else "apk" if platform == "android" else platform
    args = [flutter, "build", target, "--release", "--no-pub"]
    if platform == "android":
        args.append(f"--flavor={flavor}")
    if platform == "ios" and unsigned_ios:
        # Signed entitlements remain explicitly unverified in an unsigned audit.
        args.append("--no-codesign")
    steps.append(args)
    log_dir = run_dir / "logs"
    log_dir.mkdir(parents=True, exist_ok=True)
    for index, args in enumerate(steps):
        log = log_dir / f"{name}-{index}.log"
        result["commands"].append({"argv": args, "log": str(log)})
        print(f"[{name}] {' '.join(args)} (log: {log})", file=sys.stderr, flush=True)
        try:
            with log.open("wb") as stream:
                completed = subprocess.run(args, cwd=workspace, env=env, stdout=stream, stderr=subprocess.STDOUT)
        except OSError as error:
            return {**result, "error": str(error)}
        if completed.returncode:
            return {**result, "error": f"Build step exited with {completed.returncode}; see {log}"}
    patterns = {
        "android": [f"build/app/outputs/bundle/{flavor}Release/*.aab"] if flavor == "play"
                   else [f"build/app/outputs/flutter-apk/*{flavor}*release*.apk"],
        "ios": ["build/ios/iphoneos/*.app"],
        "macos": ["build/macos/Build/Products/Release/*.app"],
        "web": ["build/web"],
    }
    result["artifacts"] = [str(p) for pattern in patterns[platform] for p in workspace.glob(pattern)]
    result["resolved_inputs"] = {
        relative: digest(workspace / relative)
        for relative in ("pubspec.yaml", "pubspec.lock", "lib/packages/ads/ads.dart")
        if (workspace / relative).is_file()
    }
    result["status"] = "built" if result["artifacts"] else "unverified"
    if not result["artifacts"]:
        result["error"] = "Build returned success but no expected artifact was found"
    result["recipe"] = "repository release patch" if flavor in ("play", "fdroid") or platform == "web" else "release"
    if platform == "ios" and unsigned_ios:
        result["recipe"] += " (unsigned; signed entitlements unverified)"
    reports = list((workspace / "build/app/outputs/logs").glob("manifest-merger-*-report.txt"))
    result["manifest_merger_reports"] = [str(p) for p in reports]
    result["permission_origins"] = {}
    for report in reports:
        result["permission_origins"].update(permission_origins(report.read_text(errors="replace")))
    return result


def report_artifacts(path: Path) -> tuple[dict, list[dict]]:
    """A prior report supplies artifact identities, never a source-only fallback."""
    try:
        data = json.loads(path.read_text())
    except (OSError, ValueError) as error:
        raise AuditError(f"Cannot read input report: {path}") from error
    if not isinstance(data, dict) or data.get("schema_version") != 1 or not isinstance(data.get("artifacts"), list):
        raise AuditError(f"Unsupported input report: {path}")
    records = []
    for record in data["artifacts"]:
        if not isinstance(record, dict) or not isinstance(record.get("artifact"), str):
            raise AuditError(f"Invalid artifact record in {path}")
        if record.get("status") not in ("inspected", "partial"):
            raise AuditError(f"Input report contains an unverified artifact: {path}")
        fingerprint = "sha256" if record.get("sha256") else "sha256_tree"
        value = record.get(fingerprint)
        if not isinstance(value, str) or len(value) != 64 or any(c not in "0123456789abcdef" for c in value):
            raise AuditError(f"Input report lacks an artifact fingerprint: {path}")
        artifact = Path(record["artifact"])
        if not artifact.is_absolute():
            artifact = path.resolve().parent / artifact
        records.append({**record, "artifact": str(artifact.resolve()), "source_report": str(path.resolve())})
    if not records:
        raise AuditError(f"Input report contains no inspected artifacts: {path}")
    return {"path": str(path.resolve()), "sha256": digest(path)}, records


def canonical_declarations(declarations: list[dict]) -> list[dict]:
    # Keep differing SDK bounds/module declarations; only exact duplicates collapse.
    encoded = {json.dumps(row, ensure_ascii=False, sort_keys=True) for row in declarations}
    return sorted((json.loads(row) for row in encoded), key=lambda row: (
        row["kind"], row["name"], json.dumps(row, ensure_ascii=False, sort_keys=True)
    ))


def catalog_target(artifact: dict) -> dict:
    platform = artifact.get("platform")
    flavor = artifact.get("flavor")
    if platform not in PLATFORMS:
        raise AuditError("Catalog artifact has no supported platform")
    if platform == "android" and flavor not in FLAVORS:
        raise AuditError("Android catalog needs an explicit flavor: use --build, --from-report or --artifact-flavor")
    result = {"platform": platform, "flavor": flavor if platform == "android" else None,
              "status": artifact["status"], "declarations": []}
    if artifact["status"] not in ("inspected", "partial"):
        return {**result, "status": "unverified", "limitations": ["artifact_not_inspected"]}
    if platform == "web":
        # No Android-style browser permission inventory exists in a Flutter PWA manifest.
        return {**result, "status": "unverified", "limitations": ["browser_permissions_not_inspected"]}
    if platform == "android":
        modules = artifact.get("modules", {None: artifact})
        base = modules.get("base", next(iter(modules.values())))
        result.update(application_id=base.get("application_id"), version_name=base.get("versionName"),
                      build_number=base.get("versionCode"))
        if base.get("sdk"):
            result["sdk"] = base["sdk"]
        for module, manifest in modules.items():
            if manifest.get("application_id") != result["application_id"]:
                raise AuditError("AAB modules disagree on application ID")
            for row in manifest.get("permissions", []):
                declaration = dict(row)
                if module is not None:
                    declaration["module"] = module
                result["declarations"].append(declaration)
    else:
        info = artifact.get("info", {})
        result.update(application_id=info.get("CFBundleIdentifier"),
                      version_name=info.get("CFBundleShortVersionString"), build_number=info.get("CFBundleVersion"))
        for name, value in info.items():
            if name.endswith("UsageDescription"):
                result["declarations"].append({"kind": "usage-description", "name": name, "value": value})
            elif name == "UIBackgroundModes":
                result["declarations"].extend({"kind": "background-mode", "name": mode} for mode in value)
        signed = artifact.get("signed_entitlements", {"status": "unverified"})
        result["checks"] = {"info_plist": "inspected", "signed_entitlements": signed["status"],
                            "distribution_signature": "unverified"}
        result["limitations"] = ["distribution_signature_not_verified"]
        if signed["status"] == "inspected":
            for name, value in signed.get("values", {}).items():
                result["declarations"].append({"kind": "entitlement", "name": name, "value": value})
            if any(signed.get("values", {}).get(key) for key in (
                "get-task-allow", "com.apple.security.get-task-allow"
            )):
                result["limitations"].append("development_debugging_entitlement")
        else:
            result["limitations"].append("signed_entitlements_not_inspected")
        result["status"] = "partial"
    if not all(result.get(key) for key in ("application_id", "version_name", "build_number")):
        raise AuditError("Catalog artifact lacks package identity/version")
    result["declarations"] = canonical_declarations(result["declarations"])
    return result


def app_catalog(report: dict) -> dict:
    """Export observed declarations, with no inferred purpose or authorization state."""
    targets = {}
    for platform in PLATFORMS:
        for flavor in FLAVORS if platform == "android" else (None,):
            targets[platform, flavor] = {
                "platform": platform, "flavor": flavor, "status": "unverified", "declarations": [],
                "limitations": ["no_artifact"],
            }
    seen = set()
    for artifact in report["artifacts"]:
        target = catalog_target(artifact)
        key = target["platform"], target["flavor"]
        if key in seen and targets[key] != target:
            raise AuditError(f"Conflicting catalog artifacts for {key}; select one release per target")
        targets[key] = target
        seen.add(key)
    return {"schema_version": 1, "scope": "package_declarations", "runtime_authorization_verified": False,
            "targets": list(targets.values())}


def validate_outputs(outputs: list[Path], inputs: list[Path]) -> None:
    resolved = [path.resolve() for path in outputs]
    if len(set(resolved)) != len(resolved):
        raise AuditError("Output paths must be distinct")
    for output in resolved:
        for source in inputs:
            source = source.resolve()
            if output == source or (source.is_dir() and output.is_relative_to(source)):
                raise AuditError("Report/catalog outputs must not overwrite or modify an input")


def write_output(path: Path, text: str) -> None:
    if path.exists() and path.read_text() == text:
        return
    path.parent.mkdir(parents=True, exist_ok=True)
    temporary = None
    try:
        with tempfile.NamedTemporaryFile(mode="w", encoding="utf-8", dir=path.parent, delete=False) as stream:
            temporary = Path(stream.name)
            stream.write(text)
        temporary.replace(path)
    finally:
        if temporary and temporary.exists():
            temporary.unlink()


def cache_root(repo: Path) -> Path:
    root = (repo / ".build/permission-artifacts").resolve()
    if not root.is_relative_to(repo.resolve()):
        raise AuditError("Artifact cache must remain inside the repository")
    return root


def project_version(repo: Path) -> tuple[str, str]:
    try:
        text = (repo / "pubspec.yaml").read_text()
    except OSError as error:
        raise AuditError("Cache-first mode requires a readable pubspec.yaml") from error
    match = re.search(r"^version:\s*['\"]?([\w.-]+)\+(\d+)['\"]?\s*(?:#.*)?$", text, re.MULTILINE)
    if not match:
        raise AuditError("Cache-first/build mode requires version: name+build in pubspec.yaml")
    return match.group(1), match.group(2)


def record_version(record: dict) -> tuple[str | None, str | None]:
    if record.get("platform") == "android":
        base = record.get("modules", {}).get("base", record)
        return base.get("versionName"), base.get("versionCode")
    info = record.get("info", {})
    return info.get("CFBundleShortVersionString"), info.get("CFBundleVersion")


def cached_tool(repo: Path) -> Path | None:
    root = cache_root(repo)
    metadata = root / "tools.json"
    if not metadata.exists():
        return None
    try:
        entry = json.loads(metadata.read_text())["bundletool"]
        path = (root / entry["path"]).resolve()
        if not path.is_relative_to(root) or not path.is_file() or digest(path) != entry["sha256"]:
            raise AuditError("Cached bundletool fingerprint/path is invalid; supply --bundletool explicitly")
        return path
    except (OSError, ValueError, KeyError, TypeError) as error:
        raise AuditError("Invalid cached tool metadata; supply --bundletool explicitly") from error


def retain_tool(repo: Path, path: Path | None) -> None:
    if path is None:
        return
    root = cache_root(repo)
    sha = digest(path)
    target = root / "tools" / f"bundletool-{sha[:16]}.jar"
    target.parent.mkdir(parents=True, exist_ok=True)
    if not target.exists():
        shutil.copy2(path, target)
    if digest(target) != sha:
        raise AuditError("Retained bundletool fingerprint mismatch")
    write_output(root / "tools.json", json.dumps({"schema_version": 1, "bundletool": {
        "path": str(target.relative_to(root)), "sha256": sha,
    }}, indent=2) + "\n")


def cached_artifacts(repo: Path, targets: list[tuple[str, str | None]]) -> tuple[list[dict], list[tuple], list[dict]]:
    root = cache_root(repo)
    version = project_version(repo)
    candidates = []
    for index in sorted(root.glob("*/index.json"), reverse=True):
        if index.is_symlink() or not index.resolve().is_relative_to(root):
            continue
        try:
            source, records = report_artifacts(index)
            for record in records:
                if (record.get("cache_version_name"), record.get("cache_build_number")) == version:
                    candidates.append((record.get("cached_at_utc", ""), str(index), record, source))
        except AuditError as error:
            print(f"Cache index ignored: {error}", file=sys.stderr)
    candidates.sort(key=lambda item: item[:2], reverse=True)
    found, missing, sources = [], [], {}
    for platform, flavor in targets:
        for match in candidates:
            if (match[2].get("platform"), match[2].get("flavor")) != (platform, flavor):
                continue
            _, _, record, source = match
            path = Path(record["artifact"])
            fingerprint = "sha256" if record.get("sha256") else "sha256_tree"
            try:
                valid = path.is_relative_to(root) and artifact_fingerprint(path).get(fingerprint) == record[fingerprint]
            except (OSError, AuditError):
                valid = False
            if valid:
                found.append({**record, "cache_hit": True})
                sources[source["path"]] = source
                print(f"Cache hit: {platform}/{flavor or '-'}", file=sys.stderr)
                break
        else:
            missing.append((platform, flavor))
            print(f"Cache miss: {platform}/{flavor or '-'}", file=sys.stderr)
    return found, missing, list(sources.values())


def retain_artifacts(repo: Path, records: list[dict], bundletool: Path | None, env: dict,
                     destination: Path | None = None) -> tuple[Path, list[dict]]:
    """Publish an index only after copied packages have been hashed and reparsed."""
    version = project_version(repo)
    root = cache_root(repo)
    root.mkdir(parents=True, exist_ok=True)
    if destination is None:
        stamp = dt.datetime.now(dt.timezone.utc).strftime("%Y%m%dT%H%M%SZ")
        destination = Path(tempfile.mkdtemp(prefix=f"{version[0]}+{version[1]}-{stamp}-", dir=root))
    else:
        destination = destination.resolve()
        if destination.parent != root or destination.exists():
            raise AuditError("Retention destination must be a new direct child of the artifact cache")
        destination.mkdir()
    indexed, retained = [], []
    now = dt.datetime.now(dt.timezone.utc).isoformat()
    try:
        for original in records:
            if original.get("status") not in ("inspected", "partial"):
                raise AuditError("Cannot retain an uninspected artifact")
            platform, flavor = original.get("platform"), original.get("flavor")
            if platform not in BUILD_PLATFORMS or (platform == "android" and flavor not in FLAVORS):
                raise AuditError("Retained artifact requires an explicit supported target")
            if platform != "web" and record_version(original) != version:
                raise AuditError("Retained artifact version does not match pubspec.yaml")
            source = Path(original["artifact"])
            fingerprint = "sha256" if original.get("sha256") else "sha256_tree"
            if artifact_fingerprint(source).get(fingerprint) != original.get(fingerprint):
                raise AuditError("Source artifact changed before retention")
            target = destination / platform
            if platform == "android":
                target /= flavor
            if platform != "web":
                target /= source.name
            target.parent.mkdir(parents=True, exist_ok=True)
            if target.exists():
                raise AuditError("Duplicate retention target")
            if source.is_dir():
                if sys.platform == "darwin":
                    command(["ditto", str(source), str(target)], env=env)
                else:
                    shutil.copytree(source, target, symlinks=True)
            else:
                shutil.copy2(source, target)
            if artifact_fingerprint(target).get(fingerprint) != original[fingerprint]:
                raise AuditError("Copied artifact fingerprint mismatch")
            current = inspect_artifact(target, repo, bundletool, env)
            current.update(flavor=flavor, provenance="retained_artifact", original_artifact=str(source))
            if current["status"] == "unverified" or catalog_target(current) != catalog_target(original):
                raise AuditError("Reparsed retained artifact differs from its source declarations")
            for key in ("input_sha256", "recipe"):
                if key in original:
                    current[key] = original[key]
            entry = {key: current[key] for key in (
                "platform", "flavor", "status", "sha256", "sha256_tree", "input_sha256", "recipe"
            ) if key in current}
            entry.update(artifact=str(target.relative_to(destination)), cache_version_name=version[0],
                         cache_build_number=version[1], cached_at_utc=now)
            indexed.append(entry)
            retained.append(current)
        if not indexed:
            raise AuditError("No artifacts to retain")
        retain_tool(repo, bundletool)
        write_output(destination / "index.json", json.dumps({
            "schema_version": 1, "artifacts": indexed,
        }, ensure_ascii=False, indent=2) + "\n")
        return destination, retained
    except Exception:
        # Never remove the source packages on an unsuccessful copy/inspection.
        shutil.rmtree(destination)
        raise


def retain_run_evidence(run: Path, destination: Path) -> None:
    for pattern in ("logs/*.log", "workspaces/*-inputs.json", "workspaces/*/build/app/outputs/logs/*.txt"):
        for source in run.glob(pattern):
            if source.is_file() and not source.is_symlink():
                target = destination / "evidence" / source.relative_to(run)
                target.parent.mkdir(parents=True, exist_ok=True)
                shutil.copy2(source, target)


def remove_completed_run(repo: Path, run: Path, outputs: list[Path]) -> bool:
    parent = repo.resolve() / "build/privacy-audit"
    if run.is_symlink() or run.resolve().parent != parent or not run.name.startswith("run-"):
        raise AuditError("Refusing to remove a non-audit workspace")
    if any(path.resolve().is_relative_to(run.resolve()) for path in outputs):
        return False
    shutil.rmtree(run)
    return True


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    parser.add_argument("--repo", type=Path, default=Path(__file__).resolve().parent.parent)
    parser.add_argument("--artifact", type=Path, action="append", default=[])
    parser.add_argument("--artifact-flavor", choices=FLAVORS, help="Explicit flavor for existing Android artifacts")
    parser.add_argument("--from-report", type=Path, action="append", default=[],
                        help="Reinspect artifacts from prior JSON reports, checking their fingerprints")
    parser.add_argument("--build", choices=("android", "ios", "macos", "web"), action="append", default=[])
    parser.add_argument("--platform", choices=BUILD_PLATFORMS, action="append",
                        help="Select cache-first targets; default: all supported platforms")
    parser.add_argument("--flavor", choices=FLAVORS, action="append", help="Default: all Android flavors")
    parser.add_argument("--bundletool", type=Path, help="Existing official bundletool JAR for AAB inspection")
    parser.add_argument("--unsigned-ios", action="store_true", help="Build unsigned iOS; signature evidence remains unverified")
    parser.add_argument("--include-input", type=Path, action="append", default=[],
                        help="Explicit repo-relative source file to include in isolated builds, even if untracked")
    parser.add_argument("--format", choices=("json", "markdown"), default="json")
    parser.add_argument("--output", type=Path, help="Audit report; otherwise stdout")
    parser.add_argument("--catalog-output", type=Path, help="Explicitly write a compact App declaration catalog")
    parser.add_argument("--markdown-output", type=Path, help="Also write a human-readable audit report")
    options = parser.parse_args()
    cache_first = not options.artifact and not options.build and not options.from_report
    if options.platform and not cache_first:
        parser.error("--platform selects cache-first targets; use --build to force a build")
    repo = options.repo.resolve()
    env = tool_environment()
    outputs = [p for p in (options.output, options.catalog_output, options.markdown_output) if p]
    imported = []
    source_reports = []
    try:
        for path in options.from_report:
            source, records = report_artifacts(path)
            source_reports.append(source)
            imported.extend(records)
        requested = [(platform, flavor) for platform in dict.fromkeys(options.build or options.platform or BUILD_PLATFORMS)
                     for flavor in (list(dict.fromkeys(options.flavor or FLAVORS)) if platform == "android" else [None])]
        to_build = requested if options.build else []
        if cache_first:
            imported, to_build, cached_sources = cached_artifacts(repo, requested)
            source_reports.extend(cached_sources)
        bundletool = options.bundletool if options.bundletool is not None else cached_tool(repo)
        protected_inputs = options.artifact + options.from_report + [Path(a["artifact"]) for a in imported]
        protected_inputs.extend(Path(source["path"]) for source in source_reports)
        if bundletool:
            protected_inputs.append(bundletool)
        validate_outputs(outputs, protected_inputs)
    except AuditError as error:
        parser.error(str(error))
    report: dict = {"schema_version": 1, "generated_at_utc": dt.datetime.now(dt.timezone.utc).isoformat(),
                    "auditor_sha256": digest(Path(__file__)),
                    "scope": "artifact declarations; runtime requests, user grants and collection are not verified",
                    "builds": [], "artifacts": [], "unverified_platforms": []}
    report["source_reports"] = source_reports
    report["mode"] = "cache_first" if cache_first else "force_build" if options.build else "explicit_read"
    if cache_first:
        report["cache_hits"] = len(imported)
        report["cache_misses"] = [{"platform": p, "flavor": f} for p, f in to_build]
    artifacts = [(path, None) for path in options.artifact]
    artifacts.extend((Path(record["artifact"]), record) for record in imported)
    run_dir = None
    if to_build:
        run_dir = Path(tempfile.mkdtemp(prefix="run-", dir=ensure_audit_dir(repo)))
        report["run_directory"] = str(run_dir)
        for platform, flavor in to_build:
            try:
                result = build_artifacts(repo, platform, flavor, run_dir, env, options.unsigned_ios,
                                         tuple(options.include_input))
            except (AuditError, OSError) as error:
                result = {"platform": platform, "flavor": flavor, "status": "unverified", "error": str(error)}
            report["builds"].append(result)
            artifacts.extend((Path(p), None) for p in result.get("artifacts", []))
    try:
        validate_outputs(outputs, protected_inputs + [path for path, _ in artifacts])
    except AuditError as error:
        parser.error(str(error))
    for artifact, previous in artifacts:
        record = inspect_artifact(artifact, repo, bundletool, env)
        record["provenance"] = "external_or_existing_artifact"
        if options.artifact_flavor and record.get("platform") == "android" and previous is None:
            record["flavor"] = options.artifact_flavor
        if previous is not None:
            fingerprint = "sha256" if previous.get("sha256") else "sha256_tree"
            if record.get(fingerprint) != previous[fingerprint]:
                record.update(status="unverified", error="Artifact fingerprint changed since input report")
            record.update(source_report=previous["source_report"], provenance="reinspected_from_report")
            if previous.get("cache_hit"):
                record.update(provenance="cache_reparsed", cache_hit=True)
                if record["status"] != "unverified" and record.get("platform") != "web" and record_version(record) != project_version(repo):
                    record.update(status="unverified", error="Cached package identity differs from the indexed version")
            for key in ("flavor", "input_sha256", "recipe"):
                if key in previous:
                    record[key] = previous[key]
        for build in report["builds"]:
            if str(artifact) in build.get("artifacts", []):
                record.update(provenance="built_in_this_run", flavor=build["flavor"],
                              input_sha256=build["input_sha256"], recipe=build["recipe"])
        report["artifacts"].append(record)
    inspected = {p.get("platform") for p in report["artifacts"] if p["status"] in ("inspected", "partial")}
    report["unverified_platforms"] = sorted({"android", "ios", "macos", "web", "windows", "linux"} - inspected)
    if any(p == "android" for p, _ in requested) and (options.build or cache_first):
        requested = set(options.flavor or FLAVORS)
        complete = {a.get("flavor") for a in report["artifacts"]
                    if a.get("platform") == "android" and a["status"] == "inspected"}
        report["unverified_android_flavors"] = sorted(requested - complete)
    catalog = None
    if options.catalog_output:
        if any(a["status"] == "unverified" for a in report["artifacts"]):
            report["catalog_error"] = "An input artifact could not be verified"
            print(f"Catalog not written: {report['catalog_error']}", file=sys.stderr)
            catalog_error = True
        else:
            try:
                catalog = app_catalog(report)
                catalog_error = False
            except AuditError as error:
                report["catalog_error"] = str(error)
                print(f"Catalog not written: {error}", file=sys.stderr)
                catalog_error = True
        if catalog is not None:
            catalog_text = json.dumps(catalog, ensure_ascii=False, indent=2) + "\n"
            report["catalog_output"] = {"path": str(options.catalog_output.resolve()),
                                        "sha256": hashlib.sha256(catalog_text.encode()).hexdigest()}
    else:
        catalog_error = False
    failures = any(b["status"] != "built" for b in report["builds"])
    failures |= any(a["status"] == "unverified" for a in report["artifacts"])
    retained_dir = None
    if run_dir is not None and not failures and not catalog_error:
        built = [a for a in report["artifacts"] if a["provenance"] == "built_in_this_run"]
        try:
            retained_dir, retained = retain_artifacts(repo, built, bundletool, env)
            retain_run_evidence(run_dir, retained_dir)
            replacements = {record["original_artifact"]: record for record in retained}
            report["artifacts"] = [replacements.get(a["artifact"], a) for a in report["artifacts"]]
            for build in report["builds"]:
                build["original_artifacts"] = build["artifacts"]
                build["artifacts"] = [replacements[p]["artifact"] for p in build["artifacts"]]
            report["retained_index"] = str(retained_dir / "index.json")
        except (AuditError, OSError) as error:
            report["retention_error"] = str(error)
            failures = True
    text = (markdown_report(report, catalog) if options.format == "markdown"
            else json.dumps(report, ensure_ascii=False, indent=2, default=str) + "\n")
    if options.output:
        write_output(options.output, text)
        print(f"Report: {options.output}", file=sys.stderr)
    else:
        print(text, end="")
    if options.markdown_output:
        write_output(options.markdown_output, markdown_report(report, catalog))
        print(f"Markdown: {options.markdown_output}", file=sys.stderr)
    if catalog is not None:
        write_output(options.catalog_output, catalog_text)
        print(f"App catalog: {options.catalog_output}", file=sys.stderr)
    if retained_dir is not None:
        write_output(retained_dir / "reports/audit.json", json.dumps(report, ensure_ascii=False, indent=2) + "\n")
        if not failures and not catalog_error:
            try:
                removed = remove_completed_run(repo, run_dir, outputs)
                print(f"Intermediate run {'removed' if removed else 'kept (contains requested output)'}: {run_dir}", file=sys.stderr)
            except (AuditError, OSError) as error:
                print(f"Intermediate run kept: {error}", file=sys.stderr)
                return 1
    if failures or catalog_error:
        return 1
    partial_catalog = catalog is not None and any(t["status"] == "partial" for t in catalog["targets"])
    return 2 if partial_catalog or any(a["status"] == "partial" for a in report["artifacts"]) else 0


def markdown_report(report: dict, catalog: dict | None = None) -> str:
    def cell(value: object) -> str:
        return str(value).replace("|", "\\|").replace("\n", " ")

    lines = ["# Release artifact permissions", "", report["generated_at_utc"], "", report["scope"], ""]
    if report.get("catalog_error"):
        lines.extend(["Catalog was not exported: " + cell(report["catalog_error"]), ""])
    if report.get("source_reports"):
        lines.extend(["Reinspected existing artifacts; no new build is implied.", ""])
        for source in report["source_reports"]:
            lines.append(f"- Input JSON: {cell(source['path'])}; SHA-256: {source['sha256']}")
        lines.append("")
    if catalog is not None:
        lines.extend(["## App catalog coverage", "", "| Platform | Flavor | Evidence status | Declaration nodes |",
                      "|---|---|---|---|"])
        for target in catalog["targets"]:
            lines.append(f"| {target['platform']} | {target['flavor'] or '-'} | {target['status']} | "
                         f"{len(target['declarations'])} |")
        lines.extend(["", "Unverified/partial evidence is not proof of no permissions. Declaration nodes include "
                      "custom definitions and Apple capabilities, not just user-grantable permissions.", ""])
    for build in report["builds"]:
        lines.extend([f"- Build {build['platform']}/{build.get('flavor') or '-'}: **{build['status']}**"
                      + (f" — {build['error']}" if build.get("error") else "")])
    for artifact in report["artifacts"]:
        lines.extend(["", f"## {cell(artifact['artifact'])}", "",
                      f"Platform: {artifact.get('platform', 'unknown')}; flavor: {artifact.get('flavor') or '-'}",
                      f"Status: **{artifact['status']}**; provenance: {artifact['provenance']}", ""])
        if artifact.get("error"):
            lines.append(artifact["error"])
            continue
        manifests = artifact.get("modules", {"manifest": artifact})
        if artifact.get("platform") == "android":
            for module, manifest in manifests.items():
                lines.extend([f"### {module}", "",
                              f"Application: {cell(manifest.get('application_id', ''))}; "
                              f"version: {cell(manifest.get('versionName', ''))} "
                              f"({cell(manifest.get('versionCode', ''))})",
                              "", "| Kind | Permission | maxSdkVersion | Protection |",
                              "|---|---|---|---|"])
                for permission in manifest.get("permissions", []):
                    lines.append("| " + " | ".join(cell(permission.get(key, ""))
                                 for key in ("kind", "name", "maxSdkVersion", "protectionLevel")) + " |")
        elif artifact.get("info"):
            lines.extend(["| Declaration | Value |", "|---|---|"])
            for key, value in artifact["info"].items():
                lines.append(f"| {cell(key)} | {cell(value)} |")
            signed = artifact["signed_entitlements"]
            lines.extend(["", "Signed entitlements: " + signed["status"]])
            for key, value in signed.get("values", {}).items():
                lines.append(f"- {cell(key)}: {cell(value)}")
            lines.extend(["", "Privacy manifests:"])
            for path in artifact.get("privacy_manifests", {}):
                lines.append(f"- {cell(path)}")
        if artifact.get("limitation"):
            lines.append(artifact["limitation"])
        lines.append("\nArtifact fingerprint: " + artifact.get("sha256", artifact.get("sha256_tree", "unavailable")))
    lines.extend(["", "Unverified platforms: " + ", ".join(report["unverified_platforms"])])
    if report.get("unverified_android_flavors"):
        lines.append("Unverified Android flavors: " + ", ".join(report["unverified_android_flavors"]))
    return "\n".join(lines) + "\n"


def ensure_audit_dir(repo: Path) -> str:
    directory = repo / "build/privacy-audit"
    directory.mkdir(parents=True, exist_ok=True)
    return str(directory)


if __name__ == "__main__":
    raise SystemExit(main())
