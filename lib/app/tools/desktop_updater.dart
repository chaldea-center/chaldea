import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import 'package:path/path.dart' as p;
import 'package:window_manager/window_manager.dart';

import 'package:chaldea/app/tools/app_update.dart';
import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/models/db.dart';
import 'package:chaldea/packages/app_info.dart';
import 'package:chaldea/packages/logger.dart';
import 'package:chaldea/packages/platform/platform.dart';
import 'package:chaldea/utils/utils.dart';
import 'package:chaldea/widgets/widgets.dart';

/// One-click in-app upgrade for Windows/Linux green (zip/tar.gz) builds.
///
/// Flow: precheck -> streaming download -> sha256 verify -> extract to
/// staging -> generate an external updater script -> launch it detached ->
/// exit the app. The script (see ADR 0002) waits for this process to die,
/// moves program files (everything in exeFolder except `userdata/` and
/// `_backups/`) into a versioned backup, moves staged files in, launches
/// the new version, and self-cleans. Any mid-way failure rolls back.
class DesktopUpgrader {
  DesktopUpgrader._();

  static const int keepBackups = 3;
  static const backupsRootName = '_backups';
  static const workspaceName = '_upgrade';

  static bool get supported => !kIsWeb && (PlatformU.isWindows || PlatformU.isLinux);

  static String get exeFolder => p.dirname(PlatformU.resolvedExecutable);
  static String get backupsRoot => p.join(exeFolder, backupsRootName);
  static String get workspace => p.join(backupsRoot, workspaceName);
  static String get stagingDir => p.join(workspace, 'staging');

  /// Removes leftovers from a previous upgrade and prunes old backups.
  /// Called on every desktop launch — safe no-op when nothing is pending.
  static Future<void> cleanupArtifacts() async {
    if (!supported) return;
    try {
      await Future.delayed(const Duration(seconds: 5));
      final root = Directory(backupsRoot);
      if (!root.existsSync()) return;
      // keep the last updater log for troubleshooting before wiping workspace
      final log = File(p.join(workspace, 'update.log'));
      if (await log.exists()) {
        try {
          await log.copy(p.join(backupsRoot, 'last-update.log'));
        } catch (e) {
          logger.e('copy update log failed', e);
        }
      }
      final ws = Directory(workspace);
      if (ws.existsSync()) {
        await ws.delete(recursive: true);
      }
      final backups = root.listSync().whereType<Directory>().where((d) {
        final name = p.basename(d.path);
        return name.startsWith('chaldea-backup-') && !name.startsWith(workspaceName);
      }).toList();
      // sort by the timestamp embedded in the folder name (stable against
      // user edits to mtime); fall back to mtime when the name cannot be parsed
      backups.sort((a, b) {
        final ta = backupSortValue(p.basename(a.path), fallbackModified: a.statSync().modified);
        final tb = backupSortValue(p.basename(b.path), fallbackModified: b.statSync().modified);
        return tb.compareTo(ta);
      });
      for (final dir in backups.skip(keepBackups)) {
        try {
          await dir.delete(recursive: true);
        } catch (e) {
          logger.e('failed to prune backup ${dir.path}', e);
        }
      }
    } catch (e, s) {
      logger.e('cleanup desktop upgrade artifacts failed', e, s);
    }
  }

  /// Runs the whole upgrade; never throws — failures are reported via [state].
  static Future<void> upgrade(
    AppUpdateDetail detail, {
    required ValueNotifier<DesktopUpgradeState> state,
    CancelToken? cancelToken,
  }) async {
    try {
      state.value = const DesktopUpgradeState(phase: DesktopUpgradePhase.precheck);
      await _precheck(detail);

      final zipPath = p.join(workspace, detail.installer.name);
      state.value = const DesktopUpgradeState(phase: DesktopUpgradePhase.download);
      await _download(detail, zipPath, state, cancelToken);

      state.value = const DesktopUpgradeState(phase: DesktopUpgradePhase.verify);
      await _verifyChecksum(detail, zipPath);

      state.value = const DesktopUpgradeState(phase: DesktopUpgradePhase.extract);
      await _extractToStaging(detail, zipPath);

      state.value = const DesktopUpgradeState(phase: DesktopUpgradePhase.restart);
      await _launchUpdaterScript(detail);

      await _exitApp();
      // unreachable: _exitApp terminates the process
    } on DioException catch (e, s) {
      logger.e('desktop upgrade failed (network)', e, s);
      if (CancelToken.isCancel(e)) {
        state.value = const DesktopUpgradeState(phase: DesktopUpgradePhase.cancelled);
      } else {
        state.value = DesktopUpgradeState(
          phase: DesktopUpgradePhase.error,
          error: 'Download failed, please check the network and retry.\n下载失败，请检查网络后重试。',
        );
      }
    } catch (e, s) {
      logger.e('desktop upgrade failed', e, s);
      state.value = DesktopUpgradeState(
        phase: DesktopUpgradePhase.error,
        error: e is DesktopUpgradeException ? e.message : 'Upgrade failed: $e\n升级失败：$e',
      );
    }
  }

