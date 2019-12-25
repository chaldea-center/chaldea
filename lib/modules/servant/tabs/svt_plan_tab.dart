import 'dart:math';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:chaldea/components/components.dart';

import '../servant_detail_page.dart';
import 'leveling_cost_page.dart';
import 'svt_tab_base.dart';

class SvtPlanTab extends SvtTabBaseWidget {
  SvtPlanTab(
      {Key key, ServantDetailPageState parent, Servant svt, ServantStatus plan})
      : super(key: key, parent: parent, svt: svt, status: plan);

  @override
  State<StatefulWidget> createState() =>
      _SvtPlanTabState(parent: parent, svt: svt, status: status);
}

class _SvtPlanTabState extends SvtTabBaseState<SvtPlanTab>
    with AutomaticKeepAliveClientMixin {
  _SvtPlanTabState(
      {ServantDetailPageState parent, Servant svt, ServantStatus status})
      : super(parent: parent, svt: svt, status: status);

  Widget buildPlanRow(
      {Widget leading,
      String title,
      String subtitle,
      int start,
      int end,
      int minVal,
      int maxVal,
      Function onValueChanged,
      WidgetBuilder detailPageBuilder}) {
    assert(start != null && minVal <= start && start <= end && end <= maxVal);
    Widget selector;
    if (end == null) {
      selector = DropdownButton(
        value: start,
        items: List.generate(
            maxVal - minVal + 1,
            (index) => DropdownMenuItem(
                  value: minVal + index,
                  child: Text((minVal + index).toString()),
                )),
        onChanged: onValueChanged,
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
    final plan = db.curUser.curPlan.putIfAbsent(svt.no, () => ServantPlan());
    // ascension part
    List<Widget> children = [];
    if (svt.no != 1) {
      children.add(TileGroup(
        header: '灵基再临',
        children: <Widget>[
          buildPlanRow(
              title: '灵基再临',
              start: status.curVal.ascension,
              end: plan.ascension,
              minVal: 0,
              maxVal: 4,
              onValueChanged: (_start, _end) {
                status.curVal
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
                    curLv: status.curVal.ascension,
                    targetLv: plan.ascension,
                  ))
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
            image: db.getIconFile(skill.icon),
            height: 110 * 0.3,
          ),
          title: '${skill.name} ${skill.rank}',
          start: status.curVal.skills[index],
          end: plan.skills[index],
          minVal: 1,
          maxVal: 10,
          onValueChanged: (_start, _end) {
            status.curVal
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
                curLv: status.curVal.skills[index],
                targetLv: plan.skills[index],
              )));
    }
    children.add(TileGroup(header: '技能升级', children: skillWidgets));

    // dress part
    List<Widget> dressWidgets = [];
    for (int index = 0; index < svt.itemCost.dress.length; index++) {
      if (status.curVal.dress.length <= index) {
        // dress number may increase in the future
        status.curVal.dress.add(0);
        plan.dress.add(0);
      }
      dressWidgets.add(buildPlanRow(
          leading: Image(image: db.getIconFile('灵衣开放权'), height: 110 * 0.3),
          title: svt.itemCost.dressName[index],
          subtitle: svt.itemCost.dressNameJp[index],
          start: status.curVal.dress[index],
          end: plan.dress[index],
          minVal: 0,
          maxVal: 1,
          onValueChanged: (_start, _end) {
            status.curVal
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
              )));
    }
    if (dressWidgets.length > 0) {
      children.add(TileGroup(header: '灵衣开放', children: dressWidgets));
    }

    return Column(
      children: <Widget>[
        Expanded(
          child: ListView(children: children),
        ),
        ButtonBar(
          children: <Widget>[
            IconButton(
                icon: Icon(Icons.vertical_align_top),
                tooltip: '练度最大化(310)',
                onPressed: () {
                  ((widget.parent ?? this) as State).setState(() {
                    status.curVal.setMax(skill: 10);
                    plan.setMax(skill: 10);
                  });
                }),
            Stack(
              alignment: AlignmentDirectional.bottomEnd,
              children: <Widget>[
                Text('9  '),
                IconButton(
                    icon: Icon(Icons.trending_up),
                    tooltip: '规划最大化(999)',
                    onPressed: () {
                      ((widget.parent ?? this) as State).setState(() {
                        plan.setMax(skill: 9);
                        status.curVal.favorite = true;
                        for (int i = 0; i < 3; i++) {
                          status.curVal.skills[i] =
                              min(status.curVal.skills[i], 9);
                        }
                      });
                    }),
              ],
            ),
            Stack(
              alignment: AlignmentDirectional.bottomEnd,
              children: <Widget>[
                Text('10 '),
                IconButton(
                    icon: Icon(Icons.trending_up),
                    tooltip: '规划最大化',
                    onPressed: () {
                      ((widget.parent ?? this) as State).setState(() {
                        status.curVal.favorite = true;
                        plan.setMax(skill: 10);
                      });
                    }),
              ],
            ),
            IconButton(
                icon: Icon(Icons.replay),
                tooltip: '重置',
                onPressed: () {
                  ((widget.parent ?? this) as State).setState(() {
                    status.curVal.reset();
                    plan.reset();
                  });
                }),
          ],
        )
      ],
    );
  }

  @override
  bool get wantKeepAlive => true;
}
