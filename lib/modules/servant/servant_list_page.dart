import 'dart:convert';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:chaldea/components/components.dart';
import 'package:chaldea/modules/item/item_list_page.dart';
import 'package:chaldea/modules/shared/filter_page.dart';
import 'package:chaldea/modules/shared/list_page_share.dart';

import 'servant_detail_page.dart';
import 'servant_filter_page.dart';

class ServantListPage extends StatefulWidget {
  final bool planMode;
  final void Function(Servant)? onSelected;

  ServantListPage({Key? key, this.planMode = false, this.onSelected})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => ServantListPageState();
}

class ServantListPageState
    extends SearchableListState<Servant, ServantListPage> {
  @override
  Iterable<Servant> get wholeData => db.gameData.servantsWithUser.values;

  Query __textFilter = Query();

  Set<Servant> hiddenPlanServants = {};

  SvtFilterData get filterData => db.userData.svtFilter;

  void onFilterChanged(SvtFilterData data) {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void initState() {
    super.initState();
    if (db.userData.autoResetFilter) {
      filterData.reset();
    }
    if (db.userData.favoritePreferred != null) {
      filterData.favorite = db.userData.favoritePreferred! ? 1 : 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    return db.streamBuilder((context) {
      this.filterShownList(
        compare: (a, b) => Servant.compare(a, b,
            keys: filterData.sortKeys,
            reversed: filterData.sortReversed,
            user: db.curUser),
      );
      return scrollListener(
        useGrid: widget.planMode ? false : filterData.useGrid,
        appBar: appBar,
      );
    });
  }

  PreferredSizeWidget? get appBar {
    return AppBar(
      title: AutoSizeText(
        widget.planMode
            ? '${S.current.plan} ${db.curUser.curSvtPlanNo + 1}'
            : S.of(context).servant,
        maxLines: 1,
        overflow: TextOverflow.fade,
      ),
      leading: MasterBackButton(),
      titleSpacing: 0,
      bottom: showSearchBar ? searchBar : null,
      actions: <Widget>[
        IconButton(
            icon: Icon([
              Icons.remove_circle_outline,
              Icons.favorite,
              Icons.favorite_border
            ][filterData.favorite % 3]),
            tooltip: ['All', 'Favorite', 'Others'][filterData.favorite % 3],
            onPressed: () {
              setState(() {
                filterData.favorite = (filterData.favorite + 1) % 3;
              });
            }),
        IconButton(
          icon: Icon(Icons.filter_alt),
          tooltip: S.current.filter,
          onPressed: () => FilterPage.show(
              context: context,
              builder: (context) => ServantFilterPage(
                  filterData: filterData, onChanged: onFilterChanged)),
        ),
        searchIcon,
        PopupMenuButton(
          itemBuilder: (context) {
            return [
              PopupMenuItem(
                  value: 'switch_plan', child: Text(S.of(context).select_plan)),
              if (widget.planMode)
                PopupMenuItem(
                    value: 'copy_plan',
                    child: Text(S.of(context).copy_plan_menu)),
              if (widget.planMode)
                PopupMenuItem(value: 'help', child: Text(S.current.help)),
            ];
          },
          onSelected: (v) {
            if (v == 'copy_plan') {
              copyPlan();
            } else if (v == 'switch_plan') {
              onSwitchPlan(
                context: context,
                onChange: (index) {
                  db.curUser.curSvtPlanNo = index;
                  db.curUser.ensurePlanLarger();
                  db.itemStat.updateSvtItems();
                },
              );
            } else if (v == 'help') {
              SimpleCancelOkDialog(
                title: Text(S.current.help),
                scrollable: true,
                content: Text(LocalizedText.of(
                  chs: """1.规划列表页与从者列表页相似，但主要用于<批量>设置从者<目标>练度(灵基/技能/灵衣)
2.仅更改列表中"已显示"的从者
3.通过筛选/搜索功能筛选显示列表，通过每行尾部的显示按钮可以单独隐藏/显示特定从者""",
                  jpn:
                      """1.プランページはサーヴァントページに似ていますが、主にサーヴァントの目標レベルを一律に設定するために使用されます（霊基再臨/スキル/霊衣）
2.リストで「表示」されているサーヴァントのみを変更します
3.フィルター/検索機能で表示リストをフィルターし、各行の表示ボタンで特定のサーヴァントを個別に表示/非表示にすることができます """,
                  eng:
                      """1. The plan page is similar to servant list page, but it is mainly used for <uniformly> setting the <target> value of servant ascension/skills/costumes
2. Only change the servants who are "shown" in the list
3. Filter the display list through the filter/search function, and you can hide/show specific servants individually through the display button at the end of each line""",
                )),
              ).showDialog(context);
            }
          },
        ),
      ],
    );
  }

  Map<Servant, String> searchMap = {};

  void _onTapSvt(Servant svt) {
    if (widget.onSelected != null) {
      widget.onSelected!(svt);
    } else {
      SplitRoute.push(
        context,
        ServantDetailPage(svt),
        popDetail: true,
      );
      selected = svt;
    }
    setState(() {});
  }

  Widget _getDetailTable(Servant svt) {
    ServantStatus status = db.curUser.svtStatusOf(svt.no);
    ServantPlan cur = status.curVal, target = db.curUser.svtPlanOf(svt.no);
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

    if (!status.favorite) {
      return Center(child: Text(S.of(context).svt_not_planned));
    }
    if (hiddenPlanServants.contains(svt)) {
      return Center(child: Text(S.of(context).svt_plan_hidden));
    }
    cur.fixDressLength(svt.costumeNos.length);
    target.fixDressLength(svt.costumeNos.length);
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
          if (cur.dress.isNotEmpty)
            for (int row = 0; row < cur.dress.length / 3; row++)
              TableRow(
                children: [
                  _getHeader(S.of(context).costume + ':'),
                  ...List.generate(3, (col) {
                    final dressIndex = row * 3 + col;
                    if (dressIndex >= cur.dress.length)
                      return Container();
                    else
                      return _getRange(
                          cur.dress[dressIndex], target.dress[dressIndex]);
                  })
                ],
              ),
        ],
      ),
    );
  }

  bool isSvtFavorite(Servant svt) {
    return db.curUser.svtStatusOf(svt.no).favorite;
  }

  int? _planTargetAscension;
  int? _planTargetSkill;
  int? _planTargetDress;

  @override
  bool filter(String keyword, Servant svt) {
    // input text filter
    if (keyword.isNotEmpty && searchMap[svt] == null) {
      List<String> searchStrings = [
        svt.no.toString(),
        svt.mcLink,
        ...Utils.getSearchAlphabets(
            svt.info.name, svt.info.nameJp, svt.info.nameEn),
        ...Utils.getSearchAlphabetsForList(svt.info.nicknames),
        ...Utils.getSearchAlphabetsForList(
            svt.info.cv, svt.info.cvJp, svt.info.cvEn),
        ...Utils.getSearchAlphabets(svt.info.illustrator,
            svt.info.illustratorJp, svt.info.illustratorEn),
        ...svt.info.traits
      ];
      [...svt.nobelPhantasm, ...svt.nobelPhantasmEn].forEach((td) {
        searchStrings.addAll([
          td.name,
          td.nameJp ?? '',
          td.upperName,
          td.upperNameJp ?? '',
          for (var e in td.effects) e.description
        ]);
      });
      [...svt.activeSkills, ...svt.activeSkillsEn].forEach((activeSkill) {
        activeSkill.skills.forEach((skill) {
          searchStrings.addAll([
            skill.name,
            skill.nameJp ?? '',
            for (var e in skill.effects) e.description
          ]);
        });
      });
      [...svt.passiveSkills, ...svt.passiveSkillsEn].forEach((skill) {
        searchStrings.addAll([
          skill.name,
          skill.nameJp ?? '',
          for (var e in skill.effects) e.description
        ]);
      });
      searchMap[svt] = searchStrings.toSet().join('\t');
    }
    if (keyword.isNotEmpty) {
      __textFilter.parse(keyword);
      if (!__textFilter.match(searchMap[svt]!)) {
        return false;
      }
    }

    /// In search mode, filters and favorite are ignored
    final svtStat = db.curUser.svtStatusOf(svt.no);
    final svtPlan = db.curUser.svtPlanOf(svt.no);
    if ((filterData.favorite == 1 && !svtStat.favorite) ||
        (filterData.favorite == 2 && svtStat.favorite)) {
      return false;
    }
    if (filterData.hasDress) {
      if (svt.costumeNos.isEmpty) {
        return false;
      }
    }
    if (!filterData.svtDuplicated
        .singleValueFilter(svt.originNo == svt.no ? '1' : '2')) {
      return false;
    }
    if (filterData.planCompletion.options.containsValue(true)) {
      if (!svtStat.favorite) return false;
      bool planNotComplete = <bool>[
        svtPlan.ascension > svtStat.curVal.ascension,
        svtPlan.grail > svtStat.curVal.grail,
        for (var i = 0; i < 3; i++)
          svtPlan.skills[i] > svtStat.curVal.skills[i],
        svtPlan.fouHp > svtStat.curVal.fouHp,
        svtPlan.fouAtk > svtStat.curVal.fouAtk,
        for (var i = 0;
            i < min(svtPlan.dress.length, svtStat.curVal.dress.length);
            i++)
          svtPlan.dress[i] > svtStat.curVal.dress[i]
      ].contains(true);
      if (filterData.planCompletion.options[planNotComplete ? '0' : '1'] !=
          true) return false;
    }
    // svt data filter
    // skill level
    if (filterData.skillLevel.options.containsValue(true)) {
      final curSvtState = svtStat.curVal;
      if (!svtStat.favorite) return false;
      int lowestSkill = curSvtState.skills.reduce((a, b) => min(a, b));
      if (!filterData.skillLevel.singleValueFilter(
          SvtFilterData.skillLevelData[max(lowestSkill - 8, 0)])) {
        return false;
      }
    }
    // class name
    if (!filterData.className.singleValueFilter(svt.stdClassName)) {
      return false;
    }
    // single value
    Map<FilterGroupData, String?> singleValuePair = {
      filterData.priority: svtStat.priority.toString(),
      filterData.rarity: svt.info.rarity.toString(),
      filterData.obtain: svt.info.obtain,
      filterData.npColor: svt.nobelPhantasm.getOrNull(0)?.color,
      filterData.npType: svt.nobelPhantasm.getOrNull(0)?.category,
      filterData.attribute: svt.info.attribute,
    };
    for (var entry in singleValuePair.entries) {
      if (!entry.key.singleValueFilter(entry.value)) {
        return false;
      }
    }
    //alignments
    if (!filterData.alignment1.listValueFilter(svt.info.alignments) ||
        !filterData.alignment2.listValueFilter(svt.info.alignments)) {
      return false;
    }
    // gender
    if (!filterData.gender.singleValueFilter(svt.info.gender, compares: {
      '其他': (optionKey, value) =>
      value != SvtFilterData.genderData[0] &&
          value != SvtFilterData.genderData[1]
    })) {
      return false;
    }
    // trait
    if (!filterData.trait.listValueFilter(
      svt.info.traits,
      defaultCompare: (o, v) => v?.contains(o) ?? false,
      compares: {
        '天地(拟似除外)': (o, v) => !svt.info.isTDNS,
        'EA不特攻': (o, v) => !svt.info.isWeakToEA,
      },
    )) {
      return false;
    }
    bool _matchNPCharge(List<Effect> effects) {
      String string =
          effects.map((e) => e.description).join('\t').toUpperCase();
      // print(string);
      //182->
      final keys = [
        RegExp(r'NP[^\s获]{0,3}增加'),
        RegExp(r'每回合([^\s]*?)NP(?!获)'),
        RegExp(r'增加([^\s]*?)NP(?!获)'),
        RegExp(r'吸收([^\s]*?)NP')
      ];
      bool result = keys.any((e) => string.contains(e));
      return result;
    }

    if (!filterData.special.listValueFilter(
      [''],
      compares: {
        '充能(技能)': (o, v) {
          List<Effect> effects = [];
          for (var active in svt.activeSkills) {
            for (var skill in active.skills) {
              effects.addAll(skill.effects);
            }
          }
          return _matchNPCharge(effects);
        },
        '充能(宝具)': (o, v) {
          List<Effect> effects = [];
          for (var np in svt.nobelPhantasm) {
            effects.addAll(np.effects);
          }
          return _matchNPCharge(effects);
        },
      },
    )) {
      return false;
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
    return Scrollbar(
      controller: scrollController,
      child: useGrid
          ? buildGridView()
          : buildListView(topHint: hintText, bottomHint: hintText),
    );
  }

  @override
  Widget gridItemBuilder(Servant svt) {
    final status = db.curUser.svtStatusOf(svt.no);
    Widget Function(TextStyle)? textBuilder;
    if (status.favorite) {
      textBuilder = (style) {
        return RichText(
          text: TextSpan(text: '', style: style, children: [
            WidgetSpan(
              style: style,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(6),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.white,
                      blurRadius: 3,
                      spreadRadius: 1,
                    )
                  ],
                ),
                child: db.getIconImage('宝具强化', width: 13, height: 13),
              ),
            ),
            TextSpan(text: status.npLv.toString()),
            TextSpan(
                text: '\n${status.curVal.ascension}-' +
                    status.curVal.skills.join('/'))
          ]),
        );
      };
    }
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 3, horizontal: 3),
      child: AspectRatio(
        aspectRatio: 132 / 144,
        child: ImageWithText(
          image: db.getIconImage(svt.icon),
          shadowSize: 4,
          textBuilder: textBuilder,
          textStyle: TextStyle(fontSize: 11, color: Colors.black),
          shadowColor: Colors.white,
          alignment: AlignmentDirectional.bottomStart,
          padding: EdgeInsets.fromLTRB(2, 0, 0, 2),
          onTap: () => _onTapSvt(svt),
        ),
      ),
    );
  }

  @override
  Widget listItemBuilder(Servant svt) {
    return widget.planMode
        ? _planListItemBuilder(svt)
        : _usualListItemBuilder(svt);
  }

  @override
  PreferredSizeWidget? get buttonBar {
    if (!widget.planMode) return null;

    final buttons = [
      DropdownButton<int>(
        value: _planTargetAscension,
        icon: Container(),
        hint: Text(S.of(context).ascension),
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
            _planTargetAscension = v;
            if (_planTargetAscension == null) return;
            shownList.forEach((svt) {
              if (isSvtFavorite(svt) && !hiddenPlanServants.contains(svt)) {
                final cur = db.curUser.svtStatusOf(svt.no).curVal,
                    target = db.curUser.svtPlanOf(svt.no);
                target.ascension = max(cur.ascension, _planTargetAscension!);
              }
            });
          });
        },
      ),
      DropdownButton<int>(
        value: _planTargetSkill,
        icon: Container(),
        hint: Text(S.of(context).skill),
        items: List.generate(11, (i) {
          if (i == 0) {
            return DropdownMenuItem(value: i, child: Text('x + 1'));
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
            _planTargetSkill = v;
            if (_planTargetSkill == null) return;
            shownList.forEach((svt) {
              if (isSvtFavorite(svt) && !hiddenPlanServants.contains(svt)) {
                final cur = db.curUser.svtStatusOf(svt.no).curVal,
                    target = db.curUser.svtPlanOf(svt.no);
                for (int i = 0; i < 3; i++) {
                  if (v == 0) {
                    target.skills[i] = min(10, cur.skills[i] + 1);
                  } else {
                    target.skills[i] = max(cur.skills[i], _planTargetSkill!);
                  }
                }
              }
            });
          });
        },
      ),
      DropdownButton<int>(
        value: _planTargetDress,
        icon: Container(),
        hint: Text(S.of(context).costume),
        items: List.generate(
            2,
                (i) => DropdownMenuItem(
                value: i, child: Text(S.of(context).costume + ['×', '√'][i]))),
        onChanged: (v) {
          setState(() {
            _planTargetDress = v;
            if (_planTargetDress == null) return;
            shownList.forEach((svt) {
              if (isSvtFavorite(svt) && !hiddenPlanServants.contains(svt)) {
                final cur = db.curUser.svtStatusOf(svt.no).curVal,
                    target = db.curUser.svtPlanOf(svt.no);
                for (int i = 0; i < target.dress.length; i++) {
                  target.dress[i] = max(cur.dress[i], _planTargetDress!);
                }
              }
            });
          });
        },
      ),
      ElevatedButton(
        onPressed: () {
          db.itemStat.updateSvtItems();
          SplitRoute.push(
            context,
            ItemListPage(),
            detail: false,
          );
        },
        child: Text('→' + S.of(context).item),
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
            child: ButtonBar(children: buttons),
          ),
        ),
      ),
      preferredSize: Size.fromHeight(48),
    );
  }

  Widget _usualListItemBuilder(Servant svt) {
    final status = db.curUser.svtStatusOf(svt.no);
    Widget? statusText;
    if (status.favorite) {
      statusText = Column(
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
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // db.getIconImage('技能强化', width: 16, height: 16),
              Text(status.curVal.ascension.toString() + '-'),
              Text(status.curVal.skills.join('/')),
            ],
          ),
          if (status.curVal.dress.isNotEmpty)
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                db.getIconImage('灵衣开放权', width: 16, height: 16),
                Text(status.curVal.dress.join('/')),
              ],
            ),
        ],
      );
      statusText = DefaultTextStyle(
        style: TextStyle(color: Colors.grey, fontSize: 14),
        child: statusText,
      );
    }
    String additionalText = '';
    switch (filterData.sortKeys.first) {
      case SvtCompare.atk:
        additionalText = '  ATK ${svt.info.atkMax}';
        break;
      case SvtCompare.hp:
        additionalText = '  HP ${svt.info.hpMax}';
        break;
      default:
        break;
    }
    return CustomTile(
      leading: db.getIconImage(svt.icon, width: 56),
      title: AutoSizeText(
        svt.info.localizedName,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          if (!Language.isJP) AutoSizeText(svt.info.nameJp, maxLines: 1),
          Text('No.${svt.no} ${svt.info.className}  $additionalText')
        ],
      ),
      trailing: statusText,
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
          if (_hidden)
            hiddenPlanServants.remove(svt);
          else
            hiddenPlanServants.add(svt);
        });
      },
    );

    return CustomTile(
      leading: db.getIconImage(svt.icon, width: 48),
      subtitle: _getDetailTable(svt),
      trailing: eyeWidget,
      selected: SplitRoute.isSplit(context) && selected == svt,
      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 3),
      onTap: () => _onTapSvt(svt),
    );
  }

  void copyPlan() {
    showDialog(
      context: context,
      builder: (context) => SimpleDialog(
        title: Text(S.of(context).select_copy_plan_source),
        children: List.generate(db.curUser.servantPlans.length, (index) {
          bool isCur = index == db.curUser.curSvtPlanNo;
          return ListTile(
            title: Text(S.of(context).plan_x(index + 1) +
                ' ' +
                (isCur ? '(${S.current.current_})' : '')),
            onTap: isCur
                ? null
                : () {
                    db.curUser.curSvtPlan.clear();
                    db.curUser.servantPlans[index].forEach((key, plan) {
                      db.curUser.curSvtPlan[key] =
                          ServantPlan.fromJson(jsonDecode(jsonEncode(plan)));
                    });
                    db.curUser.ensurePlanLarger();
                    Navigator.of(context).pop();
                  },
          );
        }),
      ),
    );
  }
}
