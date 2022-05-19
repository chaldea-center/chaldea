import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';

import 'package:archive/archive.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:open_file/open_file.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import 'package:chaldea/app/api/chaldea.dart';
import 'package:chaldea/app/app.dart';
import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/models/api/recognizer.dart';
import 'package:chaldea/models/models.dart';
import 'package:chaldea/packages/file_plus/file_plus_web.dart';
import 'package:chaldea/packages/packages.dart';
import 'package:chaldea/utils/utils.dart';
import 'package:chaldea/widgets/custom_dialogs.dart';
import 'package:chaldea/widgets/tile_items.dart';
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
                  value: db.settings.useAndroidExternal,
                  title: Text(S.current.app_data_use_external_storage),
                  subtitle: Text(S.current.restart_to_apply_changes),
                  onChanged: _migrateAndroidData,
                ),
              ListTile(
                title: Text(S.current.app_data_folder),
                subtitle: Text(db.paths.convertIosPath(db.paths.appPath)),
                onTap: () {
                  if (PlatformU.isWeb) {
                    EasyLoading.showInfo('Check it in IndexedDB');
                  } else if (PlatformU.isDesktop) {
                    OpenFile.open(db.paths.appPath);
                  } else {
                    EasyLoading.showInfo(S.current.open_in_file_manager);
                  }
                },
              )
            ],
          ),
          TileGroup(
            header: S.current.userdata_sync_server,
            footer: S.current.userdata_sync_hint,
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
            header: S.current.userdata_local,
            footer: S.current.settings_userdata_footer,
            children: <Widget>[
              ListTile(
                title: Text(S.current.backup),
                onTap: backupUserData,
              ),
              ListTile(
                title: Text(S.current.backup_history),
                trailing: const Icon(Icons.keyboard_arrow_right),
                onTap: () {
                  router.pushPage(_BackupHistoryPage());
                },
              ),
              ListTile(
                title: Text(S.current.import_backup),
                subtitle: const Text('userdata.json/*.json'),
                onTap: importUserData,
              ),
              ListTile(
                title: Text(S.current.import_userdata_more),
                trailing: const Icon(Icons.keyboard_arrow_right),
                onTap: () {
                  router.pushPage(ImportPageHome(), detail: false);
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
      await db.backupUserdata();
      db.userData = userdata;
      db.saveUserData();
      EasyLoading.showToast(S.current.import_data_success);
      db.notifyDb();
      db.notifyAppUpdate();
    } catch (e, s) {
      logger.e('import user data failed', e, s);
      EasyLoading.showError(S.of(context).import_data_error(e));
    }
  }

  Future backupUserData() async {
    return SimpleCancelOkDialog(
      title: Text(S.current.backup),
      content: Text(db.paths.convertIosPath(db.paths.backupDir)),
      onTapOk: () async {
        final fps = await db.backupUserdata();
        String hint = '';
        if (fps.isEmpty) {
          hint += S.current.backup_failed;
        } else {
          hint += '${fps[0]}\n';
        }
        showDialog(
          context: context,
          useRootNavigator: false,
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
                    OpenFile.open(db.paths.backupDir);
                  },
                ),
            ],
          ),
        );
      },
    ).showDialog(context);
  }

  bool checkUserPwd() {
    if (db.security.get('chaldea_user') == null ||
        db.security.get('chaldea_auth') == null) {
      SimpleCancelOkDialog(
        content: Text(S.current.login_first_hint),
        onTapOk: () {
          router.pushPage(LoginPage());
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
            GZipEncoder().encode(utf8.encode(jsonEncode(db.userData)))!);
        return dio.post('/account/backup/upload', data: {
          'username': db.security.get('chaldea_user'),
          'auth': db.security.get('chaldea_auth'),
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
        'username': db.security.get('chaldea_user'),
        'auth': db.security.get('chaldea_auth')
      }),
      onSuccess: (resp) {
        List<UserDataBackup> backups = [];
        try {
          backups = List.from(resp.body())
              .map((e) => UserDataBackup.fromJson(e))
              .toList();
          backups.sort2((e) => e.timestamp, reversed: true);
        } catch (e, s) {
          logger.e('decode server backup response failed', e, s);
          EasyLoading.showError(e.toString());
          return;
        }

        showDialog(
          context: context,
          useRootNavigator: false,
          builder: (context) {
            List<Widget> children = [];
            if (backups.isEmpty) {
              children.add(const ListTile(title: Text('No backup found')));
            }
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
                        Navigator.pop(context);
                        db.userData = backup.content!;
                        db.itemCenter.init();
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
      useRootNavigator: false,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text(S.current.migrate_external_storage_title),
        content: Text('From:\n ${from.path}\nTo:\n${to.path}'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(S.current.cancel),
          ),
          TextButton(
            onPressed: () {
              db.settings.useAndroidExternal = useExternal;
              db.saveSettings();
              Navigator.of(context).pop();
              SimpleCancelOkDialog(
                title: Text('⚠️ ${S.current.warning}'),
                content:
                    Text(S.current.migrate_external_storage_manual_warning),
                hideCancel: true,
              ).showDialog(context);
            },
            child: Text(S.current.migrate_external_storage_btn_no),
          ),
          TextButton(
            onPressed: () async {
              EasyLoading.show(
                  status: 'Moving...', maskType: EasyLoadingMaskType.clear);
              try {
                Navigator.of(context).pop();
                await _copyDirectory(from, to);
                db.settings.useAndroidExternal = useExternal;
                if (mounted) {
                  SimpleCancelOkDialog(
                    title: const Text('⚠️ Warning'),
                    content: Text(S.current.restart_to_apply_changes),
                    hideCancel: true,
                  ).showDialog(context);
                }
                db.saveSettings();
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
            child: Text(S.current.migrate_external_storage_btn_yes),
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
        if (fp.startsWith(db.paths.backupDir) &&
            fp.toLowerCase().contains('.json')) {
          validFiles.add(MapEntry(fp, null));
        }
      }
      validFiles.sort((a, b) => b.key.compareTo(a.key));
    } else {
      final dir = Directory(db.paths.backupDir);
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
                    ? () => OpenFile.open(db.paths.backupDir)
                    : null,
                child: Padding(
                  padding: const EdgeInsets.all(6),
                  child: Text(db.paths.convertIosPath(db.paths.backupDir)),
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
                  onTapOk: () async {
                    try {
                      final userdata = UserData.fromJson(json
                          .decode(await FilePlus(entry.key).readAsString()));
                      await db.backupUserdata();
                      db.userData = userdata;
                      EasyLoading.showToast(S.current.import_data_success);
                      db.saveUserData();
                      db.notifyDb(recalc: true);
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
