import 'dart:io';

import 'package:flutter/material.dart';

import 'package:dio/dio.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/packages/method_channel/method_channel_chaldea.dart';
import 'package:chaldea/packages/packages.dart';
import 'package:chaldea/utils/utils.dart';

/// Android direct-install service (see
/// docs/context/android-install/CONTEXT.md).
///
/// Capability gating: [isSupported] probes the manifest DECLARATION of
/// REQUEST_INSTALL_PACKAGES — silent, cached, never a dialog. The user
/// GRANT is checked per flow, permission-first: an ungranted device is
/// guided to system settings before any download starts, and the user
/// re-taps Install after returning.
class ApkInstaller {
  ApkInstaller._();

  static bool? _supported;

  /// Whether this build offers direct-install UI at all.
  static Future<bool> isSupported() async {
    if (!PlatformU.isAndroid) return false;
    _supported ??= (await MethodChannelChaldea.getInstallCapability())?.declared ?? false;
    return _supported!;
  }

  static String filenameOf(String url) {
    final segments = Uri.tryParse(url)?.pathSegments;
    final name = (segments == null || segments.isEmpty) ? null : segments.last;
    if (name != null && name.contains('.')) return name;
    return 'download.apk';
  }

  /// Direct-install flow: grant check → download with progress → system
  /// package installer.
  static Future<void> installFromUrl(BuildContext context, {required String url, String? filename}) async {
    final capability = await MethodChannelChaldea.getInstallCapability();
    if (capability == null || !capability.declared) return;
    if (!context.mounted) return;
    if (!capability.granted) {
      final open = await _showGrantDialog(context);
      if (open == true) {
        await MethodChannelChaldea.openInstallPermissionSettings();
      }
      // permission-first: nothing is downloaded until the user grants in
      // settings and returns to tap Install again
      return;
    }
    await _showDownloadDialog(context, url: url, filename: filename ?? filenameOf(url));
  }

  static Future<bool?> _showGrantDialog(BuildContext context) {
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
}

// ---------------------------------------------------------------------------
// download + install dialog (modeled after showDesktopUpgradeDialog)
// ---------------------------------------------------------------------------

enum _ApkInstallPhase { downloading, done, cancelled, error }

class _ApkInstallState {
  final _ApkInstallPhase phase;
  final int? received;
  final int? total;
  final String? error;

  const _ApkInstallState({required this.phase, this.received, this.total, this.error});
}

Future<void> _showDownloadDialog(BuildContext context, {required String url, required String filename}) {
  final state = ValueNotifier(const _ApkInstallState(phase: _ApkInstallPhase.downloading));
  final cancelToken = CancelToken();
  Future<void>.microtask(() => _downloadAndInstall(url, filename, state, cancelToken));
  return showDialog(
    context: context,
    useRootNavigator: false,
    barrierDismissible: false,
    builder: (context) {
      return PopScope(
        canPop: false,
        child: AlertDialog(
          title: Text(S.current.install),
          content: ValueListenableBuilder<_ApkInstallState>(
            valueListenable: state,
            builder: (context, value, _) => _buildDownloadDialogContent(value),
          ),
          actions: [
            ValueListenableBuilder<_ApkInstallState>(
              valueListenable: state,
              builder: (context, value, _) {
                if (value.phase == _ApkInstallPhase.downloading) {
                  return TextButton(
                    onPressed: () {
                      cancelToken.cancel();
                    },
                    child: Text(S.current.cancel),
                  );
                }
                return TextButton(onPressed: () => Navigator.pop(context), child: Text(S.current.confirm));
              },
            ),
          ],
        ),
      );
    },
  );
}

Future<void> _downloadAndInstall(
  String url,
  String filename,
  ValueNotifier<_ApkInstallState> state,
  CancelToken cancelToken,
) async {
  String? savePath;
  try {
    final dir = await getExternalStorageDirectory();
    if (dir == null) {
      state.value = _ApkInstallState(phase: _ApkInstallPhase.error, error: 'no external storage');
      return;
    }
    savePath = p.join(dir.path, filename);
    await DioE().download(
      url,
      savePath,
      cancelToken: cancelToken,
      onReceiveProgress: (count, total) {
        state.value = _ApkInstallState(
          phase: _ApkInstallPhase.downloading,
          received: count,
          total: total > 0 ? total : null,
        );
      },
    );
    final ok = await MethodChannelChaldea.installApk(savePath);
    if (!ok) {
      throw Exception(S.current.install_failed_to_start);
    }
    state.value = const _ApkInstallState(phase: _ApkInstallPhase.done);
  } on DioException catch (e, s) {
    logger.e('apk download failed', e, s);
    _deleteQuietly(savePath);
    if (CancelToken.isCancel(e)) {
      state.value = const _ApkInstallState(phase: _ApkInstallPhase.cancelled);
    } else {
      state.value = _ApkInstallState(phase: _ApkInstallPhase.error, error: escapeDioException(e));
    }
  } catch (e, s) {
    logger.e('apk install failed', e, s);
    _deleteQuietly(savePath);
    state.value = _ApkInstallState(phase: _ApkInstallPhase.error, error: e.toString());
  }
}

void _deleteQuietly(String? path) {
  if (path == null) return;
  try {
    final file = File(path);
    if (file.existsSync()) file.deleteSync();
  } catch (e) {
    logger.e('delete partial apk failed', e);
  }
}

Widget _buildDownloadDialogContent(_ApkInstallState state) {
  Widget progress = const SizedBox(height: 6, child: LinearProgressIndicator(minHeight: 6));
  String text;
  switch (state.phase) {
    case _ApkInstallPhase.downloading:
      text = S.current.downloading;
      if (state.total != null) {
        progress = SizedBox(
          height: 6,
          child: LinearProgressIndicator(
            minHeight: 6,
            value: state.received == null ? null : state.received! / state.total!,
          ),
        );
        final receivedMB = (state.received ?? 0) / 1024 / 1024;
        final totalMB = state.total! / 1024 / 1024;
        text += '\n${receivedMB.toStringAsFixed(1)} / ${totalMB.toStringAsFixed(1)} MB';
      }
    case _ApkInstallPhase.done:
      text = S.current.downloaded;
      progress = const SizedBox.shrink();
    case _ApkInstallPhase.cancelled:
      text = S.current.download_cancelled;
      progress = const SizedBox.shrink();
    case _ApkInstallPhase.error:
      text = '${S.current.failed}: ${state.error ?? ''}';
      progress = const SizedBox.shrink();
  }
  return Column(
    mainAxisSize: MainAxisSize.min,
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [Text(text), if (progress != const SizedBox.shrink()) const SizedBox(height: 16), progress],
  );
}
