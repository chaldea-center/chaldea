import 'dart:math';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

import 'package:chaldea/app/api/atlas.dart';
import 'package:chaldea/app/app.dart';
import 'package:chaldea/app/battle/models/user.dart';
import 'package:chaldea/app/modules/common/builders.dart';
import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/models/gamedata/individuality.dart' show Individuality;
import 'package:chaldea/models/models.dart';
import 'package:chaldea/utils/utils.dart';
import 'package:chaldea/widgets/widgets.dart';
import '../battle/formation/team.dart';

const int _kMaxSvtNum = 6;

String _strRate(int value) => value.format(percent: true, base: 10);

class SvtBondBonusResult {
  int baseValue = 0;

  int equipAddRate = 0;
  int equipAddValue = 0;

  int eventAddRate = 0;
  int eventAddValue = 0;

  int customAddRate = 0;
  int customAddValue = 0;

  int frontlineAddRate = 0;

  int teapotTimes = 1;

  int get totalAddRate => min(eventAddRate + equipAddRate + customAddRate, ConstData.constants.maxFriendShipUpRatio);

  int get totalAddValue => equipAddValue + eventAddValue + customAddValue;

  // final result
  // （（礼装羁绊+活动羁绊）*首位羁绊+50羁绊礼装）*茶壶
  int get totalBond {
    int value = (baseValue * (1 + frontlineAddRate / 1000)).floor();
    value = (value * (1 + totalAddRate / 1000)).floor();
    value += totalAddValue;
    value *= teapotTimes;
    return value;
  }
}

class FormationBondTab extends StatefulWidget {
  /// null: persistent instance backed by `db.userData.formationBondOption`, saved on dispose;
  /// non-null: temporary instance (e.g. opened from battle simulation), never written back.
  final FormationBondOption? option;
  const FormationBondTab({super.key, this.option});

  @override
  State<FormationBondTab> createState() => _FormationBondTabState();
}

class _FormationBondTabState extends State<FormationBondTab> {
  late final FormationBondOption option;
  // runtime formation, converted from/to [FormationBondOption.teamFormation] on load/save
  final BattleTeamSetup formation = BattleTeamSetup();
  QuestPhase? questEntity;

  /// False until [restore] finishes. [dispose] refuses to persist before then,
  /// otherwise leaving the tab mid-restore would overwrite the stored
  /// formation with the still-empty runtime one.
  bool _restored = false;

  @override
  void initState() {
    super.initState();
    option = widget.option ?? db.userData.curUser.formationBondOption;
    restore();
  }

  /// Restore the two non-JSON runtime values (team setup, quest entity) from persisted option.
  /// Quest resolution falls back to network; on failure the quest is cleared but other settings kept.
  /// All other fields are referenced directly on [option], no conversion needed.
  Future<void> restore() async {
    final questInfo = option.quest;
    if (questInfo != null) {
      questEntity =
          db.gameData.getQuestPhase(questInfo.id, questInfo.phase) ??
          await AtlasApi.questPhase(questInfo.id, questInfo.phase);
      if (questEntity == null) option.quest = null;
    }

    final saved = option.teamFormation;
    final svts = <PlayerSvtData>[];
    for (int index = 0; index < max(6, saved.svts.length); index++) {
      svts.add(await PlayerSvtData.fromStoredData(saved.svts.getOrNull(index)));
    }
    formation.svts
      ..clear()
      ..addAll(svts);
    formation.mysticCodeData.loadStoredData(saved.mysticCode);
    _restored = true;
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    if (widget.option == null && _restored) saveData();
    super.dispose();
  }

  /// Persist runtime formation/quest back into [option]. Only called for the persistent instance.
  void saveData() {
    option.teamFormation = formation.toFormationData();
    option.quest = questEntity == null ? null : BattleQuestInfo.quest(questEntity!);
  }

  void validate() {
    validateFormationBondOption(option, questEntity);
  }

  List<SvtBondBonusResult> calcResults() => calcFormationBondResults(option, questEntity, formation);

  String strTime(int t) => t.sec2date().toStringShort(omitSec: true);

