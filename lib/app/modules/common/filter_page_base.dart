import 'dart:math';

import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/packages/split_route/split_route.dart';
import 'package:chaldea/widgets/widgets.dart';
import '../../../models/models.dart';

abstract class FilterPage<T> extends StatefulWidget {
  final T filterData;
  final ValueChanged<T>? onChanged;

  const FilterPage({super.key, required this.filterData, this.onChanged});

  static void show({required BuildContext context, required WidgetBuilder builder}) {
    if (SplitRoute.isSplit(context)) {
      showDialog(context: context, builder: builder, useRootNavigator: false);
    } else {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        builder: (context) => LayoutBuilder(builder: (context, constraints) {
          return ConstrainedBox(
            constraints: constraints.copyWith(maxHeight: constraints.maxHeight * 0.7),
            child: SafeArea(child: builder(context)),
          );
        }),
      );
    }
  }
}

abstract class FilterPageState<T, St extends FilterPage<T>> extends State<St> {
  T get filterData => widget.filterData;

  TextStyle textStyle = const TextStyle();
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

  Widget buildAdaptive({Widget? title, required Widget content, List<Widget> actions = const []}) {
    return useSplitView
        ? _buildDialog(title: title, content: content, actions: actions)
        : _buildSheet(title: title, content: content, actions: actions);
  }

  Widget _buildSheet({Widget? title, required Widget content, List<Widget> actions = const []}) {
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
            constraints: BoxConstraints(minHeight: min(400, MediaQuery.of(context).size.height * 0.4)),
            child: content,
          ),
        ),
        const SafeArea(child: SizedBox()),
      ],
    );
  }

  Widget _buildDialog({Widget? title, required Widget content, List<Widget> actions = const []}) {
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
        constraints: BoxConstraints(maxHeight: min(420, MediaQuery.of(context).size.width * 0.8)),
        child: content,
      ),
    );
  }

  List<Widget> getDefaultActions({VoidCallback? onTapReset, bool? showOk, List<Widget> extraActions = const []}) {
    showOk ??= useSplitView;
    if (useSplitView) {
      return [
        ...extraActions,
        TextButton(
          onPressed: onTapReset,
          child: Text(
            S.current.reset.toUpperCase(),
            style: const TextStyle(color: Colors.redAccent),
          ),
        ),
        if (showOk)
          TextButton(
            child: Text(S.current.ok.toUpperCase()),
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
            onPressed: () => Navigator.pop(context),
          )
      ];
    }
  }

  Widget getListViewBody({List<Widget> children = const [], String? restorationId}) {
    final size = MediaQuery.of(context).size;
    return LimitedBox(
      maxHeight: min(420, size.height * 0.65),
      child: ScrollRestoration(
        restorationId: restorationId,
        builder: (context, controller) => ListView(
          controller: controller,
          padding: const EdgeInsets.symmetric(vertical: 6),
          shrinkWrap: true,
          children: divideTiles(children, divider: const Divider(color: Colors.transparent, height: 5)),
        ),
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
              value: e.key,
              child: Text(
                e.value,
                style: textStyle,
                textScaleFactor: 0.9,
              )))
          .toList(),
      onChanged: onSortAttr,
    );
  }

  Widget buildClassFilter(
    FilterGroupData<SvtClass> data, {
    VoidCallback? onChanged,
    bool showUnknown = false,
  }) {
    final shownClasses = [
      ...SvtClassX.regularAllWithBeast,
      if (showUnknown) SvtClass.unknown,
    ];
    int crossCount = (shownClasses.length / 2).ceil();
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(S.current.svt_class, style: textStyle),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: Row(
              children: <Widget>[
                Expanded(
                  flex: 1,
                  child: GridView.count(
                    crossAxisCount: 1,
                    childAspectRatio: 1.2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    children: List.generate(2, (index) {
                      final icon = SvtClass.ALL.icon(index == 0 ? 5 : 1);
                      return GestureDetector(
                        child: db.getIconImage(icon, width: 60),
                        onTap: () {
                          data.options = index == 0 ? shownClasses.toSet() : {};
                          update();
                          onChanged?.call();
                        },
                      );
                    }),
                  ),
                ),
                Container(width: 10),
                Expanded(
                  flex: crossCount,
                  child: GridView.count(
                    crossAxisCount: crossCount,
                    shrinkWrap: true,
                    childAspectRatio: 1.2,
                    physics: const NeverScrollableScrollPhysics(),
                    children: shownClasses.map((className) {
                      final selected = data.options.contains(className);
                      Widget icon = db.getIconImage(className.icon(selected ? 5 : 1), aspectRatio: 1);
                      return GestureDetector(
                        child: icon,
                        onTap: () {
                          data.toggle(className);
                          update();
                          onChanged?.call();
                        },
                      );
                    }).toList(),
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildGroupDivider({String? text, Widget? child}) {
    if (text == null && child == null) {
      return const Divider(
        height: 16,
        indent: 12,
        endIndent: 12,
        thickness: 1,
      );
    }
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Expanded(
            child: Divider(
              height: 16,
              indent: 12,
              endIndent: 8,
              thickness: 1,
            ),
          ),
          child ?? Text(text!, style: Theme.of(context).textTheme.bodySmall),
          const Expanded(
            child: Divider(
              height: 16,
              indent: 8,
              endIndent: 12,
              thickness: 1,
            ),
          ),
        ],
      ),
    );
  }
}
