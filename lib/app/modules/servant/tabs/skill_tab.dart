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
    return (skill.num == 1 && skill.condLimitCount != 0) ||
        (skill.num == 2 && skill.condLimitCount != 1) ||
        (skill.num == 3 && skill.condLimitCount != 3);
  }

  static Widget releaseCondition(final NiceSkill skill) {
    bool notMain = ['91', '94'].contains(skill.condQuestId.toString().padRight(2).substring(0, 2));
    final quest = db.gameData.quests[skill.condQuestId];
    final jpTime = quest?.openedAt,
        localTime = db.gameData.mappingData.questRelease[skill.condQuestId]?.ofRegion(db.curUser.region);
    return SimpleCancelOkDialog(
      title: Text(skill.lName.l),
      hideCancel: true,
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (skill.condQuestId > 0)
            CondTargetValueDescriptor(
              condType: notMain ? CondType.questClear : CondType.questClearPhase,
              target: skill.condQuestId,
              value: skill.condQuestPhase,
            ),
          Text('${S.current.ascension_short} ${skill.condLimitCount}'),
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
    for (final skill in [
      ...svt.classPassive,
      ...svt.extraPassive.where((e) => e.extraPassive.any((cond) => cond.eventId == 0))
    ]) {
      children.add(SkillDescriptor(
        skill: skill,
        showEnemy: !svt.isUserSvt,
      ));
    }
    children.add(SHeader(S.current.append_skill));
    svt.appendPassive.sort2((s) => s.num * 100 + s.priority);
    for (final appendSkill in svt.appendPassive) {
      children.add(SkillDescriptor(
        skill: appendSkill.skill,
        showEnemy: !svt.isUserSvt,
        level: status.favorite ? status.appendSkills.getOrNull(appendSkill.num - 100) : -1,
      ));
    }
    final extraPassives = svt.extraPassive.where((e) => e.extraPassive.any((cond) => cond.eventId != 0)).toList();
    if (extraPassives.isNotEmpty) {
      children.add(SimpleAccordion(
        headerBuilder: (context, expanded) {
          return SHeader('${extraPassives.length} ${S.current.event_skill}');
        },
        contentBuilder: (context) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (final skill in extraPassives)
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
    if (skills.length == 1 && skills.first.condQuestId <= 0) {
      return SkillDescriptor(
        skill: skills.first,
        level: level,
        showEnemy: !svt.isUserSvt,
      );
    }
    NiceSkill initSkill = svt.getDefaultSkill(skills, db.curUser.region) ?? skills.last;
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
                  state.value = v.radioValue!;
                  state.updateState();
                },
              ),
            ),
            if (skill.condQuestId > 0 || SvtSkillTab.hasUnusualLimitCond(skill))
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
