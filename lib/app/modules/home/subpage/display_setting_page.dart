import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:chaldea/app/app.dart';
import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/models/models.dart';
import 'package:chaldea/packages/app_info.dart';
import 'package:chaldea/packages/method_channel/method_channel_chaldea.dart';
import 'package:chaldea/packages/platform/platform.dart';
import 'package:chaldea/widgets/tile_items.dart';
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
  CarouselSetting get carousel => db.settings.carousel;

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
                  value: db.settings.alwaysOnTop,
                  title: Text(S.current.setting_always_on_top),
                  onChanged: (v) async {
                    db.settings.alwaysOnTop = v;
                    db.saveSettings();
                    MethodChannelChaldeaNext.setAlwaysOnTop(v);
                    setState(() {});
                  },
                ),
              // only show on mobile phone, not desktop and tablet
              // on Android, cannot detect phone or mobile
              if (PlatformU.isMobile && !AppInfo.isIPad || kDebugMode)
                SwitchListTile.adaptive(
                  value: db.settings.autoRotate,
                  title: Text(S.current.setting_auto_rotate),
                  onChanged: (v) {
                    setState(() {
                      db.settings.autoRotate = v;
                      if (v) {
                        SystemChrome.setPreferredOrientations([]);
                      } else {
                        SystemChrome.setPreferredOrientations(
                            [DeviceOrientation.portraitUp]);
                      }
                    });
                    db.notifyAppUpdate();
                  },
                ),
              SwitchListTile.adaptive(
                value: db.settings.display.showAccountAtHome,
                title: Text(S.current.setting_show_account_at_homepage),
                onChanged: (v) {
                  setState(() {
                    db.settings.display.showAccountAtHome = v;
                    db.saveSettings();
                  });
                  db.notifyUserdata();
                },
              ),
              ListTile(
                title: Text(S.current.carousel_setting),
                trailing: const Icon(Icons.keyboard_arrow_right),
                onTap: () {
                  router.pushPage(const CarouselSettingPage());
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
                value: db.settings.autoResetFilter,
                title: Text(S.current.auto_reset),
                onChanged: (v) async {
                  db.settings.autoResetFilter = v;
                  db.saveSettings();
                  setState(() {});
                },
              ),
              SwitchListTile.adaptive(
                value: db.settings.hideUnreleasedCard,
                title: Text(S.current.hide_unreleased_card),
                onChanged: (v) async {
                  db.settings.hideUnreleasedCard = v;
                  db.saveSettings();
                  setState(() {});
                },
              ),
            ],
          ),
          TileGroup(
            header: S.current.servant,
            children: [
              ListTile(
                title: Text(S.current.svt_ascension_icon),
                trailing: DropdownButton<int>(
                  value: db.userData.svtAscensionIcon,
                  underline: const SizedBox(),
                  items: List.generate(
                    4,
                    (index) => DropdownMenuItem(
                      value: index + 1,
                      child: Text('${S.current.ascension} ${index + 1}'),
                    ),
                  ),
                  onChanged: (v) {
                    if (v != null) {
                      db.userData.svtAscensionIcon = v;
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
              ListTile(
                title: Text(S.current.setting_setting_favorite_button_default),
                trailing: const Icon(Icons.keyboard_arrow_right),
                onTap: () {
                  router.pushPage(FavOptionSetting());
                },
              ),
              ListTile(
                title: Text(S.current.setting_servant_class_filter_style),
                trailing: const Icon(Icons.keyboard_arrow_right),
                onTap: () {
                  router.pushPage(ClassFilterStyleSetting());
                },
              ),
              SwitchListTile.adaptive(
                title: Text(S.current.setting_auto_turn_on_plan_not_reach),
                subtitle: Text(S.current.setting_home_plan_list_page),
                value: db.settings.display.autoTurnOnPlanNotReach,
                onChanged: (v) {
                  setState(() {
                    db.settings.display.autoTurnOnPlanNotReach = v;
                    db.saveSettings();
                  });
                },
                controlAffinity: ListTileControlAffinity.trailing,
              ),
              SwitchListTile.adaptive(
                title: Text(S.current.setting_only_change_second_append_skill),
                subtitle: Text(S.current.setting_home_plan_list_page),
                value: db.settings.display.onlyAppendSkillTwo,
                onChanged: (v) {
                  setState(() {
                    db.settings.display.onlyAppendSkillTwo = v;
                    db.saveSettings();
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
                  router.pushPage(SvtTabsSortingSetting());
                },
              ),
              ListTile(
                title: Text(S.current.setting_priority_tagging),
                trailing: const Icon(Icons.keyboard_arrow_right),
                onTap: () {
                  router.pushPage(SvtPriorityTagging());
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