  // ---------------------------------------------------------------------------
  // phases
  // ---------------------------------------------------------------------------

  static Future<void> _precheck(AppUpdateDetail detail) async {
    // 1. write permission probes — the updater script inherits the very same
    //    privileges, so this probe faithfully predicts the script's ability.
    for (final dir in [exeFolder, backupsRoot]) {
      try {
        Directory(dir).createSync(recursive: true);
        final probe = File(p.join(dir, '.write_probe'));
        await probe.writeAsString('probe');
        await probe.delete();
      } catch (e) {
        throw DesktopUpgradeException(
          'No write permission to the app folder. Please move the app to a user-writable folder '
          '(NOT "Program Files"), or run the app as administrator.\n'
          '程序目录无写入权限。请将程序移动到用户可写目录（不要放在「Program Files」等系统目录），'
          '或以管理员身份运行应用。',
        );
      }
    }
    // 2. PowerShell availability (the replacement script host on Windows)
    if (PlatformU.isWindows) {
      try {
        final r = Process.runSync('powershell.exe', ['-NoProfile', '-Command', 'exit 0']);
        if (r.exitCode != 0) throw Exception('exit ${r.exitCode}');
      } catch (e) {
        throw DesktopUpgradeException(
          'PowerShell is not available. Cannot perform the upgrade automatically.\n'
          '系统 PowerShell 不可用，无法自动升级，请手动升级。',
        );
      }
    }
    // 3. free disk space: zip + extracted copy + safety margin.
    //    (the backup itself is a same-volume move and needs no extra space)
    final required = detail.installer.size * 3;
    final free = await _freeBytes(exeFolder);
    if (free != null && free < required) {
      throw DesktopUpgradeException(
        'Not enough free disk space (need ~${(required / 1024 / 1024).round()} MB).\n'
        '磁盘剩余空间不足（约需 ${(required / 1024 / 1024).round()} MB），请清理后重试。',
      );
    }
  }

  static Future<void> _download(
    AppUpdateDetail detail,
    String savePath,
    ValueNotifier<DesktopUpgradeState> state,
    CancelToken? cancelToken,
  ) async {
    await DioE().download(
      detail.installer.downloadUrl,
      savePath,
      cancelToken: cancelToken,
      onReceiveProgress: (count, total) {
        state.value = DesktopUpgradeState(
          phase: DesktopUpgradePhase.download,
          received: count,
          total: total > 0 ? total : null,
        );
      },
    );
  }

  static Future<void> _verifyChecksum(AppUpdateDetail detail, String zipPath) async {
    final digest = detail.installer.digest;
    if (!digest.startsWith('sha256:')) return;
    final expected = digest.substring('sha256:'.length).toLowerCase();
    final actual = (await sha256.bind(File(zipPath).openRead()).last).toString();
    if (actual != expected) {
      // a corrupt package must not be retried via cache
      try {
        await File(zipPath).delete();
      } catch (e) {
        logger.e('delete corrupt package failed', e);
      }
      throw DesktopUpgradeException(
        'Package checksum mismatch, the download is corrupted. Please retry.\n'
        '安装包校验失败（文件损坏），请重试。',
      );
    }
  }

