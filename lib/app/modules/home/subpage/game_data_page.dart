import 'dart:io';

import 'package:chaldea/app/app.dart';
import 'package:chaldea/app/tools/gamedata_loader.dart';
import 'package:chaldea/components/localized/localized_base.dart';
import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/models/db.dart';
import 'package:chaldea/modules/extras/icon_cache_manager.dart';
import 'package:chaldea/packages/platform/platform.dart';
import 'package:chaldea/utils/utils.dart';
import 'package:chaldea/widgets/widgets.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:url_launcher/url_launcher.dart';

class GameDataPage extends StatefulWidget {
  GameDataPage({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _GameDataPageState();
}

class _GameDataPageState extends State<GameDataPage> {
  final loader = GameDataLoader();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(S.current.gamedata)),
      body: ListView(
        children: [
          TileGroup(
            children: [
              ListTile(
                title: Text(S.current.version),
                subtitle: Text(S.current.gamedata),
                trailing: db2.onUserData((context, snapshot) => Text(
                      db2.gameData.version.text(true),
                      textAlign: TextAlign.end,
                    )),
              ),
              // TODO: 不兼容版本提示
              if (loader.loadedGameData != null &&
                  loader.loadedGameData!.version.timestamp >
                      db2.gameData.version.timestamp)
                ListTile(
                  title:
                      const Text('Update Available, click or restart to load'),
                  trailing: Text(
                    loader.loadedGameData!.version.text(true),
                    style: TextStyle(color: Theme.of(context).errorColor),
                    textAlign: TextAlign.end,
                  ),
                  onTap: () {
                    if (loader.loadedGameData != null) {
                      for (final child in rootRouter.appState.children) {
                        child.popAll();
                      }
                      db2.gameData = loader.loadedGameData!;
                      db2.itemCenter.init();
                      db2.notifyAppUpdate();
                      setState(() {});
                      EasyLoading.showSuccess('Updated');
                    }
                  },
                )
            ],
          ),
          TileGroup(
            header: S.current.download_source,
            footer: '用于App更新, 若国内无法连接Github',
            children: [
              SwitchListTile.adaptive(
                value: db2.settings.useProxy,
                title: const Text('Use Proxy'),
                onChanged: (v) {
                  setState(() {
                    db2.settings.useProxy = v;
                    db2.saveSettings();
                    if (kIsWeb) {
                      kPlatformMethods.setLocalStorage(
                          'useProxy', v.toString());
                    }
                  });
                },
              ),
            ],
          ),
          TileGroup(
            header: S.current.gamedata,
            footer: S.current.download_latest_gamedata_hint,
            children: <Widget>[
              SwitchListTile.adaptive(
                value: db2.settings.autoUpdateData,
                title: Text(S.current.auto_update),
                onChanged: (v) {
                  setState(() {
                    db2.settings.autoUpdateData = v;
                    db2.saveSettings();
                  });
                },
              ),
              ValueStatefulBuilder<double?>(
                  initValue: loader.progress,
                  builder: (context, state) {
                    String hint;
                    if (state.value == null) {
                      hint = 'not started';
                    } else {
                      hint = (state.value! * 100).toStringAsFixed(2) + '%';
                    }
                    if (loader.error != null) {
                      hint = loader.error!.toString();
                    }
                    return ListTile(
                      title: Text(S.current.update),
                      subtitle: Text('Progress: $hint', maxLines: 2),
                      onTap: () async {
                        loader.setOnUpdate((value) {
                          state.value = value;
                          state.updateState();
                        });
                        loader.reload(offline: false).then((value) async {
                          showDialog(
                            context: kAppKey.currentContext!,
                            builder: (context) {
                              return SimpleCancelOkDialog(
                                title: Text(S.current.update_dataset),
                                content: Text(
                                    'Current: ${db2.gameData.version.text(false)}\n'
                                    'Latest : ${value.version.text(false)}'),
                                onTapOk: () {
                                  db2.gameData = value;
                                  db2.itemCenter.calculate();
                                  db2.notifyAppUpdate();
                                },
                              );
                            },
                          );
                        }).onError((error, stackTrace) async {
                          EasyLoading.showError(
                              'Update dataset failed!\n$error');
                        }).whenComplete(() {
                          state.updateState();
                        });
                        EasyLoading.showInfo('Background Updating...');
                      },
                    );
                  }),
              ListTile(
                title: Text(LocalizedText.of(
                    chs: '下载图标',
                    jpn: 'アイコンをダウンロード',
                    eng: 'Download Icons',
                    kor: '아이콘 다운로드')),
                subtitle: const Text('Icons only'),
                onTap: downloadIcons,
              ),
              if (!PlatformU.isWeb)
                ListTile(
                  title: Text('${S.current.import_data} (dataset*.zip)'),
                  subtitle: Text(S.current.not_implemented),
                  onTap: importGamedata,
                ),
              ListTile(
                title: Text(S.current.clear_cache),
                subtitle: Text(S.current.clear_cache_hint),
                onTap: clearCache,
              ),
            ],
          ),
          TileGroup(
            header: 'TEMP',
            footer: 'Installer for Android/Windows/macOS/Linux.',
            children: [
              ListTile(
                leading: const Icon(Icons.cloud_circle, size: 28),
                title: const Text('Lanzou/woozooo'),
                subtitle: RichText(
                  text: TextSpan(
                    text: 'https://www.lanzouw.com/b01tuahmf\n',
                    style: const TextStyle(color: Colors.grey),
                    children: [
                      TextSpan(
                        text: 'password: chaldea',
                        style: TextStyle(color: Colors.redAccent[100]),
                      )
                    ],
                  ),
                ),
                horizontalTitleGap: 0,
                onTap: () {
                  launch('https://www.lanzouw.com/b01tuahmf');
                },
              ),
            ],
          )
        ],
      ),
    );
  }

  void downloadIcons() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => IconCacheManagePage(),
    );
  }

  Future<void> importGamedata() async {
    try {
      throw UnimplementedError();
    } catch (e) {
      SimpleCancelOkDialog(
        title: Text(S.current.failed),
        content: Text(e.toString()),
      ).showDialog(context);
    }
  }

  Future<void> clearCache() async {
    await DefaultCacheManager().emptyCache();
    if (!kIsWeb) {
      Directory(db2.paths.tempDir)
        ..deleteSync(recursive: true)
        ..createSync(recursive: true);
    }
    imageCache.clear();
    EasyLoading.showToast(S.current.clear_cache_finish);
  }
}
