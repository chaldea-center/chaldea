/// src: https://github.com/mayankkushal/flutter_json_viewer
/// Apache License 2.0

import 'package:material_ui/material_ui.dart';

import 'package:chaldea/widgets/inherit_selection_area.dart';
import 'package:chaldea/widgets/theme.dart';

const double _kIndentWidth = 10.0;

ThemeData _resolveTheme(BuildContext context, ThemeMode? themeMode) {
  final theme = Theme.of(context);
  final brightness = switch (themeMode) {
    null => theme.brightness,
    ThemeMode.system => MediaQuery.platformBrightnessOf(context),
    ThemeMode.light => Brightness.light,
    ThemeMode.dark => Brightness.dark,
  };
  if (brightness == theme.brightness) return theme;
  return (brightness == Brightness.dark ? AppTheme.dark() : AppTheme.light()).copyWith(platform: theme.platform);
}

class _JsonColors {
  final Color key;
  final Color muted;
  final Color number;
  final Color string;
  final Color boolean;

  const _JsonColors({
    required this.key,
    required this.muted,
    required this.number,
    required this.string,
    required this.boolean,
  });

  static const light = _JsonColors(
    key: Color(0xFF6A3289),
    muted: Color(0xFF535967),
    number: Color(0xFF006054),
    string: Color(0xFFA42A25),
    boolean: Color(0xFF254E9B),
  );

  static const dark = _JsonColors(
    key: Color(0xFFE4B7FF),
    muted: Color(0xFFBBC2D0),
    number: Color(0xFF81DDC3),
    string: Color(0xFFFFADA5),
    boolean: Color(0xFFA8C8FF),
  );

  static _JsonColors of(BuildContext context) => Theme.of(context).brightness == Brightness.dark ? dark : light;
}

class JsonViewerPage extends StatefulWidget {
  final dynamic jsonObj;
  final bool defaultOpen;

  /// Overrides the inherited theme mode for this page when provided.
  final ThemeMode? themeMode;

  const JsonViewerPage(this.jsonObj, {super.key, this.defaultOpen = false, this.themeMode});

  @override
  State<JsonViewerPage> createState() => _JsonViewerPageState();
}

class _JsonViewerPageState extends State<JsonViewerPage> {
  late bool defaultOpen = widget.defaultOpen;

