import 'dart:math' show max, min;

import 'package:chaldea/components/components.dart';
import 'package:flutter/material.dart';

class SHeader extends StatelessWidget {
  final String label;
  final TextStyle style;

  SHeader(this.label, {this.style});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(left: 10.0, top: 8.0, bottom: 5.0),
      child: Text(label,
          style: style ?? TextStyle(color: Colors.black54, fontSize: 14.0)),
    );
  }
}

class SFooter extends StatelessWidget {
  final String label;

  const SFooter(this.label);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(left: 15.0, right: 15.0, top: 7.5),
      child: Text(
        label,
        style: TextStyle(
            color: Color(0xFF777777), fontSize: 13.0, letterSpacing: -0.08),
      ),
    );
  }
}

class SWidget extends StatelessWidget {
  final String label;
  final Icon icon;
  final Widget trailing;
  final VoidCallback callback;

  const SWidget({Key key, this.label, this.icon, this.trailing, this.callback})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: MyColors.setting_tile,
      child: ListTile(
        leading: icon,
        title: Text(label),
        trailing: trailing,
        onTap: callback,
      ),
    );
  }
}

class SModal extends StatelessWidget {
  final String label;
  final Icon icon;
  final String value;
  final VoidCallback callback;

  SModal({Key key, this.label, this.icon, this.value, this.callback})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: MyColors.setting_tile,
      child: ListTile(
        leading: icon,
        title: Text(label),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(
              value ?? "",
              style: TextStyle(color: Colors.grey),
            ),
            IconButton(
              icon: Icon(Icons.arrow_forward_ios),
              iconSize: 5.0,
              onPressed: null,
            ),
          ],
        ),
        onTap: callback,
      ),
    );
  }
}

class SSwitch extends StatelessWidget {
  final String label;
  final Icon icon;
  final bool value;
  final ValueChanged<bool> callback;

  const SSwitch({Key key, this.label, this.icon, this.value, this.callback})
      : super(key: key); //handle switch/tile value change

  @override
  Widget build(BuildContext context) {
    return Container(
      color: MyColors.setting_tile,
      child: SwitchListTile(
        secondary: icon,
        title: Text(label),
        value: value ?? false,
        onChanged: callback,
      ),
    );
  }
}

class SSelect extends StatelessWidget {
  final List<String> labels;
  final int selected;
  final ValueChanged<int> callback;

  const SSelect({Key key, this.labels, this.selected, this.callback})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TileGroup(
      tiles: labels
          .asMap()
          .map((index, label) {
            return MapEntry(
                index,
                ListTile(
                  title: Text(label),
                  trailing: index == selected
                      ? Icon(
                          Icons.check,
                          color: Theme.of(context).primaryColor,
                        )
                      : null,
                  onTap: () {
                    callback(index);
                  },
                ));
          })
          .values
          .toList(),
    );
  }
}

/// [tiles] should be [SSwitch] or [SModal] or []
class TileGroup extends StatelessWidget {
  final List<Widget> tiles;
  final String header;
  final String footer;
  final EdgeInsets padding;

  const TileGroup({Key key, this.tiles, this.header, this.footer, this.padding})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    bool _first = true; // add top border of first child
    final List<Widget> group = tiles.map((tile) {
      final box = Container(
        decoration: BoxDecoration(
            border: Border(
                top: _first
                    ? Divider.createBorderSide(context, width: 0.5)
                    : BorderSide.none,
                bottom: Divider.createBorderSide(context, width: 0.5)),
            color: MyColors.setting_tile),
        child: tile,
      );
      _first = false;
      return box;
    }).toList();
    return Padding(
      padding: padding ?? EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[]
          ..addAll(null == header ? [] : [SHeader(header)])
          ..addAll(group)
          ..addAll(null == footer ? [] : [SFooter(footer)]),
      ),
    );
  }
}

//not finished
class SRadios extends StatefulWidget {
  final List<Widget> tiles;

  const SRadios({Key key, this.tiles}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _SRadiosState();
}

class _SRadiosState extends State<SRadios> {
  @override
  Widget build(BuildContext context) {
    return TileGroup(
      tiles: widget.tiles,
    );
  }
}

class RangeSelector<T extends num> extends StatefulWidget {
  final T start;
  final T end;
  final List<MapEntry<T, Widget>> startItems;
  final List<MapEntry<T, Widget>> endItems;
  final void Function(T, T) onChanged;

  final bool increasing;

  const RangeSelector(
      {Key key,
      this.start,
      this.end,
      this.startItems,
      this.endItems,
      this.increasing=true,
      this.onChanged})
      : super(key: key);

  @override
  _RangeSelectorState createState() => _RangeSelectorState<T>(start, end);
}

class _RangeSelectorState<T extends num> extends State<RangeSelector<T>> {
  T start;
  T end;

