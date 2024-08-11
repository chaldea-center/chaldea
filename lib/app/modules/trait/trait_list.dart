import 'package:chaldea/app/app.dart';
import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/models/models.dart';
import 'package:chaldea/packages/split_route/split_route.dart';
import 'package:chaldea/utils/utils.dart';
import 'package:chaldea/widgets/widgets.dart';
import 'trait.dart';

class TraitListPage extends StatefulWidget {
  final ValueChanged<int>? onSelected;
  final String? initSearchString;
  final bool multipleMode;
  TraitListPage({super.key, this.onSelected, this.initSearchString, bool? multipleMode})
      : multipleMode = multipleMode ?? onSelected == null;

  @override
  _TraitListPageState createState() => _TraitListPageState();
}

class _TraitListPageState extends State<TraitListPage> with SearchableListState<int, TraitListPage> {
  Set<int> selectedTraits = {};

  @override
  void initState() {
    super.initState();
    searchEditingController = TextEditingController(text: widget.initSearchString);
  }

  @override
  Iterable<int> get wholeData {
    List<int> sortedIds = {
      ...Trait.values.map((e) => e.value),
      ...db.gameData.mappingData.trait.keys,
      ...db.gameData.mappingData.eventTrait.keys,
      ...db.gameData.mappingData.fieldTrait.keys,
    }.toList();
    sortedIds.sort();
    int? _searchInt = int.tryParse(searchEditingController.text);
    if (_searchInt != null) {
      if (sortedIds.contains(_searchInt)) {
        sortedIds.remove(_searchInt);
        sortedIds.insert(0, _searchInt);
      } else {
        sortedIds.insert(0, _searchInt);
      }
    }
    if (_searchInt != null && !sortedIds.contains(_searchInt)) sortedIds.insert(0, _searchInt);
    sortedIds.remove(Trait.unknown.value);
    return sortedIds;
  }

  Trait? getTrait(int id) => kTraitIdMapping[id];

  @override
  Widget build(BuildContext context) {
    filterShownList(compare: null);
    return scrollListener(
      useGrid: false,
      appBar: AppBar(
        leading: const MasterBackButton(),
        title: Text(S.current.trait),
        bottom: searchBar,
        actions: const [],
      ),
    );
  }

  @override
  bool filter(int id) => true;

  @override
  Iterable<String?> getSummary(int id) sync* {
    yield id.toString();
    yield getTrait(id)?.name;
    yield* SearchUtil.getAllKeys(Transl.trait(id));
    final warIds = db.gameData.mappingData.fieldTrait[id]?.warIds;
    if (warIds != null) {
      for (final warId in warIds) {
        if (warId > 1000) yield 'fieldWar$warId';
      }
    }
  }

  @override
  Widget listItemBuilder(int id) {
    final trait = getTrait(id);
    String title, subtitle;
    if (Trait.isEventField(id)) {
      title = 'ID $id';
      final warIds = db.gameData.mappingData.fieldTrait[id]?.warIds.toList() ?? [];
      warIds.sort();
      if (warIds.length > 2 && warIds.every((e) => e < 1000)) {
        subtitle = "War ${warIds.join('\u200B/')}";
      } else {
        subtitle = warIds
            .map((e) {
              final war = db.gameData.wars[e];
              final event = war?.eventReal;
              if (event != null) return event.lShortName.l.setMaxLines(1);
              if (war != null) return war.lShortName;
              return "War $e";
            })
            .toSet()
            .join(" / ");
      }
    } else {
      title = Transl.trait(id).l;
      subtitle = 'ID $id';
      if (trait != null) {
        subtitle += '  ${trait.name}';
      }
    }

    final hasTransl = id.toString() != title;
    return ListTile(
      dense: true,
      title: Text(hasTransl ? title : subtitle),
      subtitle: hasTransl ? Text(subtitle, maxLines: 2, overflow: TextOverflow.ellipsis) : null,
      onTap: () {
        if (widget.onSelected != null) {
          Navigator.pop(context);
          widget.onSelected!(id);
        } else {
          router.popDetailAndPush(context: context, url: Routes.traitI(id));
        }
      },
      trailing: widget.multipleMode
          ? Checkbox(
              value: selectedTraits.contains(id),
              onChanged: (v) {
                setState(() {
                  selectedTraits.toggle(id);
                });
              },
            )
          : null,
    );
  }

  @override
  PreferredSizeWidget? get buttonBar {
    if (!widget.multipleMode) return null;
    return PreferredSize(
      preferredSize: const Size.fromHeight(48),
      child: OverflowBar(
        alignment: MainAxisAlignment.center,
        children: [
          FilledButton(
            onPressed: selectedTraits.isEmpty
                ? null
                : () {
                    router.popDetailAndPush(context: context, child: TraitDetailPage.ids(ids: selectedTraits.toList()));
                  },
            child: Text(
              selectedTraits.isEmpty
                  ? '0 ${S.current.trait}'
                  : selectedTraits.map((e) => Transl.trait(e).l).join(' & '),
              textAlign: TextAlign.center,
            ),
          ),
          IconButton(
            onPressed: selectedTraits.isEmpty
                ? null
                : () {
                    setState(() {
                      selectedTraits.clear();
                    });
                  },
            icon: const Icon(Icons.replay),
            tooltip: S.current.clear,
          ),
        ],
      ),
    );
  }

  @override
  Widget gridItemBuilder(int id) => throw UnimplementedError('GridView not designed');
}
