/// src: https://github.com/mayankkushal/flutter_json_viewer
/// Apache License 2.0

import 'package:flutter/material.dart';

import 'package:chaldea/widgets/inherit_selection_area.dart';

class JsonViewerPage extends StatelessWidget {
  final dynamic jsonObj;
  final bool defaultOpen;

  const JsonViewerPage(this.jsonObj, {super.key, this.defaultOpen = false});

  @override
  Widget build(BuildContext context) {
    final lightTheme = ThemeData.light();
    return Scaffold(
      appBar: AppBar(title: const Text("Json Viewer")),
      backgroundColor: lightTheme.scaffoldBackgroundColor,
      body: Theme(
        data: lightTheme,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(8),
          child: JsonViewer(jsonObj, defaultOpen: defaultOpen),
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
        child: Align(
          alignment: Alignment.centerLeft,
          child: getContentWidget(jsonObj, defaultOpen),
        ),
      ),
    );
  }

  static Widget getContentWidget(dynamic content, bool defaultOpen) {
    if (content == null) {
      return const Text('{}');
    } else if (content is List) {
      return JsonArrayViewer(content, notRoot: false, defaultOpen: defaultOpen);
    } else {
      return JsonObjectViewer(content, notRoot: false, defaultOpen: defaultOpen);
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
        padding: const EdgeInsets.only(left: 14.0),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: _getList()),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: _getList(),
    );
  }

  List<Widget> _getList() {
    List<Widget> list = [];
    for (MapEntry entry in widget.jsonObj.entries) {
      bool ex = isExtensible(entry.value);
      bool ink = isInkWell(entry.value);
      list.add(Text.rich(TextSpan(children: [
        WidgetSpan(
          child: ex
              ? ((openFlag[entry.key] ?? widget.defaultOpen)
                  ? Icon(Icons.arrow_drop_down, size: 14, color: Colors.grey[700])
                  : Icon(Icons.arrow_right, size: 14, color: Colors.grey[700]))
              : const Icon(
                  Icons.arrow_right,
                  color: Color.fromARGB(0, 0, 0, 0),
                  size: 14,
                ),
        ),
        (ex && ink)
            ? WidgetSpan(
                child: InkWell(
                child: Text(entry.key, style: TextStyle(color: Colors.purple[900])),
                onTap: () {
                  setState(() {
                    openFlag[entry.key] = !(openFlag[entry.key] ?? widget.defaultOpen);
                  });
                },
              ))
            : TextSpan(
                text: entry.key,
                style: TextStyle(
                  color: entry.value == null ? Colors.grey : Colors.purple[900],
                ),
              ),
        const TextSpan(
          text: ': ',
          style: TextStyle(color: Colors.grey),
        ),
        getValueWidget(entry)
      ])));

      list.add(const SizedBox(height: 4));
      if (ex && (openFlag[entry.key] ?? widget.defaultOpen)) {
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

  static isInkWell(dynamic content) {
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
        return false;
      } else {
        return true;
      }
    }
    return true;
  }

  InlineSpan getValueWidget(MapEntry entry) {
    if (entry.value == null) {
      return const TextSpan(
        text: 'null',
        style: TextStyle(color: Colors.grey),
      );
    } else if (entry.value is int) {
      return TextSpan(
        text: entry.value.toString(),
        style: const TextStyle(color: Colors.teal),
      );
    } else if (entry.value is String) {
      return TextSpan(
        text: '"${entry.value}"',
        style: const TextStyle(color: Colors.redAccent),
      );
    } else if (entry.value is bool) {
      return TextSpan(
        text: entry.value.toString(),
        style: const TextStyle(color: Colors.purple),
      );
    } else if (entry.value is double) {
      return TextSpan(
        text: entry.value.toString(),
        style: const TextStyle(color: Colors.teal),
      );
    } else if (entry.value is List) {
      if (entry.value.isEmpty) {
        return const TextSpan(
          text: 'Array[0]',
          style: TextStyle(color: Colors.grey),
        );
      } else {
        return WidgetSpan(
          child: InkWell(
            child: Text(
              '<${getTypeName(entry.value[0])}>[${entry.value.length}]',
              style: const TextStyle(color: Colors.grey),
            ),
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
        child: const Text(
          'Object',
          style: TextStyle(color: Colors.grey),
        ),
        onTap: () {
          setState(() {
            openFlag[entry.key] = !(openFlag[entry.key] ?? widget.defaultOpen);
          });
        },
      ),
    );
  }

  static isExtensible(dynamic content) {
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

  static getTypeName(dynamic content) {
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
        padding: const EdgeInsets.only(left: 14.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: _getList(),
        ),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: _getList(),
    );
  }

  @override
  void initState() {
    super.initState();
    openFlag = List.filled(widget.jsonArray.length, widget.defaultOpen);
  }

  List<Widget> _getList() {
    List<Widget> list = [];
    int i = 0;
    for (dynamic content in widget.jsonArray) {
      bool ex = JsonObjectViewerState.isExtensible(content);
      bool ink = JsonObjectViewerState.isInkWell(content);
      list.add(Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          ex
              ? ((openFlag[i])
                  ? Icon(Icons.arrow_drop_down, size: 14, color: Colors.grey[700])
                  : Icon(Icons.arrow_right, size: 14, color: Colors.grey[700]))
              : const Icon(
                  Icons.arrow_right,
                  color: Color.fromARGB(0, 0, 0, 0),
                  size: 14,
                ),
          (ex && ink)
              ? getInkWell(i)
              : Text(
                  '[$i]',
                  style: TextStyle(
                    color: content == null ? Colors.grey : Colors.purple[900],
                  ),
                ),
          const Text(
            ':',
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(width: 3),
          getValueWidget(content, i)
        ],
      ));
      list.add(const SizedBox(height: 4));
      if (ex && openFlag[i]) {
        list.add(JsonObjectViewerState.getContentWidget(content, widget.defaultOpen));
      }
      i++;
    }
    return list;
  }

  getInkWell(int index) {
    return InkWell(
      child: Text('[$index]', style: TextStyle(color: Colors.purple[900])),
      onTap: () {
        setState(() {
          openFlag[index] = !(openFlag[index]);
        });
      },
    );
  }

  getValueWidget(dynamic content, int index) {
    if (content == null) {
      return const Expanded(
        child: Text(
          'null',
          style: TextStyle(color: Colors.grey),
        ),
      );
    } else if (content is int) {
      return Expanded(
        child: Text(
          content.toString(),
          style: const TextStyle(color: Colors.teal),
        ),
      );
    } else if (content is String) {
      return Expanded(
        child: Text(
          '"$content"',
          style: const TextStyle(color: Colors.redAccent),
        ),
      );
    } else if (content is bool) {
      return Expanded(
        child: Text(
          content.toString(),
          style: const TextStyle(color: Colors.purple),
        ),
      );
    } else if (content is double) {
      return Expanded(
        child: Text(
          content.toString(),
          style: const TextStyle(color: Colors.teal),
        ),
      );
    } else if (content is List) {
      if (content.isEmpty) {
        return const Text(
          'Array[0]',
          style: TextStyle(color: Colors.grey),
        );
      } else {
        return InkWell(
          child: Text(
            'Array<${JsonObjectViewerState.getTypeName(content)}>[${content.length}]',
            style: const TextStyle(color: Colors.grey),
          ),
          onTap: () {
            setState(() {
              openFlag[index] = !(openFlag[index]);
            });
          },
        );
      }
    }
    return InkWell(
      child: const Text(
        'Object',
        style: TextStyle(color: Colors.grey),
      ),
      onTap: () {
        setState(() {
          openFlag[index] = !(openFlag[index]);
        });
      },
    );
  }
}
