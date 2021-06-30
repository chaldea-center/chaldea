import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:chaldea/components/components.dart';
import 'package:chaldea/modules/home/subpage/login_page.dart';
import 'package:file_picker_cross/file_picker_cross.dart';
import 'package:open_file/open_file.dart';
import 'package:path/path.dart' show basenameWithoutExtension;
import 'package:share_plus/share_plus.dart';

class UserDataPage extends StatefulWidget {
  @override
  _UserDataPageState createState() => _UserDataPageState();
}

class _UserDataPageState extends State<UserDataPage> {
  Map<String, String> cachedFiles = {};
  List<String> onlineVersions = [];

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(),
        title: Text(S.of(context).userdata),
        actions: <Widget>[],
      ),
      body: ListView(
        children: <Widget>[
          TileGroup(
            header: S.of(context).userdata + '(Local)',
            footer: S.of(context).settings_userdata_footer,
            children: <Widget>[
              // ListTile(
              //   title: Text(S.of(context).clear),
              //   onTap: () {
              //     SimpleCancelOkDialog(
              //       title: Text(S.of(context).clear_userdata),
              //       onTapOk: () async {
              //         await db.clearData(user: true, game: false);
              //         db.notifyDbUpdate(true);
              //         EasyLoading.showToast(S.of(context).userdata_cleared);
              //       },
              //     ).show(context);
              //   },
              // ),
              ListTile(
                title: Text(S.of(context).backup),
                onTap: backupUserData,
              ),
              ListTile(
                title: Text(S.current.backup_history),
                trailing: Icon(Icons.keyboard_arrow_right),
                onTap: () {
                  SplitRoute.push(
                    context: context,
                    builder: (ctx, _) => _BackupHistoryPage(),
                  );
                },
              ),
              ListTile(
                title: Text(S.of(context).import_data),
                onTap: importUserData,
              ),
              ListTile(
                title: Text(S.of(context).reset_svt_enhance_state),
                subtitle: Text(S.of(context).reset_svt_enhance_state_hint),
                onTap: () {
                  db.curUser.servants.forEach((svtNo, svtStatus) {
                    svtStatus.resetEnhancement();
                  });
                  EasyLoading.showToast(S.of(context).reset_success);
                },
              ),
              if (Platform.isMacOS || Platform.isWindows)
                ListTile(
                  title: Text(LocalizedText.of(
                      chs: '打开目录', jpn: 'フォルダを開く', eng: 'Open Folder')),
                  subtitle: Text(db.paths.convertIosPath(db.paths.appPath)),
                  onTap: () {
                    OpenFile.open(db.paths.appPath);
                  },
                )
            ],
          ),
          TileGroup(
            header: S.current.userdata_sync + '(Server)',
            footer: LocalizedText.of(
                chs: '仅更新账户数据，不包含本地设置',
                jpn: 'アカウントデータのみを更新し、ローカル設定を含めない ',
                eng: 'Only update account data, excluding local settings'),
            children: [
              ListTile(
                title: Text(S.current.userdata_upload_backup),
                onTap: uploadToServer,
              ),
              ListTile(
                title: Text(S.current.userdata_download_backup),
                onTap: downloadFromServer,
              ),
            ],
          ),
        ],
      ),
    );
  }

  void importUserData() async {
    try {
      FilePickerCross result = await FilePickerCross.importFromStorage(
          type: FileTypeCross.custom, fileExtension: 'json');
      final path = result.path!;
      db.backupUserdata();

      db.userData =
          UserData.fromJson(json.decode(File(path).readAsStringSync()));
      EasyLoading.showToast(S.current.import_data_success);
      db.saveUserData();
      db.notifyDbUpdate(item: true, svt: true);
      db.notifyAppUpdate();
    } on FileSelectionCanceledError {} catch (e) {
      EasyLoading.showError(S.of(context).import_data_error(e));
    }
  }

  Future backupUserData() async {
    return SimpleCancelOkDialog(
      title: Text(S.of(context).backup),
      content: Text(db.paths.convertIosPath(db.paths.userDataBackupDir)),
      onTapOk: () async {
        final fps = db.backupUserdata();
        String hint = '';
        if (fps.isEmpty) {
          hint += LocalizedText.of(
              chs: '备份失败', jpn: 'バックアップに失敗しました', eng: 'Backup failed');
        } else {
          hint += LocalizedText.of(
                  chs: '已备份至:', jpn: 'バックアップ:', eng: 'Backup to:') +
              '\n${fps[0]}\n';
          hint += LocalizedText.of(
              chs: '删除应用(以及升级时可能)将导致临时备份被删除，建议手动备份到外部可靠储存位置！',
              jpn:
                  'アプリを削除すると、一時バックアップが削除されます。外部の信頼できるストレージ場所に手動でバックアップすることをお勧めします',
              eng:
                  'The backups will be deleted when uninstalling the app. It is recommended to manually backup to an external storage.');
        }
        showInformDialog(
          context,
          title: S.of(context).backup,
          content: hint,
          actions: [
            if (Platform.isAndroid || Platform.isIOS)
              TextButton(
                child: Text(S.of(context).share),
                onPressed: () {
                  Navigator.of(context).pop();
                  Share.shareFiles(fps);
                },
              ),
            if (Platform.isMacOS || Platform.isWindows)
              TextButton(
                child: Text(S.of(context).open),
                onPressed: () {
                  OpenFile.open(db.paths.userDir);
                },
              ),
          ],
        );
      },
    ).showDialog(context);
  }

  bool checkUserPwd() {
    if (db.prefs.userName.get()?.isNotEmpty != true ||
        db.prefs.userPwd.get()?.isNotEmpty != true) {
      SimpleCancelOkDialog(
        content: Text(S.current.login_first_hint),
        onTapOk: () {
          SplitRoute.push(
            context: context,
            builder: (context, _) => LoginPage(),
            detail: true,
          );
        },
      ).showDialog(context);
      return false;
    } else {
      return true;
    }
  }

  Future<void> uploadToServer() async {
    if (!checkUserPwd()) return;
    await catchErrorAsync(
      () async {
        EasyLoading.show(
            status: 'uploading', maskType: EasyLoadingMaskType.clear);
        final resp = ChaldeaResponse.fromResponse(
            await db.serverDio.post('/user/uploadBackup', data: {
          HttpUtils.usernameKey: db.prefs.userName.get(),
          HttpUtils.passwordKey: db.prefs.userPwd.get(),
          HttpUtils.bodyKey: jsonEncode(db.userData),
        }));
        if (!resp.success) {
          resp.showMsg(context);
          return;
        }
      },
      onSuccess: () => EasyLoading.showSuccess('Uploaded'),
      onError: (e, s) => EasyLoading.showError(e.toString()),
    ).whenComplete(() => EasyLoadingUtil.dismiss());
  }

  Future<void> downloadFromServer() async {
    if (!checkUserPwd()) return;
    await catchErrorAsync(
      () async {
        final resp = ChaldeaResponse.fromResponse(
            await db.serverDio.post('/user/listBackups', data: {
          HttpUtils.usernameKey: db.prefs.userName.get(),
          HttpUtils.passwordKey: db.prefs.userPwd.get(),
        }));
        if (!resp.success) {
          resp.showMsg(context);
          return;
        }
        Map<String, int> body = Map.from(resp.body ?? {});
        String? fn = await SimpleDialog(
          title: Text(S.current.userdata_download_choose_backup),
          children: [
            if (body.isEmpty) ListTile(title: Text('No backup found')),
            for (var entry in body.entries)
              ListTile(
                title: Text(entry.key),
                subtitle: Text(
                    DateTime.fromMillisecondsSinceEpoch(entry.value * 1000)
                        .toString()),
                onTap: () {
                  Navigator.pop(context, entry.key);
                },
              ),
            IconButton(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: Icon(Icons.clear),
            )
          ],
        ).showDialog(context);
        if (fn == null) return;
        EasyLoading.show(
            status: 'Downloading', maskType: EasyLoadingMaskType.clear);
        final resp2 = ChaldeaResponse.fromResponse(
            await db.serverDio.post('/user/downloadBackup', data: {
          HttpUtils.usernameKey: db.prefs.userName.get(),
          HttpUtils.passwordKey: db.prefs.userPwd.get(),
          'bak': fn,
        }));
        // print(resp2);
        if (!resp2.success) {
          resp2.showMsg(context);
          return;
        }
        final userdata = UserData.fromJson(jsonDecode(resp2.body));
        db.backupUserdata(disk: true, memory: true);
        // only update UserData.users part
        final newUserdata = db.userData;
        newUserdata.users = userdata.users;
        newUserdata.curUserKey; // ensure _curUserKey is set correctly
        db.loadUserData(newUserdata);
        db.saveUserData();
        db.itemStat.update();
        db.notifyAppUpdate();
        EasyLoading.showSuccess('Import $fn');
      },
      onError: (e, s) => EasyLoading.showError(e.toString()),
    ).whenComplete(() => EasyLoadingUtil.dismiss());
  }
}

