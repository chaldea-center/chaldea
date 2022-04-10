import 'dart:convert';
import 'dart:math';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:chaldea/app/app.dart';
import 'package:chaldea/app/modules/common/builders.dart';
import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/models/models.dart';
import 'package:chaldea/packages/language.dart';
import 'package:chaldea/packages/split_route/split_route.dart';
import 'package:chaldea/utils/utils.dart';
import 'package:flutter/material.dart';

import '../../../widgets/widgets.dart';
import '../common/filter_group.dart';
import '../common/filter_page_base.dart';
import 'filter.dart';
import 'servant.dart';

class ServantListPage extends StatefulWidget {
  final bool planMode;
  final void Function(Servant)? onSelected;

  ServantListPage({Key? key, this.planMode = false, this.onSelected})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => ServantListPageState();
}

class ServantListPageState extends State<ServantListPage>
    with SearchableListState<Servant, ServantListPage> {
  @override
  Iterable<Servant> get wholeData => db2.gameData.servants.values;

  Set<Servant> hiddenPlanServants = {};

  SvtFilterData get filterData => db2.settings.svtFilterData;

  FavoriteState get favoriteState =>
      widget.planMode ? filterData.planFavorite : filterData.favorite;

  set favoriteState(FavoriteState v) {
    if (widget.planMode) {
      filterData.planFavorite = v;
    } else {
      filterData.favorite = v;
    }
  }

  @override
  bool get prototypeExtent => !widget.planMode;

  @override
  void initState() {
    super.initState();
    if (db2.settings.autoResetFilter) {
      filterData.reset();
    }
    if (db2.settings.favoritePreferred != null) {
      filterData.favorite = db2.settings.favoritePreferred!;
    }
    if (widget.planMode) {
      filterData.planFavorite = FavoriteState.owned;
      if (db2.settings.display.autoTurnOnPlanNotReach) {
        filterData.favorite = FavoriteState.owned;
        filterData.planCompletion.options
          ..clear()
          ..add(false);
      }
    }
    options = _ServantOptions(onChanged: (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    filterShownList(
      compare: (a, b) => SvtFilterData.compare(a, b,
          keys: filterData.sortKeys,
          reversed: filterData.sortReversed,
          user: db2.curUser),
    );
    return scrollListener(
      useGrid: widget.planMode ? false : filterData.useGrid,
      appBar: appBar,
    );
  }

  PreferredSizeWidget? get appBar {
    Widget title = AutoSizeText(
      widget.planMode ? db2.curUser.getFriendlyPlanName() : S.current.servant,
      maxLines: 1,
      minFontSize: 12,
      maxFontSize: 18,
    );
    if (widget.planMode) {
      title = Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(child: title),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 6),
            child: Opacity(opacity: 0.7, child: Icon(Icons.edit, size: 14)),
          ),
        ],
      );
      title = InkWell(
        child: title,
        onTap: () {
          InputCancelOkDialog(
            title: S.current.set_plan_name,
            text: db2.curUser.planNames[db2.curUser.curSvtPlanNo],
            onSubmit: (s) {
              setState(() {
                s = s.trim();
                db2.curUser.planNames[db2.curUser.curSvtPlanNo] = s;
              });
            },
          ).showDialog(context);
        },
      );
    }
    return AppBar(
      title: title,
      leading: const MasterBackButton(),
      titleSpacing: 0,
      bottom: showSearchBar ? searchBar : null,
      actions: <Widget>[
        IconButton(
            icon: Icon([
              Icons.remove_circle_outline, // other
              Icons.favorite, // owned
              Icons.favorite_border, // planned
            ][favoriteState.index]),
            tooltip: ['All', 'Owned', 'Others'][favoriteState.index],
            onPressed: () {
              setState(() {
                favoriteState =
                    EnumUtil.next(FavoriteState.values, favoriteState);
              });
            }),
        IconButton(
          icon: const Icon(Icons.filter_alt),
          tooltip: S.current.filter,
          onPressed: () => FilterPage.show(
            context: context,
            builder: (context) => ServantFilterPage(
              filterData: filterData,
              onChanged: (_) {
                if (mounted) {
                  setState(() {});
                }
              },
            ),
          ),
        ),
        searchIcon,
        PopupMenuButton(
          itemBuilder: (context) {
            return [
              if (!widget.planMode)
                PopupMenuItem(
                  child: Text(db2.curUser.getFriendlyPlanName()),
                  enabled: false,
                ),
              PopupMenuItem(
                child: Text(S.current.select_plan),
                onTap: () async {
                  await null;
                  SharedBuilder.showSwitchPlanDialog(
                    context: context,
                    onChange: (index) {
                      db2.curUser.curSvtPlanNo = index;
                      db2.curUser.ensurePlanLarger();
                      db2.itemCenter.updateSvts(all: true);
                    },
                  );
                },
              ),
              if (widget.planMode) ...[
                PopupMenuItem(
                  child: Text(S.current.copy_plan_menu),
                  onTap: () async {
                    await null;
                    copyPlan();
                  },
                ),
                PopupMenuItem(
                  child: Text(
                      S.current.reset_plan_shown(db2.curUser.curSvtPlanNo + 1)),
                  onTap: () async {
                    await null;
                    SimpleCancelOkDialog(
                      title: Text(S.current.confirm),
                      content: Text(S.current
                          .reset_plan_shown(db2.curUser.curSvtPlanNo + 1)),
                      onTapOk: () {
                        for (final svt in shownList) {
                          db2.curPlan.remove(svt.collectionNo);
                        }
                        db2.itemCenter.updateSvts(all: true);
                        setState(() {});
                      },
                    ).showDialog(context);
                  },
                ),
                PopupMenuItem(
                  child: Text(
                      S.current.reset_plan_all(db2.curUser.curSvtPlanNo + 1)),
                  onTap: () async {
                    await null;
                    SimpleCancelOkDialog(
                      title: Text(S.current.confirm),
                      content: Text(S.current
                          .reset_plan_all(db2.curUser.curSvtPlanNo + 1)),
                      onTapOk: () {
                        db2.curPlan.clear();
                        db2.itemCenter.updateSvts(all: true);
                        setState(() {});
                      },
                    ).showDialog(context);
                  },
                ),
                PopupMenuItem(
                  child: Text(
                    'Only change Append 2',
                    style: db2.settings.display.onlyAppendSkillTwo
                        ? null
                        : const TextStyle(
                            decoration: TextDecoration.lineThrough),
                  ),
                  onTap: () {
                    setState(() {
                      db2.settings.display.onlyAppendSkillTwo =
                          !db2.settings.display.onlyAppendSkillTwo;
                      db2.saveSettings();
                    });
                  },
                ),
                PopupMenuItem(
                  child: const Text('Show Full Screen'),
                  enabled: SplitRoute.isSplit(context),
                  onTap: () {
                    db2.settings.display.planPageFullScreen =
                        !db2.settings.display.planPageFullScreen;
                    db2.saveSettings();
                    SplitRoute.of(context)!.detail =
                        db2.settings.display.planPageFullScreen ? null : false;
                  },
                ),
                PopupMenuItem(
                  child: Text(S.current.help),
                  onTap: () async {
                    await null;
                    SimpleCancelOkDialog(
                      title: Text(S.current.help),
                      scrollable: true,
                      content: const Text('Help msg'),
                    ).showDialog(context);
                  },
                ),
              ]
            ];
          },
        ),
      ],
    );
  }

  void _onTapSvt(Servant svt) {
    if (widget.onSelected != null) {
      widget.onSelected!(svt);
    } else {
      router.push(
        url: svt.route,
        child: ServantDetailPage(id: svt.id, svt: svt),
        detail: true,
        popDetail: true,
      );
      selected = svt;
    }
    setState(() {});
  }

  Widget _getDetailTable(Servant svt) {
    SvtStatus status = db2.curUser.svtStatusOf(svt.collectionNo);
    SvtPlan cur = status.cur, target = db2.curUser.svtPlanOf(svt.collectionNo);
    Widget _getRange(int _c, int _t) {
      bool highlight = _t > _c;
      return Center(
        child: Text(
          '$_c-$_t',
          style: TextStyle(
            color: highlight ? Colors.redAccent : null,
            // decoration: TextDecoration.underline,
          ),
        ),
      );
    }

    Widget _getHeader(String header) {
      return Center(child: Text(header, maxLines: 1));
    }

    if (!status.cur.favorite) {
      return Center(child: Text(S.of(context).svt_not_planned));
    }
    if (hiddenPlanServants.contains(svt)) {
      return Center(child: Text(S.of(context).svt_plan_hidden));
    }
    // cur.fixDressLength(svt.costumeNos.length);
    // target.fixDressLength(svt.costumeNos.length);
    return DefaultTextStyle(
      style: TextStyle(
        fontSize: 12,
        color: Theme.of(context).textTheme.caption?.color,
        fontFamily: kMonoFont,
      ),
      child: Table(
        // border: TableBorder.all(),
        children: [
          TableRow(children: [
            _getHeader(S.of(context).ascension + ':'),
            _getRange(cur.ascension, target.ascension),
            _getHeader(S.of(context).grail + ':'),
            _getRange(cur.grail, target.grail),
          ]),
          TableRow(children: [
            _getHeader(S.of(context).skill + ':'),
            for (int i = 0; i < 3; i++)
              _getRange(cur.skills[i], target.skills[i])
          ]),
          TableRow(children: [
            _getHeader(S.current.append_skill_short + ':'),
            for (int i = 0; i < 3; i++)
              _getRange(cur.appendSkills[i], target.appendSkills[i])
          ]),
          // if (cur.costumes.isNotEmpty)
          //   for (int row = 0; row < cur.dress.length / 3; row++)
          //     TableRow(
          //       children: [
          //         _getHeader(S.of(context).costume + ':'),
          //         ...List.generate(3, (col) {
          //           final dressIndex = row * 3 + col;
          //           if (dressIndex >= cur.dress.length) {
          //             return Container();
          //           } else {
          //             return _getRange(
          //                 cur.dress[dressIndex], target.dress[dressIndex]);
          //           }
          //         })
          //       ],
          //     ),
        ],
      ),
    );
  }

  bool isSvtFavorite(Servant svt) {
    return db2.curUser.svtStatusOf(svt.collectionNo).cur.favorite;
  }

  bool changeTarget = true;
  int? _changedAscension;
  int? _changedSkill;
  int? _changedAppend; // only append skill 2 - NP related
  bool? _changedDress;

  @override
  bool filter(Servant svt) {
    final svtStat = db2.curUser.svtStatusOf(svt.collectionNo);
    final svtPlan = db2.curUser.svtPlanOf(svt.collectionNo);
    if ((favoriteState == FavoriteState.owned && !svtStat.cur.favorite) ||
        (favoriteState == FavoriteState.other && svtPlan.favorite)) {
      return false;
    }

    // if (!filterData.svtDuplicated
    //     .singleValueFilter(svt.originNo == svt.no ? '1' : '2')) {
    //   return false;
    // }

    if (filterData.planCompletion.options.isNotEmpty) {
      if (!svtStat.favorite) return false;
      bool planCompletion = !<bool>[
        svtPlan.ascension > svtStat.cur.ascension,
        for (var i = 0; i < 3; i++) svtPlan.skills[i] > svtStat.cur.skills[i],
        for (var i = 0; i < 3; i++)
          svtPlan.appendSkills[i] > svtStat.cur.appendSkills[i],
        for (var costume in svt.profile.costume.values)
          (svtPlan.costumes[costume.battleCharaId] ?? 0) >
              (svtStat.cur.costumes[costume.battleCharaId] ?? 0),
        svtPlan.grail > svtStat.cur.grail,
        // svtPlan.fouHp > svtStat.cur.fouHp,
        // svtPlan.fouAtk > svtStat.cur.fouAtk,
        // svtPlan.bondLimit > svtStat.cur.bondLimit,
      ].contains(true);
      if (!filterData.planCompletion.matchOne(planCompletion)) return false;
    }
    // svt data filter
    // skill level
    // if (filterData.skillLevel.options.containsValue(true)) {
    //   final curSvtState = svtStat.cur;
    //   if (!svtStat.favorite) return false;
    //   int lowestSkill = curSvtState.skills.reduce((a, b) => min(a, b));
    //   if (!filterData.skillLevel.singleValueFilter(
    //       SvtFilterData.skillLevelData[max(lowestSkill - 8, 0)])) {
    //     return false;
    //   }
    // }
    // class name
    if (!filterData.svtClass.matchOne(svt.className, compares: {
      SvtClass.caster: (v, o) =>
          v == SvtClass.caster || v == SvtClass.grandCaster,
      SvtClass.beastII: (v, o) => SvtClassX.beasts.contains(v),
    })) {
      return false;
    }
    if (!filterData.rarity.matchOne(svt.rarity)) {
      return false;
    }

    if (!filterData.npColor
        .matchAny(svt.noblePhantasms.map((e) => e.card).toList())) {
      return false;
    }

    if (!filterData.npType
        .matchAny(svt.noblePhantasms.map((e) => e.damageType))) {
      return false;
    }

    // plan status
    if (!filterData.priority.matchOne(svtStat.priority)) {
      return false;
    }
    // end plan status

    if (!filterData.obtain.matchAny(svt.extra.obtains)) {
      return false;
    }

    if (!filterData.attribute.matchOne(svt.attribute)) {
      return false;
    }
    if (!filterData.policy
        .matchOne(svt.profile.stats?.policy ?? ServantPolicy.none)) {
      return false;
    }
    if (!filterData.personality
        .matchOne(svt.profile.stats?.personality ?? ServantPersonality.none)) {
      return false;
    }
    if (!filterData.gender.matchOne(svt.gender)) {
      return false;
    }
    if (!filterData.trait.matchAny(svt.traitsAll)) {
      return false;
    }
    if (filterData.funcType.options.isNotEmpty ||
        filterData.buffType.options.isNotEmpty) {
      List<NiceFunction> funcs = [
        if (filterData.effectScope.contain(SvtEffectScope.active))
          for (final skill in svt.skills) ...skill.functions,
        if (filterData.effectScope.contain(SvtEffectScope.passive))
          for (final skill in svt.classPassive) ...skill.functions,
        if (filterData.effectScope.contain(SvtEffectScope.append))
          for (final skill in svt.appendPassive) ...skill.skill.functions,
        if (filterData.effectScope.contain(SvtEffectScope.td))
          for (final td in svt.noblePhantasms) ...td.functions,
      ];
      if (filterData.funcTarget.options.isNotEmpty) {
        funcs.retainWhere((func) {
          return filterData.funcTarget.matchOne(func.funcTargetType);
        });
      }
      if (filterData.funcType.options.isNotEmpty) {
        if (!filterData.funcType.matchAny(funcs.map((e) => e.funcType))) {
          return false;
        }
      }
      if (filterData.buffType.options.isNotEmpty) {
        if (!filterData.buffType.matchAny(
            [for (final func in funcs) ...func.buffs.map((e) => e.type)])) {
          return false;
        }
      }

      if (filterData.buffType.options.isNotEmpty) {
        funcs.retainWhere((func) {
          final buff = func.buffs.getOrNull(0)?.type;
          if (buff == null) return false;
          return filterData.buffType.matchOne(buff);
        });
      }
      if (funcs.isEmpty) return false;
    }
    return true;
  }

  @override
  Widget buildScrollable({bool useGrid = false}) {
    int _hiddenNum = 0;
    if (widget.planMode) {
      _hiddenNum =
          shownList.where((e) => hiddenPlanServants.contains(e)).length;
    }
    final hintText = SearchableListState.defaultHintBuilder(
      context,
      defaultHintText(shownList.length, wholeData.length,
          widget.planMode ? _hiddenNum : null),
    );
    final scrollable = Scrollbar(
      controller: scrollController,
      child: useGrid
          ? buildGridView(
              topHint: hintText,
              bottomHint: hintText,
            )
          : buildListView(
              topHint: hintText,
              bottomHint: hintText,
              separator: widget.planMode
                  ? const Divider(
                      height: 1, thickness: 0.5, indent: 72, endIndent: 16)
                  : null,
            ),
    );
    if (db2.settings.display.classFilterStyle ==
        SvtListClassFilterStyle.doNotShow) {
      return scrollable;
    }
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
          child: LayoutBuilder(builder: _buildClassFilter),
        ),
        Expanded(child: scrollable)
      ],
    );
  }

  Widget _buildClassFilter(BuildContext context, BoxConstraints constraints) {
    final clsRegularBtns = [
      _oneClsBtn(SvtClass.ALL),
      for (var clsName in SvtClassX.regular) _oneClsBtn(clsName),
    ];
    final clsExtraBtns = [
      for (var clsName in [...SvtClassX.extra, SvtClass.beastII])
        _oneClsBtn(clsName),
    ];
    final extraBtn = _oneClsBtn(SvtClass.EXTRA);
    SvtListClassFilterStyle style = db2.settings.display.classFilterStyle;
    // full window mode
    if (SplitRoute.isSplit(context) && SplitRoute.of(context)!.detail == null) {
      style = SvtListClassFilterStyle.singleRowExpanded;
    }
    if (style == SvtListClassFilterStyle.auto) {
      double height = MediaQuery.of(context).size.height;
      if (height < 600) {
        // one row
        if (constraints.maxWidth < 32 * 10) {
          // fixed
          style = SvtListClassFilterStyle.singleRow;
        } else {
          // expand, scrollable
          style = SvtListClassFilterStyle.singleRowExpanded;
        }
      } else {
        // two rows ok
        if (constraints.maxWidth < 32 * 10) {
          // two row
          style = SvtListClassFilterStyle.twoRow;
        } else {
          // expand, scrollable
          style = SvtListClassFilterStyle.singleRowExpanded;
        }
      }
    }
    switch (style) {
      case SvtListClassFilterStyle.auto: // already resolved
        return Container();
      case SvtListClassFilterStyle.singleRow:
        return ConstrainedBox(
          constraints: const BoxConstraints(maxHeight: 40),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [...clsRegularBtns, extraBtn]
                .map((e) => Expanded(child: e))
                .toList(),
          ),
        );
      case SvtListClassFilterStyle.singleRowExpanded:
        final allBtns = [...clsRegularBtns, ...clsExtraBtns];
        return SizedBox(
          height: 40,
          child: Row(
            children: [
              Expanded(
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: allBtns,
                ),
              ),
              if (constraints.maxWidth < 36 * allBtns.length)
                Padding(
                  padding: const EdgeInsetsDirectional.only(start: 6),
                  child: Icon(
                    DirectionalIcons.keyboard_arrow_forward(context),
                    color: Theme.of(context).disabledColor,
                  ),
                ),
            ],
          ),
        );
      case SvtListClassFilterStyle.twoRow:
        int crossCount = max(clsRegularBtns.length, clsExtraBtns.length);
        clsRegularBtns.addAll(List.generate(
            crossCount - clsRegularBtns.length, (index) => Container()));
        clsExtraBtns.addAll(List.generate(
            crossCount - clsExtraBtns.length, (index) => Container()));
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final btns in [clsRegularBtns, clsExtraBtns])
              ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 40),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: btns.map((e) => Expanded(child: e)).toList(),
                ),
              ),
          ],
        );
      case SvtListClassFilterStyle.doNotShow:
        return Container();
    }
  }

  Widget _oneClsBtn(SvtClass clsName) {
    final extraClasses = [...SvtClassX.extra, SvtClass.beastII];
    int rarity = 1;
    if (clsName == SvtClass.ALL) {
      rarity = filterData.svtClass.isEmpty(SvtClassX.regularAll) ||
              filterData.svtClass.isAll(SvtClassX.regularAll)
          ? 5
          : 1;
    } else if (clsName == SvtClass.EXTRA) {
      if (filterData.svtClass.isAll(extraClasses)) {
        rarity = 5;
      } else if (filterData.svtClass.isEmpty(extraClasses)) {
        rarity = 1;
      } else {
        rarity = 3;
      }
    } else {
      rarity = filterData.svtClass.options.contains(clsName) ? 5 : 1;
    }
    Widget icon = db2.getIconImage(
      clsName.icon(rarity),
      aspectRatio: 1,
      width: 32,
    );
    if (rarity != 3 && clsName == SvtClass.beastII) {
      icon = Opacity(opacity: 0.5, child: icon);
    }
    return InkWell(
      child: Padding(
        padding: const EdgeInsets.all(1),
        child: icon,
      ),
      onTap: () {
        filterData.svtClass.options.clear();
        if (clsName == SvtClass.ALL) {
        } else if (clsName == SvtClass.EXTRA) {
          filterData.svtClass.options.addAll(extraClasses);
        } else {
          filterData.svtClass.options.add(clsName);
        }
        setState(() {});
      },
    );
  }

  @override
  Widget gridItemBuilder(Servant svt) {
    final status = db2.curUser.svtStatusOf(svt.collectionNo);
    Widget textBuilder(TextStyle style) {
      return RichText(
        text: TextSpan(text: '', style: style, children: [
          WidgetSpan(
            style: style,
            child: DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(6),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.white,
                    blurRadius: 3,
                    spreadRadius: 1,
                  )
                ],
              ),
              child: db2.getIconImage(
                  Atlas.asset('Terminal/Info/CommonUIAtlas/icon_nplv.png'),
                  width: 13,
                  height: 13),
            ),
          ),
          TextSpan(text: status.cur.npLv.toString()),
          TextSpan(
              text: '\n${status.cur.ascension}-' + status.cur.skills.join('/'))
        ]),
      );
    }

    return db2.onUserData(
      (context, snapshot) => InkWell(
        onLongPress: () {},
        child: ImageWithText(
          image: db2.getIconImage(svt.customIcon),
          shadowSize: 4,
          textBuilder: status.cur.favorite ? textBuilder : null,
          textStyle: const TextStyle(fontSize: 11, color: Colors.black),
          shadowColor: Colors.white,
          alignment: AlignmentDirectional.bottomStart,
          padding: const EdgeInsets.fromLTRB(4, 0, 2, 4),
          onTap: () => _onTapSvt(svt),
        ),
      ),
    );
  }

  @override
  Widget listItemBuilder(Servant svt) {
    db2.curUser
        .svtPlanOf(svt.collectionNo)
        .validate(db2.curUser.svtStatusOf(svt.collectionNo).cur);
    return widget.planMode
        ? _planListItemBuilder(svt)
        : _usualListItemBuilder(svt);
  }

  @override
  PreferredSizeWidget? get buttonBar {
    if (!widget.planMode) return null;

    final buttons = [
      DropdownButton<int>(
        value: _changedAscension,
        icon: Container(),
        hint: Text(S.current.ascension),
        items: List.generate(
          5,
          (i) => DropdownMenuItem(
            value: i,
            child: Text(
              S.current.words_separate(S.current.ascension, '$i'),
            ),
          ),
        ),
        onChanged: (v) {
          setState(() {
            _changedAscension = v;
            if (_changedAscension == null) return;
            shownList.forEach((svt) {
              if (isSvtFavorite(svt) && !hiddenPlanServants.contains(svt)) {
                final cur = db2.curUser.svtStatusOf(svt.collectionNo).cur,
                    target = db2.curUser.svtPlanOf(svt.collectionNo);
                if (changeTarget) {
                  target.ascension = max(cur.ascension, _changedAscension!);
                } else {
                  cur.ascension = _changedAscension!;
                }
              }
            });
          });
        },
      ),
      DropdownButton<int>(
        value: _changedSkill,
        icon: Container(),
        hint: Text(S.of(context).skill),
        items: List.generate(11, (i) {
          if (i == 0) {
            return DropdownMenuItem(value: i, child: const Text('x + 1'));
          } else {
            return DropdownMenuItem(
              value: i,
              child:
                  Text(S.current.words_separate(S.current.skill, i.toString())),
            );
          }
        }),
        onChanged: (v) {
          setState(() {
            _changedSkill = v;
            if (_changedSkill == null) return;
            shownList.forEach((svt) {
              if (isSvtFavorite(svt) && !hiddenPlanServants.contains(svt)) {
                final cur = db2.curUser.svtStatusOf(svt.collectionNo).cur,
                    target = db2.curUser.svtPlanOf(svt.collectionNo);
                for (int i = 0; i < 3; i++) {
                  if (changeTarget) {
                    if (v == 0) {
                      target.skills[i] = min(10, cur.skills[i] + 1);
                    } else {
                      target.skills[i] = max(cur.skills[i], _changedSkill!);
                    }
                  } else {
                    if (v == 0) {
                      cur.skills[i] = min(10, cur.skills[i] + 1);
                    } else {
                      cur.skills[i] = _changedSkill!;
                    }
                  }
                }
              }
            });
          });
        },
      ),
      DropdownButton<int>(
        value: _changedAppend,
        icon: Container(),
        hint: Text(S.current.append_skill_short +
            (db2.settings.display.onlyAppendSkillTwo ? '2' : '')),
        items: List.generate(12, (i) {
          if (i == 0) {
            return const DropdownMenuItem(value: -1, child: Text('x + 1'));
          } else {
            return DropdownMenuItem(
              value: i - 1,
              child: Text(S.current.words_separate(
                  S.current.append_skill_short +
                      (db2.settings.display.onlyAppendSkillTwo ? '2-' : '-'),
                  (i - 1).toString())),
            );
          }
        }),
        onChanged: (v) {
          setState(() {
            _changedAppend = v;
            if (_changedAppend == null) return;
            shownList.forEach((svt) {
              if (isSvtFavorite(svt) && !hiddenPlanServants.contains(svt)) {
                final cur = db2.curUser.svtStatusOf(svt.collectionNo).cur,
                    target = db2.curUser.svtPlanOf(svt.collectionNo);
                for (int i in (db2.settings.display.onlyAppendSkillTwo
                    ? [1]
                    : [0, 1, 2])) {
                  if (changeTarget) {
                    if (v == -1) {
                      target.appendSkills[i] = min(10, cur.appendSkills[i] + 1);
                    } else {
                      target.appendSkills[i] =
                          max(cur.appendSkills[i], _changedAppend!);
                    }
                  } else {
                    if (v == -1) {
                      cur.appendSkills[i] = min(10, cur.appendSkills[i] + 1);
                    } else {
                      cur.appendSkills[i] = _changedAppend!;
                    }
                  }
                }
              }
            });
          });
        },
      ),
      DropdownButton<bool>(
        value: _changedDress,
        icon: Container(),
        hint: Text(S.current.costume),
        items: [
          DropdownMenuItem(
              value: false, child: Text(S.of(context).costume + '×')),
          DropdownMenuItem(
              value: true, child: Text(S.of(context).costume + '√'))
        ],
        onChanged: (v) {
          setState(() {
            _changedDress = v;
            if (_changedDress == null) return;
            shownList.forEach((svt) {
              if (isSvtFavorite(svt) && !hiddenPlanServants.contains(svt)) {
                final cur = db2.curUser.svtStatusOf(svt.collectionNo).cur,
                    target = db2.curUser.svtPlanOf(svt.collectionNo);
                final costumes = changeTarget ? target.costumes : cur.costumes;
                costumes
                  ..clear()
                  ..addAll(Map.fromIterable(svt.profile.costume.keys,
                      value: (k) => _changedDress == true ? 1 : 0));
              }
            });
          });
        },
      ),
    ];
    return PreferredSize(
      child: Container(
        decoration: BoxDecoration(
            border: Border(top: Divider.createBorderSide(context, width: 0.5))),
        child: Align(
          alignment: Alignment.center,
          child: FittedBox(
            fit: BoxFit.contain,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Wrap(
                  spacing: 6,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: buttons,
                ),
                Wrap(
                  spacing: 6,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    const Padding(
                      padding: EdgeInsetsDirectional.only(start: 8),
                      child: Text('Set All'),
                    ),
                    FilterGroup<bool>(
                      combined: true,
                      options: const [false, true],
                      values: FilterRadioData(changeTarget),
                      onFilterChanged: (v) {
                        setState(() {
                          changeTarget = v.radioValue!;
                          _changedAscension = null;
                          _changedSkill = null;
                          _changedAppend = null;
                          _changedDress = null;
                        });
                      },
                      optionBuilder: (s) => Text(s ? 'Target' : 'Current'),
                    ),
                    IconButton(
                      onPressed: () {
                        router.push(url: Routes.items);
                      },
                      color: Theme.of(context).colorScheme.secondary,
                      icon: const Icon(Icons.category),
                      tooltip: S.current.item_title,
                    ),
                  ],
                ),
                const SizedBox(height: 4),
              ],
            ),
          ),
        ),
      ),
      preferredSize: const Size.fromHeight(64),
    );
  }

  Widget _usualListItemBuilder(Servant svt) {
    final status = db2.curUser.svtStatusOf(svt.collectionNo);
    Widget? getStatusText(BuildContext context) {
      if (!status.cur.favorite) return null;
      Widget statusText = Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // Row(
          //   mainAxisSize: MainAxisSize.min,
          //   children: [
          //     db.getIconImage('宝具强化', width: 16, height: 16),
          //     Text(status.npLv.toString()),
          //   ],
          // ),
          Text(status.cur.ascension.toString() +
              '-' +
              status.cur.skills.join('/')),
          if (status.cur.appendSkills.any((e) => e > 0))
            Text(
                status.cur.appendSkills.map((e) => e == 0 ? '-' : e).join('/')),
          if (svt.profile.costume.isNotEmpty)
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                db2.getIconImage(Atlas.assetItem(Items.costumeIconId),
                    width: 16, height: 16),
                Text(svt.profile.costume.values
                    .map((e) => status.cur.costumes[e.battleCharaId] ?? 0)
                    .join('/')),
              ],
            ),
        ],
      );
      statusText = DefaultTextStyle(
        style: Theme.of(context).textTheme.caption ?? const TextStyle(),
        child: statusText,
      );
      return statusText;
    }

    String additionalText = '';
    switch (filterData.sortKeys.first) {
      case SvtCompare.atk:
        additionalText = '  ATK ${svt.atkMax}';
        break;
      case SvtCompare.hp:
        additionalText = '  HP ${svt.hpMax}';
        break;
      default:
        break;
    }
    return CustomTile(
      leading: db2.getIconImage(svt.customIcon, width: 56),
      title: Text(
        svt.lName.l,
        maxLines: 1,
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          if (!Language.isJP) Text(svt.name, maxLines: 1),
          Text(
            'No.${svt.collectionNo} ${EnumUtil.titled(svt.className)}  $additionalText',
            maxLines: 1,
          )
        ],
      ),
      trailing: db2.onUserData(
          (context, snapshot) => getStatusText(context) ?? const SizedBox()),
      selected: SplitRoute.isSplit(context) && selected == svt,
      onTap: () => _onTapSvt(svt),
    );
  }

  Widget _planListItemBuilder(Servant svt) {
    final _hidden = hiddenPlanServants.contains(svt);
    final eyeWidget = IconButton(
      icon: Icon(
        Icons.remove_red_eye,
        color: isSvtFavorite(svt) && !_hidden
            ? Theme.of(context).colorScheme.primary
            : Theme.of(context).highlightColor,
      ),
      onPressed: () {
        if (!isSvtFavorite(svt)) return;
        setState(() {
          if (_hidden) {
            hiddenPlanServants.remove(svt);
          } else {
            hiddenPlanServants.add(svt);
          }
        });
      },
    );

    return db2.onUserData((context, snapshot) => CustomTile(
          leading: db2.getIconImage(svt.customIcon, width: 48),
          subtitle: _getDetailTable(svt),
          trailing: eyeWidget,
          selected: SplitRoute.isSplit(context) && selected == svt,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 3),
          onTap: () => _onTapSvt(svt),
        ));
  }

  void copyPlan() {
    showDialog(
      context: context,
      builder: (context) => SimpleDialog(
        title: Text(S.of(context).select_copy_plan_source),
        children: List.generate(db2.curUser.svtPlanGroups.length, (index) {
          bool isCur = index == db2.curUser.curSvtPlanNo;
          String title = db2.curUser.getFriendlyPlanName(index);
          if (isCur) title += ' (${S.current.current_})';
          return ListTile(
            title: Text(title),
            onTap: isCur
                ? null
                : () {
                    db2.curUser.curPlan.clear();
                    db2.curUser.svtPlanGroups[index].forEach((key, plan) {
                      db2.curUser.curPlan[key] =
                          SvtPlan.fromJson(jsonDecode(jsonEncode(plan)));
                    });
                    db2.curUser.ensurePlanLarger();
                    Navigator.of(context).pop();
                  },
          );
        }),
      ),
    );
  }
}

