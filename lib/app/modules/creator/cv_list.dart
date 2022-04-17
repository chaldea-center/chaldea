import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/models/models.dart';
import 'package:chaldea/utils/utils.dart';
import 'package:chaldea/widgets/widgets.dart';
import 'package:flutter/material.dart';

import '../../tools/localized_base.dart';

class CvListPage extends StatefulWidget {
  CvListPage({Key? key}) : super(key: key);

  @override
  _CvListPageState createState() => _CvListPageState();
}

class _CvListPageState extends State<CvListPage>
    with SearchableListState<String, CvListPage> {
  @override
  Iterable<String> get wholeData => cvs;

  Map<String, List<Servant>> svtMap = {};
  Map<String, List<CraftEssence>> ceMap = {};
  List<String> cvs = [];

  bool _initiated = false;

  void _parse() async {
    cvs.clear();
    svtMap.clear();
    ceMap.clear();

    void _update<T>(Map<String, List<T>> map, String cv, T card) {
      final creators = cv.split(RegExp(r'[&＆\s]+')).toSet();
      creators.add(cv);
      for (final creator in creators) {
        map.putIfAbsent(creator.trim(), () => []).add(card);
      }
    }

    for (final svt in db.gameData.servants.values) {
      _update<Servant>(svtMap, svt.profile.cv, svt);
    }
    for (final ce in db.gameData.craftEssences.values) {
      if (ce.profile.cv.isNotEmpty) {
        _update<CraftEssence>(ceMap, ce.profile.cv, ce);
      }
    }

    cvs = {...svtMap.keys, ...ceMap.keys}.toList();
    cvs.sort((a, b) =>
        SearchUtil.getSortAlphabet(a).compareTo(SearchUtil.getSortAlphabet(b)));

    if (mounted) {
      setState(() {
        _initiated = true;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _parse();
    options = _CVOptions(
      onChanged: (_) {
        if (mounted) setState(() {});
      },
      state: this,
    );
  }

  @override
  Widget build(BuildContext context) {
    filterShownList(compare: null);
    return scrollListener(
      useGrid: false,
      appBar: AppBar(
        title: Text(S.current.info_cv),
        bottom: showSearchBar ? searchBar : null,
        actions: [searchIcon],
      ),
    );
  }

  @override
  Widget buildScrollable({bool useGrid = false}) {
    if (shownList.isEmpty && !_initiated) {
      return const Center(child: CircularProgressIndicator());
    }
    return super.buildScrollable(useGrid: useGrid);
  }

  @override
  bool filter(String cv) => true;

  @override
  Widget listItemBuilder(String cv) {
    int count = (svtMap[cv]?.length ?? 0) + (ceMap[cv]?.length ?? 0);
    return SimpleAccordion(
      headerBuilder: (context, _) {
        return ListTile(
          title: Text(cv.isEmpty ? '?' : Transl.cvNames(cv).l),
          trailing: Text(count.toString()),
        );
      },
      contentBuilder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (svtMap[cv] != null) _cardGrid(svtMap[cv]!),
          if (ceMap[cv] != null) _cardGrid(ceMap[cv]!),
        ],
      ),
    );
  }

  Widget _cardGrid(List<GameCardMixin> cards) {
    return GridView.extent(
      maxCrossAxisExtent: 60,
      childAspectRatio: 132 / 144,
      padding: const EdgeInsetsDirectional.fromSTEB(16, 2, 16, 8),
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      children: cards.map((e) => e.iconBuilder(context: context)).toList(),
    );
  }

  @override
  Widget gridItemBuilder(String cv) =>
      throw UnimplementedError('GridView not designed');
}

class _CVOptions with SearchOptionsMixin<String> {
  bool cvName = true;
  bool cardName = true;
  @override
  ValueChanged? onChanged;

  _CvListPageState state;

  _CVOptions({this.onChanged, required this.state});

  @override
  Widget builder(BuildContext context, StateSetter setState) {
    return Wrap(
      children: [
        CheckboxWithLabel(
          value: cvName,
          label: Text(S.current.info_cv),
          onChanged: (v) {
            cvName = v ?? cvName;
            setState(() {});
            updateParent();
          },
        ),
        CheckboxWithLabel(
          value: cardName,
          label: Text(LocalizedText.of(
              chs: '卡牌名称', jpn: 'カード名', eng: 'Card Name', kor: '카드명')),
          onChanged: (v) {
            cardName = v ?? cardName;
            setState(() {});
            updateParent();
          },
        ),
      ],
    );
  }

  @override
  Iterable<String?> getSummary(String cv) sync* {
    if (cvName) {
      yield* getAllKeys(Transl.cvNames(cv));
    }
    if (cardName) {
      for (final svt in state.svtMap[cv] ?? <Servant>[]) {
        yield* getAllKeys(svt.lName);
      }
      for (final ce in state.ceMap[cv] ?? <CraftEssence>[]) {
        yield* getAllKeys(ce.lName);
      }
    }
  }
}
