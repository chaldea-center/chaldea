import 'package:chaldea/components/components.dart';
import 'package:flutter/material.dart';

class SHeader extends StatelessWidget {
  final String label;

  SHeader(this.label);

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Container(
      padding: const EdgeInsets.only(left: 10.0, top: 30.0, bottom: 5.0),
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
    // TODO: implement build
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
    // TODO: implement build
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
    // TODO: implement build
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
    // TODO: implement build
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
    final r = RadioListTile(
      groupValue: null,
      onChanged: (value) {},
      value: null,
    );
    return SGroup(
      children: labels
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

/// [children] should be [SSwitch] or [SModal] or []
class SGroup extends StatelessWidget {
  final List<Widget> children;
  final String header;
  final String footer;

  const SGroup({Key key, @required this.children, this.header, this.footer})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    bool _first = true; // add top border of first child
    final List<Widget> group = children.map((child) {
      final box = Container(
        decoration: BoxDecoration(
          border: Border(
              top: _first
                  ? Divider.createBorderSide(context, width: 0.5)
                  : BorderSide.none,
              bottom: Divider.createBorderSide(context, width: 0.5)),
        ),
        child: child,
      );
      _first = false;
      return box;
    }).toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[]
        ..addAll(null == header ? [] : [SHeader(header)])
        ..addAll(group)
        ..addAll(null == footer ? [] : [SFooter(footer)]),
    );
  }
}

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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[]
        ..addAll(null == header ? [] : [SHeader(header)])
        ..addAll(group)
        ..addAll(null == footer ? [] : [SFooter(footer)]),
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
