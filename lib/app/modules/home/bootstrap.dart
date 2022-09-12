import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import 'package:chaldea/app/app.dart';
import 'package:chaldea/app/tools/gamedata_loader.dart';
import 'package:chaldea/models/models.dart';
import 'package:chaldea/packages/app_info.dart';
import 'package:chaldea/packages/platform/platform.dart';
import 'package:chaldea/utils/img_util.dart';
import 'package:chaldea/utils/utils.dart';
import 'package:chaldea/widgets/widgets.dart';
import '../../../generated/l10n.dart';
import '../../../packages/language.dart';
import '../../../packages/logger.dart';
import '../../../packages/network.dart';

class BootstrapPage extends StatefulWidget {
  BootstrapPage({Key? key}) : super(key: key);

  @override
  _BootstrapPageState createState() => _BootstrapPageState();
}

class _BootstrapPageState extends State<BootstrapPage>
    with SingleTickerProviderStateMixin, AfterLayoutMixin {
  late PageController _pageController;
  late TextEditingController _accountEditing;
  int page = 0;
  List<Widget> pages = [];
  final _loader = GameDataLoader();
  bool _offlineLoading = true;
  bool invalidStartup = false;
  bool _fa_ = false;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _accountEditing = TextEditingController(text: db.curUser.name);

    if (PlatformU.isWindows) {
      final startupPath = db.paths.appPath.toLowerCase();
      if (startupPath.contains(r'appdata\local\temp') ||
          startupPath.contains(r'c:\program files')) {
        invalidStartup = true;
      }
      try {
        File(joinPaths(db.paths.appPath, 'chaldea.ignore'))
          ..writeAsStringSync('  ')
          ..deleteSync();
      } catch (e) {
        invalidStartup = true;
      }
    }
  }

  @override
  void afterFirstLayout(BuildContext context) async {
    if (invalidStartup) return;
    _fa_ = AppInfo.packageName.startsWith(_d('Y29tLmxkcy4='));
    if (_fa_) return;
    try {
      if (!db.settings.tips.starter) {
        final data = await _loader.reload(
          offline: true,
          silent: true,
          onUpdate: (v) {
            if (mounted) setState(() {});
          },
        );
        if (data != null) {
          db.gameData = data;
          onDataReady(true);
        } else {
          _offlineLoading = false;
        }
      }
    } catch (e, s) {
      _offlineLoading = false;
      if (e is! UpdateError) logger.e('init data error', e, s);
    } finally {
      if (mounted) setState(() {});
    }
  }

  String _d(String s) {
    return utf8.decode(base64Decode(s));
  }

  @override
  Widget build(BuildContext context) {
    if (_fa_) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _d('U29tZXRoaW5nIHdlbnQgd3Jvbmch'),
                style: Theme.of(context).textTheme.headline4,
                textAlign: TextAlign.center,
              ),
              TextButton(
                onPressed: () {
                  launch(kGooglePlayLink);
                },
                child: Text(_d('UmVkb3dubG9hZCA=') + kPackageName),
              ),
              const SizedBox(height: 48),
              SFooter(_d(
                  '64u57Iug7J2AIOyVhOuniCDrtojrspUg67O17KCcIOyGjO2UhO2KuOybqOyWtOydmCDtlLztlbTsnpDsnbwg6rKD7J2064uk')),
            ],
          ),
        ),
      );
    }
    if (invalidStartup) {
      pages = [
        StartupFailedPage(
          error: '${S.current.invalid_startup_path}\n'
              '${db.paths.appPath}\n\n'
              '${S.current.invalid_startup_path_info}',
        )
      ];
    } else if (db.settings.tips.starter) {
      pages = [
        welcomePage,
        languagePage,
        if (kIsWeb) webDomainPage,
        darkModePage,
        createAccountPage,
        dataPage,
      ];
    } else if (_offlineLoading) {
      pages = [_OfflineLoadingPage(progress: _loader.progress)];
    } else {
      pages = [dataPage];
    }
    Widget child = PageView(
      controller: _pageController,
      children: pages,
      onPageChanged: (i) {
        FocusScope.of(context)
            .requestFocus(FocusNode()); //Dismiss keyboard on page change
        setState(() {
          page = i;
        });
      },
    );

    if (!invalidStartup && (db.settings.tips.starter || !_offlineLoading)) {
      child = Stack(children: [child, _bottom()]);
    }
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 0,
        elevation: 0,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 768),
            child: child,
          ),
        ),
      ),
    );
  }

  Widget get welcomePage {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 20),
          child: Image.asset(
            // 'res/img/chaldea.png',
            'res/img/launcher_icon/app_icon_logo.png',
            width: 180,
          ),
        ),
        Text(
          'Chaldea',
          style: Theme.of(context).textTheme.headline4,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),
        _AnimatedHello(),
        const SizedBox(height: 100)
      ],
    );
  }

  Widget get languagePage {
    return _IntroPage(
      icon: FontAwesomeIcons.earthAsia,
      title: S.current.select_lang,
      content: ListView.separated(
        itemBuilder: (context, index) {
          final lang = Language.supportLanguages[index];
          return ListTile(
            leading: Language.getLanguage(db.settings.language) == lang
                ? const Icon(Icons.done_rounded)
                : const SizedBox(),
            title: Text(lang.name),
            horizontalTitleGap: 0,
            onTap: () {
              db.settings.setLanguage(lang);
              db.saveSettings();
              db.notifyAppUpdate();
            },
          );
        },
        separatorBuilder: (context, _) => const Divider(
          height: 1,
          indent: 48,
          endIndent: 48,
        ),
        itemCount: Language.supportLanguages.length,
      ),
    );
  }

  Widget get webDomainPage {
    final cnDomain = Uri.parse('https://cn.chaldea.center'),
        globalDomain = Uri.parse('https://chaldea.center');
    Widget _tile(bool isCN) {
      final domain = isCN ? cnDomain : globalDomain;
      bool selected = Uri.base.host == domain.host;
      return ListTile(
        leading: selected ? const Icon(Icons.done_rounded) : const SizedBox(),
        title: Text(isCN
            ? S.current.chaldea_server_cn
            : S.current.chaldea_server_global),
        subtitle: Text(domain.toString()),
        horizontalTitleGap: 0,
        trailing: selected ? null : const Icon(Icons.open_in_new),
        onTap: selected
            ? null
            : () {
                launch(domain.toString());
              },
      );
    }

    return _IntroPage(
      icon: FontAwesomeIcons.link,
      title: 'Domains',
      content: ListView(
        children: [
          _tile(false),
          _tile(true),
          ListTile(
            leading: const SizedBox(),
            title: const Text('Native App'),
            subtitle: const Text('Android/iOS/Windows/macOS/Linux'),
            horizontalTitleGap: 0,
            trailing: const Icon(Icons.open_in_new),
            onTap: () {
              launch(HttpUrlHelper.projectDocUrl('installation.html'));
            },
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 12),
            child: Text(
              S.current.download_source_hint,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.caption,
            ),
          )
        ],
      ),
    );
  }

  String _themeModeName(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.dark:
        return S.current.dark_mode_dark;
      case ThemeMode.light:
        return S.current.dark_mode_light;
      default:
        return S.current.dark_mode_system;
    }
  }

  Widget get darkModePage {
    return _IntroPage(
      icon: FontAwesomeIcons.circleHalfStroke,
      title: S.current.dark_mode,
      content: ListView.separated(
        itemBuilder: (context, index) {
          final mode = ThemeMode.values[index];
          return ListTile(
            leading: db.settings.themeMode == mode
                ? const Icon(Icons.done_rounded)
                : const SizedBox(),
            title: Text(_themeModeName(mode)),
            horizontalTitleGap: 0,
            onTap: () {
              db.settings.themeMode = mode;
              db.saveSettings();
              db.notifyAppUpdate();
            },
          );
        },
        separatorBuilder: (context, _) => const Divider(
          height: 1,
          indent: 48,
          endIndent: 48,
        ),
        itemCount: ThemeMode.values.length,
      ),
    );
  }

  Widget get createAccountPage {
    return _IntroPage(
      icon: FontAwesomeIcons.gamepad,
      title: 'Fate/GO',
      content: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextFormField(
              controller: _accountEditing,
              decoration: InputDecoration(
                border: const OutlineInputBorder(),
                labelText: S.current.account_title,
                helperText: S.current.create_account_textfield_helper,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            S.current.game_server,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          ...divideTiles(
            List.generate(Region.values.length, (index) {
              final region = Region.values[index];
              return ListTile(
                leading: region == db.curUser.region
                    ? const Icon(Icons.done)
                    : const SizedBox(),
                title: Text(region.localName),
                horizontalTitleGap: 0,
                onTap: () {
                  setState(() {
                    db.curUser.region = region;
                  });
                },
              );
            }),
            divider: const Divider(
              height: 1,
              indent: 48,
              endIndent: 48,
            ),
          ),
        ],
      ),
    );
  }

  Widget get dataPage {
    return _IntroPage(
      icon: FontAwesomeIcons.database,
      title: S.current.database,
      content: _DatabaseIntro(),
    );
  }

  Widget _bottom() {
    return PositionedDirectional(
      bottom: 10.0,
      start: 10.0,
      end: 10.0,
      child: Row(
        children: <Widget>[
          page <= 0
              ? const SizedBox(width: 64)
              : TextButton(
                  child: Text(S.current.prev_page),
                  onPressed: () {
                    _pageController.previousPage(
                      duration: kTabScrollDuration,
                      curve: Curves.easeInOut,
                    );
                  },
                ),
          Expanded(
            flex: 2,
            child: Center(
              child: SmoothPageIndicator(
                controller: _pageController,
                count: pages.length,
                effect: const WormEffect(
                    dotHeight: 10, dotWidth: 10, activeDotColor: Colors.blue),
                onDotClicked: (i) {
                  setState(() {
                    page = i;
                    _pageController.animateToPage(
                      i,
                      duration: kTabScrollDuration,
                      curve: Curves.easeInOut,
                    );
                  });
                },
              ),
            ),
          ),
          page >= pages.length - 1
              ? TextButton(
                  child: Text(S.current.done),
                  onPressed: () {
                    if (db.gameData.version.timestamp > 0) {
                      db.settings.tips.starter = false;
                      onDataReady(false);
                      db.saveSettings();
                    } else {
                      showDialog(
                        context: context,
                        useRootNavigator: false,
                        builder: (context) => SimpleCancelOkDialog(
                          content: Text(S.current.database_not_downloaded),
                          onTapOk: () {
                            db.settings.tips.starter = false;
                            db.saveSettings();
                            onDataReady(false);
                          },
                        ),
                      );
                    }
                  },
                )
              : TextButton(
                  child: Text(S.current.next_page),
                  onPressed: () {
                    _pageController.nextPage(
                      duration: kTabScrollDuration,
                      curve: Curves.easeInOut,
                    );
                  },
                ),
        ],
      ),
    );
  }

  void onDataReady(bool needCheckUpdate) async {
    needCheckUpdate = needCheckUpdate && db.settings.autoUpdateData;
    print('onDataReady: needCheckUpdate=$needCheckUpdate');
    rootRouter.appState.dataReady = true;
    if (needCheckUpdate && network.available && kReleaseMode) {
      await Future.delayed(const Duration(seconds: 3));
      await _loader.reload(updateOnly: true, silent: true);
    }
  }

  @override
  void dispose() {
    super.dispose();
    _pageController.dispose();
    _accountEditing.dispose();
  }
}

