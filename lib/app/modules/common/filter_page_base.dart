import 'dart:math';

import 'package:flutter/material.dart';

import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/packages/split_route/split_route.dart';
import 'package:chaldea/widgets/custom_tile.dart';
import 'package:chaldea/widgets/tile_items.dart';

abstract class FilterPage<T> extends StatefulWidget {
  final T filterData;
  final ValueChanged<T>? onChanged;

  const FilterPage({Key? key, required this.filterData, this.onChanged})
      : super(key: key);

  static void show(
      {required BuildContext context, required WidgetBuilder builder}) {
    if (SplitRoute.isSplit(context)) {
      showDialog(context: context, builder: builder, useRootNavigator: false);
    } else {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        builder: (context) => LayoutBuilder(builder: (context, constraints) {
          return ConstrainedBox(
            constraints:
                constraints.copyWith(maxHeight: constraints.maxHeight * 0.7),
            child: SafeArea(child: builder(context)),
          );
        }),
      );
    }
  }
}

abstract class FilterPageState<T> extends State<FilterPage<T>> {
  T get filterData => widget.filterData;

  TextStyle textStyle = const TextStyle(fontSize: 16);
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
          toolbarHeight: 40,
          leading: const BackButton(),
          title: title,
          centerTitle: true,
          actions: actions,
        ),
        Flexible(
          child: ConstrainedBox(
            constraints: BoxConstraints(
                minHeight: min(400, MediaQuery.of(context).size.height * 0.4)),
            child: content,
          ),
        ),
        const SafeArea(child: SizedBox()),
      ],
    );
  }

  Widget _buildDialog(
      {Widget? title,
      required Widget content,
      List<Widget> actions = const []}) {
    return AlertDialog(
      title: Center(child: title),
      titlePadding: const EdgeInsetsDirectional.fromSTEB(24, 12, 24, 12),
      contentPadding: EdgeInsets.zero,
      actionsPadding: EdgeInsets.zero,
      actions: actions,
      content: Container(
        // for landscape, limit it's width
        width: min(420, MediaQuery.of(context).size.width * 0.8),
        // for portrait, limit it's height
        constraints: BoxConstraints(
            maxHeight: min(420, MediaQuery.of(context).size.width * 0.8)),
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
              style: const TextStyle(color: Colors.redAccent)),
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
        IconButton(icon: const Icon(Icons.replay), onPressed: onTapReset),
        if (showOk)
          IconButton(
              icon: const Icon(Icons.done),
              onPressed: () => Navigator.pop(context))
      ];
    }
  }

  Widget getListViewBody({List<Widget> children = const []}) {
    final size = MediaQuery.of(context).size;
    return LimitedBox(
      maxHeight: min(420, size.height * 0.65),
      child: ListView(
        padding: const EdgeInsets.symmetric(vertical: 6),
        shrinkWrap: true,
        children: divideTiles(children,
            divider: const Divider(color: Colors.transparent, height: 5)),
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
            spacing: 8,
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
      padding: const EdgeInsetsDirectional.fromSTEB(12, 6, 12, 0),
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

  Widget getSortButton<S>(
      {String? prefix,
      required S value,
      required Map<S, String> items,
      ValueChanged<S?>? onSortAttr,
      bool reversed = true,
      ValueChanged<bool>? onSortDirectional}) {
    return DropdownButton(
      isDense: true,
      value: value,
      icon: IconButton(
        icon: Icon(reversed ? Icons.south_rounded : Icons.north_rounded),
        onPressed: () {
          if (onSortDirectional != null) {
            onSortDirectional(!reversed);
          }
        },
        padding: EdgeInsets.zero,
        constraints: BoxConstraints.loose(const Size.square(24)),
        iconSize: 20,
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
      ),
      items: items.entries
          .map((e) => DropdownMenuItem(
              child: Text(e.value, style: textStyle), value: e.key))
          .toList(),
      onChanged: onSortAttr,
    );
  }
}
