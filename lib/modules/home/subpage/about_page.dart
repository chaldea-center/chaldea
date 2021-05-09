import 'package:auto_size_text/auto_size_text.dart';
import 'package:chaldea/components/components.dart';
import 'package:chaldea/modules/extras/updates.dart';
import 'package:flutter/foundation.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutPage extends StatefulWidget {
  @override
  _AboutPageState createState() => _AboutPageState();
}

class _AboutPageState extends State<AboutPage> {
  Map<String, String> get references => {
        'TYPE-MOON/FGO PROJECT': 'https://www.fate-go.jp',
        'Mooncell': 'https://fgo.wiki',
        'Fandom-fategrandorder': 'https://fategrandorder.fandom.com/wiki',
        'NGA-FGO': 'https://bbs.nga.cn/thread.php?fid=540',
        S.current.fgo_domus_aurea:
            'https://sites.google.com/view/fgo-domus-aurea',
        '茹西教王的理想鄉': 'http://kazemai.github.io/fgo-vz/'
      };

  final crashFile = File(db.paths.crashLog);

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(),
        title: Text(MaterialLocalizations.of(context)
            .aboutListTileTitle(AppInfo.appName)),
      ),
      body: ListView(
        children: <Widget>[
          _AboutProgram(
            name: AppInfo.appName,
            version: AppInfo.fullVersion2,
            icon: SizedBox(
              height: 120,
              child: Image.asset('res/img/launcher_icon/app_icon_logo.png',
                  height: 120),
            ),
            legalese: 'Copyright © 2021 cc.narumi.\nAll rights reserved.',
          ),
          if (!AppInfo.isMacStoreApp &&
                  (!Platform.isIOS ||
                      db.runtimeData.upgradableVersion != null) ||
              kDebugMode)
            TileGroup(
              header: S.current.update,
              children: [
                ListTile(
                  title: Text(S.current.check_update),
                  trailing: db.runtimeData.upgradableVersion != null
                      ? Text(db.runtimeData.upgradableVersion!.version + '↑',
                          style: TextStyle(color: Colors.redAccent))
                      : null,
                  onTap: () {
                    AutoUpdateUtil().checkAppUpdate(background: false);
                  },
                ),
                if (!Platform.isIOS && !AppInfo.isMacStoreApp)
                  SwitchListTile.adaptive(
                    value: db.userData.autoUpdateApp,
                    title: Text(S.current.auto_update),
                    onChanged: (v) {
                      setState(() {
                        db.userData.autoUpdateApp = v;
                      });
                    },
                  ),
                ListTile(
                  title: Text(LocalizedText.of(
                      chs: '更新历史', jpn: '更新履歴', eng: 'Release Notes')),
                  onTap: () {
                    launch('$kProjectHomepage/blob/master/CHANGELOG.md');
                  },
                ),
              ],
            ),
          ListTile(
            title: Text(S.of(context).about_app_declaration_text),
          ),
          TileGroup(
            header: S.of(context).about_data_source,
            footer: S.of(context).about_data_source_footer,
            children: <Widget>[
              for (var ref in references.entries)
                ListTile(
                  title: Text(ref.key),
                  subtitle: AutoSizeText(ref.value, maxLines: 1),
                  onTap: () =>
                      jumpToExternalLinkAlert(url: ref.value, name: ref.key),
                ),
              ListTile(
                title: Text('Fandom Contributors'),
                onTap: () {
                  SplitRoute.push(
                    context: context,
                    builder: (_, __) => _FandomContributorsPage(),
                    detail: true,
                  );
                },
              ),
            ],
          ),
          TileGroup(
            header: 'Project',
            children: [
              ListTile(
                title: Text('Starring on Github'),
                subtitle: Text(kProjectHomepage),
                onTap: () {
                  launch(kProjectHomepage);
                },
              ),
              ListTile(
                title: Text(S.current.support_chaldea),
                onTap: () {
                  launch(kProjectHomepage + '/wiki/Support');
                },
              ),
              ListTile(
                title: Text('Contribute to Chaldea'),
                subtitle: Text('e.g. Translation'),
                onTap: () {
                  SimpleCancelOkDialog(
                    title: Text('Contribute to Chaldea'),
                    content: Text(
                        '- Add English/Japanese translation of some game-related words like "servant","Palingenesis"\n'
                        // '- \n'
                        '\nIf you are willing to contribute, please contact me through email:\n'
                        '$kSupportTeamEmailAddress'),
                    scrollable: true,
                  ).showDialog(context);
                },
              )
            ],
          ),
          TileGroup(
            header: MaterialLocalizations.of(context).licensesPageTitle,
            children: [
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
                            'Copyright © 2021 cc.narumi.\nAll rights reserved.',
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
  }) : super(key: key);

  final String name;
  final String version;
  final Widget? icon;
  final String? legalese;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Theme.of(context).cardColor,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 24.0),
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
            const SizedBox(height: 12),
            Text(
              legalese ?? '',
              style: Theme.of(context).textTheme.caption,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}

class _FandomContributorsPage extends StatelessWidget {
  const _FandomContributorsPage({Key? key}) : super(key: key);

  final Map<String, String> data = const {
    'Fandom FGO Team': 'https://fategrandorder.fandom.com/wiki',
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
        subtitle: Text(link),
        onTap: () {
          jumpToExternalLinkAlert(url: link);
        },
      ));
    });
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(),
        title: Text('Fandom Contributors'),
      ),
      body: ListView(children: children),
    );
  }
}
