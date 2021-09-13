import 'package:chaldea/components/components.dart';
import 'package:chaldea/components/localized/localized_base.dart';
import 'package:chaldea/modules/shared/filter_page.dart';

import '../servant_detail_page.dart';
import 'svt_tab_base.dart';

class SvtSkillTab extends SvtTabBaseWidget {
  const SvtSkillTab({
    Key? key,
    ServantDetailPageState? parent,
    Servant? svt,
    ServantStatus? status,
  }) : super(key: key, parent: parent, svt: svt, status: status);

  @override
  State<StatefulWidget> createState() => _SvtSkillTabState();
}

class _SvtSkillTabState extends SvtTabBaseState<SvtSkillTab> {
  @override
  Widget build(BuildContext context) {
    if (svt.lActiveSkills.isNotEmpty != true) {
      return const Center(child: Text('Nothing'));
    }
    status.validate(svt);
    return ListView(children: [
      SHeader(S.of(context).active_skill),
      for (var index = 0; index < svt.lActiveSkills.length; index++)
        buildActiveSkill(index),
      if (svt.lPassiveSkills.isNotEmpty == true) ...[
        SHeader(S.of(context).passive_skill),
        for (var index = 0; index < svt.lPassiveSkills.length; index++)
          buildPassiveSkill(index),
      ],
      if (svt.appendSkills.isNotEmpty) ...[
        SHeader(S.current.append_skill),
        for (var index = 0; index < svt.appendSkills.length; index++)
          buildAppendSkill(index),
      ]
    ]);
  }

  Widget buildActiveSkill(int index) {
    ActiveSkill activeSkill = svt.lActiveSkills[index];
    int? _state;
    if (Servant.unavailable.contains(svt.no)) {
      _state = 0;
    } else {
      _state = status.skillIndex.getOrNull(index);
    }
    _state ??= activeSkill.skills.length - 1;
    Skill? skill = activeSkill.ofIndex(_state);
    if (skill == null) return Container();
    String name = '${skill.name} ${skill.rank ?? ""}';
    String nameJp = '${skill.nameJp} ${skill.rank ?? ""}';
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (activeSkill.skills.length > 1)
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: FilterGroup(
                  useRadio: true,
                  shrinkWrap: true,
                  combined: true,
                  options: List.generate(
                      activeSkill.skills.length, (index) => index.toString()),
                  optionBuilder: (v) => Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
                    child: Text(activeSkill.skills[int.parse(v)].state2),
                  ),
                  values: FilterGroupData(options: {_state.toString(): true}),
                  onFilterChanged: (v) {
                    status.skillIndex[index] = int.parse(
                        v.options.keys.firstWhere((e) => v.options[e] == true));
                    ((widget.parent ?? this) as State).setState(() {});
                  },
                ),
              ),
              if (skill.openCondition?.isNotEmpty == true)
                IconButton(
                  padding: const EdgeInsets.all(2),
                  constraints: const BoxConstraints(
                    minWidth: 48,
                    minHeight: 24,
                  ),
                  onPressed: () {
                    SimpleCancelOkDialog(
                      title: Text(skill.localizedName),
                      content: Text(
                        skill.openCondition!,
                        style: Theme.of(context).textTheme.caption,
                      ),
                    ).showDialog(context);
                  },
                  icon: const Icon(Icons.info_outline),
                  color: Theme.of(context).hintColor,
                  tooltip: S.current.open_condition,
                ),
            ],
          ),
        TileGroup(
          children: <Widget>[
            CustomTile(
                contentPadding: const EdgeInsets.fromLTRB(16, 6, 22, 6),
                leading: db.getIconImage(skill.icon, width: 33),
                title: Text(Language.isJP ? nameJp : name),
                subtitle: Language.isCN ? Text(nameJp) : null,
                trailing: Text('   CD: ${skill.cd}→${skill.cd - 2}')),
            for (Effect effect in skill.effects) ...buildEffect(effect)
          ],
        ),
      ],
    );
  }

  Widget buildPassiveSkill(int index) {
    Skill skill = svt.lPassiveSkills[index];
    return TileGroup(
      children: <Widget>[
        CustomTile(
          contentPadding: const EdgeInsets.fromLTRB(16, 6, 22, 6),
          leading: db.getIconImage(skill.icon, width: 33, height: 33),
          title: Text('${skill.localizedName} ${skill.rank ?? ""}'),
        ),
        for (Effect effect in skill.effects) ...buildEffect(effect),
      ],
    );
  }

  Widget buildAppendSkill(int index) {
    Skill skill = svt.appendSkills[index];
    return TileGroup(
      children: <Widget>[
        CustomTile(
          contentPadding: const EdgeInsets.fromLTRB(16, 6, 22, 6),
          leading: db.getIconImage(skill.icon, width: 33, height: 33),
          title: Text(skill.localizedName),
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
    String description = effect.lDescription;
    if (Language.isEN) {
      description =
          description.split('\n').map((e) => '· ${e.trim()}').join('\n');
    }
    return <Widget>[
      CustomTile(
        contentPadding: EdgeInsets.fromLTRB(16, 6, crossCount == 0 ? 0 : 16, 6),
        subtitle: crossCount == 0
            ? Row(children: [
                Expanded(child: Text(description), flex: 4),
                if (effect.lvData.isNotEmpty)
                  Expanded(
                      child: Center(child: Text(effect.lvData[0])), flex: 1),
              ])
            : Text(description),
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
                      padding: const EdgeInsets.all(5),
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
