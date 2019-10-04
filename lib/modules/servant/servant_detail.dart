import 'package:chaldea/components/components.dart';
import 'package:chaldea/components/custom_tile.dart';
import 'package:chaldea/modules/blank_page.dart';
import 'package:chaldea/modules/servant/servant_tabs.dart';
import 'package:flutter/material.dart';

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
  List<String> _tabNames = ['规划', '技能', '宝具', '特攻', '卡池', '礼装', '语音', '卡面'];

  // store data
  List<bool> enhanced = [false, false, false, false];
  ServantPlan plan;

  ServantDetailPageState(this.svt);

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabNames.length, vsync: this);
    if (!db.userData.servants.containsKey(svt.no.toString())) {
      db.userData.servants[svt.no.toString()] = ServantPlan();
    }
    plan = db.userData.servants[svt.no.toString()];
  }

  @override
  void deactivate() {
    super.deactivate();
    db.saveData(user: true);
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
              leading: Image.file(db.getIconFile(svt.icon),
                  fit: BoxFit.contain, height: 100),
              titlePadding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              title: Text('No.${svt.no}\n${svt.info.className}'),
              trailing: IconButton(
                icon: plan.favorite
                    ? Icon(Icons.favorite, color: Colors.redAccent)
                    : Icon(Icons.favorite_border),
                onPressed: () {
                  plan.favorite = !plan.favorite;
                  setState(() {});
                },
              ),
            ),
            TabBar(
              controller: _tabController,
              labelColor: Colors.black87,
              unselectedLabelColor: Colors.grey,
              isScrollable: true,
              tabs: _tabNames.map((name) => Tab(text: name)).toList(),
            ),
            Divider(
              height: 0.0,
            ),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: _tabNames.map((name) {
                  switch (name) {
                    case '规划':
                      return PlanTab(parent: this);
                    case '技能':
                      return SkillTab(parent: this);
                    case '宝具':
                      return NobelPhantasmTab(parent: this);
                    default:
                      return ListView(
                        children: <Widget>[
                          Container(
                            height: 600.0,
                            child: Center(
                                child: FlatButton(
                              child: Text(name),
                              onPressed: () {
                                Navigator.of(context).push(MaterialPageRoute(
                                  builder: (context) => BlankPage(),
                                ));
                              },
                            )),
                          )
                        ],
                      );
                  }
                }).toList(),
              ),
            )
          ],
        ));
  }
}
