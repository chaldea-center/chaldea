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
                  title: Text(S.current.setting_always_on_top),
                  onChanged: (v) async {
                    db2.settings.alwaysOnTop = v;
                    db2.saveSettings();
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
                      db2.saveSettings();
                    });
                    db2.notifyAppUpdate();
                  },
                ),
              SwitchListTile.adaptive(
                value: db2.settings.display.showAccountAtHome,
                title: Text(S.current.setting_show_account_at_homepage),
                onChanged: (v) {
                  setState(() {
                    db2.settings.display.showAccountAtHome = v;
                    db2.saveSettings();
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
                  db2.saveSettings();
                  setState(() {});
                },
              ),
            ],
          ),
          TileGroup(
            header: S.current.servant,
            children: [
              ListTile(
                title: Text(S.current.ascension_icon),
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
                    if (v != null) {
                      db2.userData.svtAscensionIcon = v;
                    }
                    setState(() {});
                  },
                ),
              )
            ],
          ),
          TileGroup(
            header: S.current.servant_list_page,
            children: [
              SwitchListTile.adaptive(
                title: Text(S.current.setting_auto_turn_on_plan_not_reach),
                subtitle: Text(S.current.setting_plans_list_page),
                value: db2.settings.display.autoTurnOnPlanNotReach,
                onChanged: (v) {
                  setState(() {
                    db2.settings.display.autoTurnOnPlanNotReach = v;
                    db2.saveSettings();
                  });
                },
                controlAffinity: ListTileControlAffinity.trailing,
              ),
              ListTile(
                title: Text(S.current.setting_setting_favorite_button_default),
                trailing: const Icon(Icons.keyboard_arrow_right),
                onTap: () {
                  SplitRoute.push(context, FavOptionSetting());
                },
              ),
              ListTile(
                title: Text(S.current.setting_servant_class_filter_style),
                trailing: const Icon(Icons.keyboard_arrow_right),
                onTap: () {
                  SplitRoute.push(context, ClassFilterStyleSetting());
                },
              ),
              SwitchListTile.adaptive(
                title: Text(S.current.setting_only_change_second_append_skill),
                subtitle: Text(S.current.setting_home_plan_list_page),
                value: db2.settings.display.onlyAppendSkillTwo,
                onChanged: (v) {
                  setState(() {
                    db2.settings.display.onlyAppendSkillTwo = v;
                    db2.saveSettings();
                  });
                },
              ),
            ],
          ),
          TileGroup(
            header: S.current.servant_detail_page,
            children: [
              ListTile(
                title: Text(S.current.setting_tabs_sorting),
                trailing: const Icon(Icons.keyboard_arrow_right),
                onTap: () {
                  SplitRoute.push(context, SvtTabsSortingSetting());
                },
              ),
              ListTile(
                title: Text(S.current.setting_priority_tagging),
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
