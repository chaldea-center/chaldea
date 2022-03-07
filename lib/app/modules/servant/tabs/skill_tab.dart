import 'package:chaldea/app/modules/common/filter_group.dart';
import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/models/models.dart';
import 'package:chaldea/utils/utils.dart';
import 'package:chaldea/widgets/widgets.dart';
import 'package:flutter/material.dart';

class SvtSkillTab extends StatelessWidget {
  final Servant svt;

  const SvtSkillTab({Key? key, required this.svt}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    List<Widget> children = [];
    children.add(SHeader(S.current.active_skill));
    for (final skills in svt.groupedActiveSkills) {
      children.add(_buildSkill(skills));
    }
    children.add(SHeader(S.current.passive_skill));
    for (final skill in svt.classPassive) {
      children.add(_buildOneSkill(skill));
    }
    children.add(SHeader(S.current.append_skill));
    svt.appendPassive.sort2((s) => s.num * 100 + s.priority);
    for (final appendSkill in svt.appendPassive) {
      children.add(_buildOneSkill(appendSkill.skill));
    }
    return ListView(children: children);
  }

  Widget _buildSkill(List<NiceSkill> skills) {
    if (skills.length == 1) return _buildOneSkill(skills.first);
    return ValueStatefulBuilder<NiceSkill>(
      initValue: skills.last,
      builder: (context, state) {
        final skill = state.value;
        final toggle = Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: FilterGroup<NiceSkill>(
                shrinkWrap: true,
                combined: true,
                options: skills,
                optionBuilder: (v) => Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
                  child: Text(Transl.skillNames(v.name).l),
                ),
                values: FilterRadioData(skill),
                onFilterChanged: (v) {
                  state.value = v.radioValue!;
                  state.updateState();
                },
              ),
            ),
            if (skill.aiIds?.isNotEmpty == true)
              IconButton(
                padding: const EdgeInsets.all(2),
                constraints: const BoxConstraints(
                  minWidth: 48,
                  minHeight: 24,
                ),
                onPressed: () {
                  SimpleCancelOkDialog(
                    title: Text(Transl.skillNames(skill.name).l),
                    hideCancel: true,
                    content: Text(
                      'TODO',
                      style: Theme.of(context).textTheme.caption,
                    ),
                  ).showDialog(context);
                },
                icon: const Icon(Icons.info_outline),
                color: Theme.of(context).hintColor,
                tooltip: S.current.open_condition,
              ),
          ],
        );
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            toggle,
            _buildOneSkill(skill),
          ],
        );
      },
    );
  }

  Widget _buildOneSkill(NiceSkill skill) {
    int cd0 = 0, cd1 = 0;
    if (skill.coolDown.isNotEmpty) {
      cd0 = skill.coolDown.first;
      cd1 = skill.coolDown.last;
    }
    final header = CustomTile(
      contentPadding: const EdgeInsetsDirectional.fromSTEB(16, 6, 22, 6),
      leading: db2.getIconImage(skill.icon, width: 33),
      title: Text(skill.lName.l),
      subtitle: Transl.isJP ? null : Text(skill.name),
      trailing: cd0 <= 0 && cd1 <= 0
          ? null
          : cd0 == cd1
              ? Text('   CD: $cd0')
              : Text('   CD: $cd0→$cd1'),
    );
    return TileGroup(
      children: [
        header,
        SFooter(
          skill.lDetail ?? '???',
          padding: const EdgeInsetsDirectional.fromSTEB(16, 0, 16, 4),
        )
      ],
    );
  }
}
