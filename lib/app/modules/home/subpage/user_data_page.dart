import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:file_picker/file_picker.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:chaldea/app/app.dart';
import 'package:chaldea/app/tools/backup_backend/chaldea_backend.dart';
import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/models/models.dart';
import 'package:chaldea/packages/file_plus/file_plus_web.dart';
import 'package:chaldea/packages/packages.dart';
import 'package:chaldea/packages/platform/platform.dart';
import 'package:chaldea/utils/utils.dart';
import 'package:chaldea/widgets/custom_dialogs.dart';
import 'package:chaldea/widgets/tile_items.dart';
import '../../import_data/home_import_page.dart';
import 'github_backup_page.dart';

class UserDataPage extends StatefulWidget {
  UserDataPage({super.key});

  @override
  _UserDataPageState createState() => _UserDataPageState();
}

class _UserDataPageState extends State<UserDataPage> {
  Map<String, String> cachedFiles = {};
  List<String> onlineVersions = [];
  final _serverBackup = ChaldeaServerBackup();

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
      appBar: AppBar(title: Text(S.current.userdata)),
      body: ListView(
        children: <Widget>[
          TileGroup(
            footer: ['All data saved here.', if (kIsWeb) 'Browser local data, may be cleared by browser!'].join('\n'),
            children: [
              // if (androidExternalDirs.length >= 2)
              //   SwitchListTile.adaptive(
              //     value: db.settings.useAndroidExternal,
              //     title: Text(S.current.app_data_use_external_storage),
              //     subtitle: Text(S.current.restart_to_apply_changes),
              //     onChanged: _migrateAndroidData,
              //   ),
              ListTile(
                title: Text(S.current.app_data_folder),
                subtitle: Text(db.paths.convertIosPath(db.paths.appPath)),
                onTap: () {
                  if (PlatformU.isWeb) {
                    EasyLoading.showInfo('Check it in IndexedDB');
                  } else if (PlatformU.isDesktop) {
                    openFile(db.paths.appPath);
                  } else {
                    EasyLoading.showInfo(S.current.open_in_file_manager);
                  }
                },
              ),
            ],
          ),
          TileGroup(
            header: S.current.userdata_sync_server,
            footer: S.current.userdata_sync_hint,
            children: [
              ListTile(title: Text(S.current.userdata_upload_backup), onTap: () => _serverBackup.backup()),
              ListTile(title: Text(S.current.userdata_download_backup), onTap: () => _serverBackup.restore()),
              if (PlatformU.isDesktop)
                SwitchListTile.adaptive(
                  title: Text(S.current.upload_before_close_app),
                  subtitle: Text('${S.current.disabled}/Removed'),
                  value: false,
                  onChanged: null,
                ),
            ],
          ),
          TileGroup(
            header: 'Github',
            children: [
              ListTile(
                title: const Text('Github Backup'),
                trailing: Icon(DirectionalIcons.keyboard_arrow_forward(context)),
                onTap: () {
                  router.pushPage(const GithubBackupPage());
                },
              ),
            ],
          ),
          TileGroup(
            header: S.current.userdata_local,
            footer: S.current.settings_userdata_footer,
            children: <Widget>[
              if (kIsWeb || PlatformU.isMobile) ListTile(title: Text(S.current.save_as), onTap: saveAsUserData),
              ListTile(title: Text(S.current.backup), onTap: backupUserData),
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
                subtitle: Text('${S.current.gallery_tab_name}-${S.current.general_import}'),
                trailing: const Icon(Icons.keyboard_arrow_right),
                enabled: db.gameData.isValid,
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
      final result = await FilePickerU.pickFiles(type: FileType.custom, allowedExtensions: ['json'], clearCache: true);
      final bytes = result?.files.first.bytes;
      if (bytes == null) return;
      final userdata = UserData.fromJson(jsonDecode(utf8.decode(bytes)));
      await db.backupUserdata();
      db.userData = userdata;
      db.saveUserData();
      EasyLoading.showToast(S.current.import_data_success);
      db.notifyAppUpdate();
    } catch (e, s) {
      logger.e('import user data failed', e, s);
      EasyLoading.showError(S.current.import_data_error(e));
    }
  }

  Future saveAsUserData() async {
    final fn = 'chaldea-userdata-${DateFormat('yyyyMMddTHHmmss').format(DateTime.now())}.json';
    final content = jsonEncode(db.userData);
    if (kIsWeb) {
      kPlatformMethods.downloadString(content, fn);
    } else if (PlatformU.isMobile) {
      final fp = joinPaths(db.paths.tempDir, fn);
      await File(fp).writeAsString(content);
      if (mounted) return ShareX.shareFile(fp, context: context);
    }
  }

  Future backupUserData() async {
    return SimpleConfirmDialog(
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
        if (!mounted) return;
        showDialog(
          context: context,
          useRootNavigator: false,
          builder:
              (context) => SimpleConfirmDialog(
                title: Text(S.current.backup),
                content: Text(hint),
                showCancel: false,
                actions: [
                  if (fps.isNotEmpty)
                    PlatformU.isDesktop
                        ? TextButton(
                          child: Text(S.current.open),
                          onPressed: () {
                            openFile(db.paths.backupDir);
                          },
                        )
                        : TextButton(
                          child: Text(S.current.share),
                          onPressed: () {
                            Navigator.of(context).pop();
                            ShareX.shareFile(fps.first, context: context);
                          },
                        ),
                ],
              ),
        );
      },
    ).showDialog(context);
  }

  // ignore: unused_element
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
      builder:
          (context) => AlertDialog(
            title: Text(S.current.migrate_external_storage_title),
            content: Text('From:\n ${from.path}\nTo:\n${to.path}'),
            actions: [
              TextButton(onPressed: () => Navigator.of(context).pop(), child: Text(S.current.cancel)),
              TextButton(
                onPressed: () async {
                  db.paths.androidUseExternalStorage = useExternal;
                  Navigator.of(context).pop();
                  SimpleConfirmDialog(
                    title: Text('⚠️ ${S.current.warning}'),
                    content: Text(S.current.migrate_external_storage_manual_warning),
                    showCancel: false,
                  ).showDialog(context);
                  final sp = await SharedPreferences.getInstance();
                  sp.setBool('android_use_external', useExternal);
                },
                child: Text(S.current.migrate_external_storage_btn_no),
              ),
              TextButton(
                onPressed: () async {
                  try {
                    Navigator.of(context).pop();
                    await showEasyLoading(() => _copyDirectory(from, to));
                    final sp = await SharedPreferences.getInstance();
                    sp.setBool('android_use_external', useExternal);
                    if (context.mounted) {
                      SimpleConfirmDialog(
                        title: const Text('⚠️ Warning'),
                        content: Text(S.current.restart_to_apply_changes),
                        showCancel: false,
                      ).showDialog(context);
                    }
                    EasyLoading.dismiss();
                  } catch (e, s) {
                    logger.e('migrate android data to external failed', e, s);
                    if (context.mounted) {
                      SimpleConfirmDialog(
                        title: const Text('⚠️ ERROR'),
                        content: Text(e.toString()),
                        showCancel: false,
                      ).showDialog(context);
                    }
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
        var newDirectory = Directory(p.join(destination.absolute.path, p.basename(entity.path)));
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
  _BackupHistoryPage();

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
    final folder = db.paths.backupDirUser;
    if (PlatformU.isWeb) {
      for (final fp in FilePlusWeb.list()) {
        if (fp.startsWith(folder) && fp.toLowerCase().contains('.json')) {
          validFiles.add(MapEntry(fp, null));
        }
      }
      validFiles.sort((a, b) => b.key.compareTo(a.key));
    } else {
      final dir = Directory(folder);
      if (await dir.exists()) {
        await for (var entry in dir.list()) {
          if (await FileSystemEntity.isFile(entry.path) && entry.path.toLowerCase().contains('.json')) {
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
                onTap: PlatformU.isDesktop ? () => openFile(db.paths.backupDirUser) : null,
                child: Padding(
                  padding: const EdgeInsets.all(6),
                  child: Text(db.paths.convertIosPath(db.paths.backupDirUser)),
                ),
              ),
            );
          }
          final entry = validFiles[index - 1];
          return ListTile(
            title: Text(p.basenameWithoutExtension(entry.key)),
            subtitle: Text('Modified: ${entry.value}'),
            trailing: Wrap(
              children: [
                IconButton(
                  icon: const Icon(Icons.restore),
                  tooltip: S.current.import_data,
                  onPressed: () {
                    SimpleConfirmDialog(
                      title: Text(S.current.import_data),
                      content: Text(db.paths.convertIosPath(entry.key)),
                      onTapOk: () async {
                        try {
                          final jsonData = jsonDecode(await FilePlus(entry.key).readAsString());
                          if (jsonData['users'] == null) {
                            EasyLoading.showError('Empty Data!');
                            return;
                          }
                          final userdata = UserData.fromJson(jsonData);
                          await db.backupUserdata();
                          db.userData = userdata;
                          EasyLoading.showToast(S.current.import_data_success);
                          db.saveUserData();
                          db.notifyAppUpdate();
                        } catch (e) {
                          EasyLoading.showError(S.current.import_data_error(e));
                        }
                      },
                    ).showDialog(context);
                  },
                ),
                if (kIsWeb)
                  IconButton(
                    onPressed: () async {
                      try {
                        kPlatformMethods.downloadFile(await FilePlus(entry.key).readAsBytes(), p.basename(entry.key));
                      } catch (e) {
                        EasyLoading.showError(e.toString());
                      }
                    },
                    icon: const Icon(Icons.save),
                    tooltip: S.current.save,
                  ),
              ],
            ),
          );
        },
        separatorBuilder: (_, _) => kDefaultDivider,
        itemCount: validFiles.length + 1,
      ),
    );
  }
}
