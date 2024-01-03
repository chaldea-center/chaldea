import 'dart:io';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/scheduler.dart';

import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import 'package:chaldea/app/app.dart';
import 'package:chaldea/app/modules/home/bootstrap/startup_load_page.dart';
import 'package:chaldea/app/modules/home/subpage/network_settings.dart';
import 'package:chaldea/app/tools/gamedata_loader.dart';
import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/models/models.dart';
import 'package:chaldea/packages/file_plus/file_plus_web.dart';
import 'package:chaldea/packages/language.dart';
import 'package:chaldea/packages/logger.dart';
import 'package:chaldea/packages/platform/platform.dart';
import 'package:chaldea/utils/utils.dart';
import 'package:chaldea/widgets/widgets.dart';
import 'startup_failed_page.dart';

class BootstrapPage extends StatefulWidget {
  BootstrapPage({super.key});

  @override
  _BootstrapPageState createState() => _BootstrapPageState();
}

class _BootstrapPageState extends State<BootstrapPage> with SingleTickerProviderStateMixin {
  late PageController _pageController;
  late TextEditingController _accountEditing;
  int page = 0;
  List<Widget> pages = [];
  bool _startupLoadingFailed = false;
  bool invalidStartup = false;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _accountEditing = TextEditingController(text: db.curUser.name);

