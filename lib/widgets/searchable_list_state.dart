import 'package:flutter/material.dart';

import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/packages/packages.dart';
import 'package:chaldea/packages/query.dart';
import 'package:chaldea/utils/utils.dart';
import 'animation_on_scroll.dart';
import 'custom_tile.dart';
import 'search_bar.dart';

mixin SearchableListState<T, St extends StatefulWidget> on State<St> {
  Iterable<T> get wholeData;

  final List<T> shownList = [];
  T? selected;
  bool showSearchBar = false;
  bool showOddBg = false;

  late ScrollController scrollController;
  late TextEditingController searchEditingController;

  /// String Search
  Query query = Query();

  SearchOptionsMixin<T>? options;

  /// Generate the string summary of datum entry
  Iterable<String?> getSummary(T datum) => options?.getSummary(datum) ?? [];

  /// Extra filters, string search is executed before calling [filter],
  bool filter(T datum);

  void filterShownList({Comparator<T>? compare}) {
    shownList.clear();
    final keyword = searchEditingController.text.trim();
    query.parse(keyword);
    for (final T datum in wholeData) {
      if (keyword.isNotEmpty || (showSearchBar && _allowSummary)) {
        if (!query.match(getSummary(datum))) continue;
      }
      if (filter(datum)) {
        shownList.add(datum);
      }
    }
    if (compare != null) shownList.sort(compare);
  }

  /// end of String Search

  @override
  void initState() {
    super.initState();
    scrollController = ScrollController();
    searchEditingController = TextEditingController();
  }

  @override
  void dispose() {
    super.dispose();
    scrollController.dispose();
    searchEditingController.dispose();
  }

  bool _allowSummary = false;

  Widget get searchIcon {
    return IconButton(
      onPressed: () {
        setState(() {
          showSearchBar = !showSearchBar;
          if (!showSearchBar) searchEditingController.text = '';
          if (showSearchBar && !_allowSummary) {
            EasyDebounce.debounce('query_string', const Duration(seconds: 1),
                () {
              if (mounted) {
                setState(() {
                  _allowSummary = true;
                });
              }
            });
          }
        });
      },
      icon: Icon(showSearchBar ? Icons.search_off : Icons.search),
      tooltip: S.current.search,
    );
  }

  PreferredSizeWidget get searchBar {
    return SearchBar(
      controller: searchEditingController,
      onChanged: (s) {
        EasyDebounce.debounce(
            'search_onchanged', const Duration(milliseconds: 300), () {
          if (mounted) setState(() {});
        });
      },
      onSubmitted: (s) {
        FocusScope.of(context).unfocus();
      },
      searchOptionsBuilder: options?.builder,
    );
  }

  PreferredSizeWidget? buttonBar;

  Widget scrollListener({
    required bool useGrid,
    PreferredSizeWidget? appBar,
  }) {
    return UserScrollListener(
      shouldAnimate: (userScroll) => userScroll.metrics.axis == Axis.vertical,
      builder: (context, animationController) => Scaffold(
        appBar: appBar,
        floatingActionButton: ScaleTransition(
          scale: animationController,
          child: Padding(
            padding:
                EdgeInsets.only(bottom: buttonBar?.preferredSize.height ?? 0),
            child: FloatingActionButton(
              child: const Icon(Icons.arrow_upward),
              onPressed: () => scrollController.animateTo(0,
                  duration: const Duration(milliseconds: 600),
                  curve: Curves.easeOut),
            ),
          ),
        ),
        body: buildScrollable(useGrid: useGrid),
      ),
    );
  }

  Widget buildScrollable({bool useGrid = false}) {
    final hintText = defaultHintBuilder(
        context, defaultHintText(shownList.length, wholeData.length));
    return Scrollbar(
      controller: scrollController,
      trackVisibility: PlatformU.isDesktopOrWeb,
      child: useGrid
          ? buildGridView(
              topHint: hintText,
              bottomHint: hintText,
            )
          : buildListView(topHint: hintText, bottomHint: hintText),
    );
  }

  double? itemExtent;
  // TODO: move to func param somewhere
  bool get prototypeExtent => false;

  Widget buildListView({
    Widget? topHint,
    Widget? bottomHint,
    Widget? separator,
  }) {
    List<Widget> slivers = [];

    if (topHint != null) {
      slivers.add(SliverToBoxAdapter(child: topHint));
    }
    Widget? _itemBuilder(BuildContext context, int index) {
      if (index >= 0 && index < shownList.length) {
        Widget child = listItemBuilder(shownList[index]);
        if (showOddBg) {
          child = DecoratedBox(
            decoration: BoxDecoration(
              color: index.isEven ? Theme.of(context).hoverColor : null,
            ),
            child: child,
          );
        }
        return child;
      }
      return null;
    }

    if (shownList.isEmpty) {
      // do nothing
    } else if (itemExtent != null) {
      slivers.add(SliverFixedExtentList(
        delegate: SliverChildBuilderDelegate(
          _itemBuilder,
          childCount: shownList.length,
        ),
        itemExtent: itemExtent!,
      ));
    } else if (prototypeExtent == true) {
      slivers.add(SliverPrototypeExtentList(
        delegate: SliverChildBuilderDelegate(
          _itemBuilder,
          childCount: shownList.length,
        ),
        prototypeItem: listItemBuilder(shownList.first),
      ));
    } else {
      slivers.add(SliverList(
        delegate: SliverChildBuilderDelegate(
          _itemBuilder,
          childCount: shownList.length,
        ),
      ));
    }

    if (bottomHint != null && (shownList.length > 5 || bottomHint != topHint)) {
      slivers.add(SliverToBoxAdapter(child: bottomHint));
    }
    slivers.add(
        const SliverSafeArea(sliver: SliverPadding(padding: EdgeInsets.zero)));

    return _wrapButtonBar(
      CustomScrollView(
        controller: scrollController,
        slivers: slivers,
        physics: const AlwaysScrollableScrollPhysics(),
      ),
    );
  }

  Widget buildGridView({
    double? maxCrossAxisExtent,
    double childAspectRatio = 132 / 144, //132*144
    Widget? topHint,
    Widget? bottomHint,
  }) {
    List<Widget> slivers = [];
    if (topHint != null) {
      slivers.add(SliverToBoxAdapter(child: topHint));
    }
    if (shownList.isNotEmpty) {
      slivers.add(SliverPadding(
        padding: const EdgeInsets.symmetric(horizontal: 6),
        sliver: SliverGrid.extent(
          maxCrossAxisExtent: maxCrossAxisExtent ?? 72,
          mainAxisSpacing: 2,
          crossAxisSpacing: 2,
          childAspectRatio: childAspectRatio,
          children: [
            for (final datum in shownList) gridItemBuilder(datum),
          ],
        ),
      ));
    }
    if (bottomHint != null &&
        (shownList.length > 20 || bottomHint != topHint)) {
      slivers.add(SliverToBoxAdapter(child: bottomHint));
    }
    slivers.add(
        const SliverSafeArea(sliver: SliverPadding(padding: EdgeInsets.zero)));

    return _wrapButtonBar(
      CustomScrollView(
        controller: scrollController,
        slivers: slivers,
        physics: const AlwaysScrollableScrollPhysics(),
      ),
    );
  }

  Widget _wrapButtonBar(Widget child) {
    if (buttonBar == null) {
      return child;
    } else {
      return Column(
        children: [
          Expanded(child: child),
          SafeArea(child: buttonBar!),
        ],
      );
    }
  }

  Widget listItemBuilder(T datum);

  Widget gridItemBuilder(T datum);

  T? switchNext(T cur, bool reversed, List<T> shownList) {
    T? nextCard = Utility.findNextOrPrevious<T>(
        list: shownList, cur: cur, reversed: reversed, defaultFirst: true);
    if (nextCard != null) selected = nextCard;
    if (mounted) setState(() {});
    return nextCard;
  }

  String defaultHintText(int shown, int total, [int? ignore]) {
    if (ignore == null) {
      return S.current.list_count_shown_all(shown, total);
    } else {
      return S.current.list_count_shown_hidden_all(shown, ignore, total);
    }
  }

  static Widget defaultHintBuilder(BuildContext context, String text) {
    return CustomTile(
      contentPadding: const EdgeInsets.symmetric(vertical: 2),
      subtitle: Center(
        child: Text(
          text,
          style: const TextStyle(color: Colors.grey, fontSize: 14),
        ),
      ),
    );
  }
}
