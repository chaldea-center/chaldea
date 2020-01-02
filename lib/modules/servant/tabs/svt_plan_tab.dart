import 'dart:math' show max, min;

import 'package:auto_size_text/auto_size_text.dart';
import 'package:chaldea/components/components.dart';

import '../servant_detail_page.dart';
import 'leveling_cost_page.dart';
import 'svt_tab_base.dart';

class SvtPlanTab extends SvtTabBaseWidget {
  SvtPlanTab(
      {Key key,
      ServantDetailPageState parent,
      Servant svt,
      ServantStatus status})
      : super(key: key, parent: parent, svt: svt, status: status);

  @override
  State<StatefulWidget> createState() =>
      _SvtPlanTabState(parent: parent, svt: svt, status: status);
}

class _SvtPlanTabState extends SvtTabBaseState<SvtPlanTab> {
//  ServantPlan plan;
  ServantPlan get plan =>
      db.curUser.curPlan.putIfAbsent(this.svt.no, () => ServantPlan());

  _SvtPlanTabState(
      {ServantDetailPageState parent, Servant svt, ServantStatus status})
      : super(parent: parent, svt: svt, status: status) {}

  void ensurePlanLarger(ServantPlan cur, ServantPlan target) {
    target.ascension = max(target.ascension, cur.ascension);
    for (var i = 0; i < cur.skills.length; i++) {
      target.skills[i] = max(target.skills[i], cur.skills[i]);
    }
    for (var i = 0; i < cur.dress?.length ?? 0; i++) {
      target.dress[i] = max(target.dress[i], cur.dress[i]);
    }
    target.grail = max(target.grail, cur.grail);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    if (svt.activeSkills == null) {
      return Center(child: Text('Nothing'));
    }
    final curVal = status.curVal;
    ensurePlanLarger(curVal, plan);
    // ascension part
    List<Widget> children = [];
    if (svt.no != 1) {
      children.add(TileGroup(
        header: '灵基再临',
        children: <Widget>[
          buildPlanRow(
            title: '灵基再临',
            start: curVal.ascension,
            end: plan.ascension,
            minVal: 0,
            maxVal: 4,
            onValueChanged: (_start, _end) {
              curVal
                ..ascension = _start
                ..favorite = true;
              plan
                ..ascension = _end
                ..favorite = true;
              widget.parent?.setState(() {});
            },
            detailPageBuilder: (context) => LevelingCostPage(
              costList: svt.itemCost.ascension,
              title: '灵基再临',
              curLv: curVal.ascension,
              targetLv: plan.ascension,
            ),
          )
        ],
      ));
    }

    //skill part
    List<Widget> skillWidgets = [];
    for (int index = 0; index < svt.activeSkills.length; index++) {
      List<Skill> skillList = svt.activeSkills[index];
      bool enhanced = status.skillEnhanced[index] ?? skillList[0].enhanced;
      Skill skill = skillList[enhanced ? 1 : 0];
      skillWidgets.add(buildPlanRow(
        leading: Image(
          image: db.getIconImage(skill.icon),
          height: 110 * 0.3,
        ),
        title: '${skill.name} ${skill.rank}',
        start: curVal.skills[index],
        end: plan.skills[index],
        minVal: 1,
        maxVal: 10,
        onValueChanged: (_start, _end) {
          curVal
            ..skills[index] = _start
            ..favorite = true;
          plan
            ..skills[index] = _end
            ..favorite = true;
          widget.parent?.setState(() {});
        },
        detailPageBuilder: (context) => LevelingCostPage(
          costList: svt.itemCost.skill,
          title: '技能${index + 1} - ${skill.name}',
          curLv: curVal.skills[index],
          targetLv: plan.skills[index],
        ),
      ));
    }
    children.add(TileGroup(header: '技能升级', children: skillWidgets));

    // dress part
    List<Widget> dressWidgets = [];
    for (int index = 0; index < svt.itemCost.dress.length; index++) {
      if (curVal.dress.length <= index) {
        // dress number may increase in the future
        curVal.dress.add(0);
        plan.dress.add(0);
      }
      dressWidgets.add(buildPlanRow(
        leading: Image(image: db.getIconImage('灵衣开放权'), height: 110 * 0.3),
        title: svt.itemCost.dressName[index],
        subtitle: svt.itemCost.dressNameJp[index],
        start: curVal.dress[index],
        end: plan.dress[index],
        minVal: 0,
        maxVal: 1,
        onValueChanged: (_start, _end) {
          curVal
            ..dress[index] = _start
            ..favorite = true;
          plan
            ..dress[index] = _end
            ..favorite = true;
          widget.parent?.setState(() {});
        },
        detailPageBuilder: (context) => LevelingCostPage(
          costList: [svt.itemCost.dress[index]],
          title: '灵衣开放 - ${svt.itemCost.dressName[index]}',
        ),
      ));
    }
    if (dressWidgets.length > 0) {
      children.add(TileGroup(header: '灵衣开放', children: dressWidgets));
    }
    children.add(TileGroup(
      header: '其他',
      children: <Widget>[
        buildPlanRow(
          leading: Image(image: db.getIconImage('宝具强化'), height: 110 * 0.3),
          title: '宝具等级',
          start: status.treasureDeviceLv,
          minVal: 1,
          maxVal: 5,
          onValueChanged: (_value, _) {
            status.treasureDeviceLv = _value;
            curVal.favorite = true;
            plan.favorite = true;
            widget.parent?.setState(() {});
          },
          detailPageBuilder: null,
        ),
        buildPlanRow(
          leading: Image(image: db.getIconImage('圣杯'), height: 110 * 0.3),
          title: '圣杯等级',
          start: curVal.grail,
          end: plan.grail,
          minVal: 0,
          maxVal: [0, 10, 10, 9, 7, 5][svt.info.rarity2],
          onValueChanged: (_start, _end) {
            curVal
              ..grail = _start
              ..favorite = true;
            plan
              ..grail = _end
              ..favorite = true;
            widget.parent?.setState(() {});
          },
          detailPageBuilder: null,
        )
      ],
    ));

    return Column(
      children: <Widget>[
        Expanded(child: ListView(children: children)),
        buildButtonBar(),
      ],
    );
  }

