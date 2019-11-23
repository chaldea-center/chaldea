import 'package:auto_size_text/auto_size_text.dart';
import 'package:chaldea/components/components.dart';
import 'package:flutter_email_sender/flutter_email_sender.dart';
import 'package:package_info/package_info.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutPage extends StatefulWidget {
  @override
  _AboutPageState createState() => _AboutPageState();
}

class _AboutPageState extends State<AboutPage> {
  final references = const {
    'Mooncell': 'https://fgo.wiki',
    'NGA': 'https://bbs.nga.cn/thread.php?fid=540',
    '效率剧场': 'https://sites.google.com/view/fgo-domus-aurea'
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(leading: BackButton(), title: Text('关于Chaldea')),
      body: ListView(
        children: <Widget>[
          TileGroup(
            header: '数据来源',
            footer: '若存在未标注的来源或侵权敬请告知',
            tiles: <Widget>[
              for (var ref in references.entries)
                CustomTile(
                  title: Text(ref.key),
                  subtitle: Text(ref.value),
                  onTap: () => jumpToLink(context, ref.key, ref.value),
                ),
            ],
          ),
          TileGroup(
            header: '反馈',
            tiles: <Widget>[
              ListTile(
                title: Text('Send Email'),
                subtitle: AutoSizeText('优先使用出错时的弹窗发送，并附上出错页面截图', maxLines: 1),
                onTap: () async {
                  final info = await PackageInfo.fromPlatform();
                  final Email email = Email(
                    subject: '${info.appName} v${info.version} Freedback',
                    body: 'Please attach screenshot.',
                    recipients: [supportTeamEmailAddress],
                    isHTML: true,
                  );
                  FlutterEmailSender.send(email);
                },
              ),
              ListTile(title: Text('***@NGA'))
            ],
          )
        ],
      ),
    );
  }
}

void jumpToLink(BuildContext context, String name, String link) {
  showDialog(
      context: context,
      child: SimpleCancelOkDialog(
        title: Text('跳转到 $name'),
        content:
            Text(link, style: TextStyle(decoration: TextDecoration.underline)),
        onTapOk: () async {
          if (await canLaunch(link)) {
            launch(link);
            Navigator.of(context).pop();
          } else {
            throw 'Could not launch $link';
          }
        },
      ));
}
