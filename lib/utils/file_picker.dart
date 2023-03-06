import 'package:file_picker/file_picker.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

import 'package:chaldea/packages/packages.dart';

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
}
