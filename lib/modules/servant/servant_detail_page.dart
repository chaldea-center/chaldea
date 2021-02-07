import 'package:auto_size_text/auto_size_text.dart';
import 'package:chaldea/components/components.dart';
import 'package:chaldea/modules/blank_page.dart';
import 'package:chaldea/modules/servant/tabs/svt_quest_tab.dart';
import 'package:chaldea/modules/servant/tabs/svt_voice_tab.dart';
import 'package:chaldea/modules/shared/list_page_share.dart';

import 'tabs/svt_illust_tab.dart';
import 'tabs/svt_info_tab.dart';
import 'tabs/svt_nobel_phantasm_tab.dart';
import 'tabs/svt_plan_tab.dart';
import 'tabs/svt_skill_tab.dart';

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

  ServantPlan get plan => db.curUser.svtPlanOf(svt.no);

  ServantDetailPageState(this.svt) {
    if (!Servant.unavailable.contains(svt.no)) {
      _builders[S.current.plan] = (context) => SvtPlanTab(parent: this);
    }
    if (svt.activeSkills?.isNotEmpty == true) {
      _builders[S.current.skill] = (context) => SvtSkillTab(parent: this);
    }
    if (svt.nobelPhantasm?.isNotEmpty == true) {
      _builders[S.current.nobel_phantasm] =
          (context) => SvtTreasureDeviceTab(parent: this);
    }
    _builders[S.current.card_info] = (context) => SvtInfoTab(parent: this);
    _builders[S.current.illustration] = (context) => SvtIllustTab(parent: this);
    if (svt.voices?.isNotEmpty == true) {
      _builders[S.current.voice] = (context) => SvtVoiceTab(parent: this);
    }
    if (!Servant.unavailable.contains(svt.no)) {
      _builders[S.current.quest] = (context) => SvtQuestTab(parent: this);
    }
  }

  /// just for test
  Widget getDefaultTab(String name) {
    return Center(
      child: TextButton(
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
    // TODO: why state re-created after fullscreen page popped?
    super.initState();
    _tabController = TabController(length: _builders.length, vsync: this);
    status = db.curUser.svtStatusOf(svt.no);
  }

  @override
  void deactivate() {
    super.deactivate();
    db.saveUserData();
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
          title: AutoSizeText(svt.info.localizedName, maxLines: 1),
          actions: <Widget>[
            buildSwitchPlanButton(
              context: context,
              onChange: (index) {
                db.curUser.curSvtPlanNo = index;
                this.setState(() {});
                db.itemStat.updateSvtItems();
              },
            ),
            if (!Servant.unavailable.contains(svt.no))
              IconButton(
                icon: status.curVal.favorite
                    ? Icon(Icons.favorite, color: Colors.redAccent)
                    : Icon(Icons.favorite_border),
                tooltip: S.of(context).favorite,
                onPressed: () {
                  setState(() {
                    plan.favorite =
                        status.curVal.favorite = !status.curVal.favorite;
                  });
                  db.userData.broadcastUserUpdate();
                  db.itemStat.updateSvtItems();
                },
              ),
            if (!Servant.unavailable.contains(svt.no))
              IconButton(
                icon: Icon(Icons.replay),
                tooltip: S.of(context).reset,
                // constraints: _iconConstraint,
                onPressed: () {
                  SimpleCancelOkDialog(
                    title: Text(S.of(context).reset),
                    onTapOk: () {
                      setState(() {
                        status.reset();
                        db.curUser.svtPlanOf(svt.no).reset();
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
            Align(
              alignment: Alignment.centerLeft,
              child: TabBar(
                controller: _tabController,
                labelColor: Colors.black87,
                indicatorSize: TabBarIndicatorSize.label,
                labelPadding: EdgeInsets.symmetric(horizontal: 6.0),
                unselectedLabelColor: Colors.grey,
                isScrollable: true,
                tabs: _builders.keys
                    .map((name) => Padding(
                        padding:
                            EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                        child: Text(name)))
                    .toList(),
              ),
            ),
            Divider(
              height: 1,
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

  Widget _buildHeader() {
    return CustomTile(
      leading: db.getIconImage(svt.icon, fit: BoxFit.contain, height: 65),
      title: Text('No.${svt.no}  ${svt.info.className}'),
      titlePadding: EdgeInsets.only(left: 16),
      subtitle: Wrap(
        spacing: 3,
        runSpacing: 2,
        children: <Widget>[
          // more tags/info here
          ...getObtainBadges(),
        ],
      ),
    );
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
    // TODO: obtains including some non-standard category
    final texts = {
      "初始获得": S.current.svt_obtain_initial,
      "圣晶石常驻": S.current.svt_obtain_permanent,
      "剧情限定": S.current.svt_obtain_story,
      "活动赠送": S.current.svt_obtain_event,
      "期间限定": S.current.svt_obtain_limited,
      "友情点召唤": S.current.svt_obtain_friend_point,
      "无法召唤": S.current.svt_obtain_unavailable
    };
    return svt.info.obtains.map((obtain) {
      final bgColor = badgeColors[obtain] ?? badgeColors['无法召唤'];
      final String shownText = texts[obtain] ?? obtain;
      return DecoratedBox(
        decoration: BoxDecoration(
          border: Border.all(width: 0.5, color: bgColor),
          borderRadius: BorderRadius.circular(10),
          color: bgColor,
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: Text(shownText,
              style: TextStyle(color: Colors.white, fontSize: 13)),
        ),
      );
    }).toList();
  }
}
