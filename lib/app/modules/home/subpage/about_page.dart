import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'package:chaldea/app/app.dart';
import 'package:chaldea/app/tools/app_update.dart';
import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/models/db.dart';
import 'package:chaldea/packages/app_info.dart';
import 'package:chaldea/packages/platform/platform.dart';
import 'package:chaldea/utils/utils.dart';
import 'package:chaldea/widgets/widgets.dart';
import 'dev_page.dart';

class AboutPage extends StatefulWidget {
  AboutPage({super.key});

  @override
  _AboutPageState createState() => _AboutPageState();
}

class _AboutPageState extends State<AboutPage> {
  int pressTimes = 0;

  Map<String, String> get references => {
        'TYPE-MOON/FGO PROJECT': 'https://www.fate-go.jp',
        'Atlas Academy': 'https://atlasacademy.io',
        'Mooncell': 'https://fgo.wiki',
        'Fandom-fategrandorder': 'https://fategrandorder.fandom.com/wiki/',
        'NGA-FGO': 'https://bbs.nga.cn/thread.php?fid=540',
        S.current.fgo_domus_aurea: 'https://sites.google.com/view/fgo-domus-aurea',
        '茹西教王的理想鄉': 'http://kazemai.github.io/fgo-vz/'
      };
  Map<String, String> get inspiredBy => {
        "Guda@iOS": "https://ngabbs.com/read.php?tid=12082000",
        "素材规划小程序": "https://ngabbs.com/read.php?tid=12570313",
        "Teamup": "https://www.fgo-teamup.com",
      };

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final devicePixelRatio = MediaQuery.of(context).devicePixelRatio;
    return Scaffold(
      appBar: AppBar(
        title: Text(MaterialLocalizations.of(context).aboutListTileTitle(AppInfo.appName)),
        actions: [
          IconButton(
            onPressed: () {
              launch(kProjectHomepage);
            },
            icon: const FaIcon(FontAwesomeIcons.github),
            tooltip: 'view on Github',
          )
        ],
      ),
      body: ListView(
        children: <Widget>[
          InheritSelectionArea(
            child: _AboutProgram(
              name: AppInfo.appName,
              version: AppInfo.fullVersion2,
              icon: SizedBox(
                height: 120,
                child: Image.asset('res/img/launcher_icon/app_icon_logo.png', height: 120),
              ),
              legalese: 'Copyright © $kCopyrightYear cc.narumi.\nAll rights reserved.',
              debugInfo: 'UUID\n${AppInfo.uuid}\n'
                  'Size: ${size.width.toInt()}×${size.height.toInt()} [×$devicePixelRatio]',
              onDoubleTap: () {
                pressTimes += 1;
                if (pressTimes == 5) {
                  pressTimes = 0;
                  db.runtimeData.enableDebugTools = true;
                  EasyLoading.showInfo("Enabled Test Mode!");
                }
              },
              onLongPress: () async {
                setState(() {
                  db.runtimeData.enableDebugTools = true;
                  Future.delayed(const Duration(seconds: 1), db.notifyAppUpdate);
                });
                await Clipboard.setData(ClipboardData(text: AppInfo.uuid));
                EasyLoading.showToast('UUID ${S.current.copied}');
              },
            ),
          ),
          TileGroup(
            header: S.current.about_app,
            children: [
              if (!kIsWeb && !AppInfo.isMacStoreApp && (!PlatformU.isIOS || db.runtimeData.upgradableVersion != null))
                ListTile(
                  title: Text(S.current.check_update),
                  trailing: db.runtimeData.upgradableVersion != null
                      ? Text('${db.runtimeData.upgradableVersion!.versionString}↑',
                          style: const TextStyle(color: Colors.redAccent))
                      : null,
                  onTap: () async {
                    if (PlatformU.isApple) {
                      launch(kAppStoreLink);
                      return;
                    } else if (AppInfo.isFDroid) {
                      launch('https://f-droid.org/packages/$kPackageNameFDroid');
                      return;
                    }
                    AppUpdateDetail? detail = db.runtimeData.releaseDetail;
                    if (detail == null) {
                      EasyLoading.showToast('Checking update...');
                      detail = await AppUpdater.check();
                    }
                    if (detail == null) {
                      EasyLoading.showInfo('No Update Found');
                      return;
                    }
                    final update = await AppUpdater.showUpdateAlert(detail);
                    if (update != true) return;
                    EasyLoading.showInfo('Background downloading...');
                    final savePath = await AppUpdater.download(detail);
                    if (savePath == null && !PlatformU.isAndroid) {
                      EasyLoading.showError('Download app update failed');
                    }
                    final install = await AppUpdater.showInstallAlert(detail.release.version!);
                    if (install != true) return;
                    await AppUpdater.installUpdate(detail, savePath);
                  },
                ),
              if (!kIsWeb && !PlatformU.isIOS && !AppInfo.isMacStoreApp && !AppInfo.isFDroid)
                SwitchListTile.adaptive(
                  value: db.settings.autoUpdateApp,
                  title: Text(S.current.auto_update),
                  onChanged: (v) {
                    setState(() {
                      db.settings.autoUpdateApp = v;
                      db.saveSettings();
                    });
                  },
                ),
              ListTile(
                title: Text(S.current.change_log),
                onTap: () {
                  launch(ChaldeaUrl.doc('install#releases'));
                },
              ),
              ListTile(
                title: const Text('README'),
                onTap: () {
                  router.pushPage(
                    const _GithubMarkdownPage(
                      title: 'README',
                      link: '$kProjectHomepage/blob/main/README.md',
                      assetKey: 'README.md',
                    ),
                  );
                  // launch('$kProjectHomepage/blob/main/CHANGELOG.md');
                },
              ),
              ListTile(
                title: const Text('CONTRIBUTORS'),
                onTap: () {
                  router.pushPage(
                    const _GithubMarkdownPage(
                      title: 'CONTRIBUTORS',
                      link: '$kProjectHomepage/blob/main/CONTRIBUTORS',
                      assetKey: 'CONTRIBUTORS',
                      disableMd: true,
                    ),
                  );
                },
              ),
            ],
          ),
          ListTile(
            title: Text(S.current.about_app_declaration_text),
          ),
          TileGroup(
            children: [
              ListTile(
                title: const Text('Yome/FGO Simulator'),
                subtitle: const Text('https://github.com/SharpnelXu/FGOSimulator'),
                onTap: () {
                  launch('https://github.com/SharpnelXu/FGOSimulator');
                },
              )
            ],
          ),
          TileGroup(
            header: S.current.about_data_source,
            footer: S.current.about_data_source_footer,
            children: <Widget>[
              for (var ref in references.entries)
                ListTile(
                  title: Text(ref.key),
                  subtitle: AutoSizeText(ref.value, maxLines: 1),
                  onTap: () => launch(ref.value),
                ),
              const ListTile(
                title: Text('icyalala@NGA'),
                subtitle: AutoSizeText('Fate/Freedom Order data', maxLines: 1),
              ),
            ],
          ),
          TileGroup(
            header: 'Inspired by',
            children: <Widget>[
              for (var ref in inspiredBy.entries)
                ListTile(
                  title: Text(ref.key),
                  subtitle: AutoSizeText(ref.value, maxLines: 1),
                  onTap: () => launch(ref.value),
                ),
            ],
          ),
          TileGroup(
            header: 'Policy',
            children: [
              ListTile(
                title: const Text('Privacy Policy'),
                onTap: () {
                  launch(ChaldeaUrl.doc('/privacy'));
                },
              )
            ],
          ),
          TileGroup(
            header: MaterialLocalizations.of(context).licensesPageTitle,
            children: [
              ListTile(
                title: const Text('License'),
                subtitle: const Text('AGPL-3.0'),
                onTap: () {
                  router.pushPage(const _GithubMarkdownPage(
                    title: 'LICENSE',
                    link: '$kProjectHomepage/blob/main/LICENSE',
                    assetKey: 'LICENSE',
                  ));
                },
              ),
              ListTile(
                title: Text(MaterialLocalizations.of(context).viewLicensesButtonLabel),
                onTap: () {
                  Navigator.push(
                    context,
                    PageRouteBuilder(
                      pageBuilder: (context, _, __) => LicensePage(
                        applicationName: AppInfo.appName,
                        applicationVersion: AppInfo.fullVersion2,
                        applicationIcon: Image.asset(
                          'res/img/launcher_icon/app_icon_logo.png',
                          height: 120,
                        ),
                        applicationLegalese: 'Copyright © $kCopyrightYear cc.narumi.\nAll rights reserved.',
                      ),
                    ),
                  );
                },
              )
            ],
          ),
          TileGroup(
            header: 'Dev',
            children: [
              ListTile(
                title: const Text('Device Info'),
                onTap: () {
                  router.pushPage(const DevInfoPage());
                },
              )
            ],
          ),
          ListTile(
            dense: true,
            title: Text(
              kIsWeb ? kICPFilingNumberWeb : kICPFilingNumberApp,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
        ],
      ),
    );
  }
}

class _AboutProgram extends StatelessWidget {
  const _AboutProgram({
    required this.name,
    required this.version,
    this.icon,
    this.legalese,
    this.debugInfo,
    this.onLongPress,
    this.onDoubleTap,
  });

