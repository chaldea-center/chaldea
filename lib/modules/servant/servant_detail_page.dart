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

  /// just for test
  Widget getDefaultTab(String name) {
    return Center(
      child: FlatButton(
        child: Text(name),
        onPressed: () {
          Navigator.of(context)
              .push(MaterialPageRoute(builder: (context) => BlankPage()));
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

  List<Widget> getObtainBadges() {
    // {初始获得, 常驻, 剧情, 活动, 限定, 友情点召唤, 无法召唤}
    // {'活动赠送', '事前登录赠送', '初始获得', '友情点召唤', '期间限定', '通关报酬', '无法获得',
    //   '圣晶石常驻', '剧情限定'}
    const badgeColors = {
      "初始获得": Color(0xFFA6A6A6),
      "圣晶石常驻": Color(0xFF84B63C),
      "剧情限定": Color(0xFFA443DF),
      "活动赠送": Color(0xFF4487DF),
      "期间限定": Color(0xFFE7815C),
      "友情点召唤": Color(0xFFD19F76),
      "无法召唤": Color(0xFFA6A6A6)
    };
    return svt.info.obtains.map((obtain) {
      final bgColor = badgeColors[obtain] ?? badgeColors['无法召唤'];
      return DecoratedBox(
        decoration: BoxDecoration(
          border: Border.all(width: 0.5, color: bgColor),
          borderRadius: BorderRadius.circular(6),
          color: bgColor,
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child:
              Text(obtain, style: TextStyle(color: Colors.white, fontSize: 13)),
        ),
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          leading: BackButton(
            onPressed: () {
              Navigator.of(context).maybePop();
            },
          ),
          title: Text(svt.info.name),
          actions: <Widget>[
            IconButton(
                icon: Icon(Icons.list),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => SimpleDialog(
                      title: Text('选择规划'),
                      children: List.generate(db.curUser.servantPlans.length,
                          (index) {
                        return ListTile(
                          title: Text('规划 ${index + 1}'),
                          selected: index == db.curUser.curSvtPlanNo,
                          onTap: () {
                            Navigator.of(context).pop();
                            db.curUser.curSvtPlanNo = index;
                            this.setState(() {});
                            db.itemStat.updateSvtItems();
                          },
                        );
                      }),
                    ),
                  );
                }),
            if (!Servant.unavailable.contains(svt.no))
              IconButton(
                icon: status.curVal.favorite
                    ? Icon(Icons.favorite, color: Colors.redAccent)
                    : Icon(Icons.favorite),
                tooltip: '关注',
                onPressed: () {
                  setState(() {
                    status.curVal.favorite = !status.curVal.favorite;
                  });
                  db.userData.broadcastUserUpdate();
                  db.itemStat.updateSvtItems();
                },
              ),
            if (!Servant.unavailable.contains(svt.no))
              IconButton(
                icon: Icon(Icons.replay),
                tooltip: '重置',
                // constraints: _iconConstraint,
                onPressed: () {
                  SimpleCancelOkDialog(
                    title: Text('Confirm to reset'),
                    onTapOk: () {
                      setState(() {
                        status.reset();
                        db.curUser.curSvtPlan[svt.no].reset();
                      });
                      db.userData.broadcastUserUpdate();
                      db.itemStat.updateSvtItems();
                    },
                  ).show(context);
                },
              )
          ],
        ),
        body: Column(
          children: <Widget>[
            _buildHeader(),
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

  Widget _buildHeader() {
    final avatar = Image(
        image: db.getIconImage(svt.icon), fit: BoxFit.contain, height: 90);

    final tabbar = Container(
      height: 36,
      child: Align(
        alignment: Alignment.centerLeft,
        child: TabBar(
          controller: _tabController,
          labelColor: Colors.black87,
          indicatorSize: TabBarIndicatorSize.label,
          labelPadding: kTabLabelPadding,
          unselectedLabelColor: Colors.grey,
          isScrollable: true,
          tabs: _builders.keys.map((name) => Tab(text: name)).toList(),
        ),
      ),
    );

    return DecoratedBox(
      decoration: BoxDecoration(
          border: Border(bottom: Divider.createBorderSide(context))),
      child: Column(
        // Tile+TabBar@Tablet
        mainAxisSize: MainAxisSize.min,
        children: [
          CustomTile(
            alignment: CrossAxisAlignment.start,
            leading: avatar,
            titlePadding: EdgeInsets.only(left: 16),
            title: Column(
              // (text + badges + iconButtons) + TabBar@Phone)
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Row(
                  // (text + badges) + iconButtons
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.only(top: 8),
                        child: Column(
                          // text + badges
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('No.${svt.no}  ${svt.info.className}'),
                            Padding(
                              padding: EdgeInsets.symmetric(vertical: 6),
                              child: Wrap(
                                spacing: 3,
                                runSpacing: 2,
                                children: <Widget>[
                                  // more tags/info here
                                  ...getObtainBadges(),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                // tab bar
                tabbar,
              ],
            ),
          ),
        ],
      ),
    );
  }
}
