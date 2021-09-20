import 'package:chaldea/components/components.dart';
import 'package:chaldea/modules/item/item_detail_page.dart';
import 'package:chaldea/modules/shared/common_builders.dart';

import 'statistics_servant_tab.dart';

class GameStatisticsPage extends StatefulWidget {
  GameStatisticsPage({Key? key}) : super(key: key);

  @override
  _GameStatisticsPageState createState() => _GameStatisticsPageState();
}

class _GameStatisticsPageState extends State<GameStatisticsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return db.streamBuilder(
      (context) => Scaffold(
        appBar: AppBar(
          title: Text(S.current.statistics_title),
          actions: [
            CommonBuilder.buildSwitchPlanButton(
              context: context,
              onChange: (index) {
                db.curUser.curSvtPlanNo = index;
                db.itemStat.update(lapse: const Duration());
                setState(() {});
              },
            ),
            CommonBuilder.priorityIcon(context: context),
          ],
          bottom: TabBar(
            controller: _tabController,
            isScrollable: true,
            tabs: [
              Tab(
                  text: LocalizedText.of(
                      chs: '素材需求', jpn: 'アイテム需要', eng: 'Item Demands')),
              Tab(
                  text: LocalizedText.of(
                      chs: '已消耗素材', jpn: 'アイテム消費済', eng: 'Item Consumed')),
              Tab(text: S.of(context).servant)
            ],
          ),
        ),
        body: TabBarView(
          controller: _tabController,
          // pie chart relate
          physics:
              PlatformU.isAndroid ? const NeverScrollableScrollPhysics() : null,
          children: [
            KeepAliveBuilder(builder: (context) => StatItemDemandsTab()),
            KeepAliveBuilder(builder: (context) => StatItemConsumedTab()),
            KeepAliveBuilder(builder: (context) => StatisticServantTab())
          ],
        ),
      ),
    );
  }
}

class StatItemConsumedTab extends StatefulWidget {
  StatItemConsumedTab({Key? key}) : super(key: key);

  @override
  _StatItemConsumedTabState createState() => _StatItemConsumedTabState();
}

class _StatItemConsumedTabState extends State<StatItemConsumedTab> {
  late ScrollController _scrollController;
  Map<String, int> shownItems = {};
  bool includeOwnedItems = false;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
  }

  @override
  void dispose() {
    super.dispose();
    _scrollController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    calculateItem();
    return ListView(
      controller: _scrollController,
      padding: const EdgeInsets.only(bottom: 8),
      children: [
        Wrap(
          spacing: 6,
          runSpacing: 6,
          alignment: WrapAlignment.center,
          children: [
            CheckboxWithLabel(
              value: includeOwnedItems,
              label: Text(LocalizedText.of(
                  chs: '包含库存', jpn: '在庫を含める', eng: 'Include Owned')),
              onChanged: (v) {
                setState(() {
                  if (v != null) includeOwnedItems = v;
                });
              },
            ),
          ],
        ),
        CustomTile(
          color: Theme.of(context).cardColor,
          leading: db.getIconImage(Items.qp, height: 56),
          title: Text(formatNumber(shownItems[Items.qp] ?? 0)),
          onTap: () =>
              SplitRoute.push(context, ItemDetailPage(itemKey: Items.qp)),
        ),
        buildClassifiedItemList(
          context: context,
          data: shownItems..remove(Items.qp),
          divideRarity: true,
          divideClassItem: false,
          compactNum: false,
          minCrossCount: 7,
        )
      ],
    );
  }

  void calculateItem() {
    shownItems.clear();
    final emptyPlan = ServantStatus()..curVal.favorite = true;
    db.curUser.servants.forEach((no, svtStat) {
      if (!svtStat.favorite) return;
      if (!db.gameData.servantsWithUser.containsKey(no)) {
        print('No $no: ${db.gameData.servantsWithUser.length}');
        return;
      }
      final svt = db.gameData.servantsWithUser[no]!;
      sumDict(
        [shownItems, svt.getAllCost(status: emptyPlan, target: svtStat.curVal)],
        inPlace: true,
      );
    });
    sumDict([shownItems, if (includeOwnedItems) db.curUser.items],
        inPlace: true);
    shownItems.removeWhere((key, value) {
      int group = (db.gameData.items[key]?.id ?? 0) ~/ 100;
      return key != Items.qp && (!(group >= 10 && group < 40) || value <= 0);
    });
  }
}

class StatItemDemandsTab extends StatefulWidget {
  StatItemDemandsTab({Key? key}) : super(key: key);

  @override
  _StatItemDemandsTabState createState() => _StatItemDemandsTabState();
}

class _StatItemDemandsTabState extends State<StatItemDemandsTab> {
  late ScrollController _scrollController;
  Map<String, int> shownItems = {};
  bool subtractOwnedItems = false;
  bool subtractEventItems = false;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
  }

  @override
  void dispose() {
    super.dispose();
    _scrollController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    calculateItem();
    return ListView(
      controller: _scrollController,
      padding: const EdgeInsets.only(bottom: 8),
      children: [
        Wrap(
          spacing: 6,
          runSpacing: 6,
          alignment: WrapAlignment.center,
          children: [
            CheckboxWithLabel(
              value: subtractOwnedItems,
              label: Text(LocalizedText.of(
                  chs: '减去库存', jpn: '在庫を差し引く', eng: 'Subtract Owned')),
              onChanged: (v) {
                setState(() {
                  subtractOwnedItems = v ?? subtractOwnedItems;
                });
              },
            ),
            CheckboxWithLabel(
              value: subtractEventItems,
              label: Text(LocalizedText.of(
                  chs: '减去活动所得', jpn: '活動収入を差し引く', eng: 'Subtract Event')),
              onChanged: (v) {
                setState(() {
                  subtractEventItems = v ?? subtractEventItems;
                });
              },
            ),
          ],
        ),
        CustomTile(
          color: Theme.of(context).cardColor,
          leading: db.getIconImage(Items.qp, height: 56),
          title: Text(formatNumber(shownItems[Items.qp] ?? 0)),
          onTap: () =>
              SplitRoute.push(context, ItemDetailPage(itemKey: Items.qp)),
        ),
        buildClassifiedItemList(
          context: context,
          data: shownItems..remove(Items.qp),
          divideRarity: true,
          divideClassItem: false,
          compactNum: false,
          minCrossCount: 7,
        )
      ],
    );
  }

  void calculateItem() {
    shownItems = Map.of(db.itemStat.svtItems);
    sumDict([
      shownItems,
      if (subtractOwnedItems) multiplyDict(db.curUser.items, -1),
      if (subtractEventItems) multiplyDict(db.itemStat.eventItems, -1),
    ], inPlace: true);
    shownItems.removeWhere((key, value) {
      int group = (db.gameData.items[key]?.id ?? 0) ~/ 100;
      return key != Items.qp && (!(group >= 10 && group < 40) || value <= 0);
    });
  }
}
