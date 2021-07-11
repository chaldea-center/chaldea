import 'package:chaldea/components/components.dart';
import 'package:chaldea/modules/cmd_code/cmd_code_detail_page.dart';
import 'package:chaldea/modules/craft/craft_detail_page.dart';
import 'package:chaldea/modules/servant/servant_detail_page.dart';

const String _unknownCreator = '---';

class CvListPage extends StatefulWidget {
  @override
  _CvListPageState createState() => _CvListPageState();
}

class _CvListPageState extends SearchableListState<String, CvListPage> {
  Map<String, List<Servant>> cvMap = {};
  List<String> cvs = [];

  void _parse() {
    cvMap.clear();
    cvs.clear();
    for (var svt in db.gameData.servants.values) {
      List<String> cvs = svt.info.lCV;
      if (cvs.isEmpty) cvs = svt.info.cv;
      if (cvs.isEmpty) {
        cvMap.putIfAbsent(_unknownCreator, () => []).add(svt);
      }
      for (var cv in cvs) {
        cvMap.putIfAbsent(cv, () => []).add(svt);
      }
    }
    cvs = cvMap.keys.toList();
    cvs.sort((a, b) => Utils.toAlphabet(a).compareTo(Utils.toAlphabet(b)));

    if (mounted) setState(() {});
  }

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(milliseconds: 400), _parse);
  }

  @override
  Widget build(BuildContext context) {
    filterShownList(data: cvs, compare: null);
    return scrollListener(
      useGrid: false,
      appBar: AppBar(
        leading: BackButton(),
        title: Text(S.current.info_cv),
        bottom: showSearchBar ? searchBar : null,
        actions: [searchIcon],
      ),
    );
  }

  Query __textFilter = Query();
  Map<String, String> searchMap = {};

  @override
  Widget buildScrollable({bool useGrid = false}) {
    if (shownList.isEmpty) {
      return Center(child: CircularProgressIndicator());
    }
    return super.buildScrollable(useGrid: useGrid);
  }

  @override
  bool filter(String keyword, String cv) {
    __textFilter.parse(keyword);
    if (keyword.isNotEmpty && searchMap[cv] == null) {
      List<Servant> cards = cvMap[cv]!;
      if (cards.isEmpty) return false;
      List<String> searchStrings = Utils.getSearchAlphabetsForList(
          cards.first.info.cv, cards.first.info.cvJp, cards.first.info.cvEn);
      for (final svt in cards) {
        searchStrings.addAll([
          ...Utils.getSearchAlphabets(
              svt.info.name, svt.info.nameJp, svt.info.nameEn),
          ...Utils.getSearchAlphabetsForList(svt.info.namesOther,
              svt.info.namesJpOther, svt.info.namesEnOther),
          ...Utils.getSearchAlphabetsForList(svt.info.nicknames),
        ]);
      }
      searchMap[cv] = searchStrings.toSet().join('\t');
    }

    if (keyword.isNotEmpty) {
      if (!__textFilter.match(searchMap[cv]!)) {
        return false;
      }
    }
    return true;
  }

  @override
  Widget listItemBuilder(String cv) {
    final svts = cvMap[cv]!;
    // // add card icon at trailing
    // if (svts.length == 1) {
    //   return ListTile(
    //     title: Text(cv),
    //     trailing: _cardIcon(context, svts.first),
    //   );
    // }
    List<Widget> children = [];
    for (var svt in svts) {
      children.add(_cardIcon(context, svt));
    }
    return SimpleAccordion(
      headerBuilder: (context, _) {
        return ListTile(
          title: Text(cv),
          trailing: Text(svts.length.toString()),
        );
      },
      contentBuilder: (context) => _gridView(context, svts),
    );
  }

  @override
  Widget gridItemBuilder(String cv) =>
      throw UnimplementedError('GridView not allowed');
}

class IllustratorListPage extends StatefulWidget {
  @override
  _IllustratorListPageState createState() => _IllustratorListPageState();
}

