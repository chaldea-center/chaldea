import 'dart:math' show max, min;
import 'package:chaldea/components/components.dart';
import 'package:flutter/material.dart';

class SHeader extends StatelessWidget {
  final String label;

  SHeader(this.label);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(left: 10.0, top: 8.0, bottom: 5.0),
      child:
      Text(label, style: TextStyle(color: Colors.black54, fontSize: 14.0)),
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

  const TileGroup({Key key, this.tiles, this.header, this.footer})
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
      padding: EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[]..addAll(
            null == header ? [] : [SHeader(header)])..addAll(group)..addAll(
            null == footer ? [] : [SFooter(footer)]),
      ),
    );
  }
}

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

  /// compare>0: start<end; compare<0: start>end; compare=0: no change
  final Sign sort;

  const RangeSelector({Key key,
    this.start,
    this.end,
    this.startItems,
    this.endItems,
    this.sort = Sign.positive,
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
              .map((entry) =>
              DropdownMenuItem<T>(
                value: entry.key,
                child: entry.value,
              ))
              .toList(),
          onChanged: (value) {
            start = value;
            end = widget.sort == Sign.positive
                ? max(start, end)
                : widget.sort == Sign.negative ? min(start, end) : end;
            widget.onChanged(start, end);
          },
        ),
        Text('   →   '),
        DropdownButton<T>(
          value: end,
          items: widget.endItems
              .map((entry) =>
              DropdownMenuItem<T>(
                value: entry.key,
                child: entry.value,
              ))
              .toList(),
          onChanged: (value) {
            end = value;
            start = widget.sort == Sign.positive
                ? min(start, end)
                : widget.sort == Sign.negative ? max(start, end) : start;
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
    return tiles;
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

List<Widget> divideTiles2(List<Widget> tiles,
    {Widget divider = const Divider(height: 1.0),
      bool top = false,
      bool bottom = false}) {
  if (tiles.length == 0) {
    return tiles;
  }
  List<Widget> combined = [];
  if (top) {
    combined.add(divider);
  }
  for (int index = 0; index < tiles.length - 1; index++) {
    combined..add(tiles[index])..add(divider);
  }
  combined.add(tiles.last);
  if (bottom) {
    combined.add(divider);
  }
  return combined;
}

void showSheet(BuildContext context, Widget child) {
  // exactly, ModalBottomSheet's height is decided by [initialChildSize]
  // and cannot be modified by drag.
  showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) =>
          DraggableScrollableSheet(
            initialChildSize: 0.75,
            minChildSize: 0.25,
            maxChildSize: 0.9,
            expand: false,
            builder:
                (BuildContext context, ScrollController scrollController) =>
            child,
          ));
}
