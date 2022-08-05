import 'package:flutter/material.dart';

import 'package:chaldea/models/models.dart';
import 'package:chaldea/utils/utils.dart';
import 'descriptor_base.dart';
import 'mission_cond_detail.dart';

class CondTargetNumDescriptor extends StatelessWidget with DescriptorBase {
  final CondType condType;
  final int targetNum;
  @override
  final List<int> targetIds;
  final EventMissionConditionDetail? detail;
  final List<EventMission> missions;
  @override
  final bool? useAnd;
  @override
  final TextStyle? style;
  @override
  final double? textScaleFactor;
  @override
  final InlineSpan? leading;

  const CondTargetNumDescriptor({
    Key? key,
    required this.condType,
    required this.targetNum,
    required this.targetIds,
    this.detail,
    this.missions = const [],
    this.style,
    this.textScaleFactor,
    this.leading,
    this.useAnd,
  }) : super(key: key);

  bool _isPlayableAll(List<int> clsIds) {
    return clsIds.toSet().equalTo(kSvtIdsPlayable.toSet()) ||
        clsIds.toSet().equalTo(kSvtIdsPlayableNA.toSet());
  }

  @override
  Widget build(BuildContext context) {
    if (condType == CondType.missionConditionDetail && detail != null) {
      return MissionCondDetailDescriptor(
        targetNum: targetNum,
        detail: detail!,
        style: style,
        textScaleFactor: textScaleFactor,
        leading: leading,
      );
    }
    return super.build(context);
  }

