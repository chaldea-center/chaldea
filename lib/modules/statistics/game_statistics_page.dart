import 'package:chaldea/components/components.dart';
import 'package:chaldea/modules/item/item_detail_page.dart';
import 'package:chaldea/modules/shared/item_related_builder.dart';

class GameStatisticsPage extends StatefulWidget {
  @override
  _GameStatisticsPageState createState() => _GameStatisticsPageState();
}

class _GameStatisticsPageState extends State<GameStatisticsPage>
    with SingleTickerProviderStateMixin {
  TabController _tabController;
  Map<String, int> allItemCost;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(),
        title: Text('统计'),
        actions: [],
        bottom: TabBar(
            controller: _tabController,
            tabs: [Tab(text: '素材'), Tab(text: '从者')]),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          KeepAliveBuilder(builder: (context) => _buildItemTab()),
          KeepAliveBuilder(builder: (context) => _buildSvtTab())
        ],
      ),
    );
  }

  Widget _buildItemTab() {
    calculateItem();
    final shownItems = Map<String, int>.from(allItemCost)
      ..removeWhere((key, value) {
        int group = (db.gameData.items[key]?.id ?? 0) ~/ 100;
        return !(group >= 10 && group < 40) || value <= 0;
      });
    return ListView(
      padding: EdgeInsets.symmetric(vertical: 12),
      children: [
        ListTile(
          leading: Image(image: db.getIconImage(Item.qp)),
          title: Text(formatNumber(allItemCost[Item.qp] ?? 0)),
          onTap: () => SplitRoute.push(
              context: context,
              builder: (context, _) => ItemDetailPage(Item.qp)),
        ),
        buildClassifiedItemList(
          context: context,
          data: shownItems,
          divideRarity: false,
          crossCount: SplitRoute.isSplit(context) ? 7 : 7,
          onTap: (itemKey) => SplitRoute.push(
              context: context,
              builder: (context, _) => ItemDetailPage(itemKey)),
        )
      ],
    );
  }

  Widget _buildSvtTab() {
    return Center(
      child: Text('To do'),
    );
  }

  void calculateItem() {
    if (allItemCost != null) return;
    allItemCost = {};
    final emptyPlan = ServantPlan(favorite: true);
    db.curUser.servants.forEach((no, svtStat) {
      if (svtStat.curVal.favorite != true) return;
      final svt = db.gameData.servants[no];
      sumDict(
          [allItemCost, svt.getAllCost(cur: emptyPlan, target: svtStat.curVal)],
          inPlace: true);
    });
  }
}
