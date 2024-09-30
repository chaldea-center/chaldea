import 'package:chaldea/utils/extension.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:flutter_easyloading/flutter_easyloading.dart';

import 'package:chaldea/app/app.dart';
import 'package:chaldea/app/tools/app_window.dart';
import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/models/models.dart';
import 'package:chaldea/packages/ads/ads.dart';
import 'package:chaldea/packages/app_info.dart';
import 'package:chaldea/packages/logger.dart';
import 'package:chaldea/packages/platform/platform.dart';
import 'package:chaldea/packages/split_route/split_route.dart';
import 'package:chaldea/utils/notification.dart';
import 'package:chaldea/widgets/custom_dialogs.dart';
import 'package:chaldea/widgets/tile_items.dart';
import '../../root/global_fab.dart';
import 'display_settings/ad_setting.dart';
import 'display_settings/carousel_setting_page.dart';
import 'display_settings/class_filter_style.dart';
import 'display_settings/fav_option.dart';
import 'display_settings/hide_svt_plan_detail.dart';
import 'display_settings/master_ratio.dart';
import 'display_settings/svt_priority_tagging.dart';
import 'display_settings/svt_tab_sorting.dart';

class DisplaySettingPage extends StatefulWidget {
  DisplaySettingPage({super.key});

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
            header: S.current.gallery_tab_name,
            children: [
              ListTile(
                title: Text(S.current.carousel),
                trailing: const Icon(Icons.keyboard_arrow_right),
                onTap: () {
                  router.pushPage(const CarouselSettingPage());
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
                title: Text(S.current.setting_split_ratio),
                subtitle: Text(S.current.setting_split_ratio_hint),
                trailing: const Icon(Icons.keyboard_arrow_right),
                onTap: () {
                  router.pushPage(MasterRatioSetting());
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
                value: db.settings.autoResetFilter,
                title: Text(S.current.auto_reset),
                onChanged: (v) {
                  db.settings.autoResetFilter = v;
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
                  items: [
                    for (int index = 1; index <= 4; index++)
                      DropdownMenuItem(
                        value: index,
                        child: Text('${S.current.ascension} $index'),
                      ),
                    DropdownMenuItem(
                      value: -1,
                      child: Text(S.current.plan),
                    ),
                  ],
                  onChanged: (v) {
                    if (v != null) {
                      db.userData.svtAscensionIcon = v;
                    }
                    setState(() {});
                  },
                ),
              ),
              SwitchListTile.adaptive(
                value: db.userData.preferAprilFoolIcon,
                title: Text(S.current.prefer_april_fool_icon),
                controlAffinity: ListTileControlAffinity.trailing,
                onChanged: (v) {
                  setState(() {
                    db.userData.preferAprilFoolIcon = v;
                  });
                },
              ),
              ListTile(
                title: Text(S.current.reset_custom_ascension_icon),
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (context) => SimpleCancelOkDialog(
                      title: Text(S.current.confirm),
                      content: Text(S.current.reset_custom_ascension_icon),
                      confirmText: S.current.reset.toUpperCase(),
                      onTapOk: () {
                        db.userData.customSvtIcon.clear();
                        EasyLoading.showSuccess(S.current.success);
                      },
                    ),
                  );
                },
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
              ListTile(
                title: Text(S.current.hide_svt_plan_details),
                trailing: const Icon(Icons.keyboard_arrow_right),
                onTap: () {
                  router.pushPage(const HideSvtPlanDetailSettingPage());
                },
              ),
              ListTile(
                title: Text(S.current.svt_switch_slider_dropdown),
                trailing: DropdownButton<SvtPlanInputMode>(
                  value: db.settings.display.svtPlanInputMode,
                  underline: const SizedBox(),
                  items: [
                    for (final mode in [SvtPlanInputMode.dropdown, SvtPlanInputMode.slider])
                      DropdownMenuItem(
                        value: mode,
                        child: Text(mode.name),
                      ),
                  ],
                  onChanged: (v) {
                    if (v != null) {
                      db.settings.display.svtPlanInputMode = v;
                    }
                    setState(() {});
                  },
                ),
              ),
            ],
          ),
          if (1 > 2)
            TileGroup(
              header: S.current.quest,
              footer: S.current.quest_region_has_enemy_hint,
              children: [
                ListTile(
                  title: Text(S.current.quest_prefer_region),
                  subtitle: Text(
                    S.current.quest_prefer_region_hint,
                    textScaler: const TextScaler.linear(0.9),
                  ),
                  trailing: DropdownButton<Region?>(
                    value: db.settings.preferredQuestRegion,
                    items: [
                      DropdownMenuItem(
                        value: null,
                        child: Text(S.current.general_default),
                      ),
                      for (final region in Region.values)
                        DropdownMenuItem(
                          value: region,
                          child: Text(region.localName),
                        ),
                    ],
                    onChanged: (v) {
                      setState(() {
                        db.settings.preferredQuestRegion = v;
                      });
                    },
                  ),
                ),
              ],
            ),
          TileGroup(
            header: 'App',
            footer: PlatformU.isDesktop
                ? 'If system tray crash, delete settings.json or change "showSystemTray" value from true to false.'
                : null,
            children: [
              if (PlatformU.isDesktop)
                SwitchListTile.adaptive(
                  value: db.settings.alwaysOnTop,
                  title: Text(S.current.setting_always_on_top),
                  onChanged: (v) {
                    db.settings.alwaysOnTop = v;
                    db.saveSettings();
                    AppWindowUtil.setAlwaysOnTop(v);
                    setState(() {});
                  },
                ),
              SwitchListTile.adaptive(
                value: db.settings.display.showWindowFab,
                title: Text(S.current.display_show_window_fab),
                onChanged: (v) {
                  db.settings.display.showWindowFab = v;
                  db.saveSettings();
                  if (v) {
                    WindowManagerFab.createOverlay(context);
                  } else {
                    WindowManagerFab.removeOverlay();
                  }
                  setState(() {});
                },
              ),
              SwitchListTile.adaptive(
                value: db.settings.showDebugFab,
                title: Text(S.current.debug_fab),
                subtitle: Text('${S.current.screenshots} etc.'),
                onChanged: (v) {
                  setState(() {
                    db.settings.showDebugFab = v;
                    db.saveSettings();
                  });
                  if (v) {
                    DebugFab.createOverlay(context);
                  } else {
                    DebugFab.removeOverlay();
                  }
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
                        SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
                      }
                    });
                    db.notifyAppUpdate();
                  },
                ),
              if (!SplitRoute.isPopGestureAlwaysDisabled)
                SwitchListTile.adaptive(
                  value: db.settings.enableEdgeSwipePopGesture,
                  title: Text(S.current.edge_swipe_pop_gesture),
                  onChanged: (v) {
                    setState(() {
                      db.settings.enableEdgeSwipePopGesture = v;
                    });
                    db.notifyAppUpdate();
                  },
                ),
              if (PlatformU.isTargetDesktop)
                SwitchListTile.adaptive(
                  value: db.settings.enableMouseDrag,
                  title: Text(S.current.setting_drag_by_mouse),
                  subtitle: Text(S.current.desktop_only),
                  onChanged: (v) {
                    setState(() {
                      db.settings.enableMouseDrag = v;
                    });
                    db.notifyAppUpdate();
                  },
                ),
              SwitchListTile.adaptive(
                value: db.settings.globalSelection,
                title: Text(S.current.global_text_selection),
                // subtitle: Text(S.current.desktop_only),
                onChanged: (v) {
                  setState(() {
                    db.settings.globalSelection = v;
                  });
                  db.notifyAppUpdate();
                },
              ),
              if (PlatformU.isDesktop) ...[
                SwitchListTile.adaptive(
                  value: db.settings.showSystemTray,
                  title: Text(S.current.show_system_tray),
                  subtitle: Text(S.current.system_tray_close_hint),
                  onChanged: (v) {
                    setState(() {
                      db.settings.showSystemTray = v;
                    });
                    AppWindowUtil.toggleTray(v);
                  },
                ),
              ],
              if (AppAds.instance.supported || kDebugMode)
                ListTile(
                  title: Text(S.current.ad),
                  trailing: const Icon(Icons.keyboard_arrow_right),
                  onTap: () {
                    router.pushPage(const AdSettingPage());
                  },
                ),
              if (LocalNotificationUtil.supported)
                ListTile(
                  title: const Text('Request Notification Permissions'),
                  onTap: () async {
                    try {
                      final result = await LocalNotificationUtil.requestPermissions();
                      if (result == true) {
                        EasyLoading.showSuccess(S.current.success);
                        LocalNotificationUtil.showNotification(
                          title: 'Chaldea',
                          body: 'LINK START!\n${DateTime.now().toCustomString(year: false)}',
                        );
                      } else {
                        EasyLoading.showError(result.toString());
                      }
                    } catch (e, s) {
                      EasyLoading.showError(e.toString());
                      logger.e('request notification permission failed', e, s);
                    }
                  },
                  onLongPress: () {
                    InputCancelOkDialog(
                      title: 'Notify after seconds',
                      keyboardType: TextInputType.number,
                      validate: (s) => (int.tryParse(s) ?? -1) > 0,
                      onSubmit: (s) {
                        LocalNotificationUtil.scheduleNotification(
                          title: 'Chaldea',
                          body: 'LINK START!\n${DateTime.now().toCustomString(year: false)}',
                          dateTime: DateTime.now().add(Duration(seconds: int.parse(s))),
                        );
                      },
                    ).showDialog(context);
                  },
                ),
            ],
          ),
        ],
      ),
    );
  }
}