  @override
  Widget build(BuildContext context) {
    final page = Scaffold(
      appBar: AppBar(
        title: const Text("Json Viewer"),
        actions: [
          IconButton(
            onPressed: () {
              setState(() {
                defaultOpen = !defaultOpen;
              });
            },
            icon: const Icon(Icons.expand),
            tooltip: 'Expand',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(8),
        child: JsonViewer(widget.jsonObj, defaultOpen: defaultOpen, key: Key('_json_viewer_key_$defaultOpen')),
      ),
    );
    return Theme(data: _resolveTheme(context, widget.themeMode), child: page);
  }
}

class JsonViewer extends StatelessWidget {
  final dynamic jsonObj;
  final bool defaultOpen;

  /// Null inherits the nearest [Theme]. An explicit mode paints a matching surface.
  final ThemeMode? themeMode;

  const JsonViewer(this.jsonObj, {super.key, this.defaultOpen = false, this.themeMode});

  /// Displays a small JSON tree using the current Material card style.
  static Widget card(
    dynamic jsonObj, {
    Key? key,
    bool defaultOpen = false,
    ThemeMode? themeMode,
    EdgeInsetsGeometry? margin,
    EdgeInsetsGeometry padding = const EdgeInsets.all(8),
  }) {
    return Builder(
      key: key,
      builder: (context) => Theme(
        data: _resolveTheme(context, themeMode),
        child: Card(
          margin: margin,
          child: Padding(
            padding: padding,
            child: JsonViewer(jsonObj, defaultOpen: defaultOpen),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final viewer = InheritSelectionArea(
      child: Directionality(
        textDirection: TextDirection.ltr,
        child: Align(alignment: Alignment.centerLeft, child: getContentWidget(jsonObj, defaultOpen)),
      ),
    );
    if (themeMode == null) return viewer;
    final theme = _resolveTheme(context, themeMode);
    return Theme(
      data: theme,
      child: Material(color: theme.colorScheme.surface, child: viewer),
    );
  }

  static Widget getContentWidget(dynamic content, bool defaultOpen) {
    if (content == null || (content is Map && content.isEmpty)) {
      return Builder(
        builder: (context) {
          return Text('{}', style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color));
        },
      );
    } else if (content is List) {
      return JsonArrayViewer(content, notRoot: false, defaultOpen: defaultOpen);
    } else if (content is Map) {
      return JsonObjectViewer(content, notRoot: false, defaultOpen: defaultOpen);
    } else {
      return Builder(
        builder: (context) {
          return Text(
            '${content.runtimeType}: $content',
            style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color),
          );
        },
      );
    }
  }
}

class JsonObjectViewer extends StatefulWidget {
  final Map<String, dynamic> jsonObj;
  final bool notRoot;
  final bool defaultOpen;

  JsonObjectViewer(Map<dynamic, dynamic> jsonObj, {super.key, this.notRoot = false, this.defaultOpen = false})
    : jsonObj = jsonObj.map((key, value) => MapEntry(key.toString(), value));

  @override
  JsonObjectViewerState createState() => JsonObjectViewerState();
}

class JsonObjectViewerState extends State<JsonObjectViewer> {
  Map<String, bool> openFlag = {};

  late _JsonColors _colors;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _colors = _JsonColors.of(context);
  }

  @override
  Widget build(BuildContext context) {
    if (widget.notRoot) {
      return Container(
        padding: const EdgeInsets.only(left: _kIndentWidth),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: _getList()),
      );
    }
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: _getList());
  }

  List<Widget> _getList() {
    List<Widget> list = [];
    for (MapEntry entry in widget.jsonObj.entries) {
      bool extensible = _isExtensible(entry.value);
      bool ink = _isInkWell(entry.value);
      bool isNullEmpty = _isNullOrEmpty(entry.value);
      list.add(
        Text.rich(
          TextSpan(
            children: [
              WidgetSpan(
                child: extensible
                    ? ((openFlag[entry.key] ?? widget.defaultOpen)
                          ? Icon(Icons.arrow_drop_down, size: 14, color: _colors.muted)
                          : Icon(Icons.arrow_right, size: 14, color: _colors.muted))
                    : const Icon(Icons.arrow_right, color: Color.fromARGB(0, 0, 0, 0), size: 14),
              ),
              (extensible && ink)
                  ? WidgetSpan(
                      child: InkWell(
                        child: Text(entry.key, style: TextStyle(color: isNullEmpty ? _colors.muted : _colors.key)),
                        onTap: () {
                          setState(() {
                            openFlag[entry.key] = !(openFlag[entry.key] ?? widget.defaultOpen);
                          });
                        },
                      ),
                    )
                  : TextSpan(
                      text: entry.key,
                      style: TextStyle(color: isNullEmpty ? _colors.muted : _colors.key),
                    ),
              TextSpan(
                text: ': ',
                style: TextStyle(color: _colors.muted),
              ),
              getValueWidget(entry),
            ],
          ),
        ),
      );

      list.add(const SizedBox(height: 4));
      if (extensible && (openFlag[entry.key] ?? widget.defaultOpen)) {
        list.add(getContentWidget(entry.value, widget.defaultOpen));
      }
    }
    return list;
  }

  static Widget getContentWidget(dynamic content, bool defaultOpen) {
    if (content is List) {
      return JsonArrayViewer(content, notRoot: true, defaultOpen: defaultOpen);
    } else {
      return JsonObjectViewer(content, notRoot: true, defaultOpen: defaultOpen);
    }
  }

  InlineSpan getValueWidget(MapEntry entry) {
    final value = entry.value;
    if (value == null) {
      return TextSpan(
        text: 'null',
        style: TextStyle(color: _colors.muted),
      );
    } else if (value is int) {
      return TextSpan(
        text: value.toString(),
        style: TextStyle(color: _colors.number),
      );
    } else if (value is String) {
      return TextSpan(
        text: '"${_limitStrLength(value)}"',
        style: TextStyle(color: _colors.string),
      );
    } else if (value is bool) {
      return TextSpan(
        text: value.toString(),
        style: TextStyle(color: _colors.boolean),
      );
    } else if (value is double) {
      return TextSpan(
        text: value.toString(),
        style: TextStyle(color: _colors.number),
      );
    } else if (value is List) {
      if (value.isEmpty) {
        return TextSpan(
          text: 'Array[0]',
          style: TextStyle(color: _colors.muted),
        );
      } else {
        return WidgetSpan(
          child: InkWell(
            child: Text('<${_getTypeName(value[0])}>[${value.length}]', style: TextStyle(color: _colors.muted)),
            onTap: () {
              setState(() {
                openFlag[entry.key] = !(openFlag[entry.key] ?? widget.defaultOpen);
              });
            },
          ),
        );
      }
    }
    return WidgetSpan(
      child: InkWell(
        child: Text('Object', style: TextStyle(color: _colors.muted)),
        onTap: () {
          setState(() {
            openFlag[entry.key] = !(openFlag[entry.key] ?? widget.defaultOpen);
          });
        },
      ),
    );
  }
}

class JsonArrayViewer extends StatefulWidget {
  final List<dynamic> jsonArray;

  final bool notRoot;
  final bool defaultOpen;

  JsonArrayViewer(this.jsonArray, {super.key, this.notRoot = false, this.defaultOpen = false});

  @override
  _JsonArrayViewerState createState() => _JsonArrayViewerState();
}

class _JsonArrayViewerState extends State<JsonArrayViewer> {
  late List<bool> openFlag;

  late _JsonColors _colors;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _colors = _JsonColors.of(context);
  }

