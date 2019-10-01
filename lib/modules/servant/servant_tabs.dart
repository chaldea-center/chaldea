import 'package:auto_size_text/auto_size_text.dart';
import 'package:chaldea/components/components.dart';
import 'package:chaldea/components/custom_tile.dart';
import 'package:chaldea/components/tile_items.dart';
import 'package:flutter/material.dart';


class ItemCostPage extends StatefulWidget {
  final List<List<Item>> costList;
  final int curLv;
  final int targetLv;
  final String title;

  const ItemCostPage({Key key,
    @required this.costList,
    this.curLv = 0,
    this.targetLv = 0,
    this.title = ''})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => ItemCostPageState();
}

class ItemCostPageState extends State<ItemCostPage> {
  bool showAll = false;

  @override
  Widget build(BuildContext context) {
    final bool isSkill = widget.costList.length == 9;
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
        children: widget.costList
            .asMap()
            .keys
            .map((index) {
              final lva = isSkill ? index + 1 : index,
                  lvb = isSkill ? index + 2 : index + 1;
              final lvCost = widget.costList[index];
              if (widget.curLv < widget.targetLv &&
                  !showAll &&
                  (lva < widget.curLv || lva >= widget.targetLv)) {
                return null;
              }
              return Padding(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 3),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    CustomTile(
                      title: Text('Lv.$lva → Lv.$lvb'),
                      contentPadding: EdgeInsets.zero,
                    ),
                    Wrap(
                        alignment: WrapAlignment.start,
                        spacing: 5,
                        children: lvCost
                            .map((item) => ItemUnit(
                          Image.file(db.getIconFile(item.name),
                                      width: 110 * 0.5),
                                  formatNumberToString(item.num, 'kilo'),
                                ))
                            .toList())
                  ],
                ),
              );
            })
            .where((e) => e != null)
            .toList(),
      ),
    );
  }
}

class PlanTab extends StatefulWidget {
  final Servant svt;
  final VoidCallback updateParent;
  final ServantPlan plan;

  const PlanTab(this.svt, {Key key, this.updateParent, this.plan})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => PlanTabState(plan);
}

class PlanTabState extends State<PlanTab> with AutomaticKeepAliveClientMixin {
  ServantPlan svtPlan;

  @override
  void initState() {
    super.initState();
    svtPlan = svtPlan ?? ServantPlan();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    if (widget.svt.activeSkills == null) {
      return Center(
        child: Text('Nothing'),
      );
    }

    // ascension part
    List<Widget> children = [];
    if (widget.svt.no != 1) {
      children.add(TileGroup(
        header: '灵基再临',
        tiles: <Widget>[
          CustomTile(
            title: Text('灵基再临'),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                RangeSelector<int>(
                  start: svtPlan.ascensionLv[0],
                  end: svtPlan.ascensionLv[1],
                  startItems: List.generate(
                      5, (index) => MapEntry(index, Text(index.toString()))),
                  endItems: List.generate(
                      5, (index) => MapEntry(index, Text(index.toString()))),
                  onChanged: (start, end) {
                    svtPlan.ascensionLv = [start, end];
                    svtPlan.favorite = true;
                    widget?.updateParent();
                    setState(() {});
                  },
                ),
                IconButton(
                  icon: Icon(Icons.info_outline, color: Colors.blueAccent),
                  onPressed: () {
                    showSheet(
                      context,
                      builder: (sheetContext, setSheetState) =>
                          ItemCostPage(
                              costList: widget.svt.itemCost.ascension,
                              title: '灵基再临',
                              curLv: svtPlan.ascensionLv[0],
                              targetLv: svtPlan.ascensionLv[1]),
                    );
                  },
                )
              ],
            ),
          )
        ],
      ));
    }

    //skill part
    List<Widget> skillWidgets = [];
    for (int index = 0; index < widget.svt.activeSkills.length; index++) {
      Skill skill = widget.svt.activeSkills[index][0];
      skillWidgets.add(CustomTile(
        contentPadding: EdgeInsets.fromLTRB(16, 6, 16, 6),
        leading: Image.file(
          db.getIconFile(skill.icon),
          height: 110 * 0.3,
        ),
        title: Text('${skill.name} ${skill.rank}'),
        trailing: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
            RangeSelector(
              start: svtPlan.skillLv[index][0],
              end: svtPlan.skillLv[index][1],
              startItems: List.generate(10,
                      (index) =>
                      MapEntry(index + 1, Text((index + 1).toString()))),
              endItems: List.generate(10,
                      (index) =>
                      MapEntry(index + 1, Text((index + 1).toString()))),
              onChanged: (start, end) {
                svtPlan.skillLv[index] = [start, end];
                svtPlan.favorite = true;
                widget?.updateParent();
              },
            ),
            IconButton(
              icon: Icon(Icons.info_outline, color: Colors.blueAccent),
              onPressed: () {
                showSheet(context,
                    builder: (sheetContext, setSheetState) =>
                        ItemCostPage(
                          costList: widget.svt.itemCost.skill,
                          title: '技能${index + 1} - ${skill.name}',
                          curLv: svtPlan.skillLv[index][0],
                          targetLv: svtPlan.skillLv[index][1],
                        ));
              },
            )
          ],
        ),
      ));
    }
    children.add(TileGroup(header: '技能升级', tiles: skillWidgets));

    // dress part
    List<Widget> dressWidgets = [];
    for (int index = 0; index < widget.svt.itemCost.dress.length; index++) {
      if (svtPlan.dressLv.length <= index) {
        // dress number may increase in the future
        svtPlan.dressLv.add([0, 0]);
      }
      dressWidgets.add(CustomTile(
        leading: Image.file(db.getIconFile('灵衣开放权'), height: 110 * 0.3),
        title: AutoSizeText(widget.svt.itemCost.dressName[index], maxLines: 1),
        subtitle: AutoSizeText(
          widget.svt.itemCost.dressNameJp[index],
          maxLines: 1,
          minFontSize: 10,
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            RangeSelector<int>(
              start: svtPlan.dressLv[index][0],
              end: svtPlan.dressLv[index][1],
              startItems: List.generate(
                  2, (index) => MapEntry(index, Text(index.toString()))),
              endItems: List.generate(
                  2, (index) => MapEntry(index, Text(index.toString()))),
              onChanged: (start, end) {
                svtPlan.dressLv[index] = [start, end];
                svtPlan.favorite = true;
                widget?.updateParent();
              },
            ),
            IconButton(
              icon: Icon(Icons.info_outline, color: Colors.blueAccent),
              onPressed: () {
                showSheet(context,
                    builder: (sheetContext, setSheetState) =>
                        ItemCostPage(
                          costList: [widget.svt.itemCost.dress[index]],
                          title:
                          '灵衣开放 - ${widget.svt.itemCost.dressName[index]}',
                        ));
              },
            )
          ],
        ),
      ));
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

  PlanTabState(this.svtPlan);
}

