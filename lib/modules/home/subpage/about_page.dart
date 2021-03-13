import 'dart:io';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:chaldea/components/components.dart';
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
        'NGA-FGO': 'https://bbs.nga.cn/thread.php?fid=540',
        S.current.fgo_domus_aurea:
            'https://sites.google.com/view/fgo-domus-aurea'
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
              .aboutListTileTitle(AppInfo.appName))),
      body: ListView(
        children: <Widget>[
          Card(
            margin: EdgeInsets.all(0),
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(
                    height: 120,
                    child: Image.asset(
                      'res/img/launcher_icon/app_icon_logo.png',
                      height: 120,
                    ),
                  ),
                  Text(
                    AppInfo.appName,
                    style: Theme.of(context).textTheme.headline6,
                  ),
                  Wrap(
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: 3,
                    children: [
                      Text('${S.of(context).version}: ${AppInfo.fullVersion2}'),
                      if (db.runtimeData.appUpgradable)
                        Text(' ⃰', style: TextStyle(color: Colors.red)),
                      if (!Platform.isIOS && !Platform.isMacOS || kDebugMode)
                        ElevatedButton(
                          onPressed: () => checkAppUpdate(false),
                          child: Text(S.of(context).check_update),
                          style: ElevatedButton.styleFrom(
                            textStyle: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.normal,
                                fontSize: 12),
                            minimumSize: Size(10, 30),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16)),
                          ),
                        )
                    ],
                  )
                ],
              ),
            ),
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
            ],
          ),
          TileGroup(
            header: S.of(context).project_homepage,
            children: [
              ListTile(
                title: Text('Github'),
                subtitle: Text(kProjectHomepage),
                onTap: () {
                  launch(kProjectHomepage);
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
