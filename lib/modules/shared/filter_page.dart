import 'package:chaldea/components/components.dart';

abstract class FilterPage<T> extends StatefulWidget {
  final T filterData;
  final ValueChanged<T>? onChanged;

  const FilterPage({Key? key, required this.filterData, this.onChanged})
      : super(key: key);

  static void show(
      {required BuildContext context, required WidgetBuilder builder}) {
    if (SplitRoute.isSplit(context)) {
      showDialog(context: context, builder: builder);
    } else {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        builder: (context) => builder(context),
      );
    }
  }
}

abstract class FilterPageState<T> extends State<FilterPage<T>> {
  T get filterData => widget.filterData;

  TextStyle textStyle = TextStyle(fontSize: 16);
  bool? _useTabletView;

  bool get useSplitView {
    _useTabletView ??= SplitRoute.isSplit(context);
    return _useTabletView!;
  }

  void update() {
    if (widget.onChanged != null) {
      widget.onChanged!(filterData);
    }
    setState(() {});
  }

  Widget buildAdaptive(
      {Widget? title,
      required Widget content,
      List<Widget> actions = const []}) {
    return useSplitView
        ? _buildDialog(title: title, content: content, actions: actions)
        : _buildSheet(title: title, content: content, actions: actions);
  }

  Widget _buildSheet(
      {Widget? title,
      required Widget content,
      List<Widget> actions = const []}) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AppBar(
          elevation: 0,
          leading: BackButton(),
          title: title,
          actions: actions,
        ),
        content
      ],
    );
  }

  Widget _buildDialog(
      {Widget? title,
      required Widget content,
      List<Widget> actions = const []}) {
    return AlertDialog(
      backgroundColor: AppColors.setting_bg,
      title: Center(child: title),
      titlePadding: EdgeInsets.fromLTRB(24, 12, 24, 12),
      contentPadding: EdgeInsets.zero,
      actionsPadding: EdgeInsets.zero,
      actions: actions,
      content: Container(
        color: Colors.white,
        // for landscape, limit it's width
        width: defaultDialogWidth(context),
        // for portrait, limit it's height
        constraints: BoxConstraints(maxHeight: defaultDialogHeight(context)),
        child: content,
      ),
    );
  }

  List<Widget> getDefaultActions(
      {VoidCallback? onTapReset,
      bool? showOk,
      List<Widget> extraActions = const []}) {
    showOk ??= useSplitView;
    if (useSplitView) {
      return [
        ...extraActions,
        TextButton(
          child: Text(S.of(context).reset.toUpperCase(),
              style: TextStyle(color: Colors.redAccent)),
          // textColor: Colors.redAccent,
          onPressed: onTapReset,
        ),
        if (showOk)
          TextButton(
            child: Text(S.of(context).ok.toUpperCase()),
            onPressed: () => Navigator.pop(context),
          ),
      ];
    } else {
      return [
        ...extraActions,
        IconButton(icon: Icon(Icons.replay), onPressed: onTapReset),
        if (showOk)
          IconButton(
              icon: Icon(Icons.done), onPressed: () => Navigator.pop(context))
      ];
    }
  }

  Widget getListViewBody({List<Widget> children = const []}) {
    final size = MediaQuery.of(context).size;
    return LimitedBox(
      maxHeight: min(420, size.height * 0.65),
      child: ListView(
        padding: EdgeInsets.symmetric(vertical: 6),
        shrinkWrap: true,
        children: divideTiles(children,
            divider: Divider(color: Colors.transparent, height: 5)),
      ),
    );
  }

  Widget getGroup({
    String? header,
    List<Widget> children = const [],
    EdgeInsetsGeometry padding = const EdgeInsets.symmetric(horizontal: 12),
  }) {
    return Padding(
      padding: padding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          if (header != null)
            CustomTile(
              title: Text(header, style: textStyle),
              contentPadding: EdgeInsets.zero,
            ),
          Wrap(
            spacing: 6,
            runSpacing: 3,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: children,
          )
        ],
      ),
    );
  }

  Widget getDisplayOptions({String? header, List<Widget> children = const []}) {
    header ??= S.current.filter_shown_type;
    return Padding(
      padding: EdgeInsets.fromLTRB(12, 6, 12, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          CustomTile(
            title: Text(header, style: textStyle),
            contentPadding: EdgeInsets.zero,
          ),
          Wrap(
            spacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: children,
          )
        ],
      ),
    );
  }

  Widget getSortButton<T>(
      {String? prefix,
      required T value,
      required Map<T, String> items,
      ValueChanged<T?>? onSortAttr,
      bool reversed = true,
      ValueChanged<bool>? onSortDirectional}) {
    return DecoratedBox(
      decoration: BoxDecoration(
          border: Border(bottom: BorderSide(width: 0, color: Colors.grey))),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (prefix != null) Text(prefix + ' - ', style: textStyle),
          DropdownButtonHideUnderline(
              child: DropdownButton(
            isDense: true,
            value: value,
            items: items.entries
                .map((e) => DropdownMenuItem(
                    child: Text(e.value, style: textStyle), value: e.key))
                .toList(),
            onChanged: onSortAttr,
          )),
          IconButton(
            icon: Icon(reversed ? Icons.south_rounded : Icons.north_rounded),
            onPressed: () {
              if (onSortDirectional != null) {
                onSortDirectional(!reversed);
              }
            },
            padding: EdgeInsets.zero,
            constraints: BoxConstraints.loose(Size.square(24)),
            iconSize: 20,
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent,
          )
        ],
      ),
    );
  }
}

