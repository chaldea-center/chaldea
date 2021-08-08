import 'package:auto_size_text/auto_size_text.dart';
import 'package:chaldea/components/components.dart';
import 'package:chaldea/modules/blank_page.dart';
import 'package:chaldea/modules/shared/list_page_share.dart';
import 'package:url_launcher/url_launcher.dart';

import 'tabs/svt_illust_tab.dart';
import 'tabs/svt_info_tab.dart';
import 'tabs/svt_noble_phantasm_tab.dart';
import 'tabs/svt_plan_tab.dart';
import 'tabs/svt_quest_tab.dart';
import 'tabs/svt_skill_tab.dart';
import 'tabs/svt_sprite_tab.dart';
import 'tabs/svt_summon_tab.dart';
import 'tabs/svt_voice_tab.dart';

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
  late SharedPrefItem<bool> svtPlanSliderMode;

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
    if (svt.lActiveSkills.isNotEmpty) {
      _builders[S.current.skill] = (context) => SvtSkillTab(parent: this);
    }
    if (svt.noblePhantasm.isNotEmpty) {
      _builders[S.current.noble_phantasm] =
          (context) => SvtNoblePhantasmTab(parent: this);
    }
    _builders[S.current.card_info] = (context) => SvtInfoTab(parent: this);
    _builders[S.current.illustration] = (context) => SvtIllustTab(parent: this);
    if (svt.icons.isNotEmpty || svt.sprites.isNotEmpty)
      _builders[S.current.sprites] = (context) => SvtSpriteTab(parent: this);

    if (!Servant.unavailable.contains(svt.no) &&
        !['活动', '初始获得', '无法召唤', '友情点召唤'].contains(svt.info.obtain)) {
      _builders[S.current.summon] = (context) => SvtSummonTab(parent: this);
    }
    if (svt.voices.isNotEmpty) {
      _builders[S.current.voice] = (context) => SvtVoiceTab(parent: this);
    }
    if (!Servant.unavailable.contains(svt.no) &&
        db.gameData.svtQuests[svt.no]?.isNotEmpty == true) {
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
    svtPlanSliderMode = SharedPrefItem('svtPlanSliderMode');
  }

  @override
  void dispose() {
    super.dispose();
    _tabController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          leading: BackButton(),
          titleSpacing: 0,
          title: AutoSizeText(
            svt.info.localizedName,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          actions: <Widget>[
            if (!Servant.unavailable.contains(svt.no))
              db.streamBuilder(
                (context) => IconButton(
                  icon: status.favorite
                      ? Icon(Icons.favorite, color: Colors.redAccent)
                      : Icon(Icons.favorite_border),
                  tooltip: S.of(context).favorite,
                  onPressed: () {
                    status.favorite = !status.favorite;
                    db.itemStat.updateSvtItems();
                  },
                ),
              ),
            _popupButton,
          ],
        ),
        body: Column(
          children: <Widget>[
            _buildHeader(),
            Align(
              alignment: Alignment.centerLeft,
              child: SizedBox(
                height: 36,
                child: TabBar(
                  controller: _tabController,
                  labelColor: Theme.of(context).colorScheme.secondary,
                  indicatorSize: TabBarIndicatorSize.tab,
                  labelPadding: EdgeInsets.symmetric(horizontal: 8.0),
                  unselectedLabelColor: Colors.grey,
                  isScrollable: true,
                  tabs: _builders.keys
                      .map((name) => Tab(
                          child: Text(name,
                              style: Theme.of(context).textTheme.bodyText2)))
                      .toList(),
                ),
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
            value: 'plan', // dialog
          ),
          if (!Servant.unavailable.contains(svt.no))
            PopupMenuItem<String>(
              child: Text(S.of(context).reset),
              value: 'reset', // dialog
            ),
          if (!Servant.unavailable.contains(svt.no))
            PopupMenuItem<String>(
              child: Text(S.current.svt_reset_plan),
              value: 'reset_plan',
              onTap: () {
                setState(() {
                  plan.reset();
                  // plan
                  //   ..ascension = status.curVal.ascension
                  //   ..skills = List.of(status.curVal.skills)
                  //   ..dress = List.of(status.curVal.dress)
                  //   ..appendSkills = List.of(status.curVal.appendSkills)
                  //   ..grail = status.curVal.grail
                  //   ..fouHp = status.curVal.fouHp
                  //   ..fouAtk = status.curVal.fouAtk
                  //   ..bond = status.curVal.bond;
                });
                db.itemStat.updateSvtItems();
              },
            ),
          // if (!Servant.unavailable.contains(svt.no))
          //   PopupMenuItem<String>(
          //     child: Text(S.of(context).reset_svt_enhance_state),
          //     value: 'reset_enhance',
          //     onTap: () {
          //       setState(() {
          //         status.resetEnhancement();
          //       });
          //     },
          //   ),
          PopupMenuItem<String>(
            child: Text(S.of(context).jump_to('Mooncell')),
            onTap: () {
              launch(WikiUtil.mcFullLink(svt.mcLink));
            },
          ),
          PopupMenuItem<String>(
            child: Text(S.of(context).jump_to('Fandom')),
            onTap: () {
              launch(WikiUtil.fandomFullLink(svt.info.nameEn));
            },
          ),
          if (!Servant.unavailable.contains(svt.originNo))
            PopupMenuItem<String>(
              child: Text(S.current.create_duplicated_svt),
              value: 'duplicate_svt', // push new page
            ),
          if (svt.no != svt.originNo)
            PopupMenuItem<String>(
              child: Text(S.current.remove_duplicated_svt),
              value: 'delete_duplicated', //pop cur page
            ),
          if (_tabController.index == 0)
            PopupMenuItem<String>(
              child: Text(S.current.svt_switch_slider_dropdown),
              value: 'switch_slider_dropdown',
              onTap: () {
                svtPlanSliderMode.set(!(svtPlanSliderMode.get() ?? false));
                setState(() {});
              },
            ),
        ];
      },
      onSelected: (select) {
        if (select == 'plan') {
          onSwitchPlan(
            context: context,
            onChange: (index) {
              db.curUser.curSvtPlanNo = index;
              db.curUser.ensurePlanLarger();
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
              db.itemStat.updateSvtItems();
            },
          ).showDialog(context);
        } else if (select == 'reset_plan') {
          // in onTap
        } else if (select == 'reset_enhance') {
          // in onTap
        } else if (select == 'jump_mc') {
          // in onTap
        } else if (select == 'jump_fandom') {
          // in onTap
        } else if (select == 'duplicate_svt') {
          final newSvt = db.curUser.addDuplicatedForServant(svt);
          print('add ${newSvt.no}');
          if (newSvt == svt) {
            SimpleCancelOkDialog(
              title: Text('复制从者失败'),
              content: Text('同一从者超过999个上限'),
            ).showDialog(context);
          } else {
            SplitRoute.push(
              context,
              ServantDetailPage(newSvt),
              detail: true,
            );
            db.notifyDbUpdate();
          }
        } else if (select == 'delete_duplicated') {
          db.curUser.removeDuplicatedServant(svt.no);
          db.notifyDbUpdate();
          Navigator.pop(context);
        } else if (select == 'switch_slider_dropdown') {
          // in onTap
        }
      },
    );
  }

  Widget _buildHeader() {
    return CustomTile(
      leading: InkWell(
        child:
            svt.iconBuilder(context: context, height: 64, jumpToDetail: false),
        onTap: () {
          FullscreenImageViewer.show(
            context: context,
            urls: svt.info.illustrations.values.toList(),
            placeholder: (context, url) => db.getIconImage(svt.cardBackFace),
          );
        },
      ),
      title: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('No.${svt.no}  ${svt.info.className}'),
          Text(
            'ATK ${svt.info.atkMax}  HP ${svt.info.hpMax}',
            style: Theme.of(context).textTheme.caption,
          ),
          const SizedBox(height: 4),
        ],
      ),
      titlePadding: EdgeInsets.only(left: 16),
      subtitle: Wrap(
        spacing: 3,
        runSpacing: 2,
        children: <Widget>[
          // more tags/info here
          ...getObtainBadges(),
        ],
      ),
      trailing: db.streamBuilder(
        (context) => Tooltip(
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
                    color: Theme.of(context).colorScheme.secondary,
                  ));
            }),
            onChanged: (v) {
              status.priority = v ?? status.priority;
              db.notifyDbUpdate();
            },
            underline: Container(),
            icon: Container(),
          ),
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
    return svt.info.obtains.map((obtain) {
      final bgColor = badgeColors[obtain] ?? badgeColors['无法召唤']!;
      final String shownText = Localized.svtFilter.of(obtain);
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
