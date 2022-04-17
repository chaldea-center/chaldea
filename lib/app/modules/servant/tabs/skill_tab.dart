import 'package:chaldea/app/descriptors/skill_descriptor.dart';
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
    final status = db2.curUser.svtStatusOf(svt.collectionNo).cur;
    List<Widget> children = [];
    children.add(SHeader(S.current.active_skill));
    for (final skills in svt.groupedActiveSkills) {
      List<NiceSkill> shownSkills = [];
      for (final skill in skills) {
        if (shownSkills.every((e) => e.id != skill.id)) {
          shownSkills.add(skill);
        }
      }
      children.add(_buildSkill(
        shownSkills,
        status.favorite ? status.skills.getOrNull(skills.first.num - 1) : -1,
      ));
    }
    children.add(SHeader(S.current.passive_skill));
    for (final skill in svt.classPassive) {
      children.add(SkillDescriptor(skill: skill));
    }
    children.add(SHeader(S.current.append_skill));
    svt.appendPassive.sort2((s) => s.num * 100 + s.priority);
    for (final appendSkill in svt.appendPassive) {
      children.add(SkillDescriptor(
        skill: appendSkill.skill,
        level: status.favorite
            ? status.appendSkills.getOrNull(appendSkill.num - 100)
            : -1,
      ));
    }
    return ListView.builder(
      itemCount: children.length,
      itemBuilder: (context, index) => children[index],
    );
  }

  Widget _buildSkill(List<NiceSkill> skills, int? level) {
    if (skills.length == 1) {
      return SkillDescriptor(skill: skills.first, level: level);
    }
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
            if (skill.condQuestId > 0)
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
            SkillDescriptor(skill: skill, level: level),
          ],
        );
      },
    );
  }
}
