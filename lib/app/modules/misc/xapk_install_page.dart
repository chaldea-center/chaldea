import 'dart:async';
import 'dart:io';

import 'package:flutter/services.dart';

import 'package:dio/dio.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/packages/language.dart';
import 'package:chaldea/packages/method_channel/method_channel_chaldea.dart';
import 'package:chaldea/packages/packages.dart';
import 'package:chaldea/utils/utils.dart';
import 'package:chaldea/widgets/widgets.dart';

/// XAPK direct-install page (ADR 0004, docs/xapk-install.md).
///
/// Accepts either a local [filePath] (e.g. picked via the file picker
/// or passed from another page) or a remote [url] (downloaded first).
/// URL mode never auto-downloads: the URL tile offers a manual
/// download/redownload button. Once a local file is available
/// (downloaded or picked) the file tile shows its path and hosts the
/// install button. Plain .apk files fall back to the existing
/// ACTION_VIEW install path. The install itself runs natively; states
/// stream through [MethodChannelChaldea.xapkEvents].
class XapkInstallPage extends StatefulWidget {
  final String? filePath;
  final String? url;

  const XapkInstallPage({super.key, this.filePath, this.url});

  @override
  State<XapkInstallPage> createState() => _XapkInstallPageState();
}

enum _FlowPhase { idle, downloading, parsing, parsed, installing, confirming, success, failed }

/// Centralized mutable view-model for the XAPK install flow.
///
/// Owns every piece of flow/file state (phase, source file, download,
/// parse result, install event) plus the derived flags the UI relies on
/// ([installEnabled], [isApk]). The page writes its fields inside
/// `setState`; read-only concerns stay as getters here so the UI never
/// recomputes them in multiple places.
class XapkFlowModel {
  _FlowPhase phase = _FlowPhase.idle;

  /// URL mode: non-null while the page source is a remote url.
  String? sourceUrl;

  /// Local file ready for parse/install (file tile).
  String? sourcePath;
  String? fileName;

  // download state (URL tile only)
  String? savePath;
  CancelToken? cancelToken;
  Future<void>? downloadFuture;
  int? downloadReceived;
  int? downloadTotal;
  String? downloadError;

  /// The downloaded file exists at [savePath] (redownload offered).
  bool urlFileReady = false;

  // parse result / errors
  XapkManifestInfo? manifest;
  String? errorMessage;

  // install state
  XapkInstallEvent? installEvent;

  /// True when the selected file is a plain .apk (no manifest.json).
  bool get isApk => sourcePath?.toLowerCase().endsWith('.apk') ?? false;

  /// Phases in which the file, even if present, cannot be installed.
  ///
  /// Decided by exclusion (default = installable) rather than inclusion so
  /// that a newly added phase naturally stays installable. ``downloading`` /
  /// ``parsing`` / ``idle`` coincidentally clear [sourcePath], but listing
  /// them here keeps the guard self-contained regardless of that coupling.
  static const _nonInstallablePhases = {
    _FlowPhase.idle,
    _FlowPhase.downloading,
    _FlowPhase.parsing,
    _FlowPhase.installing,
    _FlowPhase.confirming,
  };

  /// Whether the Install button is enabled. The button is always rendered
  /// while a file is selected — a previous failure or success must never
  /// hide it, only disable it. A plain .apk is installable as soon as it is
  /// present (no manifest.json); a XAPK only after a successful parse, so a
  /// parse failure keeps the button visible but disabled.
  bool get installEnabled {
    if (_nonInstallablePhases.contains(phase)) return false;
    if (sourcePath == null) return false;
    return manifest != null || isApk;
  }
}

class _XapkInstallPageState extends State<XapkInstallPage> {
  /// Mutable flow/file state (+ derived UI flags). See [XapkFlowModel].
  final XapkFlowModel _flow = XapkFlowModel();

  bool canInstall = false;
  bool granted = true;
  String manufacturer = '';

