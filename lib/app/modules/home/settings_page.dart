import 'package:chaldea/_test_page.dart';
import 'package:chaldea/app/app.dart';
import 'package:chaldea/app/modules/common/frame_rate_layer.dart';
import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/models/models.dart';
import 'package:chaldea/packages/app_info.dart';
import 'package:chaldea/packages/language.dart';
import 'package:chaldea/packages/platform/platform.dart';
import 'package:chaldea/packages/split_route/split_route.dart';
import 'package:chaldea/utils/utils.dart';
import 'package:chaldea/widgets/tile_items.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../root/global_fab.dart';
import 'subpage/about_page.dart';
import 'subpage/account_page.dart';
import 'subpage/display_setting_page.dart';
import 'subpage/feedback_page.dart';
import 'subpage/game_data_page.dart';
import 'subpage/game_server_page.dart';
import 'subpage/share_app_dialog.dart';
import 'subpage/support_donation_page.dart';
import 'subpage/translation_setting.dart';
import 'subpage/user_data_page.dart';

class SettingsPage extends StatefulWidget {
  SettingsPage({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  // avoid PrimaryController error
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
  }

  @override
  void dispose() {
    super.dispose();
    _scrollController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(S.current.settings_tab_name),
        titleSpacing: NavigationToolbar.kMiddleSpacing,
      ),
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          SliverTileGroup(
            header: 'Chaldea User',
            children: [userTile],
          ),
          SliverTileGroup(
            header: S.current.cur_account,
            children: [
              ListTile(
                title: Text(S.current.cur_account),
                trailing: _wrapArrowTrailing(db2
                    .onUserData((context, snapshot) => Text(db2.curUser.name))),
                onTap: () {
                  router.push(child: AccountPage());
                },
              ),
              ListTile(
                title: Text(S.current.server),
                trailing: _wrapArrowTrailing(db2.onUserData(
                    (context, snapshot) =>
                        Text(EnumUtil.upperCase(db2.curUser.region)))),
                onTap: () {
                  router.push(child: GameServerPage());
                },
              ),
            ],
          ),
          SliverTileGroup(
            header: S.current.event_progress,
            footer:
                '${S.current.limited_event}/${S.current.main_record}/${S.current.summon}',
            children: const [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: ListTile(
                  title: Text('TODO'),
                ),
              ),
            ],
          ),
          SliverTileGroup(
            header: S.current.settings_data,
            children: <Widget>[
              ListTile(
                title: Text(S.current.userdata),
                trailing:
                    Icon(DirectionalIcons.keyboard_arrow_forward(context)),
                onTap: () {
                  router.push(child: UserDataPage());
                },
              ),
              ListTile(
                title: Text(S.current.gamedata),
                trailing: db2
                    .onUserData((context, snapshot) => _wrapArrowTrailing(Text(
                          db2.gameData.version.text(true),
                          textAlign: TextAlign.end,
                        ))),
                onTap: () {
                  router.push(child: GameDataPage());
                },
              ),
            ],
          ),
          SliverTileGroup(
            header: S.current.settings_general,
            children: <Widget>[
              ListTile(
                title: Text(S.current.settings_language),
                subtitle:
                    Language.isEN ? const Text('语言') : const Text('Language'),
                trailing: db2.onSettings(
                  (context, snapshot) => DropdownButton<Language>(
                    underline:
                        const Divider(thickness: 0, color: Colors.transparent),
                    // need to check again
                    value: Language.getLanguage(db2.settings.language),
                    items: Language.supportLanguages
                        .map((lang) => DropdownMenuItem(
                            value: lang, child: Text(lang.name)))
                        .toList(),
                    onChanged: (lang) {
                      if (lang == null) return;
                      db2.settings.setLanguage(lang);
                      db2.saveSettings();
                      db2.notifyAppUpdate();
                      db2.notifySettings();
                    },
                  ),
                ),
              ),
              ListTile(
                title: const Text('Translations'),
                trailing: db2.onSettings((context, _) => _wrapArrowTrailing(
                    Text(db2.settings.resolvedPreferredRegions.first
                        .toUpper()))),
                onTap: () {
                  router.push(child: TranslationSetting());
                },
              ),
              ListTile(
                title: Text(S.current.dark_mode),
                trailing: db2.onSettings(
                  (context, snapshot) => DropdownButton<ThemeMode>(
                    value: db2.settings.themeMode,
                    underline: Container(),
                    items: [
                      DropdownMenuItem(
                          child: Text(S.current.dark_mode_system),
                          value: ThemeMode.system),
                      DropdownMenuItem(
                          child: Text(S.current.dark_mode_light),
                          value: ThemeMode.light),
                      DropdownMenuItem(
                          child: Text(S.current.dark_mode_dark),
                          value: ThemeMode.dark),
                    ],
                    onChanged: (v) {
                      if (v != null) {
                        db2.settings.themeMode = v;
                        db2.saveSettings();
                        db2.notifySettings();
                        db2.notifyAppUpdate();
                      }
                    },
                  ),
                ),
              ),
              ListTile(
                title: Text(S.current.display_setting),
                trailing:
                    Icon(DirectionalIcons.keyboard_arrow_forward(context)),
                onTap: () {
                  SplitRoute.push(
                    context,
                    DisplaySettingPage(),
                    popDetail: true,
                  );
                },
              ),
              if (kIsWeb)
                ListTile(
                  title: const Text('Web Renderer'),
                  subtitle: const Text('Restart to take effect'),
                  trailing: DropdownButton<WebRenderMode>(
                    value: db2.runtimeData.webRendererCanvasKit ??
                        (kPlatformMethods.rendererCanvasKit
                            ? WebRenderMode.canvaskit
                            : WebRenderMode.html),
                    underline: const SizedBox(),
                    items: [
                      for (final value in WebRenderMode.values)
                        DropdownMenuItem(
                          child: Text(value.name, textAlign: TextAlign.end),
                          value: value,
                        ),
                    ],
                    onChanged: (v) {
                      if (v != null) {
                        kPlatformMethods.setLocalStorage(
                            'flutterWebRenderer', v.name);
                        db2.runtimeData.webRendererCanvasKit = v;
                        setState(() {});
                      }
                    },
                  ),
                )
            ],
          ),
          SliverTileGroup(
            header: S.of(context).about_app,
            children: <Widget>[
              ListTile(
                title: Text(MaterialLocalizations.of(context)
                    .aboutListTileTitle(AppInfo.appName)),
                trailing: db2.runtimeData.upgradableVersion == null
                    ? Icon(DirectionalIcons.keyboard_arrow_forward(context))
                    : Text(
                        db2.runtimeData.upgradableVersion!.versionString + ' ↑',
                      ),
                onTap: () => SplitRoute.push(
                  context,
                  AboutPage(),
                  popDetail: true,
                ).then((_) {
                  if (mounted) setState(() {});
                }),
              ),
              ListTile(
                title: Text(S.current.about_feedback),
                trailing:
                    Icon(DirectionalIcons.keyboard_arrow_forward(context)),
                onTap: () {
                  SplitRoute.push(context, FeedbackPage(), popDetail: true);
                },
              ),
              ListTile(
                title: const Text('Bootstrap Page'),
                onTap: () {
                  db2.settings.tips.starter = true;
                  rootRouter.appState.dataReady = false;
                },
              ),
              ListTile(
                title: Text(S.of(context).settings_documents),
                subtitle: const Text(kProjectDocRoot),
                trailing: const Icon(Icons.menu_book),
                onTap: () {
                  launch(
                      joinUrl(kProjectDocRoot, (Language.isZH ? '/zh/' : '/')));
                },
              ),
              if (!PlatformU.isApple || db2.settings.launchTimes > 5)
                ListTile(
                  title: Text(S.current.support_chaldea),
                  trailing: const Icon(Icons.favorite),
                  onTap: () {
                    SplitRoute.push(
                      context,
                      SupportDonationPage(),
                      popDetail: true,
                    );
                  },
                ),
              if (PlatformU.isApple)
                ListTile(
                  title: Text(S.current.rate_app_store),
                  trailing: const Icon(Icons.star_half_rounded),
                  onTap: () {
                    launch(kAppStoreLink);
                  },
                ),
              if (PlatformU.isAndroid)
                ListTile(
                  title: Text(S.current.rate_play_store),
                  trailing: const Icon(Icons.star_half_rounded),
                  onTap: () {
                    launch(kGooglePlayLink);
                  },
                ),
              ListTile(
                title: Text(S.current.share),
                trailing: const Icon(Icons.ios_share),
                onTap: () => ShareAppDialog().showDialog(context),
              ),
            ],
          ),
          if (db2.runtimeData.enableDebugTools)
            SliverTileGroup(
              header: 'Debug',
              children: <Widget>[
                ListTile(
                  title: const Text('Test Func'),
                  onTap: () => testFunction(context),
                ),
                SwitchListTile.adaptive(
                  value: FrameRateLayer.showFps,
                  title: const Text('Show Frame Rate'),
                  onChanged: (v) {
                    setState(() {
                      FrameRateLayer.showFps = v;
                    });
                    if (v) {
                      FrameRateLayer.createOverlay(context);
                    } else {
                      FrameRateLayer.removeOverlay();
                    }
                  },
                ),
                SwitchListTile.adaptive(
                  value: db2.settings.showDebugFab,
                  title: const Text('Debug FAB'),
                  onChanged: (v) {
                    setState(() {
                      db2.settings.showDebugFab = v;
                      db2.saveSettings();
                    });
                    if (v) {
                      DebugFab.createOverlay(context);
                    } else {
                      DebugFab.removeOverlay();
                    }
                  },
                ),
                ListTile(
                  title: const Text('Master-Detail width'),
                  trailing: DropdownButtonHideUnderline(
                    child: DropdownButton<double>(
                      value: db2.runtimeData.criticalWidth ?? 768,
                      items: const <DropdownMenuItem<double>>[
                        DropdownMenuItem(value: 768, child: Text('768')),
                        DropdownMenuItem(value: 600, child: Text('600'))
                      ],
                      onChanged: (v) {
                        db2.runtimeData.criticalWidth = v;
                        db2.notifyAppUpdate();
                      },
                    ),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _wrapArrowTrailing(Widget trailing) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        trailing,
        Icon(DirectionalIcons.keyboard_arrow_forward(context))
      ],
    );
  }

  Widget get userTile {
    return ListTile(
      title: Text(S.current.login_username),
      trailing: const Text('NotAvailable'),
    );
  }
}
