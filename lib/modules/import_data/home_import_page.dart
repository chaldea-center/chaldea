import 'package:chaldea/components/components.dart';
import 'package:chaldea/modules/import_data/import_guda_page.dart';
import 'package:chaldea/modules/import_data/import_http_page.dart';
import 'package:chaldea/modules/import_data/import_item_screenshot_page.dart';
import 'package:chaldea/modules/import_data/import_skill_screenshot_page.dart';

class ImportPageHome extends StatefulWidget {
  const ImportPageHome({Key? key}) : super(key: key);

  @override
  _ImportPageHomeState createState() => _ImportPageHomeState();
}

class _ImportPageHomeState extends State<ImportPageHome> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: MasterBackButton(),
        title: Text(S.current.import_data),
      ),
      body: ListView(
        children: [
          ListTile(
            leading: Icon(Icons.http),
            title: Text(LocalizedText.of(
                chs: 'HTTPS抓包', jpn: 'HTTPSスニッフィング', eng: 'HTTPS Sniffing')),
            subtitle: Text('借助抓包工具获取账号登陆时的数据'),
            trailing: Icon(Icons.keyboard_arrow_right),
            onTap: () {
              SplitRoute.push(
                context: context,
                builder: (context, _) => ImportHttpPage(),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.screenshot),
            title: Text(LocalizedText.of(
                chs: '素材截图解析',
                jpn: 'アイテムのスクリーンショット',
                eng: 'Items Screenshots')),
            subtitle: Text('My Room - 道具一览'),
            trailing: Icon(Icons.keyboard_arrow_right),
            onTap: () {
              SplitRoute.push(
                context: context,
                builder: (context, _) => ImportItemScreenshotPage(),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.screenshot),
            title: Text(LocalizedText.of(
                chs: '技能截图解析', jpn: 'スキルのスクリーンショット', eng: 'Skill Screenshots')),
            subtitle: Text(LocalizedText.of(
                chs: '强化-技能升级', jpn: 'jpn', eng: 'Enhancement-Skill')),
            trailing: Icon(Icons.keyboard_arrow_right),
            onTap: () {
              SplitRoute.push(
                context: context,
                builder: (context, _) => ImportSkillScreenshotPage(),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.compare_arrows),
            title: Text(LocalizedText.of(
                chs: 'Guda数据', jpn: 'Gudaデータ', eng: 'Guda Data')),
            trailing: Icon(Icons.keyboard_arrow_right),
            onTap: () {
              SplitRoute.push(
                context: context,
                builder: (ctx, _) => ImportGudaPage(),
              );
            },
          ),
        ],
      ),
    );
  }
}
