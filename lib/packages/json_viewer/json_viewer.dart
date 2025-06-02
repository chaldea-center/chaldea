/// src: https://github.com/mayankkushal/flutter_json_viewer
/// Apache License 2.0

import 'package:flutter/material.dart';

import 'package:chaldea/widgets/inherit_selection_area.dart';

const double _kIndentWidth = 10.0;

class JsonViewerPage extends StatefulWidget {
  final dynamic jsonObj;
  final bool defaultOpen;

  const JsonViewerPage(this.jsonObj, {super.key, this.defaultOpen = false});

  @override
  State<JsonViewerPage> createState() => _JsonViewerPageState();
}

class _JsonViewerPageState extends State<JsonViewerPage> {
  late bool defaultOpen = widget.defaultOpen;

  @override
  Widget build(BuildContext context) {
    final lightTheme = ThemeData.light(useMaterial3: Theme.of(context).useMaterial3);
    return Scaffold(
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
      backgroundColor: lightTheme.scaffoldBackgroundColor,
      body: Theme(
        data: lightTheme,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(8),
          child: JsonViewer(widget.jsonObj, defaultOpen: defaultOpen, key: Key('_json_viewer_key_$defaultOpen')),
        ),
      ),
    );
  }
}

class JsonViewer extends StatelessWidget {
  final dynamic jsonObj;
  final bool defaultOpen;
  JsonViewer(this.jsonObj, {super.key, this.defaultOpen = false});

  @override
  Widget build(BuildContext context) {
    return InheritSelectionArea(
      child: Directionality(
        textDirection: TextDirection.ltr,
        child: Align(alignment: Alignment.centerLeft, child: getContentWidget(jsonObj, defaultOpen)),
      ),
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
                          ? Icon(Icons.arrow_drop_down, size: 14, color: Colors.grey[700])
                          : Icon(Icons.arrow_right, size: 14, color: Colors.grey[700]))
                    : const Icon(Icons.arrow_right, color: Color.fromARGB(0, 0, 0, 0), size: 14),
              ),
              (extensible && ink)
                  ? WidgetSpan(
                      child: InkWell(
                        child: Text(entry.key, style: TextStyle(color: isNullEmpty ? Colors.grey : Colors.purple[900])),
                        onTap: () {
                          setState(() {
                            openFlag[entry.key] = !(openFlag[entry.key] ?? widget.defaultOpen);
                          });
                        },
                      ),
                    )
                  : TextSpan(
                      text: entry.key,
                      style: TextStyle(color: isNullEmpty ? Colors.grey : Colors.purple[900]),
                    ),
              const TextSpan(
                text: ': ',
                style: TextStyle(color: Colors.grey),
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
      return const TextSpan(
        text: 'null',
        style: TextStyle(color: Colors.grey),
      );
    } else if (value is int) {
      return TextSpan(
        text: value.toString(),
        style: const TextStyle(color: Colors.teal),
      );
    } else if (value is String) {
      return TextSpan(
        text: '"${_limitStrLength(value)}"',
        style: const TextStyle(color: Colors.redAccent),
      );
    } else if (value is bool) {
      return TextSpan(
        text: value.toString(),
        style: const TextStyle(color: Colors.purple),
      );
    } else if (value is double) {
      return TextSpan(
        text: value.toString(),
        style: const TextStyle(color: Colors.teal),
      );
    } else if (value is List) {
      if (value.isEmpty) {
        return const TextSpan(
          text: 'Array[0]',
          style: TextStyle(color: Colors.grey),
        );
      } else {
        return WidgetSpan(
          child: InkWell(
            child: Text('<${_getTypeName(value[0])}>[${value.length}]', style: const TextStyle(color: Colors.grey)),
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
        child: const Text('Object', style: TextStyle(color: Colors.grey)),
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
                  style: TextStyle(color: content == null ? Colors.grey : Colors.purple[900]),
                ),
                const Text(':', style: TextStyle(color: Colors.grey)),
                const SizedBox(width: 3),
                const Expanded(
                  child: Text('too long - hidden', style: TextStyle(color: Colors.grey)),
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
                      ? Icon(Icons.arrow_drop_down, size: 14, color: Colors.grey[700])
                      : Icon(Icons.arrow_right, size: 14, color: Colors.grey[700]))
                : const Icon(Icons.arrow_right, color: Colors.transparent, size: 14),
            (ex && ink)
                ? getInkWell(i)
                : Text('[$i]', style: TextStyle(color: content == null ? Colors.grey : Colors.purple[900])),
            const Text(':', style: TextStyle(color: Colors.grey)),
            const SizedBox(width: 3),
            getValueWidget(content, i),
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

  Widget getInkWell(int index) {
    return InkWell(
      child: Text('[$index]', style: TextStyle(color: Colors.purple[900])),
      onTap: () {
        setState(() {
          openFlag[index] = !(openFlag[index]);
        });
      },
    );
  }

  Widget getValueWidget(dynamic content, int index) {
    if (content == null) {
      return const Expanded(
        child: Text('null', style: TextStyle(color: Colors.grey)),
      );
    } else if (content is int) {
      return Expanded(
        child: Text(content.toString(), style: const TextStyle(color: Colors.teal)),
      );
    } else if (content is String) {
      return Expanded(
        child: Text('"${_limitStrLength(content)}"', style: const TextStyle(color: Colors.redAccent)),
      );
    } else if (content is bool) {
      return Expanded(
        child: Text(content.toString(), style: const TextStyle(color: Colors.purple)),
      );
    } else if (content is double) {
      return Expanded(
        child: Text(content.toString(), style: const TextStyle(color: Colors.teal)),
      );
    } else if (content is List) {
      if (content.isEmpty) {
        return const Text('Array[0]', style: TextStyle(color: Colors.grey));
      } else {
        return InkWell(
          child: Text('Array<${_getTypeName(content)}>[${content.length}]', style: const TextStyle(color: Colors.grey)),
          onTap: () {
            setState(() {
              openFlag[index] = !(openFlag[index]);
            });
          },
        );
      }
    }
    return InkWell(
      child: const Text('Object', style: TextStyle(color: Colors.grey)),
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
  return '${v.substring(0, length)}...';
}
