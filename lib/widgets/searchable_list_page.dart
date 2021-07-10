import 'package:chaldea/components/animation/animate_on_scroll.dart';
import 'package:chaldea/components/components.dart';
import 'package:chaldea/components/utils.dart' show DelayedTimer;
import 'package:chaldea/generated/l10n.dart';
import 'package:flutter/material.dart';

import 'search_bar.dart';

typedef SearchableItemBuilder<T> = Widget Function(
    BuildContext context, T datum, List<T> shownList);

class SearchableListPage<T> extends StatefulWidget {
  /// data related
  final List<T> data;
  final bool Function(String searchString, T datum)? stringFilter;
  final Comparator? compare;

  final bool useGrid;
  final bool showSearchBar;
  final ScrollController? scrollController;
  final TextEditingController? textEditingController;

  /// (ctx, SearchBar)=>AppBar
  final PreferredSizeWidget? Function(BuildContext, PreferredSizeWidget?)?
      appBarBuilder;
  final SearchableItemBuilder<T>? listItemBuilder;
  final SearchableItemBuilder<T>? gridItemBuilder;
  final PreferredSizeWidget Function(BuildContext context, List<T> shownList)?
      buttonBarBuilder;
  final Widget? listSeparator;
  final double gridChildAspectRatio;
  final Widget Function(BuildContext context, List<T> shownList)?
      topHintBuilder;
  final Widget Function(BuildContext context, List<T> shownList)?
      bottomHintBuilder;

  const SearchableListPage({
    Key? key,
    required this.data,
    this.stringFilter,
    this.compare,
    this.useGrid = false,
    this.showSearchBar = false,
    this.scrollController,
    this.textEditingController,
    this.appBarBuilder,
    required this.listItemBuilder,
    required this.gridItemBuilder,
    this.buttonBarBuilder,
    this.listSeparator = const Divider(height: 1, indent: 16),
    this.gridChildAspectRatio = 130 / 144, //132*144
    this.topHintBuilder,
    this.bottomHintBuilder,
  })  : assert(listItemBuilder != null || gridItemBuilder != null),
        assert((useGrid && gridItemBuilder != null) ||
            (!useGrid && listItemBuilder != null)),
        super(key: key);

  @override
  _SearchableListPageState<T> createState() => _SearchableListPageState<T>();

  static Widget defaultHintBuilder<T>(BuildContext context, List<T> shownList) {
    return CustomTile(
      subtitle: Center(
        child: Text(
          S.of(context).search_result_count(shownList.length),
          style: TextStyle(color: Colors.grey, fontSize: 14),
        ),
      ),
    );
  }
}

