import 'package:chaldea/components/components.dart';

import '../servant_detail_page.dart';
import 'svt_tab_base.dart';

class SvtSkillTab extends SvtTabBaseWidget {
  SvtSkillTab(
      {Key key, ServantDetailPageState parent, Servant svt, ServantPlan plan})
      : super(key: key, parent: parent, svt: svt, plan: plan);

  @override
  State<StatefulWidget> createState() =>
      _SvtSkillTabState(parent: parent, svt: svt, plan: plan);
}

class _SvtSkillTabState extends SvtTabBaseState<SvtSkillTab>
    with AutomaticKeepAliveClientMixin {
  _SvtSkillTabState(
      {ServantDetailPageState parent, Servant svt, ServantPlan plan})
      : super(parent: parent, svt: svt, plan: plan);

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
