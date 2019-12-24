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
    if (svt.activeSkills != null) {
      _builders['技能'] = (context) => SvtSkillTab(parent: this);
    }
    if (svt.treasureDevice != null && svt.treasureDevice.length > 0) {
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
    db.saveData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(leading: BackButton(), title: Text(svt.info.name)),
        body: Column(
          children: <Widget>[
            CustomTile(
              alignment: CrossAxisAlignment.start,
              leading: Image(
                  image: db.getIconFile(svt.icon),
                  fit: BoxFit.contain,
                  height: 90),
              titlePadding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              title: Text('No.${svt.no}\n${svt.info.className}'),
              subtitle: null,
              trailing: Servant.unavailable.contains(svt.no)
                  ? null
                  : FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          IconButton(
                            icon: status.curVal.favorite
                                ? Icon(Icons.favorite, color: Colors.redAccent)
                                : Icon(Icons.favorite_border),
                            tooltip: '关注',
                            onPressed: () {
                              setState(() {
                                status.curVal.favorite =
                                    !status.curVal.favorite;
                              });
                            },
                          ),
                        ],
                      ),
                    ),
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