class _SearchableListPageState<T> extends State<SearchableListPage<T>> {
  ScrollController? _fallbackScrollController;
  TextEditingController? _fallbackTextEditingController;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    _fallbackScrollController?.dispose();
    _fallbackTextEditingController?.dispose();
  }

  ScrollController get _effectiveScrollController {
    if (widget.scrollController != null) return widget.scrollController!;
    return _fallbackScrollController ??= ScrollController();
  }

  TextEditingController get _effectiveTextEditingController {
    if (widget.textEditingController != null)
      return widget.textEditingController!;
    return _fallbackTextEditingController ??= TextEditingController();
  }

  final List<T> shownList = [];

  @override
  Widget build(BuildContext context) {
    shownList.clear();
    if (widget.stringFilter == null) {
      shownList.addAll(widget.data);
    } else {
      shownList.addAll(widget.data.where((datum) => widget.stringFilter!(
          _effectiveTextEditingController.text.trim(), datum)));
    }
    if (widget.compare != null) shownList.sort(widget.compare!);

    _resolvedButtonBar = null;
    if (widget.buttonBarBuilder != null) {
      _resolvedButtonBar = widget.buttonBarBuilder!(context, shownList);
    }
    return UserScrollListener(
      builder: (context, animationController) => Scaffold(
        appBar: widget.appBarBuilder?.call(context, searchBar),
        floatingActionButton: ScaleTransition(
          scale: animationController,
          child: Padding(
            padding: EdgeInsets.only(
                bottom: _resolvedButtonBar?.preferredSize.height ?? 0),
            child: FloatingActionButton(
              child: Icon(Icons.arrow_upward),
              onPressed: () => _effectiveScrollController.animateTo(0,
                  duration: Duration(milliseconds: 600), curve: Curves.easeOut),
            ),
          ),
        ),
        body: body,
      ),
    );
  }

  final _onSearchTimer = DelayedTimer(Duration(milliseconds: 250));

  PreferredSizeWidget? get searchBar {
    if (!widget.showSearchBar) return null;
    return SearchBar(
      controller: _effectiveTextEditingController,
      onChanged: (s) {
        _onSearchTimer.delayed(() {
          if (mounted)
            setState(() {
              // filterData.filterString = s;
            });
        });
      },
      onSubmitted: (s) {
        FocusScope.of(context).unfocus();
      },
    );
  }

  Widget get body {
    return Scrollbar(
      controller: _effectiveScrollController,
      child: widget.useGrid ? _buildGridView() : _buildListView(),
    );
  }

  Widget _buildListView() {
    List<Widget> children = [];
    if (widget.topHintBuilder != null) {
      children.add(widget.topHintBuilder!(context, shownList));
    }
    if (widget.listItemBuilder != null) {
      for (final datum in shownList) {
        children.add(widget.listItemBuilder!(context, datum, shownList));
      }
    }
    if (widget.bottomHintBuilder != null) {
      children.add(widget.bottomHintBuilder!(context, shownList));
    }

    ListView listView;
    if (widget.listSeparator == null) {
      listView = ListView.builder(
        controller: _effectiveScrollController,
        itemBuilder: (context, index) => children[index],
        itemCount: children.length,
      );
    } else {
      listView = ListView.separated(
        controller: _effectiveScrollController,
        itemBuilder: (context, index) => children[index],
        separatorBuilder: (_, __) => widget.listSeparator!,
        itemCount: children.length,
      );
    }
    return _wrapButtonBar(listView);
  }

  Widget _buildGridView() {
    List<Widget> children = [];
    // if (widget.topHintBuilder != null) {
    //   children.add(widget.topHintBuilder!(context, shownList));
    // }
    if (widget.gridItemBuilder != null) {
      for (final datum in shownList) {
        children.add(widget.gridItemBuilder!(context, datum, shownList));
      }
    }
    // if (widget.bottomHintBuilder != null) {
    //   children.add(widget.bottomHintBuilder!(context, shownList));
    // }

    Widget grid = LayoutBuilder(builder: (context, constraints) {
      int crossCount = constraints.maxWidth ~/ 72;
      if (crossCount == double.infinity) crossCount = 7;
      return GridView.count(
        controller: _effectiveScrollController,
        crossAxisCount: crossCount,
        childAspectRatio: widget.gridChildAspectRatio,
        padding: EdgeInsets.symmetric(horizontal: 4, vertical: 6),
        children: children,
      );
    });
    return _wrapButtonBar(grid);
  }

  PreferredSizeWidget? _resolvedButtonBar;

  Widget _wrapButtonBar(Widget child) {
    if (_resolvedButtonBar == null) {
      return child;
    } else {
      return Column(
        children: [
          Expanded(child: child),
          _resolvedButtonBar!,
        ],
      );
    }
  }
}

mixin SearchableListMixin<T, S extends StatefulWidget> on State<S> {
  T? _selected;

  T? get selected => _selected;

  set selected(T? datum) => _selected = datum;

  Widget listItemBuilder(BuildContext context, T datum, List<T> shownList);

  Widget gridItemBuilder(BuildContext context, T datum, List<T> shownList);

  bool filter(String keyword, T datum);

  T? switchNext(T cur, bool reversed, List<T> shownList) {
    T? nextCard = Utils.findNextOrPrevious<T>(
        list: shownList, cur: cur, reversed: reversed, defaultFirst: true);
    if (nextCard != null) selected = nextCard;
    if (mounted) setState(() {});
    return nextCard;
  }
}
