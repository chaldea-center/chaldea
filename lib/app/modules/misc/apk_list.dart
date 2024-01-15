import 'package:flutter/cupertino.dart';

import 'package:dio/dio.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'package:chaldea/app/api/chaldea.dart';
import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/models/models.dart';
import 'package:chaldea/packages/language.dart';
import 'package:chaldea/utils/utils.dart';
import 'package:chaldea/widgets/widgets.dart';

class _ApkData {
  Region? region;
  String packageId;
  int bundleId;
  String countryCode;
  String? version;
  String? url;
  String? url32;
  // status
  bool loading = false;
  dynamic error;

  _ApkData(this.region, this.packageId, this.bundleId, this.countryCode);
}

class ApkListPage extends StatefulWidget {
  const ApkListPage({super.key});

  @override
  State<ApkListPage> createState() => _ApkListPageState();
}

class _ApkListPageState extends State<ApkListPage> {
  static final apks = [
    _ApkData(null, kPackageName, 1548713491, 'cn'),
    _ApkData(Region.jp, 'com.aniplex.fategrandorder', 1015521325, 'us'),
    _ApkData(Region.cn, 'com.bilibili.fatego', 1108397779, 'cn'),
    _ApkData(Region.tw, 'com.xiaomeng.fategrandorder', 1225867328, 'tw'),
    _ApkData(Region.na, 'com.aniplex.fategrandorder.en', 1183802626, 'us'),
    _ApkData(Region.kr, 'com.netmarble.fgok', 1241893973, 'kr'),
  ];

  late final _hidden = db.settings.hideApple;
  late bool proxy = db.settings.proxy.worker;
  String get apkHost => proxy ? '${HostsX.worker.kCN}/proxy' : 'https://fgo.bigcereal.com';

  @override
  void initState() {
    super.initState();
    if (apks.any((e) => e.url == null)) {
      load();
    }
  }

  void load() async {
    await Future.wait(apks.map((e) => _load(e, apkHost)).toList());
    if (mounted) setState(() {});
  }

