import 'dart:math';

import 'package:chaldea/app/app.dart';
import 'package:chaldea/app/tools/gamedata_loader.dart';
import 'package:chaldea/models/models.dart';
import 'package:chaldea/utils/basic.dart';
import 'package:chaldea/utils/extension.dart';
import 'package:chaldea/widgets/after_layout.dart';
import 'package:chaldea/widgets/custom_dialogs.dart';
import 'package:chaldea/widgets/tile_items.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

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

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _accountEditing = TextEditingController(text: db2.curUser.name);
  }

  @override
  void afterFirstLayout(BuildContext context) async {
    try {
      if (!db2.settings.tips.starter) {
        db2.gameData = await _loader.reload(
          offline: true,
          onUpdate: (v) {
            if (mounted) setState(() {});
          },
        );
        onDataReady(true);
      }
    } catch (e) {
      //
    } finally {
      if (mounted) setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    pages = !db2.settings.tips.starter
        ? [
            _OfflineLoadingPage(
              progress: _loader.progress,
              error: _loader.error,
            ),
            if (_loader.error != null) dataPage,
          ]
        : [
            welcomePage,
            languagePage,
            darkModePage,
            createAccountPage,
            dataPage,
          ];
    Widget child;
    if (pages.length > 1) {
      child = Stack(
        children: [
          PageView(
            controller: _pageController,
            children: pages,
            onPageChanged: (i) {
              setState(() {
                page = i;
              });
            },
          ),
          _bottom(),
        ],
      );
    } else {
      child = pages.first;
    }
    return Scaffold(
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 768),
          child: child,
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
      icon: FontAwesomeIcons.globeAsia,
      title: 'Select Language',
      content: ListView.separated(
        itemBuilder: (context, index) {
          final lang = Language.supportLanguages[index];
          return ListTile(
            leading: Language.getLanguage(db2.settings.language) == lang
                ? const Icon(Icons.done_rounded)
                : const SizedBox(),
            title: Text(lang.name),
            horizontalTitleGap: 0,
            onTap: () {
              db2.settings.language = lang.code;
              db2.notifyAppUpdate();
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

  Widget get darkModePage {
    return _IntroPage(
      icon: FontAwesomeIcons.adjust,
      title: 'Dark Mode',
      content: ListView.separated(
        itemBuilder: (context, index) {
          final mode = ThemeMode.values[index];
          return ListTile(
            leading: db2.settings.themeMode == mode
                ? const Icon(Icons.done_rounded)
                : const SizedBox(),
            title: Text(EnumUtil.titled(mode)),
            horizontalTitleGap: 0,
            onTap: () {
              db2.settings.themeMode = mode;
              db2.notifyAppUpdate();
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
            child: TextField(
              controller: _accountEditing,
              decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Account',
                  hintText: 'Any name',
                  helperText: 'You can add more accounts later in Settings'),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Game Server',
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          ...divideTiles(
            List.generate(Region.values.length, (index) {
              final region = Region.values[index];
              return ListTile(
                leading: region == db2.curUser.region
                    ? const Icon(Icons.done)
                    : const SizedBox(),
                title: Text(EnumUtil.shortString(region).toUpperCase()),
                horizontalTitleGap: 0,
                onTap: () {
                  setState(() {
                    db2.curUser.region = region;
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
      title: 'Database',
      content: _DatabaseIntro(),
    );
  }

  Widget _bottom() {
    return Positioned(
      bottom: 10.0,
      left: 10.0,
      right: 10.0,
      child: Row(
        children: <Widget>[
          Container(
            alignment: Alignment.center,
            width: MediaQuery.of(context).size.width / 4,
            child: page <= 0
                ? const SizedBox()
                : TextButton(
                    child: const Text('PREV'),
                    onPressed: () {
                      _pageController.previousPage(
                        duration: kTabScrollDuration,
                        curve: Curves.easeInOut,
                      );
                    },
                  ),
          ),
          Expanded(
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
          Container(
            alignment: Alignment.center,
            width: MediaQuery.of(context).size.width / 4,
            child: page >= pages.length - 1
                ? TextButton(
                    child: const Text('DONE'),
                    onPressed: () {
                      if (db2.gameData.version.timestamp > 0) {
                        db2.settings.tips.starter = false;
                        onDataReady(false);
                        db2.saveSettings();
                      } else {
                        showDialog(
                          context: context,
                          builder: (context) => SimpleCancelOkDialog(
                            content: const Text(
                                'Database is not downloaded, still continue?'),
                            onTapOk: () {
                              db2.settings.tips.starter = false;
                              db2.saveSettings();
                              onDataReady(false);
                            },
                          ),
                        );
                      }
                    },
                  )
                : TextButton(
                    child: const Text('NEXT'),
                    onPressed: () {
                      _pageController.nextPage(
                        duration: kTabScrollDuration,
                        curve: Curves.easeInOut,
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  void onDataReady(bool needCheckUpdate) async {
    rootRouter.appState.dataReady = true;
    if (needCheckUpdate && network.available) {
      await Future.delayed(const Duration(seconds: 3));
      await _loader.reload(updateOnly: true).catchError((e, s) async {
        logger.d('silent background update error');
      });
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
  final dynamic error;

  _OfflineLoadingPage({Key? key, this.progress, required this.error})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    Widget img = const Image(
      image: AssetImage("res/img/chaldea.png"),
      filterQuality: FilterQuality.high,
      height: 240,
    );
    if (Utility.isDarkMode(context)) {
      // assume r=g=b
      int b = Theme.of(context).scaffoldBackgroundColor.blue;
      if (!kIsWeb) {
        double v = (255 - b) / 255;
        img = ColorFiltered(
          colorFilter: ColorFilter.matrix([
            //R G  B  A  Const
            -v, 0, 0, 0, 255,
            0, -v, 0, 0, 255,
            0, 0, -v, 0, 255,
            0, 0, 0, 0.8, 0,
          ]),
          child: img,
        );
      } else {
        img = ColorFiltered(
          colorFilter: const ColorFilter.matrix([
            // R    G       B       A  Const
            0.2126, 0.5152, 0.0722, 0, 0,
            0.2126, 0.5152, 0.0722, 0, 0,
            0.2126, 0.5152, 0.0722, 0, 0,
            0, 0, 0, 1, 0,
          ]),
          child: img,
        );
      }
    }
    img = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: img,
    );
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Center(
            child: error == null
                ? img
                : ListView(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    children: [
                      img,
                      ListTile(subtitle: Center(child: Text(error.toString()))),
                    ],
                  ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 48),
          child: LinearProgressIndicator(
            value: progress ?? 0,
            color: error != null
                ? Theme.of(context).errorColor
                : Theme.of(context).primaryColorLight,
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
  dynamic error;
  bool success = false;

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        SwitchListTile.adaptive(
          title: const Text('Auto Update'),
          value: db2.settings.autoUpdateData,
          onChanged: (v) {
            setState(() {
              db2.settings.autoUpdateData = v;
            });
          },
        ),
        ListTile(
          title: const Text('Current Version'),
          trailing: Text(
            db2.gameData.version.timestamp > 0
                ? DateTime.fromMillisecondsSinceEpoch(
                        db2.gameData.version.timestamp * 1000)
                    .toStringShort()
                    .replaceFirst(' ', '\n')
                : 'NotFound',
            textAlign: TextAlign.end,
          ),
        ),
        Center(
          child: ElevatedButton(
            onPressed: () async {
              try {
                setState(() {
                  error = null;
                  success = false;
                });
                final gamedata = await _loader.reload(
                  offline: false,
                  onUpdate: (v) {
                    if (mounted) setState(() {});
                  },
                );
                db2.gameData = gamedata;
                success = true;
              } catch (e, s) {
                logger.e('download gamedata error', e, s);
                error = e;
              }
              if (mounted) setState(() {});
            },
            child: const Text('Update Now'),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 32),
          child: Stack(
            alignment: Alignment.center,
            children: [
              if (_loader.progress == 1.0)
                Icon(
                  error != null ? Icons.close : Icons.done,
                  size: 80,
                  color: error != null
                      ? Theme.of(context).errorColor
                      : Theme.of(context).colorScheme.primary,
                ),
              Center(
                child: SizedBox(
                  width: 120,
                  height: 120,
                  child: CircularProgressIndicator(
                    value: _loader.progress ?? 0,
                    color: error != null ? Theme.of(context).errorColor : null,
                  ),
                ),
              ),
            ],
          ),
        ),
        if (error != null)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Center(child: Text(error.toString())),
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
        '¡¡Buenas!',
        'مرحبا'
      ];
  bool shown = false;
  int index = 0;

  @override
  void initState() {
    super.initState();
    SchedulerBinding.instance!.addPostFrameCallback((timeStamp) {
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
