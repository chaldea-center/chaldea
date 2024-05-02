import 'package:chaldea/app/modules/common/builders.dart';
import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/models/models.dart';
import 'package:chaldea/widgets/widgets.dart';
import 'item_stat.dart';
import 'servant_details.dart';
import 'svt_class_stat.dart';

class GameStatisticsPage extends StatefulWidget {
  GameStatisticsPage({super.key});

  @override
  _GameStatisticsPageState createState() => _GameStatisticsPageState();
}

class _GameStatisticsPageState extends State<GameStatisticsPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
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
    return db.onUserData(
      (context, _) => Scaffold(
        appBar: AppBar(
          title: Text(S.current.statistics_title),
          actions: [
            SharedBuilder.buildSwitchPlanButton(
              context: context,
              onChange: (index) {
                db.curUser.curSvtPlanNo = index;
                db.itemCenter.calculate();
                if (mounted) setState(() {});
              },
            ),
            SharedBuilder.priorityIcon(context: context),
          ],
          bottom: FixedHeight.tabBar(TabBar(
            controller: _tabController,
            isScrollable: true,
            tabAlignment: TabAlignment.center,
            tabs: [
              Tab(text: S.current.demands),
              Tab(text: S.current.consumed),
              Tab(text: S.current.details),
              Tab(text: S.current.svt_class_dist),
            ],
          )),
        ),
        body: TabBarView(
          controller: _tabController,
          children: [
            KeepAliveBuilder(builder: (context) => ItemStatTab(demandMode: true)),
            KeepAliveBuilder(builder: (context) => ItemStatTab(demandMode: false)),
            ServantDemandDetailStat(),
            KeepAliveBuilder(builder: (context) => StatisticServantTab())
          ],
        ),
      ),
    );
  }
}
