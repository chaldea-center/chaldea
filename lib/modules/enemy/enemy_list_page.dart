import 'package:auto_size_text/auto_size_text.dart';
import 'package:chaldea/components/components.dart';

import 'enemy_detail_page.dart';

class EnemyListPage extends StatefulWidget {
  final void Function(EnemyDetail)? onSelected;

  EnemyListPage({Key? key, this.onSelected}) : super(key: key);

  @override
  State<StatefulWidget> createState() => EnemyListPageState();
}

class EnemyListPageState
    extends SearchableListState<EnemyDetail, EnemyListPage> {
  bool useGrid = false;

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
      useGrid: useGrid,
      appBar: AppBar(
        leading: MasterBackButton(),
        title: Text('敌人一览'),
        titleSpacing: 0,
        bottom: showSearchBar ? searchBar : null,
        actions: <Widget>[
          IconButton(
            onPressed: () {
              setState(() {
                useGrid = !useGrid;
              });
            },
            icon: Icon(useGrid ? Icons.grid_on : Icons.view_list),
            tooltip: 'List/Grid',
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
      trailing: Icon(Icons.keyboard_arrow_right),
      selected: SplitRoute.isSplit(context) && selected == enemy,
      onTap: () => _onTapCard(enemy),
    );
  }

  @override
  Widget gridItemBuilder(EnemyDetail enemy) {
    return Padding(
      padding: EdgeInsets.all(3),
      child: GestureDetector(
        child: db.getIconImage(enemy.icon),
        onTap: () => _onTapCard(enemy),
      ),
    );
  }

  @override
  String getSummary(EnemyDetail enemy) {
    List<String> searchStrings = [
      ...Utils.getSearchAlphabetsForList(enemy.ids),
      ...Utils.getSearchAlphabetsForList(enemy.names),
      ...Utils.getSearchAlphabets(enemy.category),
    ];
    return searchStrings.toSet().join('\t');
  }

  @override
  bool filter(EnemyDetail enemy) {
    return true;
  }
}
