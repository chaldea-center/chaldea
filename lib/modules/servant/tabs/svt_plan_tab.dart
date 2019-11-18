import 'package:auto_size_text/auto_size_text.dart';
import 'package:chaldea/components/components.dart';

import '../servant_detail_page.dart';
import 'leveling_cost_page.dart';
import 'svt_tab_base.dart';

class SvtPlanTab extends SvtTabBaseWidget {
  SvtPlanTab(
      {Key key, ServantDetailPageState parent, Servant svt, ServantPlan plan})
      : super(key: key, parent: parent, svt: svt, plan: plan);

  @override
  State<StatefulWidget> createState() =>
      _SvtPlanTabState(parent: parent, svt: svt, plan: plan);
}

class _SvtPlanTabState extends SvtTabBaseState<SvtPlanTab>
    with AutomaticKeepAliveClientMixin {
  _SvtPlanTabState(
      {ServantDetailPageState parent, Servant svt, ServantPlan plan})
      : super(parent: parent, svt: svt, plan: plan);

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
              detailPageBuilder: (context) => LevelingCostPage(
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
          leading: Image(
            image: db.getIconFile(skill.icon),
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
          detailPageBuilder: (context) => LevelingCostPage(
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
          leading: Image(image: db.getIconFile('灵衣开放权'), height: 110 * 0.3),
          title: svt.itemCost.dressName[index],
          subtitle: svt.itemCost.dressNameJp[index],
          value: IntRangeValues.fromList(plan.dressLv[index]),
          range: IntRangeValues(0, 1),
          onRangeChanged: (_start, _end) {
            plan.dressLv[index] = [_start, _end];
            plan.favorite = true;
            widget.parent?.setState(() {});
          },
          detailPageBuilder: (context) => LevelingCostPage(
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
