import 'package:chaldea/components/components.dart';
import 'package:chaldea/modules/blank_page.dart';
import 'package:chaldea/modules/servant/tabs/svt_illust_tab.dart';
import 'package:chaldea/modules/servant/tabs/svt_info_tab.dart';

import 'tabs/svt_plan_tab.dart';
import 'tabs/svt_skill_tab.dart';
import 'tabs/svt_treasure_device_tab.dart';

class ServantDetailPage extends StatefulWidget {
  final Servant svt;

  const ServantDetailPage(this.svt);

  @override
  State<StatefulWidget> createState() => ServantDetailPageState(svt);
}

class ServantDetailPageState extends State<ServantDetailPage>
    with SingleTickerProviderStateMixin {
  Servant svt;
  TabController _tabController;

//  List<String> _tabNames = ['规划', '技能', '宝具', '特攻', '卡池', '礼装', '语音', '卡面'];
  // 特攻, 卡池,礼装,语音,卡面
  Map<String, WidgetBuilder> _builders = {};

  // store data
  List<bool> enhanced = [false, false, false, false];
  ServantPlan plan;

  ServantDetailPageState(this.svt) {
    if (!Servant.unavailable.contains(svt.no)) {
      _builders['规划'] = (context) => SvtPlanTab(parent: this);
    }
    if (svt.activeSkills != null) {
      _builders['技能'] = (context) => SvtSkillTab(parent: this);
    }
    if (svt.treasureDevice != null && svt.treasureDevice.length > 0) {
      _builders['宝具'] = (context) => SvtTreasureDeviceTab(parent: this);
    }
    _builders['资料'] = (context) => SvtInfoTab(parent: this);
    final getDefaultPage = (String name) {
      return Center(
          child: FlatButton(
        child: Text(name),
        onPressed: () {
          Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => BlankPage(
              showProgress: true,
            ),
          ));
        },
      ));
    };

    _builders['卡面'] = (context) => SvtIllustTab(parent: this);

    _builders['语音'] = (context) => getDefaultPage('语音');
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _builders.length, vsync: this);
    if (!db.curPlan.servants.containsKey(svt.no)) {
      db.curPlan.servants[svt.no] = ServantPlan();
    }
    plan = db.curPlan.servants[svt.no];
  }

  @override
  void deactivate() {
    super.deactivate();
    db.saveData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          leading: BackButton(),
          title: Text(svt.info.name),
        ),
        body: Column(
          children: <Widget>[
            CustomTile(
              alignment: CrossAxisAlignment.start,
              leading: Image(
                  image: db.getIconFile(svt.icon),
                  fit: BoxFit.contain,
                  height: 100),
              titlePadding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              title: Text('No.${svt.no}\n${svt.info.className}'),
              subtitle: Servant.unavailable.contains(svt.no)
                  ? null
                  : Align(
                      alignment: Alignment.centerRight,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          IconButton(
                              icon: Icon(Icons.vertical_align_top),
                              tooltip: '练度最大化',
                              onPressed: () {
                                setState(() {
                                  plan.allMax();
                                });
                              }),
                          IconButton(
                              icon: Icon(Icons.trending_up),
                              tooltip: '规划最大化',
                              onPressed: () {
                                setState(() {
                                  plan.planMax();
                                });
                              }),
                          IconButton(
                              icon: Icon(Icons.replay),
                              tooltip: '重置',
                              onPressed: () {
                                setState(() {
                                  plan.reset();
                                });
                              }),
                          IconButton(
                            icon: plan.favorite
                                ? Icon(Icons.favorite, color: Colors.redAccent)
                                : Icon(Icons.favorite_border),
                            tooltip: '关注',
                            onPressed: () {
                              setState(() {
                                plan.favorite = !plan.favorite;
                              });
                            },
                          ),
                        ],
                      ),
                    ),
              trailing: null,
            ),
            TabBar(
              controller: _tabController,
              labelColor: Colors.black87,
              unselectedLabelColor: Colors.grey,
              isScrollable: true,
              tabs: _builders.keys.map((name) => Tab(text: name)).toList(),
            ),
            Divider(
              height: 0.0,
            ),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: _builders.values
                    .map((builder) => builder(context))
                    .toList(),
              ),
            )
          ],
        ));
  }
}
