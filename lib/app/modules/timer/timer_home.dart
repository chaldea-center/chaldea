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
import 'quest.dart';
import 'shop.dart';
import 'time.dart';

class TimerHomePage extends StatefulWidget {
  TimerHomePage({super.key});

  @override
  State<TimerHomePage> createState() => _TimerHomePageState();
}

class _TimerHomePageState extends State<TimerHomePage>
    with SingleTickerProviderStateMixin, RegionBasedState<GameTimerData, TimerHomePage> {
  late final _tabController = TabController(length: 7, vsync: this);
  final filterData = TimerFilterData();

  GameTimerData get timerData => data!;

  bool _initiated = false;

  @override
  void initState() {
    super.initState();
    region = db.curUser.region;
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging && mounted) setState(() {});
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
  Future<GameTimerData?> fetchData(Region? r, {Duration? expireAfter}) async {
    final data = await AtlasApi.timerData(r ?? Region.jp, expireAfter: expireAfter);
    final events = data?.events.values.toList() ?? [];
    for (final event in events) {
      event.calcItems(db.gameData);
    }
    return data;
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
              ),
            ],
          ),
        ],
        bottom: FixedHeight.tabBar(
          TabBar(
            isScrollable: true,
            tabAlignment: TabAlignment.center,
            controller: _tabController,
            tabs: [
              S.current.general_all,
              S.current.event,
              S.current.summon_banner,
              S.current.master_mission,
              S.current.shop,
              S.current.quest,
              "Time",
            ].map((e) => Tab(text: e)).toList(),
          ),
        ),
      ),
      body: buildBody(context),
    );
  }

  @override
  Widget buildContent(BuildContext context, GameTimerData timerData) {
    final region = this.region!;
    Widget _toTab(List<TimerItem> groups) {
      return TimerTabBase(groups: groups, filterData: filterData, region: region);
    }

    final view = TabBarView(
      controller: _tabController,
      children: [
        _AllItemTab(region: region, timerData: timerData, filterData: filterData),
        _toTab(TimerEventItem.group(timerData.events.values, region)),
        _toTab(TimerGachaItem.group(timerData.gachas.values, region)),
        _toTab(TimerMissionItem.group(timerData.masterMissions.values, region)),
        _toTab(TimerShopItem.group(timerData.shops.values, region)),
        _toTab(TimerQuestItem.group(timerData.quests.values, region)),
        RegionTimeTab(region: region),
      ],
    );
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
    return OverflowBar(
      alignment: MainAxisAlignment.center,
      spacing: 4,
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
      ...TimerEventItem.group(timerData.events.values, region),
      ...TimerGachaItem.group(timerData.gachas.values, region),
      ...TimerMissionItem.group(timerData.masterMissions.values, region),
      ...TimerShopItem.group(timerData.shops.values, region),
      ...TimerQuestItem.group(timerData.quests.values, region),
    ];
    items = filterData.getSorted(items);
    return ListView.separated(
      itemBuilder: (context, index) {
        if (index == 0) {
          String header = '${S.current.update_time}: ';
          header += [
            timerData.timestamp,
            if (timerData.updatedAt - timerData.timestamp > 30 * 60) timerData.updatedAt,
          ].map((e) => e.sec2date().toCustomString(second: false)).join(' / ');
          return ListTile(dense: true, title: Text(header, textAlign: TextAlign.center));
        }
        return items[index - 1].buildItem(context, expanded: false);
      },
      separatorBuilder: (context, _) => const Divider(indent: 16, endIndent: 16),
      itemCount: items.length + 1,
    );
  }
}