  Future<void> _load(_ApkData data, String host) async {
    try {
      data.loading = true;
      data.error = null;
      if (mounted) setState(() {});
      String? url;
      if (data.region == Region.cn) {
        final resp = await Dio().get('https://static.biligame.com/config/fgo.config.js');
        // "android_link": "https://pkg.biligame.com/games/my-gwzdFateGO_2.57.0_1_20221227_023526_aeba0.apk",
        url = RegExp(r"""android_link["']?:\s*["']([^"']+)["']""").firstMatch(resp.data.toString())?.group(1);
        if (url != null) {
          data.url = url;
          data.version = RegExp(r'FateGO[_\-](\d+\.\d+\.\d+)[_\-]').firstMatch(url)?.group(1);
        }
      } else if (data.region != null) {
        final workerHost = HostsX.worker.of(proxy || Language.isCHS);
        final versions = await ChaldeaWorkerApi.cacheManager.getModel(
            '$workerHost/proxy/apk/current_ver.json?t=${DateTime.now().timestamp}', (v) => Map<String, String>.from(v));
        final ver = versions?[data.region!.upper];
        final ver32 = versions?['${data.region!.upper}_32'];
        if (ver != null) {
          data.version = ver;
          url = data.url = '$host/apk/${data.packageId}.v$ver.apk';
          if (ver32 != null) {
            data.url32 = '$host/apk/${data.packageId}.v$ver32.armeabi_v7a.apk';
          }
        }
      } else if (data.region == null) {
        final latestRelease = await ChaldeaWorkerApi.githubRelease('chaldea-center', 'chaldea', tag: null);
        if (latestRelease != null) {
          final ver = latestRelease.tagName!.trimCharLeft('v');
          data.version = ver;
          url = data.url = proxy
              ? '${HostsX.worker.cn}/proxy/github/github.com/chaldea-center/chaldea/releases/download/v$ver/chaldea-$ver-'
              : 'https://github.com/chaldea-center/chaldea/releases/download/v$ver/chaldea-$ver-';
        }
      }
      if (url == null) {
        data.error = 'Something went wrong';
      }
    } catch (e) {
      data.error = e;
      EasyLoading.showError('${data.region?.localName ?? "Chaldea"}: ${S.current.failed}');
    } finally {
      data.loading = false;
      if (mounted) setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final regions = {Region.jp, ...db.settings.resolvedPreferredRegions, ...Region.values}.toList();
    final _dataList = apks.toList();
    _dataList.sort2((e) => e.region == null ? -1 : regions.indexOf(e.region!));
    return Scaffold(
      appBar: AppBar(
        title: Text(_hidden ? 'App' : 'FGO APK'),
        actions: [
          IconButton(
            onPressed: () {
              launch(ChaldeaUrl.doc('fgo_apk'), external: true);
            },
            icon: const Icon(Icons.open_in_new),
          ),
          IconButton(
            onPressed: load,
            icon: const Icon(Icons.refresh),
            tooltip: S.current.refresh,
          ),
        ],
      ),
      body: _hidden
          ? const Center(child: Icon(Icons.nearby_error_rounded))
          : ListView(
              children: [
                Wrap(
                  alignment: WrapAlignment.center,
                  children: [
                    for (bool v in [false, true])
                      RadioWithLabel<bool>(
                        value: v,
                        groupValue: proxy,
                        label: Text(v ? S.current.chaldea_server_cn : S.current.chaldea_server_global),
                        onChanged: (v) {
                          setState(() {
                            if (v != null) proxy = v;
                          });
                        },
                      )
                  ],
                ),
                for (final data in _dataList) buildOne(data),
                TileGroup(
                  header: "Rayshift APK Mod",
                  footer: "Disclaimer: 3rd party modified apk, use at your own risk.",
                  children: [
                    for (final r in const ['jp', 'na'])
                      ListTile(
                        dense: true,
                        title: Text("BFGO ${r.toUpperCase()}"),
                        subtitle: Text('io.rayshift.betterfgo${r == 'jp' ? '' : ".en"}'),
                        trailing: const Icon(Icons.open_in_new, size: 18),
                        onTap: () {
                          launch('https://rayshift.io/betterfgo/download/$r', external: true);
                        },
                      )
                  ],
                ),
                const SizedBox(height: 16),
                const DividerWithTitle(title: 'Links', indent: 16, height: 16),
                TileGroup(
                  header: 'Web',
                  children: [
                    ListTile(
                      dense: true,
                      title: const Text('FGO Apk'),
                      subtitle: Text(ChaldeaUrl.doc('fgo_apk')),
                      onTap: () {
                        launch(ChaldeaUrl.doc('fgo_apk'));
                      },
                    ),
                    ListTile(
                      dense: true,
                      title: const Text('Chaldea App'),
                      subtitle: Text(ChaldeaUrl.doc('install')),
                      onTap: () {
                        launch(ChaldeaUrl.doc('install'));
                      },
                    ),
                  ],
                ),
                TileGroup(
                  header: 'Credits',
                  children: [
                    ListTile(
                      dense: true,
                      title: const Text('@Cereal'),
                      trailing: const Icon(Icons.open_in_new, size: 18),
                      onTap: () {
                        launch('https://fgo.bigcereal.com/', external: true);
                      },
                    ),
                    ListTile(
                      dense: true,
                      title: const Text('All APKs'),
                      // subtitle: Text('$apkHost/apk/'),
                      trailing: const Icon(Icons.open_in_new, size: 18),
                      onTap: () {
                        launch('$apkHost/apk/?sort=time&order=desc', external: true);
                      },
                    ),
                    ListTile(
                      dense: true,
                      title: const Text('Rayshift'),
                      trailing: const Icon(Icons.open_in_new, size: 18),
                      onTap: () {
                        launch('https://rayshift.io', external: true);
                      },
                    ),
                  ],
                )
              ],
            ),
    );
  }

  Widget buildOne(_ApkData data) {
    List<Widget> children = [];
    children.add(ListTile(
      dense: true,
      contentPadding: const EdgeInsetsDirectional.only(start: 16, end: 0),
      title: Text(data.packageId, style: Theme.of(context).textTheme.bodySmall),
      trailing: Wrap(
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          IconButton(
            onPressed: () {
              final appname = data.region == null ? 'Chaldea' : 'fate-grand-order';
              launch('https://apps.apple.com/${data.countryCode}/app/$appname/id${data.bundleId}', external: true);
            },
            icon: const FaIcon(FontAwesomeIcons.appStore),
            tooltip: 'App Store',
            iconSize: 18,
          ),
          if (data.region != Region.cn)
            IconButton(
              onPressed: () {
                launch('https://play.google.com/store/apps/details?id=${data.packageId}', external: true);
              },
              icon: const FaIcon(FontAwesomeIcons.googlePlay),
              tooltip: 'Google Play',
              iconSize: 18,
            ),
          if (data.region == Region.cn)
            IconButton(
              onPressed: () {
                launch('https://game.bilibili.com/fgo/', external: true);
              },
              icon: const FaIcon(FontAwesomeIcons.bilibili),
              tooltip: 'bilibili',
              iconSize: 18,
            ),
        ],
      ),
    ));
    if (data.region == null) {
      if (data.url != null) {
        children.addAll([
          chaldeaTile(data.version, data.url!, 'android', '.apk'),
          chaldeaTile(data.version, data.url!, 'windows', '.zip'),
          chaldeaTile(data.version, data.url!, 'linux', '.tar.gz'),
        ]);
      }
    } else {
      children.addAll([
        if (data.url != null) downloadTile(data.region, data.version, data.url!, false),
        if (data.url32 != null) downloadTile(data.region, data.version, data.url32!, true),
      ]);
    }
    if (data.error != null) {
      children.add(ListTile(
        dense: true,
        title: Text(
          '${S.current.error}: ${escapeDioException(data.error)}',
          maxLines: 3,
        ),
      ));
    }
    return TileGroup(
      headerWidget: Row(
        children: [
          Expanded(child: SHeader(data.region?.localName ?? 'Chaldea App')),
          if (data.loading)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 12),
              child: CupertinoActivityIndicator(radius: 8),
            ),
        ],
      ),
      children: children,
    );
  }

  Widget downloadTile(Region? region, String? ver, String url, bool is32) {
    List<String> titles = [
      region?.upper ?? 'Chaldea App',
      if (ver != null) 'v$ver',
      if (is32) '32-bit/v7a',
      if ((region == Region.jp || region == Region.na) && !is32) '64-bit/v8a'
    ];
    return ListTile(
      dense: true,
      contentPadding: const EdgeInsetsDirectional.only(start: 16, end: 0),
      title: Text(titles.join('  ')),
      subtitle: Text(url.breakWord, maxLines: 2, overflow: TextOverflow.ellipsis),
      onTap: () {
        launch(url, external: true);
      },
      trailing: IconButton(
        onPressed: () {
          copyToClipboard(url);
          EasyLoading.showToast([S.current.copied, url].join('\n'));
        },
        icon: const Icon(Icons.copy, size: 18),
        tooltip: S.current.copy,
      ),
    );
  }

  Widget chaldeaTile(String? ver, String url, String platform, String suffix) {
    url = url + platform + suffix;
    return ListTile(
      dense: true,
      contentPadding: const EdgeInsetsDirectional.only(start: 16, end: 0),
      title: Text('${platform.toTitle()}  v$ver'),
      subtitle: Text(url.split('/').last.breakWord, maxLines: 2, overflow: TextOverflow.ellipsis),
      onTap: () {
        launch(url, external: true);
      },
      trailing: IconButton(
        onPressed: () {
          copyToClipboard(url);
          EasyLoading.showToast([S.current.copied, url].join('\n'));
        },
        icon: const Icon(Icons.copy, size: 18),
        tooltip: S.current.copy,
      ),
    );
  }
}
