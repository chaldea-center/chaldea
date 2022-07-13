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
  final TextStyle? style;
  @override
  final double? textScaleFactor;

  const CondTargetNumDescriptor({
    Key? key,
    required this.condType,
    required this.targetNum,
    required this.targetIds,
    this.detail,
    this.missions = const [],
    this.style,
    this.textScaleFactor,
  }) : super(key: key);

  bool _isPlayableAll(List<int> clsIds) {
    return clsIds.toSet().equalTo(kSvtIdsPlayable.toSet()) ||
        clsIds.toSet().equalTo(kSvtIdsPlayableNA.toSet());
  }

  @override
  Widget build(BuildContext context) {
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
          jp: null,
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
          jp: null,
          cn: () =>
              combineToRich(context, '通关', quests(context), '进度$targetNum'),
          tw: null,
          na: () => combineToRich(
              context, 'Cleared arrow $targetNum of quest', quests(context)),
          kr: null,
        );
      case CondType.questClearNum:
        return localized(
          jp: null,
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
          jp: null,
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
          jp: null,
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
          jp: null,
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
          jp: null,
          cn: () => combineToRich(context, '活动', event(context), '结束'),
          tw: null,
          na: () =>
              combineToRich(context, 'Event ', event(context), ' has ended'),
          kr: () => combineToRich(context, '이벤트 ', event(context), ' 종료'),
        );
      case CondType.svtHaving:
        return localized(
          jp: null,
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
          jp: null,
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
          jp: null,
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
              jp: null,
              cn: () => text('将$targetNum骑从者升级到$lv级以上'),
              tw: null,
              na: () => text('Raise $targetNum servants to level $lv'),
              kr: null,
            );
          } else {
            return localized(
              jp: null,
              cn: () => text(
                  '将$targetNum骑${clsIds.map((e) => Transl.svtClassId(e).l).join('/')}从者升级到$lv级以上'),
              tw: null,
              na: () => text(
                  'Raise $targetNum ${clsIds.map((e) => Transl.svtClassId(e).l).join(',')} to level $lv'),
              kr: null,
            );
          }
        } else {
          return localized(
            jp: null,
            cn: () => text(
                '升级$targetNum骑 ${List.generate(clsIds.length, (index) => 'Lv.${levels[index]} ${kSvtClassIds[clsIds[index]]?.name ?? clsIds[index]}').join(' 或 ')} 从者'),
            tw: null,
            na: () => text(
                'Raise $targetNum ${List.generate(clsIds.length, (index) => 'Lv.${levels[index]} ${kSvtClassIds[clsIds[index]]?.name ?? clsIds[index]}').join(' or ')}'),
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
              jp: null,
              cn: () => text('让$targetNum骑从者达到灵基再临第$limit阶段'),
              tw: null,
              na: () => text('Raise $targetNum servants to ascension $limit'),
              kr: null,
            );
          } else {
            return localized(
              jp: null,
              cn: () => text(
                  '让$targetNum骑${clsIds.map((e) => Transl.svtClassId(e).l).join('/')}从者达到灵基再临第$limit阶段'),
              tw: null,
              na: () => text(
                  'Raise $targetNum ${clsIds.map((e) => Transl.svtClassId(e).l).join(',')} to ascension $limit'),
              kr: null,
            );
          }
        } else {
          return localized(
            jp: null,
            cn: () => text(
                '升级$targetNum骑 ${List.generate(clsIds.length, (index) => '灵基${limits[index]}${kSvtClassIds[clsIds[index]]?.name ?? clsIds[index]}').join(' 或 ')} 从者'),
            tw: null,
            na: () => text(
                'Raise $targetNum ${List.generate(clsIds.length, (index) => 'Ascension ${limits[index]} ${kSvtClassIds[clsIds[index]]?.name ?? clsIds[index]}').join(' or ')}'),
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
              jp: null,
              cn: () => text('将$targetNum种概念礼装的等级提升到$level以上'),
              tw: null,
              na: () => text('Raise $targetNum CEs to level $level'),
              kr: null,
            );
          } else {
            return localized(
              jp: null,
              cn: () => text(
                  '将$targetNum种${rarities.map((e) => '$e$kStarChar').join('/')}概念礼装的等级提升到$level以上'),
              tw: null,
              na: () => text(
                  'Raise $targetNum ${rarities.map((e) => '$e$kStarChar').join('/')} to level $level'),
              kr: null,
            );
          }
        } else {
          return localized(
            jp: null,
            cn: () => text(
                '升级$targetNum种 ${List.generate(levels.length, (index) => 'Lv.${levels[index]} ${rarities[index]}$kStarChar').join(' 或 ')} 礼装'),
            tw: null,
            na: () => text(
                'Raise $targetNum ${List.generate(levels.length, (index) => 'Lv.${levels[index]} ${rarities[index]}$kStarChar').join(' or ')}'),
            kr: null,
          );
        }
      case CondType.eventMissionAchieve:
        final mission = missions
            .firstWhereOrNull((mission) => mission.id == targetIds.first);
        final targets =
            '${mission?.dispNo}-${mission?.name ?? targetIds.first}';
        return localized(
          jp: null,
          cn: () => text('完成任务 $targets'),
          tw: null,
          na: () => text('Archive mission $targets'),
          kr: () => text('미션을 완수하다 $targets'),
        );
      case CondType.eventTotalPoint:
        return localized(
          jp: null,
          cn: () => text('获得活动点数$targetNum点'),
          tw: null,
          na: () => text('Reach $targetNum event points'),
          kr: () => text('이벤트 포인트 $targetNum점'),
        );
      case CondType.eventMissionClear:
        final missionMap = {for (final m in missions) m.id: m};
        final dispNos =
            targetIds.map((e) => missionMap[e]?.dispNo ?? e).toList();

        if (dispNos.length == targetNum) {
          return localized(
            jp: null,
            cn: () => combineToRich(
                context, '完成以下全部任务:', missionList(context, missionMap)),
            tw: null,
            na: () => combineToRich(context, 'Clear all missions of',
                missionList(context, missionMap)),
            kr: () => combineToRich(
                context, '다음 모든 미션을 완료', missionList(context, missionMap)),
          );
        } else {
          return localized(
            jp: null,
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
      case CondType.missionConditionDetail:
        if (detail == null) break;
        return MissionCondDetailDescriptor(
          targetNum: targetNum,
          detail: detail!,
          style: style,
          textScaleFactor: textScaleFactor,
        );
      case CondType.date:
        final time = DateTime.fromMillisecondsSinceEpoch(targetNum * 1000)
            .toStringShort(omitSec: true);
        return localized(
          jp: null,
          cn: () => text('$time后开放'),
          tw: null,
          na: () => text('After $time'),
          kr: () => text('$time 개방'),
        );
      default:
        break;
    }
    return localized(
      jp: null,
      cn: () => text('未知条件(${condType.name}): $targetNum, $targetIds'),
      tw: null,
      na: () => text('Unknown Cond(${condType.name}): $targetNum, $targetIds'),
      kr: () => text('미확인 (${condType.name}): $targetNum, $targetIds'),
    );
  }
}
