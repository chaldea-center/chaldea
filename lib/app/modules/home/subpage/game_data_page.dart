import 'dart:io';

import 'package:flutter/foundation.dart';

import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

import 'package:chaldea/app/api/atlas.dart';
import 'package:chaldea/app/tools/gamedata_loader.dart';
import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/models/db.dart';
import 'package:chaldea/packages/platform/platform.dart';
import 'package:chaldea/utils/utils.dart';
import 'package:chaldea/widgets/widgets.dart';
import '../../../tools/icon_cache_manager.dart';

class GameDataPage extends StatefulWidget {
  GameDataPage({super.key});

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
              ValueListenableBuilder<double?>(
                  valueListenable: loader.progress,
                  builder: (context, progress, child) {
                    String hint;
                    if (progress == null) {
                      hint = 'not started';
                    } else {
                      hint = '${(progress * 100).toStringAsFixed(2)}%';
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
                        EasyLoading.showInfo('Background Updating...');
                        final data = await loader.fetchUpdates(rtnData: true);
                        if (data == null) return;
                        if (!data.isValid) {
                          EasyLoading.showError("Invalid game data");
                          return;
                        }
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
                              onTapOk: () async {
                                db.gameData = data;
                                await loader.fetchNewCards(silent: true);
                                db.notifyAppUpdate();
                              },
                            );
                          },
                        );
                      },
                    );
                  }),
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
              SwitchListTile.adaptive(
                value: kIsWeb
                    ? db.settings.autoUpdateData
                    : db.settings.updateDataBeforeStart,
                title: Text(S.current.update_data_at_start),
                subtitle: Text(
                  db.settings.updateDataBeforeStart
                      ? S.current.update_data_at_start_on_hint
                      : S.current.update_data_at_start_off_hint,
                  textScaleFactor: 0.8,
                ),
                onChanged: !kIsWeb && db.settings.autoUpdateData
                    ? (v) {
                        setState(() {
                          db.settings.updateDataBeforeStart = v;
                          db.saveSettings();
                        });
                      }
                    : null,
              ),
              SwitchListTile.adaptive(
                value: db.settings.checkDataHash,
                title: Text(S.current.check_file_hash),
                onChanged: (v) {
                  setState(() {
                    db.settings.checkDataHash = v;
                    db.saveSettings();
                  });
                },
              ),
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
                onTap: () => showDialog(
                  context: context,
                  useRootNavigator: false,
                  builder: (context) => const _ClearCacheDialog(),
                ),
              ),
            ],
          ),
          TileGroup(
            header: 'TEMP',
            footer: 'Installer for Android/Windows/Linux.',
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
}

class _ClearCacheDialog extends StatefulWidget {
  const _ClearCacheDialog();

  @override
  State<_ClearCacheDialog> createState() => __ClearCacheDialogState();
}

class __ClearCacheDialogState extends State<_ClearCacheDialog> {
  bool memory = true;
  bool app = false;
  final bool atlas = false;
  bool temp = false;

  @override
  Widget build(BuildContext context) {
    return SimpleCancelOkDialog(
      title: Text(S.current.clear_cache),
      confirmText: S.current.clear,
      scrollable: true,
      content: Column(
        children: [
          CheckboxListTile(
            dense: true,
            contentPadding: EdgeInsets.zero,
            value: memory,
            controlAffinity: ListTileControlAffinity.leading,
            title: const Text('Memory Cache'),
            onChanged: (v) {
              setState(() {
                memory = !memory;
              });
            },
          ),
          CheckboxListTile(
            dense: true,
            contentPadding: EdgeInsets.zero,
            value: temp,
            controlAffinity: ListTileControlAffinity.leading,
            title: const Text('Temp Directory'),
            subtitle: Text(db.paths.convertIosPath(db.paths.tempDir)),
            onChanged: (v) {
              setState(() {
                temp = !temp;
              });
            },
          ),
          CheckboxListTile(
            dense: true,
            contentPadding: EdgeInsets.zero,
            value: app,
            controlAffinity: ListTileControlAffinity.leading,
            title: const Text('Image Cache'),
            subtitle:
                const Text('Network images, including event/summon banners'),
            onChanged: (v) {
              setState(() {
                app = !app;
              });
            },
          ),
          CheckboxListTile(
            dense: true,
            contentPadding: EdgeInsets.zero,
            value: atlas,
            controlAffinity: ListTileControlAffinity.leading,
            title: const Text('Game Assets'),
            subtitle: Text(db.paths.convertIosPath(db.paths.atlasAssetsDir)),
            onChanged: null,
          ),
        ],
      ),
      onTapOk: () async {
        if (memory) {
          AtlasIconLoader.i.clearAll();
          imageCache.clear();
          await AtlasApi.clear();
        }
        if (app) {
          await DefaultCacheManager().emptyCache();
          await ImageViewerCacheManager().emptyCache();
        }
        if (temp) {
          await AtlasApi.clear();
          if (!kIsWeb) {
            Directory(db.paths.tempDir)
              ..deleteSync(recursive: true)
              ..createSync(recursive: true);
          }
        }
        if (atlas) {
          //
        }
        EasyLoading.showToast(S.current.clear_cache_finish);
      },
    );
  }
}
