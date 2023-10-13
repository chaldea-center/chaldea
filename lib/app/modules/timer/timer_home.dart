import 'dart:async';

import 'package:chaldea/app/api/atlas.dart';
import 'package:chaldea/app/modules/common/builders.dart';
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

class TimerHomePage extends StatefulWidget {
  TimerHomePage({super.key});

  @override
  State<TimerHomePage> createState() => _TimerHomePageState();
}

class _TimerHomePageState extends State<TimerHomePage>
    with SingleTickerProviderStateMixin, RegionBasedState<GameTimerData, TimerHomePage> {
  late final _tabController = TabController(length: 5, vsync: this);

  GameTimerData get timerData => data!;

  @override
  void initState() {
    super.initState();
    region = db.curUser.region;
    doFetchData();
  }

  @override
  Future<GameTimerData?> fetchData(Region? r, {Duration? expireAfter}) {
    return AtlasApi.timerData(r ?? Region.jp, expireAfter: expireAfter);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        titleSpacing: NavigationToolbar.kMiddleSpacing,
        title: const Text("Timer"),
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
          controller: _tabController,
          tabs: [S.current.general_all, S.current.event, S.current.summon, S.current.master_mission, S.current.shop]
              .map((e) => Tab(text: e))
              .toList(),
        )),
      ),
      body: buildBody(context),
    );
  }

  @override
  Widget buildContent(BuildContext context, data) {
    final region = this.region!;
    return TabBarView(controller: _tabController, children: [
      _AllItemTab(region: region, timerData: timerData),
      TimerEventTab(region: region, events: timerData.events),
      TimerGachaTab(region: region, gachas: timerData.gachas),
      TimerMissionTab(region: region, mms: timerData.masterMissions),
      TimerShopTab(region: region, shops: timerData.shops),
    ]);
  }
}

class _AllItemTab extends StatelessWidget {
  final GameTimerData timerData;
  final Region region;
  const _AllItemTab({required this.timerData, required this.region});

  @override
  Widget build(BuildContext context) {
    List<TimerItem> entries = [
      ...TimerEventItem.group(timerData.events, region),
      ...timerData.gachas.map((e) => TimerGachaItem(e, region)),
      ...timerData.masterMissions.map((e) => TimerMissionItem(e, region)),
      ...TimerShopItem.group(timerData.shops, region),
    ];
    entries.sort2((e) => e.endedAt);
    final now = DateTime.now().timestamp;
    entries.sortByList((e) => [e.endedAt > now ? -1 : 1, (e.endedAt - now).abs()]);
    return ListView.separated(
      itemBuilder: (context, index) => entries[index].buildItem(context, expanded: false),
      separatorBuilder: (context, _) => const Divider(indent: 16, endIndent: 16),
      itemCount: entries.length,
    );
  }
}
