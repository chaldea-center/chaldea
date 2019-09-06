import 'dart:io';

import 'package:chaldea/components/components.dart';
import 'package:chaldea/components/custom_tile.dart';
import 'package:flutter/material.dart';
import 'dart:math' show max, min;

class ItemUnit extends StatelessWidget {
  final Image icon;
  final String text;
  final AlignmentDirectional alignment;

  ItemUnit(this.icon, this.text,
      {Key key, this.alignment = AlignmentDirectional.bottomEnd})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: alignment,
      children: <Widget>[
        icon,
        Padding(
          padding: EdgeInsets.symmetric(
              vertical: icon.width * 0.05, horizontal: icon.width * 0.1),
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: icon.width * 0.9),
            child: FittedBox(
              fit: BoxFit.fitWidth,
              child: Stack(
                children: <Widget>[
                  Text(
                    text,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      foreground: Paint()
                        ..style = PaintingStyle.stroke
                        ..strokeWidth = 3
                        ..color = Colors.white,
                    ),
                  ),
                  Text(
                    text,
                    style: TextStyle(fontWeight: FontWeight.bold),
                  )
                ],
              ),
            ),
          ),
        )
      ],
    );
  }
}

class ItemCostPage extends StatefulWidget {
  final List<List<Item>> costList;
  final int curLv;
  final int targetLv;