    if (PlatformU.isWindows) {
      if (!db.paths.isAppPathValid) {
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
  void dispose() {
    super.dispose();
    _pageController.dispose();
    _accountEditing.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (invalidStartup) {
      return wrapChild(StartupFailedPage(
        error: '${S.current.invalid_startup_path}\n'
            '${db.paths.appPath}\n\n'
            '${S.current.invalid_startup_path_info}',
      ));
    }
    if (!_startupLoadingFailed && !db.settings.tips.starter) {
      return wrapChild(StartupLoadingPage(
        onSuccess: () {
          rootRouter.appState.dataReady = true;
        },
        onFailed: () {
          _startupLoadingFailed = true;
          if (mounted) setState(() {});
        },
      ));
    }
    pages = db.settings.tips.starter
        ? [
            welcomePage,
            languagePage,
            if (kIsWeb) webDomainPage,
            darkModePage,
            createAccountPage,
            dataPage,
          ]
        : [dataPage];

    Widget child = PageView(
      controller: _pageController,
      children: pages,
      onPageChanged: (i) {
        FocusScope.of(context).requestFocus(FocusNode()); //Dismiss keyboard on page change
        setState(() {
          page = i;
        });
      },
    );

    child = Stack(children: [child, _bottom()]);
    return wrapChild(child);
  }

  Widget wrapChild(Widget child) {
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
          style: Theme.of(context).textTheme.headlineMedium,
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
            leading:
                Language.getLanguage(db.settings.language) == lang ? const Icon(Icons.done_rounded) : const SizedBox(),
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
    final cnDomain = Uri.parse('https://cn.chaldea.center'), globalDomain = Uri.parse('https://chaldea.center');
    Widget _tile(bool isCN) {
      final domain = isCN ? cnDomain : globalDomain;
      bool selected = Uri.base.host == domain.host;
      return ListTile(
        leading: selected ? const Icon(Icons.done_rounded) : const SizedBox(),
        title: Text(isCN ? S.current.chaldea_server_cn : S.current.chaldea_server_global),
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
              launch(ChaldeaUrl.doc('install'));
            },
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 12),
            child: Text(
              S.current.web_domain_choice_hint,
              // textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall,
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
            leading: db.settings.themeMode == mode ? const Icon(Icons.done_rounded) : const SizedBox(),
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
                leading: region == db.curUser.region ? const Icon(Icons.done) : const SizedBox(),
                title: Text(region.localName),
                horizontalTitleGap: 0,
                onTap: () {
                  setState(() {
                    db.curUser.region = region;
                  });
                  db.settings.carousel.enableFor(region);
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
    List<Widget> children = [];
    if (page <= 0) {
      children.add(const SizedBox(width: 64));
    } else {
      children.add(TextButton(
        child: Text(S.current.prev_page),
        onPressed: () {
          _pageController.previousPage(
            duration: kTabScrollDuration,
            curve: Curves.easeInOut,
          );
        },
      ));
    }
    children.add(Expanded(
      flex: 2,
      child: Center(
        child: SmoothPageIndicator(
          controller: _pageController,
          count: pages.length,
          effect: const WormEffect(dotHeight: 10, dotWidth: 10, activeDotColor: Colors.blue),
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
    ));
    if (page >= pages.length - 1) {
      children.add(TextButton(
        child: Text(S.current.done),
        onPressed: () {
          if (db.gameData.version.timestamp > 0) {
            db.settings.tips.starter = false;
            rootRouter.appState.dataReady = true;
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
                  rootRouter.appState.dataReady = true;
                },
              ),
            );
          }
        },
      ));
    } else {
      children.add(TextButton(
        child: Text(S.current.next_page),
        onPressed: () {
          _pageController.nextPage(
            duration: kTabScrollDuration,
            curve: Curves.easeInOut,
          );
        },
      ));
    }
    return PositionedDirectional(
      bottom: 10.0,
      start: 10.0,
      end: 10.0,
      child: Row(children: children),
    );
  }
}

class _DatabaseIntro extends StatefulWidget {
  _DatabaseIntro();

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
        ListTile(
          dense: true,
          title: Text(S.current.download_source),
          subtitle: Text(S.current.download_source_hint),
          trailing: Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              DropdownButton<bool>(
                value: db.settings.proxy.data,
                items: [
                  DropdownMenuItem(
                      value: false,
                      child: Text(S.current.chaldea_server_global, textScaler: const TextScaler.linear(0.8))),
                  DropdownMenuItem(
                      value: true, child: Text(S.current.chaldea_server_cn, textScaler: const TextScaler.linear(0.8))),
                ],
                onChanged: (v) {
                  setState(() {
                    if (v != null) {
                      db.settings.proxy.setAll(v);
                    }
                  });
                },
              ),
              IconButton(
                onPressed: () async {
                  await Navigator.of(context)
                      .push(MaterialPageRoute(builder: (context) => const NetworkSettingsPage()));
                  if (mounted) setState(() {});
                },
                icon: Icon(DirectionalIcons.keyboard_arrow_forward(context)),
                tooltip: S.current.details,
              )
            ],
          ),
        ),
        SwitchListTile.adaptive(
          dense: true,
          title: Text('${S.current.auto_update} (${S.current.gamedata})'),
          // subtitle: Text(),
          value: db.settings.autoUpdateData,
          onChanged: (v) {
            setState(() {
              db.settings.autoUpdateData = v;
              db.saveSettings();
            });
          },
        ),
        ListTile(
          dense: true,
          title: Text(S.current.current_version),
          trailing: Text(
            db.gameData.version.timestamp > 0
                ? DateTime.fromMillisecondsSinceEpoch(db.gameData.version.timestamp * 1000)
                    .toStringShort()
                    .replaceFirst(' ', '\n')
                : S.current.not_found,
            textAlign: TextAlign.end,
            textScaler: const TextScaler.linear(0.9),
          ),
        ),
        Wrap(
          spacing: 16,
          alignment: WrapAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () async {
                try {
                  setState(() {
                    success = false;
                  });
                  final gamedata = await _loader.reload(force: true, offline: false, silent: false);
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
            if (_loader.error != null)
              TextButton(
                onPressed: () async {
                  if (kIsWeb) {
                    final prefix = FilePlusWeb.normalizePath(db.paths.gameDir);
                    for (final key in FilePlusWeb.list()) {
                      if (key.startsWith(prefix)) {
                        await FilePlusWeb(key).delete();
                        print('deleting $key');
                      }
                    }
                  } else {
                    final dir = Directory(db.paths.gameDir);
                    try {
                      dir.deleteSync(recursive: true);
                    } catch (e, s) {
                      logger.e('delete game folder folder', e, s);
                    } finally {
                      dir.createSync(recursive: true);
                    }
                  }
                  EasyLoading.showSuccess(S.current.clear_cache_finish);
                },
                child: Text(
                  S.current.clear_cache,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              )
          ],
        ),
        progressIcon,
        if (_loader.error != null)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Center(child: Text(escapeDioException(_loader.error))),
          ),
      ],
    );
  }

  Widget get progressIcon {
    return ValueListenableBuilder<double?>(
      valueListenable: GameDataLoader.instance.progress,
      builder: (context, progress, _) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 32),
          child: Stack(
            alignment: Alignment.center,
            children: [
              if (progress == 1.0)
                Icon(
                  _loader.error != null ? Icons.clear_rounded : Icons.done,
                  size: 80,
                  color: _loader.error != null
                      ? Theme.of(context).colorScheme.error
                      : Theme.of(context).colorScheme.primary,
                ),
              if (progress != null && progress < 1.0)
                Text(
                  '${(progress * 100).toInt()}%',
                  style: const TextStyle(fontSize: 24),
                ),
              Center(
                child: SizedBox(
                  width: 120,
                  height: 120,
                  child: CircularProgressIndicator(
                    value: progress ?? 0,
                    color: _loader.error != null ? Theme.of(context).colorScheme.error : null,
                    backgroundColor: Theme.of(context).colorScheme.background,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _IntroPage extends StatelessWidget {
  final IconData? icon;
  final String? title;
  final Widget? content;

  const _IntroPage({this.icon, this.title, this.content});

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
            color: Theme.of(context).brightness == Brightness.dark ? null : Theme.of(context).colorScheme.secondary,
          ),
        if (title != null)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Text(title!, style: Theme.of(context).textTheme.titleLarge),
          ),
        if (content != null) Expanded(child: content!),
        const SizedBox(height: 48),
      ],
    );
  }
}

class _AnimatedHello extends StatefulWidget {
  _AnimatedHello();

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
