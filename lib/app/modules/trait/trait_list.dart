import 'package:chaldea/app/app.dart';
import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/models/models.dart';
import 'package:chaldea/packages/split_route/split_route.dart';
import 'package:chaldea/utils/utils.dart';
import 'package:chaldea/widgets/widgets.dart';

class TraitListPage extends StatefulWidget {
  final ValueChanged<int>? onSelected;
  final String? initSearchString;
  const TraitListPage({super.key, this.onSelected, this.initSearchString});

  @override
  _TraitListPageState createState() => _TraitListPageState();
}

class _TraitListPageState extends State<TraitListPage>
    with SearchableListState<int, TraitListPage> {
  @override
  void initState() {
    super.initState();
    searchEditingController =
        TextEditingController(text: widget.initSearchString);
  }

  @override
  Iterable<int> get wholeData {
    Set<int> ids = Trait.values.map((e) => e.id).toSet();
    ids.addAll(db.gameData.mappingData.trait.keys);
    ids.addAll(db.gameData.mappingData.eventTrait.keys);
    int? _searchInt = int.tryParse(searchEditingController.text);
    if (_searchInt != null) ids.add(_searchInt);
    ids.remove(Trait.unknown.id);
    return ids.toList();
  }

  Trait? getTrait(int id) => kTraitIdMapping[id];

  @override
  Widget build(BuildContext context) {
    filterShownList(compare: null);
    return scrollListener(
      useGrid: false,
      appBar: AppBar(
        leading: const MasterBackButton(),
        title: Text(S.current.info_trait),
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
  }

  @override
  Widget listItemBuilder(int id) {
    final trait = getTrait(id);
    String name = Transl.trait(id).l;
    String subtitle = 'ID $id';
    if (trait != null) {
      subtitle += '  ${trait.name}';
    }
    final hasTransl = id.toString() != name;
    return ListTile(
      dense: true,
      title: Text(hasTransl ? name : subtitle),
      subtitle: hasTransl ? Text(subtitle) : null,
      onTap: () {
        if (widget.onSelected != null) {
          widget.onSelected!(id);
        } else {
          router.popDetailAndPush(url: Routes.traitI(id));
        }
      },
    );
  }

  @override
  Widget gridItemBuilder(int id) =>
      throw UnimplementedError('GridView not designed');
}
