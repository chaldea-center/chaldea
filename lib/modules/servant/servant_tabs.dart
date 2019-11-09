import 'package:auto_size_text/auto_size_text.dart';
import 'package:chaldea/components/components.dart';
import 'package:chaldea/components/custom_tile.dart';
import 'package:chaldea/components/tile_items.dart';
import 'package:chaldea/modules/servant/servant_detail.dart';
import 'package:flutter/material.dart';

class LevelUpCostPage extends StatefulWidget {
  final List<List<Item>> costList;
  final int curLv;
  final int targetLv;
  final String title;

  const LevelUpCostPage(
      {Key key,
      @required this.costList,
      this.curLv = 0,
      this.targetLv = 0,
      this.title = ''})
      : assert(curLv <= targetLv),
        super(key: key);

  @override
  State<StatefulWidget> createState() => LevelUpCostPageState();
}

class LevelUpCostPageState extends State<LevelUpCostPage> {
  bool showAll = false;

  Widget buildOneLevel(String title, List<Item> lvCost) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 3),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          CustomTile(
            title: Text(title),
            contentPadding: EdgeInsets.zero,
          ),
          GridView.count(
            crossAxisCount: 6,
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            children: lvCost
                .map((item) => ImageWithText(
                      image: Image.file(db.getIconFile(item.name)),
                      text: formatNumToString(item.num, 'kilo'),
                      padding: EdgeInsets.only(right: 3),
                    ))
                .toList(),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final int offset = widget.costList.length == 9 ? -1 : 0;
    final bool _showAll = showAll || widget.curLv >= widget.targetLv;
    final int lva = _showAll ? 0 : widget.curLv + offset,
        lvb = _showAll ? widget.costList.length : widget.targetLv + offset;
    assert(0 <= lva && lvb <= widget.costList.length);
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        centerTitle: true,
        actions: <Widget>[
          IconButton(
              icon: Icon(showAll ? Icons.pie_chart_outlined : Icons.pie_chart),
              onPressed: () {
                showAll = !showAll;
                setState(() {});
              })
        ],
      ),
      body: ListView(
        children: List.generate(lvb - lva, (i) {
          return buildOneLevel(
            'Lv.${lva + i - offset} → Lv.${lva + i - offset + 1}',
            widget.costList[lva + i],
          );
        }),
      ),
    );
  }
}

class PlanTab extends StatefulWidget {
  final ServantDetailPageState parent;
  final Servant svt;
  final ServantPlan plan;

  PlanTab({Key key, this.parent, this.svt, this.plan}) : super(key: key);

  @override
  State<StatefulWidget> createState() =>
      _PlanTabState(parent: this.parent, svt: this.svt, plan: this.plan);
}

class _PlanTabState extends State<PlanTab> with AutomaticKeepAliveClientMixin {
  Servant svt;
  ServantPlan plan;

  _PlanTabState(
      {ServantDetailPageState parent, Servant svt, ServantPlan plan}) {
    this.svt = svt ?? parent?.svt;
    assert(this.svt != null);
    this.plan = plan ?? widget.parent?.plan ?? ServantPlan();
  }

  @override
  void initState() {
    super.initState();
  }

