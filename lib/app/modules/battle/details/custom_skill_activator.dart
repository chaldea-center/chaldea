import 'dart:math';

import 'package:flutter_easyloading/flutter_easyloading.dart';

import 'package:chaldea/app/api/atlas.dart';
import 'package:chaldea/app/battle/models/battle.dart';
import 'package:chaldea/app/battle/models/skill.dart';
import 'package:chaldea/app/battle/models/svt_entity.dart';
import 'package:chaldea/app/descriptors/skill_descriptor.dart';
import 'package:chaldea/app/modules/battle/svt_option_editor.dart';
import 'package:chaldea/app/modules/common/filter_group.dart';
import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/models/db.dart';
import 'package:chaldea/models/gamedata/gamedata.dart';
import 'package:chaldea/models/userdata/filter_data.dart';
import 'package:chaldea/packages/logger.dart';
import 'package:chaldea/utils/utils.dart';
import 'package:chaldea/widgets/widgets.dart';

class CustomSkillActivator extends StatefulWidget {
  final BattleData battleData;

  const CustomSkillActivator({super.key, required this.battleData});

  @override
  State<CustomSkillActivator> createState() => _CustomSkillActivatorState();
}

class _CustomSkillActivatorState extends State<CustomSkillActivator> {
  BaseSkill? skill;
  int skillLv = 1;
  BattleServantData? activator;
  bool isAlly = true;
  String? skillErrorMsg;
  String? errorMsg;
  Region? region;

  TextEditingController skillIdTextController = TextEditingController();

  @override
  void dispose() {
    super.dispose();
    skillIdTextController.dispose();
  }

  static const _validRegions = [Region.jp, Region.na];

  @override
  Widget build(final BuildContext context) {
    if (region != null && !_validRegions.contains(region)) {
      region = Region.jp;
    }
    errorMsg = skill == null ? S.current.battle_no_skill_selected : null;
    if (skill != null) skillLv = min(skillLv, skill!.functions.first.svals.length);
    final List<BattleServantData> actors = isAlly ? widget.battleData.nonnullAllies : widget.battleData.nonnullEnemies;

    return Scaffold(
      appBar: AppBar(title: Text(S.current.battle_activate_custom_skill)),
      body: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Expanded(
            child: ListView(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: TextFormField(
                    controller: skillIdTextController,
                    decoration: InputDecoration(
                      isDense: true,
                      border: const OutlineInputBorder(),
                      hintText: '969756 ${S.current.logic_type_or} **/JP/skill/969756'.breakWord,
                      labelText: 'skillId ${S.current.logic_type_or} chaldea/AADB skill url',
                      hintStyle: const TextStyle(overflow: TextOverflow.visible),
                      floatingLabelBehavior: FloatingLabelBehavior.always,
                    ),
                  ),
                ),
                Wrap(
                  alignment: WrapAlignment.center,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 8,
                  children: [
                    DropdownButton<Region>(
                      isDense: true,
                      value: region,
                      items: [
                        for (final r in _validRegions)
                          DropdownMenuItem(value: r, child: Text(r.localName, textScaleFactor: 0.9)),
                      ],
                      hint: Text(Region.jp.localName),
                      onChanged: (v) {
                        setState(() {
                          if (v != null) region = v;
                        });
                      },
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        EasyLoading.show();
                        try {
                          await _fetchSkill();
                        } catch (e, s) {
                          logger.e('fetch skill failed', e, s);
                          skillErrorMsg = escapeDioError(e);
                        } finally {
                          EasyLoading.dismiss();
                          if (mounted) setState(() {});
                        }
                      },
                      child: Text(S.current.search),
                    ),
                  ],
                ),
                if (skillErrorMsg != null)
                  SFooter.rich(
                      TextSpan(text: skillErrorMsg, style: TextStyle(color: Theme.of(context).colorScheme.error))),
                if (skill != null)
                  SkillDescriptor(
                    skill: skill!,
                    showEnemy: true,
                    showNone: true,
                    jumpToDetail: false,
                  ),
                if (skill != null && skill!.maxLv > 1)
                  ServantOptionEditPage.buildSlider(
                    padding: EdgeInsets.zero,
                    leadingText: S.current.level,
                    min: 1,
                    max: skill!.functions.first.svals.length,
                    value: skillLv,
                    label: skillLv.toString(),
                    onChange: (v) {
                      skillLv = v.toInt();
                      if (mounted) setState(() {});
                    },
                  ),
                const Divider(),
                ButtonBar(
                  alignment: MainAxisAlignment.start,
                  children: [
                    Text(S.current.battle_select_activator),
                    FilterGroup<bool>(
                      combined: true,
                      options: const [true, false],
                      values: FilterRadioData.nonnull(isAlly),
                      optionBuilder: (value) => Text(value ? S.current.battle_ally_servants : S.current.enemy),
                      onFilterChanged: (v, _) {
                        isAlly = v.radioValue!;
                        if (mounted) setState(() {});
                      },
                    ),
                  ],
                ),
                ButtonBar(
                  alignment: MainAxisAlignment.start,
                  children: [
                    FilterGroup<BattleServantData?>(
                      combined: true,
                      options: [null, ...actors],
                      values: FilterRadioData(activator),
                      optionBuilder: (value) => Text(value == null ? S.current.battle_no_source : value.lBattleName),
                      onFilterChanged: (v, _) {
                        activator = v.radioValue;
                        if (mounted) setState(() {});
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
          kDefaultDivider,
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Text(
                      errorMsg ?? "",
                      style:
                          Theme.of(context).textTheme.bodySmall?.copyWith(color: Theme.of(context).colorScheme.error),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  FilledButton.icon(
                    onPressed: errorMsg != null
                        ? null
                        : () {
                            widget.battleData.pushSnapshot();
                            if (activator != null) widget.battleData.setActivator(activator!);
                            widget.battleData.battleLogger
                                .action('${activator == null ? S.current.battle_no_source : activator!.lBattleName}'
                                    ' - ${S.current.skill}: ${skill!.lName.l}');
                            BattleSkillInfoData.activateSkill(
                              widget.battleData,
                              skill!,
                              skillLv,
                              defaultToAlly: isAlly,
                            );
                            Navigator.of(context).pop(skill);
                          },
                    icon: const Icon(Icons.arrow_right_rounded),
                    label: Text(S.current.battle_activate_custom_skill),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _fetchSkill() async {
    skillErrorMsg = null;
    final text = skillIdTextController.text.trim();
    // quest id and phase
    final match = RegExp(r'(\d+)').firstMatch(text);
    if (match == null) {
      skillErrorMsg = S.current.invalid_input;
      return;
    }
    final skillId = int.parse(match.group(1)!);
    // region
    final regionText = RegExp(r'(JP|NA|CN|TW|KR)/').firstMatch(text)?.group(1);
    Region region = this.region ??= const RegionConverter().fromJson(regionText ?? "");
    // hash
    final hash = RegExp(r'\?hash=([0-9a-zA-Z_\-]{14})$').firstMatch(text)?.group(1);

    if (region == Region.jp) skill = db.gameData.baseSkills[skillId];
    skill ??= await AtlasApi.skill(skillId, region: region);
    if (skill == null) {
      skillErrorMsg = '${S.current.not_found}: /${region.upper}/quest/$skillId';
      if (hash != null) skillErrorMsg = '${skillErrorMsg!}?hash=$hash';
    }
    if (mounted) setState(() {});
  }
}
