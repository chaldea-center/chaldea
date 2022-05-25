import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:auto_size_text/auto_size_text.dart';

import 'package:chaldea/app/app.dart';
import 'package:chaldea/app/modules/common/builders.dart';
import 'package:chaldea/app/tools/icon_cache_manager.dart';
import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/models/models.dart';
import 'package:chaldea/utils/utils.dart';
import 'package:chaldea/widgets/charts/growth_curve_page.dart';
import 'package:chaldea/widgets/widgets.dart';
import '../common/extra_assets_page.dart';
import '../common/not_found.dart';
import 'tabs/info_tab.dart';
import 'tabs/plan_tab.dart';
import 'tabs/profile_tab.dart';
import 'tabs/quest_tab.dart';
import 'tabs/related_cards_tab.dart';
import 'tabs/skill_tab.dart';
import 'tabs/summon_tab.dart';
import 'tabs/td_tab.dart';
import 'tabs/voice_tab.dart';

class _SubTabInfo {
  final SvtTab tab;
  final String Function() tabBuilder;
  final WidgetBuilder? viewBuilder;

  _SubTabInfo({
    required this.tab,
    required this.tabBuilder,
    this.viewBuilder,
  });
}

class ServantDetailPage extends StatefulWidget {
  final int? id;
  final Servant? svt;

  const ServantDetailPage({Key? key, this.id, this.svt}) : super(key: key);

  @override
  State<StatefulWidget> createState() => ServantDetailPageState();
}

