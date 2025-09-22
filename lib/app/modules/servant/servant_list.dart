import 'dart:convert';
import 'dart:math';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

import 'package:chaldea/app/app.dart';
import 'package:chaldea/app/modules/common/builders.dart';
import 'package:chaldea/app/modules/common/misc.dart';
import 'package:chaldea/app/tools/gamedata_loader.dart';
import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/models/models.dart';
import 'package:chaldea/packages/language.dart';
import 'package:chaldea/packages/split_route/split_route.dart';
import 'package:chaldea/utils/utils.dart';
import '../../../widgets/widgets.dart';
import '../common/filter_group.dart';
import '../common/filter_page_base.dart';
import 'filter.dart';
import 'servant.dart';

class ServantListPage extends StatefulWidget {
  final bool planMode;
  final void Function(Servant svt)? onSelected;
  final SvtFilterData? filterData;
  //
  final List<int>? pinged;
  final bool showSecondaryFilter;
  final int? eventId;

  ServantListPage({
    super.key,
    this.planMode = false,
    this.onSelected,
    this.filterData,
    this.pinged,
    this.showSecondaryFilter = false,
    this.eventId,
  });

  @override
  State<StatefulWidget> createState() => ServantListPageState();
}

class ServantListPageState extends State<ServantListPage> with SearchableListState<Servant, ServantListPage> {
  @override
  Iterable<Servant> get wholeData {
    if (db.settings.hideUnreleasedEnemyCollection || widget.planMode) {
      return db.gameData.servantsWithDup.values.where((e) => e.type != SvtType.enemyCollectionDetail);
    } else {
      return db.gameData.servantsWithDup.values;
    }
  }

  Set<Servant> hiddenPlanServants = {};

  SvtFilterData get filterData => widget.filterData ?? db.settings.filters.svtFilterData;

