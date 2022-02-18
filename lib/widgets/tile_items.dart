import 'dart:math' show max, min;

import 'package:chaldea/utils/constants.dart';
import 'package:flutter/material.dart';

class SHeader extends StatelessWidget {
  final String label;
  final TextStyle? style;
  final EdgeInsetsGeometry padding;

  const SHeader(
    this.label, {
    Key? key,
    this.style,
    this.padding = const EdgeInsets.only(left: 16.0, top: 8.0, bottom: 4.0),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // 138
    final color = Theme.of(context).textTheme.caption?.color?.withAlpha(175);
    return Container(
      padding: padding,
      child: Text(
        label,
        style: style ??
            TextStyle(
              color: color,
              fontWeight: FontWeight.normal,
              fontSize: 14.0,
            ),
      ),
    );
  }
}

class SFooter extends StatelessWidget {
  final String label;
  final EdgeInsetsGeometry padding;

  const SFooter(this.label,
      {Key? key,
      this.padding = const EdgeInsetsDirectional.fromSTEB(15, 7.5, 15, 5)})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: Text(
        label,
        style: TextStyle(
            color: Theme.of(context).textTheme.caption?.color,
            fontSize: 13.0,
            letterSpacing: -0.08),
      ),
    );
  }
}

class SWidget extends StatelessWidget {
  final String label;
  final Icon? icon;
  final Widget? trailing;
  final VoidCallback? callback;

  const SWidget(
      {Key? key, required this.label, this.icon, this.trailing, this.callback})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Theme.of(context).cardColor,
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
  final Icon? icon;
  final String? value;
  final VoidCallback? callback;

  const SModal(
      {Key? key, required this.label, this.icon, this.value, this.callback})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Theme.of(context).cardColor,
      child: ListTile(
        leading: icon,
        title: Text(label),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(value ?? "", style: const TextStyle(color: Colors.grey)),
            const IconButton(
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
  final Icon? icon;
  final bool? value;
  final ValueChanged<bool>? callback;

  const SSwitch(
      {Key? key, required this.label, this.icon, this.value, this.callback})
      : super(key: key); //handle switch/tile value change

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Theme.of(context).cardColor,
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
  final ValueChanged<int>? callback;

  const SSelect(
      {Key? key, this.labels = const [], this.selected = 0, this.callback})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    List<Widget> children = [];
    for (int index = 0; index < labels.length; index++) {
      children.add(ListTile(
        title: Text(labels[index]),
        trailing: index == selected
            ? Icon(Icons.check, color: Theme.of(context).primaryColor)
            : null,
        onTap: () {
          if (callback != null) {
            callback!(index);
          }
        },
      ));
    }
    return TileGroup(children: children);
  }
}

/// [children] should be [SSwitch] or [SModal] or []
class TileGroup extends StatelessWidget {
  final List<Widget> children;
  final String? header;
  final String? footer;
  final EdgeInsets? padding;
  final Widget divider;
  final bool innerDivider;
  final Color? tileColor;
  final CrossAxisAlignment crossAxisAlignment;
  final bool scrollable;
  final bool shrinkWrap;

  const TileGroup({
    Key? key,
    this.children = const [],
    this.header,
    this.footer,
    this.padding,
    this.divider = const Divider(height: 1, thickness: 0.5),
    this.innerDivider = false,
    this.tileColor,
    this.crossAxisAlignment = CrossAxisAlignment.start,
    this.scrollable = false,
    this.shrinkWrap = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    List<Widget> group;
    if (innerDivider) {
      group = divideTiles(children, divider: divider, top: true, bottom: true);
    } else {
      group = [divider, ...children, divider];
    }
    final _children = <Widget>[
      if (header != null) SHeader(header!),
      Material(
        color: tileColor ?? Theme.of(context).cardColor,
        child: Column(
          crossAxisAlignment: crossAxisAlignment,
          mainAxisSize: MainAxisSize.min,
          children: group,
        ),
      ),
      if (footer != null) SFooter(footer!)
    ];
    if (scrollable) {
      return ListView(
        shrinkWrap: shrinkWrap,
        children: _children,
        padding: padding ?? const EdgeInsets.only(bottom: 8),
      );
    } else {
      return Padding(
        padding: padding ?? const EdgeInsets.only(bottom: 8),
        child: Column(
          crossAxisAlignment: crossAxisAlignment,
          mainAxisSize: MainAxisSize.min,
          children: _children,
        ),
      );
    }
  }
}

class SliverTileGroup extends StatelessWidget {
  final List<Widget> children;
  final String? header;
  final String? footer;
  final EdgeInsets? padding;
  final Widget divider;
  final bool innerDivider;
  final Color? tileColor;
  final CrossAxisAlignment crossAxisAlignment;
  final bool scrollable;
  final bool shrinkWrap;

