import 'package:chaldea/components/animation/animate_on_scroll.dart';
import 'package:chaldea/components/localized/localized.dart';
import 'package:chaldea/components/query.dart';
import 'package:chaldea/components/utils.dart' show DelayedTimer, Utils;
import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/platform_interface/platform/platform.dart';
import 'package:flutter/material.dart';

import 'custom_tile.dart';
import 'search_bar.dart';

abstract class SearchableListState<T, St extends StatefulWidget>
    extends State<St> {
  Iterable<T> get wholeData;

  final List<T> shownList = [];
  T? selected;
  bool showSearchBar = false;

  late ScrollController scrollController;
  late TextEditingController searchEditingController;

  /// String Search
  Query query = Query();

  SearchOptionsMixin<T>? options;

  /// Generate the string summary of datum entry
  String getSummary(T datum);

  /// Extra filters, string search is executed before calling [filter],
  bool filter(T datum);

  void filterShownList({Comparator<T>? compare}) {
    shownList.clear();
    final keyword = searchEditingController.text.trim();
    query.parse(keyword);
    for (final T datum in wholeData) {
      if (keyword.isNotEmpty || (showSearchBar && _allowSummary)) {
        String summary = getSummary(datum);
        if (!query.match(summary)) continue;
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
            Future.delayed(kThemeAnimationDuration, () {
              if (mounted) {
                setState(() {
                  _allowSummary = true;
                });
              }
            });
          }
        });
      },
      icon: const Icon(Icons.search),
      tooltip: S.current.search,
    );
  }

  PreferredSizeWidget get searchBar {
    return SearchBar(
      controller: searchEditingController,
      onChanged: (s) {
        _onSearchTimer.delayed(() {
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

  final _onSearchTimer = DelayedTimer(const Duration(milliseconds: 250));

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
      showTrackOnHover: PlatformU.isDesktopOrWeb,
      child: useGrid
          ? buildGridView()
          : buildListView(topHint: hintText, bottomHint: hintText),
    );
  }

  Widget buildListView({
    Widget? topHint,
    Widget? bottomHint,
    Widget? separator,
  }) {
    List<Widget> children = [];
    if (topHint != null) {
      children.add(topHint);
    }
    for (final datum in shownList) {
      children.add(listItemBuilder(datum));
    }
    if (bottomHint != null) {
      // don't show same hint when nothing shown
      if (shownList.isNotEmpty || bottomHint != topHint) {
        children.add(bottomHint);
      }
    }

    ListView listView;
    if (separator == null) {
      listView = ListView.builder(
        controller: scrollController,
        itemBuilder: (context, index) => children[index],
        itemCount: children.length,
      );
    } else {
      listView = ListView.separated(
        controller: scrollController,
        itemBuilder: (context, index) => children[index],
        separatorBuilder: (context, index) {
          if (index == 0 && topHint != null && children.contains(topHint)) {
            return const Divider(height: 1);
          }
          if (index == children.length - 2 &&
              topHint != null &&
              children.contains(bottomHint)) {
            return const Divider(height: 1);
          }
          return separator;
        },
        itemCount: children.length,
      );
    }
    return _wrapButtonBar(listView);
  }

  Widget buildGridView({
    int? crossCount,
    double childAspectRatio = 130 / 144, //132*144
  }) {
    List<Widget> children = [];

    for (final datum in shownList) {
      children.add(gridItemBuilder(datum));
    }

    Widget grid = LayoutBuilder(builder: (context, constraints) {
      int count = crossCount ??
          (constraints.maxWidth == double.infinity
              ? 7
              : constraints.maxWidth ~/ 64);
      return GridView.builder(
        controller: scrollController,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: count, childAspectRatio: childAspectRatio),
        itemBuilder: (context, index) => children[index],
        itemCount: children.length,
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
      );
    });
    return _wrapButtonBar(grid);
  }

  Widget _wrapButtonBar(Widget child) {
    if (buttonBar == null) {
      return child;
    } else {
      return Column(
        children: [
          Expanded(child: child),
          buttonBar!,
        ],
      );
    }
  }

  Widget listItemBuilder(T datum);

  Widget gridItemBuilder(T datum);

  T? switchNext(T cur, bool reversed, List<T> shownList) {
    T? nextCard = Utils.findNextOrPrevious<T>(
        list: shownList, cur: cur, reversed: reversed, defaultFirst: true);
    if (nextCard != null) selected = nextCard;
    if (mounted) setState(() {});
    return nextCard;
  }

  String defaultHintText(int shown, int total, [int? ignore]) {
    if (ignore == null) {
      return LocalizedText.of(
        chs: '显示$shown/总计$total',
        jpn: '表示$shown/合計$total',
        eng: '$shown shown (total $total)',
        kor: '$shown 표시 (합계 $total)',
      );
    } else {
      return LocalizedText.of(
        chs: '显示$shown/忽略$ignore/总计$total',
        jpn: '表示$shown/無視$ignore/合計$total',
        eng: '$shown shown, $ignore ignored (total $total)',
        kor: '$shown 표시, $ignore 무시 (합계) $total)',
      );
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
