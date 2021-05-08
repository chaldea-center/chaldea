import 'package:chaldea/components/components.dart';
import 'package:chaldea/components/localized/localized_base.dart';

import '../servant_detail_page.dart';
import 'svt_tab_base.dart';

class SvtSkillTab extends SvtTabBaseWidget {
  SvtSkillTab({
    Key? key,
    ServantDetailPageState? parent,
    Servant? svt,
    ServantStatus? status,
  }) : super(key: key, parent: parent, svt: svt, status: status);

  @override
  State<StatefulWidget> createState() =>
      _SvtSkillTabState(parent: parent, svt: svt, plan: status);
}

class _SvtSkillTabState extends SvtTabBaseState<SvtSkillTab> {
  _SvtSkillTabState(
      {ServantDetailPageState? parent, Servant? svt, ServantStatus? plan})
      : super(parent: parent, svt: svt, status: plan);

  @override
  Widget build(BuildContext context) {
    if (svt.lActiveSkills.isNotEmpty != true) {
      return Center(child: Text('Nothing'));
    }
    status.validate();
    return ListView(children: [
      SHeader(S.of(context).active_skill),
      for (var index = 0; index < svt.lActiveSkills.length; index++)
        buildActiveSkill(index),
      if (svt.lPassiveSkills.isNotEmpty == true) ...[
        SHeader(S.of(context).passive_skill),
        for (var index = 0; index < svt.lPassiveSkills.length; index++)
          buildPassiveSkill(index),
      ]
    ]);
  }

  Widget buildActiveSkill(int index) {
    ActiveSkill activeSkill = svt.lActiveSkills[index];
    int? _state;
    if (Servant.unavailable.contains(svt.no)) {
      _state = 0;
    } else {
      _state = status.skillIndex.getOrNull(index) ??
          (Language.isCN ? activeSkill.cnState : null);
    }
    _state ??= activeSkill.skills.length - 1;
    Skill skill = activeSkill.skills[_state];
    String name = '${skill.name} ${skill.rank}';
    String nameJp = '${skill.nameJp} ${skill.rank}';
    return TileGroup(
      children: <Widget>[
        CustomTile(
            contentPadding: EdgeInsets.fromLTRB(16, 6, 22, 6),
            leading: db.getIconImage(skill.icon, width: 33),
            title: Text(Language.isJP ? nameJp : name),
            subtitle: Language.isCN ? Text(nameJp) : null,
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                for (int i = 1; i < activeSkill.skills.length; i++)
                  GestureDetector(
                    onTap: () {
                      status.skillIndex[index] =
                          status.skillIndex[index] == i ? i - 1 : i;
                      ((widget.parent ?? this) as State).setState(() {});
                    },
                    child: db.getIconImage(
                      _state >= i ? '技能强化'
                          : '技能未强化',
                      width: 22,
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
    Skill skill = svt.lPassiveSkills[index];
    return TileGroup(
      children: <Widget>[
        CustomTile(
          contentPadding: EdgeInsets.fromLTRB(16, 6, 22, 6),
          leading: db.getIconImage(skill.icon, width: 33, height: 33),
          title: Text('${skill.localizedName} ${skill.rank ?? ""}'),
        ),
        for (Effect effect in skill.effects) ...buildEffect(effect),
      ],
    );
  }

  List<Widget> buildEffect(Effect effect) {
    assert([0, 1, 10].contains(effect.lvData.length));
    int crossCount = effect.lvData.length > 1
        ? 5
        : effect.lvData.length == 1 && effect.lvData.first.length >= 10
            ? 1
            : 0;
    return <Widget>[
      CustomTile(
        contentPadding: EdgeInsets.fromLTRB(16, 6, crossCount == 0 ? 0 : 16, 6),
        subtitle: crossCount == 0
            ? Row(children: [
                Expanded(child: Text(effect.description), flex: 4),
                if (effect.lvData.isNotEmpty)
                  Expanded(
                      child: Center(child: Text(effect.lvData[0])), flex: 1),
              ])
            : Text(effect.description),
      ),
      if (crossCount > 0)
        Table(
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
    ];
  }
}
