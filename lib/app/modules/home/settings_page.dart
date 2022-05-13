import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:url_launcher/url_launcher.dart';

import 'package:chaldea/_test_page.dart';
import 'package:chaldea/app/app.dart';
import 'package:chaldea/app/modules/common/frame_rate_layer.dart';
import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/models/models.dart';
import 'package:chaldea/packages/app_info.dart';
import 'package:chaldea/packages/language.dart';
import 'package:chaldea/packages/platform/platform.dart';
import 'package:chaldea/utils/utils.dart';
import 'package:chaldea/widgets/tile_items.dart';
import '../root/global_fab.dart';
import 'subpage/about_page.dart';
import 'subpage/account_page.dart';
import 'subpage/display_setting_page.dart';
import 'subpage/feedback_page.dart';
import 'subpage/game_data_page.dart';
import 'subpage/game_server_page.dart';
import 'subpage/login_page.dart';
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
            header: S.current.chaldea_account,
            children: [
              userTile,
              ListTile(
                leading: const Icon(Icons.dns),
                title: Text(S.current.chaldea_server),
                // subtitle: Text(S.current.chaldea_server_hint),
                horizontalTitleGap: 0,
                trailing: DropdownButton<bool>(
                  value: db.settings.proxyServer,
                  underline: const SizedBox(),
                  items: [
                    DropdownMenuItem(
                      child: Text(S.current.chaldea_server_global),
                      value: false,
                    ),
                    DropdownMenuItem(
                      child: Text(S.current.chaldea_server_cn),
                      value: true,
                    ),
                  ],
                  onChanged: (v) {
                    setState(() {
                      if (v != null) {
                        db.settings.proxyServer = v;
                      }
                      if (kIsWeb) {
                        kPlatformMethods.setLocalStorage(
                            'useProxy', v.toString());
                      }
                      db.saveSettings();
                    });
                  },
                ),
              ),
            ],
          ),
          SliverTileGroup(
            header: S.current.game_account,
            children: [
              ListTile(
                title: Text(S.current.cur_account),
                trailing: _wrapArrowTrailing(db
                    .onUserData((context, snapshot) => Text(db.curUser.name))),
                onTap: () {
                  router.push(child: AccountPage());
                },
              ),
              ListTile(
                title: Text(S.current.game_server),
                trailing: _wrapArrowTrailing(db.onUserData(
                    (context, snapshot) => Text(db.curUser.region.localName))),
                onTap: () {
                  router.push(child: GameServerPage());
                },
              ),
            ],
          ),
          // SliverTileGroup(
          //   header: S.current.event_progress,
          //   footer:
          //       '${S.current.limited_event}/${S.current.main_story}/${S.current.summon}',
          //   children: const [
          //     Padding(
          //       padding: EdgeInsets.symmetric(horizontal: 16),
          //       child: ListTile(
          //         title: Text('TODO'),
          //       ),
          //     ),
          //   ],
          // ),
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
                trailing: db
                    .onUserData((context, snapshot) => _wrapArrowTrailing(Text(
                          db.gameData.version.text(true),
                          textAlign: TextAlign.end,
                        ))),
                onTap: () {
                  router.push(child: GameDataPage());
                },
              ),
              ListTile(
                title: Text(S.current.preferred_translation),
                trailing: db.onSettings((context, _) {
                  final region = db.settings.resolvedPreferredRegions.first;
                  return _wrapArrowTrailing(
                      Text('${region.toLanguage().name}(${region.localName})'));
                }),
                onTap: () {
                  router.push(child: TranslationSetting());
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
                trailing: db.onSettings(
                  (context, snapshot) => DropdownButton<Language>(
                    underline:
                        const Divider(thickness: 0, color: Colors.transparent),
                    // need to check again
                    value: Language.getLanguage(S.current.localeName),
                    items: Language.supportLanguages
                        .map((lang) => DropdownMenuItem(
                            value: lang, child: Text(lang.name)))
                        .toList(),
                    onChanged: (lang) {
                      if (lang == null) return;
                      db.settings.setLanguage(lang);
                      db.saveSettings();
                      db.notifyAppUpdate();
                      db.notifySettings();
                    },
                  ),
                ),
              ),
              ListTile(
                title: Text(S.current.dark_mode),
                trailing: db.onSettings(
                  (context, snapshot) => DropdownButton<ThemeMode>(
                    value: db.settings.themeMode,
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
                        db.settings.themeMode = v;
                        db.saveSettings();
                        db.notifySettings();
                        db.notifyAppUpdate();
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
                  router.push(child: DisplaySettingPage());
                },
              ),
              if (kIsWeb)
                ListTile(
                  title: Text(S.current.web_renderer),
                  subtitle: Text(S.current.restart_to_apply_changes),
                  trailing: DropdownButton<WebRenderMode>(
                    value: db.runtimeData.webRendererCanvasKit ??
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
                        db.runtimeData.webRendererCanvasKit = v;
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
                trailing: db.runtimeData.upgradableVersion == null
                    ? Icon(DirectionalIcons.keyboard_arrow_forward(context))
                    : Text(
                        db.runtimeData.upgradableVersion!.versionString + ' ↑',
                        style: TextStyle(
                            color: Theme.of(context).errorColor.withAlpha(200)),
                      ),
                onTap: () => router.push(child: AboutPage()),
              ),
              ListTile(
                title: Text(S.current.about_feedback),
                trailing:
                    Icon(DirectionalIcons.keyboard_arrow_forward(context)),
                onTap: () {
                  router.push(child: FeedbackPage());
                },
              ),
              ListTile(
                title: Text(S.current.bootstrap_page_title),
                onTap: () {
                  db.settings.tips.starter = true;
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
              if (!PlatformU.isApple || db.settings.launchTimes > 5)
                ListTile(
                  title: Text(S.current.support_chaldea),
                  trailing: const Icon(Icons.favorite),
                  onTap: () {
                    router.push(child: SupportDonationPage());
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
          if (db.runtimeData.enableDebugTools)
            SliverTileGroup(
              header: S.current.debug,
              children: <Widget>[
                ListTile(
                  title: const Text('Test Func'),
                  onTap: () => testFunction(context),
                ),
                SwitchListTile.adaptive(
                  value: FrameRateLayer.showFps,
                  title: Text(S.current.show_frame_rate),
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
                  value: db.settings.showDebugFab,
                  title: Text(S.current.debug_fab),
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
                ListTile(
                  title: Text(S.current.master_detail_width),
                  trailing: DropdownButtonHideUnderline(
                    child: DropdownButton<double>(
                      value: db.runtimeData.criticalWidth ?? 768,
                      items: const <DropdownMenuItem<double>>[
                        DropdownMenuItem(value: 768, child: Text('768')),
                        DropdownMenuItem(value: 600, child: Text('600'))
                      ],
                      onChanged: (v) {
                        db.runtimeData.criticalWidth = v;
                        db.notifyAppUpdate();
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
      leading: const Icon(Icons.person),
      horizontalTitleGap: 0,
      title: Text(S.current.login_username),
      trailing: db.onSettings(
          (context, snapshot) => Text(db.security.get('chaldea_user') ?? '')),
      onTap: () {
        router.push(child: LoginPage());
      },
    );
  }
}