  SliverTileGroup({
    Key? key,
    this.children = const [],
    this.header,
    this.footer,
    this.padding,
    this.divider = const Divider(height: 1, thickness: 0.5),
    this.innerDivider = false,
    this.tileColor,
    this.crossAxisAlignment = CrossAxisAlignment.start,
    this.scrollable = false,
    this.shrinkWrap = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    List<Widget> group;
    if (innerDivider) {
      group = divideTiles(children, divider: divider, top: true, bottom: true);
    } else {
      group = [divider, ...children, divider];
    }
    final _children = <Widget>[
      if (header != null) SHeader(header!),
      for (final e in group)
        Material(
          color: tileColor ?? Theme.of(context).cardColor,
          child: e,
        ),
      if (footer != null) SFooter(footer!)
    ];
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) => _children[index],
        childCount: _children.length,
      ),
    );
  }
}

//not finished
class SRadios extends StatefulWidget {
  final List<Widget> tiles;

  const SRadios({Key? key, this.tiles = const []}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _SRadiosState();
}

class _SRadiosState extends State<SRadios> {
  @override
  Widget build(BuildContext context) {
    return TileGroup(
      children: widget.tiles,
    );
  }
}

class RangeSelector<T extends num> extends StatefulWidget {
  final T start;
  final T end;
  final List<T> startItems;
  final List<T> endItems;
  final Widget Function(BuildContext context, T value)? itemBuilder;
  final bool startEnabled;
  final bool endEnabled;
  final void Function(T, T)? onChanged;

  final bool increasing;

  const RangeSelector(
      {Key? key,
      required this.start,
      required this.end,
      required this.startItems,
      required this.endItems,
      this.itemBuilder,
      this.startEnabled = true,
      this.endEnabled = true,
      this.increasing = true,
      this.onChanged})
      : super(key: key);

  @override
  _RangeSelectorState createState() => _RangeSelectorState<T>();
}

class _RangeSelectorState<T extends num> extends State<RangeSelector<T>> {
  _RangeSelectorState();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        DropdownButton<T>(
          value: widget.start,
          items: widget.startItems
              .map((v) => DropdownMenuItem<T>(
                    value: v,
                    child: widget.itemBuilder == null
                        ? Text(v.toString())
                        : widget.itemBuilder!(context, v),
                  ))
              .toList(),
          onChanged: widget.startEnabled
              ? (value) {
                  if (value == null) return;
                  final start = value;
                  final end = widget.increasing
                      ? max(start, widget.end)
                      : min(start, widget.end);
                  if (widget.onChanged != null) {
                    widget.onChanged!(start, end);
                  }
                }
              : null,
        ),
        const Text('   →   '),
        DropdownButton<T>(
          value: widget.end,
          items: widget.endItems
              .map((v) => DropdownMenuItem<T>(
                    value: v,
                    child: widget.itemBuilder == null
                        ? Text(v.toString())
                        : widget.itemBuilder!(context, v),
                  ))
              .toList(),
          onChanged: widget.endEnabled
              ? (value) {
                  if (value == null) return;
                  final end = value;
                  final start = widget.increasing
                      ? min(widget.start, end)
                      : max(widget.start, end);
                  if (widget.onChanged != null) {
                    widget.onChanged!(start, end);
                  }
                }
              : null,
        )
      ],
    );
  }
}

List<Widget> divideTiles(Iterable<Widget> tiles,
    {Widget divider = kDefaultDivider, bool top = false, bool bottom = false}) {
  Iterator iterator = tiles.iterator;
  if (!iterator.moveNext()) {
    return [];
  }
  List<Widget> combined = [];
  if (top) {
    combined.add(divider);
  }
  combined.add(iterator.current);
  while (iterator.moveNext()) {
    combined
      ..add(divider)
      ..add(iterator.current);
  }
  if (bottom) {
    combined.add(divider);
  }
  return combined;
}
