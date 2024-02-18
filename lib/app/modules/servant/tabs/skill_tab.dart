import 'package:chaldea/app/api/atlas.dart';
import 'package:chaldea/app/descriptors/cond_target_value.dart';
import 'package:chaldea/app/descriptors/skill_descriptor.dart';
import 'package:chaldea/app/modules/common/filter_group.dart';
import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/models/models.dart';
import 'package:chaldea/utils/utils.dart';
import 'package:chaldea/widgets/widgets.dart';

class SvtSkillTab extends StatefulWidget {
  final Servant svt;

  const SvtSkillTab({super.key, required this.svt});

  @override
  State<SvtSkillTab> createState() => _SvtSkillTabState();

  static bool hasUnusualLimitCond(final NiceSkill skill) {
    final skillSvt = skill.svt;
    return (skill.svt.num == 1 && skillSvt.condLimitCount != 0) ||
        (skill.svt.num == 2 && skillSvt.condLimitCount != 1) ||
        (skill.svt.num == 3 && skillSvt.condLimitCount != 3);
  }

  static Widget releaseCondition(final NiceSkill skill) {
    final skillSvt = skill.svt;

    bool notMain = ['91', '94'].contains(skillSvt.condQuestId.toString().padRight(2).substring(0, 2));
    final quest = db.gameData.quests[skillSvt.condQuestId];
    final jpTime = quest?.openedAt,
        localTime = db.gameData.mappingData.questRelease[skillSvt.condQuestId]?.ofRegion(db.curUser.region);
    return SimpleCancelOkDialog(
      title: Text(skill.lName.l),
      hideCancel: true,
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (skillSvt.condQuestId > 0)
            CondTargetValueDescriptor(
              condType: notMain ? CondType.questClear : CondType.questClearPhase,
              target: skillSvt.condQuestId,
              value: skillSvt.condQuestPhase,
            ),
          Text('${S.current.ascension_short} ${skillSvt.condLimitCount}'),
          if (jpTime != null) Text('JP: ${jpTime.sec2date().toDateString()}'),
          if (db.curUser.region != Region.jp && localTime != null)
            Text('${db.curUser.region.upper}: ${localTime.sec2date().toDateString()}'),
        ],
      ),
    );
  }
}

class _SvtSkillTabState extends State<SvtSkillTab> {
  Servant get svt => widget.svt;

  Map<int, List<NiceSkill>> skillRankUps = {};

  @override
  void initState() {
    super.initState();
    svt.script?.skillRankUp?.forEach((key, skillIds) async {
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
    for (final skills in svt.groupedActiveSkills.values) {
      List<NiceSkill> shownSkills = [];
      for (final skill in skills) {
        if (shownSkills.every((e) => e.id != skill.id)) {
          shownSkills.add(skill);
          shownSkills.addAll(skillRankUps[skill.id] ?? []);
        }
      }
      children.add(_buildSkill(
        shownSkills,
        status.favorite ? status.skills.getOrNull(skills.first.svt.num - 1) : -1,
      ));
    }

    List<NiceSkill> extraPassiveFixed = [], extraPassiveEvent = [], extraPassiveMain = [];
    final extraPassives = svt.extraPassive.toList();
    extraPassives.sort2((e) => e.extraPassive.firstOrNull?.startedAt ?? 0, reversed: true);
    for (final passive in extraPassives) {
      final eventId = passive.extraPassive.firstOrNull?.eventId ?? 0;
      if (eventId == 0) {
        extraPassiveFixed.add(passive);
      } else if (db.gameData.events[eventId]?.warIds.any((e) => e < 1000) == true) {
        extraPassiveMain.add(passive);
      } else {
        extraPassiveEvent.add(passive);
      }
    }

    children.add(SHeader(S.current.passive_skill));
    for (final skill in [...svt.classPassive, ...extraPassiveFixed]) {
      children.add(SkillDescriptor(
        skill: skill,
        showEnemy: !svt.isUserSvt,
      ));
    }
    if (svt.appendPassive.isNotEmpty) children.add(SHeader(S.current.append_skill));
    for (final appendSkill in svt.appendPassive) {
      children.add(SkillDescriptor(
        skill: appendSkill.skill,
        showEnemy: !svt.isUserSvt,
        level: status.favorite ? status.appendSkills.getOrNull(appendSkill.num - 100) : -1,
      ));
    }

    for (final (index, passives) in [extraPassiveEvent, extraPassiveMain].indexed) {
      if (passives.isEmpty) continue;
      children.add(SimpleAccordion(
        headerBuilder: (context, expanded) {
          return SHeader('${passives.length} ${S.current.extra_passive}${index == 1 ? " *" : ""}');
        },
        contentBuilder: (context) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (final skill in passives)
                SkillDescriptor(
                  skill: skill,
                  showEnemy: !svt.isUserSvt,
                )
            ],
          );
        },
      ));
    }

    children.add(const SafeArea(child: SizedBox()));
    return ListView.builder(
      itemCount: children.length,
      itemBuilder: (context, index) => children[index],
    );
  }

  Widget _buildSkill(List<NiceSkill> skills, int? level) {
    if (skills.length == 1 && skills.first.svt.condQuestId <= 0) {
      return SkillDescriptor(
        skill: skills.first,
        level: level,
        showEnemy: !svt.isUserSvt,
      );
    }
    NiceSkill initSkill = svt.getDefaultSkill(skills, db.curUser.region) ?? skills.last;
    return ValueStatefulBuilder<NiceSkill>(
      initValue: initSkill,
      builder: (context, value) {
        final skill = value.value;
        final toggle = Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: FilterGroup<NiceSkill>(
                shrinkWrap: true,
                combined: true,
                options: skills,
                optionBuilder: (v) {
                  String name = Transl.skillNames(v.name).l;
                  if (name.trim().isEmpty) name = '???';
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
                    child: Text(name),
                  );
                },
                values: FilterRadioData.nonnull(skill),
                onFilterChanged: (v, _) {
                  value.value = v.radioValue!;
                },
              ),
            ),
            if (skill.svt.condQuestId > 0 || SvtSkillTab.hasUnusualLimitCond(skill))
              IconButton(
                padding: const EdgeInsets.all(2),
                constraints: const BoxConstraints(
                  minWidth: 48,
                  minHeight: 24,
                ),
                onPressed: () => showDialog(
                  context: context,
                  useRootNavigator: false,
                  builder: (_) => SvtSkillTab.releaseCondition(skill),
                ),
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
            SkillDescriptor(skill: skill, showEnemy: !svt.isUserSvt, level: level),
          ],
        );
      },
    );
  }
}
