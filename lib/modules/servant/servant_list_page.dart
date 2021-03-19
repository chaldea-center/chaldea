import 'dart:convert';
import 'dart:math';
import 'dart:ui';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:chaldea/components/components.dart';
import 'package:chaldea/modules/item/item_list_page.dart';
import 'package:chaldea/modules/shared/filter_page.dart';
import 'package:chaldea/modules/shared/list_page_share.dart';
import 'package:flutter/cupertino.dart';

import 'servant_detail_page.dart';
import 'servant_filter_page.dart';

class ServantListPage extends StatefulWidget {
  final bool planMode;

  ServantListPage({Key? key, this.planMode = false}) : super(key: key);

  @override
  State<StatefulWidget> createState() => ServantListPageState();
}

class ServantListPageState extends State<ServantListPage> {
  SvtFilterData get filterData => db.userData.svtFilter;
  Set<Servant> hiddenPlanServants = {};
  late TextEditingController _inputController;
  late FocusNode _inputFocusNode;
  late ScrollController _scrollController;

  //temp, calculate once build() called.
  Query __textFilter = Query();

  @override
  void initState() {
    super.initState();
    filterData.filterString = '';
    filterData.favorite = widget.planMode ? 1 : 0;
    _inputController = TextEditingController();
    _scrollController = ScrollController();
    _inputFocusNode = FocusNode();
  }

  @override
  void dispose() {
    _inputController.dispose();
    _scrollController.dispose();
    _inputFocusNode.dispose();
    super.dispose();
  }

  @override
  void deactivate() {
    super.deactivate();
  }

  void beforeFiltrate() {
    __textFilter.parse(filterData.filterString);
  }