class _IllustratorListPageState
    extends SearchableListState<String, IllustratorListPage> {
  Map<String, List<Servant>> svtMap = {};
  Map<String, List<CraftEssence>> craftMap = {};
  Map<String, List<CommandCode>> codeMap = {};
  List<String> illustrators = [];

  void _parse() {
    svtMap.clear();
    craftMap.clear();
    codeMap.clear();
    illustrators.clear();
    db.gameData.servants.values.forEach((svt) {
      svtMap.putIfAbsent(svt.info.lIllustrator, () => []).add(svt);
    });
    db.gameData.crafts.values.forEach((craft) {
      String illus = craft.lIllustrators;
      if (illus.isEmpty) illus = craft.illustrators.join(', ');
      if (illus.isEmpty) illus = _unknownCreator;
      craftMap.putIfAbsent(illus, () => []).add(craft);
    });
    db.gameData.cmdCodes.values.forEach((code) {
      String illus = code.lIllustrators;
      if (illus.isEmpty) illus = code.illustrators.join(', ');
      if (illus.isEmpty) illus = _unknownCreator;
      codeMap.putIfAbsent(illus, () => []).add(code);
    });

    illustrators
      ..addAll(svtMap.keys)
      ..addAll(craftMap.keys)
      ..addAll(codeMap.keys);
    illustrators = illustrators.toSet().toList();
    illustrators
        .sort((a, b) => Utils.toAlphabet(a).compareTo(Utils.toAlphabet(b)));
    if (mounted) setState(() {});
  }

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(milliseconds: 400), _parse);
  }

  @override
  Widget build(BuildContext context) {
    filterShownList(data: illustrators, compare: null);
    return scrollListener(
        useGrid: false,
        appBar: AppBar(
          leading: BackButton(),
          title: Text(S.current.illustrator),
          bottom: showSearchBar ? searchBar : null,
          actions: [searchIcon],
        ));
  }

  @override
  Widget buildScrollable({bool useGrid = false}) {
    if (shownList.isEmpty) {
      return Center(child: CircularProgressIndicator());
    }
    return super.buildScrollable(useGrid: useGrid);
  }

  Query __textFilter = Query();
  Map<String, String> searchMap = {};

  @override
  bool filter(String keyword, String creator) {
    __textFilter.parse(keyword);
    if (keyword.isNotEmpty && searchMap[creator] == null) {
      List<String> searchStrings = [];
      for (final svt in svtMap[creator] ?? <Servant>[]) {
        searchStrings.addAll([
          ...Utils.getSearchAlphabets(svt.info.illustrator,
              svt.info.illustratorJp, svt.info.illustratorEn),
        ]);
        searchStrings.addAll([
          ...Utils.getSearchAlphabets(
              svt.info.name, svt.info.nameJp, svt.info.nameEn),
          ...Utils.getSearchAlphabetsForList(svt.info.namesOther,
              svt.info.namesJpOther, svt.info.namesEnOther),
          ...Utils.getSearchAlphabetsForList(svt.info.nicknames),
        ]);
      }
      for (final craft in craftMap[creator] ?? <CraftEssence>[]) {
        searchStrings.addAll([
          ...Utils.getSearchAlphabets(craft.illustrators.join('\t'),
              craft.illustratorsJp, craft.illustratorsEn),
          ...Utils.getSearchAlphabets(craft.name, craft.nameJp, craft.nameEn),
          ...Utils.getSearchAlphabetsForList(craft.nameOther),
        ]);
      }
      for (final code in codeMap[creator] ?? <CommandCode>[]) {
        searchStrings.addAll([
          ...Utils.getSearchAlphabets(code.illustrators.join('\t'),
              code.illustratorsJp, code.illustratorsEn),
          ...Utils.getSearchAlphabets(code.name, code.nameJp, code.nameEn),
          ...Utils.getSearchAlphabetsForList(code.nameOther),
        ]);
      }
      searchMap[creator] = searchStrings.toSet().join('\t');
    }

    if (keyword.isNotEmpty) {
      if (!__textFilter.match(searchMap[creator]!)) {
        return false;
      }
    }

    return true;
  }

  @override
  Widget listItemBuilder(String creator) {
    int count = (svtMap[creator]?.length ?? 0) +
        (craftMap[creator]?.length ?? 0) +
        (codeMap[creator]?.length ?? 0);
    return SimpleAccordion(
      disableAnimation: true,
      headerBuilder: (context, _) => ListTile(
        title: Text(creator),
        trailing: Text(count.toString()),
      ),
      contentBuilder: (context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (svtMap[creator] != null) _gridView(context, svtMap[creator]!),
            if (craftMap[creator] != null)
              _gridView(context, craftMap[creator]!),
            if (codeMap[creator] != null) _gridView(context, codeMap[creator]!),
          ],
        );
      },
    );
  }

  @override
  Widget gridItemBuilder(String creator) =>
      throw UnimplementedError('GridView not allowed');
}

Widget _cardIcon<T>(BuildContext context, T card) {
  String icon;
  Widget Function(BuildContext, SplitLayout) builder;
  if (card is Servant) {
    icon = card.icon;
    builder = (context, _) => ServantDetailPage(card);
  } else if (card is CraftEssence) {
    icon = card.icon;
    builder = (context, _) => CraftDetailPage(ce: card);
  } else if (card is CommandCode) {
    icon = card.icon;
    builder = (context, _) => CmdCodeDetailPage(code: card);
  } else {
    throw ArgumentError.value(card.runtimeType, 'card', 'Unknown type');
  }
  return InkWell(
    onTap: () {
      SplitRoute.push(
        context: context,
        builder: builder,
        detail: true,
      );
    },
    child: Padding(
      padding: EdgeInsets.all(2),
      child: db.getIconImage(icon, width: 132 / 2.5, height: 144 / 2.5),
    ),
  );
}

Widget _gridView<T>(BuildContext context, List<T> cards) {
  return LayoutBuilder(builder: (context, constraints) {
    int count = constraints.maxWidth ~/ 54;
    return GridView.count(
      childAspectRatio: 132 / 144,
      crossAxisCount: count,
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      physics: NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      children: cards.map((e) => _cardIcon(context, e)).toList(),
    );
  });
}
