import 'dart:async';

import 'package:chaldea/app/api/atlas.dart';
import 'package:chaldea/app/modules/common/builders.dart';
import 'package:chaldea/app/modules/common/filter_group.dart';
import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/models/models.dart';
import 'package:chaldea/utils/utils.dart';
import 'package:chaldea/widgets/region_based.dart';
import 'package:chaldea/widgets/widgets.dart';
import 'base.dart';
import 'event.dart';
import 'gacha.dart';
import 'mission.dart';
import 'shop.dart';
import 'time.dart';

class TimerHomePage extends StatefulWidget {
  TimerHomePage({super.key});

  @override
  State<TimerHomePage> createState() => _TimerHomePageState();
}

class _TimerHomePageState extends State<TimerHomePage>
    with SingleTickerProviderStateMixin, RegionBasedState<GameTimerData, TimerHomePage> {
  late final _tabController = TabController(length: 6, vsync: this);
  final filterData = TimerFilterData();

  GameTimerData get timerData => data!;

  bool _initiated = false;

  @override
  void initState() {
    super.initState();
    region = db.curUser.region;
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) setState(() {});
    });
  }

  /// [IndexedStack] wraps children with [Visibility.maintain]
  /// So fetch data when become visible rather in [initState]
  void init() {
    if (_initiated || !mounted || !Visibility.of(context)) return;
    _initiated = true;
    doFetchData();
  }

  @override
  Future<GameTimerData?> fetchData(Region? r, {Duration? expireAfter}) {
    return AtlasApi.timerData(r ?? Region.jp, expireAfter: expireAfter);
  }

  @override
  Widget build(BuildContext context) {
    init();
    return Scaffold(
      appBar: AppBar(
        titleSpacing: NavigationToolbar.kMiddleSpacing,
        title: const Text("Timer"),
        centerTitle: true,
        actions: [
          SharedBuilder.appBarRegionDropdown(
            context: context,
            region: region ?? Region.jp,
            onChanged: (v) {
              setState(() {
                if (v != null) {
                  region = v;
                  doFetchData();
                }
              });
            },
          ),
          PopupMenuButton(
            itemBuilder: (context) => [
              PopupMenuItem(
                child: Text(S.current.refresh),
                onTap: () {
                  doFetchData(expireAfter: Duration.zero);
                },
              )
            ],
          )
        ],
        bottom: FixedHeight.tabBar(TabBar(
          isScrollable: true,
          tabAlignment: TabAlignment.center,
          controller: _tabController,
          tabs: [
            S.current.general_all,
            S.current.event,
            S.current.summon_banner,
            S.current.master_mission,
            S.current.shop,
            "Time",
          ].map((e) => Tab(text: e)).toList(),
        )),
      ),
      body: buildBody(context),
    );
  }

  @override
  Widget buildContent(BuildContext context, GameTimerData data) {
    final region = this.region!;
    final view = TabBarView(controller: _tabController, children: [
      _AllItemTab(region: region, timerData: timerData, filterData: filterData),
      TimerEventTab(region: region, events: timerData.events, filterData: filterData),
      TimerGachaTab(region: region, gachas: timerData.gachas, filterData: filterData),
      TimerMissionTab(region: region, mms: timerData.masterMissions, filterData: filterData),
      TimerShopTab(region: region, shops: timerData.shownShops, filterData: filterData),
      RegionTimeTab(region: region),
    ]);
    return Column(
      children: [
        Expanded(child: view),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 800),
          child: _tabController.index == _tabController.length - 1 ? const SizedBox.shrink() : buildButtonBar(),
        ),
      ],
    );
  }

  Widget buildButtonBar() {
    final buttonStyle = ButtonStyle(
      minimumSize: ButtonStyleButton.allOrNull<Size>(const Size(2, 36)),
      padding: ButtonStyleButton.allOrNull<EdgeInsetsGeometry>(const EdgeInsets.symmetric(horizontal: 4)),
    );
    return ButtonBar(
      mainAxisSize: MainAxisSize.min,
      alignment: MainAxisAlignment.center,
      children: [
        FilterGroup<TimerSortType>(
          padding: EdgeInsets.zero,
          combined: true,
          options: TimerSortType.values,
          values: filterData.sortType,
          onFilterChanged: (v, _) {
            setState(() {});
          },
          optionBuilder: (value) => Text(switch (value) {
            TimerSortType.auto => "${S.current.sort_order}:Auto",
            TimerSortType.startTime => S.current.time_start,
            TimerSortType.endTime => S.current.time_end,
          }),
          buttonStyle: buttonStyle,
        ),
        FilterGroup<OngoingStatus>(
          padding: EdgeInsets.zero,
          combined: true,
          options: OngoingStatus.values,
          values: filterData.status,
          onFilterChanged: (v, _) {
            setState(() {});
          },
          optionBuilder: (value) => Text(switch (value) {
            OngoingStatus.ended => S.current.ended,
            OngoingStatus.ongoing => S.current.ongoing,
            OngoingStatus.notStarted => S.current.not_started,
          }),
          buttonStyle: buttonStyle,
        ),
      ],
    );
  }
}

class _AllItemTab extends StatelessWidget {
  final GameTimerData timerData;
  final Region region;
  final TimerFilterData filterData;
  const _AllItemTab({required this.timerData, required this.region, required this.filterData});

  @override
  Widget build(BuildContext context) {
    List<TimerItem> items = [
      ...TimerEventItem.group(timerData.events, region),
      ...timerData.gachas.map((e) => TimerGachaItem(e, region)),
      ...timerData.masterMissions.map((e) => TimerMissionItem(e, region)),
      ...TimerShopItem.group(timerData.shownShops, region),
    ];
    items = filterData.getSorted(items);
    return ListView.separated(
      itemBuilder: (context, index) {
        if (index == 0) {
          return ListTile(
            dense: true,
            title: Text(
              '${S.current.update_time}: ${timerData.updatedAt.sec2date().toCustomString(second: false)}',
              textAlign: TextAlign.center,
            ),
          );
        }
        return items[index - 1].buildItem(context, expanded: false);
      },
      separatorBuilder: (context, _) => const Divider(indent: 16, endIndent: 16),
      itemCount: items.length + 1,
    );
  }
}
