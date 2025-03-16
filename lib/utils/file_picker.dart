import 'dart:io';

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
      return FilePicker.platform.clearTemporaryFiles();
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

  static Future<FilePickerResult?> pickFiles({
    String? dialogTitle,
    String? initialDirectory,
    FileType type = FileType.any,
    List<String>? allowedExtensions,
    Function(FilePickerStatus)? onFileLoading,
    bool allowCompression = true,
    bool allowMultiple = false,
    // web always have to [withData]
    bool withData = true,
    bool withReadStream = false,
    bool lockParentWindow = false,
    // extra
    bool clearCache = false,
    bool showError = true,
  }) async {
    return await _withPicking<FilePickerResult?>(
      showError: showError,
      task: () async {
        if (clearCache) {
          await clearTemporaryFiles();
        }
        return await FilePicker.platform.pickFiles(
          dialogTitle: dialogTitle,
          initialDirectory: initialDirectory,
          type: type,
          allowedExtensions: allowedExtensions,
          onFileLoading: onFileLoading,
          allowCompression: allowCompression,
          allowMultiple: allowMultiple,
          withData: withData,
          withReadStream: withReadStream,
          lockParentWindow: lockParentWindow,
        );
      },
    );
  }

  static Future<void> saveFile({
    required List<int> data,
    required String? filename,
    String? saveFolder,
    BuildContext? dialogContext,
  }) async {
    if (kIsWeb) {
      return kPlatformMethods.downloadFile(data, filename ?? "unknown_format_file.bin");
    }
    String? fp;
    fp = await _withPicking<String?>(
      showError: true,
      task:
          () => FilePicker.platform.saveFile(
            fileName: filename,
            initialDirectory: saveFolder,
            bytes: Uint8List.fromList(data),
          ),
    );
    if (fp == null) return;
    final file = File(fp);

    if (PlatformU.isDesktop) {
      // plugin didn't write file on desktop
      file.parent.createSync(recursive: true);
      await file.writeAsBytes(data);
    }

    if (dialogContext != null && dialogContext.mounted) {
      showDialog(
        context: dialogContext,
        builder: (context) {
          return SimpleConfirmDialog(
            title: Text(S.current.saved),
            content: Text(db.paths.convertIosPath(file.path).breakWord),
            showCancel: false,
            actions: [
              if (PlatformU.isDesktop)
                TextButton(
                  child: Text(S.current.open),
                  onPressed: () {
                    openFile(file.parent.path);
                  },
                ),
              if (PlatformU.isMobile)
                TextButton(
                  child: Text(S.current.share),
                  onPressed: () {
                    Navigator.of(context).pop();
                    ShareX.shareFile(file.path, context: context);
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
