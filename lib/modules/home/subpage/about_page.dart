import 'dart:io';
import 'dart:math';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:chaldea/components/components.dart';
import 'package:flutter_email_sender/flutter_email_sender.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:package_info/package_info.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutPage extends StatefulWidget {
  @override
  _AboutPageState createState() => _AboutPageState();
}

class _AboutPageState extends State<AboutPage> {
  final references = const {
    'Mooncell': 'https://fgo.wiki',
    'NGA-FGO版块': 'https://bbs.nga.cn/thread.php?fid=540',
    '效率剧场': 'https://sites.google.com/view/fgo-domus-aurea'
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
      appBar: AppBar(leading: BackButton(), title: Text('关于Chaldea')),
      body: ListView(
        children: <Widget>[
          TileGroup(
            header: '数据来源',
            footer: '若存在未标注的来源或侵权敬请告知',
            children: <Widget>[
              for (var ref in references.entries)
                ListTile(
                  title: Text(ref.key),
                  subtitle: AutoSizeText(ref.value, maxLines: 1),
                  onTap: () => jumpToLink(context, ref.key, ref.value),
                ),
            ],
          ),
          TileGroup(
            header: '反馈',
            children: <Widget>[
              ListTile(
                title: Text('Email'),
                subtitle: AutoSizeText('请附上出错页面截图', maxLines: 1),
                onTap: () async {
                  final info = await PackageInfo.fromPlatform();
                  final Email email = Email(
                      subject: '${info.appName} v${info.version} Freedback',
                      body: '请附上出错页面截图.\n\n',
                      recipients: [kSupportTeamEmailAddress],
                      isHTML: true,
                      attachmentPaths: [
                        if (crashFile.existsSync()) crashFile.path,
                      ]);
                  FlutterEmailSender.send(email);
                },
              ),
              ListTile(title: Text('***@NGA')),
            ],
          ),
          // if(kDebugMode)
          TileGroup(
            header: 'Crash log (${crashFile.statSync().size ~/ 1000} KB)',
            children: <Widget>[
              ListTile(
                title: Text('Delete crash logs'),
                onTap: () {
                  crashFile.delete().then((_) {
                    showToast('crash logs has been deleted.');
                    loadLog();
                    setState(() {});
                  });
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

  void jumpToLink(BuildContext context, String name, String link) {
    showDialog(
      context: context,
      builder: (_) => SimpleCancelOkDialog(
        title: Text('跳转到 $name'),
        content:
            Text(link, style: TextStyle(decoration: TextDecoration.underline)),
        onTapOk: () async {
          if (await canLaunch(link)) {
            launch(link);
          } else {
            Fluttertoast.showToast(msg: 'Could not launch uri: $link');
          }
        },
      ),
    );
  }
}