  @override
  Widget build(BuildContext context) {
    final quest = questEntity;
    final eventId = quest?.logicEventId;
    final eventSkillIds = {
      if (eventId != null)
        for (final svt in db.gameData.servantsNoDup.values)
          for (final skill in svt.extraPassive)
            if (skill.functions.any((e) => e.funcType == FuncType.servantFriendshipUp))
              for (final extraPassive in skill.extraPassive)
                if (extraPassive.getValidEventIds().contains(eventId)) skill.id,
    }.toList()..sort();
    validate();
    final results = calcResults();
    // resolve id/idx-keyed campaigns into runtime Event/EventCampaign instances
    final eventCampaignToggles = <(Event, EventCampaign, bool)>[];
    for (final (eventId, eventCampaigns) in option.campaigns.items) {
      final event = db.gameData.events[eventId];
      if (event == null) continue;
      for (final (idx, enabled) in eventCampaigns.items) {
        final campaign = event.campaigns.firstWhereOrNull((e) => e.idx == idx);
        if (campaign == null) continue;
        eventCampaignToggles.add((event, campaign, enabled));
      }
    }
    return ListView(
      children: [
        TeamSetupCard(
          formation: formation,
          quest: quest,
          playerRegion: Region.jp,
          onChanged: () {
            if (mounted) setState(() {});
          },
        ),
        DividerWithTitle(title: '${S.current.general_custom} / ${S.current.bond} 15 / ${S.current.bond_limit}'),
        Row(
          children: [
            for (final index in range(option.svtBonus.length)) Expanded(child: Center(child: buildExtraBonus(index))),
          ],
        ),
        DividerWithTitle(title: '${S.current.results} (base ${quest?.bond ?? 0})', indent: 16),
        Row(
          children: [
            for (final index in range(results.length))
              Expanded(child: Center(child: buildResult(index, results[index]))),
          ],
        ),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: Text.rich(
            TextSpan(
              text: '${S.current.total} ',
              children: [
                TextSpan(
                  text: Maths.sum(results.map((e) => e.totalBond)).toString(),
                  style: TextStyle(color: Theme.of(context).colorScheme.secondary),
                ),
                const TextSpan(text: '  COST '),
                TextSpan(
                  text: formation.totalCost.toString(),
                  style: TextStyle(color: Theme.of(context).colorScheme.secondary),
                ),
              ],
            ),
            textAlign: TextAlign.center,
          ),
        ),
        DividerWithTitle(title: S.current.settings_tab_name),
        BondQuestPicker(
          quest: quest,
          onChanged: (v) {
            questEntity = v;
            if (mounted) setState(() {});
          },
        ),
        DividerWithTitle(title: S.current.event, indent: 16),
        SwitchListTile.adaptive(
          dense: true,
          title: Text(S.current.event_skill),
          subtitle: eventSkillIds.isEmpty ? null : Text('${db.gameData.events[eventId]?.lShortName.l ?? eventId}'),
          value: option.enableEvent,
          onChanged: (v) {
            setState(() {
              option.enableEvent = v;
            });
          },
        ),
        if (eventSkillIds.isNotEmpty)
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Wrap(
              spacing: 8,
              runSpacing: 4,
              children: [
                for (final skillId in eventSkillIds)
                  Text.rich(
                    SharedBuilder.textButtonSpan(
                      context: context,
                      text: db.gameData.baseSkills[skillId]?.lName.l ?? skillId.toString(),
                      onTap: () => router.push(url: Routes.skillI(skillId)),
                    ),
                    style: TextStyle(fontSize: 12),
                  ),
              ],
            ),
          ),
        DividerWithTitle(title: 'misc', indent: 16),
        ListTile(
          dense: true,
          leading: Item.iconBuilder(
            context: context,
            item: null,
            itemId: Items.teapotId,
            width: 28,
            jumpToDetail: false,
          ),
          title: Text(Transl.itemNames('星見のティーポット').l),
          trailing: DropdownButton<int>(
            value: option.teapotTimes,
            items: [
              for (final times in [1, 2, 3]) DropdownMenuItem(value: times, child: Text(times == 1 ? '--' : '×$times')),
            ],
            onChanged: (v) {
              setState(() {
                if (v != null) option.teapotTimes = v;
              });
            },
          ),
        ),
        SwitchListTile.adaptive(
          dense: true,
          value: option.frontlineBonus,
          title: Text("${S.current.bond_bonus}: ${S.current.team_starting_member}"),
          subtitle: Text(
            '${Transl.funcTargetType(FuncTargetType.self).l}+20%; [${S.current.support_servant_short}] ${Transl.funcTargetType(FuncTargetType.ptFull).l} +4%',
          ),
          onChanged: (v) {
            setState(() {
              option.frontlineBonus = v;
            });
          },
        ),
        if (eventCampaignToggles.isNotEmpty) DividerWithTitle(title: S.current.event_campaign, indent: 16),
        for (final (event, campaign, enabled) in eventCampaignToggles)
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: SwitchListTile.adaptive(
                  dense: true,
                  title: Text(event.lShortName.l),
                  subtitle: Text(
                    '${S.current.bond} ${campaign.calcType.operatorText}${campaign.value.format(percent: true, base: 10)}'
                    '\n${strTime(event.startedAt)}~${strTime(event.endedAt)}',
                  ),
                  value: enabled,
                  onChanged: (v) {
                    setState(() {
                      (option.campaigns[event.id] ??= {})[campaign.idx] = v;
                    });
                  },
                ),
              ),
              IconButton(onPressed: event.routeTo, icon: Icon(DirectionalIcons.keyboard_arrow_forward(context))),
            ],
          ),
      ],
    );
  }

  Widget buildExtraBonus(int index) {
    final deckSvt = formation.svts.getOrNull(index);
    if (deckSvt == null || deckSvt.svt == null || deckSvt.supportType.isSupport) return const SizedBox.shrink();
    final detail = option.svtBonus[index];

    Widget _textButton(String text, VoidCallback onTap) {
      Widget child = InkWell(
        onTap: onTap,
        child: Container(
          constraints: BoxConstraints(minHeight: 18),
          padding: EdgeInsets.symmetric(vertical: 2),
          child: AutoSizeText(
            text,
            maxLines: 1,
            minFontSize: 2,
            style: TextStyle(color: Theme.of(context).colorScheme.primary),
          ),
        ),
      );
      return child;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        _textButton('+${detail.addValue}', () {
          InputCancelOkDialog.number(
            title: 'Bond Add Value',
            autofocus: true,
            initValue: detail.addValue,
            validate: (v) => v >= 0,
            onSubmit: (value) {
              detail.addValue = value;
              if (mounted) setState(() {});
            },
          ).showDialog(context);
        }),
        _textButton('+${detail.addRate.format(percent: true, base: 10)}', () {
          InputCancelOkDialog(
            title: 'Bond Add Percent(%)',
            autofocus: true,
            initValue: (detail.addValue / 10).format(),
            validate: (s) => (double.parse(s) * 10).toInt() >= 0,
            onSubmit: (s) {
              detail.addRate = (double.parse(s) * 10).toInt();
              if (mounted) setState(() {});
            },
          ).showDialog(context);
        }),
        Checkbox(
          visualDensity: VisualDensity.compact,
          value: detail.isBond15,
          onChanged: (v) {
            setState(() {
              detail.isBond15 = v!;
            });
          },
        ),
        Checkbox(
          visualDensity: VisualDensity.compact,
          value: detail.isBondReachLimit,
          onChanged: (v) {
            setState(() {
              detail.isBondReachLimit = v!;
            });
          },
        ),
      ],
    );
  }

  Widget buildResult(int index, SvtBondBonusResult result) {
    final deckSvt = formation.svts.getOrNull(index);
    if (deckSvt == null || deckSvt.svt == null) return const SizedBox.shrink();
    final detail = option.svtBonus[index];
    if (deckSvt.supportType.isSupport) {
      return Text('-', style: Theme.of(context).textTheme.bodySmall);
    } else if (detail.isBondReachLimit) {
      return Text('Lv.MAX', style: Theme.of(context).textTheme.bodySmall);
    }

    Widget _row(String text, [double? textScaleFactor]) {
      return InkWell(
        onTap: () {
          Widget _param(String name, String value) {
            return ListTile(contentPadding: EdgeInsets.zero, dense: true, title: Text(name), trailing: Text(value));
          }

          SimpleConfirmDialog(
            title: Text('Params'),
            scrollable: true,
            showCancel: false,
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (final (k, v) in <String, String>{
                  "baseValue": result.baseValue.toString(),
                  "equipAddRate": _strRate(result.equipAddRate),
                  "equipAddValue": result.equipAddValue.toString(),
                  "eventAddRate": _strRate(result.eventAddRate),
                  "eventAddValue": result.eventAddValue.toString(),
                  "customAddRate": _strRate(result.customAddRate),
                  "customAddValue": result.customAddValue.toString(),
                  "frontlineAddRate": _strRate(result.frontlineAddRate),
                }.items)
                  _param(k, v),
                kDefaultDivider,
                for (final (k, v) in <String, String>{
                  "totalAddRate": _strRate(result.totalAddRate),
                  "totalAddValue": '+${result.totalAddValue}',
                  "teapotTimes": '×${result.teapotTimes}',
                  "totalBond": result.totalBond.toString(),
                }.items)
                  _param(k, v),
              ],
            ),
          ).showDialog(context);
        },
        child: AutoSizeText(text, maxLines: 1, maxFontSize: 16, minFontSize: 2, textScaleFactor: textScaleFactor),
      );
    }

    final totalBond = result.totalBond;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [_row('+${totalBond - result.baseValue}', 0.9), _row(totalBond.toString())],
    );
  }
}

