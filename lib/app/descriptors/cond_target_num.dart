import 'package:flutter/gestures.dart';

import 'package:chaldea/app/modules/common/builders.dart';
import 'package:chaldea/models/models.dart';
import 'package:chaldea/utils/utils.dart';
import 'package:chaldea/widgets/widgets.dart';
import 'descriptor_base.dart';
import 'mission_cond_detail.dart';
import 'multi_entry.dart';

class CondTargetNumDescriptor extends HookWidget with DescriptorBase {
  final CondType condType;
  final int targetNum;
  @override
  final List<int> targetIds;
  final List<EventMissionConditionDetail> details;
  final List<EventMission> missions;

  /// logic among [details]
  @override
  final bool? useAnd;
  @override
  final TextStyle? style;
  @override
  final double? textScaleFactor;
  @override
  final InlineSpan? leading;
  final int? eventId;
  @override
  final String? unknownMsg;
  @override
  final EdgeInsetsGeometry? padding;

  const CondTargetNumDescriptor({
    super.key,
    required this.condType,
    required this.targetNum,
    required this.targetIds,
    List<EventMissionConditionDetail>? details,
    this.missions = const [],
    this.style,
    this.textScaleFactor,
    this.leading,
    this.useAnd,
    this.eventId,
    this.unknownMsg,
    this.padding,
  }) : details = details ?? const [];

  bool _isPlayableAll(List<int> clsIds) {
    return kSvtClassIdsPlayableAlways.every((e) => clsIds.contains(e)) &&
        clsIds.every((e) => kSvtClassIdsPlayableAll.contains(e));
  }

  @override
  Widget build(BuildContext context) {
    if (condType == CondType.missionConditionDetail && details.isNotEmpty) {
      if (details.length == 1) {
        return MissionCondDetailDescriptor(
          targetNum: targetNum,
          detail: details.first,
          style: style,
          textScaleFactor: textScaleFactor,
          leading: leading,
          useAnd: details.first.useAnd,
          eventId: eventId,
          unknownMsg: unknownMsg,
        );
      }

      List<InlineSpan> spans = [
        if (leading != null) leading!,
        TextSpan(text: M.of(jp: null, cn: '总计$targetNum: ', tw: '總計$targetNum: ', na: 'Total $targetNum: ', kr: null)),
      ];

      for (int index = 0; index < details.length; index++) {
        spans.add(const TextSpan(text: '『'));
        spans.addAll(
          MissionCondDetailDescriptor(
            targetNum: null,
            detail: details[index],
            useAnd: details[index].useAnd,
            eventId: eventId,
            // unknownMsg: null,
          ).buildContent(context),
        );
        spans.add(const TextSpan(text: '』'));
        if (index != details.length - 1) {
          spans.add(
            TextSpan(
              text:
                  (useAnd ?? false)
                      ? M.of(jp: null, cn: '且', tw: '且', na: ' AND ', kr: null)
                      : M.of(jp: null, cn: '或', tw: '或', na: ' OR ', kr: null),
            ),
          );
        }
      }

      return Text.rich(
        TextSpan(children: spans),
        textScaler: textScaleFactor == null ? null : TextScaler.linear(textScaleFactor!),
        style: style,
      );
    }
    return super.build(context);
  }