class _OfflineLoadingPage extends StatelessWidget {
  final double? progress;

  _OfflineLoadingPage({Key? key, this.progress}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Widget img = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: ImageUtil.getChaldeaBackground(context),
    );
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(child: Center(child: img)),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 48),
          child: LinearProgressIndicator(
            value: progress ?? 0,
            color: Theme.of(context).primaryColorLight,
            backgroundColor: Colors.transparent,
          ),
        ),
      ],
    );
  }
}

class _DatabaseIntro extends StatefulWidget {
  _DatabaseIntro({Key? key}) : super(key: key);

  @override
  _DatabaseIntroState createState() => _DatabaseIntroState();
}

class _DatabaseIntroState extends State<_DatabaseIntro> {
  final GameDataLoader _loader = GameDataLoader();
  bool success = false;

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        SwitchListTile.adaptive(
          title: Text(S.current.auto_update),
          value: db.settings.autoUpdateData,
          onChanged: (v) {
            setState(() {
              db.settings.autoUpdateData = v;
              db.saveSettings();
            });
          },
        ),
        ListTile(
          title: Text(S.current.download_source),
          subtitle: Text(S.current.download_source_hint),
          trailing: DropdownButton<bool>(
            value: db.settings.proxyServer,
            items: [
              DropdownMenuItem(
                  value: false, child: Text(S.current.chaldea_server_global)),
              DropdownMenuItem(
                  value: true, child: Text(S.current.chaldea_server_cn)),
            ],
            onChanged: (v) {
              setState(() {
                if (v != null) {
                  db.settings.proxyServer = v;
                }
                db.saveSettings();
              });
            },
          ),
        ),
        ListTile(
          title: Text(S.current.current_version),
          trailing: Text(
            db.gameData.version.timestamp > 0
                ? DateTime.fromMillisecondsSinceEpoch(
                        db.gameData.version.timestamp * 1000)
                    .toStringShort()
                    .replaceFirst(' ', '\n')
                : S.current.not_found,
            textAlign: TextAlign.end,
          ),
        ),
        Center(
          child: ElevatedButton(
            onPressed: () async {
              try {
                setState(() {
                  success = false;
                });
                final gamedata = await _loader.reload(
                  offline: false,
                  silent: false,
                  onUpdate: (v) {
                    if (mounted) setState(() {});
                  },
                );
                if (gamedata != null) {
                  db.gameData = gamedata;
                  success = true;
                }
              } on UpdateError {
                //
              } catch (e, s) {
                logger.e('download gamedata error', e, s);
              }
              if (mounted) setState(() {});
            },
            child: Text(S.current.update),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 32),
          child: Stack(
            alignment: Alignment.center,
            children: [
              if (_loader.progress == 1.0)
                Icon(
                  _loader.error != null ? Icons.clear_rounded : Icons.done,
                  size: 80,
                  color: _loader.error != null
                      ? Theme.of(context).errorColor
                      : Theme.of(context).colorScheme.primary,
                ),
              if (_loader.progress != null && _loader.progress! < 1.0)
                Text(
                  '${(_loader.progress! * 100).toInt()}%',
                  style: const TextStyle(fontSize: 24),
                ),
              Center(
                child: SizedBox(
                  width: 120,
                  height: 120,
                  child: CircularProgressIndicator(
                    value: _loader.progress ?? 0,
                    color: _loader.error != null
                        ? Theme.of(context).errorColor
                        : null,
                    backgroundColor: Theme.of(context).backgroundColor,
                  ),
                ),
              ),
            ],
          ),
        ),
        if (_loader.error != null)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Center(child: Text(escapeDioError(_loader.error))),
          ),
      ],
    );
  }
}