/// Recomputes the derived fields of [option] for [quest]: clamps the teapot
/// multiplier, pads `svtBonus` to [_kMaxSvtNum], drops an out-of-range
/// `fixedDate`, and rebuilds the campaign toggle map from the game data.
///
/// Shared by [FormationBondTab] and [BondSolverTab] so a quest's campaign
/// toggles are resolved in exactly one place.
void validateFormationBondOption(FormationBondOption option, QuestPhase? quest) {
  option.teapotTimes = option.teapotTimes.clamp(1, 3);
  if (option.svtBonus.length < _kMaxSvtNum) {
    option.svtBonus = List.generate(
      _kMaxSvtNum,
      (index) => option.svtBonus.getOrNull(index) ?? FormationBondSvtBonus(),
    );
  }
  if (quest == null) return;
  final startedAt = quest.openedAt, endedAt = quest.closedAt;

  if (option.fixedDate != null) {
    if (option.fixedDate! < startedAt || option.fixedDate! > endedAt) {
      option.fixedDate = null;
    }
  }

  final prevData = option.campaigns;
  option.campaigns = {};
  for (final event in db.gameData.events.values) {
    if (event.startedAt >= endedAt || event.endedAt <= startedAt) continue;
    if (!event.isCampaignQuest(quest.id)) continue;
    for (final campaign in event.campaigns) {
      if (campaign.target != CombineAdjustTarget.questFriendship) continue;
      if (campaign.warIds.isNotEmpty && !campaign.warIds.contains(quest.warId)) continue;
      if (campaign.warGroupIds.isNotEmpty) {
        final warGroups = quest.war?.groups ?? [];
        if (warGroups.isEmpty) continue;
        if (!campaign.warGroupIds.any((warGroupId) {
          final warGroup = quest.war?.groups.firstWhereOrNull((e) => e.id == warGroupId);
          if (warGroup == null) return false;
          return quest.afterClear == warGroup.questAfterClear && quest.type == warGroup.questType;
        })) {
          continue;
        }
      }

      if (campaign.target == CombineAdjustTarget.questFriendship && event.isCampaignQuest(quest.id)) {
        (option.campaigns[event.id] ??= {})[campaign.idx] ??=
            prevData[event.id]?[campaign.idx] ?? (quest.closedAt < kNeverClosedTimestamp);
      }
    }
  }
  option.campaigns = sortDict(
    option.campaigns,
    compare: (a, b) => (db.gameData.events[b.key]?.startedAt ?? 0) - (db.gameData.events[a.key]?.startedAt ?? 0),
  );
}

