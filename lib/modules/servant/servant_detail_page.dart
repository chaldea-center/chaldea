import 'package:auto_size_text/auto_size_text.dart';
import 'package:chaldea/components/components.dart';
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

class _SubTabInfo {
  final SvtTab tab;
  final String Function() tabBuilder;
  final WidgetBuilder viewBuilder;

  _SubTabInfo({
    required this.tab,
    required this.tabBuilder,
    required this.viewBuilder,
  });
}

class ServantDetailPage extends StatefulWidget {
  final Servant svt;

  const ServantDetailPage(this.svt, {Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => ServantDetailPageState();
}

class ServantDetailPageState extends State<ServantDetailPage>
    with SingleTickerProviderStateMixin {
  Servant get svt => widget.svt;

  List<_SubTabInfo> builders = [];

  // store data
  ServantStatus get status => db.curUser.svtStatusOf(svt.no);

  ServantPlan get plan => db.curUser.svtPlanOf(svt.no);

  _SubTabInfo? _getBuilder(SvtTab tab) {
    switch (tab) {
      case SvtTab.plan:
        if (Servant.unavailable.contains(svt.no)) return null;
        return _SubTabInfo(
          tab: tab,
          tabBuilder: () => S.current.plan,
          viewBuilder: (ctx) => SvtPlanTab(parent: this),
        );
      case SvtTab.skill:
        if (svt.lActiveSkills.isEmpty) return null;
        return _SubTabInfo(
          tab: tab,
          tabBuilder: () => S.current.skill,
          viewBuilder: (ctx) => SvtSkillTab(parent: this),
        );
      case SvtTab.np:
        if (svt.noblePhantasm.isEmpty) return null;
        return _SubTabInfo(
          tab: tab,
          tabBuilder: () => S.current.noble_phantasm,
          viewBuilder: (ctx) => SvtNoblePhantasmTab(parent: this),
        );
      case SvtTab.info:
        return _SubTabInfo(
          tab: tab,
          tabBuilder: () => S.current.card_info,
          viewBuilder: (ctx) => SvtInfoTab(parent: this),
        );
      case SvtTab.illustration:
        return _SubTabInfo(
          tab: tab,
          tabBuilder: () => S.current.illustration,
          viewBuilder: (ctx) => SvtIllustTab(parent: this),
        );
      case SvtTab.sprite:
        if (svt.icons.isEmpty && svt.sprites.isEmpty) return null;
        return _SubTabInfo(
          tab: tab,
          tabBuilder: () => S.current.sprites,
          viewBuilder: (ctx) => SvtSpriteTab(parent: this),
        );
      case SvtTab.summon:
        if (Servant.unavailable.contains(svt.no) ||
            ['活动', '初始获得', '无法召唤', '友情点召唤'].contains(svt.info.obtain)) {
          return null;
        }
        return _SubTabInfo(
          tab: tab,
          tabBuilder: () => S.current.summon,
          viewBuilder: (ctx) => SvtSummonTab(parent: this),
        );
      case SvtTab.voice:
        if (svt.voices.isEmpty) return null;
        return _SubTabInfo(
          tab: tab,
          tabBuilder: () => S.current.voice,
          viewBuilder: (ctx) => SvtVoiceTab(parent: this),
        );
      case SvtTab.quest:
        if (Servant.unavailable.contains(svt.no) ||
            db.gameData.svtQuests[svt.no]?.isNotEmpty != true) {
          return null;
        }
        return _SubTabInfo(
          tab: tab,
          tabBuilder: () => S.current.quest,
          viewBuilder: (ctx) => SvtQuestTab(parent: this),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    db.appSetting.validateSvtTabs();
    builders = db.appSetting.sortedSvtTabs
        .map((e) => _getBuilder(e))
        .whereType<_SubTabInfo>()
        .toList();
    return DefaultTabController(
      length: builders.length,
      child: Scaffold(
          appBar: AppBar(
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
                        ? const Icon(Icons.favorite, color: Colors.redAccent)
                        : const Icon(Icons.favorite_border),
                    tooltip: S.of(context).favorite,
                    onPressed: () {
                      setState(() {
                        status.favorite = !status.favorite;
                      });
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
                    labelColor: Theme.of(context).colorScheme.secondary,
                    indicatorSize: TabBarIndicatorSize.tab,
                    labelPadding: const EdgeInsets.symmetric(horizontal: 8.0),
                    unselectedLabelColor: Colors.grey,
                    isScrollable: true,
                    tabs: builders
                        .map((e) => Tab(
                            child: Text(e.tabBuilder(),
                                style: Theme.of(context).textTheme.bodyText2)))
                        .toList(),
                  ),
                ),
              ),
              const Divider(height: 1),
              Expanded(
                child: TabBarView(
                  children:
                      builders.map((e) => e.viewBuilder(context)).toList(),
                ),
              )
            ],
          )),
    );
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
          // if (_tabController.index == 0)
          PopupMenuItem<String>(
            child: Text(S.current.svt_switch_slider_dropdown),
            value: 'switch_slider_dropdown',
            onTap: () {
              db.appSetting.svtPlanSliderMode =
                  !db.appSetting.svtPlanSliderMode;
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
            const SimpleCancelOkDialog(
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
          if (!db.gameData.unavailableSvts.contains(svt.no))
            Text(
              'ATK ${svt.info.atkMax}  HP ${svt.info.hpMax}',
              style: Theme.of(context).textTheme.caption,
            ),
          const SizedBox(height: 4),
        ],
      ),
      titlePadding: const EdgeInsets.only(left: 16),
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
              final int priority = 5 - index;
              return DropdownMenuItem(
                value: priority,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(icons[index],
                        color: Theme.of(context).colorScheme.secondary),
                    SizedBox(
                      width: 40,
                      child: Center(
                        child: Text(
                          db.appSetting.priorityTags['$priority'] ?? '',
                          overflow: TextOverflow.fade,
                          style: const TextStyle(fontSize: 12),
                          maxLines: 1,
                        ),
                      ),
                    )
                  ],
                ),
              );
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
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: Text(shownText,
              style: const TextStyle(color: Colors.white, fontSize: 13)),
        ),
      );
    }).toList();
  }
}
