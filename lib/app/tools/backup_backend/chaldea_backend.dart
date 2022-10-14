import 'dart:async';
import 'dart:convert';

import 'package:archive/archive.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

import 'package:chaldea/app/api/chaldea.dart';
import 'package:chaldea/app/app.dart';
import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/models/api/recognizer.dart';
import 'package:chaldea/models/models.dart';
import 'package:chaldea/packages/packages.dart';
import 'package:chaldea/utils/utils.dart';
import 'package:chaldea/widgets/widgets.dart';
import '../../modules/home/subpage/login_page.dart';
import 'backend.dart';

class ChaldeaServerBackup extends BackupBackend<UserData> {
  ChaldeaServerBackup();

  String? get user => db.security.get('chaldea_user');
  String? get pwd => db.security.get('chaldea_auth');

  bool _check() {
    if (user == null || pwd == null) {
      SimpleCancelOkDialog(
        content: Text(S.current.login_first_hint),
        onTapOk: () {
          router.pushPage(LoginPage());
        },
      ).showDialog(null);
      return false;
    } else {
      return true;
    }
  }

  @override
  Future<bool> backup() async {
    if (!_check()) return false;
    dynamic error;
    try {
      EasyLoading.show(maskType: EasyLoadingMaskType.clear);
      final dio = db.apiWorkerDio;
      final content = base64Encode(
          GZipEncoder().encode(utf8.encode(jsonEncode(db.userData)))!);
      final resp =
          ChaldeaResponse(await dio.post('/account/backup/upload', data: {
        'username': user,
        'auth': pwd,
        'content': content,
      }));
      if (resp.success) {
        EasyLoading.showSuccess(S.current.success);
        return true;
      } else {
        error = resp.error;
      }
    } catch (e, s) {
      logger.e('upload server backup failed', e, s);
      error = escapeDioError(e);
    }
    EasyLoading.showError(error ?? S.current.failed);
    return false;
  }

  @override
  Future<UserData?> restore() async {
    if (!_check()) return null;
    EasyLoading.show(maskType: EasyLoadingMaskType.clear);
    try {
      final resp = ChaldeaResponse(
          await db.apiWorkerDio.post('/account/backup/download', data: {
        'username': db.security.get('chaldea_user'),
        'auth': db.security.get('chaldea_auth')
      }));
      List<UserDataBackup> backups = [];
      backups = List.from(resp.body())
          .map((e) => UserDataBackup.fromJson(e))
          .toList();
      backups.sort2((e) => e.timestamp, reversed: true);
      if (backups.isEmpty) {
        EasyLoading.showError('No backup found');
        return null;
      }
      EasyLoading.dismiss();
      return showDialog<UserData?>(
        context: kAppKey.currentContext!,
        useRootNavigator: false,
        builder: (context) {
          List<Widget> children = [];
          for (int index = 0; index < backups.length; index++) {
            final backup = backups[index];
            String title = '${S.current.backup} ${index + 1}';
            if (backup.content == null) {
              title += ' (Error)';
            }
            children.add(ListTile(
              title: Text(title),
              subtitle: Text(backup.timestamp.toString()),
              enabled: backup.content != null,
              onTap: backup.content == null
                  ? null
                  : () {
                      db.userData = backup.content!;
                      Navigator.pop(context, backup.content!);
                      db.notifyUserdata();
                      EasyLoading.showSuccess(S.current.import_data_success);
                    },
            ));
          }
          return SimpleDialog(
            title: Text(S.current.userdata_download_choose_backup),
            children: [
              ...children,
              IconButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                icon: const Icon(Icons.clear),
              )
            ],
          );
        },
      );
    } catch (e, s) {
      logger.e('decode server backup response failed', e, s);
      EasyLoading.showError(escapeDioError(e));
      return null;
    }
  }
}
