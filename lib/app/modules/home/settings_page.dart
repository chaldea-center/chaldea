import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

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
import 'subpage/network_settings.dart';
import 'subpage/share_app_dialog.dart';
import 'subpage/theme_color.dart';
import 'subpage/translation_setting.dart';
import 'subpage/user_data_page.dart';

class SettingsPage extends StatefulWidget {
  SettingsPage({super.key});

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
        toolbarHeight: kToolbarHeight,
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
                title: Text(S.current.network_settings),
                trailing: Icon(DirectionalIcons.keyboard_arrow_forward(context)),
                onTap: () {
                  router.popDetailAndPush(child: const NetworkSettingsPage());
                },
              ),
            ],
          ),
          SliverTileGroup(
            header: S.current.game_account,
            children: [
              ListTile(
                title: Text(S.current.cur_account),
                trailing: _wrapArrowTrailing(db.onUserData((context, snapshot) => Text(db.curUser.name))),
                onTap: () {
                  router.popDetailAndPush(child: AccountPage());
                },
              ),
              ListTile(
                title: Text(S.current.game_server),
                trailing: _wrapArrowTrailing(db.onUserData((context, snapshot) => Text(db.curUser.region.localName))),
                onTap: () {
                  router.popDetailAndPush(child: GameServerPage());
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
                trailing: Icon(DirectionalIcons.keyboard_arrow_forward(context)),
                onTap: () {
                  router.popDetailAndPush(child: UserDataPage());
                },
              ),
              ListTile(
                title: Text(S.current.gamedata),
                trailing: db.onUserData((context, snapshot) => _wrapArrowTrailing(Text(
                      db.gameData.version.text(true),
                      textAlign: TextAlign.end,
                    ))),
                onTap: () {
                  router.popDetailAndPush(child: GameDataPage());
                },
              ),
              ListTile(
                title: Text(S.current.preferred_translation),
                trailing: db.onSettings((context, _) {
                  final region = db.settings.resolvedPreferredRegions.first;
                  return _wrapArrowTrailing(Text('${region.language.name}(${region.localName})'));
                }),
                onTap: () {
                  router.popDetailAndPush(child: TranslationSetting());
                },
              ),
              ListTile(
                title: Text(Language.isZH ? '协助翻译！' : 'Help Translation!'),
                trailing: const Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Icon(Icons.sos),
                    SizedBox(width: 8),
                    Icon(Icons.translate, size: 20),
                  ],
                ),
                onTap: () {
                  launch(ChaldeaUrl.doc('translation'));
                },
              ),
            ],
          ),
          SliverTileGroup(
            header: S.current.settings_general,
            children: <Widget>[
              ListTile(
                title: Text(S.current.settings_language),
                subtitle: Language.isEN ? const Text('语言') : const Text('Language'),
                trailing: db.onSettings(
                  (context, snapshot) => DropdownButton<Language>(
                    underline: const Divider(thickness: 0, color: Colors.transparent),
                    // need to check again
                    alignment: AlignmentDirectional.centerEnd,
                    value: Language.getLanguage(S.current.localeName),
                    items: Language.supportLanguages
                        .map((lang) => DropdownMenuItem(
                            value: lang,
                            child: Text.rich(
                              TextSpan(text: lang.name, children: [
                                TextSpan(
                                  text: '\n${lang.nameEn}',
                                  style: Theme.of(context).textTheme.bodySmall,
                                )
                              ]),
                              textScaleFactor: 0.9,
                            )))
                        .toList(),
                    selectedItemBuilder: (context) {
                      return Language.supportLanguages
                          .map((lang) => DropdownMenuItem(
                                  child: Text.rich(
                                TextSpan(text: lang.name, children: [
                                  TextSpan(
                                    text: '\n${lang.nameEn}',
                                    style: Theme.of(context).textTheme.bodySmall,
                                  )
                                ]),
                                textScaleFactor: 0.9,
                                textAlign: TextAlign.end,
                              )))
                          .toList();
                    },
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
                    alignment: AlignmentDirectional.centerEnd,
                    items: [
                      DropdownMenuItem(value: ThemeMode.system, child: Text(S.current.dark_mode_system)),
                      DropdownMenuItem(value: ThemeMode.light, child: Text(S.current.dark_mode_light)),
                      DropdownMenuItem(value: ThemeMode.dark, child: Text(S.current.dark_mode_dark)),
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
                title: const Text('Theme Color'),
                trailing: Icon(DirectionalIcons.keyboard_arrow_forward(context)),
                onTap: () {
                  router.popDetailAndPush(child: const ThemeColorPage());
                },
              ),
              ListTile(
                title: Text(S.current.display_setting),
                trailing: Icon(DirectionalIcons.keyboard_arrow_forward(context)),
                onTap: () {
                  router.popDetailAndPush(child: DisplaySettingPage());
                },
              ),
              if (kIsWeb)
                ListTile(
                  title: Text(S.current.web_renderer),
                  subtitle: Text(S.current.restart_to_apply_changes),
                  trailing: DropdownButton<WebRenderMode>(
                    value: db.runtimeData.webRendererCanvasKit ??
                        (kPlatformMethods.rendererCanvasKit ? WebRenderMode.canvaskit : WebRenderMode.html),
                    underline: const SizedBox(),
                    items: [
                      for (final value in WebRenderMode.values)
                        DropdownMenuItem(
                          value: value,
                          child: Text(value.name, textAlign: TextAlign.end),
                        ),
                    ],
                    onChanged: (v) {
                      if (v != null) {
                        kPlatformMethods.setLocalStorage('flutterWebRenderer', v.name);
                        db.runtimeData.webRendererCanvasKit = v;
                        setState(() {});
                      }
                    },
                  ),
                )
            ],
          ),
          SliverTileGroup(
            header: S.current.about_app,
            children: <Widget>[
              ListTile(
                title: Text(MaterialLocalizations.of(context).aboutListTileTitle(AppInfo.appName)),
                trailing: db.runtimeData.upgradableVersion == null
                    ? Icon(DirectionalIcons.keyboard_arrow_forward(context))
                    : Text(
                        '${db.runtimeData.upgradableVersion!.versionString} ↑',
                        style: TextStyle(color: Theme.of(context).colorScheme.error.withAlpha(200)),
                      ),
                onTap: () => router.popDetailAndPush(child: AboutPage()),
              ),
              ListTile(
                title: Text(S.current.about_feedback),
                trailing: Icon(DirectionalIcons.keyboard_arrow_forward(context)),
                onTap: () {
                  router.popDetailAndPush(child: FeedbackPage());
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
                title: Text(S.current.settings_documents),
                subtitle: Text(ChaldeaUrl.docHome),
                trailing: const Icon(Icons.menu_book),
                onTap: () {
                  launch(ChaldeaUrl.docHome);
                },
              ),
              if (!db.settings.hideApple)
                ListTile(
                  title: Text(S.current.support_chaldea),
                  trailing: const Icon(Icons.favorite),
                  onTap: () {
                    launch(ChaldeaUrl.doc('donation'));
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
                if (!kReleaseMode)
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
                      FrameRateLayer.createOverlay(kAppKey.currentContext ?? context);
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
                SwitchListTile.adaptive(
                  value: db.runtimeData.showSkillOriginText,
                  title: const Text('Show original skill/NP detail'),
                  onChanged: (v) {
                    setState(() {
                      db.runtimeData.showSkillOriginText = v;
                    });
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
    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      children: <Widget>[trailing, Icon(DirectionalIcons.keyboard_arrow_forward(context))],
    );
  }

  Widget get userTile {
    return ListTile(
      leading: const Icon(Icons.person),
      // horizontalTitleGap: 0,
      title: Text(S.current.login_username),
      trailing: db.onSettings((context, snapshot) => Text(db.security.username ?? '')),
      onTap: () {
        router.popDetailAndPush(child: LoginPage());
      },
    );
  }
}
