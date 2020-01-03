import 'package:chaldea/components/components.dart';
import 'package:chaldea/modules/blank_page.dart';

import 'tabs/svt_illust_tab.dart';
import 'tabs/svt_info_tab.dart';
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
  ServantStatus status;

  ServantDetailPageState(this.svt) {
    if (!Servant.unavailable.contains(svt.no)) {
      _builders['规划'] = (context) => SvtPlanTab(parent: this);
    }
    if (svt.activeSkills?.isNotEmpty == true) {
      _builders['技能'] = (context) => SvtSkillTab(parent: this);
    }
    if (svt.treasureDevice?.isNotEmpty == true) {
      _builders['宝具'] = (context) => SvtTreasureDeviceTab(parent: this);
    }
    _builders['资料'] = (context) => SvtInfoTab(parent: this);

    _builders['卡面'] = (context) => SvtIllustTab(parent: this);

    // _builders['语音'] = (context) => getDefaultTab('语音');
  }

  Widget getDefaultTab(String name) {
    return Center(
      child: FlatButton(
        child: Text(name),
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => BlankPage(showProgress: true),
            ),
          );
        },
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _builders.length, vsync: this);
    status = db.curUser.servants.putIfAbsent(svt.no, () => ServantStatus());
  }

  @override
  void deactivate() {
    super.deactivate();
    db.saveUserData();
  }

  Widget getObtainIcon() {
    //{初始获得, 常驻, 剧情, 活动, 限定, 友情点召唤, 无法召唤}
    final bgColor = {
      "初始获得": Color(0xFFA6A6A6),
      "常驻": Color(0xFF84B63C),
      "剧情": Color(0xFFA443DF),
      "活动": Color(0xFF4487DF),
      "限定": Color(0xFFE7815C),
      "友情点召唤": Color(0xFFD19F76),
      "无法召唤": Color(0xFFA6A6A6)
    }[svt.info.obtain];
    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border.all(width: 0.5, color: bgColor),
        borderRadius: BorderRadius.circular(6),
        color: bgColor,
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Text(svt.info.obtain, style: TextStyle(color: Colors.white)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          leading: BackButton(),
          title: Text(svt.info.name),
          actions: <Widget>[
            IconButton(
                icon: Icon(Icons.list),
                onPressed: () {
                  showDialog(
                      context: context,
                      child: SimpleDialog(
                        title: Text('Choose plan'),
                        children: List.generate(db.curUser.servantPlans.length,
                            (index) {
                          return ListTile(
                            title: Text('Plan ${index + 1}'),
                            selected: index == db.curUser.curSvtPlanNo,
                            onTap: () {
                              Navigator.of(context).pop();
                              db.curUser.curSvtPlanNo = index;
                              db.runtimeData.itemStatistics.update(db.curUser);
                              this.setState(() {});
                            },
                          );
                        }),
                      ));
                }),
          ],
        ),
        body: Column(
          children: <Widget>[
            CustomTile(
              alignment: CrossAxisAlignment.start,
              leading: Image(
                  image: db.getIconImage(svt.icon),
                  fit: BoxFit.contain,
                  height: 90),
              titlePadding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              title: Text('No.${svt.no}\n${svt.info.className}'),
              subtitle: Padding(
                padding: EdgeInsets.symmetric(vertical: 6),
                child: Wrap(
                  spacing: 4,
                  children: <Widget>[
                    // more tags/info here
                    getObtainIcon(),
                  ],
                ),
              ),
              trailing: Servant.unavailable.contains(svt.no)
                  ? null
                  : FittedBox(
                      fit: BoxFit.scaleDown,
                      child: IconTheme(
                          data: Theme.of(context)
                              .iconTheme
                              .copyWith(color: Colors.black54),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              IconButton(
                                icon: status.curVal.favorite
                                    ? Icon(Icons.favorite,
                                        color: Colors.redAccent)
                                    : Icon(Icons.favorite_border),
                                tooltip: '关注',
                                onPressed: () {
                                  setState(() {
                                    status.curVal.favorite =
                                        !status.curVal.favorite;
                                  });
                                },
                              ),
                              IconButton(
                                icon: Icon(Icons.replay),
                                tooltip: '重置',
                                onPressed: () {
                                  setState(() {
                                    status.reset();
                                    db.curUser.curSvtPlan[svt.no].reset();
                                  });
                                },
                              ),
                            ],
                          )),
                    ),
            ),
            Container(
              height: 36,
              decoration: BoxDecoration(
                  border: Border(bottom: Divider.createBorderSide(context))),
              child: Center(
                child: TabBar(
                  controller: _tabController,
                  labelColor: Colors.black87,
                  labelPadding: kTabLabelPadding,
                  unselectedLabelColor: Colors.grey,
                  isScrollable: true,
                  tabs: _builders.keys.map((name) => Tab(text: name)).toList(),
                ),
              ),
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
