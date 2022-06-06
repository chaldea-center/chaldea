import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

import 'package:chaldea/app/tools/gamedata_loader.dart';
import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/models/db.dart';
import 'package:chaldea/packages/platform/platform.dart';
import 'package:chaldea/utils/utils.dart';
import 'package:chaldea/widgets/widgets.dart';
import '../../../tools/icon_cache_manager.dart';

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
                trailing: db.onUserData(
                  (context, snapshot) => Text(
                    db.gameData.version.text(true),
                    textAlign: TextAlign.end,
                  ),
                ),
              ),
              ListTile(
                title: Text(S.current.fgo_domus_aurea),
                trailing: db.onUserData(
                  (context, snapshot) => Text(
                    db.gameData.dropRate.updatedAt.sec2date().toDateString(),
                  ),
                ),
              ),
            ],
          ),
          TileGroup(
            header: S.current.gamedata,
            footer: S.current.download_latest_gamedata_hint,
            children: <Widget>[
              SwitchListTile.adaptive(
                value: db.settings.autoUpdateData,
                title: Text(S.current.auto_update),
                onChanged: (v) {
                  setState(() {
                    db.settings.autoUpdateData = v;
                    db.saveSettings();
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
                      hint = '${(state.value! * 100).toStringAsFixed(2)}%';
                    }
                    if (loader.error != null) {
                      hint = loader.error!.toString();
                    }
                    String? newVersion;
                    if (db.runtimeData.upgradableDataVersion != null &&
                        db.runtimeData.upgradableDataVersion!.timestamp >
                            db.gameData.version.timestamp) {
                      newVersion = db.runtimeData.upgradableDataVersion!.text();
                    }
                    return ListTile(
                      title: Text(S.current.update),
                      subtitle: Text('Progress: $hint', maxLines: 2),
                      trailing: newVersion?.toText(textAlign: TextAlign.end),
                      onTap: () async {
                        loader.setOnUpdate((value) {
                          state.value = value;
                          state.updateState();
                        });
                        EasyLoading.showInfo('Background Updating...');
                        final data = await loader.reload(offline: false);
                        if (data == null) return;
                        showDialog(
                          context: kAppKey.currentContext!,
                          useRootNavigator: false,
                          builder: (context) {
                            return SimpleCancelOkDialog(
                              title: Text(S.current.update_dataset),
                              content: Text(
                                  'Current: ${db.gameData.version.text(false)}\n'
                                  'Latest : ${data.version.text(false)}'),
                              hideOk: data.version.timestamp <=
                                  db.gameData.version.timestamp,
                              onTapOk: () {
                                db.gameData = data;
                                db.itemCenter.init();
                                db.notifyAppUpdate();
                              },
                            );
                          },
                        );
                        state.updateState();
                      },
                    );
                  }),
              // if (!PlatformU.isWeb)
              //   ListTile(
              //     title: Text(S.current.import_data),
              //     subtitle: Text(S.current.not_implemented),
              //     onTap: importGamedata,
              //   ),
              if (!PlatformU.isWeb)
                ListTile(
                  title: Text(S.current.cache_icons),
                  onTap: () {
                    showDialog(
                      context: context,
                      barrierDismissible: false,
                      useRootNavigator: false,
                      builder: (context) => IconCacheManagePage(),
                    );
                  },
                ),
              ListTile(
                title: Text(S.current.clear_cache),
                // subtitle: Text(S.current.clear_cache_hint),
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
                subtitle: Text.rich(
                  TextSpan(
                    text: 'https://www.lanzouw.com/b01tuahmf\n',
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
    AtlasIconLoader.i.clearFailed();
    await DefaultCacheManager().emptyCache();
    if (!kIsWeb) {
      Directory(db.paths.tempDir)
        ..deleteSync(recursive: true)
        ..createSync(recursive: true);
    }
    imageCache.clear();
    EasyLoading.showToast(S.current.clear_cache_finish);
  }
}
