import 'package:chaldea/components/components.dart';
import 'package:chaldea/modules/item/item_detail_page.dart';
import 'package:chaldea/modules/shared/item_related_builder.dart';

class GameStatisticsPage extends StatefulWidget {
  @override
  _GameStatisticsPageState createState() => _GameStatisticsPageState();
}

class _GameStatisticsPageState extends State<GameStatisticsPage>
    with SingleTickerProviderStateMixin {
  TabController? _tabController;
  Map<String, int>? allItemCost;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(),
        title: Text(S.of(context).statistics_title),
        actions: [],
        bottom: TabBar(controller: _tabController, tabs: [
          Tab(text: S.of(context).item),
          Tab(text: S.of(context).servant)
        ]),
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

  bool includeCurItems = false;

  Widget _buildItemTab() {
    calculateItem();
    final shownItems =
        sumDict([allItemCost, if (includeCurItems) db.curUser.items]);
    shownItems.removeWhere((key, value) {
      int group = (db.gameData.items[key]?.id ?? 0) ~/ 100;
      return key != Item.qp && (!(group >= 10 && group < 40) || value <= 0);
    });
    return ListView(
      padding: EdgeInsets.symmetric(vertical: 12),
      children: [
        CheckboxListTile(
          value: includeCurItems,
          onChanged: (v) => setState(() {
            if (v != null) includeCurItems = v;
          }),
          controlAffinity: ListTileControlAffinity.leading,
          title: Text(S.of(context).statistics_include_checkbox),
        ),
        CustomTile(
          leading: db.getIconImage(Item.qp, height: kGridIconSize),
          title: Text(formatNumber(shownItems[Item.qp] ?? 0)),
          onTap: () => SplitRoute.push(
            context: context,
            builder: (context, _) => ItemDetailPage(itemKey: Item.qp),
          ),
        ),
        buildClassifiedItemList(
          context: context,
          data: shownItems..remove(Item.qp),
          divideRarity: false,
          crossCount: SplitRoute.isSplit(context) ? 7 : 7,
          onTap: (itemKey) => SplitRoute.push(
            context: context,
            builder: (context, _) => ItemDetailPage(itemKey: itemKey),
          ),
          compact: false,
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
      if(!db.gameData.servantsWithUser.containsKey(no)){
        print('No $no: ${db.gameData.servantsWithUser.length}');
      }
      final svt = db.gameData.servantsWithUser[no]!;
      sumDict(
        [allItemCost, svt.getAllCost(cur: emptyPlan, target: svtStat.curVal)],
        inPlace: true,
      );
    });
  }
}
