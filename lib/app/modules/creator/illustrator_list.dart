import 'package:chaldea/components/localized/localized_base.dart';
import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/models/models.dart';
import 'package:chaldea/utils/utils.dart';
import 'package:chaldea/widgets/widgets.dart';
import 'package:flutter/material.dart';

class IllustratorListPage extends StatefulWidget {
  IllustratorListPage({Key? key}) : super(key: key);

  @override
  _IllustratorListPageState createState() => _IllustratorListPageState();
}

class _IllustratorListPageState extends State<IllustratorListPage>
    with SearchableListState<String, IllustratorListPage> {
  @override
  Iterable<String> get wholeData => illustrators;
  bool _initiated = false;
  Map<String, List<Servant>> svtMap = {};
  Map<String, List<CraftEssence>> ceMap = {};
  Map<String, List<CommandCode>> codeMap = {};
  List<String> illustrators = [];

  void _parse() async {
    illustrators.clear();
    svtMap.clear();
    ceMap.clear();
    codeMap.clear();
    void _update<T>(Map<String, List<T>> map, String illust, T card) {
      final creators = illust.split(RegExp(r'[&＆\s]+')).toSet();
      creators.add(illust);
      for (final creator in creators) {
        map.putIfAbsent(creator.trim(), () => []).add(card);
      }
    }

    for (final svt in db2.gameData.servants.values) {
      _update<Servant>(svtMap, svt.profile.illustrator, svt);
    }
    for (final ce in db2.gameData.craftEssences.values) {
      _update<CraftEssence>(ceMap, ce.profile.illustrator, ce);
    }
    for (final cc in db2.gameData.commandCodes.values) {
      _update<CommandCode>(codeMap, cc.illustrator, cc);
    }

    illustrators = {...svtMap.keys, ...ceMap.keys, ...codeMap.keys}.toList();

    illustrators.sort2((a) => SearchUtil.getSortAlphabet(a));
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
    options = _IllustratorOptions(
        onChanged: (_) {
          if (mounted) setState(() {});
        },
        state: this);
  }

  @override
  Widget build(BuildContext context) {
    filterShownList(compare: null);
    return scrollListener(
      useGrid: false,
      appBar: AppBar(
        title: Text(S.current.illustrator),
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
  bool filter(String creator) => true;

  @override
  Widget listItemBuilder(String creator) {
    int count = (svtMap[creator]?.length ?? 0) +
        (ceMap[creator]?.length ?? 0) +
        (codeMap[creator]?.length ?? 0);
    return SimpleAccordion(
      headerBuilder: (context, _) => ListTile(
        title: Text(Transl.illustratorNames(creator).l),
        trailing: Text(count.toString()),
      ),
      contentBuilder: (context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (svtMap[creator] != null) _cardGrid(svtMap[creator]!),
            if (ceMap[creator] != null) _cardGrid(ceMap[creator]!),
            if (codeMap[creator] != null) _cardGrid(codeMap[creator]!),
          ],
        );
      },
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
  Widget gridItemBuilder(String creator) =>
      throw UnimplementedError('GridView not designed');
}

class _IllustratorOptions with SearchOptionsMixin<String> {
  bool creatorName = true;
  bool cardName = true;
  @override
  ValueChanged? onChanged;

  _IllustratorListPageState state;

  _IllustratorOptions({this.onChanged, required this.state});

  @override
  Widget builder(BuildContext context, StateSetter setState) {
    return Wrap(
      children: [
        CheckboxWithLabel(
          value: creatorName,
          label: Text(S.current.illustrator),
          onChanged: (v) {
            creatorName = v ?? creatorName;
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
  Iterable<String?> getSummary2(String creator) sync* {
    if (creatorName) {
      yield* getAllKeys(Transl.illustratorNames(creator));
    }
    if (cardName) {
      for (final svt in state.svtMap[creator] ?? <Servant>[]) {
        yield* getAllKeys(svt.lName);
      }
      for (final ce in state.ceMap[creator] ?? <CraftEssence>[]) {
        yield* getAllKeys(ce.lName);
      }
      for (final cc in state.codeMap[creator] ?? <CommandCode>[]) {
        yield* getAllKeys(cc.lName);
      }
    }
  }
}