  static Future<void> _extractToStaging(AppUpdateDetail detail, String zipPath) async {
    final staging = Directory(stagingDir);
    if (staging.existsSync()) {
      await staging.delete(recursive: true);
    }
    staging.createSync(recursive: true);
    ProcessResult result;
    if (PlatformU.isWindows) {
      result = await Process.run('powershell.exe', [
        '-NoProfile',
        '-ExecutionPolicy',
        'Bypass',
        '-Command',
        'Expand-Archive -LiteralPath ${_psQuote(zipPath)} -DestinationPath ${_psQuote(stagingDir)} -Force',
      ]);
    } else {
      // tar preserves the executable bits recorded in the archive
      result = await Process.run('tar', ['-xzf', zipPath, '-C', stagingDir]);
    }
    if (result.exitCode != 0) {
      throw DesktopUpgradeException(
        'Failed to extract the package: ${result.stderr}\n'
        '解压安装包失败：${result.stderr}',
      );
    }
    // The CI archives bundle contents at the root, but tolerate a single
    // top-level wrapper directory for robustness.
    var root = stagingDir;
    final entries = staging.listSync();
    if (entries.length == 1 && entries.single is Directory) {
      final inner = entries.single as Directory;
      if (!File(p.join(inner.path, _exeName)).existsSync()) {
        root = inner.path;
      }
    }
    if (!File(p.join(root, _exeName)).existsSync()) {
      throw DesktopUpgradeException(
        'Invalid package layout: "$_exeName" not found.\n'
        '升级包结构异常：未找到主程序 $_exeName。',
      );
    }
  }

  static Future<void> _launchUpdaterScript(AppUpdateDetail detail) async {
    final backupDir = _uniqueBackupDir();
    final scriptPath = p.join(workspace, PlatformU.isWindows ? 'updater.ps1' : 'updater.sh');
    final logFile = p.join(workspace, 'update.log');
    final newExe = p.join(exeFolder, _exeName);
    final script = PlatformU.isWindows
        ? _buildPowerShellScript(
            exeFolder: exeFolder,
            backupDir: backupDir,
            stagingDir: stagingDir,
            newExe: newExe,
            exeName: _exeName,
            logFile: logFile,
            parentPid: pid,
          )
        : _buildShellScript(
            exeFolder: exeFolder,
            backupDir: backupDir,
            stagingDir: stagingDir,
            newExe: newExe,
            exeName: _exeName,
            logFile: logFile,
            parentPid: pid,
          );
    final file = File(scriptPath);
    if (PlatformU.isWindows) {
      // UTF-8 BOM so Windows PowerShell 5.1 reads non-ASCII paths correctly
      await file.writeAsString('\uFEFF$script');
    } else {
      await file.writeAsString(script);
    }
    logger.i('desktop updater script written: $scriptPath');
    if (PlatformU.isWindows) {
      await Process.start('powershell.exe', [
        '-NoProfile',
        '-ExecutionPolicy',
        'Bypass',
        '-File',
        scriptPath,
      ], mode: ProcessStartMode.detached);
    } else {
      await Process.start('/bin/sh', [scriptPath], mode: ProcessStartMode.detached);
    }
    // give the detached process a moment to spawn before we exit
    await Future.delayed(const Duration(seconds: 1));
  }

  static Future<void> _exitApp() async {
    try {
      await db.saveAll();
    } catch (e, s) {
      logger.e('save data before upgrade exit failed', e, s);
    }
    try {
      await windowManager.setPreventClose(false);
      await windowManager.destroy();
    } catch (e, s) {
      logger.e('destroy window before upgrade exit failed', e, s);
    }
    exit(0);
  }

  // ---------------------------------------------------------------------------
  // helpers
  // ---------------------------------------------------------------------------

  static String get _exeName => p.basename(PlatformU.resolvedExecutable);

  static String _uniqueBackupDir() {
    // the embedded timestamp makes the name self-describing and sortable;
    // a rare same-second collision falls back to a -N suffix
    final base = 'chaldea-backup-${AppInfo.versionString}-${_timeStamp()}';
    var dir = p.join(backupsRoot, base);
    var i = 1;
    while (Directory(dir).existsSync()) {
      dir = p.join(backupsRoot, '$base-$i');
      i++;
    }
    return dir;
  }

  static String _timeStamp() {
    final now = DateTime.now();
    String two(int v) => v.toString().padLeft(2, '0');
    return '${now.year}${two(now.month)}${two(now.day)}${two(now.hour)}${two(now.minute)}${two(now.second)}';
  }