  _RangeSelectorState(this.start, this.end);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        DropdownButton<T>(
          value: start,
          items: widget.startItems
              .map((entry) => DropdownMenuItem<T>(
                    value: entry.key,
                    child: entry.value,
                  ))
              .toList(),
          onChanged: (value) {
            start = value;
            end = widget.increasing == null
                ? end
                : widget.increasing ? max(start, end) : min(start, end);
            widget.onChanged(start, end);
          },
        ),
        Text('   →   '),
        DropdownButton<T>(
          value: end,
          items: widget.endItems
              .map((entry) => DropdownMenuItem<T>(
                    value: entry.key,
                    child: entry.value,
                  ))
              .toList(),
          onChanged: (value) {
            end = value;
            start = widget.increasing == null
                ? start
                : widget.increasing ? min(start, end) : max(start, end);
            widget.onChanged(start, end);
          },
        )
      ],
    );
  }
}

List<Widget> divideTiles(Iterable<Widget> tiles,
    {Widget divider = const Divider(height: 1.0),
    bool top = false,
    bool bottom = false}) {
  if (tiles.length == 0) {
    return tiles.toList();
  }
  List<Widget> combined = [];
  if (top) {
    combined.add(divider);
  }
  Iterator iterator = tiles.iterator;
  combined.add(iterator.current);
  while (iterator.moveNext()) {
    combined..add(divider)..add(iterator.current);
  }
  if (bottom) {
    combined.add(divider);
  }
  return combined;
}

typedef SheetBuilder = Widget Function(BuildContext, StateSetter);

void showSheet(BuildContext context,
    {@required SheetBuilder builder, double size = 0.75}) {
  assert(size >= 0.25 && size <= 1);

  showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => StatefulBuilder(
            builder: (sheetContext, setSheetState) {
              return DraggableScrollableSheet(
                initialChildSize: size,
                minChildSize: 0.25,
                maxChildSize: 1,
                expand: false,
                builder: (context, scrollController) =>
                    builder(sheetContext, setSheetState),
              );
            },
          ));
}

// for filter items
typedef bool FilterCallBack<T>(T data);

class FilterGroup<T> extends StatelessWidget {
  final Widget title;
  final List<String> options;
  final FilterGroupData values;
  final Widget Function(String value) generator;
  final bool showMatchAll;
  final bool showInvert;
  final bool useRadio;
  final void Function(FilterGroupData optionData) onFilterChanged;

  FilterGroup(
      {Key key,
      this.title,
      @required this.options,
      @required this.values,
      this.generator,
      this.showMatchAll = false,
      this.showInvert = false,
        this.useRadio=false,
      this.onFilterChanged})
      : assert(values != null),
        super(key: key);

  Widget _buildSwitch(bool checked, String text, VoidCallback onTap,BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        children: <Widget>[
          Icon(
            checked ? Icons.check_box : Icons.check_box_outline_blank,
            color: Colors.lightBlueAccent,
          ),
          Text(text)
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          if (title != null || showMatchAll || showInvert)
            CustomTile(
              title: title,
              contentPadding: EdgeInsets.zero,
              trailing: Row(
                children: <Widget>[
                  if (showMatchAll)
                    _buildSwitch(values.matchAll, 'Match All', () {
                      values.matchAll = !values.matchAll;
                      if (onFilterChanged != null) {
                        onFilterChanged(values);
                      }
                    },context),
                  if (showInvert)
                    _buildSwitch(values.invert, 'Invert', () {
                      values.invert = !values.invert;
                      if (onFilterChanged != null) {
                        onFilterChanged(values);
                      }
                    },context)
                ],
              ),
            ),
          Wrap(
            spacing: 6,
            children: options.map((key) {
              return FilterOption(
                  selected: values.options[key] ?? false,
                  value: key,
                  child: generator == null ? Text(key) : generator(key),
                  onChanged: (v) {
                    if(useRadio){
                      values.options.clear();
                    }
                    values.options[key] = v;
                    values.options.removeWhere((k, v) => v != true);
                    if (onFilterChanged != null) {
                      onFilterChanged(values);
                    }
                  });
            }).toList(),
          )
        ],
      ),
    );
  }
}

class FilterOption<T, S> extends StatelessWidget {
  final bool selected;
  final T value;
  final Widget child;
  final ValueChanged<bool> onChanged;
  final Color selectedColor;
  final Color unselectedColor;

  FilterOption(
      {Key key,
      @required this.selected,
      @required this.value,
      this.child,
      this.onChanged,
      this.selectedColor = Colors.lightBlueAccent,
      this.unselectedColor})
      : assert(selected != null && value != null),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(maxHeight: 36),
      child: ButtonTheme(
        minWidth: 20,
        height: 30,
        child: FlatButton(
          onPressed: () {
            onChanged(!selected);
          },
          color: selected ? selectedColor : unselectedColor,
          child: child ?? Text(value.toString()),
          shape: ContinuousRectangleBorder(
              side: BorderSide(color: Colors.grey),
              borderRadius: BorderRadius.circular(3)),
        ),
      ),
    );
  }
}