  @override
  List<InlineSpan> buildContent(BuildContext context) {
    switch (condType) {
      case CondType.none:
        return localized(
          jp: null,
          cn: null,
          tw: null,
          na: () => text('NONE'),
          kr: null,
        );
      case CondType.questClear:
        bool all = targetNum == targetIds.length && targetNum != 1;
        return localized(
          jp: () => combineToRich(
            context,
            '${all ? "すべての" : ""}クエストを$targetNum種クリアせよ',
            quests(context),
          ),
          cn: () => combineToRich(
            context,
            '通关${all ? "所有" : ""}$targetNum个关卡',
            quests(context),
          ),
          tw: null,
          na: () => combineToRich(
            context,
            'Clear ${all ? "all" : ""} $targetNum quests of ',
            quests(context),
          ),
          kr: null,
        );
      case CondType.questClearPhase:
        return localized(
          jp: () => combineToRich(
              context, null, quests(context), '進行度$targetNumをクリアせよ'),
          cn: () =>
              combineToRich(context, '通关', quests(context), '进度$targetNum'),
          tw: null,
          na: () => combineToRich(
              context, 'Cleared arrow $targetNum of quest', quests(context)),
          kr: null,
        );
      case CondType.questClearNum:
        return localized(
          jp: () => combineToRich(
              context, '以下のクエストを$targetNum回クリアせよ', quests(context)),
          cn: () =>
              combineToRich(context, '通关$targetNum次以下关卡', quests(context)),
          tw: null,
          na: () => combineToRich(
            context,
            '$targetNum runs of quests ',
            quests(context),
          ),
          kr: () => combineToRich(
            context,
            '$targetNum 퀘스트 탐색 ',
            quests(context),
          ),
        );
      case CondType.svtLimit:
        return localized(
          jp: () => combineToRich(
              context, null, servants(context), 'の霊基再臨を$targetNum段階目にする'),
          cn: () => combineToRich(
              context, null, servants(context), '达到灵基再临第$targetNum阶段'),
          tw: null,
          na: () => combineToRich(
            context,
            null,
            servants(context),
            ' at ascension $targetNum',
          ),
          kr: () => combineToRich(
            context,
            null,
            servants(context),
            '영기재림 $targetNum 단계',
          ),
        );
      case CondType.svtFriendship:
        return localized(
          jp: () => combineToRich(
              context, null, servants(context), 'の絆レベルが$targetNumになる'),
          cn: () => combineToRich(
              context, null, servants(context), '的羁绊等级达到$targetNum'),
          tw: null,
          na: () => combineToRich(
            context,
            null,
            servants(context),
            ' at bond level $targetNum',
          ),
          kr: () => combineToRich(
            context,
            null,
            servants(context),
            ' 인연도 레벨 $targetNum',
          ),
        );
      case CondType.svtGet:
        return localized(
          jp: () =>
              combineToRich(context, null, servants(context), 'は霊基一覧の中にいる'),
          cn: () => combineToRich(context, null, servants(context), '在灵基一览中'),
          tw: null,
          na: () => combineToRich(
            context,
            null,
            servants(context),
            ' in Spirit Origin Collection',
          ),
          kr: () => combineToRich(
            context,
            null,
            servants(context),
            ' 정식가입',
          ),
        );
      case CondType.eventEnd:
        return localized(
          jp: () => combineToRich(context, 'イベント', event(context), 'は終了した'),
          cn: () => combineToRich(context, '活动', event(context), '结束'),
          tw: null,
          na: () =>
              combineToRich(context, 'Event ', event(context), ' has ended'),
          kr: () => combineToRich(context, '이벤트 ', event(context), ' 종료'),
        );
      case CondType.svtHaving:
        return localized(
          jp: () =>
              combineToRich(context, 'サーヴァント', servants(context), 'を持っている'),
          cn: () => combineToRich(context, '持有从者', servants(context)),
          tw: null,
          na: () =>
              combineToRich(context, 'Presence of Servant ', servants(context)),
          kr: null,
        );
      case CondType.svtRecoverd:
        return localized(
          jp: null,
          cn: null,
          tw: null,
          na: () => text('Servant Recovered'),
          kr: () => text('서번트 회복되다'),
        );
      case CondType.limitCountAbove:
        return localized(
          jp: () => combineToRich(
              context, null, servants(context), 'の霊基再臨を ≥ $targetNum段階目にする'),
          cn: () => combineToRich(
              context, '从者', servants(context), '的灵基再临 ≥ $targetNum'),
          tw: null,
          na: () => combineToRich(
            context,
            'Servant',
            servants(context),
            ' at ascension ≥ $targetNum',
          ),
          kr: () => combineToRich(
            context,
            '서번트',
            servants(context),
            ' 재림 ≥ $targetNum',
          ),
        );
      case CondType.limitCountBelow:
        return localized(
          jp: () => combineToRich(
              context, null, servants(context), 'の霊基再臨を ≤ $targetNum段階目にする'),
          cn: () => combineToRich(
              context, '从者', servants(context), '的灵基再临 ≤ $targetNum'),
          tw: null,
          na: () => combineToRich(
            context,
            'Servant',
            servants(context),
            ' at ascension ≤ $targetNum',
          ),
          kr: () => combineToRich(
            context,
            '서번트',
            servants(context),
            ' 재림 ≥ $targetNum',
          ),
        );
      case CondType.svtLevelClassNum:
        List<int> clsIds = [];
        List<int> levels = [];
        for (int index = 0; index < targetIds.length / 2; index++) {
          clsIds.add(targetIds[index * 2]);
          levels.add(targetIds[index * 2 + 1]);
        }
        if (levels.toSet().length == 1) {
          final lv = levels.first;
          if (_isPlayableAll(clsIds)) {
            return localized(
              jp: () => text('サーヴァント$targetNum騎をLv.$lv以上にせよ'),
              cn: () => text('将$targetNum骑从者升级到$lv级以上'),
              tw: null,
              na: () => text('Raise $targetNum servants to level $lv'),
              kr: null,
            );
          } else {
            final frags = clsIds.map((e) => Transl.svtClassId(e).l);
            return localized(
              jp: () =>
                  text('『${frags.join('/')}』クラスのサーヴァント$targetNum騎をLv.$lv以上にせよ'),
              cn: () => text('将$targetNum骑${frags.join('/')}从者升级到$lv级以上'),
              tw: null,
              na: () =>
                  text('Raise $targetNum ${frags.join(', ')} to level $lv'),
              kr: null,
            );
          }
        } else {
          return localized(
            jp: () {
              final frags = List.generate(
                clsIds.length,
                (index) =>
                    'Lv.${levels[index]} ${Transl.svtClassId(clsIds[index]).jp}',
              );
              return text('${frags.join('/')} のサーヴァント$targetNum騎をレベルアップする');
            },
            cn: () {
              final frags = List.generate(
                clsIds.length,
                (index) =>
                    'Lv.${levels[index]} ${Transl.svtClassId(clsIds[index]).cn}',
              );
              return text('升级$targetNum骑 ${frags.join(' 或 ')} 从者');
            },
            tw: null,
            na: () {
              final frags = List.generate(
                clsIds.length,
                (index) =>
                    'Lv.${levels[index]} ${Transl.svtClassId(clsIds[index]).na}',
              );
              return text('Raise $targetNum ${frags.join(', ')}');
            },
            kr: null,
          );
        }
      case CondType.svtLimitClassNum:
        List<int> clsIds = [];
        List<int> limits = [];
        for (final id in targetIds) {
          clsIds.add(id ~/ 100);
          limits.add(id % 100);
        }
        if (limits.toSet().length == 1) {
          final limit = limits.first;
          if (_isPlayableAll(clsIds)) {
            return localized(
              jp: () => text('サーヴァント$targetNum騎の霊基再臨を$limit段階目にする'),
              cn: () => text('让$targetNum骑从者达到灵基再临第$limit阶段'),
              tw: null,
              na: () => text('Raise $targetNum servants to ascension $limit'),
              kr: null,
            );
          } else {
            return localized(
              jp: () => text(
                  '『${clsIds.map((e) => Transl.svtClassId(e).jp).join("/")}』クラスのサーヴァント$targetNum騎の霊基再臨を$limit段階目にする'),
              cn: () => text(
                  '让$targetNum骑${clsIds.map((e) => Transl.svtClassId(e).cn).join('/')}从者达到灵基再临第$limit阶段'),
              tw: null,
              na: () => text(
                  'Raise $targetNum ${clsIds.map((e) => Transl.svtClassId(e).na).join(', ')} to ascension $limit'),
              kr: null,
            );
          }
        } else {
          return localized(
            jp: () {
              final frags = List.generate(
                clsIds.length,
                (index) =>
                    '霊基再臨${limits[index]}階目 ${Transl.svtClassId(clsIds[index]).jp}',
              );
              return text('${frags.join('/')} のサーヴァント$targetNum騎を霊基再臨する');
            },
            cn: () {
              final frags = List.generate(
                clsIds.length,
                (index) =>
                    '灵基${limits[index]}${Transl.svtClassId(clsIds[index]).cn}',
              );
              return text('升级$targetNum骑 ${frags.join(' 或 ')} 从者');
            },
            tw: null,
            na: () {
              final frags = List.generate(
                clsIds.length,
                (index) =>
                    'Ascension ${limits[index]} ${Transl.svtClassId(clsIds[index]).na}',
              );
              return text('Raise $targetNum ${frags.join(' or ')}');
            },
            kr: null,
          );
        }
      case CondType.svtEquipRarityLevelNum:
        List<int> levels = [];
        List<int> rarities = [];
        for (final id in targetIds) {
          levels.add(id ~/ 100);
          rarities.add(id % 100);
        }
        if (levels.toSet().length == 1) {
          final level = levels.first;
          if (rarities.toSet().equalTo({1, 2, 3, 4, 5})) {
            return localized(
              jp: () => text('概念礼装$targetNum種をLv.$level以上にせよ'),
              cn: () => text('将$targetNum种概念礼装的等级提升到$level以上'),
              tw: null,
              na: () => text('Raise $targetNum CEs to level $level'),
              kr: null,
            );
          } else {
            final frags = rarities.map((e) => '$e$kStarChar').join('/');
            return localized(
              jp: () => text('$frags概念礼装$targetNum種をLv.$level以上にせよ'),
              cn: () => text('将$targetNum种$frags概念礼装的等级提升到$level以上'),
              tw: null,
              na: () => text('Raise $targetNum $frags CEs to level $level'),
              kr: null,
            );
          }
        } else {
          final frags = List.generate(levels.length,
              (index) => 'Lv.${levels[index]} ${rarities[index]}$kStarChar}');
          return localized(
            jp: () => text('${frags.join('/')} の概念礼装$targetNum種をレベルアップする'),
            cn: () => text('升级$targetNum种 ${frags.join(' 或 ')} 礼装'),
            tw: null,
            na: () => text('Raise $targetNum ${frags.join(' or ')} CEs'),
            kr: null,
          );
        }
      case CondType.eventMissionAchieve:
        final mission = missions
            .firstWhereOrNull((mission) => mission.id == targetIds.first);
        final targets =
            '${mission?.dispNo}-${mission?.name ?? targetIds.first}';
        return localized(
          jp: () => text('クエストをクリアせよ $targets'),
          cn: () => text('完成任务 $targets'),
          tw: null,
          na: () => text('Achieve mission $targets'),
          kr: () => text('미션을 완수하다 $targets'),
        );
      case CondType.eventTotalPoint:
        return localized(
          jp: () => text('イベントポイントを$targetNum点獲得'),
          cn: () => text('活动点数达到$targetNum点'),
          tw: null,
          na: () => text('Reach $targetNum event points'),
          kr: () => text('이벤트 포인트 $targetNum점'),
        );
      case CondType.eventMissionClear:
        final missionMap = {for (final m in missions) m.id: m};
        final dispNos =
            targetIds.map((e) => missionMap[e]?.dispNo ?? e).toList();

        if (dispNos.length == targetNum) {
          if (targetNum == 1) {
            return localized(
              jp: () => combineToRich(
                  context, 'ミッションをクリア: ', missionList(context, missionMap)),
              cn: () => combineToRich(
                  context, '完成任务: ', missionList(context, missionMap)),
              tw: null,
              na: () => combineToRich(
                  context, 'Clear mission: ', missionList(context, missionMap)),
              kr: () => combineToRich(
                  context, '미션 완료: ', missionList(context, missionMap)),
            );
          } else {
            return localized(
              jp: () => combineToRich(context, '以下のすべてのミッションをクリアせよ:',
                  missionList(context, missionMap)),
              cn: () => combineToRich(
                  context, '完成以下全部任务:', missionList(context, missionMap)),
              tw: null,
              na: () => combineToRich(context, 'Clear all missions of ',
                  missionList(context, missionMap)),
              kr: () => combineToRich(
                  context, '다음 모든 미션을 완료', missionList(context, missionMap)),
            );
          }
        } else {
          return localized(
            jp: () => combineToRich(context, '以下の異なるクエスト$targetNum個をクリアせよ',
                missionList(context, missionMap)),
            cn: () => combineToRich(context, '完成$targetNum个不同的任务',
                missionList(context, missionMap)),
            tw: null,
            na: () => combineToRich(
              context,
              'Clear $targetNum different missions from ',
              missionList(context, missionMap),
            ),
            kr: () => combineToRich(context, '완료$targetNum 다른 미션들',
                missionList(context, missionMap)),
          );
        }
      // case CondType.missionConditionDetail:
      case CondType.date:
        final time = DateTime.fromMillisecondsSinceEpoch(targetNum * 1000)
            .toStringShort(omitSec: true);
        return localized(
          jp: () => text('$time以降に開放'),
          cn: () => text('$time后开放'),
          tw: null,
          na: () => text('After $time'),
          kr: () => text('$time 개방'),
        );
      default:
        break;
    }
    return localized(
      jp: () => text('不明な条件(${condType.name}): $targetNum, $targetIds'),
      cn: () => text('未知条件(${condType.name}): $targetNum, $targetIds'),
      tw: null,
      na: () => text('Unknown Cond(${condType.name}): $targetNum, $targetIds'),
      kr: () => text('미확인 (${condType.name}): $targetNum, $targetIds'),
    );
  }
}
