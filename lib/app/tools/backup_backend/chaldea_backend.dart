import 'dart:async';

import 'package:flutter_easyloading/flutter_easyloading.dart';

import 'package:chaldea/app/api/chaldea.dart';
import 'package:chaldea/app/app.dart';
import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/models/api/api.dart';
import 'package:chaldea/models/models.dart';
import 'package:chaldea/packages/packages.dart';
import 'package:chaldea/utils/utils.dart';
import 'package:chaldea/widgets/widgets.dart';
import '../../modules/home/subpage/login_page.dart';
import 'backend.dart';

class ChaldeaServerBackup extends BackupBackend<UserData> {
  bool _check() {
    if (!db.settings.secrets.isLoggedIn) {
      SimpleConfirmDialog(
        content: Text(S.current.login_first_hint),
        onTapOk: () {
          router.pushPage(LoginPage());
        },
      ).showDialog(router.navigatorKey.currentContext);
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
      final content = UserBackupData.encode(db.userData);
      final resp = await showEasyLoading(() => ChaldeaWorkerApi.uploadBackup(content: content));
      if (resp != null) {
        resp.showToast();
      }
      return resp != null && !resp.hasError;
    } catch (e, s) {
      error = escapeDioException(e);
      logger.e('upload server backup failed', e, s);
    }
    EasyLoading.showError(error ?? S.current.error);
    return false;
  }

  @override
  Future<UserData?> restore() async {
    if (!_check()) return null;
    try {
      final backups = await showEasyLoading(() => ChaldeaWorkerApi.listBackup());
      if (backups == null) return null;
      if (backups.isEmpty) {
        EasyLoading.showError('No backup found');
        return null;
      }
      backups.sort2((e) => -e.createdAt);
      final selected = await showDialog<UserData?>(
        context: kAppKey.currentContext!,
        useRootNavigator: false,
        builder: (context) => _ChooseBackupDialog(backups: backups),
      );
      if (selected != null) {
        db.userData = selected;
        db.notifyUserdata();
        EasyLoading.showSuccess(S.current.import_data_success);
      }
      return selected;
    } catch (e, s) {
      logger.e('decode server backup response failed', e, s);
      EasyLoading.showError(escapeDioException(e));
      return null;
    }
  }
}

class _ChooseBackupDialog extends StatelessWidget {
  final List<UserBackupData> backups;
  const _ChooseBackupDialog({required this.backups});

  @override
  Widget build(BuildContext context) {
    List<Widget> children = [];
    for (int index = 0; index < backups.length; index++) {
      final backup = backups[index];
      String title = '${S.current.backup} ${index + 1}';
      if (backup.appVer != null) {
        title += '  @${backup.appVer}';
      }
      if (backup.decoded == null) {
        title += ' (Error)';
      }
      final decoded = backup.decoded;
      children.add(
        ListTile(
          dense: true,
          title: Text(title),
          subtitle: Text(
            <String?>[backup.createdAt.sec2date().toStringShort(), backup.os].whereType<String>().join('\n'),
          ),
          enabled: decoded != null,
          onTap: decoded == null
              ? null
              : () {
                  Navigator.pop(context, decoded);
                },
        ),
      );
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
        ),
      ],
    );
  }
}
