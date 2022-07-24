import 'package:flutter/material.dart';

import 'package:chaldea/app/app.dart';
import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/models/models.dart';
import 'package:chaldea/utils/utils.dart';
import 'package:chaldea/widgets/widgets.dart';

class TraitListPage extends StatefulWidget {
  const TraitListPage({Key? key}) : super(key: key);

  @override
  _TraitListPageState createState() => _TraitListPageState();
}

class _TraitListPageState extends State<TraitListPage>
    with SearchableListState<int, TraitListPage> {
  @override
  Iterable<int> get wholeData {
    Set<int> ids = kTraitIdMappingReverse.values.toSet();
    int? _searchInt = int.tryParse(searchEditingController.text);
    if (_searchInt != null) ids.add(_searchInt);
    return ids.toList();
  }

  Trait? getTrait(int id) => kTraitIdMapping[id];

  @override
  Widget build(BuildContext context) {
    filterShownList(compare: null);
    return scrollListener(
      useGrid: false,
      appBar: AppBar(
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
        router.push(url: Routes.traitI(id));
      },
    );
  }

  @override
  Widget gridItemBuilder(int id) =>
      throw UnimplementedError('GridView not designed');
}