  final String name;
  final String version;
  final Widget? icon;
  final String? legalese;
  final String? debugInfo;
  final VoidCallback? onLongPress;
  final VoidCallback? onDoubleTap;

  @override
  Widget build(BuildContext context) {
    Widget child = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 24.0),
      child: Column(
        children: <Widget>[
          if (icon != null) IconTheme(data: Theme.of(context).iconTheme, child: icon!),
          Text(
            name,
            style: Theme.of(context).textTheme.headlineSmall,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 6),
          Text(
            version,
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 3),
          Text.rich(
            TextSpan(
              text: "${AppInfo.commitHash} - ${AppInfo.commitDate}",
              // recognizer: TapGestureRecognizer()
              //   ..onTap = () => launch(AppInfo.commitUrl),
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            legalese ?? '',
            style: Theme.of(context).textTheme.bodySmall,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          if (debugInfo != null) ...[
            const SizedBox(height: 12),
            Text(
              debugInfo!,
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center,
            )
          ],
          const SizedBox(width: double.infinity),
        ],
      ),
    );
    if (onLongPress != null) {
      child = InkWell(
        onLongPress: onLongPress,
        onDoubleTap: onDoubleTap,
        child: child,
      );
    }
    return Card(
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(16)),
      ),
      child: child,
    );
  }
}

class _GithubMarkdownPage extends StatelessWidget {
  final String title;
  final String? link;
  final String? assetKey;
  final bool disableMd;

  const _GithubMarkdownPage({
    required this.title,
    this.link,
    this.assetKey,
    this.disableMd = false,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: [
          if (link != null)
            IconButton(
              onPressed: () {
                launch(link!);
              },
              icon: const FaIcon(FontAwesomeIcons.github),
              tooltip: 'view on Github',
            )
        ],
      ),
      body: MyMarkdownWidget(assetKey: assetKey, disableMd: disableMd),
    );
  }
}
