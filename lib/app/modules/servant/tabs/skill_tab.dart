import 'package:flutter/material.dart';

import 'package:chaldea/app/api/atlas.dart';
import 'package:chaldea/app/descriptors/skill_descriptor.dart';
import 'package:chaldea/app/modules/common/filter_group.dart';
import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/models/models.dart';
import 'package:chaldea/utils/utils.dart';
import 'package:chaldea/widgets/widgets.dart';

class SvtSkillTab extends StatefulWidget {
  final Servant svt;

  const SvtSkillTab({Key? key, required this.svt}) : super(key: key);

  @override
  State<SvtSkillTab> createState() => _SvtSkillTabState();
}

class _SvtSkillTabState extends State<SvtSkillTab> {
  Servant get svt => widget.svt;

  Map<int, List<NiceSkill>> skillRankUps = {};

  @override
  void initState() {
    super.initState();
    svt.script.skillRankUp?.forEach((key, skillIds) async {
      final skills = skillRankUps.putIfAbsent(key, () => []);
      for (final skillId in skillIds.toSet()) {
        if (skillId == key) continue;
        var skill = db.gameData.baseSkills[skillId]?.toNice();
        if (skill != null) {
          skills.add(skill);
        } else {
          skill = await AtlasApi.skill(skillId);
          if (skill != null) {
            skills.add(skill);
            if (mounted) setState(() {});
          }
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final status = db.curUser.svtStatusOf(svt.collectionNo).cur;
    List<Widget> children = [];
    children.add(SHeader(S.current.active_skill));
    for (final skills in svt.groupedActiveSkills) {
      List<NiceSkill> shownSkills = [];
      for (final skill in skills) {
        if (shownSkills.every((e) => e.id != skill.id)) {
          shownSkills.add(skill);
          shownSkills.addAll(skillRankUps[skill.id] ?? []);
        }
      }
      children.add(_buildSkill(
        shownSkills,
        status.favorite ? status.skills.getOrNull(skills.first.num - 1) : -1,
      ));
    }
    children.add(SHeader(S.current.passive_skill));
    for (final skill in svt.classPassive) {
      children.add(SkillDescriptor.only(
        skill: skill,
        isPlayer: svt.isUserSvt,
      ));
    }
    children.add(SHeader(S.current.append_skill));
    svt.appendPassive.sort2((s) => s.num * 100 + s.priority);
    for (final appendSkill in svt.appendPassive) {
      children.add(SkillDescriptor.only(
        skill: appendSkill.skill,
        isPlayer: svt.isUserSvt,
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
      return SkillDescriptor.only(
        skill: skills.first,
        level: level,
        isPlayer: svt.isUserSvt,
      );
    }
    NiceSkill initSkill =
        svt.getDefaultSkill(skills, db.curUser.region) ?? skills.last;
    return ValueStatefulBuilder<NiceSkill>(
      initValue: initSkill,
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
                onFilterChanged: (v, _) {
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
            SkillDescriptor.only(
                skill: skill, isPlayer: svt.isUserSvt, level: level),
          ],
        );
      },
    );
  }
}