class _IntroPage extends StatelessWidget {
  final IconData? icon;
  final String? title;
  final Widget? content;

  const _IntroPage({Key? key, this.icon, this.title, this.content})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(height: 36),
        if (icon != null)
          FaIcon(
            icon!,
            size: 80,
            color: Theme.of(context).brightness == Brightness.dark
                ? null
                : Theme.of(context).colorScheme.secondary,
          ),
        if (title != null)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Text(title!, style: Theme.of(context).textTheme.headline6),
          ),
        if (content != null) Expanded(child: content!),
        const SizedBox(height: 48),
      ],
    );
  }
}

class _AnimatedHello extends StatefulWidget {
  _AnimatedHello({Key? key}) : super(key: key);

  @override
  _AnimatedHelloState createState() => _AnimatedHelloState();
}

class _AnimatedHelloState extends State<_AnimatedHello> {
  List<String> get _hellos => const [
        // 'φ(≧ω≦*)♪'
        'ヽ(^o^)丿',
        '你好',
        'Hello',
        'こんにちは',
        '哈嘍',
        '안녕하세요',
        '¡Buenas!',
        '\u0645\u0631\u062d\u0628\u0627', // Arabic
      ];
  bool shown = false;
  int index = 0;

  @override
  void initState() {
    super.initState();
    SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
      if (mounted) {
        setState(() {
          shown = true;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: shown ? 0.9 : 0,
      curve: Curves.easeInOut,
      duration: const Duration(seconds: 2),
      onEnd: () {
        if (!shown) {
          index = Random().nextInt(_hellos.length);
        }
        shown = !shown;
        setState(() {});
      },
      child: SizedBox(
        height: 36,
        child: Text(
          _hellos[index],
          style: const TextStyle(fontSize: 18),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}

class StartupFailedPage extends StatelessWidget {
  final dynamic error;
  final StackTrace? stackTrace;
  const StartupFailedPage({Key? key, required this.error, this.stackTrace})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsetsDirectional.all(24),
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          child: ImageUtil.getChaldeaBackground(context),
        ),
        const SizedBox(height: 48),
        Text('Error: $error', style: Theme.of(context).textTheme.subtitle1),
        if (stackTrace != null)
          Text('\n\n$stackTrace', style: Theme.of(context).textTheme.caption),
        const SizedBox(height: 24),
      ],
    );
  }
}
