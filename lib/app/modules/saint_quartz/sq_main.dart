import 'package:chaldea/app/tools/localized_base.dart';
import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/models/models.dart';
import 'package:chaldea/widgets/widgets.dart';
import 'daily_bonus.dart';
import 'setting_tab.dart';
import 'table_tab.dart';

SaintQuartzPlan get _plan => db.curUser.saintQuartzPlan;

class SaintQuartzPlanning extends StatefulWidget {
  SaintQuartzPlanning({super.key});

  @override
  _SaintQuartzPlanningState createState() => _SaintQuartzPlanningState();
}

class _SaintQuartzPlanningState extends State<SaintQuartzPlanning> with SingleTickerProviderStateMixin {
  late final TabController _tabController = TabController(length: 3, vsync: this);

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
        title: Text(Items.stone?.lName.l ?? "Stone"),
        bottom: FixedHeight.tabBar(TabBar(
          controller: _tabController,
          isScrollable: true,
          tabAlignment: TabAlignment.center,
          tabs: [
            Tab(text: S.current.settings_tab_name),
            // Tab(
            //   text: LocalizedText.of(chs: '特殊御主任务', jpn: 'エクストラミッション', eng: 'Extra Mission', kor: '엑스트라 미션'),
            // ),
            Tab(
              text: LocalizedText.of(chs: '攒石表', jpn: '結果表', eng: 'Table', kor: '결과표'),
            ),
            Tab(text: S.current.login_bonus),
          ],
        )),
      ),
      body: TabBarView(
        controller: _tabController,
        // physics: const NeverScrollableScrollPhysics(),
        children: [
          SQSettingTab(),
          // ExtraMissionTab(),
          SQTableTab(),
          KeepAliveBuilder(builder: (context) => DailyBonusTab()),
        ],
      ),
    );
  }
}
