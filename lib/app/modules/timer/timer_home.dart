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
    if (!db.gameData.isValid) return null;
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
    Widget _toTab(
      List<TimerItem> groups, {
      bool? expanded,
      List<Widget> Function(BuildContext context)? topWidgetsBuilder,
    }) {
      return TimerTabBase(
        groups: groups,
        filterData: filterData,
        region: region,
        expanded: expanded,
        topWidgetsBuilder: topWidgetsBuilder,
      );
    }

    final now = DateTime.now().timestamp;
    List<int> pickupSvtIds = [
      for (final gacha in timerData.gachas.values)
        if (gacha.openedAt <= now &&
            gacha.closedAt > now &&
            gacha.type == GachaType.payGacha.value &&
            gacha.closedAt - gacha.openedAt < 360 * kSecsPerDay)
          ...gacha.featuredSvtIds,
    ];
    pickupSvtIds = pickupSvtIds.toSet().toList();
    pickupSvtIds.sort((a, b) => SvtFilterData.compareId(a, b));

    final view = TabBarView(
      controller: _tabController,
      children: [
        _toTab(
          [
            ...TimerEventItem.group(timerData.events.values, region),
            ...TimerGachaItem.group(timerData.gachas.values, region),
            ...TimerMissionItem.group(timerData.masterMissions.values, region),
            ...TimerShopItem.group(timerData.shops.values, region),
            ...TimerQuestItem.group(timerData.quests.values, region),
          ],
          expanded: false,
          topWidgetsBuilder: (context) => [
            ListTile(
              dense: true,
              title: Text.rich(
                TextSpan(
                  text: '${S.current.update_time}: ',
                  children: [
                    TextSpan(
                      text: [
                        timerData.timestamp,
                        if (timerData.updatedAt - timerData.timestamp > 30 * 60) timerData.updatedAt,
                      ].map((e) => e.sec2date().toCustomString(second: false)).join(' / '),
                    ),
                  ],
                ),
                textAlign: TextAlign.center,
              ),
            ),
            _pickupListBuilder(context, pickupSvtIds),
          ],
        ),
        _toTab(TimerEventItem.group(timerData.events.values, region)),
        _toTab(
          TimerGachaItem.group(timerData.gachas.values, region),
          topWidgetsBuilder: pickupSvtIds.isEmpty ? null : (context) => [_pickupListBuilder(context, pickupSvtIds)],
        ),
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

  Widget _pickupListBuilder(BuildContext context, List<int> pickupSvtIds) {
    if (pickupSvtIds.isEmpty) {
      return const SizedBox.shrink();
    }
    return SizedBox(
      height: 48,
      child: ListView.builder(
        padding: .symmetric(horizontal: 8, vertical: 4),
        scrollDirection: .horizontal,
        itemCount: pickupSvtIds.length,
        itemBuilder: (context, index) {
          final svtId = pickupSvtIds[index];
          final svt = db.gameData.servantsById[svtId];
          final status = svt?.status;
          return svt?.iconBuilder(
                context: context,
                text: status != null && status.favorite ? ' NP${status.cur.npLv} ' : null,
                height: 48 - 4 * 2,
                option: ImageWithTextOption(alignment: .bottomLeft, textAlign: .left, fontSize: 8),
              ) ??
              Text('No.$svtId');
        },
      ),
    );
  }
}
