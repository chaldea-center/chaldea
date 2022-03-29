import 'package:chaldea/app/app.dart';
import 'package:chaldea/app/modules/common/builders.dart';
import 'package:chaldea/components/localized/localized_base.dart';
import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/models/models.dart';
import 'package:chaldea/packages/packages.dart';
import 'package:chaldea/utils/utils.dart';
import 'package:chaldea/widgets/widgets.dart';
import 'package:flutter/material.dart';

import '../common/filter_group.dart';
import '../item/item.dart';
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
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return db2.onUserData(
      (context, _) => Scaffold(
        appBar: AppBar(
          title: Text(S.current.statistics_title),
          actions: [
            SharedBuilder.buildSwitchPlanButton(
              context: context,
              onChange: (index) {
                db2.curUser.curSvtPlanNo = index;
                db2.itemCenter.updateSvts(all: true);
                setState(() {});
              },
            ),
            SharedBuilder.priorityIcon(context: context),
          ],
          bottom: TabBar(
            controller: _tabController,
            isScrollable: true,
            tabs: [
              Tab(text: S.current.demands),
              Tab(text: S.current.consumed),
              Tab(text: S.current.servant)
            ],
          ),
        ),
        body: TabBarView(
          controller: _tabController,
          // pie chart relate
          physics: PlatformU.isMobile && _tabController.index == 2
              ? const NeverScrollableScrollPhysics()
              : null,
          children: [
            KeepAliveBuilder(
                builder: (context) => ItemStatTab(demandMode: true)),
            KeepAliveBuilder(
                builder: (context) => ItemStatTab(demandMode: false)),
            KeepAliveBuilder(builder: (context) => StatisticServantTab())
          ],
        ),
      ),
    );
  }
}

class ItemStatTab extends StatefulWidget {
  final bool demandMode;
  ItemStatTab({Key? key, required this.demandMode}) : super(key: key);

  @override
  _ItemStatTabState createState() => _ItemStatTabState();
}

class _ItemStatTabState extends State<ItemStatTab> {
  late ScrollController _scrollController;
  Map<int, int> shownItems = {};
  FilterGroupData<int> svtParts = FilterGroupData();

  bool get demandMode => widget.demandMode;
  // consume
  bool includeOwnedItems = false;
  // demand
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
    if (demandMode) {
      calculateDemand();
    } else {
      calculateConsumed();
    }
    return Column(
      children: [
        Expanded(
          child: ListView(
            controller: _scrollController,
            children: [
              CustomTile(
                color: Theme.of(context).cardColor,
                leading: db2.getIconImage(Items.qp.borderedIcon, height: 56),
                title: Text((shownItems[Items.qpId] ?? 0)
                    .format(compact: false, groupSeparator: ',')),
                onTap: () => Items.qp.routeTo(),
              ),
              SharedBuilder.groupItems(
                context: context,
                items: Map.of(shownItems)..remove(Items.qpId),
                onTap: (itemId) {
                  router.push(
                    url: Routes.itemI(itemId),
                    child: ItemDetailPage(
                        itemId: itemId, initialTabIndex: demandMode ? 0 : 1),
                  );
                },
              )
            ],
          ),
        ),
        buttonBar,
      ],
    );
  }

  Widget get buttonBar {
    return ButtonBar(
      alignment: MainAxisAlignment.center,
      children: [
        Wrap(
          spacing: 6,
          runSpacing: 6,
          alignment: WrapAlignment.center,
          children: [
            FilterGroup<int>(
              options: List.generate(5, (index) => index),
              values: svtParts,
              combined: true,
              // shrinkWrap: true,
              optionBuilder: (index) {
                return Text([
                  S.current.ascension_short,
                  S.current.active_skill,
                  S.current.append_skill_short,
                  S.current.costume,
                  'Special',
                ][index]);
              },
              onFilterChanged: (v) {
                setState(() {});
              },
            ),
            if (!demandMode)
              CheckboxWithLabel(
                value: includeOwnedItems,
                label: Text(LocalizedText.of(
                    chs: '包含库存',
                    jpn: '在庫を含める',
                    eng: 'Include Owned',
                    kor: '재고 포함')),
                onChanged: (v) {
                  setState(() {
                    if (v != null) includeOwnedItems = v;
                  });
                },
              ),
            if (demandMode) ...[
              CheckboxWithLabel(
                value: subtractOwnedItems,
                label: Text(LocalizedText.of(
                    chs: '减去库存',
                    jpn: '在庫を差し引く',
                    eng: 'Subtract Owned',
                    kor: '재고 제외')),
                onChanged: (v) {
                  setState(() {
                    subtractOwnedItems = v ?? subtractOwnedItems;
                  });
                },
              ),
              CheckboxWithLabel(
                value: subtractEventItems,
                label: Text(LocalizedText.of(
                    chs: '减去活动所得',
                    jpn: '活動収入を差し引く',
                    eng: 'Subtract Event',
                    kor: '이벤트 제외')),
                onChanged: (v) {
                  setState(() {
                    subtractEventItems = v ?? subtractEventItems;
                  });
                },
              ),
            ]
          ],
        ),
      ],
    );
  }

  void calculateConsumed() {
    shownItems.clear();
    final emptyPlan = SvtStatus();
    emptyPlan.cur.favorite = true;
    db2.curUser.servants.forEach((no, svtStat) {
      if (!svtStat.favorite) return;
      if (!db2.gameData.servants.containsKey(no)) {
        print('No $no: ${db2.gameData.servants.length}');
        return;
      }
      final svt = db2.gameData.servants[no]!;
      final detail = db2.itemCenter.calcOneSvt(svt, emptyPlan.cur, svtStat.cur);
      Maths.sumDict(
        [
          shownItems,
          if (svtParts.options.isEmpty) detail.all,
          if (svtParts.options.isNotEmpty)
            ...List.generate(
              detail.parts.length,
              (index) => svtParts.options.contains(index)
                  ? detail.parts[index]
                  : <int, int>{},
            ),
        ],
        inPlace: true,
      );
    });
    Maths.sumDict([shownItems, if (includeOwnedItems) db2.curUser.items],
        inPlace: true);
    shownItems.removeWhere((key, value) {
      return value <= 0;
    });
  }

  void calculateDemand() {
    shownItems.clear();
    if (svtParts.options.isEmpty) {
      shownItems = Map.of(db2.itemCenter.statSvtDemands);
    } else {
      db2.curUser.servants.forEach((no, svtStat) {
        if (!svtStat.favorite) return;
        final svt = db2.gameData.servants[no];
        if (svt == null) {
          print('No $no: ${db2.gameData.servants.length}');
          return;
        }
        final detail = db2.itemCenter
            .calcOneSvt(svt, svtStat.cur, db2.curUser.svtPlanOf(no));
        Maths.sumDict(
          [
            shownItems,
            ...List.generate(
              detail.parts.length,
              (index) => svtParts.options.contains(index)
                  ? detail.parts[index]
                  : <int, int>{},
            ),
          ],
          inPlace: true,
        );
      });
    }
    Maths.sumDict([
      shownItems,
      if (subtractOwnedItems) Maths.multiplyDict(db2.curUser.items, -1),
      if (subtractEventItems) Maths.multiplyDict(db2.itemCenter.statObtain, -1),
    ], inPlace: true);
    shownItems.removeWhere((key, value) {
      return value <= 0;
    });
  }
}