  StreamSubscription<XapkInstallEvent>? _subscription;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    final capability = await MethodChannelChaldea.getInstallCapability();
    if (!mounted) return;
    setState(() {
      canInstall = capability?.declared ?? false;
      granted = capability?.granted ?? false;
      manufacturer = (capability?.manufacturer ?? '').toLowerCase();
    });
    _subscription = MethodChannelChaldea.xapkEvents.listen(_onInstallEvent);
    final path = widget.filePath;
    final url = widget.url;
    if (path != null) {
      await _startWithFile(path);
    } else if (url != null) {
      await _enterUrlMode(url);
    }
  }

  @override
  void dispose() {
    _subscription?.cancel();
    _flow.cancelToken?.cancel();
    super.dispose();
  }

  // ---- flow entry points ---------------------------------------------------

  Future<void> _pickFile() async {
    if (_flow.phase == _FlowPhase.downloading) {
      final cancelAndPick = await _showCancelDownloadDialog(context);
      if (cancelAndPick != true) return;
      _flow.cancelToken?.cancel();
      await _flow.downloadFuture;
      if (!mounted) return;
    } else if (_flow.phase == _FlowPhase.parsing ||
        _flow.phase == _FlowPhase.installing ||
        _flow.phase == _FlowPhase.confirming) {
      return;
    }
    final file = await FilePickerU.pickFile(dialogTitle: S.current.xapk_select_file, type: .custom);
    if (file == null || file.path == null) return;
    await _startWithFile(file.path!);
  }

  /// Enter URL mode: no auto-download, but an already-downloaded file
  /// (from a previous session) is picked up and parsed immediately.
  Future<void> _enterUrlMode(String url) async {
    final name = Uri.tryParse(url)?.pathSegments.lastOrNull;
    final saveName = (name != null && name.contains('.')) ? name : 'download.xapk';
    final dir = await getExternalStorageDirectory();
    if (dir == null || !mounted) return;
    final path = p.join(dir.path, saveName);
    final exists = File(path).existsSync();
    setState(() {
      _flow.sourceUrl = url;
      _flow.savePath = path;
      _flow.urlFileReady = exists;
      if (exists) {
        _flow.sourcePath = path;
        _flow.fileName = saveName;
      }
    });
    if (exists) {
      await _parse(path);
    }
  }

  Future<void> _startWithFile(String path) async {
    setState(() {
      // a picked local file replaces URL mode entirely
      _flow.sourceUrl = null;
      _flow.savePath = null;
      _flow.urlFileReady = false;
      _flow.downloadError = null;
      _flow.sourcePath = path;
      _flow.fileName = p.basename(path);
      _flow.manifest = null;
      _flow.errorMessage = null;
      _flow.installEvent = null;
    });
    if (path.toLowerCase().endsWith('.apk')) {
      // plain APK: parse summary unavailable (no manifest.json) — offer the
      // existing ACTION_VIEW path directly
      setState(() => _flow.phase = _FlowPhase.parsed);
      return;
    }
    await _parse(path);
  }

  Future<void> _startDownload() async {
    final url = _flow.sourceUrl;
    final path = _flow.savePath;
    if (url == null || path == null) return;
    setState(() {
      _flow.phase = _FlowPhase.downloading;
      _flow.downloadReceived = 0;
      _flow.downloadTotal = null;
      _flow.downloadError = null;
      // the target file is being replaced
      _flow.sourcePath = null;
      _flow.fileName = null;
      _flow.urlFileReady = false;
      _flow.manifest = null;
      _flow.errorMessage = null;
      _flow.installEvent = null;
      _flow.cancelToken = CancelToken();
    });
    final future = _download(url, path);
    _flow.downloadFuture = future;
    await future;
  }

  Future<void> _download(String url, String path) async {
    try {
      await DioE().download(
        url,
        path,
        cancelToken: _flow.cancelToken,
        onReceiveProgress: (count, total) {
          if (mounted) {
            setState(() {
              _flow.downloadReceived = count;
              _flow.downloadTotal = total > 0 ? total : null;
            });
          }
        },
      );
      if (!mounted) return;
      setState(() {
        _flow.urlFileReady = true;
        _flow.sourcePath = path;
        _flow.fileName = p.basename(path);
      });
      if (path.toLowerCase().endsWith('.apk')) {
        // plain APK has no manifest.json — go straight to the install state
        setState(() => _flow.phase = _FlowPhase.parsed);
      } else {
        await _parse(path);
      }
    } on DioException catch (e) {
      if (!mounted) return;
      if (CancelToken.isCancel(e)) {
        _deleteQuietly(path);
        setState(() {
          _flow.phase = _FlowPhase.idle;
          _flow.urlFileReady = false;
        });
      } else {
        logger.e('xapk download failed', e);
        _deleteQuietly(path);
        setState(() {
          _flow.phase = _FlowPhase.idle;
          _flow.urlFileReady = false;
          _flow.downloadError = escapeDioException(e);
        });
      }
    } catch (e) {
      if (!mounted) return;
      logger.e('xapk download failed', e);
      _deleteQuietly(path);
      setState(() {
        _flow.phase = _FlowPhase.idle;
        _flow.urlFileReady = false;
        _flow.downloadError = e.toString();
      });
    }
  }

  Future<void> _parse(String path) async {
    setState(() => _flow.phase = _FlowPhase.parsing);
    try {
      final result = await MethodChannelChaldea.parseXapk(path);
      if (!mounted) return;
      setState(() {
        _flow.manifest = result;
        _flow.phase = _FlowPhase.parsed;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _flow.phase = _FlowPhase.failed;
        _flow.errorMessage = _errorMessage(e);
      });
    }
  }

  Future<void> _install() async {
    final path = _flow.sourcePath;
    if (path == null) return;
    if (!granted) {
      final open = await _showGrantDialog(context);
      if (open == true) {
        await MethodChannelChaldea.openInstallPermissionSettings();
      }
      // permission-first: the user re-taps Install after returning
      return;
    }
    if (path.toLowerCase().endsWith('.apk')) {
      final ok = await MethodChannelChaldea.installApk(path);
      if (!ok) {
        setState(() {
          _flow.phase = _FlowPhase.failed;
          _flow.errorMessage = S.current.install_failed_to_start;
        });
      }
      return;
    }
    final ok = await MethodChannelChaldea.installXapk(path);
    if (!ok) {
      setState(() {
        _flow.phase = _FlowPhase.failed;
        _flow.errorMessage = S.current.install_failed_to_start;
      });
    }
  }

  // ---- install events -------------------------------------------------------

  void _onInstallEvent(XapkInstallEvent event) {
    if (!mounted) return;
    switch (event.phase) {
      case XapkInstallPhase.parsing:
        setState(() => _flow.phase = _FlowPhase.parsing);
      case XapkInstallPhase.installing:
        setState(() {
          _flow.phase = _FlowPhase.installing;
          _flow.installEvent = event;
        });
      case XapkInstallPhase.confirming:
        setState(() {
          _flow.phase = _FlowPhase.confirming;
          _flow.installEvent = event;
        });
      case XapkInstallPhase.success:
        setState(() {
          _flow.phase = _FlowPhase.success;
          _flow.installEvent = event;
        });
      case XapkInstallPhase.failed:
        setState(() {
          _flow.phase = _FlowPhase.failed;
          _flow.installEvent = event;
          _flow.errorMessage = _eventErrorMessage(event);
        });
    }
  }

  // ---- error mapping ----------------------------------------------------------

  String _errorMessage(Object e) {
    final code = e is PlatformException ? e.code : null;
    final rawMessage = e is PlatformException ? e.message : e.toString();
    switch (code) {
      case 'FILE_NOT_FOUND':
        return S.current.xapk_error_file_not_found;
      case 'NOT_ZIP':
        return S.current.xapk_error_not_zip;
      case 'NO_MANIFEST':
        return S.current.xapk_error_no_manifest;
      case 'NO_BASE_SPLIT':
        return S.current.xapk_error_no_base_split;
      case 'MISSING_SPLIT':
        return S.current.xapk_error_missing_split;
      case 'SIZE_MISMATCH':
        return S.current.xapk_error_size_mismatch;
      case 'CRC_FAILED':
        return S.current.xapk_error_crc_failed;
      case 'OBB_UNSUPPORTED':
        return S.current.xapk_error_obb_unsupported;
      default:
        return rawMessage ?? e.toString();
    }
  }

  String _eventErrorMessage(XapkInstallEvent event) {
    switch (event.error) {
      case 'OBB_UNSUPPORTED':
        return S.current.xapk_error_obb_unsupported;
      case 'CRC_FAILED':
        return S.current.xapk_error_crc_failed;
      case 'CONFIRM_ACTIVITY_MISSING':
        return S.current.xapk_error_confirm_activity_missing;
      case 'TIMEOUT':
        return S.current.xapk_error_timeout;
      default:
        return event.message?.isNotEmpty == true ? event.message! : event.error ?? S.current.xapk_install_failed;
    }
  }

  // ---- UI ---------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(S.current.xapk_install_title)),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 8),
        children: [
          _buildGrantCard(),
          _buildPickerCard(),
          if (_flow.sourceUrl != null) _buildUrlCard(),
          if (_flow.sourcePath != null) _buildFileCard(),
          if (_flow.phase != _FlowPhase.idle && _flow.phase != _FlowPhase.downloading) _buildProgressCard(),
          if (_flow.manifest != null) _buildManifestCard(),
          _buildVendorCard(),
          _buildFooterHint(),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildGrantCard() {
    if (granted) return const SizedBox.shrink();
    // If the build never declared REQUEST_INSTALL_PACKAGES (e.g. Google Play)
    // there is no permission to grant — showing "open settings" would lead to
    // a dead link, so we only guide the user to third-party tools.
    final canGrant = canInstall;
    return Card(
      margin: const EdgeInsets.all(8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.warning_amber_rounded, color: Theme.of(context).colorScheme.error),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(canGrant ? S.current.install_permission_hint : S.current.xapk_no_install_permission_hint),
                ),
              ],
            ),
            if (canGrant) ...[
              const SizedBox(height: 8),
              FilledButton.tonal(
                onPressed: () => MethodChannelChaldea.openInstallPermissionSettings(),
                child: Text(S.current.open_settings),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildPickerCard() {
    final pickingEnabled =
        _flow.phase == _FlowPhase.idle ||
        _flow.phase == _FlowPhase.parsed ||
        _flow.phase == _FlowPhase.failed ||
        _flow.phase == _FlowPhase.success;
    return TileGroup(
      header: S.current.xapk_install_title,
      children: [
        ListTile(
          leading: const Icon(Icons.folder_open),
          title: Text(S.current.xapk_select_file),
          onTap: pickingEnabled ? _pickFile : null,
        ),
      ],
    );
  }

  // ---- URL tile (download state only) --------------------------------------

  bool get _downloadEnabled =>
      _flow.phase != _FlowPhase.downloading &&
      _flow.phase != _FlowPhase.parsing &&
      _flow.phase != _FlowPhase.installing &&
      _flow.phase != _FlowPhase.confirming;

  Widget _buildUrlCard() {
    final downloading = _flow.phase == _FlowPhase.downloading;
    Widget? subtitle;
    if (downloading) {
      subtitle = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 4),
          SizedBox(
            height: 6,
            child: LinearProgressIndicator(
              minHeight: 6,
              value: (_flow.downloadTotal != null && _flow.downloadReceived != null)
                  ? (_flow.downloadReceived! / _flow.downloadTotal!).clamp(0.0, 1.0)
                  : null,
            ),
          ),
          if (_flow.downloadTotal != null)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text('${formatBytes(_flow.downloadReceived ?? 0)} / ${formatBytes(_flow.downloadTotal!)}'),
            ),
        ],
      );
    } else if (_flow.downloadError != null) {
      subtitle = Text(
        _flow.downloadError!.breakWord,
        maxLines: 3,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(color: Theme.of(context).colorScheme.error),
      );
    } else if (_flow.urlFileReady) {
      subtitle = Text(S.current.downloaded);
    }

    final Widget trailing;
    if (downloading) {
      trailing = TextButton(onPressed: () => _flow.cancelToken?.cancel(), child: Text(S.current.cancel));
    } else {
      trailing = FilledButton.tonal(
        onPressed: _downloadEnabled ? _startDownload : null,
        child: Text(_flow.urlFileReady ? S.current.redownload : S.current.download),
      );
    }

    return TileGroup(
      children: [
        ListTile(
          leading: const Icon(Icons.link),
          title: Text(_flow.sourceUrl!.breakWord, maxLines: 2, overflow: TextOverflow.ellipsis),
          subtitle: subtitle,
          trailing: trailing,
        ),
      ],
    );
  }

  // ---- file tile (local file + install) ------------------------------------

  Widget _buildFileCard() {
    return TileGroup(
      children: [
        ListTile(
          leading: const Icon(Icons.insert_drive_file_outlined),
          title: Text(_flow.fileName ?? p.basename(_flow.sourcePath!)),
          subtitle: Text(_flow.sourcePath!.breakWord, maxLines: 2, overflow: TextOverflow.ellipsis),
          trailing: FilledButton.tonal(
            onPressed: (_flow.installEnabled && canInstall) ? _install : null,
            child: Text(S.current.install),
          ),
        ),
      ],
    );
  }

  Widget _buildProgressCard() {
    final cs = Theme.of(context).colorScheme;
    final IconData icon;
    Color? iconColor;
    final String title;
    final String? detail;
    Widget? progress;
    switch (_flow.phase) {
      case _FlowPhase.idle:
      case _FlowPhase.downloading:
        return const SizedBox.shrink();
      case _FlowPhase.parsing:
        icon = Icons.hourglass_top;
        title = S.current.xapk_parsing;
        progress = const SizedBox(height: 6, child: LinearProgressIndicator(minHeight: 6));
        detail = null;
      case _FlowPhase.parsed:
        icon = Icons.check_circle_outline;
        iconColor = cs.primary;
        title = S.current.xapk_parsed;
        progress = null;
        detail = null;
      case _FlowPhase.installing:
        icon = Icons.downloading;
        title = S.current.xapk_installing;
        final ev = _flow.installEvent;
        if (ev?.progress != null) {
          progress = SizedBox(
            height: 6,
            child: LinearProgressIndicator(minHeight: 6, value: ev!.progress!.clamp(0.0, 1.0)),
          );
          detail = '${formatBytes(ev.bytes ?? 0)} / ${formatBytes(ev.totalBytes ?? 0)}';
        } else {
          progress = const SizedBox(height: 6, child: LinearProgressIndicator(minHeight: 6));
          detail = null;
        }
      case _FlowPhase.confirming:
        icon = Icons.help_outline;
        title = S.current.xapk_confirming;
        progress = const SizedBox(height: 6, child: LinearProgressIndicator(minHeight: 6));
        detail = null;
      case _FlowPhase.success:
        icon = Icons.check_circle;
        iconColor = cs.primary;
        title = S.current.xapk_install_success;
        progress = null;
        detail = null;
      case _FlowPhase.failed:
        icon = Icons.error_outline;
        iconColor = cs.error;
        title = S.current.xapk_install_failed;
        progress = null;
        detail = _flow.errorMessage;
    }
    return Card(
      margin: const EdgeInsets.all(8),
      child: ListTile(
        leading: Icon(icon, color: iconColor, size: 28),
        title: Text(title),
        subtitle: (progress == null && detail == null)
            ? null
            : Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (detail != null)
                      Text(detail, style: _flow.phase == _FlowPhase.failed ? TextStyle(color: cs.error) : null),
                    if (progress != null) ...[const SizedBox(height: 8), progress],
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildManifestCard() {
    final m = _flow.manifest!;
    final selected = m.selectedFiles.toSet();
    final appIconBytes = m.appIconBytes;
    return TileGroup(
      header: m.appName,
      children: [
        if (appIconBytes != null && appIconBytes.isNotEmpty)
          ListTile(
            leading: ClipRRect(
              borderRadius: AppShape.medium,
              child: Image.memory(appIconBytes, width: 40, height: 40, fit: BoxFit.cover),
            ),
            title: Text(m.appName),
          ),
        ListTile(dense: true, title: Text(S.current.xapk_package), subtitle: Text(m.packageName)),
        ListTile(
          dense: true,
          title: Text(S.current.version),
          subtitle: Text('v${m.versionName} (${m.versionCode}) · minSdk ${m.minSdk}'),
        ),
        ListTile(dense: true, title: Text(S.current.xapk_total_size), subtitle: Text(formatBytes(m.totalSize))),
        for (final split in m.splits)
          ListTile(
            dense: true,
            leading: Icon(
              selected.contains(split.file) ? Icons.check_circle : Icons.circle_outlined,
              size: 18,
              color: selected.contains(split.file)
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).disabledColor,
            ),
            title: Text(split.file.breakWord, maxLines: 1, overflow: TextOverflow.ellipsis),
            subtitle: Text('${split.id} · ${formatBytes(split.size)}'),
          ),
      ],
    );
  }

  Widget _buildVendorCard() {
    final isZh = Language.isZH;
    final highlight = <String>[];
    final m = manufacturer;
    if (m.contains('xiaomi') || m.contains('redmi') || m.contains('poco')) {
      highlight.add('MIUI');
    } else if (m.contains('huawei') || m.contains('honor')) {
      highlight.add('EMUI');
    } else if (m.contains('samsung')) {
      highlight.add('OneUI');
    }
    Widget entry(String title, String body) {
      final active = highlight.contains(title);
      return Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        decoration: active
            ? BoxDecoration(
                border: Border.all(color: Theme.of(context).colorScheme.primary),
                borderRadius: BorderRadius.circular(8),
              )
            : null,
        padding: const EdgeInsets.all(8),
        child: MyMarkdownWidget(scrollable: false, data: '**${active ? '⭐ ' : ''}$title**\n\n$body'),
      );
    }

    return Card(
      margin: const EdgeInsets.all(8),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(8),
              child: Text(S.current.xapk_vendor_guidance_header, style: Theme.of(context).textTheme.titleSmall),
            ),
            entry(
              'MIUI',
              isZh
                  ? '若安装无反应或失败：开发者选项 → 关闭「MIUI 优化」后重试。较新版本的 MIUI 安装器已修复此问题。'
                  : 'If install silently fails: Developer options → turn off "MIUI optimization" and retry. Recent MIUI installer versions have fixed this.',
            ),
            entry(
              'EMUI',
              isZh
                  ? '设置 → 安全 → 更多安全设置 → 「安装外部来源应用」允许 Chaldea；弹出的安全检测选择「继续安装」。'
                  : 'Settings → Security → More security settings → allow Chaldea under "Install apps from external sources"; choose "Continue install" on the security scan dialog.',
            ),
            entry(
              'OneUI',
              isZh
                  ? '若被「自动阻止程序」拦截：设置 → 安全与隐私 → 自动阻止程序，允许该来源或暂时关闭。'
                  : 'If blocked by "auto blocker": Settings → Security and privacy → Auto Blocker, allow this source or disable it temporarily.',
            ),
            entry(
              isZh ? '其他设备' : 'Others',
              isZh
                  ? '确保已授予「安装未知应用」权限（见上方提示），并在系统弹窗中确认安装。'
                  : 'Make sure the "install unknown apps" permission is granted (see above) and confirm the system dialog.',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFooterHint() {
    final style = Theme.of(context).textTheme.bodySmall;
    return Card(
      margin: const EdgeInsets.all(8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Icon(Icons.info_outline, size: 18, color: Theme.of(context).colorScheme.outline),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(S.current.xapk_not_supported_hint, style: style),
                  // Shown on every build on purpose: many users get a version
                  // without REQUEST_INSTALL_PACKAGES (e.g. Google Play) and
                  // otherwise fail to understand why nothing happens.
                  const SizedBox(height: 8),
                  Text(S.current.xapk_no_install_permission_hint, style: style),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<bool?> _showGrantDialog(BuildContext context) {
    return showDialog<bool>(
      context: context,
      useRootNavigator: false,
      builder: (context) {
        return AlertDialog(
          title: Text(S.current.install),
          content: Text(S.current.install_permission_hint),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context, false), child: Text(S.current.cancel)),
            TextButton(onPressed: () => Navigator.pop(context, true), child: Text(S.current.open_settings)),
          ],
        );
      },
    );
  }

  Future<bool?> _showCancelDownloadDialog(BuildContext context) {
    return showDialog<bool>(
      context: context,
      useRootNavigator: false,
      builder: (context) {
        return AlertDialog(
          content: Text(S.current.xapk_cancel_download_to_pick),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context, false), child: Text(S.current.cancel)),
            FilledButton.tonal(
              onPressed: () => Navigator.pop(context, true),
              child: Text(S.current.xapk_cancel_and_pick),
            ),
          ],
        );
      },
    );
  }
}

void _deleteQuietly(String? path) {
  if (path == null) return;
  try {
    final file = File(path);
    if (file.existsSync()) file.deleteSync();
  } catch (e) {
    logger.e('delete partial xapk failed', e);
  }
}
