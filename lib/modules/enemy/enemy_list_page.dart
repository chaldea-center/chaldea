import 'package:auto_size_text/auto_size_text.dart';
import 'package:chaldea/components/components.dart';
import 'package:chaldea/modules/shared/filter_page.dart';

import 'enemy_detail_page.dart';
import 'filter_page.dart';

class EnemyListPage extends StatefulWidget {
  final void Function(EnemyDetail)? onSelected;

  EnemyListPage({Key? key, this.onSelected}) : super(key: key);

  @override
  State<StatefulWidget> createState() => EnemyListPageState();
}

class EnemyListPageState extends State<EnemyListPage>
    with SearchableListState<EnemyDetail, EnemyListPage> {
  EnemyFilterData filterData = EnemyFilterData();

  @override
  List<EnemyDetail> wholeData = [];

  @override
  void initState() {
    super.initState();
    db.gameData.categorizedEnemies.values.forEach((e) {
      wholeData.addAll(e);
    });
  }

  void _onTapCard(EnemyDetail enemy) {
    if (widget.onSelected != null) {
      widget.onSelected!(enemy);
    } else {
      SplitRoute.push(
        context,
        EnemyDetailPage(enemy: enemy),
        popDetail: true,
      );
      selected = enemy;
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    filterShownList();
    return scrollListener(
      useGrid: filterData.useGrid,
      appBar: AppBar(
        leading: const MasterBackButton(),
        title: Text(S.current.enemy_list),
        titleSpacing: 0,
        bottom: showSearchBar ? searchBar : null,
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.filter_alt),
            tooltip: S.current.filter,
            onPressed: () => FilterPage.show(
              context: context,
              builder: (context) => EnemyFilterPage(
                filterData: filterData,
                onChanged: (_) {
                  if (mounted) setState(() {});
                },
              ),
            ),
          ),
          searchIcon,
        ],
      ),
    );
  }

  @override
  Widget listItemBuilder(EnemyDetail enemy) {
    return CustomTile(
      leading: db.getIconImage(enemy.icon, width: 48, height: 48),
      title: AutoSizeText(enemy.lIds.join('\n'),
          maxFontSize: 16, overflow: TextOverflow.fade),
      trailing: const Icon(Icons.keyboard_arrow_right),
      selected: SplitRoute.isSplit(context) && selected == enemy,
      onTap: () => _onTapCard(enemy),
    );
  }

  @override
  Widget gridItemBuilder(EnemyDetail enemy) {
    return Padding(
      padding: const EdgeInsets.all(3),
      child: GestureDetector(
        child: db.getIconImage(enemy.icon),
        onTap: () => _onTapCard(enemy),
      ),
    );
  }

  @override
  String getSummary(EnemyDetail enemy) {
    List<String> searchStrings = [
      ...Utils.getSearchAlphabetsForList({
        ...enemy.ids,
        ...enemy.lIds,
        ...enemy.names,
        ...enemy.lNames,
        enemy.category,
        Localized.enemy.of(enemy.category),
      }.toList()),
    ];
    return searchStrings.toSet().join('\t');
  }

  @override
  bool filter(EnemyDetail enemy) {
    if (!filterData.attribute.singleValueFilter(enemy.attribute)) {
      return false;
    }
    if (!filterData.traits.listValueFilter(enemy.traits)) {
      return false;
    }
    return true;
  }
}
