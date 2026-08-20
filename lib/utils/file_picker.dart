import 'package:flutter/foundation.dart';

import 'package:file_picker/file_picker.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/packages/packages.dart';
import 'package:chaldea/packages/platform/platform.dart';
import 'package:chaldea/utils/extension.dart';
import 'package:chaldea/utils/url.dart';
import '../models/db.dart';
import '../widgets/widgets.dart';

class FilePickerU {
  const FilePickerU._();

  static bool _picking = false;

  static Future<bool?> clearTemporaryFiles() async {
    if (PlatformU.isAndroid || PlatformU.isIOS) {
      await FilePicker.clearTemporaryFiles();
      return true;
    }
    return false;
  }

  static Future<T?> _withPicking<T>({required bool showError, required Future<T> Function() task}) async {
    if (_picking) {
      if (showError) EasyLoading.showInfo('Previous file picking request has not finished');
      return null;
    }
    try {
      _picking = true;
      return await task();
    } catch (e, s) {
      logger.e('pick or save file failed', e, s);
      if (showError) EasyLoading.showError(e.toString());
    } finally {
      _picking = false;
    }
    return null;
  }

  static Future<PlatformFile?> pickFile({
    String? dialogTitle,
    String? initialDirectory,
    FileType type = FileType.any,
    List<String>? allowedExtensions,
    // extra
    bool clearCache = false,
    bool showError = true,
  }) async {
    return await _withPicking<PlatformFile?>(
      showError: showError,
      task: () async {
        if (clearCache) {
          await clearTemporaryFiles();
        }
        return await FilePicker.pickFile(
          dialogTitle: dialogTitle,
          initialDirectory: initialDirectory,
          type: allowedExtensions != null && allowedExtensions.isNotEmpty ? FileType.custom : type,
          allowedExtensions: allowedExtensions,
        );
      },
    );
  }

  static Future<List<PlatformFile>> pickFiles({
    String? dialogTitle,
    String? initialDirectory,
    FileType type = FileType.any,
    List<String>? allowedExtensions,
    // extra
    bool clearCache = false,
    bool showError = true,
  }) async {
    final files = await _withPicking<List<PlatformFile>>(
      showError: showError,
      task: () async {
        if (clearCache) {
          await clearTemporaryFiles();
        }
        return await FilePicker.pickFiles(
          dialogTitle: dialogTitle,
          initialDirectory: initialDirectory,
          type: allowedExtensions != null && allowedExtensions.isNotEmpty ? FileType.custom : type,
          allowedExtensions: allowedExtensions,
        );
      },
    );
    return files ?? [];
  }

  static Future<void> saveFile({
    required List<int> data,
    required String filename,
    String? saveFolder,
    BuildContext? dialogContext,
  }) async {
    if (kIsWeb) {
      return kPlatformMethods.downloadFile(data, filename);
    }
    final Uri? fp = await _withPicking<Uri?>(
      showError: true,
      task: () =>
          FilePicker.saveFile(fileName: filename, initialDirectory: saveFolder, bytes: Uint8List.fromList(data)),
    );
    if (fp == null) return;

    if (dialogContext != null && dialogContext.mounted) {
      showDialog(
        context: dialogContext,
        builder: (context) {
          return SimpleConfirmDialog(
            title: Text(S.current.saved),
            content: Text(db.paths.convertIosPath(fp.toString()).breakWord),
            showCancel: false,
            actions: [
              if (PlatformU.isDesktop)
                TextButton(
                  child: Text(S.current.open),
                  onPressed: () {
                    openFileUri(fp);
                  },
                ),
              if (PlatformU.isMobile)
                TextButton(
                  child: Text(S.current.share),
                  onPressed: () {
                    Navigator.of(context).pop();
                    ShareX.shareFile(fp.path, context: context);
                  },
                ),
            ],
          );
        },
      );
    }
    return;
  }
}
