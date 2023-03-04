import 'package:chaldea/app/app.dart';
import 'package:chaldea/app/modules/creator/chara_detail.dart';
import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/models/models.dart';
import 'package:chaldea/utils/utils.dart';
import 'package:chaldea/widgets/widgets.dart';

class CharaListPage extends StatefulWidget {
  CharaListPage({super.key});

  @override
  _CharaListPageState createState() => _CharaListPageState();
}

class _CharaListPageState extends State<CharaListPage> with SearchableListState<String, CharaListPage> {
  @override
  Iterable<String> get wholeData => charas;

  Map<String, List<CraftEssence>> ceMap = {};
  Map<String, List<CommandCode>> ccMap = {};
  List<String> charas = [];

  bool _initiated = false;

  void _parse() async {
    charas.clear();
    ceMap.clear();
    ccMap.clear();

    for (final ce in db.gameData.craftEssences.values) {
      for (final chara in ce.extra.unknownCharacters) {
        ceMap.putIfAbsent(chara, () => []).add(ce);
      }
    }
    for (final cc in db.gameData.commandCodes.values) {
      for (final chara in cc.extra.unknownCharacters) {
        ccMap.putIfAbsent(chara, () => []).add(cc);
      }
    }

    charas = {...ceMap.keys, ...ccMap.keys}.toList();
    final sortKeys = {for (final c in charas) c: SearchUtil.getLocalizedSort(Transl.charaNames(c))};
    charas.sort((a, b) => sortKeys[a]!.compareTo(sortKeys[b]!));

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
    options = _CharaOptions(
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
        title: Text(S.current.characters_in_card),
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
  bool filter(String chara) => true;

  @override
  Widget listItemBuilder(String chara) {
    int count = (ccMap[chara]?.length ?? 0) + (ceMap[chara]?.length ?? 0);
    return SimpleAccordion(
      headerBuilder: (context, _) {
        return ListTile(
          title: InkWell(
            onTap: () {
              router.pushPage(CharaDetail(name: chara));
            },
            child: Text(chara.isEmpty ? '?' : Transl.charaNames(chara).l),
          ),
          trailing: Text(count.toString()),
          contentPadding: const EdgeInsetsDirectional.only(start: 16.0),
        );
      },
      contentBuilder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (ceMap[chara] != null) _cardGrid(ceMap[chara]!),
          if (ccMap[chara] != null) _cardGrid(ccMap[chara]!),
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
  Widget gridItemBuilder(String chara) => throw UnimplementedError('GridView not designed');
}

class _CharaOptions with SearchOptionsMixin<String> {
  bool charaName = true;
  bool cardName = true;
  @override
  ValueChanged? onChanged;

  _CharaListPageState state;

  _CharaOptions({this.onChanged, required this.state});

  @override
  Widget builder(BuildContext context, StateSetter setState) {
    return Wrap(
      children: [
        CheckboxWithLabel(
          value: charaName,
          label: Text(S.current.characters_in_card),
          onChanged: (v) {
            charaName = v ?? charaName;
            setState(() {});
            updateParent();
          },
        ),
        CheckboxWithLabel(
          value: cardName,
          label: Text(S.current.card_name),
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
  Iterable<String?> getSummary(String chara) sync* {
    if (charaName) {
      yield* getAllKeys(Transl.charaNames(chara), dft: Region.cn);
    }
    if (cardName) {
      for (final ce in state.ceMap[chara] ?? <CraftEssence>[]) {
        yield* getAllKeys(ce.lName);
      }
      for (final cc in state.ccMap[chara] ?? <CommandCode>[]) {
        yield* getAllKeys(cc.lName);
      }
    }
  }
}
