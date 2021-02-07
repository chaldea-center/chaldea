import 'dart:io';
import 'dart:math';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:chaldea/components/components.dart';
import 'package:flutter_email_sender/flutter_email_sender.dart';
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
  String crashLog;

  @override
  void initState() {
    super.initState();
    loadLog();
  }

  void loadLog() {
    if (crashFile.existsSync()) {
      crashLog = 'loading...';
      crashFile.readAsLines().then((lines) {
        crashLog =
            lines.sublist(max(0, lines.length - 500), lines.length).join('\n');
        setState(() {});
      });
    } else {
      crashLog = 'no crash log found.';
    }
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
                    spacing: 10,
                    children: [
                      if (AppInfo.fullVersion.isNotEmpty)
                        Text(
                            '${S.of(context).version}: ${AppInfo.fullVersion}'),
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
            header: S.of(context).about_feedback,
            children: <Widget>[
              ListTile(
                title: Text('Email'),
                subtitle: AutoSizeText(S.of(context).about_email_subtitle,
                    maxLines: 1),
                onTap: () async {
                  if (Platform.isAndroid || Platform.isIOS) {
                    final Email email = Email(
                        subject: '${AppInfo.appName} '
                            'v${AppInfo.fullVersion} ${S.of(context).about_feedback}',
                        body: S.of(context).about_email_subtitle + '\n\n',
                        recipients: [kSupportTeamEmailAddress],
                        isHTML: true,
                        attachmentPaths: [
                          if (crashFile.existsSync()) crashFile.path,
                        ]);
                    FlutterEmailSender.send(email);
                  } else {
                    SimpleCancelOkDialog(
                      title: Text(S.of(context).about_feedback),
                      content: Text(
                        S.of(context).about_email_dialog(
                            kSupportTeamEmailAddress, db.paths.crashLog),
                      ),
                    ).show(context);
                  }
                },
              ),
              ListTile(
                title: Text(S.of(context).nga),
                onTap: () => jumpToExternalLinkAlert(
                    url: 'https://bbs.nga.cn/read.php?tid=24926789',
                    name: S.of(context).nga_fgo),
              ),
              if (Platform.isIOS || Platform.isMacOS)
                ListTile(
                  title: Text(S.of(context).about_appstore_rating),
                  onTap: () {
                    launch('itms-apps://itunes.apple.com/app/id1548713491');
                  },
                )
            ],
          ),
          if (kDebugMode_)
            TileGroup(
              header: 'Crash log (${crashFile.statSync().size ~/ 1000} KB)',
              children: <Widget>[
                ListTile(
                  title: Text('Delete crash logs'),
                  onTap: () {
                    if (crashFile.existsSync()) {
                      crashFile.delete().then((_) {
                        EasyLoading.showToast('crash logs has been deleted.');
                        loadLog();
                        setState(() {});
                      });
                    }
                  },
                ),
                ConstrainedBox(
                  constraints: BoxConstraints(maxHeight: 500),
                  child: ListView(
                    shrinkWrap: true,
                    children: <Widget>[CustomTile(subtitle: Text(crashLog))],
                  ),
                )
              ],
            ),
        ],
      ),
    );
  }
}