  /// Numeric sort key for a backup folder, parsed from the `-yyyymmddhhmmss`
  /// suffix of its name. Falls back to the directory mtime when the name
  /// cannot be parsed (e.g. manual dirs). Exposed for testing.
  @visibleForTesting
  static int backupSortValue(String name, {DateTime? fallbackModified}) {
    final m = _backupTsRe.firstMatch(name);
    if (m != null) {
      final v = int.tryParse(m.group(1)!);
      if (v != null) return v;
    }
    return fallbackModified?.millisecondsSinceEpoch ?? 0;
  }

  static final RegExp _backupTsRe = RegExp(r'-(\d{14})(?:-\d+)?$');

  static Future<int?> _freeBytes(String folder) async {
    try {
      if (PlatformU.isWindows) {
        final drive = p.rootPrefix(folder);
        final r = await Process.run('fsutil', ['volume', 'diskfree', drive]);
        if (r.exitCode != 0) return null;
        for (final line in r.stdout.toString().split('\n')) {
          if (line.toLowerCase().contains('free bytes')) {
            final m = RegExp(r'([\d,]+)\s*$').firstMatch(line.trim());
            if (m != null) return int.tryParse(m.group(1)!.replaceAll(',', ''));
          }
        }
        return null;
      } else {
        final r = await Process.run('df', ['-k', folder]);
        if (r.exitCode != 0) return null;
        final lines = r.stdout.toString().split('\n');
        if (lines.length < 2) return null;
        final cols = lines[1].trim().split(RegExp(r'\s+'));
        if (cols.length < 4) return null;
        final kb = int.tryParse(cols[3]);
        return kb == null ? null : kb * 1024;
      }
    } catch (e) {
      logger.e('check free disk space failed', e);
      return null;
    }
  }

  static String _psQuote(String s) => "'${s.replaceAll("'", "''")}'";

  static String _shQuote(String s) => "'${s.replaceAll("'", r"'\''")}'";