// for filter items
typedef bool FilterCallBack<T>(T data);

class FilterGroup extends StatelessWidget {
  final Widget? title;
  final List<String> options;
  final FilterGroupData values;
  final Widget Function(String value)? optionBuilder;
  final bool showMatchAll;
  final bool showInvert;
  final bool useRadio;
  final void Function(FilterGroupData optionData)? onFilterChanged;

  final bool combined;
  final EdgeInsetsGeometry padding;

  FilterGroup({
    Key? key,
    this.title,
    required this.options,
    required this.values,
    this.optionBuilder,
    this.showMatchAll = false,
    this.showInvert = false,
    this.useRadio = false,
    this.onFilterChanged,
    this.combined = false,
    this.padding = const EdgeInsets.symmetric(horizontal: 12),
  }) : super(key: key);

  Widget _buildCheckbox(
      BuildContext context, bool checked, String text, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        children: <Widget>[
          Icon(
            checked ? Icons.check_box : Icons.check_box_outline_blank,
            color: Colors.grey,
          ),
          Text(text)
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> _optionChildren = [];
    for (int index = 0; index < options.length; index++) {
      String key = options[index];
      _optionChildren.add(FilterOption(
        selected: values.options[key] ?? false,
        value: key,
        child: optionBuilder == null ? Text('$key') : optionBuilder!(key),
        borderRadius: combined
            ? BorderRadius.horizontal(
                left: Radius.circular(index == 0 ? 3 : 0),
                right: Radius.circular(index == options.length - 1 ? 3 : 0),
              )
            : BorderRadius.circular(3),
        onChanged: (v) {
          if (useRadio) {
            values.options.clear();
            values.options[key] = true;
          } else {
            values.options[key] = v;
            values.options.removeWhere((k, v) => v != true);
          }
          if (onFilterChanged != null) {
            onFilterChanged!(values);
          }
        },
      ));
    }

    Widget child = Wrap(
      spacing: combined ? 0 : 6,
      runSpacing: 3,
      children: _optionChildren,
    );

    if (title != null) {
      child = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          CustomTile(
            title: DefaultTextStyle.merge(
                child: title!, style: TextStyle(fontSize: 14)),
            contentPadding: EdgeInsets.zero,
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                if (showMatchAll)
                  _buildCheckbox(context, values.matchAll, 'Match All', () {
                    values.matchAll = !values.matchAll;
                    if (onFilterChanged != null) {
                      onFilterChanged!(values);
                    }
                  }),
                if (showInvert)
                  _buildCheckbox(context, values.invert, 'Invert', () {
                    values.invert = !values.invert;
                    if (onFilterChanged != null) {
                      onFilterChanged!(values);
                    }
                  })
              ],
            ),
          ),
          child,
        ],
      );
    }

    return Padding(padding: padding, child: child);
  }
}

class FilterOption<T> extends StatelessWidget {
  final bool selected;
  final T value;
  final Widget? child;
  final ValueChanged<bool>? onChanged;
  final Color? selectedColor;
  final Color? unselectedColor;
  final Color? selectedTextColor;
  final BorderRadius borderRadius;

  FilterOption({
    Key? key,
    required this.selected,
    required this.value,
    this.child,
    this.onChanged,
    this.selectedColor,
    this.unselectedColor,
    this.selectedTextColor = Colors.white,
    this.borderRadius = const BorderRadius.all(Radius.circular(3)),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final _selectedColor = selectedColor ?? Theme.of(context).primaryColor;
    return ConstrainedBox(
      constraints: BoxConstraints(maxHeight: 30),
      child: ButtonTheme(
        height: 20,
        minWidth: 30,
        padding: EdgeInsets.zero,
        child: OutlinedButton(
          onPressed: () {
            if (onChanged != null) {
              onChanged!(!selected);
            }
          },
          style: OutlinedButton.styleFrom(
            primary: selected ? Colors.white : Colors.black,
            backgroundColor: selected ? _selectedColor : unselectedColor,
            // minimumSize: Size(6, 4),
            // padding: EdgeInsets.symmetric(horizontal: 5),
            textStyle: TextStyle(fontWeight: FontWeight.normal),
            shape: ContinuousRectangleBorder(borderRadius: borderRadius),
          ),
          child: child ?? Text(value.toString()),
          // shape: ,
        ),
      ),
    );
  }
}