  const ItemCostPage(this.costList,
      {this.curLv = 0, this.targetLv = 0, Key key})
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
        title: Text(isSkill ? 'Skill Level Up' : 'Ascension'),
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
                                  Image.file(
                                      db.getLocalFile(item.name, rel: 'icons'),
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
    List<Widget> children = [];
    if (widget.svt.no != 1) {
      children.add(CustomTile(
        title: Text('灵基再临'),
        trailing: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
            DropdownButton(
              value: svtPlan.curAscensionLv,
              items: List.generate(
                  5,
                  (index) => DropdownMenuItem(
                        value: index,
                        child: Text('$index  '),
                      )),
              onChanged: (int value) {
                svtPlan.curAscensionLv = value;
                svtPlan.targetAscensionLv =
                    max(value, svtPlan.targetAscensionLv);
                svtPlan.favorite = true;
                widget?.updateParent();
              },
            ),
            Text('   →   '),
            DropdownButton(
              value: svtPlan.targetAscensionLv,
              items: List.generate(
                  5,
                  (index) => DropdownMenuItem(
                        value: index,
                        child: Text('$index  '),
                      )),
              onChanged: (int value) {
                svtPlan.targetAscensionLv = value;
                svtPlan.curAscensionLv = min(value, svtPlan.curAscensionLv);
                svtPlan.favorite = true;
                widget?.updateParent();
              },
            ),
            IconButton(
              icon: Icon(Icons.info_outline, color: Colors.blueAccent),
              onPressed: () {
                showSheet(
                    context,
                    ItemCostPage(widget.svt.itemCost.ascension,
                        curLv: svtPlan.curAscensionLv,
                        targetLv: svtPlan.targetAscensionLv));
              },
            )
          ],
        ),
      ));
    }

    for (int index = 0; index < widget.svt.activeSkills.length; index++) {
      Skill skill = widget.svt.activeSkills[index][0];
      children.add(CustomTile(
        contentPadding: EdgeInsets.fromLTRB(16, 6, 16, 6),
        leading: Image.file(
          db.getLocalFile(skill.icon, rel: 'icons'),
          height: 110 * 0.3,
        ),
        title: Text('${skill.name} ${skill.rank}'),
        trailing: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
            DropdownButton(
              value: svtPlan.curSkillLv[index],
              items: List.generate(
                  10,
                  (index) => DropdownMenuItem(
                        value: index + 1,
                        child: Text('${index + 1}'),
                      )),
              onChanged: (int value) {
                svtPlan.curSkillLv[index] = value;
                svtPlan.targetSkillLv[index] =
                    max(value, svtPlan.targetSkillLv[index]);
                svtPlan.favorite = true;
                widget?.updateParent();
              },
            ),
            Text('   →   '),
            DropdownButton(
              value: svtPlan.targetSkillLv[index],
              items: List.generate(
                  10,
                  (index) => DropdownMenuItem(
                        value: 1 + index,
                        child: Text('${1 + index}'),
                      )),
              onChanged: (int value) {
                svtPlan.targetSkillLv[index] = value;
                svtPlan.curSkillLv[index] =
                    min(value, svtPlan.curSkillLv[index]);
                svtPlan.favorite = true;
                widget.updateParent();
              },
            ),
            IconButton(
              icon: Icon(Icons.info_outline, color: Colors.blueAccent),
              onPressed: () {
                showSheet(
                    context,
                    ItemCostPage(
                      widget.svt.itemCost.skill,
                      curLv: svtPlan.curSkillLv[index],
                      targetLv: svtPlan.targetSkillLv[index],
                    ));
              },
            )
          ],
        ),
      ));
    }

    for (int index = 0; index < widget.svt.itemCost.dress.length; index++) {
      children.add(CustomTile(
        leading: null,
        title: Text(widget.svt.itemCost.dressName[index]),
        trailing: IconButton(
          icon: Icon(Icons.info_outline, color: Colors.blueAccent),
          onPressed: () {
            showSheet(
                context, ItemCostPage([widget.svt.itemCost.dress[index]]));
          },
        ),
      ));
    }
    return ListView(
      children: divideTiles2(children,
          divider: Divider(
            height: 0,
            indent: 16,
            endIndent: 16,
          )),
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
  List<bool> changed = [false, false, false, false];

  @override
  Widget build(BuildContext context) {
    super.build(context);
    if (widget.svt.activeSkills == null) {
      return Center(child: Text('Nothing'));
    }
    List<Widget> children = [];
    widget.svt.activeSkills.asMap().keys.forEach((index) {
      List<Skill> skillList = widget.svt.activeSkills[index];
      Skill skill = skillList[changed[index] ? 1 : 0];
      children.add(CustomTile(
        contentPadding: EdgeInsets.fromLTRB(16, 6, 48, 6),
        leading: Image.file(
          db.getLocalFile(skill.icon, rel: 'icons'),
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
                        changed[index] = !(changed[index] ?? false);
                        setState(() {});
                      },
                      child: Image.file(
                        db.getLocalFile(
                            (skillList[0].state == '强化前') ^
                                    (changed[index] ?? false)
                                ? '技能未强化.png'
                                : '技能强化.png',
                            rel: 'icons'),
                        height: 110 * 0.2,
                      ),
                    )
                  : Container(),
            )
          ],
        ),
        trailing: Text('CD: ${skill.cd}→${skill.cd - 2}'),
      ));
      skill.effects.forEach((effect) {
        bool twoLine = effect.lvData.length == 10;
        children
          ..add(CustomTile(
              contentPadding: EdgeInsets.fromLTRB(16, 6, 48, 6),
              subtitle: Text(effect.description),
              trailing: effect.lvData.length == 1
                  ? Text(
                      formatNumberToString(effect.lvData[0], effect.valueType))
                  : null));
        if (effect.lvData.length > 1) {
          children
            ..add(CustomTile(
                contentPadding:
                    EdgeInsets.symmetric(vertical: 0.0, horizontal: 16.0),
                title: GridView.count(
                  childAspectRatio: twoLine ? 3.5 : 7,
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  crossAxisCount: twoLine ? 5 : effect.lvData.length,
                  children: effect.lvData.asMap().keys.map((index) {
                    return Center(
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
    });
    return ListView(
//      key: PageStorageKey('skills'),
      children: divideTiles2(children,
          divider: Divider(
            height: 0.0,
            indent: 16,
            endIndent: 16,
          ),
          bottom: true),
    );
  }

  @override
  bool get wantKeepAlive => true;
}

List<Widget> divideTiles(Iterable<Widget> tiles,
    {Widget divider = const Divider(height: 1.0),
    bool top = false,
    bool bottom = false}) {
  if (tiles.length == 0) {
    return tiles;
  }
  List<Widget> combined = [];
  if (top) {
    combined.add(divider);
  }
  Iterator iterator = tiles.iterator;
  combined.add(iterator.current);
  while (iterator.moveNext()) {
    combined..add(divider)..add(iterator.current);
  }
  if (bottom) {
    combined.add(divider);
  }
  return combined;
}

List<Widget> divideTiles2(List<Widget> tiles,
    {Widget divider = const Divider(height: 1.0),
    bool top = false,
    bool bottom = false}) {
  if (tiles.length == 0) {
    return tiles;
  }
  List<Widget> combined = [];
  if (top) {
    combined.add(divider);
  }
  for (int index = 0; index < tiles.length - 1; index++) {
    combined..add(tiles[index])..add(divider);
  }
  combined.add(tiles.last);
  if (bottom) {
    combined.add(divider);
  }
  return combined;
}

void showSheet(BuildContext context, Widget child) {
  // exactly, ModalBottomSheet's height is decided by [initialChildSize]
  // and cannot be modified by drag.
  showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
            initialChildSize: 0.75,
            minChildSize: 0.25,
            maxChildSize: 0.9,
            expand: false,
            builder:
                (BuildContext context, ScrollController scrollController) =>
                    child,
          ));
}
