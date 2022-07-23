import 'package:flutter/material.dart';

import 'package:chaldea/models/models.dart';
import 'package:chaldea/utils/utils.dart';
import 'package:chaldea/widgets/widgets.dart';

class BuffListPage extends StatefulWidget {
  const BuffListPage({Key? key}) : super(key: key);

  @override
  _BuffListPageState createState() => _BuffListPageState();
}

class _BuffListPageState extends State<BuffListPage>
    with SearchableListState<Buff, BuffListPage> {
  @override
  Iterable<Buff> get wholeData => db.gameData.baseBuffs.values;

  @override
  Widget build(BuildContext context) {
    filterShownList(compare: (a, b) => a.id - b.id);
    return scrollListener(
      useGrid: false,
      appBar: AppBar(
        title: const Text("Buffs"),
        bottom: searchBar,
        actions: const [
          //
        ],
      ),
    );
  }

  @override
  bool filter(Buff buff) => true;

  @override
  Iterable<String?> getSummary(Buff buff) sync* {
    yield buff.id.toString();
    yield buff.type.toString();
    yield* SearchUtil.getAllKeys(Transl.buffType(buff.type));
    yield* SearchUtil.getAllKeys(buff.lName);
    yield* SearchUtil.getAllKeys(buff.lDetail);
  }

  @override
  Widget listItemBuilder(Buff buff) {
    return ListTile(
      leading: buff.icon == null
          ? const SizedBox()
          : db.getIconImage(buff.icon, height: 24),
      horizontalTitleGap: 8,
      title: Text(buff.lName.l),
      subtitle:
          Text('${buff.id} ${buff.type.name} ${Transl.buffType(buff.type).l}'),
      onTap: () {
        buff.routeTo();
      },
    );
  }

  @override
  Widget gridItemBuilder(Buff buff) =>
      throw UnimplementedError('GridView not designed');
}
