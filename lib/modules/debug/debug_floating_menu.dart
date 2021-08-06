import 'package:chaldea/components/components.dart';

import 'theme_palette.dart';

class DebugFloatingMenuButton extends StatefulWidget {
  const DebugFloatingMenuButton({Key? key}) : super(key: key);

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
    return Positioned(
      left: offset.dx,
      top: offset.dy,
      child: GestureDetector(
        onPanUpdate: (DragUpdateDetails details) {
          setState(() {
            this.updateOffset(details.delta);
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
            child: Icon(Icons.menu_open),
          ),
        ),
      ),
    );
  }

  void updateOffset(Offset delta) {
    double x = offset.dx + delta.dx, y = offset.dy + delta.dy;
    Size btn = (context.findRenderObject() as RenderBox?)?.size ?? Size(48, 48);
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

  void hide() {
    opaque = 0;
    safeSetState();
    Future.delayed(Duration(seconds: 60), () {
      opaque = 0.75;
      safeSetState();
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
      title: Text('Debug Menu'),
      children: [
        ListTile(
          horizontalTitleGap: 0,
          leading: Icon(Icons.dark_mode),
          title: Text('Toggle Dark Mode'),
          onTap: () {
            Utils.debugChangeDarkMode();
            Navigator.of(context).pop();
          },
        ),
        ListTile(
          horizontalTitleGap: 0,
          leading: Icon(Icons.language),
          title: Text('Language'),
          trailing: DropdownButton<Language>(
            underline: const Divider(thickness: 0, color: Colors.transparent),
            value: Language.getLanguage(
                db.appSetting.language ?? Language.currentLocaleCode),
            items: Language.supportLanguages.map((lang) {
              return DropdownMenuItem(value: lang, child: Text(lang.name));
            }).toList(),
            onChanged: (lang) {
              if (lang == null) return;
              db.appSetting.language = lang.code;
              setState(() {});
              db.notifyAppUpdate();
            },
          ),
        ),
        ListTile(
          horizontalTitleGap: 0,
          leading: Icon(Icons.palette_outlined),
          title: Text('Palette'),
          onTap: () {
            Navigator.pop(context);
            SplitRoute.push(context, DarkLightThemePalette());
          },
        ),
        ListTile(
          horizontalTitleGap: 0,
          leading: Icon(Icons.palette_outlined),
          title: Text('Hide 60s'),
          onTap: () {
            widget.state?.hide();
            Navigator.pop(context);
          },
        ),
        Center(
          child: IconButton(
            icon: Icon(Icons.clear),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        )
      ],
    );
  }
}