class SkillTab extends StatefulWidget {
  final Servant svt;

  const SkillTab(this.svt, {Key key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => SkillTabState();
}

class SkillTabState extends State<SkillTab> with AutomaticKeepAliveClientMixin {
//  List<bool> changed = [false, false, false, false];

  @override
  Widget build(BuildContext context) {
    super.build(context);
    if (widget.svt.activeSkills == null) {
      return Center(child: Text('Nothing'));
    }

    final plan = db.userData.servants[widget.svt.no.toString()];
    List<Widget> children = [];
    widget.svt.activeSkills.asMap().keys.forEach((index) {
      List<Skill> skillList = widget.svt.activeSkills[index];
      bool enhanced =
      [skillList[0].enhanced, true, false][plan.skillEnhanced[index].index];

      Skill skill = skillList[enhanced ? 1 : 0];

      children.add(CustomTile(
        contentPadding: EdgeInsets.fromLTRB(16, 6, 22, 6),
        leading: Image.file(
          db.getIconFile(skill.icon),
          height: 110 * 0.3,
        ),
        title: Row(
          children: <Widget>[
            Expanded(flex: 4, child: Text('${skill.name} ${skill.rank}')),
            Expanded(
              flex: 1,
              child: skillList.length == 2
                  ? GestureDetector(
                      onTap: () {
//                  changed[index] = !(changed[index] ?? false);
                        plan.skillEnhanced[index] =
                        !enhanced ? Sign.positive : Sign.negative;
                        setState(() {});
                      },
                      child: Image.file(
                        db.getIconFile(enhanced ? '技能强化' : '技能未强化'),
                        height: 110 * 0.2,
                      ),
                    )
                  : Container(),
            )
          ],
        ),
        trailing: Text('CD: ${skill.cd}→${skill.cd - 2}'),
      ));

      if (skill.effects.length > 0) {
        List<Widget> effectWidgets = [];
        skill.effects.forEach((effect) {
          bool twoLine = effect.lvData.length == 10;
          effectWidgets
            ..add(CustomTile(
                contentPadding: EdgeInsets.fromLTRB(16, 6, 22, 6),
                subtitle: Text(effect.description),
                trailing: effect.lvData.length == 1
                    ? Text(formatNumberToString(
                    effect.lvData[0], effect.valueType))
                    : null));
          if (effect.lvData.length > 1) {
            effectWidgets
              ..add(CustomTile(
                  contentPadding:
                  EdgeInsets.symmetric(vertical: 0.0, horizontal: 16.0),
                  title: GridView.count(
                    childAspectRatio: twoLine ? 3.5 : 7,
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    crossAxisCount: twoLine ? 5 : effect.lvData.length,
                    children: effect.lvData
                        .asMap()
                        .keys
                        .map((index) {
                      return Align(
                        alignment: Alignment.centerRight,
                        child: Text(
                          formatNumberToString(
                              effect.lvData[index], effect.valueType),
                          style: TextStyle(
                              fontSize: 13,
                              color: [5, 9].contains(index)
                                  ? Colors.redAccent
                                  : null),
                        ),
                      );
                    }).toList(),
                  )));
          }
        });
        children.add(TileGroup(tiles: effectWidgets));
      }
    });
    return ListView(
      children: children,
    );
  }

  @override
  bool get wantKeepAlive => true;
}
