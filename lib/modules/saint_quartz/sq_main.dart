import 'package:chaldea/components/components.dart';

import 'extra_mission_tab.dart';
import 'setting_tab.dart';
import 'table_tab.dart';

SaintQuartzPlan get _plan => db.curUser.saintQuartzPlan;

class SaintQuartzPlanning extends StatefulWidget {
  const SaintQuartzPlanning({Key? key}) : super(key: key);

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
        print('hello');
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
            Tab(text: 'Extra Mission'),
            Tab(text: 'Result'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        physics: NeverScrollableScrollPhysics(),
        children: [
          KeepAliveBuilder(builder: (context) => SQSettingTab()),
          KeepAliveBuilder(builder: (context) => ExtraMissionTab()),
          KeepAliveBuilder(builder: (context) => SQTableTab()),
        ],
      ),
    );
  }

  Widget get resultTab {
    return ListView(
      children: [
        ListTile(
          title: Text('截止时间(Local)'),
          subtitle: Text('连续登陆/周常任务'),
          trailing: Text(''),
        )
      ],
    );
  }

  Widget get missionBonusTab {
    return ListView(
      children: [
        SwitchListTile.adaptive(
          value: _plan.weeklyMission,
          title: Text(LocalizedText.of(
              chs: '周常任务', jpn: 'ウィークリーミッション', eng: 'Weekly Mission')),
          subtitle: Text(LocalizedText.of(
              chs: '与登陆奖励时间范围相同',
              jpn: 'ログイン報酬の時間範囲と同じ',
              eng: 'Same as login bonus time range ')),
          onChanged: (v) {
            setState(() {
              _plan.weeklyMission = v;
            });
          },
          controlAffinity: ListTileControlAffinity.trailing,
        ),
        ListTile(
          title: Text('Extra Mission'),
          subtitle: Text('Unimplemented'),
        )
      ],
    );
  }
}
