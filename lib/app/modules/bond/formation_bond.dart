import 'dart:math';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

import 'package:chaldea/app/api/atlas.dart';
import 'package:chaldea/app/app.dart';
import 'package:chaldea/app/battle/models/user.dart';
import 'package:chaldea/app/battle/utils/buff_utils.dart';
import 'package:chaldea/app/modules/common/builders.dart';
import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/models/models.dart';
import 'package:chaldea/utils/utils.dart';
import 'package:chaldea/widgets/widgets.dart';
import '../battle/formation/team.dart';

const int _kMaxSvtNum = 6;

String _strRate(int value) => value.format(percent: true, base: 10);

class SvtExtraBondBonus {
  int addValue;
  int addRate;
  bool isBond15;

  SvtExtraBondBonus({this.addValue = 0, this.addRate = 0, this.isBond15 = false});
}

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

  // final result
  // （（礼装羁绊+活动羁绊）*首位羁绊+50羁绊礼装）*茶壶
  int get totalBond {
    int value = (baseValue * (1 + frontlineAddRate / 1000)).floor();
    value = (value * (1 + (eventAddRate + equipAddRate + customAddRate) / 1000)).floor();
    value += equipAddValue + eventAddValue + customAddValue;
    value *= teapotTimes;
    return value;
  }
}

class FormationBondOption {
  BattleTeamSetup formation;
  QuestPhase? quest;
  bool enableEvent;
  Map<Event, Map<EventCampaign, bool>> campaigns;
  int? fixedDate;
  List<SvtExtraBondBonus> svtBonus;
  // progress
  bool frontlineBonus;
  int teapotTimes;

  FormationBondOption({
    BattleTeamSetup? formation,
    this.quest,
    this.enableEvent = true,
    Map<Event, Map<EventCampaign, bool>>? campaigns,
    this.fixedDate,
    List<SvtExtraBondBonus>? svtBonus,
    this.frontlineBonus = true,
    this.teapotTimes = 1,
  }) : formation = formation ?? BattleTeamSetup(),
       campaigns = campaigns ?? {},
       svtBonus = svtBonus ?? List.generate(_kMaxSvtNum, (_) => SvtExtraBondBonus());
}

class FormationBondTab extends StatefulWidget {
  final FormationBondOption? option;
  const FormationBondTab({super.key, this.option});

  @override
  State<FormationBondTab> createState() => _FormationBondTabState();
}

class _FormationBondTabState extends State<FormationBondTab> {
  late final option = widget.option ?? FormationBondOption(quest: db.gameData.getQuestPhase(94137202));

