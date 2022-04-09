import 'package:auto_size_text/auto_size_text.dart';
import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/models/db.dart';
import 'package:chaldea/packages/app_info.dart';
import 'package:chaldea/packages/platform/platform.dart';
import 'package:chaldea/packages/split_route/split_route.dart';
import 'package:chaldea/utils/constants.dart';
import 'package:chaldea/widgets/markdown_page.dart';
import 'package:chaldea/widgets/tile_items.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutPage extends StatefulWidget {
  AboutPage({Key? key}) : super(key: key);

  @override
  _AboutPageState createState() => _AboutPageState();
}

class _AboutPageState extends State<AboutPage> {
  bool showDebugInfo = false;

  Map<String, String> get references => {
        'TYPE-MOON/FGO PROJECT': 'https://www.fate-go.jp',
        'Mooncell': 'https://fgo.wiki',
        'Fandom-fategrandorder': 'https://fategrandorder.fandom.com/wiki/',
        'Atlas Academy': 'https://atlasacademy.io',
        'NGA-FGO': 'https://bbs.nga.cn/thread.php?fid=540',
        S.current.fgo_domus_aurea:
            'https://sites.google.com/view/fgo-domus-aurea',
        '茹西教王的理想鄉': 'http://kazemai.github.io/fgo-vz/'
      };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(MaterialLocalizations.of(context)
            .aboutListTileTitle(AppInfo.appName)),
      ),
      body: ListView(
        children: <Widget>[
          GestureDetector(
            onDoubleTap: () {
              setState(() {
                showDebugInfo = true;
              });
            },
            onLongPress: () async {
              setState(() {
                showDebugInfo = true;
                db2.runtimeData.enableDebugTools = true;
              });
              await Clipboard.setData(ClipboardData(text: AppInfo.uuid));
              EasyLoading.showToast('UUID ' + S.current.copied);
            },
            child: _AboutProgram(
              name: AppInfo.appName,
              version: AppInfo.fullVersion2,
              icon: SizedBox(
                height: 120,
                child: Image.asset('res/img/launcher_icon/app_icon_logo.png',
                    height: 120),
              ),
              legalese: 'Copyright © 2022 cc.narumi.\nAll rights reserved.',
              debugInfo: showDebugInfo
                  ? 'UUID\n${AppInfo.uuid}\n'
                      'Width: ${MediaQuery.of(context).size.width}'
                  : null,
            ),
          ),
          TileGroup(
            header: S.current.update,
            children: [
              if (!AppInfo.isMacStoreApp &&
                  (!PlatformU.isIOS ||
                      db2.runtimeData.upgradableVersion != null))
                ListTile(
                  title: Text(S.current.check_update),
                  trailing: db2.runtimeData.upgradableVersion != null
                      ? Text(
                          db2.runtimeData.upgradableVersion!.versionString +
                              '↑',
                          style: const TextStyle(color: Colors.redAccent))
                      : null,
                  onTap: () {
                    EasyLoading.showInfo('NotImplemented');
                  },
                ),
              if (!PlatformU.isIOS && !AppInfo.isMacStoreApp)
                SwitchListTile.adaptive(
                  value: db2.settings.autoUpdateApp,
                  title: Text(S.current.auto_update),
                  onChanged: (v) {
                    setState(() {
                      db2.settings.autoUpdateApp = v;
                      db2.saveSettings();
                    });
                  },
                ),
              ListTile(
                title: const Text('README'),
                onTap: () async {
                  SplitRoute.push(
                    context,
                    const _GithubMarkdownPage(
                      title: 'README',
                      link: '$kProjectHomepage/blob/master/README.md',
                      assetKey: 'README.md',
                    ),
                  );
                  // launch('$kProjectHomepage/blob/master/CHANGELOG.md');
                },
              ),
              ListTile(
                title: Text(S.current.change_log),
                onTap: () async {
                  SplitRoute.push(
                    context,
                    _GithubMarkdownPage(
                      title: S.current.change_log,
                      link: '$kProjectHomepage/blob/master/CHANGELOG.md',
                      assetKey: 'CHANGELOG.md',
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
              ListTile(
                title: const Text("Fandom & Reddit Translators"),
                subtitle: const Text('English Communities'),
                onTap: () {
                  SplitRoute.push(
                    context,
                    _FandomContributorsPage(),
                    detail: true,
                  );
                },
              ),
              const ListTile(
                title: Text('M.Gallery & Cafe Translators'),
                subtitle: Text('Korean Communities'),
              ),
            ],
          ),
          TileGroup(
            header: MaterialLocalizations.of(context).licensesPageTitle,
            children: [
              ListTile(
                title: const Text('License'),
                subtitle: const Text('AGPL-3.0'),
                onTap: () {
                  SplitRoute.push(
                      context,
                      const _GithubMarkdownPage(
                        title: 'LICENSE',
                        link: '$kProjectHomepage/blob/master/LICENSE',
                        assetKey: 'LICENSE',
                      ));
                },
              ),
              ListTile(
                title: Text(
                    MaterialLocalizations.of(context).viewLicensesButtonLabel),
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
                        applicationLegalese:
                            'Copyright © 2022 cc.narumi.\nAll rights reserved.',
                      ),
                    ),
                  );
                },
              )
            ],
          )
        ],
      ),
    );
  }
}

