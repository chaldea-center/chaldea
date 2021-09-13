import 'package:chaldea/components/components.dart';

import 'extra_mission_tab.dart';
import 'setting_tab.dart';
import 'table_tab.dart';

SaintQuartzPlan get _plan => db.curUser.saintQuartzPlan;

class SaintQuartzPlanning extends StatefulWidget {
  SaintQuartzPlanning({Key? key}) : super(key: key);

  @override
  _SaintQuartzPlanningState createState() => _SaintQuartzPlanningState();
}

class _SaintQuartzPlanningState extends State<SaintQuartzPlanning>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging &&
          _tabController.index == _tabController.length - 1) {
        db.curUser.saintQuartzPlan.solve();
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    _tabController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _plan.validate();
    return Scaffold(
      appBar: AppBar(
        title: Text(Item.lNameOf(Items.quartz)),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: [
            Tab(text: S.current.settings_tab_name),
            Tab(
              text: LocalizedText.of(
                  chs: '特殊御主任务', jpn: 'エクストラミッション', eng: 'Extra Mission'),
            ),
            Tab(
              text: LocalizedText.of(chs: '攒石表(伪)', jpn: '結果表', eng: 'Table'),
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        physics: const NeverScrollableScrollPhysics(),
        children: [
          KeepAliveBuilder(builder: (context) => SQSettingTab()),
          KeepAliveBuilder(builder: (context) => ExtraMissionTab()),
          KeepAliveBuilder(builder: (context) => SQTableTab()),
        ],
      ),
    );
  }
}