  Widget buildPlanRow(
      {Widget leading,
      String title,
      String subtitle,
      @required IntRangeValues value,
      @required IntRangeValues range,
      void onRangeChanged(int s, int e),
      WidgetBuilder detailPageBuilder}) {
    assert(value != null && range != null);
    return CustomTile(
      contentPadding: EdgeInsets.fromLTRB(16, 4, 0, 4),
      leading: leading,
      title: title == null ? null : AutoSizeText(title, maxLines: 1),
      subtitle: subtitle == null
          ? null
          : AutoSizeText(subtitle, maxLines: 1, minFontSize: 10),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          RangeSelector<int>(
            start: value.startInt,
            end: value.endInt,
            startItems: List.generate(
                range.nodeNum,
                (index) =>
                    MapEntry(range[index], Text(range[index].toString()))),
            endItems: List.generate(
                range.nodeNum,
                (index) =>
                    MapEntry(range[index], Text(range[index].toString()))),
            onChanged: onRangeChanged,
          ),
          IconButton(
            icon: Icon(Icons.info_outline, color: Colors.blueAccent),
            onPressed: () {
              if (detailPageBuilder != null) {
                showSheet(
                  context,
                  builder: (sheetContext, setSheetState) =>
                      detailPageBuilder(sheetContext),
                );
              }
            },
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    if (svt.activeSkills == null) {
      return Center(child: Text('Nothing'));
    }

    // ascension part
    List<Widget> children = [];
    if (svt.no != 1) {
      children.add(TileGroup(
        header: '灵基再临',
        tiles: <Widget>[
          buildPlanRow(
              title: '灵基再临',
              value: IntRangeValues.fromList(plan.ascensionLv),
              range: IntRangeValues(0, 4),
              onRangeChanged: (_start, _end) {
                plan.ascensionLv = [_start, _end];
                plan.favorite = true;
                widget.parent?.setState(() {});
              },
              detailPageBuilder: (context) => LevelUpCostPage(
                    costList: svt.itemCost.ascension,
                    title: '灵基再临',
                    curLv: plan.ascensionLv[0],
                    targetLv: plan.ascensionLv[1],
                  ))
        ],
      ));
    }

    //skill part
    List<Widget> skillWidgets = [];
    for (int index = 0; index < svt.activeSkills.length; index++) {
      List<Skill> skillList = svt.activeSkills[index];
      bool enhanced = plan.skillEnhanced[index] ?? skillList[0].enhanced;
      Skill skill = skillList[enhanced ? 1 : 0];
      skillWidgets.add(buildPlanRow(
          leading: Image.file(
            db.getIconFile(skill.icon),
            height: 110 * 0.3,
          ),
          title: '${skill.name} ${skill.rank}',
          value: IntRangeValues.fromList(plan.skillLv[index]),
          range: IntRangeValues(1, 10),
          onRangeChanged: (_start, _end) {
            plan.skillLv[index] = [_start, _end];
            plan.favorite = true;
            widget.parent?.setState(() {});
          },
          detailPageBuilder: (context) => LevelUpCostPage(
                costList: svt.itemCost.skill,
                title: '技能${index + 1} - ${skill.name}',
                curLv: plan.skillLv[index][0],
                targetLv: plan.skillLv[index][1],
              )));
    }
    children.add(TileGroup(header: '技能升级', tiles: skillWidgets));

    // dress part
    List<Widget> dressWidgets = [];
    for (int index = 0; index < svt.itemCost.dress.length; index++) {
      if (plan.dressLv.length <= index) {
        // dress number may increase in the future
        plan.dressLv.add([0, 0]);
      }
      dressWidgets.add(buildPlanRow(
          leading: Image.file(db.getIconFile('灵衣开放权'), height: 110 * 0.3),
          title: svt.itemCost.dressName[index],
          subtitle: svt.itemCost.dressNameJp[index],
          value: IntRangeValues.fromList(plan.dressLv[index]),
          range: IntRangeValues(0, 1),
          onRangeChanged: (_start, _end) {
            plan.dressLv[index] = [_start, _end];
            plan.favorite = true;
            widget.parent?.setState(() {});
          },
          detailPageBuilder: (context) => LevelUpCostPage(
                costList: [svt.itemCost.dress[index]],
                title: '灵衣开放 - ${svt.itemCost.dressName[index]}',
              )));
    }
    if (dressWidgets.length > 0) {
      children.add(TileGroup(header: '灵衣开放', tiles: dressWidgets));
    }
    return ListView(
      children: children,
    );
  }

  @override
  bool get wantKeepAlive => true;
}

class SkillTab extends StatefulWidget {
  final ServantDetailPageState parent;

  const SkillTab({Key key, this.parent}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _SkillTabState();
}

class _SkillTabState extends State<SkillTab>
    with AutomaticKeepAliveClientMixin {
  Servant svt;
  ServantPlan plan;

  _SkillTabState({this.svt, this.plan});

  @override
  void initState() {
    super.initState();
    svt ??= widget.parent?.svt;
    plan ??= widget.parent?.plan ?? ServantPlan();
    assert(svt != null);
  }

  List<Widget> buildSkill(int index) {
    List<Skill> skillList = svt.activeSkills[index];
    bool enhanced = plan.skillEnhanced[index] ?? skillList[0].enhanced;
    Skill skill = skillList[enhanced ? 1 : 0];

    return <Widget>[
      CustomTile(
          contentPadding: EdgeInsets.fromLTRB(16, 6, 22, 6),
          leading: Image.file(db.getIconFile(skill.icon), height: 110 * 0.3),
          title: Text('${skill.name} ${skill.rank}'),
          subtitle: Text('${skill.nameJp} ${skill.rank}'),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              if (skillList.length > 1)
                GestureDetector(
                  onTap: () {
                    widget.parent?.setState(() {
                      plan.skillEnhanced[index] = !enhanced;
                    });
                  },
                  child: Image.file(
                    db.getIconFile(enhanced ? '技能强化' : '技能未强化'),
                    height: 110 * 0.2,
                  ),
                ),
              Text('   CD: ${skill.cd}→${skill.cd - 2}')
            ],
          )),
      for (Effect effect in skill.effects) ...buildEffect(effect)
    ];
  }

  List<Widget> buildEffect(Effect effect) {
    bool twoLine = effect.lvData.length == 10;
    return <Widget>[
      CustomTile(
          contentPadding: EdgeInsets.fromLTRB(16, 6, 22, 6),
          subtitle: Text(effect.description),
          trailing: effect.lvData.length == 1
              ? Text(formatNumToString(effect.lvData[0], effect.valueType))
              : null),
      if (effect.lvData.length > 1)
        CustomTile(
            contentPadding:
                EdgeInsets.symmetric(vertical: 0.0, horizontal: 16.0),
            title: GridView.count(
              childAspectRatio: twoLine ? 3 : 6,
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              crossAxisCount: twoLine ? 5 : effect.lvData.length,
              children: effect.lvData.asMap().keys.map((index) {
                return Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    formatNumToString(effect.lvData[index], effect.valueType),
                    style: TextStyle(
                        fontSize: 13,
                        color:
                            [5, 9].contains(index) ? Colors.redAccent : null),
                  ),
                );
              }).toList(),
            )),
    ];
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    if (svt.activeSkills == null) {
      return Center(child: Text('Nothing'));
    }