class _BackupHistoryPage extends StatefulWidget {
  const _BackupHistoryPage({Key? key}) : super(key: key);

  @override
  __BackupHistoryPageState createState() => __BackupHistoryPageState();
}

class __BackupHistoryPageState extends State<_BackupHistoryPage> {
  List<String> paths = [];

  @override
  void initState() {
    super.initState();
    final dir = Directory(db.paths.userDataBackupDir);
    if (dir.existsSync()) {
      for (var entry in dir.listSync()) {
        if (FileSystemEntity.isFileSync(entry.path) &&
            entry.path.toLowerCase().endsWith('.json')) {
          paths.add(entry.path);
        }
      }
    }
    paths.sort((a, b) => b.compareTo(a));
    paths = paths.take(50).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(),
        title: Text(S.current.backup_history),
      ),
      body: ListView.separated(
        itemBuilder: (context, index) {
          if (index == 0)
            return Card(
              child: Padding(
                padding: EdgeInsets.all(6),
                child:
                    Text(db.paths.convertIosPath(db.paths.userDataBackupDir)),
              ),
            );
          final path = paths[index - 1];
          return ListTile(
            title: Text(basenameWithoutExtension(path)),
            trailing: IconButton(
              icon: Icon(Icons.download),
              tooltip: S.current.import_data,
              onPressed: () {
                SimpleCancelOkDialog(
                  title: Text(S.current.import_data),
                  content: Text(db.paths.convertIosPath(path)),
                  onTapOk: () {
                    try {
                      db.backupUserdata();
                      db.userData = UserData.fromJson(
                          json.decode(File(path).readAsStringSync()));
                      EasyLoading.showToast(S.current.import_data_success);
                      db.saveUserData();
                      db.notifyDbUpdate(item: true, svt: true);
                      db.notifyAppUpdate();
                    } on FileSelectionCanceledError {} catch (e) {
                      EasyLoading.showError(S.of(context).import_data_error(e));
                    }
                  },
                ).showDialog(context);
              },
            ),
          );
        },
        separatorBuilder: (_, __) => kDefaultDivider,
        itemCount: paths.length + 1,
      ),
    );
  }
}
