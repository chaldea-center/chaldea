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

  const LevelUpCostPage({Key key,
    @required this.costList,
    this.curLv = 0,
    this.targetLv = 0,
    this.title = ''})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => LevelUpCostPageState();
}

class LevelUpCostPageState extends State<LevelUpCostPage> {
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
                            .map((item) =>
                            ImageWithText(
                              image: Image.file(db.getIconFile(item.name),
                                      width: 110 * 0.5),
                              text: formatNumberToString(item.num, 'kilo'),
                              bottom: ImageWithText.itemBottom,
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

//  final VoidCallback updateParent;
  final ServantDetailPageState parent;
  final ServantPlan plan;

  const PlanTab(this.svt, {Key key, this.plan, this.parent}) : super(key: key);

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

  Widget buildPlanRow({Widget leading,
    String title,
    String subtitle,
    @required IntRangeValues value,
    @required IntRangeValues range,
    void onRangeChanged(int s, int e),
    Widget detailPage}) {
    assert(value != null && range != null);
    return CustomTile(
      contentPadding: EdgeInsets.fromLTRB(16, 8, 8, 8),
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
              if (detailPage != null) {
                showSheet(
                  context,
                  builder: (sheetContext, setSheetState) => detailPage,
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
    if (widget.svt.activeSkills == null) {
      return Center(child: Text('Nothing'));
    }

    // ascension part
    List<Widget> children = [];
    if (widget.svt.no != 1) {
      children.add(TileGroup(
        header: '灵基再临',
        tiles: <Widget>[
          buildPlanRow(
              title: '灵基再临',
              value: IntRangeValues.fromList(svtPlan.ascensionLv),
              range: IntRangeValues(0, 4),
              onRangeChanged: (_start, _end) {
                svtPlan.ascensionLv = [_start, _end];
                svtPlan.favorite = true;
                widget.parent?.setState(() {});
              },
              detailPage: LevelUpCostPage(
                costList: widget.svt.itemCost.ascension,
                title: '灵基再临',
                curLv: svtPlan.ascensionLv[0],
                targetLv: svtPlan.ascensionLv[1],
              ))
        ],
      ));
    }

    //skill part
    List<Widget> skillWidgets = [];
    final plan = db.userData.servants[widget.svt.no.toString()];
    for (int index = 0; index < widget.svt.activeSkills.length; index++) {
      List<Skill> skillList = widget.svt.activeSkills[index];
      bool enhanced = plan.skillEnhanced[index] ?? skillList[0].enhanced;
      Skill skill = skillList[enhanced ? 1 : 0];
//      Skill skill = widget.svt.activeSkills[index][0];
      skillWidgets.add(buildPlanRow(
          leading: Image.file(
            db.getIconFile(skill.icon),
            height: 110 * 0.3,
          ),
          title: '${skill.name} ${skill.rank}',
          value: IntRangeValues.fromList(svtPlan.skillLv[index]),
          range: IntRangeValues(1, 10),
          onRangeChanged: (_start, _end) {
            svtPlan.skillLv[index] = [_start, _end];
            svtPlan.favorite = true;
            widget.parent?.setState(() {});
          },
          detailPage: LevelUpCostPage(
            costList: widget.svt.itemCost.skill,
            title: '技能${index + 1} - ${skill.name}',
            curLv: svtPlan.skillLv[index][0],
            targetLv: svtPlan.skillLv[index][1],
          )));
    }
    children.add(TileGroup(header: '技能升级', tiles: skillWidgets));

    // dress part
    List<Widget> dressWidgets = [];
    for (int index = 0; index < widget.svt.itemCost.dress.length; index++) {
      if (svtPlan.dressLv.length <= index) {
        // dress number may increase in the future
        svtPlan.dressLv.add([0, 0]);
      }
      dressWidgets.add(buildPlanRow(
          leading: Image.file(db.getIconFile('灵衣开放权'), height: 110 * 0.3),
          title: widget.svt.itemCost.dressName[index],
          subtitle: widget.svt.itemCost.dressNameJp[index],
          value: IntRangeValues.fromList(svtPlan.dressLv[index]),
          range: IntRangeValues(0, 1),
          onRangeChanged: (_start, _end) {
            svtPlan.dressLv[index] = [_start, _end];
            svtPlan.favorite = true;
            widget.parent?.setState(() {});
          },
          detailPage: LevelUpCostPage(
            costList: [widget.svt.itemCost.dress[index]],
            title: '灵衣开放 - ${widget.svt.itemCost.dressName[index]}',
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

  PlanTabState(this.svtPlan);
}

class SkillTab extends StatefulWidget {
  final Servant svt;
  final ServantDetailPageState parent;

  const SkillTab(this.svt, {Key key, this.parent}) : super(key: key);

  @override
  State<StatefulWidget> createState() => SkillTabState();
}

class SkillTabState extends State<SkillTab> with AutomaticKeepAliveClientMixin {
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
      bool enhanced = plan.skillEnhanced[index] ?? skillList[0].enhanced;
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
                        widget.parent?.setState(() {
                          plan.skillEnhanced[index] = !enhanced;
                        });
                      },
                      child: Image.file(
                        // Icon: skill enhanced(gold) or not enhanced(grey)
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