  @override
  Widget build(BuildContext context) {
    if (widget.notRoot) {
      return Container(
        padding: const EdgeInsets.only(left: _kIndentWidth),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: _getList()),
      );
    }
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: _getList());
  }

  @override
  void initState() {
    super.initState();
    openFlag = List.filled(widget.jsonArray.length, widget.defaultOpen);
  }

  List<Widget> _getList() {
    List<Widget> list = [];
    final int skipStartIndex = 10, skipEndIndex = widget.jsonArray.length - 10;
    for (final (i, content) in widget.jsonArray.indexed) {
      if (i >= skipStartIndex && i <= skipEndIndex) {
        if (i == skipStartIndex) {
          list.add(
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const Icon(Icons.arrow_right, color: Colors.transparent, size: 14),
                Text(
                  '[$skipStartIndex~$skipEndIndex]',
                  style: TextStyle(color: content == null ? _colors.muted : _colors.key),
                ),
                Text(':', style: TextStyle(color: _colors.muted)),
                const SizedBox(width: 3),
                Expanded(
                  child: Text('too long - hidden', style: TextStyle(color: _colors.muted)),
                ),
              ],
            ),
          );
        }
        continue;
      }
      bool ex = _isExtensible(content);
      bool ink = _isInkWell(content);
      list.add(
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            ex
                ? ((openFlag[i])
                      ? Icon(Icons.arrow_drop_down, size: 14, color: _colors.muted)
                      : Icon(Icons.arrow_right, size: 14, color: _colors.muted))
                : const Icon(Icons.arrow_right, color: Colors.transparent, size: 14),
            (ex && ink)
                ? _getInkWell(i)
                : Text('[$i]', style: TextStyle(color: content == null ? _colors.muted : _colors.key)),
            Text(':', style: TextStyle(color: _colors.muted)),
            const SizedBox(width: 3),
            _getValueWidget(content, i),
          ],
        ),
      );
      list.add(const SizedBox(height: 4));
      if (ex && openFlag[i]) {
        list.add(JsonObjectViewerState.getContentWidget(content, widget.defaultOpen));
      }
    }
    return list;
  }

  Widget _getInkWell(int index) {
    return InkWell(
      child: Text('[$index]', style: TextStyle(color: _colors.key)),
      onTap: () {
        setState(() {
          openFlag[index] = !(openFlag[index]);
        });
      },
    );
  }

  Widget _getValueWidget(dynamic content, int index) {
    if (content == null) {
      return Expanded(
        child: Text('null', style: TextStyle(color: _colors.muted)),
      );
    } else if (content is int) {
      return Expanded(
        child: Text(content.toString(), style: TextStyle(color: _colors.number)),
      );
    } else if (content is String) {
      return Expanded(
        child: Text('"${_limitStrLength(content)}"', style: TextStyle(color: _colors.string)),
      );
    } else if (content is bool) {
      return Expanded(
        child: Text(content.toString(), style: TextStyle(color: _colors.boolean)),
      );
    } else if (content is double) {
      return Expanded(
        child: Text(content.toString(), style: TextStyle(color: _colors.number)),
      );
    } else if (content is List) {
      if (content.isEmpty) {
        return Text('Array[0]', style: TextStyle(color: _colors.muted));
      } else {
        return InkWell(
          child: Text('Array<${_getTypeName(content)}>[${content.length}]', style: TextStyle(color: _colors.muted)),
          onTap: () {
            setState(() {
              openFlag[index] = !(openFlag[index]);
            });
          },
        );
      }
    }
    return InkWell(
      child: Text('Object', style: TextStyle(color: _colors.muted)),
      onTap: () {
        setState(() {
          openFlag[index] = !(openFlag[index]);
        });
      },
    );
  }
}

bool _isExtensible(dynamic content) {
  if (content == null) {
    return false;
  } else if (content is int) {
    return false;
  } else if (content is String) {
    return false;
  } else if (content is bool) {
    return false;
  } else if (content is double) {
    return false;
  }
  return true;
}

bool _isNullOrEmpty(dynamic content) {
  return content == null || (content is List && content.isEmpty) || (content is Map && content.isEmpty);
}

bool _isInkWell(dynamic content) {
  if (content == null) {
    return false;
  } else if (content is int) {
    return false;
  } else if (content is String) {
    return false;
  } else if (content is bool) {
    return false;
  } else if (content is double) {
    return false;
  } else if (content is List) {
    if (content.isEmpty) {
      return true;
    } else {
      return true;
    }
  }
  return true;
}

String _getTypeName(dynamic content) {
  if (content is int) {
    return 'int';
  } else if (content is String) {
    return 'String';
  } else if (content is bool) {
    return 'bool';
  } else if (content is double) {
    return 'double';
  } else if (content is List) {
    return 'List';
  }
  return 'Object';
}

String _limitStrLength(String v, [int length = 500]) {
  if (v.length < length) return v;
  return '${v.substring(0, length)}...(len=${v.length})';
}
