import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:archive/archive.dart';
import 'package:chaldea/app/api/chaldea.dart';
import 'package:chaldea/components/localized/localized_base.dart';
import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/models/models.dart';
import 'package:chaldea/packages/file_plus/file_plus_web.dart';
import 'package:chaldea/packages/packages.dart';
import 'package:chaldea/packages/split_route/split_route.dart';
import 'package:chaldea/utils/utils.dart';
import 'package:chaldea/widgets/custom_dialogs.dart';
import 'package:chaldea/widgets/tile_items.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:open_file/open_file.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../import_data/home_import_page.dart';
import 'login_page.dart';

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
        title: Text(S.current.userdata),
      ),
      body: ListView(
        children: <Widget>[
          TileGroup(
            footer: 'All data saved here.',
            children: [
              if (androidExternalDirs.length >= 2)
                SwitchListTile.adaptive(
                  value: db2.settings.useAndroidExternal,
                  title: Text(LocalizedText.of(
                      chs: '使用外部储存(SD卡)',
                      jpn: '外部ストレージ（SDカード）を使用',
                      eng: 'Use External Storage(SD card)',
                      kor: '외부 스토리지 (SD 카드)를 사용')),
                  subtitle: Text(LocalizedText.of(
                      chs: '下次启动生效',
                      jpn: '次の起動時に有効になります',
                      eng: 'Take effect at next startup',
                      kor: '다음 시작 시 적용됩니다')),
                  onChanged: _migrateAndroidData,
                ),
              ListTile(
                title: Text(LocalizedText.of(
                    chs: '数据目录',
                    jpn: 'データフォルダ',
                    eng: 'Data Folder',
                    kor: '데이터 폴더')),
                subtitle: Text(db2.paths.convertIosPath(db2.paths.appPath)),
                onTap: () {
                  if (PlatformU.isWeb) {
                    EasyLoading.showInfo('Check it in IndexedDB');
                  } else if (PlatformU.isDesktop) {
                    OpenFile.open(db2.paths.appPath);
                  } else {
                    EasyLoading.showInfo(LocalizedText.of(
                        chs: '请用文件管理器打开',
                        jpn: 'ファイルマネージャで開いてください',
                        eng: 'Please open with file manager',
                        kor: '파일 매니저로 열어주십시오'));
                  }
                },
              )
            ],
          ),
          TileGroup(
            header: S.current.userdata_sync + '(Server)',
            footer: LocalizedText.of(
                chs: '仅更新账户数据，不包含本地设置',
                jpn: 'アカウントデータのみを更新し、ローカル設定を含めない ',
                eng: 'Only update account data, excluding local settings',
                kor: '계정 데이터만을 갱신하여 전역 설정을 포함시키지 않음'),
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
                    chs: '导入备份',
                    jpn: 'バックアップのインポート',
                    eng: 'Import Backup',
                    kor: '백업 불러오기')),
                subtitle: const Text('userdata.json/*.json'),
                onTap: importUserData,
              ),
              ListTile(
                title: Text(LocalizedText.of(
                    chs: '更多导入方式',
                    jpn: 'その他のインポート方法',
                    eng: 'Import from ...',
                    kor: '이외의 불러오는 방법')),
                trailing: const Icon(Icons.keyboard_arrow_right),
                onTap: () {
                  SplitRoute.push(context, ImportPageHome(), detail: false);
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  void importUserData() async {
    try {
      final result = await FilePicker.platform.pickFiles(
          type: FileType.custom, allowedExtensions: ['json'], withData: true);
      final bytes = result?.files.first.bytes;
      if (bytes == null) return;
      final userdata = UserData.fromJson(jsonDecode(utf8.decode(bytes)));
      db2.backupUserdata();
      db2.userData = userdata;
      db2.saveUserData();
      EasyLoading.showToast(S.current.import_data_success);
      db2.notifyDb();
      db2.notifyAppUpdate();
    } catch (e, s) {
      logger.e('import user data failed', e, s);
      EasyLoading.showError(S.of(context).import_data_error(e));
    }
  }

  Future backupUserData() async {
    return SimpleCancelOkDialog(
      title: Text(S.current.backup),
      content: Text(db2.paths.convertIosPath(db2.paths.backupDir)),
      onTapOk: () async {
        final fps = await db2.backupUserdata();
        String hint = '';
        if (fps.isEmpty) {
          hint += LocalizedText.of(
              chs: '备份失败',
              jpn: 'バックアップに失敗しました',
              eng: 'Backup failed',
              kor: '백업 불러오기를 실패하였습니다');
        } else {
          hint += LocalizedText.of(
                  chs: '已备份至:', jpn: 'バックアップ:', eng: 'Backup to:', kor: '백업:') +
              '\n${fps[0]}\n';
          hint += LocalizedText.of(
              chs: '删除应用(以及升级时可能)将导致临时备份被删除，建议手动备份到外部可靠储存位置！',
              jpn:
                  'アプリを削除すると、一時バックアップが削除されます。外部の信頼できるストレージ場所に手動でバックアップすることをお勧めします',
              eng:
                  'The backups will be deleted when uninstalling the app. It is recommended to manually backup to an external storage.',
              kor:
                  '어플을 소삭제하면 동시에 백업이 삭제됩니다. 신뢰할 수 있는 외부 스토리지에 수동으로 백업하는 것을 추천드립니다');
        }
        showDialog(
          context: context,
          builder: (context) => SimpleCancelOkDialog(
            title: Text(S.current.backup),
            content: Text(hint),
            hideCancel: true,
            actions: [
              if (PlatformU.isAndroid || PlatformU.isIOS)
                TextButton(
                  child: Text(S.current.share),
                  onPressed: () {
                    Navigator.of(context).pop();
                    Share.shareFiles(fps);
                  },
                ),
              if (PlatformU.isDesktop)
                TextButton(
                  child: Text(S.current.open),
                  onPressed: () {
                    OpenFile.open(db2.paths.backupDir);
                  },
                ),
            ],
          ),
        );
      },
    ).showDialog(context);
  }

  bool checkUserPwd() {
    if (db2.security.get('chaldea_user') == null ||
        db2.security.get('chaldea_auth') == null) {
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
    ChaldeaResponse.request(
      caller: (dio) {
        final content = base64Encode(
            GZipEncoder().encode(utf8.encode(jsonEncode(db2.userData)))!);
        return dio.post('/account/backup/upload', data: {
          'username': db2.security.get('chaldea_user'),
          'auth': db2.security.get('chaldea_auth'),
          'content': content,
        });
      },
    );
  }

  Future<void> downloadFromServer() async {
    if (!checkUserPwd()) return;
    ChaldeaResponse.request(
      showSuccess: false,
      caller: (dio) => dio.post('/account/backup/download', data: {
        'username': db2.security.get('chaldea_user'),
        'auth': db2.security.get('chaldea_auth')
      }),
      onSuccess: (resp) {
        final body = List.from(resp.body()).map((e) => Map.from(e)).toList();
        body.sort2((e) => e['timestamp'] as int, reversed: true);
        showDialog(
          context: context,
          builder: (context) => SimpleDialog(
            title: Text(S.current.userdata_download_choose_backup),
            children: [
              if (body.isEmpty) const ListTile(title: Text('No backup found')),
              for (int index = 0; index < body.length; index++)
                ListTile(
                  title: Text('Backup ${index + 1}'),
                  subtitle: Text(DateTime.fromMillisecondsSinceEpoch(
                          body[index]['timestamp'] as int)
                      .toString()),
                  onTap: () {
                    Navigator.pop(context);
                    db2.userData = UserData.fromJson(jsonDecode(utf8.decode(
                        GZipDecoder().decodeBytes(
                            base64Decode(body[index]['content'])))));
                    db2.itemCenter.init();
                    db2.notifyUserdata();
                    EasyLoading.showSuccess(S.current.import_data_success);
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
      },
    );
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
        title: Text(LocalizedText.of(
            chs: '迁移数据', jpn: 'データの移行', eng: 'Migrate Data', kor: '데이터 이동')),
        content: Text('From:\n ${from.path}\nTo:\n${to.path}'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(S.current.cancel),
          ),
          TextButton(
            onPressed: () {
              db2.settings.useAndroidExternal = useExternal;
              db2.saveSettings();
              Navigator.of(context).pop();
              SimpleCancelOkDialog(
                title: const Text('⚠️ Warning'),
                content: Text(LocalizedText.of(
                    chs: '请手动移动数据，否则启动后为空数据。',
                    jpn: 'データを手動で移動してください。そうしないと、起動後にデータが空になります。',
                    eng:
                        'Please move the data manually, otherwise the data will be empty after startup.',
                    kor: '데이터를 수동으로 이동시켜주세요. 그렇지않으면 기동 후에 데이터가 날아가버립니다.')),
                hideCancel: true,
              ).showDialog(context);
            },
            child: Text(LocalizedText.of(
                chs: '不迁移', jpn: '移行しない', eng: 'NOT MIGRATE', kor: '이동시키지 않음')),
          ),
          TextButton(
            onPressed: () async {
              EasyLoading.show(
                  status: 'Moving...', maskType: EasyLoadingMaskType.clear);
              try {
                await _copyDirectory(from, to);
                db2.settings.useAndroidExternal = useExternal;
                Navigator.of(context).pop();
                SimpleCancelOkDialog(
                  title: const Text('⚠️ Warning'),
                  content: Text(LocalizedText.of(
                      chs: '重启以设置生效',
                      jpn: '設定を有効にするために再起動します',
                      eng: 'Restart for the settings to take effect',
                      kor: '설정을 적용 시키기 위해 재기동하여 주십시오')),
                  hideCancel: true,
                ).showDialog(context);
                db2.saveSettings();
                EasyLoading.dismiss();
              } catch (e, s) {
                logger.e('migrate android data to external failed', e, s);
                SimpleCancelOkDialog(
                  title: const Text('⚠️ ERROR'),
                  content: Text(e.toString()),
                  hideCancel: true,
                ).showDialog(context);
                EasyLoading.dismiss();
              }
            },
            child: Text(LocalizedText.of(
                chs: '迁移', jpn: '移行', eng: 'MIGRATE', kor: '이동')),
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
  List<MapEntry<String, DateTime?>> validFiles = [];

  @override
  void initState() {
    super.initState();
    listBackups();
  }

  Future<void> listBackups() async {
    if (PlatformU.isWeb) {
      for (final fp in FilePlusWeb.list()) {
        if (fp.startsWith(db2.paths.backupDir) &&
            fp.toLowerCase().contains('.json')) {
          validFiles.add(MapEntry(fp, null));
        }
      }
      validFiles.sort((a, b) => b.key.compareTo(a.key));
    } else {
      final dir = Directory(db2.paths.backupDir);
      if (await dir.exists()) {
        await for (var entry in dir.list()) {
          if (await FileSystemEntity.isFile(entry.path) &&
              entry.path.toLowerCase().contains('.json')) {
            validFiles.add(MapEntry(entry.path, (await entry.stat()).modified));
          }
        }
      }
      validFiles.sort((a, b) => b.value!.compareTo(a.value!));
    }

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
                    ? () => OpenFile.open(db2.paths.backupDir)
                    : null,
                child: Padding(
                  padding: const EdgeInsets.all(6),
                  child: Text(db2.paths.convertIosPath(db2.paths.backupDir)),
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
                  content: Text(db2.paths.convertIosPath(entry.key)),
                  onTapOk: () async {
                    try {
                      final userdata = UserData.fromJson(json
                          .decode(await FilePlus(entry.key).readAsString()));
                      db2.backupUserdata();
                      db2.userData = userdata;
                      EasyLoading.showToast(S.current.import_data_success);
                      db2.saveUserData();
                      db2.notifyDb(recalc: true);
                      db2.notifyAppUpdate();
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
