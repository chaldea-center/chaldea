import 'package:chaldea/components/components.dart';
import 'package:chaldea/generated/intl/messages_en.dart' as messages_en;
import 'package:chaldea/generated/intl/messages_ja.dart' as messages_ja;
import 'package:chaldea/generated/intl/messages_ko.dart' as messages_ko;
import 'package:chaldea/generated/intl/messages_zh.dart' as messages_zh;
import 'package:flutter/scheduler.dart';

import 'theme_palette.dart';

class DebugFloatingMenuButton extends StatefulWidget {
  const DebugFloatingMenuButton({Key? key}) : super(key: key);

  static GlobalKey<_DebugFloatingMenuButtonState> globalKey = GlobalKey();
  static OverlayEntry? _instance;

  static void createOverlay(BuildContext context) {
    // if (!kDebugMode) return;
    _instance?.remove();
    _instance = OverlayEntry(
      builder: (context) => DebugFloatingMenuButton(key: globalKey),
    );
    Overlay.of(context)?.insert(_instance!);
  }

  static void removeOverlay() {
    _instance?.remove();
    _instance = null;
  }

  @override
  _DebugFloatingMenuButtonState createState() =>
      _DebugFloatingMenuButtonState();
}

class _DebugFloatingMenuButtonState extends State<DebugFloatingMenuButton> {
  bool isMenuShowing = false;
  double opaque = 0.75;
  Offset? _offset;

  Offset get offset =>
      _offset ??
      Offset(
        MediaQuery.of(context).size.width - 48,
        MediaQuery.of(context).size.height - kBottomNavigationBarHeight - 16,
      );

  @override
  Widget build(BuildContext context) {
    updateOffset();
    return Positioned(
      left: offset.dx,
      top: offset.dy,
      child: GestureDetector(
        onPanUpdate: (DragUpdateDetails details) {
          setState(() {
            updateOffset(details.delta);
          });
        },
        child: Opacity(
          opacity: opaque,
          child: FloatingActionButton(
            mini: true,
            backgroundColor:
                isMenuShowing ? Theme.of(context).disabledColor : null,
            onPressed: isMenuShowing
                ? null
                : () {
                    setState(() {
                      isMenuShowing = true;
                    });
                    _DebugMenuDialog(state: this).showDialog(context).then((_) {
                      setState(() {
                        isMenuShowing = false;
                      });
                    });
                  },
            child: const Icon(Icons.menu_open),
          ),
        ),
      ),
    );
  }

  void updateOffset([Offset delta = Offset.zero]) {
    double x = offset.dx + delta.dx, y = offset.dy + delta.dy;
    Size btn =
        (context.findRenderObject() as RenderBox?)?.size ?? const Size(48, 48);
    Size screen = MediaQuery.of(context).size;
    final rect = Rect.fromLTRB(
      -8,
      MediaQuery.of(context).padding.top + kToolbarHeight,
      screen.width + 8 - btn.width,
      screen.height - 8 - btn.height,
    );
    x = x > rect.right
        ? rect.right
        : x < rect.left
            ? rect.left
            : x;
    y = y > rect.bottom
        ? rect.bottom
        : y < rect.top
            ? rect.top
            : y;
    _offset = Offset(x, y);
    setState(() {});
  }

  void hide([int seconds = 60]) {
    opaque = 0;
    safeSetState();
    Future.delayed(Duration(seconds: seconds), () {
      opaque = 0.75;
      safeSetState();
    });
  }

  void markNeedRebuild() {
    SchedulerBinding.instance!.addPostFrameCallback((timeStamp) {
      setState(() {});
    });
  }
}

class _DebugMenuDialog extends StatefulWidget {
  final _DebugFloatingMenuButtonState? state;

  const _DebugMenuDialog({Key? key, this.state}) : super(key: key);

  @override
  __DebugMenuDialogState createState() => __DebugMenuDialogState();
}

class __DebugMenuDialogState extends State<_DebugMenuDialog> {
  @override
  Widget build(BuildContext context) {
    return SimpleDialog(
      title: const Text('Debug Menu'),
      children: [
        ListTile(
          horizontalTitleGap: 0,
          leading: const Icon(Icons.dark_mode),
          title: const Text('Toggle Dark Mode'),
          onTap: () {
            Utils.debugChangeDarkMode();
            Navigator.of(context).pop();
          },
        ),
        ListTile(
          horizontalTitleGap: 0,
          leading: const Icon(Icons.language),
          title: const Text('Language'),
          trailing: DropdownButton<Language>(
            underline: const Divider(thickness: 0, color: Colors.transparent),
            value: Language.getLanguage(db.appSetting.language),
            items: Language.supportLanguages.map((lang) {
              return DropdownMenuItem(value: lang, child: Text(lang.name));
            }).toList(),
            onChanged: (lang) {
              if (lang == null) return;
              db.appSetting.language = lang.code;
              S.load(lang.locale, override: true);
              setState(() {});
              db.notifyAppUpdate();
            },
          ),
        ),
        ListTile(
          horizontalTitleGap: 0,
          leading: const Icon(Icons.translate),
          title: const Text('Reload l10n'),
          onTap: () {
            messages_en.messages.messages.clear();
            messages_en.messages.messages
                .addAll(messages_en.MessageLookup().messages);

            messages_ja.messages.messages.clear();
            messages_ja.messages.messages
                .addAll(messages_en.MessageLookup().messages);

            messages_ko.messages.messages.clear();
            messages_ko.messages.messages
                .addAll(messages_en.MessageLookup().messages);

            messages_zh.messages.messages.clear();
            messages_zh.messages.messages
                .addAll(messages_en.MessageLookup().messages);
            db.notifyAppUpdate();
          },
        ),
        ListTile(
          horizontalTitleGap: 0,
          leading: const Icon(Icons.palette_outlined),
          title: const Text('Palette'),
          onTap: () {
            Navigator.pop(context);
            SplitRoute.push(context, DarkLightThemePalette());
          },
        ),
        ListTile(
          horizontalTitleGap: 0,
          leading: const Icon(Icons.update),
          title: const Text('Load GameData'),
          onTap: () async {
            EasyLoading.show(status: 'Loading');
            await db.loadZipAssets(kDatasetAssetKey);
            await db.loadGameData();
            db.notifyAppUpdate();
            Navigator.pop(context);
            EasyLoading.dismiss();
          },
        ),
        ListTile(
          horizontalTitleGap: 0,
          leading: const Icon(Icons.timer),
          title: const Text('Hide 60s'),
          onTap: () {
            widget.state?.hide(60);
            Navigator.pop(context);
          },
        ),
        Center(
          child: IconButton(
            icon: const Icon(Icons.clear),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        )
      ],
    );
  }
}
