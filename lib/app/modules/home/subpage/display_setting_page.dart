import 'package:chaldea/components/localized/localized_base.dart';
import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/models/models.dart';
import 'package:chaldea/packages/app_info.dart';
import 'package:chaldea/packages/method_channel/method_channel_chaldea.dart';
import 'package:chaldea/packages/platform/platform.dart';
import 'package:chaldea/packages/split_route/split_route.dart';
import 'package:chaldea/widgets/tile_items.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'display_settings/carousel_setting_page.dart';
import 'display_settings/class_filter_style.dart';
import 'display_settings/fav_option.dart';
import 'display_settings/svt_priority_tagging.dart';
import 'display_settings/svt_tab_sorting.dart';

class DisplaySettingPage extends StatefulWidget {
  DisplaySettingPage({Key? key}) : super(key: key);

  @override
  _DisplaySettingPageState createState() => _DisplaySettingPageState();
}

class _DisplaySettingPageState extends State<DisplaySettingPage> {
  CarouselSetting get carousel => db2.settings.carousel;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(S.current.display_setting),
      ),
      body: ListView(
        children: [
          TileGroup(
            header: 'App',
            children: [
              if (PlatformU.isMacOS || PlatformU.isWindows)
                SwitchListTile.adaptive(
                  value: db2.settings.alwaysOnTop,
                  title: Text(LocalizedText.of(
                      chs: '置顶显示',
                      jpn: 'スティッキー表示',
                      eng: 'Always On Top',
                      kor: '항상 맨 위에 표시')),
                  onChanged: (v) async {
                    db2.settings.alwaysOnTop = v;
                    MethodChannelChaldeaNext.setAlwaysOnTop(v);
                    setState(() {});
                  },
                ),
              // only show on mobile phone, not desktop and tablet
              // on Android, cannot detect phone or mobile
              if (PlatformU.isMobile && !AppInfo.isIPad || kDebugMode)
                SwitchListTile.adaptive(
                  value: db2.settings.autoRotate,
                  title: Text(S.current.setting_auto_rotate),
                  onChanged: (v) {
                    setState(() {
                      db2.settings.autoRotate = v;
                    });
                    db2.notifyAppUpdate();
                  },
                ),
              SwitchListTile.adaptive(
                value: db2.settings.display.showAccountAtHome,
                title: Text(LocalizedText.of(
                    chs: '首页显示当前账号',
                    jpn: 'ホームページにアカウントを表示 ',
                    eng: 'Show Account at Homepage',
                    kor: '홈페이지에 계정 표시')),
                onChanged: (v) {
                  setState(() {
                    db2.settings.display.showAccountAtHome = v;
                  });
                  db2.notifyUserdata();
                },
              ),
              ListTile(
                title: Text(S.current.carousel_setting),
                trailing: const Icon(Icons.keyboard_arrow_right),
                onTap: () {
                  SplitRoute.push(context, const CarouselSettingPage());
                },
              )
            ],
          ),
          TileGroup(
            header: S.current.filter,
            footer: '${S.current.servant}/${S.current.craft_essence}'
                '/${S.current.command_code}',
            children: [
              SwitchListTile.adaptive(
                value: db2.settings.autoResetFilter,
                title: Text(S.current.auto_reset),
                onChanged: (v) async {
                  db2.settings.autoResetFilter = v;
                  setState(() {});
                },
              ),
            ],
          ),
          TileGroup(
            header: S.current.servant,
            children: [
              ListTile(
                title: const Text('Ascension Icon'),
                trailing: DropdownButton<int>(
                  value: db2.userData.svtAscensionIcon,
                  underline: const SizedBox(),
                  items: List.generate(
                    4,
                    (index) => DropdownMenuItem(
                      child: Text('${index + 1}'),
                      value: index + 1,
                    ),
                  ),
                  onChanged: (v) {
                    if(v!=null) {
                      db2.userData.svtAscensionIcon = v;
                    }
                    setState(() {});
                  },
                ),
              )
            ],
          ),
          TileGroup(
            header: LocalizedText.of(
                chs: '从者列表页',
                jpn: 'サーヴァントリストページ',
                eng: 'Servant List Page',
                kor: '서번트 리스트 페이지'),
            children: [
              SwitchListTile.adaptive(
                title: const Text('Auto Turn on PlanNotReach'),
                subtitle: const Text('Plans List Page'),
                value: db2.settings.display.autoTurnOnPlanNotReach,
                onChanged: (v) {
                  setState(() {
                    db2.settings.display.autoTurnOnPlanNotReach = v;
                  });
                },
                controlAffinity: ListTileControlAffinity.trailing,
              ),
              ListTile(
                title: Text(LocalizedText.of(
                  chs: '「关注」按钮默认筛选',
                  jpn: '「フォロー」ボタンディフォルト',
                  eng: '「Favorite」Button Default',
                  kor: '「즐겨찾기」버튼 디폴트',
                )),
                trailing: const Icon(Icons.keyboard_arrow_right),
                onTap: () {
                  SplitRoute.push(context, FavOptionSetting());
                },
              ),
              ListTile(
                title: Text(LocalizedText.of(
                    chs: '从者职阶筛选样式',
                    jpn: 'クラスフィルタースタイル ',
                    eng: 'Servant Class Filter Style',
                    kor: '서번트 클래스 필터 스타일')),
                trailing: const Icon(Icons.keyboard_arrow_right),
                onTap: () {
                  SplitRoute.push(context, ClassFilterStyleSetting());
                },
              ),
              SwitchListTile.adaptive(
                title: Text(LocalizedText.of(
                    chs: '仅更改附加技能2',
                    jpn: 'アペンドスキル2のみを変更 ',
                    eng: 'Only Change 2nd Append Skill',
                    kor: '어펜드 스킬 2만 변경')),
                subtitle: Text(LocalizedText.of(
                    chs: '首页-规划列表页',
                    jpn: 'ホーム-プラン',
                    eng: 'Home-Plan List Page',
                    kor: '홈-계획 리스트 페이지')),
                value: db2.settings.display.onlyAppendSkillTwo,
                onChanged: (v) {
                  setState(() {
                    db2.settings.display.onlyAppendSkillTwo = v;
                  });
                },
              ),
            ],
          ),
          TileGroup(
            header: LocalizedText.of(
                chs: '从者详情页',
                jpn: 'サーヴァント詳細ページ',
                eng: 'Servant Detail Page',
                kor: '서번트 상세 페이지'),
            children: [
              ListTile(
                title: Text(LocalizedText.of(
                    chs: '标签页排序',
                    jpn: 'ページ表示順序',
                    eng: 'Tabs Sorting',
                    kor: '페이지 표시 순서')),
                trailing: const Icon(Icons.keyboard_arrow_right),
                onTap: () {
                  SplitRoute.push(context, SvtTabsSortingSetting());
                },
              ),
              ListTile(
                title: Text(LocalizedText.of(
                    chs: '优先级备注',
                    jpn: '優先順位ノート',
                    eng: 'Priority Tagging',
                    kor: '우선순위 매기기')),
                trailing: const Icon(Icons.keyboard_arrow_right),
                onTap: () {
                  SplitRoute.push(context, SvtPriorityTagging());
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