    return ListView(children: [
      TileGroup(tiles: <Widget>[
        for (var index = 0; index < svt.activeSkills.length; index++)
          ...buildSkill(index)
      ])
    ]);
  }

  @override
  bool get wantKeepAlive => true;
}

class NobelPhantasmTab extends StatefulWidget {
  final ServantDetailPageState parent;

  const NobelPhantasmTab({Key key, this.parent}) : super(key: key);

  @override
  _NobelPhantasmTabState createState() => _NobelPhantasmTabState();
}

class _NobelPhantasmTabState extends State<NobelPhantasmTab>
    with AutomaticKeepAliveClientMixin {
  Servant svt;
  ServantPlan plan;

  _NobelPhantasmTabState({this.svt, this.plan});

  @override
  void initState() {
    super.initState();
    svt ??= widget.parent?.svt;
    plan ??= widget.parent?.plan ?? ServantPlan();
    assert(svt != null);
  }

  Widget buildHeader(NobelPhantasm np, bool enhanced) {
    return CustomTile(
      leading: Column(
        children: <Widget>[
          Image.file(
            db.getIconFile(np.color),
            height: 110 * 0.9,
          ),
          Text(
            '${np.typeText} ${np.rank}',
            style: TextStyle(fontSize: 14, color: Colors.black),
          )
        ],
      ),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            np.upperName,
            style: TextStyle(fontSize: 16, color: Colors.black54),
          ),
          Text(
            np.name,
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          Text(
            np.upperNameJp,
            style: TextStyle(fontSize: 16, color: Colors.black54),
          ),
          Text(
            np.nameJp,
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
        ],
      ),
      trailing: svt.nobelPhantasm.length <= 1
          ? null
          : GestureDetector(
              onTap: () {
                widget.parent?.setState(() {
                  plan.npEnhanced = !enhanced;
                });
              },
              child: Image.file(
                db.getIconFile(enhanced ? '宝具强化' : '宝具未强化'),
                height: 110 * 0.2,
              ),
            ),
    );
  }

  List<Widget> buildEffect(Effect effect) {
    assert([1, 5].contains(effect.lvData.length), '$effect');
    return <Widget>[
      CustomTile(
          contentPadding: EdgeInsets.fromLTRB(16, 6, 22, 6),
          subtitle: Text(effect.description),
          trailing: effect.lvData.length == 1
              ? Text(formatNumToString(effect.lvData[0], effect.valueType))
              : null),
      if (effect.lvData.length > 1)
        CustomTile(
            contentPadding:
                EdgeInsets.symmetric(vertical: 0.0, horizontal: 16.0),
            title: GridView.count(
              childAspectRatio: 2.5,
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              crossAxisCount: 5,
              children: List.generate(effect.lvData.length, (index) {
                return Align(
                  alignment: Alignment.center,
                  child: Text(
                    formatNumToString(effect.lvData[index], effect.valueType),
                    style: TextStyle(fontSize: 14),
                  ),
                );
              }),
            ))
    ];
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    if (svt.nobelPhantasm == null || svt.nobelPhantasm.length == 0) {
      return Container(child: Center(child: Text('No NobelPhantasm Data')));
    }
    bool enhanced = plan.npEnhanced ?? svt.nobelPhantasm.first.enhanced;
    final np = svt.nobelPhantasm[enhanced ? 1 : 0];
    return ListView(
      children: <Widget>[
        TileGroup(
          tiles: <Widget>[
            buildHeader(np, enhanced),
            for (Effect e in np.effects) ...buildEffect(e)
          ],
        )
      ],
    );
  }

  @override
  bool get wantKeepAlive => true;
}