  /// Test-only: generates both platform scripts so tests can syntax-check
  /// the produced content (paths quoted, heredocs intact, etc.).
  @visibleForTesting
  static (String, String) debugGenerateScripts({
    required String exeFolder,
    required String backupDir,
    required String stagingDir,
    required String newExe,
    required String exeName,
    required String logFile,
    required int parentPid,
  }) {
    return (
      _buildPowerShellScript(
        exeFolder: exeFolder,
        backupDir: backupDir,
        stagingDir: stagingDir,
        newExe: newExe,
        exeName: exeName,
        logFile: logFile,
        parentPid: parentPid,
      ),
      _buildShellScript(
        exeFolder: exeFolder,
        backupDir: backupDir,
        stagingDir: stagingDir,
        newExe: newExe,
        exeName: exeName,
        logFile: logFile,
        parentPid: parentPid,
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // updater scripts
  // ---------------------------------------------------------------------------
  //
  // Scripts stay ASCII-only in their own text (log messages in English);
  // embedded paths may be non-ASCII, hence the BOM/UTF-8 handling above.

  static String _buildPowerShellScript({
    required String exeFolder,
    required String backupDir,
    required String stagingDir,
    required String newExe,
    required String exeName,
    required String logFile,
    required int parentPid,
  }) {
    final restore = _buildPowerShellRestore(exeFolder: exeFolder, exeName: exeName);
    return '''
\$ErrorActionPreference = 'Stop'
\$ExeFolder = ${_psQuote(exeFolder)}
\$BackupDir = ${_psQuote(backupDir)}
\$StagingDir = ${_psQuote(stagingDir)}
\$NewExe = ${_psQuote(newExe)}
\$ExeName = ${_psQuote(exeName)}
\$LogFile = ${_psQuote(logFile)}
\$ParentPid = $parentPid
\$Phase = 'backup'

function Log([string]\$Message) {
  try { Add-Content -LiteralPath \$LogFile -Value ("{0} {1}" -f (Get-Date -Format 'yyyy-MM-dd HH:mm:ss'), \$Message) } catch { }
}

function Move-WithRetry([string]\$Path, [string]\$Destination) {
  for (\$Attempt = 1; \$Attempt -le 3; \$Attempt++) {
    try {
      Move-Item -LiteralPath \$Path -Destination \$Destination -Force -ErrorAction Stop
      return
    } catch {
      Start-Sleep -Milliseconds 500
    }
  }
  throw "move failed after 3 attempts: \$Path"
}

function Rollback {
  Log "rollback (phase=\$Phase)"
  if (\$Phase -eq 'install') {
    # the new files were (partially) moved in: drop them first
    Get-ChildItem -LiteralPath \$ExeFolder -Exclude @('userdata', '_backups') -ErrorAction SilentlyContinue |
      Remove-Item -Recurse -Force -ErrorAction SilentlyContinue
  }
  if (Test-Path -LiteralPath \$BackupDir) {
    Get-ChildItem -LiteralPath \$BackupDir -Exclude @('restore.ps1') | ForEach-Object {
      try { Move-Item -LiteralPath \$_.FullName -Destination \$ExeFolder -Force -ErrorAction Stop }
      catch { Log ("rollback move failed: " + \$_.Name) }
    }
  }
  \$OldExe = Join-Path \$ExeFolder \$ExeName
  if (Test-Path -LiteralPath \$OldExe) {
    Log "restarting previous version"
    Start-Process -FilePath \$OldExe -WorkingDirectory \$ExeFolder
  }
}

try {
  Log 'updater started'
  \$ParentAlive = \$true
  for (\$Waited = 0; \$Waited -lt 60; \$Waited++) {
    if (-not (Get-Process -Id \$ParentPid -ErrorAction SilentlyContinue)) { \$ParentAlive = \$false; break }
    Start-Sleep -Seconds 1
  }
  if (\$ParentAlive) { throw "app process (\$ParentPid) did not exit within 60s" }
  Log 'app exited'

  New-Item -ItemType Directory -Path \$BackupDir -Force | Out-Null
  Get-ChildItem -LiteralPath \$ExeFolder -Exclude @('userdata', '_backups') | ForEach-Object {
    Log ("backup: " + \$_.Name)
    Move-WithRetry \$_.FullName \$BackupDir
  }
  Log 'backup finished'

  Set-Content -LiteralPath (Join-Path \$BackupDir 'restore.ps1') -Value @'
$restore
'@ -Encoding UTF8
  Log 'restore script written'

  \$Phase = 'install'
  Get-ChildItem -LiteralPath \$StagingDir | ForEach-Object {
    Log ("install: " + \$_.Name)
    Move-WithRetry \$_.FullName \$ExeFolder
  }
  Log 'install finished'

  Start-Process -FilePath \$NewExe -WorkingDirectory \$ExeFolder
  Log 'new version started'

  Remove-Item -LiteralPath \$StagingDir -Recurse -Force -ErrorAction SilentlyContinue
  Log 'updater finished'
  Remove-Item -LiteralPath \$MyInvocation.MyCommand.Path -Force -ErrorAction SilentlyContinue
  exit 0
} catch {
  Log ("FAILED: " + \$_.Exception.Message)
  Rollback
  exit 1
}
''';
  }

  static String _buildPowerShellRestore({required String exeFolder, required String exeName}) {
    return '''
\$ErrorActionPreference = 'Stop'
\$ExeFolder = ${_psQuote(exeFolder)}
\$ExeName = ${_psQuote(exeName)}
\$BackupDir = Split-Path -Parent \$MyInvocation.MyCommand.Path
Write-Host ("Restoring backup to " + \$ExeFolder)
Get-ChildItem -LiteralPath \$ExeFolder -Exclude @('userdata', '_backups') -ErrorAction SilentlyContinue |
  Remove-Item -Recurse -Force -ErrorAction SilentlyContinue
Get-ChildItem -LiteralPath \$BackupDir -Exclude @('restore.ps1') | ForEach-Object {
  Move-Item -LiteralPath \$_.FullName -Destination \$ExeFolder -Force
}
\$Exe = Join-Path \$ExeFolder \$ExeName
Write-Host 'Restore finished.'
Start-Process -FilePath \$Exe -WorkingDirectory \$ExeFolder
''';
  }

  static String _buildShellScript({
    required String exeFolder,
    required String backupDir,
    required String stagingDir,
    required String newExe,
    required String exeName,
    required String logFile,
    required int parentPid,
  }) {
    final restore = _buildShellRestore(exeFolder: exeFolder, exeName: exeName);
    return '''
#!/bin/sh
# generated by chaldea app updater
EXE_FOLDER=${_shQuote(exeFolder)}
BACKUP_DIR=${_shQuote(backupDir)}
STAGING_DIR=${_shQuote(stagingDir)}
NEW_EXE=${_shQuote(newExe)}
EXE_NAME=${_shQuote(exeName)}
LOG_FILE=${_shQuote(logFile)}
PARENT_PID=$parentPid
PHASE=backup

log() {
  echo "\$(date '+%Y-%m-%d %H:%M:%S') \$1" >> "\$LOG_FILE" 2>/dev/null
}

move_retry() {
  _i=1
  while [ "\$_i" -le 3 ]; do
    if mv "\$1" "\$2" >> "\$LOG_FILE" 2>&1; then
      return 0
    fi
    sleep 1
    _i=\$((_i + 1))
  done
  return 1
}

rollback() {
  log "rollback (phase=\$PHASE)"
  if [ "\$PHASE" = "install" ]; then
    # the new files were (partially) moved in: drop them first
    for _f in "\$EXE_FOLDER"/*; do
      [ -e "\$_f" ] || continue
      _b=\$(basename "\$_f")
      [ "\$_b" = "userdata" ] && continue
      [ "\$_b" = "_backups" ] && continue
      rm -rf "\$_f" >> "\$LOG_FILE" 2>&1
    done
  fi
  if [ -d "\$BACKUP_DIR" ]; then
    for _f in "\$BACKUP_DIR"/*; do
      [ -e "\$_f" ] || continue
      _b=\$(basename "\$_f")
      [ "\$_b" = "restore.sh" ] && continue
      if ! mv "\$_f" "\$EXE_FOLDER/" >> "\$LOG_FILE" 2>&1; then
        log "rollback move failed: \$_f"
      fi
    done
  fi
  if [ -f "\$EXE_FOLDER/\$EXE_NAME" ]; then
    chmod +x "\$EXE_FOLDER/\$EXE_NAME"
    log "restarting previous version"
    nohup "\$EXE_FOLDER/\$EXE_NAME" >/dev/null 2>&1 &
  fi
}

log 'updater started'
_waited=0
while kill -0 "\$PARENT_PID" 2>/dev/null; do
  _waited=\$((_waited + 1))
  if [ "\$_waited" -ge 60 ]; then
    log "app process \$PARENT_PID did not exit within 60s"
    exit 1
  fi
  sleep 1
done
log 'app exited'

if ! mkdir -p "\$BACKUP_DIR" >> "\$LOG_FILE" 2>&1; then
  log "failed to create backup dir"
  exit 1
fi

for _f in "\$EXE_FOLDER"/*; do
  [ -e "\$_f" ] || continue
  _b=\$(basename "\$_f")
  [ "\$_b" = "userdata" ] && continue
  [ "\$_b" = "_backups" ] && continue
  log "backup: \$_b"
  if ! move_retry "\$_f" "\$BACKUP_DIR/"; then
    log "backup failed: \$_f"
    rollback
    exit 1
  fi
done
log 'backup finished'

cat > "\$BACKUP_DIR/restore.sh" <<'CHALDEA_RESTORE_EOF'
$restore
CHALDEA_RESTORE_EOF
chmod +x "\$BACKUP_DIR/restore.sh"
log 'restore script written'

PHASE=install
for _f in "\$STAGING_DIR"/*; do
  [ -e "\$_f" ] || continue
  log "install: \$(basename "\$_f")"
  if ! move_retry "\$_f" "\$EXE_FOLDER/"; then
    log "install failed: \$_f"
    rollback
    exit 1
  fi
done
chmod +x "\$NEW_EXE" 2>/dev/null
log 'install finished'

nohup "\$NEW_EXE" >/dev/null 2>&1 &
log 'new version started'

rm -rf "\$STAGING_DIR" >> "\$LOG_FILE" 2>&1
log 'updater finished'
rm -f "\$0" >> "\$LOG_FILE" 2>&1
exit 0
''';
  }

  static String _buildShellRestore({required String exeFolder, required String exeName}) {
    return '''
#!/bin/sh
EXE_FOLDER=${_shQuote(exeFolder)}
EXE_NAME=${_shQuote(exeName)}
BACKUP_DIR=\$(dirname "\$0")
echo "Restoring backup to \$EXE_FOLDER ..."
for _f in "\$EXE_FOLDER"/*; do
  [ -e "\$_f" ] || continue
  _b=\$(basename "\$_f")
  [ "\$_b" = "userdata" ] && continue
  [ "\$_b" = "_backups" ] && continue
  rm -rf "\$_f"
done
for _f in "\$BACKUP_DIR"/*; do
  [ -e "\$_f" ] || continue
  _b=\$(basename "\$_f")
  [ "\$_b" = "restore.sh" ] && continue
  mv "\$_f" "\$EXE_FOLDER/"
done
chmod +x "\$EXE_FOLDER/\$EXE_NAME"
echo 'Restore finished.'
nohup "\$EXE_FOLDER/\$EXE_NAME" >/dev/null 2>&1 &
''';
  }
}

class DesktopUpgradeException implements Exception {
  final String message;
  const DesktopUpgradeException(this.message);

  @override
  String toString() => message;
}

enum DesktopUpgradePhase { precheck, download, verify, extract, restart, cancelled, error }

class DesktopUpgradeState {
  final DesktopUpgradePhase phase;
  final int? received;
  final int? total;
  final String? error;

  const DesktopUpgradeState({required this.phase, this.received, this.total, this.error});
}

/// Stage-by-stage upgrade progress dialog (see ADR 0002 / decision #8).
Future<void> showDesktopUpgradeDialog(BuildContext context, AppUpdateDetail detail) {
  final state = ValueNotifier(const DesktopUpgradeState(phase: DesktopUpgradePhase.precheck));
  final cancelToken = CancelToken();
  Future<void>.microtask(() => DesktopUpgrader.upgrade(detail, state: state, cancelToken: cancelToken));
  return showDialog(
    context: context,
    useRootNavigator: false,
    barrierDismissible: false,
    builder: (context) {
      return PopScope(
        canPop: false,
        child: AlertDialog(
          title: Text('Upgrade v${detail.release.version?.versionString}'),
          content: ValueListenableBuilder<DesktopUpgradeState>(
            valueListenable: state,
            builder: (context, value, _) => _buildUpgradeDialogContent(context, value),
          ),
          actions: [
            ValueListenableBuilder<DesktopUpgradeState>(
              valueListenable: state,
              builder: (context, value, _) {
                if (value.phase == DesktopUpgradePhase.download) {
                  return TextButton(
                    onPressed: () {
                      cancelToken.cancel();
                    },
                    child: Text(S.current.cancel),
                  );
                }
                if (value.phase == DesktopUpgradePhase.cancelled || value.phase == DesktopUpgradePhase.error) {
                  return TextButton(onPressed: () => Navigator.pop(context), child: Text(S.current.confirm));
                }
                return const SizedBox.shrink();
              },
            ),
          ],
        ),
      );
    },
  );
}

Widget _buildUpgradeDialogContent(BuildContext context, DesktopUpgradeState state) {
  Widget progress = const SizedBox(height: 6, child: LinearProgressIndicator(minHeight: 6));
  String text;
  switch (state.phase) {
    case DesktopUpgradePhase.precheck:
      text = 'Checking environment\n正在检查升级环境…';
      break;
    case DesktopUpgradePhase.download:
      text = 'Downloading package\n正在下载更新包…';
      if (state.total != null) {
        progress = SizedBox(
          height: 6,
          child: LinearProgressIndicator(
            minHeight: 6,
            value: state.total == null || state.total == 0 ? null : state.received! / state.total!,
          ),
        );
        final receivedMB = (state.received ?? 0) / 1024 / 1024;
        final totalMB = state.total! / 1024 / 1024;
        text += '\n${receivedMB.toStringAsFixed(1)} / ${totalMB.toStringAsFixed(1)} MB';
      }
      break;
    case DesktopUpgradePhase.verify:
      text = 'Verifying integrity\n正在校验文件完整性…';
      break;
    case DesktopUpgradePhase.extract:
      text = 'Extracting package\n正在解压安装包…';
      break;
    case DesktopUpgradePhase.restart:
      text = 'The app will exit and restart to finish the upgrade.\n应用即将退出并重启以完成升级，请稍候…';
      progress = const SizedBox.shrink();
      break;
    case DesktopUpgradePhase.cancelled:
      text = 'Upgrade cancelled. The current version keeps working.\n已取消升级，当前版本不受影响。';
      progress = const SizedBox.shrink();
      break;
    case DesktopUpgradePhase.error:
      text = '${state.error ?? 'Upgrade failed\n升级失败'}\n\nThe current version keeps working.\n当前版本不受影响，可继续使用。';
      progress = const SizedBox.shrink();
      break;
  }
  return Column(
    mainAxisSize: MainAxisSize.min,
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [Text(text), if (progress != const SizedBox.shrink()) const SizedBox(height: 16), progress],
  );
}
