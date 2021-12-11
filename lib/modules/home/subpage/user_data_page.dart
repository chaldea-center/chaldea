import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:chaldea/components/components.dart';
import 'package:chaldea/modules/home/subpage/login_page.dart';
import 'package:chaldea/modules/import_data/home_import_page.dart';
import 'package:file_picker/file_picker.dart';
import 'package:open_file/open_file.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

class UserDataPage extends StatefulWidget {
  UserDataPage({Key? key}) : super(key: key);

  @override
  _UserDataPageState createState() => _UserDataPageState();
}

class _UserDataPageState extends State<UserDataPage> {
  Map<String, String> cachedFiles = {};
  List<String> onlineVersions = [];

  List<Directory> androidExternalDirs = [];

  @override
  void initState() {
    super.initState();
    if (PlatformU.isAndroid) {
      getExternalStorageDirectories().then((dirs) {
        if (dirs != null && mounted) {
          setState(() {
            androidExternalDirs = dirs;
          });
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(S.of(context).userdata),
      ),
      body: ListView(
        children: <Widget>[
          TileGroup(
            footer: 'All data saved here.',
            children: [
              if (androidExternalDirs.length >= 2)
                SwitchListTile.adaptive(
                  value: db.persistentCfg.androidUseExternal.get() == true,
                  title: Text(LocalizedText.of(
                      chs: '使用外部储存(SD卡)',
                      jpn: '外部ストレージ（SDカード）を使用',
                      eng: 'Use External Storage(SD card)')),
                  subtitle: Text(LocalizedText.of(
                      chs: '下次启动生效',
                      jpn: '次の起動時に有効になります',
                      eng: 'Take effect at next startup')),
                  onChanged: _migrateAndroidData,
                ),
              ListTile(
                title: Text(LocalizedText.of(
                    chs: '数据目录', jpn: 'データフォルダ', eng: 'Data Folder')),
                subtitle: Text(db.paths.convertIosPath(db.paths.appPath)),
                onTap: () {
                  if (PlatformU.isDesktop) {
                    OpenFile.open(db.paths.appPath);
                  } else {
                    EasyLoading.showInfo(LocalizedText.of(
                        chs: '请用文件管理器打开',
                        jpn: 'ファイルマネージャで開いてください',
                        eng: 'Please open with file manager'));
                  }
                },
              )
            ],
          ),
          TileGroup(
            header: S.current.userdata + '(Local)',
            footer: S.current.settings_userdata_footer,
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
                title: Text(S.current.backup),
                onTap: backupUserData,
              ),
              ListTile(
                title: Text(S.current.backup_history),
                trailing: const Icon(Icons.keyboard_arrow_right),
                onTap: () {
                  SplitRoute.push(context, _BackupHistoryPage());
                },
              ),
              ListTile(
                title: Text(LocalizedText.of(
                    chs: '导入备份', jpn: 'バックアップのインポート', eng: 'Import Backup')),
                subtitle: const Text('userdata.json/*.json'),
                onTap: importUserData,
              ),
              ListTile(
                title: Text(LocalizedText.of(
                    chs: '更多导入方式', jpn: 'その他のインポート方法', eng: 'Import from ...')),
                trailing: const Icon(Icons.keyboard_arrow_right),
                onTap: () {
                  SplitRoute.push(context, ImportPageHome(), detail: false);
                },
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
      final result = await FilePicker.platform
          .pickFiles(type: FileType.custom, allowedExtensions: ['json']);
      final path = result?.paths.first;
      if (path == null) return;
      db.backupUserdata();

      db.userData =
          UserData.fromJson(json.decode(File(path).readAsStringSync()));
      EasyLoading.showToast(S.current.import_data_success);
      db.saveUserData();
      db.notifyDbUpdate(item: true, svt: true);
      MobStat.logEvent('import_data', {"from": "backup"});
      db.notifyAppUpdate();
    } catch (e, s) {
      logger.e('import user data failed', e, s);
      EasyLoading.showError(S.of(context).import_data_error(e));
    }
  }

  Future backupUserData() async {
    return SimpleCancelOkDialog(
      title: Text(S.current.backup),
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
            if (PlatformU.isAndroid || PlatformU.isIOS)
              TextButton(
                child: Text(S.of(context).share),
                onPressed: () {
                  Navigator.of(context).pop();
                  Share.shareFiles(fps);
                },
              ),
            if (PlatformU.isDesktop)
              TextButton(
                child: Text(S.of(context).open),
                onPressed: () {
                  OpenFile.open(db.paths.userDataBackupDir);
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
          SplitRoute.push(context, LoginPage());
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
      onSuccess: () {
        EasyLoading.showSuccess('Uploaded');
        MobStat.logEvent('server_backup', {"action": "upload"});
      },
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
        String? fn = await showDialog(
          context: context,
          builder: (context) => SimpleDialog(
            title: Text(S.current.userdata_download_choose_backup),
            children: [
              if (body.isEmpty) const ListTile(title: Text('No backup found')),
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
                icon: const Icon(Icons.clear),
              )
            ],
          ),
        );
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
        MobStat.logEvent('server_backup', {"action": "download"});
      },
      onError: (e, s) => EasyLoading.showError(e.toString()),
    ).whenComplete(() => EasyLoadingUtil.dismiss());
  }

  Future<void> _migrateAndroidData(bool useExternal) async {
    Directory from, to;
    if (useExternal) {
      // from internal to external
      from = androidExternalDirs[0];
      to = androidExternalDirs[1];
    } else {
      // from external to internal
      from = androidExternalDirs[1];
      to = androidExternalDirs[0];
    }
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text(
            LocalizedText.of(chs: '迁移数据', jpn: 'データの移行', eng: 'Migrate Data')),
        content: Text('From:\n ${from.path}\nTo:\n${to.path}'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(S.current.cancel),
          ),
          TextButton(
            onPressed: () {
              db.persistentCfg.androidUseExternal.set(useExternal);
              Navigator.of(context).pop();
              SimpleCancelOkDialog(
                title: const Text('⚠️ Warning'),
                content: Text(LocalizedText.of(
                    chs: '请手动移动数据，否则启动后为空数据。',
                    jpn: 'データを手動で移動してください。そうしないと、起動後にデータが空になります。',
                    eng:
                        'Please move the data manually, otherwise the data will be empty after startup.')),
                hideCancel: true,
              ).showDialog(context);
            },
            child: Text(
                LocalizedText.of(chs: '不迁移', jpn: '移行しない', eng: 'NOT MIGRATE')),
          ),
          TextButton(
            onPressed: () async {
              EasyLoading.show(
                  status: 'Moving...', maskType: EasyLoadingMaskType.clear);
              try {
                await _copyDirectory(from, to);
                db.persistentCfg.androidUseExternal.set(useExternal);
                Navigator.of(context).pop();
                SimpleCancelOkDialog(
                  title: const Text('⚠️ Warning'),
                  content: Text(LocalizedText.of(
                      chs: '重启以设置生效',
                      jpn: '設定を有効にするために再起動します',
                      eng: 'Restart for the settings to take effect')),
                  hideCancel: true,
                ).showDialog(context);
              } catch (e, s) {
                logger.e('migrate android data to external failed', e, s);
                SimpleCancelOkDialog(
                  title: const Text('⚠️ ERROR'),
                  content: Text(e.toString()),
                  hideCancel: true,
                ).showDialog(context);
              } finally {
                EasyLoadingUtil.dismiss();
              }
            },
            child: Text(LocalizedText.of(chs: '迁移', jpn: '移行', eng: 'MIGRATE')),
          ),
        ],
      ),
    );
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _copyDirectory(Directory source, Directory destination) async {
    await destination.create(recursive: true);
    await for (var entity in source.list(recursive: false)) {
      if (entity is Directory) {
        var newDirectory = Directory(
            p.join(destination.absolute.path, p.basename(entity.path)));
        await newDirectory.create(recursive: true);
        await _copyDirectory(entity.absolute, newDirectory);
      } else if (entity is File) {
        await entity.copy(p.join(destination.path, p.basename(entity.path)));
      }
      //  skip link
    }
  }
}

class _BackupHistoryPage extends StatefulWidget {
  _BackupHistoryPage({Key? key}) : super(key: key);

  @override
  __BackupHistoryPageState createState() => __BackupHistoryPageState();
}

class __BackupHistoryPageState extends State<_BackupHistoryPage> {
  List<MapEntry<String, DateTime>> validFiles = [];

  @override
  void initState() {
    super.initState();
    listBackups();
  }

  Future<void> listBackups() async {
    final dir = Directory(db.paths.userDataBackupDir);
    if (await dir.exists()) {
      await for (var entry in dir.list()) {
        if (await FileSystemEntity.isFile(entry.path) &&
            entry.path.toLowerCase().contains('.json')) {
          validFiles.add(MapEntry(entry.path, (await entry.stat()).modified));
        }
      }
    }
    validFiles.sort((a, b) => b.value.compareTo(a.value));
    validFiles = validFiles.take(50).toList();
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(S.current.backup_history)),
      body: ListView.separated(
        itemBuilder: (context, index) {
          if (index == 0) {
            return Card(
              child: InkWell(
                onTap: PlatformU.isDesktop
                    ? () => OpenFile.open(db.paths.userDataBackupDir)
                    : null,
                child: Padding(
                  padding: const EdgeInsets.all(6),
                  child:
                      Text(db.paths.convertIosPath(db.paths.userDataBackupDir)),
                ),
              ),
            );
          }
          final entry = validFiles[index - 1];
          return ListTile(
            title: Text(p.basenameWithoutExtension(entry.key)),
            subtitle: Text('Modified: ${entry.value}'),
            trailing: IconButton(
              icon: const Icon(Icons.download),
              tooltip: S.current.import_data,
              onPressed: () {
                SimpleCancelOkDialog(
                  title: Text(S.current.import_data),
                  content: Text(db.paths.convertIosPath(entry.key)),
                  onTapOk: () {
                    try {
                      db.backupUserdata();
                      db.userData = UserData.fromJson(
                          json.decode(File(entry.key).readAsStringSync()));
                      EasyLoading.showToast(S.current.import_data_success);
                      db.saveUserData();
                      db.notifyDbUpdate(item: true, svt: true);
                      db.notifyAppUpdate();
                    } catch (e) {
                      EasyLoading.showError(S.of(context).import_data_error(e));
                    }
                  },
                ).showDialog(context);
              },
            ),
          );
        },
        separatorBuilder: (_, __) => kDefaultDivider,
        itemCount: validFiles.length + 1,
      ),
    );
  }
}