/// Quest (id + phase) picker shared by [FormationBondTab] and [BondSolverTab].
///
/// Resolves the chosen quest phase from local game data first and falls back to
/// the network; reports the resolved phase through [onChanged] (null on failure).
class BondQuestPicker extends StatelessWidget {
  final QuestPhase? quest;
  final ValueChanged<QuestPhase?> onChanged;

  const BondQuestPicker({super.key, required this.quest, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final quest = this.quest;
    String strTime(int t) => t.sec2date().toStringShort(omitSec: true);
    return ListTile(
      dense: true,
      title: Text('${S.current.quest} ID'),
      subtitle: quest == null
          ? null
          : Text('${quest.lNameWithChapter}\n@${quest.lSpot.l}\n${strTime(quest.openedAt)}~${strTime(quest.closedAt)}'),
      onTap: quest?.routeTo,
      trailing: TextButton(
        onPressed: () {
          InputCancelOkDialog.number(
            title: 'Quest ID',
            initValue: quest?.id,
            validate: (v) => db.gameData.quests.containsKey(v),
            onSubmit: (v) async {
              final _quest = db.gameData.quests[v];
              if (_quest == null || !context.mounted) return;
              int? phase;
              if (_quest.phases.length == 1) {
                phase = _quest.phases.single;
              } else {
                phase = await router.showDialog<int>(
                  builder: (context) => SimpleDialog(
                    title: const Text("Quest Phase"),
                    children: [
                      for (final phase in _quest.phases)
                        ListTile(
                          enabled: !_quest.phasesNoBattle.contains(phase),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 24),
                          onTap: () => Navigator.pop(context, phase),
                          title: Text('phase $phase'),
                        ),
                    ],
                  ),
                );
              }
              if (phase == null || !_quest.phases.contains(phase)) return;

              final questPhase = await showEasyLoading(() => AtlasApi.questPhase(_quest.id, phase!));
              if (questPhase == null) {
                EasyLoading.showError(S.current.not_found);
                return;
              }
              onChanged(questPhase);
            },
          ).showDialog(context);
        },
        child: Text(quest == null ? '0' : '${quest.id}/${quest.phase}'),
      ),
    );
  }
}