  FavoriteState get favoriteState => widget.planMode ? filterData.planFavorite : filterData.favorite;

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
    if (db.settings.autoResetFilter && widget.filterData == null) {
      filterData.reset();
      if (db.settings.preferredFavorite != null) {
        filterData.favorite = db.settings.preferredFavorite!;
      }
    }
    if (widget.planMode) {
      filterData.planFavorite = FavoriteState.owned;
      if (db.settings.display.autoTurnOnPlanNotReach) {
        filterData.favorite = FavoriteState.owned;
        filterData.planCompletion.options = {
          SvtPlanScope.ascension,
          SvtPlanScope.active,
          SvtPlanScope.append,
          SvtPlanScope.costume,
        };
      }
    }
    options = _ServantOptions(
      onChanged: (_) {
        if (mounted) setState(() {});
      },
    );
  }

  int _compareSvt(Servant a, Servant b) {
    return SvtFilterData.compare(a, b, keys: filterData.sortKeys, reversed: filterData.sortReversed, user: db.curUser);
  }

  @override
  Widget build(BuildContext context) {
    filterShownList(compare: _compareSvt);
    return scrollListener(useGrid: widget.planMode ? false : filterData.useGrid, appBar: appBar);
  }

  PreferredSizeWidget? get appBar {
    Widget title = db.onUserData(
      (context, snapshot) => AutoSizeText(
        widget.planMode ? db.curUser.getFriendlyPlanName() : S.current.servant,
        maxLines: 1,
        minFontSize: 12,
        // maxFontSize: 18,
      ),
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
            initValue: db.curUser.curPlan_.title,
            onSubmit: (s) {
              if (mounted) {
                setState(() {
                  s = s.trim();
                  db.curUser.curPlan_.title = s;
                });
              }
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
          icon: Icon(favoriteState.icon),
          tooltip: favoriteState.shownName,
          onPressed: () {
            setState(() {
              favoriteState = EnumUtil.next(FavoriteState.values, favoriteState);
            });
          },
        ),
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
              planMode: widget.planMode,
            ),
          ),
        ),
        searchIcon,
        PopupMenuButton(
          itemBuilder: (context) {
            return [
              if (!widget.planMode) PopupMenuItem(enabled: false, child: Text(db.curUser.getFriendlyPlanName())),
              PopupMenuItem(
                child: Text(S.current.select_plan),
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
              ),
              if (widget.planMode) ...[
                PopupMenuItem(
                  child: Text(S.current.copy_plan_menu),
                  onTap: () {
                    copyPlan();
                  },
                ),
                PopupMenuItem(
                  child: Text(S.current.reset_plan_shown(db.curUser.curSvtPlanNo + 1)),
                  onTap: () {
                    SimpleConfirmDialog(
                      title: Text(S.current.confirm),
                      content: Text(S.current.reset_plan_shown(db.curUser.curSvtPlanNo + 1)),
                      onTapOk: () {
                        for (final svt in shownList) {
                          db.curSvtPlan.remove(svt.collectionNo);
                        }
                        db.itemCenter.updateSvts(all: true);
                        if (mounted) setState(() {});
                      },
                    ).showDialog(context);
                  },
                ),
                PopupMenuItem(
                  child: Text(S.current.reset_plan_all(db.curUser.curSvtPlanNo + 1)),
                  onTap: () {
                    SimpleConfirmDialog(
                      title: Text(S.current.confirm),
                      content: Text(S.current.reset_plan_all(db.curUser.curSvtPlanNo + 1)),
                      onTapOk: () {
                        db.curSvtPlan.clear();
                        db.itemCenter.updateSvts(all: true);
                        setState(() {});
                      },
                    ).showDialog(context);
                  },
                ),
                PopupMenuItem(
                  child: Text(S.current.favorite_all_shown_svt),
                  onTap: () {
                    SimpleConfirmDialog(
                      title: Text(S.current.confirm),
                      content: Text('${S.current.favorite_all_shown_svt}\n${S.current.total} ${shownList.length}'),
                      onTapOk: () {
                        for (final svt in shownList) {
                          svt.status.favorite = true;
                        }
                        db.itemCenter.updateSvts();
                        if (mounted) setState(() {});
                      },
                    ).showDialog(context);
                  },
                ),
                PopupMenuItem(
                  enabled: SplitRoute.isSplit(context),
                  onTap: () {
                    db.settings.display.planPageFullScreen = !db.settings.display.planPageFullScreen;
                    SplitRoute.of(context)!.detail = db.settings.display.planPageFullScreen ? null : false;
                  },
                  child: Text(S.current.show_fullscreen),
                ),
                PopupMenuItem(
                  child: Text(S.current.help),
                  onTap: () {
                    launch(ChaldeaUrl.doc('servant_plan'));
                  },
                ),
              ],
            ];
          },
        ),
      ],
    );
  }

  void _onTapSvt(Servant svt) {
    setState(() {});
    if (widget.onSelected != null) {
      Navigator.pop(context);
      widget.onSelected!(svt);
    } else {
      router.popDetailAndPush(
        context: context,
        url: svt.route,
        child: ServantDetailPage(id: svt.id, svt: svt),
        detail: true,
      );
      selected = svt;
    }
  }

  Widget _getDetailTable(Servant svt) {
    SvtStatus status = db.curUser.svtStatusOf(svt.collectionNo);
    SvtPlan cur = status.cur, target = db.curUser.svtPlanOf(svt.collectionNo);
    Widget _getRange(int _c, int _t, int? m) {
      TextStyle? style;
      if (_t > _c) {
        style = const TextStyle(color: Colors.redAccent);
      } else if (m != null && _c >= m) {
        style = TextStyle(
          color: Theme.of(context).textTheme.bodySmall?.color?.withAlpha(100),
          fontStyle: FontStyle.italic,
        );
      }
      return Center(child: Text('$_c-$_t', style: style));
    }

    Widget _getHeader(String header) {
      return Center(child: Text(header, maxLines: 1));
    }

    if (!status.cur.favorite) {
      return Center(child: Text(S.current.svt_not_planned));
    }
    final costumes = svt.profile.costumeCollections.values.toList();
    costumes.sort2((e) => e.id);
    Widget child = DefaultTextStyle.merge(
      style: TextStyle(fontSize: 12, color: Theme.of(context).textTheme.bodySmall?.color, fontFamily: kMonoFont),
      child: Table(
        // border: TableBorder.all(),
        children: [
          TableRow(
            children: [
              _getHeader('${S.current.ascension_short}:'),
              _getRange(cur.ascension, target.ascension, 4),
              _getHeader('${S.current.np_short}:'),
              _getRange(cur.npLv, target.npLv, 5),
            ],
          ),
          TableRow(
            children: [
              _getHeader('${S.current.active_skill_short}:'),
              for (int i = 0; i < kActiveSkillNums.length; i++) _getRange(cur.skills[i], target.skills[i], 9),
            ],
          ),
          for (int row = 0; row < (kAppendSkillNums.length / 3).ceil(); row++)
            TableRow(
              children: [
                row == 0 ? _getHeader('${S.current.append_skill_short}:') : const SizedBox.shrink(),
                ...List.generate(3, (col) {
                  final i = row * 3 + col;
                  if (i >= kAppendSkillNums.length) return const SizedBox.shrink();
                  return _getRange(cur.appendSkills[i], target.appendSkills[i], 9);
                }),
              ],
            ),
          for (int row = 0; row < costumes.length / 3; row++)
            TableRow(
              children: [
                _getHeader('${S.current.costume}:'),
                ...List.generate(3, (col) {
                  final dressIndex = row * 3 + col;
                  final costumeId = costumes.getOrNull(dressIndex)?.battleCharaId;
                  if (costumeId == null) {
                    return Container();
                  }
                  return _getRange(cur.costumes[costumeId] ?? 0, target.costumes[costumeId] ?? 0, 1);
                }),
              ],
            ),
        ],
      ),
    );

    if (hiddenPlanServants.contains(svt)) {
      child = Stack(
        alignment: Alignment.center,
        children: [
          Opacity(opacity: 0.2, child: child),
          Text(S.current.svt_plan_hidden),
        ],
      );
    }
    return child;
  }

  bool isSvtFavorite(Servant svt) {
    return db.curUser.svtStatusOf(svt.collectionNo).cur.favorite;
  }

  bool changeTarget = true;
  int? _changedAscension;
  int? _changedActive;
  int? _appendNum; // -1=all, 0-4
  int? _changedAppend; // -1=x+1,0-10
  bool? _changedDress;
  int? _changedTd;
  bool _changeFavorite = false;

  @override
  bool filter(Servant svt) {
    return ServantFilterPage.filter(filterData, svt, planMode: widget.planMode, eventId: widget.eventId ?? 0);
  }

  @override
  List<Widget> handleSlivers(List<Widget> slivers, bool useGrid) {
    List<Servant> pingedSvts =
        widget.pinged?.map((e) => db.gameData.servantsNoDup[e]).whereType<Servant>().toList() ?? [];
    pingedSvts.sort2((e) => e.collectionNo);
    if (pingedSvts.isNotEmpty) {
      slivers = [
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 6),
          sliver: SliverGrid.extent(
            maxCrossAxisExtent: 72,
            mainAxisSpacing: 2,
            crossAxisSpacing: 2,
            childAspectRatio: 132 / 144,
            children: [for (final datum in pingedSvts) gridItemBuilder(datum)],
          ),
        ),
        ...slivers,
      ];
    }
    return super.handleSlivers(slivers, useGrid);
  }

  @override
  Widget buildScrollable({bool useGrid = false}) {
    int _hiddenNum = 0;
    if (widget.planMode) {
      _hiddenNum = shownList.where((e) => hiddenPlanServants.contains(e)).length;
    }
    final hintText = SearchableListState.defaultHintBuilder(
      context,
      defaultHintText(shownList.length, wholeData.length, widget.planMode ? _hiddenNum : null),
    );
    Widget scrollable = Scrollbar(
      controller: scrollController,
      child: useGrid
          ? buildGridView(topHint: hintText, bottomHint: hintText)
          : buildListView(
              topHint: hintText,
              bottomHint: hintText,
              separator: widget.planMode ? const Divider(height: 1, thickness: 0.5, indent: 72, endIndent: 16) : null,
            ),
    );
    scrollable = RefreshIndicator(
      onRefresh: () async {
        await GameDataLoader.instance.reloadAndUpdate();
        if (mounted) setState(() {});
      },
      child: scrollable,
    );
    if (db.settings.display.classFilterStyle == SvtListClassFilterStyle.doNotShow) {
      return scrollable;
    }
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
          child: LayoutBuilder(
            builder: (context, constraints) => SharedBuilder.topSvtClassFilter(
              context: context,
              maxWidth: constraints.maxWidth,
              data: filterData.svtClass,
              onChanged: () {
                setState(() {});
              },
            ),
          ),
        ),
        if (widget.showSecondaryFilter) secondaryTopFilters,
        Expanded(child: scrollable),
      ],
    );
  }

  Widget get secondaryTopFilters {
    const double height = 36;
    Widget _getBtn(String text) {
      return Container(
        constraints: const BoxConstraints(minHeight: height, maxHeight: height, minWidth: 28),
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: Center(child: Text(text)),
      );
    }

    return SizedBox(
      height: height,
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 2),
        scrollDirection: Axis.horizontal,
        shrinkWrap: true,
        children: [
          FilterGroup<int>(
            combined: true,
            padding: const EdgeInsets.symmetric(horizontal: 2),
            shrinkWrap: true,
            options: [CardType.arts.value, CardType.buster.value, CardType.quick.value],
            values: filterData.tdCardType,
            optionBuilder: (v) => CommandCardWidget(card: v, width: 30),
            onFilterChanged: (v, lastChanged) {
              if (lastChanged != null) {
                if (v.options.contains(lastChanged)) {
                  v.options = {lastChanged};
                } else {
                  v.options = {};
                }
              }
              setState(() {});
            },
          ),
          FilterGroup<TdEffectFlag>(
            combined: true,
            padding: const EdgeInsets.symmetric(horizontal: 4),
            shrinkWrap: true,
            values: filterData.tdType,
            options: TdEffectFlag.values,
            optionBuilder: (v) => _getBtn(Transl.enums(v, (enums) => enums.tdEffectFlag).l),
            onFilterChanged: (v, lastChanged) {
              if (lastChanged != null) {
                if (v.options.contains(lastChanged)) {
                  v.options = {lastChanged};
                } else {
                  v.options = {};
                }
              }
              setState(() {});
            },
          ),
          FilterGroup<int>(
            combined: true,
            padding: const EdgeInsets.symmetric(horizontal: 2),
            shrinkWrap: true,
            options: const [-1, 4, 5],
            values: FilterGroupData(
              options: {
                if (filterData.rarity.options.contains(5)) 5,
                if (filterData.rarity.options.contains(4)) 4,
                if (filterData.rarity.options.containSubset(<int>{0, 1, 2, 3})) -1,
              },
            ),
            optionBuilder: (v) => _getBtn(v == -1 ? '$kStarChar≤3' : v.toString()),
            onFilterChanged: (v, lastChanged) {
              if (lastChanged != null) {
                if (v.options.contains(lastChanged)) {
                  filterData.rarity.options = lastChanged == -1 ? {0, 1, 2, 3} : {lastChanged};
                } else {
                  filterData.rarity.options = {};
                }
              }
              setState(() {});
            },
          ),
          if ((widget.eventId ?? 0) != 0)
            FilterGroup<bool>(
              combined: true,
              padding: const EdgeInsets.symmetric(horizontal: 4),
              shrinkWrap: true,
              values: FilterRadioData.nonnull(filterData.isEventSvt),
              options: const [true],
              optionBuilder: (v) => _getBtn(S.current.event),
              onFilterChanged: (v, lastChanged) {
                filterData.isEventSvt = !filterData.isEventSvt;
                setState(() {});
              },
            ),
        ],
      ),
    );
  }

  @override
  Widget gridItemBuilder(Servant svt) {
    final status = db.curUser.svtStatusOf(svt.collectionNo);
    Widget textBuilder(TextStyle style) {
      return Text.rich(
        TextSpan(
          style: style,
          children: [
            WidgetSpan(
              style: style,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(6),
                  boxShadow: const [BoxShadow(color: Colors.white, blurRadius: 3, spreadRadius: 1)],
                ),
                child: db.getIconImage(Atlas.asset('Terminal/Info/CommonUIAtlas/icon_nplv.png'), width: 13, height: 13),
              ),
            ),
            TextSpan(text: status.cur.npLv.toString()),
            TextSpan(text: '\n${status.cur.ascension}-${status.cur.skills.join('/')}'),
            if (status.cur.appendSkills.any((lv) => lv > 0))
              TextSpan(text: "\n${status.cur.appendSkills.map((e) => e == 0 ? '-' : e.toString()).join('/')}"),
          ],
        ),
        textScaler: const TextScaler.linear(0.9),
      );
    }

    return db.onUserData(
      (context, snapshot) => InkWell(
        child: ImageWithText(
          image: svt.iconBuilder(context: context, jumpToDetail: false, width: 72),
          textBuilder: status.cur.favorite ? textBuilder : null,
          option: ImageWithTextOption(
            shadowSize: 4,
            textStyle: const TextStyle(fontSize: 11, color: Colors.black),
            shadowColor: Colors.white,
            alignment: AlignmentDirectional.bottomStart,
            padding: const EdgeInsets.fromLTRB(4, 0, 2, 4),
          ),
          onTap: () => _onTapSvt(svt),
        ),
        onTap: () => _onTapSvt(svt),
        onLongPress: () {
          if (widget.onSelected != null) {
            router.popDetailAndPush(
              context: context,
              url: svt.route,
              child: ServantDetailPage(id: svt.id, svt: svt),
              detail: true,
            );
          }
        },
      ),
    );
  }

  @override
  Widget listItemBuilder(Servant svt) {
    svt.curPlan.validate(svt.status.cur, svt);
    return widget.planMode ? _planListItemBuilder(svt) : _usualListItemBuilder(svt);
  }

  @override
  PreferredSizeWidget? get buttonBar {
    if (!widget.planMode) return null;

    Text text(String s) => Text(s, style: const TextStyle(fontSize: 14));

    final buttons1 = [
      DropdownButton<int>(
        isDense: true,
        value: _changedAscension,
        icon: Container(),
        hint: text(S.current.ascension_short),
        items: List.generate(
          5,
          (i) => DropdownMenuItem(value: i, child: text(S.current.words_separate(S.current.ascension_short, '$i'))),
        ),
        onChanged: (v) {
          setState(() {
            _changedAscension = v;
            if (_changedAscension == null) return;
            _batchChange((svt, cur, target) {
              if (changeTarget) {
                target.ascension = max(cur.ascension, _changedAscension!);
              } else {
                cur.ascension = _changedAscension!;
              }
            });
          });
        },
      ),
      DropdownButton<int>(
        isDense: true,
        value: _changedActive,
        icon: Container(),
        hint: text(S.current.active_skill_short),
        items: List.generate(11, (i) {
          if (i == 0) {
            return DropdownMenuItem(value: i, child: text('x + 1'));
          } else {
            return DropdownMenuItem(
              value: i,
              child: text(S.current.words_separate(S.current.active_skill_short, i.toString())),
            );
          }
        }),
        onChanged: (v) {
          setState(() {
            _changedActive = v;
            if (_changedActive == null) return;
            _batchChange((svt, cur, target) {
              for (int i = 0; i < kActiveSkillNums.length; i++) {
                if (changeTarget) {
                  if (v == 0) {
                    target.skills[i] = min(10, cur.skills[i] + 1);
                  } else {
                    target.skills[i] = max(cur.skills[i], _changedActive!);
                  }
                } else {
                  if (v == 0) {
                    cur.skills[i] = min(10, cur.skills[i] + 1);
                  } else {
                    cur.skills[i] = _changedActive!;
                  }
                }
              }
            });
          });
        },
      ),
      DropdownButton<bool>(
        isDense: true,
        value: _changedDress,
        icon: Container(),
        hint: text(S.current.costume),
        items: [
          DropdownMenuItem(value: false, child: text('${S.current.costume}×')),
          DropdownMenuItem(value: true, child: text('${S.current.costume}√')),
        ],
        onChanged: (v) {
          setState(() {
            _changedDress = v;
            if (_changedDress == null) return;
            _batchChange((svt, cur, target) {
              final costumes = changeTarget ? target.costumes : cur.costumes;
              costumes.clear();
              costumes.addAll(
                Map.fromIterable(svt.profile.costumeCollections.keys, value: (k) => _changedDress == true ? 1 : 0),
              );
            });
          });
        },
      ),
      DropdownButton<int>(
        isDense: true,
        value: _changedTd,
        icon: Container(),
        hint: text(S.current.np_short),
        items: List.generate(6, (i) => DropdownMenuItem(value: i, child: text('${S.current.np_short}$i'))),
        onChanged: (v) {
          setState(() {
            _changedTd = v;
            if (_changedTd == null) return;
            _batchChange((svt, cur, target) {
              if (changeTarget) {
                target.npLv = max(cur.npLv, _changedTd!);
              } else {
                cur.npLv = _changedTd!;
              }
            });
          });
        },
      ),
      IconButton(
        constraints: const BoxConstraints(),
        onPressed: () {
          setState(() {
            _changeFavorite = !_changeFavorite;
          });
        },
        icon: Icon(_changeFavorite ? Icons.favorite : Icons.favorite_border),
        iconSize: 18,
        padding: const EdgeInsets.symmetric(horizontal: 4),
        color: _changeFavorite ? Colors.red : null,
        tooltip: S.current.plan_list_only_unlock_append,
      ),
    ];
    final buttons2 = [
      FilterGroup<bool>(
        combined: true,
        shrinkWrap: true,
        options: const [false, true],
        padding: const EdgeInsetsDirectional.only(end: 6),
        values: FilterRadioData.nonnull(changeTarget),
        onFilterChanged: (v, _) {
          setState(() {
            changeTarget = v.radioValue!;
            _changedAscension = null;
            _changedActive = null;
            _changedAppend = null;
            _changedDress = null;
            _changedTd = null;
          });
        },
        optionBuilder: (s) => Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
          child: Text(s ? S.current.plan_list_set_all_target : S.current.plan_list_set_all_current),
        ),
      ),
      DropdownButton<int>(
        // isDense: true,
        value: _appendNum,
        icon: Container(),
        hint: text(S.current.append_skill_short),
        items: [
          DropdownMenuItem(value: -1, child: text(S.current.append_skill_short)),
          for (final i in range(5))
            DropdownMenuItem(value: i, child: text(S.current.words_separate(S.current.append_skill_short, '${i + 1}'))),
        ],
        onChanged: (v) {
          setState(() {
            _appendNum = v;
          });
        },
      ),
      DropdownButton<int>(
        // isDense: true,
        value: _changedAppend,
        icon: Container(),
        hint: text('Lv'),
        items: [
          DropdownMenuItem(value: -1, child: text('x+1')),
          for (final i in range(11)) DropdownMenuItem(value: i, child: text('Lv$i')),
        ],
        onChanged: (v) {
          setState(() {
            _changedAppend = v;
            if (_changedAppend == null) return;
            _batchChange((svt, cur, target) {
              final List<int> nums = _appendNum == null || _appendNum == -1
                  ? List.generate(kAppendSkillNums.length, (i) => i)
                  : [_appendNum!];
              for (int i in nums) {
                if (db.settings.display.onlyAppendUnlocked && cur.appendSkills[i] == 0) {
                  continue;
                }
                if (changeTarget) {
                  if (v == -1) {
                    target.appendSkills[i] = min(10, cur.appendSkills[i] + 1);
                  } else {
                    target.appendSkills[i] = max(cur.appendSkills[i], _changedAppend!);
                  }
                } else {
                  if (v == -1) {
                    cur.appendSkills[i] = min(10, cur.appendSkills[i] + 1);
                  } else {
                    cur.appendSkills[i] = _changedAppend!;
                  }
                }
              }
            });
          });
        },
      ),
      IconButton(
        constraints: const BoxConstraints(),
        onPressed: () {
          setState(() {
            db.settings.display.onlyAppendUnlocked = !db.settings.display.onlyAppendUnlocked;
          });
          EasyLoading.showToast(
            '${S.current.plan_list_only_unlock_append}: ${db.settings.display.onlyAppendUnlocked ? "on" : "off"}',
          );
        },
        icon: const Icon(Icons.lock_open),
        iconSize: 18,
        padding: const EdgeInsets.symmetric(horizontal: 4),
        color: db.settings.display.onlyAppendUnlocked
            ? Theme.of(context).colorScheme.primary
            : Theme.of(context).disabledColor,
        tooltip: S.current.plan_list_only_unlock_append,
      ),
    ];
    return PreferredSize(
      preferredSize: const Size.fromHeight(64),
      child: Container(
        decoration: BoxDecoration(border: Border(top: Divider.createBorderSide(context, width: 0.5))),
        padding: const EdgeInsets.only(top: 4),
        child: Align(
          alignment: Alignment.center,
          child: FittedBox(
            fit: BoxFit.contain,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Wrap(spacing: 6, crossAxisAlignment: WrapCrossAlignment.center, children: buttons1),
                // const SizedBox(height: 8),
                Wrap(spacing: 6, crossAxisAlignment: WrapCrossAlignment.center, children: buttons2),
                const SizedBox(height: 4),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _usualListItemBuilder(Servant svt) {
    final status = db.curUser.svtStatusOf(svt.collectionNo);
    Widget? getStatusText(BuildContext context) {
      if (!status.cur.favorite) return null;
      Widget statusText = Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text('${status.cur.ascension}-${status.cur.skills.join('/')}'),
          if (status.cur.appendSkills.any((e) => e > 0))
            Text(status.cur.appendSkills.map((e) => e == 0 ? '-' : e).join('/')),
          if (svt.profile.costumeCollections.isNotEmpty)
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                db.getIconImage(Atlas.assetItem(Items.costumeIconId), width: 16, height: 16),
                Text(
                  svt.profile.costumeCollections.values.map((e) => status.cur.costumes[e.battleCharaId] ?? 0).join('/'),
                ),
              ],
            ),
          Text('${S.current.np_short}${status.cur.npLv}'),
        ],
      );
      statusText = DefaultTextStyle(
        style: Theme.of(context).textTheme.bodySmall ?? const TextStyle(),
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
      case SvtCompare.bondLv:
        if (svt.status.favorite) {
          additionalText = '  ${S.current.bond} ${svt.status.bond}';
        }
      default:
        break;
    }
    return CustomTile(
      leading: svt.iconBuilder(context: context, height: 64),
      title: Text(svt.lAscName.l, maxLines: 1),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          if (!Language.isJP) Text(svt.lAscName.jp, maxLines: 1),
          Text('No.${svt.collectionNo} ${Transl.svtClassId(svt.classId).l}  $additionalText', maxLines: 1),
        ],
      ),
      trailing: db.onUserData((context, snapshot) => getStatusText(context) ?? const SizedBox()),
      selected: SplitRoute.isSplit(context) && selected == svt,
      onTap: () => _onTapSvt(svt),
    );
  }

  Widget _planListItemBuilder(Servant svt) {
    final _hidden = hiddenPlanServants.contains(svt);
    Widget trailingButton;
    if (_changeFavorite) {
      final fav = isSvtFavorite(svt);
      trailingButton = IconButton(
        onPressed: () {
          setState(() {
            if (svt.isUserSvt) {
              svt.status.cur.favorite = !svt.status.cur.favorite;
            }
          });
        },
        icon: Icon(fav ? Icons.favorite : Icons.favorite_border),
        color: fav ? Colors.red : null,
      );
    } else {
      trailingButton = IconButton(
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
    }

    return db.onUserData(
      (context, snapshot) => CustomTile(
        leading: svt.iconBuilder(context: context, width: 48),
        subtitle: _getDetailTable(svt),
        trailing: trailingButton,
        selected: SplitRoute.isSplit(context) && selected == svt,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 3),
        onTap: () => _onTapSvt(svt),
      ),
    );
  }

  void _batchChange(void Function(Servant svt, SvtPlan cur, SvtPlan target) onChanged) {
    for (final svt in shownList) {
      if (isSvtFavorite(svt) && !hiddenPlanServants.contains(svt)) {
        final cur = db.curUser.svtStatusOf(svt.collectionNo).cur, target = db.curUser.svtPlanOf(svt.collectionNo);
        onChanged(svt, cur, target);
      }
    }
    db.itemCenter.updateSvts(all: true);
  }

  void copyPlan() {
    showDialog(
      context: context,
      useRootNavigator: false,
      builder: (context) => SimpleDialog(
        title: Text(S.current.select_copy_plan_source),
        children: List.generate(db.curUser.plans.length, (index) {
          bool isCur = index == db.curUser.curSvtPlanNo;
          String title = db.curUser.getFriendlyPlanName(index);
          if (isCur) title += ' (${S.current.current_})';
          return ListTile(
            title: Text(title),
            onTap: isCur
                ? null
                : () {
                    final src = UserPlan.fromJson(jsonDecode(jsonEncode(db.curUser.plans[index])));
                    db.curPlan_
                      ..servants = src.servants
                      ..classBoards = src.classBoards;
                    db.curUser.ensurePlanLarger();
                    db.itemCenter.calculate();
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
      yield SearchUtil.getJP(svt.ruby);
      for (final name in svt.allNames) {
        yield* getAllKeys(Transl.svtNames(name));
      }
      yield* getAllKeys(Transl.cvNames(svt.profile.cv));
      yield* getAllKeys(Transl.illustratorNames(svt.profile.illustrator));
      yield* getListKeys(svt.extra.nicknames.cn, (e) => SearchUtil.getCN(e));
      yield* getListKeys(svt.extra.nicknames.jp, (e) => SearchUtil.getJP(e));
      yield* getListKeys(svt.extra.nicknames.na, (e) => SearchUtil.getEn(e));
      yield* getListKeys(svt.extra.nicknames.tw, (e) => SearchUtil.getCN(e));
      yield* getListKeys(svt.extra.nicknames.kr, (e) => SearchUtil.getKr(e));
    }
    if (activeSkill) {
      for (final skill in svt.skills) {
        yield* getSkillKeys(skill);
      }
    }
    if (classPassive) {
      for (final skill in svt.classPassive) {
        yield* getSkillKeys(skill);
      }
    }

    if (appendSkill) {
      for (final skill in svt.appendPassive) {
        yield* getSkillKeys(skill.skill);
      }
    }
    if (noblePhantasm) {
      for (final td in svt.noblePhantasms) {
        yield* getSkillKeys(td);
      }
      for (final name in svt.ascensionAdd.overWriteTDName.all.values) {
        yield* getAllKeys(Transl.tdNames(name));
      }
      for (final name in svt.ascensionAdd.overWriteTDRuby.all.values) {
        yield* getAllKeys(Transl.tdRuby(name));
      }
    }
  }
}
