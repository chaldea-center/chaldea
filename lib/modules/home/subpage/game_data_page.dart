import 'dart:convert';

import 'package:chaldea/components/components.dart';
import 'package:chaldea/modules/extras/icon_cache_manager.dart';
import 'package:chaldea/modules/extras/updates.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:path/path.dart' as pathlib;

class GameDataPage extends StatefulWidget {
  GameDataPage({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _GameDataPageState();
}

class _GameDataPageState extends State<GameDataPage> {
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
                trailing: Text(db.gameData.version),
              ),
              if (db.runtimeData.latestDatasetVersion != null)
                ListTile(
                  title: Text(LocalizedText.of(
                      chs: '最新版本',
                      jpn: '最新バージョン ',
                      eng: 'Latest Version',
                      kor: '최신 버전')),
                  subtitle: db.runtimeData.latestDatasetVersion!.minimalApp >
                          AppInfo.version
                      ? Text(LocalizedText.of(
                          chs: '需要升级APP',
                          jpn: 'APPをアップグレードする必要があります',
                          eng: 'Need to upgrade APP',
                          kor: '앱을 업데이트 해야합니다'))
                      : null,
                  trailing: Text(
                    db.runtimeData.latestDatasetVersion!.readable,
                    style: TextStyle(color: Theme.of(context).errorColor),
                  ),
                )
            ],
          ),
          TileGroup(
            header: S.current.download_source,
            footer: LocalizedText.of(
                chs: '用于数据包&APP更新',
                jpn: 'データとAPPの更新に使用',
                eng: 'Used for dataset & APP update',
                kor: '데이터를 앱의 갱신에 사용'),
            children: [
              sourceAccordion(
                source: GitSource.server,
                subtitle: LocalizedText.of(
                    chs: '建议仅国内不能连接Github时使用',
                    jpn: 'Githubにアクセスできない場合のみ',
                    eng: 'Only when you cannot access Github',
                    kor: 'Github에 액세스가 불가능할 경우에만'),
                hideContent: true,
              ),
              sourceAccordion(
                source: GitSource.github,
                subtitle: LocalizedText.of(
                    chs: '国内可能连不上',
                    jpn: '推奨されます',
                    eng: 'Suggested',
                    kor: '제안하기'),
              ),
              sourceAccordion(
                source: GitSource.gitee,
                subtitle: LocalizedText.of(
                    chs: '暂不作为应用内下载源，仍可手动下载',
                    jpn: '現在、アプリ内ダウンロードソースとして使用されていません',
                    eng: 'In-app download source is disabled',
                    kor: '현재, 앱 내 다운로드 소스로써 사용되지않습니다'),
                disabled: true,
              ),
            ],
          ),
          TileGroup(
            header: S.current.gamedata,
            footer: S.current.download_latest_gamedata_hint,
            children: <Widget>[
              SwitchListTile.adaptive(
                value: db.appSetting.autoUpdateDataset,
                title: Text(S.current.auto_update),
                onChanged: (v) {
                  setState(() {
                    db.appSetting.autoUpdateDataset = v;
                  });
                },
              ),
              ListTile(
                title: Text(S.current.patch_gamedata),
                subtitle: Text(S.current.patch_gamedata_hint),
                onTap: () async {
                  await AutoUpdateUtil.patchGameData(
                    background: false,
                    onError: (e, s) {
                      SimpleCancelOkDialog(
                        content: Text(e.toString()),
                        hideCancel: true,
                      ).showDialog(context);
                    },
                  );
                  if (mounted) setState(() {});
                },
              ),
              ListTile(
                title: Text(S.current.download_full_gamedata),
                subtitle: Text(S.current.download_full_gamedata_hint),
                onTap: downloadGamedata,
              ),
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
                  title: Text('${S.of(context).import_data} (dataset*.zip)'),
                  onTap: importGamedata,
                ),
              ListTile(
                title: Text(S.current.reload_default_gamedata),
                onTap: () {
                  SimpleCancelOkDialog(
                    title: Text(S.current.reload_default_gamedata),
                    onTapOk: () async {
                      EasyLoading.show(
                          status: 'reloading',
                          maskType: EasyLoadingMaskType.clear);
                      try {
                        await db.loadZipAssets(kDatasetAssetKey);
                        if (await db.loadGameData()) {
                          await EasyLoading.showSuccess(
                              S.current.reload_data_success);
                        } else {
                          await EasyLoading.showError('Failed');
                        }
                      } catch (e) {
                        await EasyLoading.showError('Error');
                      } finally {
                        EasyLoadingUtil.dismiss();
                      }
                    },
                  ).showDialog(context);
                },
              ),
              ListTile(
                title: Text(S.of(context).clear_cache),
                subtitle: Text(S.of(context).clear_cache_hint),
                onTap: clearCache,
              ),
            ],
          ),
          TileGroup(
            header: 'TEMP',
            footer: 'Installer for Android/Windows/macOS.',
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
                  jumpToExternalLinkAlert(
                      url: 'https://www.lanzouw.com/b01tuahmf');
                },
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget sourceAccordion({
    required GitSource source,
    String? subtitle,
    bool hideContent = false,
    bool disabled = false,
  }) {
    final gitTool = GitTool(source);
    Widget radio = RadioListTile<int>(
      value: source.toIndex(),
      groupValue: db.appSetting.downloadSource,
      title: Text(source.toTitleString()),
      subtitle: subtitle == null ? null : Text(subtitle),
      onChanged: disabled
          ? null
          : (v) {
              setState(() {
                if (v != null) {
                  db.appSetting.downloadSource = v;
                  db.notifyDbUpdate();
                }
              });
            },
      controlAffinity: ListTileControlAffinity.leading,
    );
    if (hideContent) return radio;
    return SimpleAccordion(
      canTapOnHeader: false,
      headerBuilder: (context, expanded) => radio,
      contentBuilder: (context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTile(
              leading: Icon(source == GitSource.github
                  ? FontAwesomeIcons.github
                  : FontAwesomeIcons.gitAlt),
              dense: true,
              contentPadding: const EdgeInsets.only(left: 20, right: 8),
              // horizontalTitleGap: 0,
              title: const Text('Chaldea app'),
              subtitle: Text(gitTool.appReleaseUrl),
              onTap: () {
                jumpToExternalLinkAlert(url: gitTool.appReleaseUrl);
              },
            ),
            ListTile(
              leading: Icon(source == GitSource.github
                  ? FontAwesomeIcons.github
                  : FontAwesomeIcons.gitAlt),
              dense: true,
              contentPadding: const EdgeInsets.only(left: 20, right: 8),
              // horizontalTitleGap: 0,
              title: const Text('Dataset'),
              subtitle: Text(gitTool.datasetReleaseUrl),
              onTap: () {
                jumpToExternalLinkAlert(url: gitTool.datasetReleaseUrl);
              },
            ),
            ListTile(
              leading: Icon(source == GitSource.github
                  ? FontAwesomeIcons.github
                  : FontAwesomeIcons.gitAlt),
              dense: true,
              contentPadding: const EdgeInsets.only(left: 20, right: 8),
              // horizontalTitleGap: 0,
              title: const Text('FFO data'),
              subtitle: Text(gitTool.ffoDataReleaseUrl),
              onTap: () {
                jumpToExternalLinkAlert(url: gitTool.ffoDataReleaseUrl);
              },
            ),
          ],
        );
      },
    );
  }

  void downloadGamedata() async {
    final gitTool = GitTool.fromDb();

    EasyLoading.show(maskType: EasyLoadingMaskType.clear);
    final release = await gitTool.latestDatasetRelease(icons: false);
    EasyLoading.dismiss();
    String fp = pathlib.join(
        db.paths.tempDir, '${release?.name}-${release?.targetAsset?.name}');
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => DownloadDialog(
        url: release?.targetAsset?.browserDownloadUrl ?? '',
        savePath: fp,
        notes: release?.body,
        confirmText: S.of(context).import_data.toUpperCase(),
        onComplete: () async {
          EasyLoading.show(status: 'loading');
          try {
            await db.extractZip(fp: fp, savePath: db.paths.gameDir);
            if (!await db.loadGameData()) {
              throw 'Load GameData failed, maybe incompatible with current app version';
            }
            Navigator.of(context).pop();
            EasyLoading.showSuccess(S.of(context).import_data_success);
          } catch (e) {
            EasyLoading.showError(S.of(context).import_data_error(e));
          } finally {
            EasyLoadingUtil.dismiss();
          }
        },
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
      // final result = await FilePicker.platform.pickFiles();
      final result = await FilePicker.platform
          .pickFiles(type: FileType.custom, allowedExtensions: ['zip', 'json']);
      if (result == null) return;
      final file = File(result.paths.single!);
      if (file.path.toLowerCase().endsWith('.zip')) {
        EasyLoading.show(
            status: 'loading', maskType: EasyLoadingMaskType.clear);
        await db.extractZip(fp: file.path, savePath: db.paths.gameDir);
        if (!await db.loadGameData()) {
          throw 'Load GameData failed, maybe incompatible with current app version';
        }
      } else if (file.path.toLowerCase().endsWith('.json')) {
        final newData = GameData.fromJson(jsonDecode(file.readAsStringSync()));
        if (newData.version != '0') {
          db.gameData = newData;
        } else {
          throw const FormatException('Invalid json contents');
        }
      } else {
        throw const FormatException('unsupported file type');
      }
      EasyLoading.showSuccess(S.of(context).import_data_success);
    } catch (e) {
      showInformDialog(context,
          title: 'Import gamedata failed!', content: e.toString());
    } finally {
      EasyLoadingUtil.dismiss();
    }
  }

  Future<void> clearCache() async {
    await DefaultCacheManager().emptyCache();
    await WikiUtil.clear();
    Directory(db.paths.tempDir)
      ..deleteSync(recursive: true)
      ..createSync(recursive: true);
    imageCache?.clear();
    EasyLoading.showToast(S.current.clear_cache_finish);
  }
}