class _ServantOptions with SearchOptionsMixin<Servant> {
  bool basic = true;
  bool activeSkill = true;
  bool classPassive = true;
  bool appendSkill = false;
  bool noblePhantasm = true;
  @override
  ValueChanged? onChanged;

  _ServantOptions({this.onChanged});

  @override
  Widget builder(BuildContext context, StateSetter setState) {
    return Wrap(
      children: [
        CheckboxWithLabel(
          value: basic,
          label: Text(S.current.search_option_basic),
          onChanged: (v) {
            basic = v ?? basic;
            setState(() {});
            updateParent();
          },
        ),
        CheckboxWithLabel(
          value: activeSkill,
          label: Text(S.current.active_skill),
          onChanged: (v) {
            activeSkill = v ?? activeSkill;
            setState(() {});
            updateParent();
          },
        ),
        CheckboxWithLabel(
          value: classPassive,
          label: Text(S.current.passive_skill),
          onChanged: (v) {
            classPassive = v ?? classPassive;
            setState(() {});
            updateParent();
          },
        ),
        CheckboxWithLabel(
          value: appendSkill,
          label: Text(S.current.append_skill),
          onChanged: (v) {
            appendSkill = v ?? appendSkill;
            setState(() {});
            updateParent();
          },
        ),
        CheckboxWithLabel(
          value: noblePhantasm,
          label: Text(S.current.noble_phantasm),
          onChanged: (v) {
            noblePhantasm = v ?? noblePhantasm;
            setState(() {});
            updateParent();
          },
        ),
      ],
    );
  }

