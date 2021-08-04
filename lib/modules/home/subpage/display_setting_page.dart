import 'package:chaldea/components/components.dart';
import 'package:chaldea/components/method_channel_chaldea.dart';

class DisplaySettingPage extends StatefulWidget {
  const DisplaySettingPage({Key? key}) : super(key: key);

  @override
  _DisplaySettingPageState createState() => _DisplaySettingPageState();
}

class _DisplaySettingPageState extends State<DisplaySettingPage> {
  CarouselSetting get carousel => db.userData.carouselSetting;

  HiveItem<bool> alwaysOnTop = db.cfg.alwaysOnTop;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(),
        title: Text(S.current.display_setting),
      ),
      body: ListView(
        children: [
          TileGroup(
            header: 'App',
            children: [
              if (Platform.isMacOS || Platform.isWindows)
                SwitchListTile.adaptive(
                  value: alwaysOnTop.get() ?? false,
                  title: Text(LocalizedText.of(
                      chs: '置顶显示', jpn: 'スティッキー表示', eng: 'Always On Top')),
                  onChanged: (v) async {
                    alwaysOnTop.put(v);
                    MethodChannelChaldea.setAlwaysOnTop(v);
                    setState(() {});
                  },
                ),
              // only show on mobile phone, not desktop and tablet
              // on Android, cannot detect phone or mobile
              if (AppInfo.isMobile && !AppInfo.isIPad || kDebugMode)
                SwitchListTile.adaptive(
                  value: db.appSetting.autorotate,
                  title: Text(S.current.setting_auto_rotate),
                  onChanged: (v) {
                    setState(() {
                      db.appSetting.autorotate = v;
                    });
                    db.notifyAppUpdate();
                  },
                ),
            ],
          ),
          TileGroup(
            header: S.current.filter,
            footer: '${S.current.servant}/${S.current.craft_essence}'
                '/${S.current.command_code}',
            children: [
              SwitchListTile.adaptive(
                value: db.appSetting.autoResetFilter,
                title: Text(LocalizedText.of(
                    chs: '自动重置', jpn: '自動リセット', eng: 'Auto Reset')),
                onChanged: (v) async {
                  db.appSetting.autoResetFilter = v;
                  setState(() {});
                },
              ),
            ],
          ),
          TileGroup(
            header: LocalizedText.of(
                chs: '从者列表页', jpn: 'サーヴァントリストページ', eng: 'Servant List Page'),
            children: [
              SwitchListTile.adaptive(
                value: db.appSetting.showClassFilterOnTop,
                title: Text(LocalizedText.of(
                    chs: '列表顶部显示职阶筛选按钮',
                    jpn: 'ランクフィルターがリストの一番上に表示',
                    eng: 'Show Class Filter on top')),
                onChanged: (v) async {
                  db.appSetting.showClassFilterOnTop = v;
                  setState(() {});
                },
              ),
            ],
          ),
          TileGroup(
            header: LocalizedText.of(
                chs: '从者筛选-"关注"默认行为',
                jpn: '"フォロー"のデフォルト動作\n'
                    '(サーバント フィルタ)',
                eng: 'Default "Favorite" of Servant Filter'),
            children: [
              RadioListTile<bool?>(
                value: null,
                groupValue: db.appSetting.favoritePreferred,
                title: Text(LocalizedText.of(
                    chs: '记住选择', jpn: '前の選択', eng: 'Remember')),
                onChanged: (v) {
                  setState(() {
                    db.appSetting.favoritePreferred = null;
                  });
                },
              ),
              RadioListTile<bool?>(
                value: true,
                groupValue: db.appSetting.favoritePreferred,
                title: Text(LocalizedText.of(
                    chs: '显示已关注', jpn: 'フォロー表示', eng: 'Show Favorite')),
                secondary: Icon(Icons.favorite),
                onChanged: (v) {
                  setState(() {
                    db.appSetting.favoritePreferred = true;
                  });
                },
              ),
              RadioListTile<bool?>(
                value: false,
                groupValue: db.appSetting.favoritePreferred,
                title: Text(LocalizedText.of(
                    chs: '显示全部', jpn: 'すべて表示', eng: 'Show All')),
                secondary: Icon(Icons.remove_circle_outline),
                onChanged: (v) {
                  setState(() {
                    db.appSetting.favoritePreferred = false;
                  });
                },
              ),
            ],
          ),
          TileGroup(
            header: S.current.carousel_setting,
            children: [
              CheckboxListTile(
                value: carousel.enableMooncell,
                title: Text('Mooncell News'),
                subtitle: Text('CN/JP'),
                controlAffinity: ListTileControlAffinity.leading,
                onChanged: (v) {
                  setState(() {
                    carousel.needUpdate = true;
                    carousel.enableMooncell = v ?? carousel.enableMooncell;
                  });
                },
              ),
              CheckboxListTile(
                value: carousel.enableJp,
                title: Text('JP News'),
                subtitle: Text('https://view.fate-go.jp/'),
                controlAffinity: ListTileControlAffinity.leading,
                onChanged: (v) {
                  setState(() {
                    carousel.needUpdate = true;
                    carousel.enableJp = v ?? carousel.enableJp;
                  });
                },
              ),
              CheckboxListTile(
                value: carousel.enableUs,
                title: Text('NA News'),
                subtitle: Text('https://webview.fate-go.us/'),
                controlAffinity: ListTileControlAffinity.leading,
                onChanged: (v) {
                  setState(() {
                    carousel.needUpdate = true;
                    carousel.enableUs = v ?? carousel.enableUs;
                  });
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
