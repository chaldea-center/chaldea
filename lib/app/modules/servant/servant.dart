import 'dart:ui';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

import 'package:chaldea/app/api/atlas.dart';
import 'package:chaldea/app/app.dart';
import 'package:chaldea/app/modules/common/builders.dart';
import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/models/models.dart';
import 'package:chaldea/utils/utils.dart';
import 'package:chaldea/widgets/charts/growth_curve_page.dart';
import 'package:chaldea/widgets/widgets.dart';
import '../common/not_found.dart';
import 'tabs/_transform_tabber.dart';
import 'tabs/illustration_tab.dart';
import 'tabs/info_tab.dart';
import 'tabs/plan_tab.dart';
import 'tabs/profile_tab.dart';
import 'tabs/quest_tab.dart';
import 'tabs/related_cards_tab.dart';
import 'tabs/skill_tab.dart';
import 'tabs/sp_dmg.dart';
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

  const ServantDetailPage({super.key, this.id, this.svt});

  @override
  State<StatefulWidget> createState() => ServantDetailPageState();
}

class ServantDetailPageState extends State<ServantDetailPage> with SingleTickerProviderStateMixin {
  Servant? _svt;

  Servant get svt => _svt!;

  BasicServant? get entity => db.gameData.entities[widget.svt?.id ?? widget.id];

  List<_SubTabInfo> builders = [];

  // store data
  SvtStatus get status => svt.status;

  SvtPlan get plan => svt.curPlan;

  @override
  void initState() {
    super.initState();
    _fetchSvt();
  }