  Widget buildPlanRow({
    Widget leading,
    String title,
    String subtitle,
    int start,
    int end,
    int minVal,
    int maxVal,
    void Function(int, int) onValueChanged,
    WidgetBuilder detailPageBuilder,
  }) {
    assert(start != null && minVal <= start && start <= maxVal);
    if (end != null) {
      assert(start <= end && end <= maxVal);
    }
    Widget selector;
    if (end == null) {
      selector = DropdownButton(
        value: start,
        items: List.generate(
          maxVal - minVal + 1,
          (index) => DropdownMenuItem(
            value: minVal + index,
            child: Text((minVal + index).toString()),
          ),
        ),
        onChanged: (v) => onValueChanged(v, -1),
      );
    } else {
      selector = RangeSelector<int>(
        start: start,
        end: end,
        startItems: List.generate(
            maxVal - minVal + 1,
            (index) =>
                MapEntry(minVal + index, Text((minVal + index).toString()))),
        endItems: List.generate(
            maxVal - minVal + 1,
            (index) =>
                MapEntry(minVal + index, Text((minVal + index).toString()))),
        onChanged: onValueChanged,
      );
    }
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
          selector,
          IconButton(
            icon: Icon(Icons.info_outline,
                color: detailPageBuilder == null
                    ? Colors.grey
                    : Colors.blueAccent),
            onPressed: detailPageBuilder == null
                ? null
                : () => showSheet(context,
                    builder: (sheetContext, setSheetState) =>
                        detailPageBuilder(sheetContext)),
          )
        ],
      ),
    );
  }

  Widget buildButtonBar() {
    final curVal = status.curVal;
    State state = widget.parent ?? this;
    return Container(
      decoration: BoxDecoration(
          border: Border(top: Divider.createBorderSide(context, width: 0.5))),
      child: Align(
        alignment: Alignment.centerRight,
        child: ButtonBar(
          children: <Widget>[
            FittedBox(
              fit: BoxFit.contain,
              child: Row(
                children: <Widget>[
                  DropdownButton(
                    value: Set.from(curVal.skills).length == 1
                        ? curVal.skills[0]
                        : null,
                    hint: Text('Lv. ≠'),
                    items: List.generate(
                        10,
                        (i) => DropdownMenuItem(
                            value: i + 1, child: Text('Lv. ${i + 1}'))),
                    onChanged: (v) {
                      state.setState(
                        () {
                          curVal.favorite = plan.favorite = true;
                          curVal.ascension = 4;
                          for (var i = 0; i < 3; i++) {
                            curVal.skills[i] = v;
                            // plan.skills[i] = max(v, plan.skills[i]);
                          }
                        },
                      );
                    },
                  ),
                  IconButton(
                    icon: Icon(Icons.vertical_align_top),
                    tooltip: '练度最大化(310)',
                    onPressed: () {
                      state.setState(() {
                        curVal.setMax(skill: 10);
                        // plan.setMax(skill: 10);
                      });
                    },
                  ),
                  Stack(
                    alignment: AlignmentDirectional.bottomEnd,
                    children: <Widget>[
                      Padding(
                        padding: EdgeInsets.fromLTRB(0, 0, 8, 4),
                        child: Text('9'),
                      ),
                      IconButton(
                        icon: Icon(Icons.trending_up),
                        tooltip: '规划最大化(999)',
                        onPressed: () {
                          state.setState(() {
                            plan.setMax(skill: 9);
                            curVal.favorite = true;
                            for (int i = 0; i < 3; i++) {
                              curVal.skills[i] = min(curVal.skills[i], 9);
                            }
                          });
                        },
                      ),
                    ],
                  ),
                  Stack(
                    alignment: AlignmentDirectional.bottomEnd,
                    children: <Widget>[
                      Padding(
                        padding: EdgeInsets.fromLTRB(0, 0, 4, 4),
                        child: Text('10'),
                      ),
                      IconButton(
                        icon: Icon(Icons.trending_up),
                        tooltip: '规划最大化(310)',
                        onPressed: () {
                          state.setState(() {
                            curVal.favorite = true;
                            plan.setMax(skill: 10);
                          });
                        },
                      ),
                    ],
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