///  ======= svals =====
///              Target: 1 ?
///       Individuality: 0, 2871, 2917...
///             EventId: 80283, 80285...
///           RateCount: 0, 10, 20, 50, 100, 200, 250, 300, 500, 1000
///     ApplySupportSvt: 0
///  OnlyMaxFuncGroupId: 1 ?
///            AddCount: 50
/// ===== followerVals =====
///       Individuality: 0
///           RateCount: 30, 150
///
/// Pure bond calculation for one fixed team. Extracted from the tab state so
/// the bond solver can be tested against the manual page's exact semantics.
List<SvtBondBonusResult> calcFormationBondResults(
  FormationBondOption option,
  QuestPhase? quest,
  BattleTeamSetup formation,
) {
  final results = List.generate(option.svtBonus.length, (_) => SvtBondBonusResult()..baseValue = quest?.bond ?? 0);

  final eventId = quest?.logicEventId ?? 0;

  for (final (deckPos, deckSvt) in formation.svts.take(_kMaxSvtNum).indexed) {
    final svt = deckSvt.svt;
    if (svt == null) continue;
    final selfResult = results[deckPos];

    final svtIndivs = svt.getIndividuality(eventId, deckSvt.limitCount);

    void checkAddFunctions(NiceSkill skill, bool isEquipSkill) {
      if (skill.actIndividuality.isNotEmpty &&
          !Individuality.checkSignedIndivPartialMatch(self: svtIndivs, signedTarget: skill.actIndividuality)) {
        return;
      }
      for (final func in skill.functions) {
        if (func.funcType != FuncType.servantFriendshipUp) continue;
        if (quest != null &&
            func.funcquestTvals.isNotEmpty &&
            !Individuality.checkSignedIndivPartialMatch(
              self: quest.questIndividuality,
              signedTarget: func.funcquestTvals,
            )) {
          continue;
        }

        DataVals? vals = switch (deckSvt.supportType) {
          SupportSvtType.none => func.svals.firstOrNull,
          SupportSvtType.friend || SupportSvtType.npc => func.followerVals?.firstOrNull ?? func.svals.firstOrNull,
        };
        if (vals == null) continue;
        if (vals.ApplySupportSvt == 0 && deckSvt.supportType.isSupport) continue;
        if (vals.EventId != null && vals.EventId != 0 && vals.EventId != eventId) continue;
        final requipredIndiv = vals.Individuality ?? 0;
        if (requipredIndiv != 0 &&
            !Individuality.checkSignedIndivPartialMatch(self: svtIndivs, signedTarget: [requipredIndiv])) {
          continue;
        }
        List<SvtBondBonusResult> targets = switch (func.funcTargetType) {
          FuncTargetType.self => [selfResult],
          FuncTargetType.ptFull => results.toList(),
          _ => [],
        };
        targets.retainWhere((target) {
          final funcOverwriteTvalsList = func.getOverwriteTvalsList();
          if (funcOverwriteTvalsList.isEmpty && func.functvals.isEmpty) return true;
          final int targetIndex = results.indexOf(target);
          final targetDeckSvt = formation.svts.getOrNull(targetIndex);
          final targetIndivs = targetDeckSvt?.svt?.getIndividuality(eventId, targetDeckSvt.limitCount) ?? [];
          if (funcOverwriteTvalsList.isNotEmpty) {
            if (funcOverwriteTvalsList.every((andVals) {
              return !Individuality.checkSignedIndivAllMatch(self: targetIndivs, signedTarget: andVals);
            })) {
              return false;
            }
          } else if (func.functvals.isNotEmpty) {
            if (!Individuality.checkSignedIndivPartialMatch(self: targetIndivs, signedTarget: func.functvals)) {
              return false;
            }
          }
          return true;
        });

        for (final target in targets) {
          if (isEquipSkill) {
            target.equipAddRate += vals.RateCount ?? 0;
            target.equipAddValue += vals.AddCount ?? 0;
          } else {
            target.eventAddRate += vals.RateCount ?? 0;
            target.eventAddValue += vals.AddCount ?? 0;
          }
        }
      }
    }

    // check event bonus
    if (option.enableEvent && quest != null) {
      Map<int, Map<int, NiceSkill>> groupedEventSkills = {};
      for (final skill in svt.extraPassive) {
        if (skill.id == 970663) continue; // 夢火の導き Bond 15
        final eventPassives = skill.extraPassive.where((eventPassive) {
          if (eventPassive.startedAt > quest.closedAt || eventPassive.endedAt < quest.openedAt) return false;
          final eventIds = eventPassive.getValidEventIds();
          if (eventIds.isNotEmpty && !eventIds.contains(eventId)) return false;
          return true;
        }).toList();
        if (eventPassives.isEmpty) continue;

        for (final eventPassive in eventPassives) {
          groupedEventSkills.putIfAbsent(eventPassive.num, () => {})[eventPassive.priority] = skill;
        }
      }
      for (final skills in groupedEventSkills.values) {
        final skill = skills[Maths.max<int>(skills.keys)]!;
        checkAddFunctions(skill, false);
      }
    }
    // check campaign bonus
    for (final (eventId, eventCampaigns) in option.campaigns.items) {
      final event = db.gameData.events[eventId];
      if (event == null) continue;
      for (final (idx, enabled) in eventCampaigns.items) {
        final campaign = event.campaigns.firstWhereOrNull((e) => e.idx == idx);
        if (campaign == null || !enabled) continue;
        if (campaign.targetIds.contains(svt.id)) {
          switch (campaign.calcType) {
            case EventCombineCalc.addition:
              selfResult.eventAddRate += max(0, campaign.value);
              break;
            case EventCombineCalc.multiplication:
              selfResult.eventAddRate += max(0, campaign.value - 1000);
            case EventCombineCalc.fixedValue:
            case EventCombineCalc.none:
              break;
          }
        }
      }
    }
    // check ce bonus (normal + event)
    final equips = [
      deckSvt.equip1,
      // equip2 is bond
      if (quest?.isUseGrandBoard == true && deckSvt.grandSvt) deckSvt.equip3,
    ];
    for (final equip in equips) {
      final ce = equip.ce;
      if (ce == null) continue;
      for (final skill in ce.getActivatedSkills(equip.limitBreak).values.expand((e) => e)) {
        checkAddFunctions(skill, true);
      }
    }
    // check position
    if (option.frontlineBonus) {
      final bool isFront = deckPos < 3;
      switch (deckSvt.supportType) {
        case SupportSvtType.none:
          if (isFront) {
            selfResult.frontlineAddRate += 200;
          }
          break;
        case SupportSvtType.friend:
        case SupportSvtType.npc:
          if (isFront) {
            for (final result in results) {
              result.frontlineAddRate += 40;
            }
          }
          break;
      }
    }

    // extra: custom bond
    final extraBonus = option.svtBonus[deckPos];
    selfResult.customAddRate += extraBonus.addRate;
    selfResult.customAddValue += extraBonus.addValue;
    // check bond 15
    if (extraBonus.isBond15 && !deckSvt.supportType.isSupport) {
      for (final result in results) {
        result.customAddRate += 250;
      }
    }

    // check teapot
    for (final result in results) {
      result.teapotTimes = option.teapotTimes;
    }
  }

  for (final index in range(results.length)) {
    final deckSvt = formation.svts.getOrNull(index);
    if (deckSvt == null ||
        deckSvt.svt == null ||
        deckSvt.supportType.isSupport ||
        option.svtBonus[index].isBondReachLimit) {
      results[index] = SvtBondBonusResult();
    }
  }
  return results;
}