class _AboutProgram extends StatelessWidget {
  const _AboutProgram({
    Key? key,
    required this.name,
    required this.version,
    this.icon,
    this.legalese,
    this.debugInfo,
  }) : super(key: key);

  final String name;
  final String version;
  final Widget? icon;
  final String? legalese;
  final String? debugInfo;

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(16)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 24.0),
        child: Column(
          children: <Widget>[
            if (icon != null)
              IconTheme(data: Theme.of(context).iconTheme, child: icon!),
            Text(
              name,
              style: Theme.of(context).textTheme.headline5,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 6),
            Text(
              version,
              style: Theme.of(context).textTheme.bodyText2,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 3),
            Text.rich(
              TextSpan(
                text: "${AppInfo.commmitHash} - ${AppInfo.commitDate}",
                recognizer: TapGestureRecognizer()
                  ..onTap = () => launch(AppInfo.commitUrl),
                style: Theme.of(context).textTheme.caption,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              legalese ?? '',
              style: Theme.of(context).textTheme.caption,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            if (debugInfo != null) ...[
              const SizedBox(height: 12),
              Text(
                debugInfo!,
                style: Theme.of(context).textTheme.caption,
                textAlign: TextAlign.center,
              )
            ],
          ],
        ),
      ),
    );
  }
}

class _FandomContributorsPage extends StatelessWidget {
  _FandomContributorsPage({Key? key}) : super(key: key);

  final Map<String, String> data = const {
    'Fandom FGO Team': 'https://fategrandorder.fandom.com/wiki/',
    'Chaldeum Translations': 'https://chaldeum.wordpress.com',
    'aabisector': 'https://www.reddit.com/user/aabisector',
    'ComunCoutinho': 'https://www.reddit.com/user/ComunCoutinho',
    'newworldfool': 'https://www.reddit.com/user/newworldfool',
    'kanramori': 'https://www.reddit.com/user/kanramori',
    'Kairosity': 'https://twitter.com/paradigmkai',
    'Konchew': 'https://www.reddit.com/user/Konchew',
    'PkFreezeAlpha': 'https://www.reddit.com/user/PkFreezeAlpha',
    'shinyklefkey': 'https://www.reddit.com/user/shinyklefkey',
    'uragiruhito': 'https://www.reddit.com/user/uragiruhito',
  };

  @override
  Widget build(BuildContext context) {
    List<Widget> children = [];
    data.forEach((name, link) {
      children.add(ListTile(
        title: Text(name),
        // subtitle: Text(link),
        onTap: () {
          launch(link);
        },
      ));
    });
    return Scaffold(
      appBar: AppBar(title: const Text('Fandom Contributors')),
      body: ListView(children: children),
    );
  }
}

class _GithubMarkdownPage extends StatelessWidget {
  final String title;
  final String? link;
  final String? assetKey;

  const _GithubMarkdownPage(
      {Key? key, required this.title, this.link, this.assetKey})
      : super(key: key);

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
      body: MyMarkdownWidget(assetKey: assetKey),
    );
  }
}