  @override
  Iterable<String?> getSummary(Servant svt) sync* {
    if (basic) {
      yield svt.collectionNo.toString();
      yield svt.id.toString();
      yield* getAllKeys(svt.lName);
      yield* getAllKeys(Transl.cvNames(svt.profile.cv));
      yield* getAllKeys(Transl.illustratorNames(svt.profile.illustrator));
      for (final nickname in svt.extra.nameOther) {
        yield SearchUtil.getCN(nickname);
      }
    }
    if (activeSkill) {
      for (final skill in svt.skills) {
        yield* _getSkillKeys(skill);
      }
    }
    if (classPassive) {
      for (final skill in svt.classPassive) {
        yield* _getSkillKeys(skill);
      }
    }

    if (appendSkill) {
      for (final skill in svt.appendPassive) {
        yield* _getSkillKeys(skill.skill);
      }
    }
    if (noblePhantasm) {
      for (final td in svt.noblePhantasms) {
        yield* _getSkillKeys(td);
      }
    }
  }

  Iterable<String?> _getSkillKeys(SkillOrTd skill) sync* {
    yield* getAllKeys(skill.lName);
    yield* getAllKeys(Transl.skillDetail(skill.unmodifiedDetail ?? ''));
    if (skill is BaseSkill) {
      for (final skillAdd in skill.skillAdd) {
        yield* getAllKeys(Transl.skillNames(skillAdd.name));
      }
    }
  }
}
