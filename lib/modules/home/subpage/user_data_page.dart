import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:chaldea/components/components.dart';
import 'package:chaldea/modules/home/subpage/login_page.dart';
import 'package:file_picker_cross/file_picker_cross.dart';
import 'package:open_file/open_file.dart';
import 'package:share/share.dart';

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
                subtitle: Text(db.paths.userDataBackupDir),
                onTap: backupUserData,
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
                  onTap: () {
                    OpenFile.open(db.paths.appPath);
                  },
                )
            ],
          ),
          TileGroup(
            header: S.current.userdata_sync + '(Server)',
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
      final path = result.path;
      db.userData =
          UserData.fromJson(json.decode(File(path).readAsStringSync()));
      EasyLoading.showToast('${S.current.import_data_success}:\n$path');
      db.saveUserData();
      db.notifyDbUpdate(true);
    } on FileSelectionCanceledError {} catch (e) {
      EasyLoading.showError(S.of(context).import_data_error(e));
    }
  }

  Future backupUserData() async {
    List<String> backupPaths = [
      Platform.isIOS ? S.of(context).ios_app_path + '/user' : db.paths.userDir
    ];
    if (db.paths.externalAppPath != null) {
      backupPaths.add(db.paths.externalAppPath!);
    }
    return SimpleCancelOkDialog(
      title: Text(S.of(context).backup),
      content: Text(backupPaths.join('\n\n')),
      onTapOk: () async {
        final fps = db.backupUserdata();
        String hint = '';
        if (fps.isEmpty) {
          hint += '备份失败';
        } else {
          hint += '临时备份已保存于：\n${fps[0]}\n';
          if (fps.length >= 2) {
            hint += '外部备份已保存于：\n${fps[0]}\n';
          }
          hint += '删除应用(以及升级时可能)将导致临时备份被删除，建议手动备份到外部可靠储存位置！';
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
        var rawResp = await db.serverDio.post('/user/uploadBackup', data: {
          HttpParamKeys.username: db.prefs.userName.get(),
          HttpParamKeys.password: db.prefs.userPwd.get(),
          HttpParamKeys.body: jsonEncode(db.userData),
        });
        final resp = ChaldeaResponse.fromResponse(rawResp.data);
        if (!resp.success) {
          resp.showMsg(context);
          return;
        }
      },
      onSuccess: () => EasyLoading.showSuccess('Uploaded'),
      onError: (e, s) => EasyLoading.showError(e.toString()),
    );
  }

  Future<void> downloadFromServer() async {
    if (!checkUserPwd()) return;
    await catchErrorAsync(
      () async {
        var rawResp = await db.serverDio.post('/user/listBackups', data: {
          HttpParamKeys.username: db.prefs.userName.get(),
          HttpParamKeys.password: db.prefs.userPwd.get(),
        });
        final resp = ChaldeaResponse.fromResponse(rawResp.data);
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
        var rawResp2 = await db.serverDio.post('/user/downloadBackup', data: {
          HttpParamKeys.username: db.prefs.userName.get(),
          HttpParamKeys.password: db.prefs.userPwd.get(),
          'bak': fn,
        });
        final resp2 = ChaldeaResponse.fromResponse(rawResp2.data);
        if (!resp2.success) {
          resp2.showMsg(context);
          return;
        }
        final userdata = UserData.fromJson(jsonDecode(resp2.body));
        db.backupUserdata(disk: true, memory: true);
        db.loadUserData(userdata);
        db.saveUserData();
        db.itemStat.update();
        db.notifyAppUpdate();
        EasyLoading.showSuccess('Import $fn');
      },
      onError: (e, s) => EasyLoading.showError(e.toString()),
    );
  }
}
