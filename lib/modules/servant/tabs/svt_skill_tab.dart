import 'package:chaldea/components/components.dart';

import '../servant_detail_page.dart';
import 'svt_tab_base.dart';

class SvtSkillTab extends SvtTabBaseWidget {
  SvtSkillTab(
      {Key key,
      ServantDetailPageState parent,
      Servant svt,
      ServantStatus status})
      : super(key: key, parent: parent, svt: svt, status: status);

  @override
  State<StatefulWidget> createState() =>
      _SvtSkillTabState(parent: parent, svt: svt, plan: status);
}

class _SvtSkillTabState extends SvtTabBaseState<SvtSkillTab> {
  _SvtSkillTabState(
      {ServantDetailPageState parent, Servant svt, ServantStatus plan})
      : super(parent: parent, svt: svt, status: plan);

  @override
  Widget build(BuildContext context) {
    super.build(context);
    if (svt.activeSkills?.isNotEmpty != true) {
      return Center(child: Text('Nothing'));
    }

    return ListView(children: [
      SHeader(S.of(context).active_skill),
      for (var index = 0; index < svt.activeSkills.length; index++)
        buildActiveSkill(index),
      if (svt.passiveSkills?.isNotEmpty == true) ...[
        SHeader(S.of(context).passive_skill),
        for (var index = 0; index < svt.passiveSkills.length; index++)
          buildPassiveSkill(index),
      ]
    ]);
  }

  Widget buildActiveSkill(int index) {
    ActiveSkill activeSkill = svt.activeSkills[index];
    Skill skill =
        activeSkill.skills[status.skillIndex[index] ?? activeSkill.cnState];
    String nameCn = '${skill.name} ${skill.rank}';
    String nameJp = '${skill.nameJp} ${skill.rank}';
    return TileGroup(
      children: <Widget>[
        CustomTile(
            contentPadding: EdgeInsets.fromLTRB(16, 6, 22, 6),
            leading:
                Image(image: db.getIconImage(skill.icon), height: 110 * 0.3),
            title: Text(MyLocale.isCN ? nameCn : nameJp),
            subtitle: Text(MyLocale.isCN ? nameJp : nameCn),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                for (int i = 1; i < activeSkill.skills.length; i++)
                  GestureDetector(
                    onTap: () {
                      status.skillIndex[index] =
                          status.skillIndex[index] == i ? i - 1 : i;
                      widget.parent?.setState(() {});
                    },
                    child: Image(
                      image: db.getIconImage(
                          (status.skillIndex[index] ?? activeSkill.cnState) >= i
                              ? '技能强化'
                              : '技能未强化'),
                      height: 110 * 0.2,
                    ),
                  ),
                Text('   CD: ${skill.cd}→${skill.cd - 2}')
              ],
            )),
        for (Effect effect in skill.effects) ...buildEffect(effect)
      ],
    );
  }

  Widget buildPassiveSkill(int index) {
    Skill skill = svt.passiveSkills[index];
    return TileGroup(
      children: <Widget>[
        CustomTile(
          contentPadding: EdgeInsets.fromLTRB(16, 6, 22, 6),
          leading: Image(image: db.getIconImage(skill.icon), height: 110 * 0.3),
          title: Text('${skill.name} ${skill.rank ?? ""}'),
        ),
        for (Effect effect in skill.effects) ...buildEffect(effect),
      ],
    );
  }

  List<Widget> buildEffect(Effect effect) {
    assert([1, 10].contains(effect.lvData.length));
    int lines =
        effect.lvData.length == 1 ? (effect.lvData[0].length < 10 ? 0 : 1) : 2;
    int crossCount =
        effect.lvData.length == 1 ? (effect.lvData[0].length < 10 ? 0 : 1) : 5;

    return <Widget>[
      CustomTile(
          contentPadding: EdgeInsets.fromLTRB(16, 6, 22, 6),
          subtitle: Text(effect.description),
          trailing: crossCount == 0 ? Text(effect.lvData[0]) : null),
      if (lines > 0)
        Padding(
          padding: EdgeInsets.only(right: 24),
          child: Table(
            children: [
              for (int row = 0; row < effect.lvData.length / crossCount; row++)
                TableRow(
                  children: List.generate(crossCount, (col) {
                    int index = row * crossCount + col;
                    if (index >= effect.lvData.length) return Container();
                    return Align(
                      alignment: Alignment.center,
                      child: Padding(
                        padding: EdgeInsets.all(5),
                        child: Text(
                          effect.lvData[index],
                          style: TextStyle(
                            fontSize: 14,
                            color: index == 5 || index == 9
                                ? Colors.redAccent
                                : null,
                          ),
                        ),
                      ),
                    );
                  }),
                )
            ],
          ),
        ),
    ];
  }
}