  void _fetchSvt() async {
    _svt = widget.svt ?? db.gameData.servantsWithDup[widget.id] ?? db.gameData.servantsById[widget.id];
    final id = widget.svt?.id ?? widget.id;
    if (id == null || _svt != null) return;
    _svt = await showEasyLoading(() => AtlasApi.svt(id));
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    if (_svt == null) {
      final _entity = entity;
      if (_entity != null) {
        return Scaffold(
          appBar: AppBar(title: Text(_entity.lName.l)),
          body: const Center(child: CircularProgressIndicator()),
        );
      }
      return NotFoundPage(url: Routes.servantI(widget.id ?? 0));
    }

    builders = db.settings.display.sortedSvtTabs.map((e) => _getBuilder(e)).whereType<_SubTabInfo>().toList();
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
    final asc =
        db.userData.svtAscensionIcon == -1 && svt.isUserSvt ? svt.status.cur.ascension : db.userData.svtAscensionIcon;
    final ascension = ascensions?[asc] ?? ascensions?.values.toList().getOrNull(0);
    return [
      SliverAppBar(
        title: AutoSizeText(svt.lAscName.l, maxLines: 1),
        actions: [
          if (svt.isUserSvt)
            db.onUserData(
              (context, _) => IconButton(
                icon: status.favorite
                    ? const Icon(Icons.favorite, color: Colors.redAccent)
                    : const Icon(Icons.favorite_border),
                tooltip: S.current.favorite,
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
        toolbarHeight: AppBarTheme.of(context).toolbarHeight ?? kToolbarHeight,
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
                  child: Opacity(
                    opacity: 0.4,
                    child: CachedImage(
                      imageUrl: ascension,
                      placeholder: (context, url) => const SizedBox(),
                      cachedOption: const CachedImageOption(
                        fit: BoxFit.fitWidth,
                        alignment: Alignment(0.0, -0.8),
                      ),
                    ),
                  ),
                ),
              if (ascension != null)
                Positioned.fill(
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 9, sigmaY: 9),
                    child: Container(
                      color:
                          (Theme.of(context).isDarkMode ? Colors.grey.shade800 : Colors.grey.shade600).withOpacity(0.3),
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
            placeholder: (context, url) => db.getIconImage(svt.classCard),
          );
        },
      ),
      title: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'No.${svt.collectionNo > 0 ? svt.collectionNo : svt.id}'
            ' $kStarChar2${svt.rarity}'
            '  ${Transl.svtClassId(svt.classId).l} ${Transl.svtSubAttribute(svt.attribute).l}',
            style: TextStyle(color: Colors.white.withOpacity(0.9)),
          ),
          if (db.gameData.constData.svtExp.containsKey(svt.growthCurve))
            TextButton(
              onPressed: () {
                router.pushPage(
                  GrowthCurvePage.fromCard(
                    title: '${S.current.growth_curve} - ${svt.lName.l}',
                    lvs: svt.curveData.lv,
                    atks: svt.atkGrowth,
                    hps: svt.hpGrowth,
                    avatar: CachedImage(
                      imageUrl: svt.extraAssets.status.ascension?[1] ?? svt.icon,
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
                // style: Theme.of(context).textTheme.bodySmall,
                textScaler: const TextScaler.linear(0.9),
                // style: TextStyle(color: Theme.of(context).colorScheme.primary),
                style: TextStyle(color: AppTheme(context).secondary),
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
              ),
            if (Items.specialSvtMat.contains(svt.id))
              TextButton(
                onPressed: () {
                  router.push(url: Routes.itemI(svt.id));
                },
                style: kTextButtonDenseStyle,
                child: Text(S.current.item_category_special),
              ),
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
    return FixedHeight.tabBar(TabBar(
      tabAlignment: TabAlignment.center,
      // labelColor: Theme.of(context).colorScheme.secondary,
      indicatorSize: TabBarIndicatorSize.tab,
      labelPadding: const EdgeInsets.symmetric(horizontal: 8.0),
      // unselectedLabelColor: Colors.grey,
      isScrollable: true,
      tabs: builders.map((e) => Tab(text: e.tabBuilder())).toList(),
      indicatorColor: Theme.of(context).isDarkMode ? null : Colors.white.withAlpha(210),
    ));
  }

  Widget get tabBarView {
    return TabBarView(
      children: [
        for (final builder in builders)
          builder.viewBuilder?.call(context) ?? Center(child: Text(S.current.not_implemented))
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
          viewBuilder: (ctx) => db.onUserData((context, _) => SvtPlanTab(svt: svt)),
        );
      case SvtTab.skill:
        if (svt.skills.isEmpty) return null;
        return _SubTabInfo(
          tab: tab,
          tabBuilder: () => S.current.skill,
          viewBuilder: (ctx) => TransformSvtProfileTabber(
            svt: svt,
            builder: (context, svt) => SvtSkillTab(svt: svt),
          ),
        );
      case SvtTab.np:
        if (svt.noblePhantasms.isEmpty) return null;
        return _SubTabInfo(
          tab: tab,
          tabBuilder: () => S.current.noble_phantasm,
          viewBuilder: (ctx) => TransformSvtProfileTabber(
            svt: svt,
            builder: (context, svt) => SvtTdTab(svt: svt),
          ),
        );
      case SvtTab.info:
        return _SubTabInfo(
          tab: tab,
          tabBuilder: () => S.current.svt_basic_info,
          viewBuilder: (ctx) => TransformSvtProfileTabber(
            svt: svt,
            builder: (context, svt) => SvtInfoTab(svt: svt),
          ),
        );
      case SvtTab.spDmg:
        return _SubTabInfo(
          tab: tab,
          tabBuilder: () => S.current.super_effective_damage,
          viewBuilder: (ctx) => TransformSvtProfileTabber(
            svt: svt,
            builder: (context, svt) => SvtSpDmgTab(svt: svt),
          ),
        );
      case SvtTab.lore:
        if (svt.originalCollectionNo == 0 && svt.profile.comments.isEmpty) {
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
          viewBuilder: (ctx) => SvtIllustrationTab(svt: svt),
        );
      case SvtTab.relatedCards:
        if (!svt.isServantType) return null;
        if (svt.bondEquip == 0 &&
            svt.valentineEquip.isEmpty &&
            db.gameData.craftEssences.values.every((e) => !e.extra.characters.contains(svt.originalCollectionNo)) &&
            db.gameData.commandCodes.values.every((e) => !e.extra.characters.contains(svt.originalCollectionNo))) {
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
            svt.obtains.contains(SvtObtain.eventReward) ||
            svt.rarity < 3) {
          return null;
        }
        return _SubTabInfo(
          tab: tab,
          tabBuilder: () => S.current.summon,
          viewBuilder: (ctx) => SvtSummonTab(svt: svt),
        );
      case SvtTab.voice:
        if (svt.collectionNo == 0 && svt.profile.voices.isEmpty) return null;
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
              onTap: () {
                SharedBuilder.showSwitchPlanDialog(
                  context: context,
                  onChange: (index) {
                    db.curUser.curSvtPlanNo = index;
                    db.curUser.ensurePlanLarger();
                    db.itemCenter.calculate();
                  },
                );
              },
              child: Text(S.current.select_plan),
            ),
            PopupMenuItem<String>(
              value: 'reset', // dialog
              onTap: () {
                SimpleCancelOkDialog(
                  title: Text(S.current.reset),
                  onTapOk: () {
                    if (mounted) {
                      setState(() {
                        status.cur.reset();
                        plan.reset();
                        svt.updateStat();
                      });
                    }
                  },
                ).showDialog(context);
              },
              child: Text(S.current.reset),
            ),
            PopupMenuItem<String>(
              value: 'reset_plan',
              onTap: () {
                plan.reset();
                svt.updateStat();
                if (mounted) setState(() {});
              },
              child: Text(S.current.svt_reset_plan),
            ),
            PopupMenuItem(
              child: Text(S.current.svt_ascension_icon),
              onTap: () async {
                await showDialog(
                  context: context,
                  useRootNavigator: false,
                  builder: (context) {
                    List<Widget> children = [];
                    void _addOne(String name, String? icon) {
                      if (icon == null) return;
                      icon = svt.bordered(icon);
                      children.add(ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: db.getIconImage(
                          icon,
                          width: 36,
                          padding: const EdgeInsets.symmetric(vertical: 2),
                        ),
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
                          svt.profile.costume[key]?.lName.l ?? '${S.current.costume} $key',
                          value,
                        );
                      });
                    }
                    if (svt.aprilFoolBorderedIcon != null) {
                      _addOne(S.current.april_fool, svt.aprilFoolBorderedIcon);
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
          if (svt.isUserSvt)
            PopupMenuItem<String>(
              onTap: () async {
                final newSvtId = db.curUser.addDupServant(svt);
                print('add $newSvtId');
                if (newSvtId == null) {
                  EasyLoading.showError(S.current.failed);
                } else {
                  db.itemCenter.init();
                  db.notifyAppUpdate();
                  await Future.delayed(const Duration(seconds: 1));
                  router.push(url: Routes.servantI(newSvtId));
                }
              },
              child: Text(S.current.create_duplicated_svt),
            ),
          if (svt.isDupSvt)
            PopupMenuItem<String>(
              onTap: () {
                db.curUser.dupServantMapping.remove(svt.collectionNo);
                db.itemCenter.init();
                db.notifyAppUpdate();
                Navigator.pop(context);
              },
              child: Text(S.current.remove_duplicated_svt),
            ),
          // if (_tabController.index == 0)
          if (svt.isUserSvt)
            PopupMenuItem(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: CheckboxWithLabel(
                ink: false,
                value: db.curUser.battleSim.pingedSvts.contains(svt.collectionNo),
                label: Text('Laplace: ${S.current.pin_to_top}'),
                onChanged: (v) {
                  db.curUser.battleSim.pingedSvts.toggle(svt.collectionNo);
                  Navigator.pop(context);
                },
              ),
              onTap: () {
                db.curUser.battleSim.pingedSvts.toggle(svt.collectionNo);
              },
            ),
          if (svt.isUserSvt)
            PopupMenuItem<String>(
              value: 'switch_slider_dropdown',
              onTap: () {
                db.settings.display.svtPlanInputMode =
                    EnumUtil.next(SvtPlanInputMode.values, db.settings.display.svtPlanInputMode);
                db.saveSettings();
                setState(() {});
              },
              child: Text(S.current.svt_switch_slider_dropdown),
            ),
        ];
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
    return svt.obtains.map((obtain) {
      final bgColor = badgeColors[obtain] ?? badgeColors[SvtObtain.unavailable]!;
      final String shownText = Transl.svtObtain(obtain).l;
      return DecoratedBox(
        decoration: BoxDecoration(
          border: Border.all(width: 0.5, color: bgColor),
          borderRadius: BorderRadius.circular(10),
          color: bgColor,
        ),
        child: Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(8, 2, 8, 4),
          child: Text(shownText, style: const TextStyle(color: Colors.white, fontSize: 13)),
        ),
      );
    }).toList();
  }
}
