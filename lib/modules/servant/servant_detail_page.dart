//@dart=2.12
import 'package:auto_size_text/auto_size_text.dart';
import 'package:chaldea/components/components.dart';
import 'package:chaldea/modules/blank_page.dart';
import 'package:chaldea/modules/servant/tabs/svt_quest_tab.dart';
import 'package:chaldea/modules/servant/tabs/svt_summon_tab.dart';
import 'package:chaldea/modules/servant/tabs/svt_voice_tab.dart';
import 'package:chaldea/modules/shared/list_page_share.dart';
import 'package:url_launcher/url_launcher.dart';

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
  late TabController _tabController;

//  List<String> _tabNames = ['规划', '技能', '宝具', '特攻', '卡池', '礼装', '语音', '卡面'];
  // 特攻, 卡池,礼装,语音,卡面
  Map<String, WidgetBuilder> _builders = {};

  // store data
  ServantStatus get status => db.curUser.svtStatusOf(svt.no);

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
          (context) => SvtNobelPhantasmTab(parent: this);
    }
    _builders[S.current.card_info] = (context) => SvtInfoTab(parent: this);
    _builders[S.current.illustration] = (context) => SvtIllustTab(parent: this);
    if (!Servant.unavailable.contains(svt.no) &&
        !['活动', '初始获得', '无法召唤', '友情点召唤'].contains(svt.info.obtain)) {
      _builders[S.current.summon] = (context) => SvtSummonTab(parent: this);
    }
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
  }

  @override
  void deactivate() {
    super.deactivate();
    _tabController.dispose();
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
          titleSpacing: 0,
          title: AutoSizeText(svt.info.localizedName, maxLines: 1),
          actions: <Widget>[
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
            _popupButton,
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

  Widget get _popupButton {
    return PopupMenuButton(
      itemBuilder: (context) {
        return [
          PopupMenuItem(
            child: Text(S.of(context).select_plan),
            value: 'plan',
          ),
          if (!Servant.unavailable.contains(svt.no))
            PopupMenuItem<String>(
              child: Text(S.of(context).reset),
              value: 'reset',
            ),
          if (!Servant.unavailable.contains(svt.no))
            PopupMenuItem<String>(
              child: Text(S.of(context).reset_svt_enhance_state),
              value: 'reset_enhance',
            ),
          PopupMenuItem<String>(
            child: Text(S.of(context).jump_to('Mooncell')),
            value: 'jump_mc',
          ),
        ];
      },
      onSelected: (select) {
        if (select == 'plan') {
          onSwitchPlan(
            context: context,
            onChange: (index) {
              db.curUser.curSvtPlanNo = index;
              setState(() {});
              db.itemStat.updateSvtItems();
            },
          );
        } else if (select == 'reset') {
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
        } else if (select == 'reset_enhance') {
          setState(() {
            status.resetEnhancement();
          });
        } else if (select == 'jump_mc') {
          launch(MooncellUtil.fullLink(svt.mcLink, encode: true));
        }
      },
    );
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
      trailing: Tooltip(
        message: S.of(context).priority,
        child: DropdownButton<int>(
          value: status.priority,
          items: List.generate(5, (index) {
            final icons = [
              Icons.looks_5_outlined,
              Icons.looks_4_outlined,
              Icons.looks_3_outlined,
              Icons.looks_two_outlined,
              Icons.looks_one_outlined,
            ];
            return DropdownMenuItem(
                value: 5 - index,
                child: Icon(
                  icons[index],
                  color: Colors.black54,
                ));
          }),
          onChanged: (v) => setState(() => status.priority = v),
          underline: Container(),
          icon: Container(),
        ),
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
      final bgColor = badgeColors[obtain] ?? badgeColors['无法召唤']!;
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
