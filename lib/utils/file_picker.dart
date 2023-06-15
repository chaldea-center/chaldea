import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import 'package:file_picker/file_picker.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/packages/packages.dart';
import 'package:chaldea/packages/platform/platform.dart';
import 'package:chaldea/utils/basic.dart';
import 'package:chaldea/utils/extension.dart';
import '../models/db.dart';
import '../widgets/custom_dialogs.dart';

class FilePickerU {
  const FilePickerU._();

  static bool _picking = false;

  static Future<bool?> clearTemporaryFiles() async {
    if (PlatformU.isAndroid || PlatformU.isIOS) {
      return FilePicker.platform.clearTemporaryFiles();
    }
    return false;
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
    if (_picking) {
      if (showError) EasyLoading.showInfo('Previous file picking request has not finished');
      return null;
    }
    try {
      _picking = true;
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
    } catch (e, s) {
      logger.e('pick file failed', e, s);
      if (showError) EasyLoading.showError(e.toString());
    } finally {
      _picking = false;
    }
    return null;
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
    String? fp;
    if (PlatformU.isDesktop) {
      fp = await FilePicker.platform.saveFile(
        fileName: filename,
        initialDirectory: saveFolder,
      );
      if (fp == null) return;
    }
    fp ??= joinPaths(saveFolder ?? db.paths.downloadDir, filename);
    final file = File(fp);
    file.parent.createSync(recursive: true);
    await file.writeAsBytes(data);
    if (dialogContext != null && dialogContext.mounted) {
      SimpleCancelOkDialog(
        title: Text(S.current.saved),
        content: Text(db.paths.convertIosPath(file.path).breakWord),
        hideCancel: true,
      ).showDialog(dialogContext);
    }
    return;
  }
}