  @override
  List<InlineSpan> buildContent(BuildContext context) {
    switch (condType) {
      case CondType.none:
        return localized(jp: null, cn: null, tw: () => text('NONE'), na: () => text('NONE'), kr: null);
      case CondType.forceFalse:
        return localized(
          jp: () => text('不可能です'),
          cn: () => text('不可能'),
          tw: () => text('不可能'),
          na: () => text('Not Possible'),
          kr: null,
        );
      case CondType.questClear:
        bool all = targetNum == targetIds.length && targetNum != 1 && useAnd != false;
        bool onlyOne = targetNum == 1 && targetIds.length == 1;
        return localized(
          jp: () => rich('${all ? "すべての" : ""}クエストを${onlyOne ? "" : "$targetNum種"}クリアせよ', quests(context)),
          cn: () => rich('通关${all ? "所有" : ""}${onlyOne ? "" : "$targetNum个"}关卡', quests(context)),
          tw: () => rich('通關${all ? "所有" : ""}${onlyOne ? "" : "$targetNum個"}關卡', quests(context)),
          na: () => rich('Clear ${all ? "all " : ""}${onlyOne ? "quest" : "$targetNum quests"} of ', quests(context)),
          kr: null,
        );
      case CondType.questNotClear:
      case CondType.questNotClearAnd:
        // condNum is not used I think
        bool and = condType == CondType.questNotClearAnd;
        return localized(
          jp: null,
          cn: () => rich('未通关以下${and ? "所有" : "任意"}关卡', quests(context)),
          tw: () => rich('未通關以下${and ? "所有" : "任意"}關卡', quests(context)),
          na: () => rich('Have not cleared ${and ? "all " : "any "}quests of ', quests(context)),
          kr: null,
        );
      case CondType.questClearPhase:
        return localized(
          jp: () => rich(null, quests(context), '進行度$targetNumをクリアせよ'),
          cn: () => rich('通关', quests(context), '进度$targetNum'),
          tw: () => rich('通關', quests(context), '進度$targetNum'),
          na: () => rich('Cleared arrow $targetNum of quest', quests(context)),
          kr: null,
        );
      case CondType.questClearNum:
        return localized(
          jp: () => rich('以下のクエストを$targetNum回クリアせよ', quests(context)),
          cn: () => rich('通关$targetNum次以下关卡', quests(context)),
          tw: () => rich('通關$targetNum次以下關卡', quests(context)),
          na: () => rich('$targetNum runs of quests ', quests(context)),
          kr: () => rich('$targetNum 퀘스트 탐색 ', quests(context)),
        );
      case CondType.questChallengeNum:
        return localized(
          jp: () => rich('以下のクエストを$targetNum回挑戦せよ', quests(context)),
          cn: () => rich('挑战$targetNum次以下关卡', quests(context)),
          tw: () => rich('挑戰$targetNum次以下關卡', quests(context)),
          na: () => rich('Challenge $targetNum runs of quests ', quests(context)),
          kr: null,
        );
      case CondType.questGroupClear:
        final questIds = [
          for (final groupId in targetIds) ...db.gameData.others.getQuestsOfGroup(QuestGroupType.questRelease, groupId),
        ];
        final questSpans = MultiDescriptor.quests(context, questIds, useAnd: useAnd);
        return localized(
          jp: () => rich('クエストを$targetNum種クリア', questSpans),
          cn: () => rich('通关$targetNum个关卡', questSpans),
          tw: () => rich('通關$targetNum個關卡', questSpans),
          na: () => rich('Clear $targetNum quests of ', questSpans),
          kr: null,
        );
      case CondType.svtCostumeReleased:
      case CondType.notSvtCostumeReleased:
      case CondType.costumeGet: // cond target value
      case CondType.notCostumeGet: // cond target value
        final svt = db.gameData.servantsById[targetIds.getOrNull(0)];
        final costume = svt?.profile.costume.values.firstWhereOrNull((e) => e.id == targetNum);
        if (svt == null || costume == null) break;
        final costumeWidget = TextSpan(
          children: [
            CenterWidgetSpan(
              child: svt.iconBuilder(
                context: context,
                overrideIcon: svt.extraAssets.faces.costume?[costume.battleCharaId],
                onTap: costume.routeTo,
                width: 36,
              ),
            ),
            SharedBuilder.textButtonSpan(
              context: context,
              text: costume.lName.l.setMaxLines(1),
              onTap: costume.routeTo,
            ),
          ],
          recognizer: TapGestureRecognizer()..onTap = costume.routeTo,
        );
        bool got = condType == CondType.svtCostumeReleased || condType == CondType.costumeGet;
        final gotText = M.of(cn: got ? '已获得' : '未获得', na: got ? 'Have got' : 'Have not got');
        return localized(
          jp: null,
          cn: () => rich('$gotText灵衣', [costumeWidget]),
          tw: () => rich('$gotText靈衣', [costumeWidget]),
          na: () => rich('$gotText Costume ', [costumeWidget]),
          kr: null,
        );
      case CondType.svtLimit:
        return localized(
          jp: () => rich(null, servants(context), 'の霊基再臨を$targetNum段階目にする'),
          cn: () => rich(null, servants(context), '达到灵基再临第$targetNum阶段'),
          tw: () => rich(null, servants(context), '達到靈基再臨第$targetNum階段'),
          na: () => rich(null, servants(context), ' at ascension $targetNum'),
          kr: () => rich(null, servants(context), '영기재림 $targetNum 단계'),
        );
      case CondType.svtFriendship:
        return localized(
          jp: () => rich(null, servants(context), 'の絆レベルが$targetNumになる'),
          cn: () => rich(null, servants(context), '的羁绊等级达到$targetNum'),
          tw: () => rich(null, servants(context), '的羈絆等級達到$targetNum'),
          na: () => rich(null, servants(context), ' at bond level $targetNum'),
          kr: () => rich(null, servants(context), ' 인연도 레벨 $targetNum'),
        );
      case CondType.svtGet:
        return localized(
          jp: () => rich(null, servants(context), 'は霊基一覧の中にいる'),
          cn: () => rich(null, servants(context), '在灵基一览中'),
          tw: () => rich(null, servants(context), '在靈基一覽中'),
          na: () => rich(null, servants(context), ' in Spirit Origin Collection'),
          kr: () => rich(null, servants(context), ' 정식가입'),
        );
      case CondType.notSvtGet:
        return localized(
          jp: null,
          cn: () => rich(null, servants(context), '不在灵基一览中'),
          tw: () => rich(null, servants(context), '不在靈基一覽中'),
          na: () => rich(null, servants(context), 'not in Spirit Origin Collection'),
          kr: null,
        );
      case CondType.commandCodeGet:
        return localized(
          jp: null,
          cn: () => rich('获得过', servants(context)),
          tw: null,
          na: () => rich('Have got', servants(context)),
          kr: null,
        );
      case CondType.notCommandCodeGet:
        return localized(
          jp: null,
          cn: () => rich('未曾获得过', servants(context)),
          tw: null,
          na: () => rich('Have not got', servants(context)),
          kr: null,
        );
      case CondType.eventEnd:
        return localized(
          jp: () => rich('イベント', events(context), 'は終了した'),
          cn: () => rich('活动', events(context), '结束'),
          tw: () => rich('活動', events(context), '結束'),
          na: () => rich('Event ', events(context), ' has ended'),
          kr: () => rich('이벤트 ', events(context), ' 종료'),
        );
      case CondType.svtHaving:
        return localized(
          jp: () => rich('サーヴァント', servants(context), 'を持っている'),
          cn: () => rich('持有从者', servants(context)),
          tw: () => rich('持有從者', servants(context)),
          na: () => rich('Presence of Servant ', servants(context)),
          kr: null,
        );
      case CondType.notSvtHaving:
        return localized(
          jp: () => rich('サーヴァント', servants(context), 'を持ってない'),
          cn: () => rich('未持有从者', servants(context)),
          tw: () => rich('未持有從者', servants(context)),
          na: () => rich('Does not presence of Servant ', servants(context)),
          kr: null,
        );
      case CondType.svtHavingLimitMax:
        return localized(
          jp: null,
          cn: () => rich('持有从者且满破', servants(context)),
          tw: () => rich('持有從者且滿破', servants(context)),
          na: () => rich('Having servant and reached Max Limit Break', servants(context)),
          kr: null,
        );
      case CondType.svtRecoverd:
        return localized(
          jp: null,
          cn: null,
          tw: () => text('從者已回復'),
          na: () => text('Servant Recovered'),
          kr: () => text('서번트 회복되다'),
        );
      case CondType.limitCountAbove:
        return localized(
          jp: () => rich(null, servants(context), 'の霊基再臨を ≥ $targetNum段階目にする'),
          cn: () => rich('从者', servants(context), '的灵基再临 ≥ $targetNum'),
          tw: () => rich('從者', servants(context), '的靈基再臨 ≥ $targetNum'),
          na: () => rich('Servant', servants(context), ' at ascension ≥ $targetNum'),
          kr: () => rich('서번트', servants(context), ' 재림 ≥ $targetNum'),
        );
      case CondType.limitCountBelow:
        return localized(
          jp: () => rich(null, servants(context), 'の霊基再臨を ≤ $targetNum段階目にする'),
          cn: () => rich('从者', servants(context), '的灵基再临 ≤ $targetNum'),
          tw: () => rich('從者', servants(context), '的靈基再臨 ≤ $targetNum'),
          na: () => rich('Servant', servants(context), ' at ascension ≤ $targetNum'),
          kr: () => rich('서번트', servants(context), ' 재림 ≥ $targetNum'),
        );
      case CondType.svtLevelClassNum:
        final (clsIds, levels) = _splitTargets(targetIds);
        if (levels.toSet().length == 1) {
          final lv = levels.first;
          if (_isPlayableAll(clsIds)) {
            return localized(
              jp: () => text('サーヴァント$targetNum騎をLv.$lv以上にせよ'),
              cn: () => text('将$targetNum骑从者升级到$lv级以上'),
              tw: () => text('將$targetNum騎從者升級到$lv級以上'),
              na: () => text('Raise $targetNum servants to level $lv'),
              kr: null,
            );
          } else {
            final frags = clsIds.map((e) => Transl.svtClassId(e).l);
            return localized(
              jp: () => text('『${frags.join('/')}』クラスのサーヴァント$targetNum騎をLv.$lv以上にせよ'),
              cn: () => text('将$targetNum骑${frags.join('/')}从者升级到$lv级以上'),
              tw: () => text('將$targetNum騎${frags.join('/')}從者升級到$lv級以上'),
              na: () => text('Raise $targetNum ${frags.join(', ')} to level $lv'),
              kr: null,
            );
          }
        } else {
          return localized(
            jp: () {
              final frags = List.generate(
                clsIds.length,
                (index) => 'Lv.${levels[index]} ${Transl.svtClassId(clsIds[index]).jp}',
              );
              return text('${frags.join('/')} のサーヴァント$targetNum騎をレベルアップする');
            },
            cn: () {
              final frags = List.generate(
                clsIds.length,
                (index) => 'Lv.${levels[index]} ${Transl.svtClassId(clsIds[index]).cn}',
              );
              return text('升级$targetNum骑 ${frags.join(' 或 ')} 从者');
            },
            tw: () {
              final frags = List.generate(
                clsIds.length,
                (index) => 'Lv.${levels[index]} ${Transl.svtClassId(clsIds[index]).tw}',
              );
              return text('升級$targetNum騎 ${frags.join(' 或 ')} 從者');
            },
            na: () {
              final frags = List.generate(
                clsIds.length,
                (index) => 'Lv.${levels[index]} ${Transl.svtClassId(clsIds[index]).na}',
              );
              return text('Raise $targetNum ${frags.join(', ')}');
            },
            kr: null,
          );
        }
      case CondType.svtLimitClassNum:
        final (clsIds, limits) = _splitTargetPercent(targetIds);
        if (limits.toSet().length == 1) {
          final limit = limits.first;
          if (_isPlayableAll(clsIds)) {
            return localized(
              jp: () => text('サーヴァント$targetNum騎の霊基再臨を$limit段階目にする'),
              cn: () => text('让$targetNum骑从者达到灵基再临第$limit阶段'),
              tw: () => text('讓$targetNum騎從者達到靈基再臨第$limit階段'),
              na: () => text('Raise $targetNum servants to ascension $limit'),
              kr: null,
            );
          } else {
            return localized(
              jp: () => text('『${classIds(clsIds)}』クラスのサーヴァント$targetNum騎の霊基再臨を$limit段階目にする'),
              cn: () => text('让$targetNum骑${classIds(clsIds)}从者达到灵基再临第$limit阶段'),
              tw: () => text('讓$targetNum騎${classIds(clsIds)}從者達到靈基再臨第$limit階段'),
              na: () => text('Raise $targetNum ${classIds(clsIds)} to ascension $limit'),
              kr: null,
            );
          }
        } else {
          return localized(
            jp: () {
              final frags = List.generate(
                clsIds.length,
                (index) => '霊基再臨${limits[index]}階目 ${Transl.svtClassId(clsIds[index]).jp}',
              );
              return text('${frags.join('/')} のサーヴァント$targetNum騎を霊基再臨する');
            },
            cn: () {
              final frags = List.generate(
                clsIds.length,
                (index) => '灵基${limits[index]}${Transl.svtClassId(clsIds[index]).cn}',
              );
              return text('升级$targetNum骑 ${frags.join(' 或 ')} 从者');
            },
            tw: () {
              final frags = List.generate(
                clsIds.length,
                (index) => '靈基${limits[index]}${Transl.svtClassId(clsIds[index]).tw}',
              );
              return text('升級$targetNum騎 ${frags.join(' 或 ')} 從者');
            },
            na: () {
              final frags = List.generate(
                clsIds.length,
                (index) => 'Ascension ${limits[index]} ${Transl.svtClassId(clsIds[index]).na}',
              );
              return text('Raise $targetNum ${frags.join(' or ')}');
            },
            kr: null,
          );
        }
      case CondType.svtLevelIdNum:
        final (svtIds, lvs) = _splitTargets(targetIds);
        if (lvs.toSet().length > 1) {
          final svts = <InlineSpan>[
            for (int index = 0; index < svtIds.length; index++) ...[
              ...MultiDescriptor.servants(context, [svtIds[index]], useAnd: useAnd),
              TextSpan(text: 'Lv.${lvs[index]} '),
            ],
          ];
          return localized(
            jp: () => rich('サーヴァント$targetNum騎をレベル以上に強化せよ: ', svts),
            cn: () => rich('将$targetNum骑从者升级到对应等级以上: ', svts),
            tw: () => rich('將$targetNum騎從者升級到對應等級以上: ', svts),
            na: () => rich('Raise $targetNum servants to level or higher: ', svts),
            kr: null,
          );
        } else {
          final lv = lvs.firstOrNull ?? '?';
          final svts = MultiDescriptor.servants(context, svtIds, useAnd: useAnd);
          return localized(
            jp: () => rich('サーヴァント$targetNum骑をLv.$lv以上にせよ: ', svts),
            cn: () => rich('将$targetNum骑从者升级到$lv级以上: ', svts),
            tw: () => rich('將$targetNum騎從者升級到$lv級以上: ', svts),
            na: () => rich('Raise $targetNum servants to level $lv: ', svts),
            kr: null,
          );
        }
      case CondType.svtEquipRarityLevelNum:
        final (levels, rarities) = _splitTargetPercent(targetIds);
        if (levels.toSet().length == 1) {
          final level = levels.first;
          if (rarities.toSet().equalTo({1, 2, 3, 4, 5})) {
            return localized(
              jp: () => text('概念礼装$targetNum種をLv.$level以上にせよ'),
              cn: () => text('将$targetNum种概念礼装的等级提升到$level以上'),
              tw: () => text('將$targetNum種概念禮裝的等級提升到$level以上'),
              na: () => text('Raise $targetNum CEs to level $level'),
              kr: null,
            );
          } else {
            final frags = rarities.map((e) => '$e$kStarChar').join('/');
            return localized(
              jp: () => text('$frags概念礼装$targetNum種をLv.$level以上にせよ'),
              cn: () => text('将$targetNum种$frags概念礼装的等级提升到$level以上'),
              tw: () => text('將$targetNum種$frags概念禮裝的等級提升到$level以上'),
              na: () => text('Raise $targetNum $frags CEs to level $level'),
              kr: null,
            );
          }
        } else {
          final frags = List.generate(levels.length, (index) => 'Lv.${levels[index]} ${rarities[index]}$kStarChar}');
          return localized(
            jp: () => text('${frags.join('/')} の概念礼装$targetNum種をレベルアップする'),
            cn: () => text('升级$targetNum种 ${frags.join(' 或 ')} 礼装'),
            tw: () => text('升級$targetNum種 ${frags.join(' 或 ')} 禮裝'),
            na: () => text('Raise $targetNum ${frags.join(' or ')} CEs'),
            kr: null,
          );
        }
      case CondType.allSvtTargetSkillLvNum:
        return localized(
          jp: () => text('スキル$targetNumつをLv.${targetIds.join("/")}以上にせよ'),
          cn: () => text('升级$targetNum个技能至Lv.${targetIds.join("/")}以上'),
          tw: () => text('升級$targetNum個技能至Lv.${targetIds.join("/")}以上'),
          na: () => text('Upgrade $targetNum skills to Lv.${targetIds.join("/")} or higher'),
          kr: null,
        );
      case CondType.svtClassFriendshipCount:
        return localized(
          jp: () => text('『$targetClassIds』クラスのサーヴァントの絆レベルを合計$targetNum以上にせよ'),
          cn: () => text('『$targetClassIds』职阶从者牵绊等级合计达到$targetNum以上'),
          tw: () => text('『$targetClassIds』職階從者羈絆等級合計達到$targetNum以上'),
          na: () => text('Reach bond level $targetNum on [$targetClassIds] class servants'),
          kr: null,
        );
      case CondType.svtClassSkillLvUpCount:
        return localized(
          jp: () => text('『$targetClassIds』クラスのサーヴァントのスキルを合計$targetNum回強化せよ(同一霊基不可) '),
          cn: () => text('『$targetClassIds』职阶从者技能强化累计$targetNum次（不计算相同灵基）'),
          tw: () => text('『$targetClassIds』職階從者技能強化累計$targetNum次（不計算相同靈基）'),
          na:
              () => text(
                'Leveled up skills of [$targetClassIds] class servants $targetNum times (not include duplicate servants)',
              ),
          kr: null,
        );
      case CondType.svtClassLvUpCount:
        return localized(
          jp: () => text('『$targetClassIds』クラスのサーヴァントのLvを合計$targetNum回強化せよ(同一霊基不可) '),
          cn: () => text('『$targetClassIds』职阶从者等级强化累计$targetNum次（不计算相同灵基）'),
          tw: () => text('『$targetClassIds』職階從者等級強化累計$targetNum次（不計算相同靈基）'),
          na:
              () =>
                  text('Leveled up [$targetClassIds] class servants $targetNum times (not include duplicate servants)'),
          kr: null,
        );
      case CondType.svtClassLimitUpCount:
        return localized(
          jp: () => text('『$targetClassIds』クラスのサーヴァントを合計$targetNum回霊基再臨せよ(同一霊基不可) '),
          cn: () => text('『$targetClassIds』职阶从者灵基再临累计$targetNum次（不计算相同灵基）'),
          tw: () => text('『$targetClassIds』職階從者靈基再臨累計$targetNum次（不計算相同靈基）'),
          na: () => text('Ascend [$targetClassIds] class servants $targetNum times (not include duplicate servants)'),
          kr: null,
        );
      case CondType.svtFriendshipClassNumAbove:
        // サーヴァント5騎の絆レベルをLv.6以上にせよ
        // 106, 206, 306, 406, 506
        final (clsIds, counts) = _splitTargetPercent(targetIds);
        if (counts.toSet().length == 1) {
          final level = counts.first;
          if (_isPlayableAll(clsIds)) {
            return localized(
              jp: () => text('サーヴァント$targetNum騎の絆レベルをLv.$level以上にせよ'),
              cn: () => text('让$targetNum骑从者的牵绊等级达到Lv.$level以上'),
              tw: () => text('讓$targetNum騎從者的羈絆等級達到Lv.$level以上'),
              na: () => text('Reach Bond Level $level or above on any $targetNum Servants'),
              kr: null,
            );
          } else {
            return localized(
              jp: () => text('『${classIds(clsIds)}』クラスのサーヴァント$targetNum騎の絆レベルをLv.$level以上にせよ'),
              cn: () => text('让$targetNum骑${classIds(clsIds)}骑从者的牵绊等级达到Lv.$level以上'),
              tw: () => text('讓$targetNum騎${classIds(clsIds)}騎從者的羈絆等級達到Lv.$level以上'),
              na: () => text('Reach Bond Level $level or above on $targetNum [${classIds(clsIds)}] Servants'),
              kr: null,
            );
          }
        } else {
          break;
        }
      case CondType.svtSkillLvClassNumAbove:
        break;
      // case CondType.totalTdLevelAbove:
      // case CondType.totalTdLevel:
      case CondType.totalTdLevelBelow:
        return localized(
          jp: null,
          cn: () => rich('总宝具等级≤$targetNum', servants(context)),
          tw: null,
          na: () => rich('Total NP levels ≤$targetNum', servants(context)),
          kr: null,
        );
      case CondType.notShopPurchase:
        final countText = targetNum == 1 ? "" : M.of(cn: "$targetNum次", na: '$targetNum times of ');
        return localized(
          jp: null,
          cn: () => rich('未兑换$countText商店', shops(context)),
          tw: () => rich('未兌換$countText商店', shops(context)),
          na: () => rich('Have not purchased ${countText}shop', shops(context)),
          kr: null,
        );
      case CondType.purchaseShop:
      case CondType.purchaseQpShop:
        final countText = targetNum <= 1 ? "" : M.of(cn: "$targetNum次", na: '$targetNum times of ');
        return localized(
          jp: null,
          cn: () => rich('已兑换$countText商店', shops(context)),
          tw: () => rich('已兌換$countText商店', shops(context)),
          na: () => rich('Have purchased ${countText}shop', shops(context)),
          kr: null,
        );
      case CondType.notEventShopPurchase:
        return localized(
          jp: null,
          cn: () => rich('未兑换活动商店', events(context)),
          tw: () => rich('未兌換活動商店', events(context)),
          na: () => rich('Have not purchased event shop', events(context)),
          kr: null,
        );
      case CondType.shopGroupLimitNum:
        return localized(
          jp: null,
          cn: () => rich('同组(${targetIds.join(",")})商店最多可兑换$targetNum次'),
          tw: () => rich('同組(${targetIds.join(",")})商店最多可兌換$targetNum次'),
          na: () => rich('Max $targetNum time(s) purchasing shop group ${targetIds.join(",")}'),
          kr: null,
        );
      case CondType.eventTotalPoint:
      case CondType.eventPoint:
        return localized(
          jp: () => text('イベントポイントを$targetNum点獲得'),
          cn: () => text('活动点数达到$targetNum点'),
          tw: () => text('活動點數達到$targetNum點'),
          na: () => text('Reach $targetNum event points'),
          kr: () => text('이벤트 포인트 $targetNum점'),
        );
      case CondType.eventMissionClear: // mission's all conditions completed
      case CondType.eventMissionAchieve: // and also claimed rewards
        var missionMap = {for (final m in missions) m.id: m};
        final claim = condType == CondType.eventMissionAchieve;
        if (targetIds.length == targetNum) {
          if (targetNum == 1) {
            return localized(
              jp: () => rich(claim ? 'ミッションを達成(報酬を受け取り): ' : 'ミッションをクリア: ', missionList(context, missionMap)),
              cn: () => rich(claim ? '达成任务(领取奖励): ' : '完成任务: ', missionList(context, missionMap)),
              tw: () => rich(claim ? '達成任務(領取獎勵): ' : '完成任務: ', missionList(context, missionMap)),
              na:
                  () => rich(
                    claim ? 'Achieve mission (claim rewards): ' : 'Clear mission: ',
                    missionList(context, missionMap),
                  ),
              kr: null,
            );
          } else {
            return localized(
              jp:
                  () => rich(
                    claim ? '以下のすべてのミッションを達成せよ(報酬を受け取り): ' : '以下のすべてのミッションをクリアせよ: ',
                    missionList(context, missionMap),
                  ),
              cn: () => rich(claim ? '达成以下全部任务(领取奖励): ' : '完成以下全部任务: ', missionList(context, missionMap)),
              tw: () => rich(claim ? '達成以下全部任務(領取獎勵): ' : '完成以下全部任務: ', missionList(context, missionMap)),
              na:
                  () => rich(
                    claim ? 'Achieve all missions (claim rewards) of ' : 'Clear all missions of ',
                    missionList(context, missionMap),
                  ),
              kr: null,
            );
          }
        } else {
          return localized(
            jp:
                () => rich(
                  claim ? '以下の異なるクエスト$targetNum個を達成せよ(報酬を受け取り): ' : '以下の異なるクエスト$targetNum個をクリアせよ: ',
                  missionList(context, missionMap),
                ),
            cn:
                () => rich(
                  claim ? '达成$targetNum个不同的任务(领取奖励): ' : '完成$targetNum个不同的任务: ',
                  missionList(context, missionMap),
                ),
            tw:
                () => rich(
                  claim ? '達成$targetNum個不同的任務(領取獎勵): ' : '完成$targetNum個不同的任務: ',
                  missionList(context, missionMap),
                ),
            na:
                () => rich(
                  claim
                      ? 'Achieve $targetNum different missions (claim rewards) from '
                      : 'Clear $targetNum different missions from ',
                  missionList(context, missionMap),
                ),
            kr: null,
          );
        }
      case CondType.startRandomMission:
        final targets = targetIds.join(', ');
        return localized(
          jp: null,
          cn: () => text('开始随机任务: $targets'),
          tw: () => text('開始隨機任務: $targets'),
          na: () => text('Start Random Mission: $targets'),
          kr: null,
        );
      case CondType.latestMainScenarioWarClear:
        return localized(
          jp: null,
          cn: () => text('通关最新主线剧情'),
          tw: () => text('通關最新主線劇情'),
          na: () => text('Clear latest main scenario'),
          kr: null,
        );
      case CondType.itemGet:
        return localized(
          jp: null,
          cn: () => rich('持有$targetNum个素材', items(context)),
          tw: () => rich('持有$targetNum個素材', items(context)),
          na: () => rich('Have $targetNum item(s)', items(context)),
          kr: null,
        );
      case CondType.notItemGet:
        return localized(
          jp: null,
          cn: () => rich('未持有$targetNum个素材', items(context)),
          tw: () => rich('未持有$targetNum個素材', items(context)),
          na: () => rich('Don not have $targetNum item(s)', items(context)),
          kr: null,
        );
      case CondType.classBoardSquareReleased:
        if (targetIds.every((e) => e == 0)) {
          return localized(
            jp: () => text('クラススコアサインを$targetNum個解放せよ'),
            cn: () => text('解放任意职阶星图的星宫$targetNum个'),
            tw: () => text('解放任意職階星圖的星宮$targetNum個'),
            na: () => text('Enhance $targetNum Class Score Signs'),
            kr: null,
          );
        } else {
          return localized(
            jp: () => rich('クラススコアサインを$targetNum個解放せよ: ', classBoards(context)),
            cn: () => rich('解放职阶星图的星宫$targetNum个: ', classBoards(context)),
            tw: () => rich('解放任意職階星圖的星宮$targetNum個: ', classBoards(context)),
            na: () => rich('Enhance $targetNum Class Score Signs: ', classBoards(context)),
            kr: null,
          );
        }
      // exchangeSvt related cond: targetIds=[eventId], but no need to show
      case CondType.svtFriendshipExchangeSvt:
        return localized(
          jp: () => rich('交換したサーヴァントの絆レベルをLv.$targetNum以上にせよ', events(context)),
          cn: () => rich('兑换的从者牵绊等级合到Lv.$targetNum以上', events(context)),
          tw: null,
          na: () => rich('Reach the exchanged servant\'s Bond to Lv.$targetNum or higher', events(context)),
          kr: null,
        );
      case CondType.skillLvExchangeSvt:
        return localized(
          jp: () => rich('交換したサーヴァントのスキル1つをLv.$targetNum以上にせよ', events(context)),
          cn: () => rich('升级兑换的从者的1个技能至Lv.$targetNum以上', events(context)),
          tw: null,
          na: () => rich('Upgrade the exchange servant\'s 1 skill to Lv.$targetNum or higher', events(context)),
          kr: null,
        );
      case CondType.svtLimitExchangeSvt:
        return localized(
          jp: () => rich('交換したサーヴァント$targetNum骑を最終再臨せよ', events(context)),
          cn: () => rich('让$targetNum骑兑换的从者完成最终再临', events(context)),
          tw: null,
          na: () => rich('Have $targetNum exchanged Servant reach Final Ascension', events(context)),
          kr: null,
        );
      case CondType.svtLevelExchangeSvt:
        return localized(
          jp: () => rich('交換したサーヴァントをLv.$targetNum以上に強化せよ', events(context)),
          cn: () => rich('将兑换的从者升级到Lv.$targetNum以上', events(context)),
          tw: null,
          na: () => rich('Raise the exchanged servant to Lv.$targetNum or higher', events(context)),
          kr: null,
        );
      case CondType.commonRelease:
        return localized(
          jp: null,
          cn: null,
          tw: null,
          na: () => rich('Common Release', MultiDescriptor.commonRelease(context, targetIds)),
          kr: null,
        );
      // case CondType.exchangeSvt: // cond_target_value
      //   break;
      case CondType.date:
        final time = DateTime.fromMillisecondsSinceEpoch(targetNum * 1000).toStringShort(omitSec: true);
        return localized(
          jp: () => text('$time以降に開放'),
          cn: () => text('$time后开放'),
          tw: () => text('$time後開放'),
          na: () => text('After $time'),
          kr: () => text('$time 개방'),
        );
      default:
        break;
    }

    return [
      TextSpan(
        children: wrapMsg(
          localized(
            jp: () => text('不明な条件(${condType.name}): $targetNum, $targetIds'),
            cn: () => text('未知条件(${condType.name}): $targetNum, $targetIds'),
            tw: () => text('未知條件(${condType.name}): $targetNum, $targetIds'),
            na: () => text('Unknown Cond(${condType.name}): $targetNum, $targetIds'),
            kr: () => text('미확인 (${condType.name}): $targetNum, $targetIds'),
          ),
        ),
        // style: kDebugMode ? const TextStyle(color: Colors.red) : null,
      ),
    ];
  }

  (List<int>, List<int>) _splitTargets(List<int> vals) {
    List<int> keys = [];
    List<int> values = [];
    for (int index = 0; index < targetIds.length / 2; index++) {
      keys.add(targetIds[index * 2]);
      values.add(targetIds[index * 2 + 1]);
    }
    return (keys, values);
  }

  (List<int>, List<int>) _splitTargetPercent(List<int> vals) {
    List<int> keys = [];
    List<int> values = [];
    for (int index = 0; index < targetIds.length; index++) {
      keys.add(targetIds[index] ~/ 100);
      values.add(targetIds[index] % 100);
    }
    return (keys, values);
  }
}