  bool filtrateServant(Servant svt) {
    final svtStat = db.curUser.svtStatusOf(svt.no);
    final svtPlan = db.curUser.svtPlanOf(svt.no);
    // input text filter
    if (filterData.filterString.trim().isNotEmpty) {
      List<String> searchStrings = [
        svt.no.toString(),
        svt.mcLink,
        ...svt.info.cv,
        svt.info.name,
        svt.info.nameJp,
        svt.info.illustrator,
        ...svt.info.nicknames,
        ...svt.info.traits
      ];
      svt.nobelPhantasm.forEach((td) {
        searchStrings.addAll([
          td.name,
          td.nameJp,
          td.upperName,
          td.upperNameJp,
          for (var e in td.effects) e.description
        ]);
      });
      svt.activeSkills.forEach((activeSkill) {
        activeSkill.skills.forEach((skill) {
          searchStrings.addAll([
            skill.name,
            skill.nameJp ?? '',
            for (var e in skill.effects) e.description
          ]);
        });
      });
      if (!__textFilter.match(searchStrings.join('\t'))) {
        return false;
      }
    }
    if (filterData.hasDress) {
      if ((svt.itemCost.dressName.length) <= 0) {
        return false;
      }
    }
    if (filterData.planCompletion.options.containsValue(true)) {
      if (svtStat.curVal.favorite != true) return false;
      bool planNotComplete = <bool>[
        svtPlan.ascension > svtStat.curVal.ascension,
        svtPlan.grail > svtStat.curVal.grail,
        for (var i = 0; i < 3; i++)
          svtPlan.skills[i] > svtStat.curVal.skills[i],
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
      if (curSvtState.favorite != true) return false;
      int lowestSkill = curSvtState.skills.reduce((a, b) => min(a, b));
      if (!filterData.skillLevel.singleValueFilter(
          SvtFilterData.skillLevelData[max(lowestSkill - 8, 0)])) {
        return false;
      }
    }
    // class name
    if (!filterData.className.singleValueFilter(svt.info.className, compares: {
      'Beast': (o, v) => v?.startsWith(o) ?? false,
      'Caster': (o, v) => v?.contains(o) ?? false
    })) {
      return false;
    }
    // single value
    Map<FilterGroupData, String?> singleValuePair = {
      filterData.priority: svtStat.priority.toString(),
      filterData.rarity: svt.info.rarity.toString(),
      filterData.obtain: svt.info.obtain,
      filterData.npColor: getListItem(svt.nobelPhantasm, 0)?.color,
      filterData.npType: getListItem(svt.nobelPhantasm, 0)?.category,
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
    if (!filterData.trait.listValueFilter(svt.info.traits, compares: {
      '魔性': (o, v) => v?.startsWith(o) ?? false,
      '超巨大': (o, v) => v?.startsWith(o) ?? false,
      '天地(拟似除外)': (o, v) => !svt.info.isTDNS,
      'EA不特攻': (o, v) => !svt.info.isWeakToEA,
      '无特殊特性': (o, v) => svt.info.traits.isEmpty,
    })) {
      return false;
    }
    // traitSpecial
    final a = SvtFilterData.traitSpecialData;
    if (filterData.traitSpecial.options.containsValue(true) &&
        !(filterData.traitSpecial.options[a[0]] == true &&
            !svt.info.isWeakToEA) &&
        !(filterData.traitSpecial.options[a[1]] == true &&
            svt.info.traits.isEmpty)) {
      return false;
    }
    return true;
  }

  void onFilterChanged(SvtFilterData data) {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return db.streamBuilder(
      (context) => Scaffold(
        appBar: AppBar(
          title: Text(widget.planMode
              ? '${S.current.plan} ${db.curUser.curSvtPlanNo + 1}'
              : S.of(context).servant),
          leading: MasterBackButton(),
          bottom: PreferredSize(
            preferredSize: Size.fromHeight(45),
            child: Theme(
              data: Theme.of(context).copyWith(primaryColor: Colors.grey),
              child: Container(
                  height: 45,
                  padding: EdgeInsets.fromLTRB(10, 0, 10, 10),
                  child: TextField(
                    focusNode: _inputFocusNode,
                    controller: _inputController,
                    style: TextStyle(fontSize: 14),
                    decoration: InputDecoration(
                        isDense: true,
                        filled: true,
                        contentPadding: EdgeInsets.zero,
                        border: OutlineInputBorder(
                            borderSide: const BorderSide(
                                width: 0, style: BorderStyle.none),
                            borderRadius:
                                BorderRadius.all(Radius.circular(10))),
                        fillColor: Colors.white,
                        hintText: 'Search',
                        prefixIcon: Icon(Icons.search, size: 20),
                        suffixIcon: IconButton(
                          padding: EdgeInsets.zero,
                          icon: Icon(Icons.clear, size: 20),
                          onPressed: () {
                            setState(() {
                              WidgetsBinding.instance!.addPostFrameCallback(
                                  (_) => _inputController.clear());
                              filterData.filterString = '';
                            });
                          },
                        )),
                    onChanged: (s) {
                      setState(() {
                        filterData.filterString = s;
                      });
                    },
                    onSubmitted: (s) {
                      FocusScope.of(context).unfocus();
                    },
                  )),
            ),
          ),
          actions: <Widget>[
            IconButton(
                icon: Icon([
                  Icons.remove_circle_outline,
                  Icons.favorite,
                  Icons.favorite_border
                ][filterData.favorite]),
                tooltip: ['All', 'Favorite', 'Others'][filterData.favorite],
                onPressed: () {
                  setState(() {
                    filterData.favorite = (filterData.favorite + 1) % 3;
                  });
                }),
            IconButton(
              icon: Icon(Icons.filter_alt),
              tooltip: S.of(context).filter,
              onPressed: () => FilterPage.show(
                  context: context,
                  builder: (context) => ServantFilterPage(
                      filterData: filterData, onChanged: onFilterChanged)),
            ),
            PopupMenuButton(
              itemBuilder: (context) {
                return [
                  PopupMenuItem(
                      value: 'switch_plan',
                      child: Text(S.of(context).select_plan)),
                  if (widget.planMode)
                    PopupMenuItem(
                        value: 'copy_plan',
                        child: Text(S.of(context).copy_plan_menu)),
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
                }
              },
            ),
          ],
        ),
        floatingActionButton: widget.planMode
            ? null
            : FloatingActionButton(
                child: Icon(Icons.arrow_upward),
                onPressed: () {
                  _scrollController.jumpTo(0);
                },
              ),
        body: buildOverview(),
      ),
    );
  }

  List<Servant> shownList = [];

  Widget buildOverview() {
    db.curUser.ensurePlanLarger();
    shownList = [];
    beforeFiltrate();
    db.gameData.servantsWithUser.forEach((no, svt) {
      if (filterData.favorite == 0 ||
          filterData.favorite ==
              ((db.curUser.svtStatusOf(no).curVal.favorite) ? 1 : 2)) {
        if (filtrateServant(svt)) {
          shownList.add(svt);
        }
      }
    });
    shownList.sort((a, b) => Servant.compare(a, b,
        keys: filterData.sortKeys,
        reversed: filterData.sortReversed,
        user: db.curUser));
    return Scrollbar(
      controller: _scrollController,
      child: widget.planMode
          ? _buildPlanListView()
          : filterData.useGrid
              ? _buildGridView()
              : _buildListView(),
    );
  }

  Widget _buildListView() {
    return ListView.separated(
      controller: _scrollController,
      separatorBuilder: (context, index) => Divider(height: 1, indent: 16),
      itemCount: shownList.length + (shownList.isEmpty ? 1 : 2),
      itemBuilder: (context, index) {
        if (index == 0 || index == shownList.length + 1) {
          return CustomTile(
            contentPadding:
                index == 0 ? null : EdgeInsets.only(top: 8, bottom: 50),
            subtitle: Center(
              child: Text(
                S.of(context).search_result_count(shownList.length),
                style: TextStyle(color: Colors.grey, fontSize: 14),
              ),
            ),
          );
        }
        final svt = shownList[index - 1];
        final status = db.curUser.svtStatusOf(svt.no);
        String statusText = '';
        if (status.curVal.favorite == true) {
          statusText =
              '${status.curVal.ascension}-' + status.curVal.skills.join('/');
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
          title: AutoSizeText(svt.info.localizedName, maxLines: 1),
          subtitle: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    if (!Language.isJP)
                      AutoSizeText(svt.info.nameJp, maxLines: 1),
                    Text('No.${svt.no} ${svt.info.className}  $additionalText')
                  ],
                ),
              ),
              Text(statusText),
            ],
          ),
          // trailing: Icon(Icons.arrow_forward_ios),
          onTap: () {
            SplitRoute.push(
              context: context,
              builder: (context, _) => ServantDetailPage(svt),
              popDetail: true,
            );
          },
        );
      },
    );
  }

  Widget _buildGridView() {
    // make sure the floating button not cover svt icon
    List<Widget> children = [];
    for (var svt in shownList) {
      final status = db.curUser.svtStatusOf(svt.no);
      String? statusText;
      if (status.curVal.favorite) {
        statusText = '${status.npLv}\n'
            '${status.curVal.ascension}-'
            '${status.curVal.skills[0]}/'
            '${status.curVal.skills[1]}/'
            '${status.curVal.skills[2]}';
      }
      children.add(Center(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 2, horizontal: 2),
          child: ImageWithText(
            image: db.getIconImage(svt.icon),
            text: statusText,
            fontSize: 11,
            alignment: AlignmentDirectional.bottomStart,
            padding: EdgeInsets.fromLTRB(4, 0, 8, 0),
            onTap: () {
              SplitRoute.push(
                context: context,
                builder: (context, _) => ServantDetailPage(svt),
                popDetail: true,
              );
            },
          ),
        ),
      ));
    }
    if (children.length % 5 == 0) {
      children.add(Container());
    }
    return GridView.count(
      crossAxisCount: 5,
      childAspectRatio: 1,
      controller: _scrollController,
      padding: EdgeInsets.symmetric(horizontal: 4, vertical: 6),
      children: children,
    );
  }

  Widget _buildPlanListView() {
    return Column(
      children: [
        Expanded(
          child: ListView.separated(
            controller: _scrollController,
            separatorBuilder: (context, index) => kDefaultDivider,
            itemCount: shownList.length + (shownList.isEmpty ? 1 : 2),
            itemBuilder: (context, index) {
              if (index == 0 || index == shownList.length + 1) {
                int _hiddenNum = shownList
                    .where((e) => hiddenPlanServants.contains(e))
                    .length;
                return CustomTile(
                  contentPadding:
                      index == 0 ? null : EdgeInsets.only(top: 8, bottom: 36),
                  subtitle: Center(
                    child: Text(
                      widget.planMode
                          ? S.of(context).search_result_count_hide(
                              shownList.length, _hiddenNum)
                          : S.of(context).search_result_count(shownList.length),
                      style: TextStyle(color: Colors.grey, fontSize: 14),
                    ),
                  ),
                );
              }
              final svt = shownList[index - 1];
              final _hidden = hiddenPlanServants.contains(svt);
              final eyeWidget = GestureDetector(
                child: Icon(
                  Icons.remove_red_eye,
                  color:
                      isSvtFavorite(svt) && !_hidden ? Colors.lightBlue : null,
                ),
                onTap: () {
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
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 16, vertical: 3),
                onTap: () {
                  SplitRoute.push(
                    context: context,
                    builder: (context, _) => ServantDetailPage(svt),
                    popDetail: true,
                  );
                },
              );
            },
          ),
        ),
        _buildButtonBar(),
      ],
    );
  }

  Widget _getDetailTable(Servant svt) {
    ServantPlan cur = db.curUser.svtStatusOf(svt.no).curVal,
        target = db.curUser.svtPlanOf(svt.no);
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

    if (cur.favorite != true) {
      return Center(child: Text(S.of(context).svt_not_planned));
    }
    if (hiddenPlanServants.contains(svt)) {
      return Center(child: Text(S.of(context).svt_plan_hidden));
    }
    cur.fixDressLength(svt.itemCost.dress.length);
    target.fixDressLength(svt.itemCost.dress.length);
    return DefaultTextStyle(
      style: TextStyle(
        fontSize: 12,
        color: Colors.black54,
        fontFamily: 'RobotoMono',
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
                  _getHeader(S.of(context).dress + ':'),
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
    return db.curUser.svtStatusOf(svt.no).curVal.favorite;
  }

  int? _planTargetAscension;
  int? _planTargetSkill;
  int? _planTargetDress;

  Widget _buildButtonBar() {
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
        hint: Text(S.of(context).dress),
        items: List.generate(
            2,
            (i) => DropdownMenuItem(
                value: i, child: Text(S.of(context).dress + ['×', '√'][i]))),
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
            context: context,
            builder: (context, _) => ItemListPage(),
            detail: false,
          );
        },
        child: Text('→' + S.of(context).item),
      ),
    ];
    return Container(
      decoration: BoxDecoration(
          border: Border(top: Divider.createBorderSide(context, width: 0.5))),
      child: Align(
        alignment: Alignment.center,
        child: FittedBox(
          fit: BoxFit.contain,
          child: ButtonBar(children: buttons),
        ),
      ),
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