  void validate() {
    option.teapotTimes = option.teapotTimes.clamp(1, 3);
    final quest = option.quest;
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
          (option.campaigns[event] ??= {})[campaign] ??=
              prevData[event]?[campaign] ?? (quest.closedAt < kNeverClosedTimestamp);
        }
      }
    }
    option.campaigns = sortDict(option.campaigns, compare: (a, b) => b.key.startedAt - a.key.startedAt);
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

  List<SvtBondBonusResult> calcResults() {
    final quest = option.quest;
    final results = List.generate(option.svtBonus.length, (_) => SvtBondBonusResult()..baseValue = quest?.bond ?? 0);

    final eventId = quest?.logicEvent?.id ?? 0;

    for (final (deckPos, deckSvt) in option.formation.allSvts.take(_kMaxSvtNum).indexed) {
      final svt = deckSvt.svt;
      if (svt == null) continue;
      final selfResult = results[deckPos];

      final svtIndivs = svt.getIndividuality(eventId, deckSvt.limitCount);

      void checkAddFunctions(NiceSkill skill, bool isEquipSkill) {
        if (skill.actIndividuality.isNotEmpty &&
            !checkSignedIndividualities2(myTraits: svtIndivs, requiredTraits: skill.actIndividuality)) {
          return;
        }
        for (final func in skill.functions) {
          if (func.funcType != FuncType.servantFriendshipUp) continue;

          if (quest != null &&
              func.funcquestTvals.isNotEmpty &&
              !checkSignedIndividualities2(myTraits: quest.questIndividuality, requiredTraits: func.funcquestTvals)) {
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
              !checkSignedIndividualities2(myTraits: svtIndivs, requiredTraits: NiceTrait.list([requipredIndiv]))) {
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
            final targetDeckSvt = option.formation.allSvts.getOrNull(targetIndex);
            final targetIndivs = targetDeckSvt?.svt?.getIndividuality(eventId, targetDeckSvt.limitCount) ?? [];
            if (funcOverwriteTvalsList.isNotEmpty) {
              if (funcOverwriteTvalsList.every((andVals) {
                return !checkSignedIndividualities2(
                  myTraits: targetIndivs,
                  requiredTraits: andVals,
                  positiveMatchFunc: allMatch,
                  negativeMatchFunc: allMatch,
                );
              })) {
                return false;
              }
            } else if (func.functvals.isNotEmpty) {
              if (!checkSignedIndividualities2(myTraits: targetIndivs, requiredTraits: func.functvals)) {
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
              target.eventAddRate += vals.AddCount ?? 0;
            }
          }
        }
      }

      // check event bonus
      if (option.enableEvent && eventId != 0) {
        // Mash has eventId=0
        Set<int> usedEventSkillIds = {};
        for (final skill in svt.extraPassive) {
          if (usedEventSkillIds.contains(skill.id)) continue;
          if (!skill.extraPassive.any((extraPassive) => extraPassive.eventId == eventId)) continue;
          usedEventSkillIds.add(skill.id);

          checkAddFunctions(skill, false);
        }
      }
      // check campaign bonus
      for (final campaigns in option.campaigns.values) {
        for (final (campaign, enabled) in campaigns.items) {
          if (enabled && campaign.targetIds.contains(svt.id)) {
            switch (campaign.calcType) {
              case EventCombineCalc.addition:
                selfResult.eventAddRate += max(0, campaign.value);
                break;
              case EventCombineCalc.multiplication:
                selfResult.eventAddRate += max(0, campaign.value - 1000);
              case EventCombineCalc.fixedValue:
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
      final deckSvt = option.formation.allSvts.getOrNull(index);
      if (deckSvt == null || deckSvt.svt == null || deckSvt.supportType.isSupport || option.svtBonus[index].isBond15) {
        results[index] = SvtBondBonusResult();
      }
    }
    return results;
  }

  String strTime(int t) => t.sec2date().toStringShort(omitSec: true);

  @override
  Widget build(BuildContext context) {
    final quest = option.quest;
    final event = quest?.logicEvent;
    final eventSkillIds = {
      if (event != null)
        for (final svt in db.gameData.servantsNoDup.values)
          for (final skill in svt.extraPassive)
            if (skill.functions.any((e) => e.funcType == FuncType.servantFriendshipUp))
              for (final extraPassive in skill.extraPassive)
                if (extraPassive.eventId == event.id) skill.id,
    }.toList()..sort();
    validate();
    final results = calcResults();
    return ListView(
      children: [
        TeamSetupCard(
          formation: option.formation,
          quest: option.quest,
          playerRegion: Region.jp,
          onChanged: () {
            if (mounted) setState(() {});
          },
        ),
        DividerWithTitle(title: '${S.current.general_custom} / ${S.current.bond} 15'),
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
                TextSpan(text: '  COST ${option.formation.totalCost}'),
              ],
            ),
            textAlign: TextAlign.center,
          ),
        ),
        DividerWithTitle(title: S.current.settings_tab_name),
        ListTile(
          dense: true,
          title: Text('${S.current.quest} ID'),
          subtitle: quest == null
              ? null
              : Text(
                  '${quest.lNameWithChapter}\n@${quest.lSpot.l}\n${strTime(quest.openedAt)}~${strTime(quest.closedAt)}',
                ),
          onTap: quest?.routeTo,
          trailing: TextButton(
            onPressed: () {
              InputCancelOkDialog.number(
                title: 'Quest ID',
                initValue: quest?.id,
                validate: (v) => db.gameData.quests.containsKey(v),
                onSubmit: (v) {
                  final _quest = db.gameData.quests[v];
                  if (_quest == null || !mounted) return;
                  router.showDialog(
                    builder: (context) => SimpleDialog(
                      title: Text("Quest Phase"),
                      children: [
                        for (final phase in _quest.phases)
                          ListTile(
                            enabled: !_quest.phasesNoBattle.contains(phase),
                            contentPadding: EdgeInsets.symmetric(horizontal: 24),
                            onTap: () async {
                              Navigator.pop(context);
                              final questPhase = await showEasyLoading(() => AtlasApi.questPhase(_quest.id, phase));
                              if (questPhase == null) {
                                EasyLoading.showError(S.current.not_found);
                                return;
                              }
                              option.quest = questPhase;
                              if (mounted) setState(() {});
                            },
                            title: Text('phase $phase'),
                          ),
                      ],
                    ),
                  );
                },
              ).showDialog(context);
            },
            child: Text(option.quest == null ? '0' : '${option.quest?.id}/${option.quest?.phase}'),
          ),
        ),
        DividerWithTitle(title: S.current.event, indent: 16),
        SwitchListTile.adaptive(
          dense: true,
          title: Text(S.current.event_skill),
          subtitle: eventSkillIds.isEmpty ? null : Text('${event?.lShortName.l}'),
          value: option.enableEvent,
          onChanged: event == null
              ? null
              : (v) {
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
          leading: Item.iconBuilder(context: context, item: null, itemId: 94065901, width: 28, jumpToDetail: false),
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
        if (option.campaigns.isNotEmpty) DividerWithTitle(title: S.current.event_campaign, indent: 16),
        for (final (event, campaigns) in option.campaigns.items)
          for (final campaign in campaigns.keys)
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
                    value: campaigns[campaign] ?? true,
                    onChanged: (v) {
                      setState(() {
                        campaigns[campaign] = v;
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
    final deckSvt = option.formation.allSvts.getOrNull(index);
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
      ],
    );
  }

  Widget buildResult(int index, SvtBondBonusResult result) {
    final deckSvt = option.formation.allSvts.getOrNull(index);
    if (deckSvt == null || deckSvt.svt == null) return const SizedBox.shrink();
    final detail = option.svtBonus[index];
    if (deckSvt.supportType.isSupport || detail.isBond15) {
      return Text('-', style: Theme.of(context).textTheme.bodySmall);
    }

    Widget _row(String text) {
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
                  "teapotTimes": result.teapotTimes.toString(),
                  "totalBond": result.totalBond.toString(),
                }.items)
                  _param(k, v),
              ],
            ),
          ).showDialog(context);
        },
        child: AutoSizeText(text, maxLines: 1, maxFontSize: 16, minFontSize: 2),
      );
    }

    final totalBond = result.totalBond;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [_row('+${totalBond - result.baseValue}'), _row(totalBond.toString())],
    );
  }
}