class ServantDetailPageState extends State<ServantDetailPage>
    with SingleTickerProviderStateMixin {
  Servant? _svt;

  Servant get svt => _svt!;

  List<_SubTabInfo> builders = [];

  // store data
  SvtStatus get status => db.curUser.svtStatusOf(svt.collectionNo);

  SvtPlan get plan => db.curUser.svtPlanOf(svt.collectionNo);

  @override
  void initState() {
    super.initState();
    _svt = widget.svt ??
        db.gameData.servants[widget.id] ??
        db.gameData.servantsById[widget.id];
  }

  @override
  void didUpdateWidget(covariant ServantDetailPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    _svt = widget.svt ??
        db.gameData.servants[widget.id] ??
        db.gameData.servantsById[widget.id];
  }

  @override
  Widget build(BuildContext context) {
    if (_svt == null) {
      return NotFoundPage(url: Routes.servantI(widget.id ?? 0));
    }
    builders = db.settings.display.sortedSvtTabs
        .map((e) => _getBuilder(e))
        .whereType<_SubTabInfo>()
        .toList();
    return DefaultTabController(
      length: builders.length,
      child: Scaffold(
        body: NestedScrollView(
          headerSliverBuilder: _sliverBuilder,
          body: MediaQuery.removePadding(
            context: context,
            removeTop: true,
            child: tabBarView,
          ),
        ),
      ),
    );
  }

  List<Widget> _sliverBuilder(BuildContext context, bool innerBoxIsScrolled) {
    final ascensions = svt.extraAssets.charaGraph.ascension;
    final ascension = ascensions?[db.userData.svtAscensionIcon] ??
        ascensions?.values.toList().getOrNull(0);
    return [
      SliverAppBar(
        title: AutoSizeText(svt.lName.l, maxLines: 1),
        elevation: 0,
        actions: [
          if (svt.isUserSvt)
            db.onUserData(
              (context, _) => IconButton(
                icon: status.favorite
                    ? const Icon(Icons.favorite, color: Colors.redAccent)
                    : const Icon(Icons.favorite_border),
                tooltip: S.of(context).favorite,
                onPressed: () {
                  setState(() {
                    status.cur.favorite = !status.cur.favorite;
                  });
                  svt.updateStat();
                },
              ),
            ),
          _popupButton,
        ],
        pinned: true,
        expandedHeight: 160,
        flexibleSpace: FlexibleSpaceBar(
          background: Stack(
            children: [
              Positioned.fill(
                child: Container(
                  color: Colors.grey,
                  // child: const SizedBox.expand(),
                ),
              ),
              if (ascension != null)
                Positioned.fill(
                  child: FadeInImage(
                    placeholder: MemoryImage(kOnePixel),
                    image: kIsWeb
                        ? NetworkImage(ascension) as ImageProvider
                        : MyCacheImage(ascension),
                    fit: BoxFit.fitWidth,
                    alignment: const Alignment(0.0, -0.8),
                  ),
                ),
              if (ascension != null)
                Positioned.fill(
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 9, sigmaY: 9),
                    child: Container(
                      color: Colors.grey[800]?.withOpacity(
                          Theme.of(context).isDarkMode ? 0.75 : 0.65),
                      child: const SizedBox.expand(),
                    ),
                  ),
                ),
              Padding(
                padding: const EdgeInsets.only(top: kToolbarHeight - 8),
                child: SafeArea(child: header),
              ),
            ],
          ),
        ),
        bottom: tabBar,
      ),
    ];
  }

  Widget get header {
    return CustomTile(
      leading: InkWell(
        child: svt.iconBuilder(
          context: context,
          height: 72,
          jumpToDetail: false,
          overrideIcon: svt.customIcon,
        ),
        onTap: () {
          FullscreenImageViewer.show(
            context: context,
            urls: svt.extraAssets.charaGraph.allUrls.toList(),
            placeholder: (context, url) {
              final card = svt.classCard;
              return card == null ? const SizedBox() : db.getIconImage(card);
            },
          );
        },
      ),
      title: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'No.${svt.collectionNo > 0 ? svt.collectionNo : svt.id}'
            '  ${Transl.svtClass(svt.className).l}',
            style: TextStyle(color: Theme.of(context).colorScheme.onPrimary),
          ),
          if (svt.isUserSvt)
            TextButton(
              onPressed: () {
                if (svt.atkGrowth.isEmpty && svt.hpGrowth.isEmpty) {
                  return;
                }
                router.pushPage(
                  GrowthCurvePage.fromCard(
                    title: '${S.current.growth_curve} - ${svt.lName.l}',
                    atks: svt.atkGrowth,
                    hps: svt.hpGrowth,
                    avatar: CachedImage(
                      imageUrl:
                          svt.extraAssets.status.ascension?[1] ?? svt.icon,
                      height: 90,
                      placeholder: (_, __) => Container(),
                    ),
                  ),
                );
              },
              style: TextButton.styleFrom(
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                padding: EdgeInsets.zero,
                visualDensity: VisualDensity.compact,
                minimumSize: const Size(48, 26),
              ),
              child: Text(
                'ATK ${svt.atkMax}  HP ${svt.hpMax}',
                // style: Theme.of(context).textTheme.caption,
                textScaleFactor: 0.9,
              ),
            ),
          const SizedBox(height: 4),
        ],
      ),
      titlePadding: const EdgeInsetsDirectional.only(start: 16),
      contentPadding: const EdgeInsetsDirectional.fromSTEB(16, 0, 16, 0),
      subtitle: SizedBox(
        height: 22,
        child: ListView(
          scrollDirection: Axis.horizontal,
          shrinkWrap: true,
          children: <Widget>[
            // more tags/info here
            for (final badge in getObtainBadges())
              Padding(
                padding: const EdgeInsetsDirectional.only(end: 4),
                child: badge,
              )
          ],
        ),
      ),
      trailing: !svt.isUserSvt
          ? null
          : SizedBox(
              height: 64,
              child: db.onUserData(
                (context, _) => Tooltip(
                  message: S.current.priority,
                  child: DropdownButton<int>(
                    value: status.priority,
                    itemHeight: 64,
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
                        child: SizedBox(
                          width: 40,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                icons[index],
                                color: Theme.of(context).colorScheme.secondary,
                              ),
                              AutoSizeText(
                                db.settings.priorityTags[priority] ?? '',
                                overflow: TextOverflow.visible,
                                minFontSize: 6,
                                maxFontSize: 12,
                                textAlign: TextAlign.center,
                                maxLines: 2,
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
                    onChanged: (v) {
                      status.priority = v ?? status.priority;
                      svt.updateStat();
                      db.notifyUserdata();
                    },
                    underline: Container(),
                    icon: Container(),
                  ),
                ),
              ),
            ),
    );
  }

  PreferredSizeWidget get tabBar {
    return PreferredSize(
      preferredSize: const Size(double.infinity, 36),
      child: SizedBox(
        height: 36,
        child: Align(
          alignment: AlignmentDirectional.centerStart,
          child: TabBar(
            // labelColor: Theme.of(context).colorScheme.secondary,
            indicatorSize: TabBarIndicatorSize.tab,
            labelPadding: const EdgeInsets.symmetric(horizontal: 8.0),
            // unselectedLabelColor: Colors.grey,
            isScrollable: true,
            tabs: builders.map((e) => Tab(text: e.tabBuilder())).toList(),
          ),
        ),
      ),
    );
  }

  Widget get tabBarView {
    return TabBarView(
      children: [
        for (final builder in builders)
          builder.viewBuilder?.call(context) ??
              Center(child: Text(S.current.not_implemented))
      ],
    );
  }

  _SubTabInfo? _getBuilder(SvtTab tab) {
    switch (tab) {
      case SvtTab.plan:
        if (!svt.isUserSvt) return null;
        return _SubTabInfo(
          tab: tab,
          tabBuilder: () => S.current.plan,
          viewBuilder: (ctx) =>
              db.onUserData((context, _) => SvtPlanTab(svt: svt)),
        );
      case SvtTab.skill:
        if (svt.skills.isEmpty) return null;
        return _SubTabInfo(
          tab: tab,
          tabBuilder: () => S.current.skill,
          viewBuilder: (ctx) => SvtSkillTab(svt: svt),
        );
      case SvtTab.np:
        if (svt.noblePhantasms.isEmpty) return null;
        return _SubTabInfo(
          tab: tab,
          tabBuilder: () => S.current.noble_phantasm,
          viewBuilder: (ctx) => SvtTdTab(svt: svt),
        );
      case SvtTab.info:
        return _SubTabInfo(
          tab: tab,
          tabBuilder: () => S.current.svt_basic_info,
          viewBuilder: (ctx) => SvtInfoTab(svt: svt),
        );
      case SvtTab.lore:
        if (svt.collectionNo == 0 && svt.profile.comments.isEmpty) {
          break;
        }
        return _SubTabInfo(
          tab: tab,
          tabBuilder: () => S.current.svt_profile,
          viewBuilder: (ctx) => SvtLoreTab(svt: svt),
        );
      case SvtTab.illustration:
        return _SubTabInfo(
          tab: tab,
          tabBuilder: () => S.current.illustration,
          viewBuilder: (ctx) => ExtraAssetsPage(
              assets: svt.extraAssets,
              aprilFoolAssets: svt.extra.aprilFoolAssets,
              spriteModels: svt.extra.spriteModels),
        );
      case SvtTab.relatedCards:
        if (svt.bondEquip == 0 &&
            svt.valentineEquip.isEmpty &&
            db.gameData.craftEssences.values
                .every((e) => !e.extra.characters.contains(svt.collectionNo)) &&
            db.gameData.commandCodes.values
                .every((e) => !e.extra.characters.contains(svt.collectionNo))) {
          return null;
        }
        return _SubTabInfo(
          tab: tab,
          tabBuilder: () => S.current.svt_related_ce,
          viewBuilder: (ctx) => SvtRelatedCardTab(svt: svt),
        );
      case SvtTab.summon:
        if (!svt.isUserSvt ||
            svt.type == SvtType.heroine ||
            svt.extra.obtains.contains(SvtObtain.eventReward) ||
            svt.rarity < 3) {
          return null;
        }
        return _SubTabInfo(
          tab: tab,
          tabBuilder: () => S.current.summon,
          viewBuilder: (ctx) => SvtSummonTab(svt: svt),
        );
      case SvtTab.voice:
        if (!svt.isUserSvt) return null;
        return _SubTabInfo(
          tab: tab,
          tabBuilder: () => S.current.voice,
          viewBuilder: (ctx) => SvtVoiceTab(svt: svt),
        );
      case SvtTab.quest:
        if (svt.relateQuestIds.isEmpty && svt.trialQuestIds.isEmpty) {
          return null;
        }
        return _SubTabInfo(
          tab: tab,
          tabBuilder: () => S.current.quest,
          viewBuilder: (ctx) => SvtQuestTab(svt: svt),
        );
    }
    return null;
  }

  Widget get _popupButton {
    return PopupMenuButton(
      itemBuilder: (context) {
        return [
          if (svt.isUserSvt) ...[
            PopupMenuItem(
              value: 'plan', // dialog
              onTap: () async {
                await null;
                SharedBuilder.showSwitchPlanDialog(
                  context: context,
                  onChange: (index) {
                    db.curUser.curSvtPlanNo = index;
                    db.curUser.ensurePlanLarger();
                    db.itemCenter.calculate();
                  },
                );
              },
              child: Text(S.of(context).select_plan),
            ),
            PopupMenuItem<String>(
              value: 'reset', // dialog
              onTap: () async {
                await null;
                if (!mounted) return;
                SimpleCancelOkDialog(
                  title: Text(S.of(context).reset),
                  onTapOk: () {
                    setState(() {
                      status.cur.reset();
                      plan.reset();
                      svt.updateStat();
                    });
                  },
                ).showDialog(context);
              },
              child: Text(S.of(context).reset),
            ),
            PopupMenuItem<String>(
              value: 'reset_plan',
              onTap: () {
                setState(() {
                  plan.reset();
                  svt.updateStat();
                });
              },
              child: Text(S.current.svt_reset_plan),
            ),
            PopupMenuItem(
              child: Text(S.current.svt_ascension_icon),
              onTap: () async {
                await null;
                await showDialog(
                  context: context,
                  useRootNavigator: false,
                  builder: (context) {
                    List<Widget> children = [];
                    void _addOne(String name, String? icon) {
                      if (icon == null) return;
                      children.add(ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: db.getIconImage(svt.bordered(icon),
                            padding: const EdgeInsets.symmetric(vertical: 2)),
                        title: Text(name),
                        onTap: () {
                          db.userData.customSvtIcon[svt.collectionNo] = icon;
                          Navigator.pop(context);
                        },
                      ));
                    }

                    final faces = svt.extraAssets.faces;
                    if (faces.ascension != null) {
                      faces.ascension!.forEach((key, value) {
                        _addOne('${S.current.ascension} $key', value);
                      });
                    }
                    if (faces.costume != null) {
                      faces.costume!.forEach((key, value) {
                        _addOne(
                          svt.profile.costume[key]?.lName.l ??
                              '${S.current.costume} $key',
                          value,
                        );
                      });
                    }
                    return SimpleCancelOkDialog(
                      title: Text(S.current.svt_ascension_icon),
                      content: SingleChildScrollView(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: children,
                        ),
                      ),
                      hideOk: true,
                      actions: [
                        TextButton(
                          onPressed: () {
                            db.userData.customSvtIcon.remove(svt.collectionNo);
                            Navigator.pop(context);
                          },
                          child: Text(S.current.reset),
                        ),
                      ],
                    );
                  },
                );
                if (mounted) setState(() {});
              },
            ),
          ],
          ...SharedBuilder.websitesPopupMenuItems(
            atlas: Atlas.dbServant(svt.id),
            mooncell: svt.extra.mcLink,
            fandom: svt.extra.fandomLink,
          ),
          // if (svt.isUserSvt)
          //   PopupMenuItem<String>(
          //     child: Text(S.current.create_duplicated_svt),
          //     value: 'duplicate_svt', // push new page
          //   ),
          // if (svt.collectionNo != svt.originNo)
          //   PopupMenuItem<String>(
          //     child: Text(S.current.remove_duplicated_svt),
          //     value: 'delete_duplicated', //pop cur page
          //   ),
          // if (_tabController.index == 0)
          if (svt.isUserSvt)
            PopupMenuItem<String>(
              value: 'switch_slider_dropdown',
              onTap: () {
                db.settings.display.svtPlanInputMode = EnumUtil.next(
                    SvtPlanInputMode.values,
                    db.settings.display.svtPlanInputMode);
                db.saveSettings();
                setState(() {});
              },
              child: Text(S.current.svt_switch_slider_dropdown),
            ),
        ];
      },
      onSelected: (select) {
        if (select == 'duplicate_svt') {
          // final newSvt = db.curUser.addDuplicatedForServant(svt);
          // print('add ${newSvt.no}');
          // if (newSvt == svt) {
          //   const SimpleCancelOkDialog(
          //     title: Text('复制从者失败'),
          //     content: Text('同一从者超过999个上限'),
          //   ).showDialog(context);
          // } else {
          //    router.pushPage(
          //     ServantDetailPage(newSvt),
          //     detail: true,
          //   );
          //   db.notifyDbUpdate();
          // }
        } else if (select == 'delete_duplicated') {
          // db.curUser.removeDuplicatedServant(svt.no);
          // db.notifyDbUpdate();
          // Navigator.pop(context);
        }
      },
    );
  }

  List<Widget> getObtainBadges() {
    const badgeColors = <SvtObtain, Color>{
      SvtObtain.heroine: Colors.purple,
      SvtObtain.permanent: Color(0xFF84B63C),
      SvtObtain.story: Color(0xFFA443DF),
      SvtObtain.eventReward: Color(0xFF4487DF),
      SvtObtain.limited: Color(0xFFE7815C),
      SvtObtain.friendPoint: Color(0xFFD19F76),
      SvtObtain.unavailable: Color(0xFFA6A6A6)
    };
    return svt.extra.obtains.map((obtain) {
      final bgColor =
          badgeColors[obtain] ?? badgeColors[SvtObtain.unavailable]!;
      final String shownText = Transl.svtObtain(obtain).l;
      return DecoratedBox(
        decoration: BoxDecoration(
          border: Border.all(width: 0.5, color: bgColor),
          borderRadius: BorderRadius.circular(10),
          color: bgColor,
        ),
        child: Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(8, 2, 8, 4),
          child: Text(shownText,
              style: const TextStyle(color: Colors.white, fontSize: 13)),
        ),
      );
    }).toList();
  }
}
