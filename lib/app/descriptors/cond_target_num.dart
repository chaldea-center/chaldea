import 'package:flutter/gestures.dart';

import 'package:chaldea/app/modules/common/builders.dart';
import 'package:chaldea/models/models.dart';
import 'package:chaldea/utils/utils.dart';
import 'package:chaldea/widgets/widgets.dart';
import 'descriptor_base.dart';
import 'mission_cond_detail.dart';

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
        TextSpan(
          text: M.of(
            jp: null,
            cn: '总计$targetNum: ',
            tw: null,
            na: 'Total $targetNum: ',
            kr: null,
          ),
        )
      ];

      for (int index = 0; index < details.length; index++) {
        spans.add(const TextSpan(text: '『'));
        spans.addAll(MissionCondDetailDescriptor(
          targetNum: null,
          detail: details[index],
          useAnd: details[index].useAnd,
          eventId: eventId,
          // unknownMsg: null,
        ).buildContent(context));
        spans.add(const TextSpan(text: '』'));
        if (index != details.length - 1) {
          spans.add(TextSpan(
            text: (useAnd ?? false)
                ? M.of(jp: null, cn: '且', tw: null, na: ' AND ', kr: null)
                : M.of(jp: null, cn: '或', tw: null, na: ' OR ', kr: null),
          ));
        }
      }

      return Text.rich(
        TextSpan(children: spans),
        textScaleFactor: textScaleFactor,
        style: style,
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
        bool all = targetNum == targetIds.length && targetNum != 1 && useAnd != false;
        bool onlyOne = targetNum == 1 && targetIds.length == 1;
        return localized(
          jp: () => combineToRich(
            context,
            '${all ? "すべての" : ""}クエストを${onlyOne ? "" : "$targetNum種"}クリアせよ',
            quests(context),
          ),
          cn: () => combineToRich(
            context,
            '通关${all ? "所有" : ""}${onlyOne ? "" : "$targetNum个"}关卡',
            quests(context),
          ),
          tw: null,
          na: () => combineToRich(
            context,
            'Clear ${all ? "all " : ""}${onlyOne ? "quest" : "$targetNum quests"} of ',
            quests(context),
          ),
          kr: null,
        );
      case CondType.questNotClear:
      case CondType.questNotClearAnd:
        // condNum is not used I think
        bool and = condType == CondType.questNotClearAnd;
        return localized(
          jp: null,
          cn: () => combineToRich(
            context,
            '未通关以下${and ? "所有" : "任意"}关卡',
            quests(context),
          ),
          tw: null,
          na: () => combineToRich(
            context,
            'Have not cleared ${and ? "all " : "any "}quests of ',
            quests(context),
          ),
          kr: null,
        );
      case CondType.questClearPhase:
        return localized(
          jp: () => combineToRich(context, null, quests(context), '進行度$targetNumをクリアせよ'),
          cn: () => combineToRich(context, '通关', quests(context), '进度$targetNum'),
          tw: null,
          na: () => combineToRich(context, 'Cleared arrow $targetNum of quest', quests(context)),
          kr: null,
        );
      case CondType.questClearNum:
        return localized(
          jp: () => combineToRich(context, '以下のクエストを$targetNum回クリアせよ', quests(context)),
          cn: () => combineToRich(context, '通关$targetNum次以下关卡', quests(context)),
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
          cn: () => combineToRich(context, '$gotText灵衣', [costumeWidget]),
          tw: null,
          na: () => combineToRich(context, '$gotText Costume ', [costumeWidget]),
          kr: null,
        );
      case CondType.svtLimit:
        return localized(
          jp: () => combineToRich(context, null, servants(context), 'の霊基再臨を$targetNum段階目にする'),
          cn: () => combineToRich(context, null, servants(context), '达到灵基再临第$targetNum阶段'),
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
          jp: () => combineToRich(context, null, servants(context), 'の絆レベルが$targetNumになる'),
          cn: () => combineToRich(context, null, servants(context), '的羁绊等级达到$targetNum'),
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
          jp: () => combineToRich(context, null, servants(context), 'は霊基一覧の中にいる'),
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
          jp: () => combineToRich(context, 'イベント', events(context), 'は終了した'),
          cn: () => combineToRich(context, '活动', events(context), '结束'),
          tw: null,
          na: () => combineToRich(context, 'Event ', events(context), ' has ended'),
          kr: () => combineToRich(context, '이벤트 ', events(context), ' 종료'),
        );
      case CondType.svtHaving:
        return localized(
          jp: () => combineToRich(context, 'サーヴァント', servants(context), 'を持っている'),
          cn: () => combineToRich(context, '持有从者', servants(context)),
          tw: null,
          na: () => combineToRich(context, 'Presence of Servant ', servants(context)),
          kr: null,
        );
      case CondType.notSvtHaving:
        return localized(
          jp: () => combineToRich(context, 'サーヴァント', servants(context), 'を持ってない'),
          cn: () => combineToRich(context, '未持有从者', servants(context)),
          tw: null,
          na: () => combineToRich(context, 'Does not presence of Servant ', servants(context)),
          kr: null,
        );
      case CondType.svtHavingLimitMax:
        return localized(
          jp: null,
          cn: () => combineToRich(context, '持有从者且满破', servants(context)),
          tw: null,
          na: () => combineToRich(context, 'Having servant and reached Max Limit Break', servants(context)),
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
          jp: () => combineToRich(context, null, servants(context), 'の霊基再臨を ≥ $targetNum段階目にする'),
          cn: () => combineToRich(context, '从者', servants(context), '的灵基再临 ≥ $targetNum'),
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
          jp: () => combineToRich(context, null, servants(context), 'の霊基再臨を ≤ $targetNum段階目にする'),
          cn: () => combineToRich(context, '从者', servants(context), '的灵基再临 ≤ $targetNum'),
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
              jp: () => text('『${frags.join('/')}』クラスのサーヴァント$targetNum騎をLv.$lv以上にせよ'),
              cn: () => text('将$targetNum骑${frags.join('/')}从者升级到$lv级以上'),
              tw: null,
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
            tw: null,
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
              cn: () => text('让$targetNum骑$classIdsStr从者达到灵基再临第$limit阶段'),
              tw: null,
              na: () => text('Raise $targetNum $classIdsStr to ascension $limit'),
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
            tw: null,
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
          final frags = List.generate(levels.length, (index) => 'Lv.${levels[index]} ${rarities[index]}$kStarChar}');
          return localized(
            jp: () => text('${frags.join('/')} の概念礼装$targetNum種をレベルアップする'),
            cn: () => text('升级$targetNum种 ${frags.join(' 或 ')} 礼装'),
            tw: null,
            na: () => text('Raise $targetNum ${frags.join(' or ')} CEs'),
            kr: null,
          );
        }
      case CondType.allSvtTargetSkillLvNum:
        return localized(
          jp: () => text('スキル$targetNumつをLv.${targetIds.join("/")}以上にせよ'),
          cn: () => text('升级$targetNum个技能至Lv.${targetIds.join("/")}以上'),
          tw: null,
          na: () => text('Upgrade $targetNum skills to Lv.${targetIds.join("/")} or higher'),
          kr: null,
        );
      case CondType.svtClassFriendshipCount:
        return localized(
          jp: () => text('『$classIdsStr』クラスのサーヴァントの絆レベルを合計$targetNum以上にせよ'),
          cn: () => text('『$classIdsStr』职阶从者牵绊等级合计达到$targetNum以上'),
          tw: null,
          na: () => text('Accumulatively reach $targetNum bond levels for [$classIdsStr] class servants'),
          kr: null,
        );
      case CondType.svtClassSkillLvUpCount:
        return localized(
          jp: () => text('『$classIdsStr』クラスのサーヴァントのスキルを合計$targetNum回強化せよ(同一霊基不可) '),
          cn: () => text('『$classIdsStr』职阶从者技能强化累计$targetNum次（不计算相同灵基）'),
          tw: null,
          na: () => text(
              'Accumulatively increase skill levels $targetNum times for [$classIdsStr] class servants (not include duplicate servants)'),
          kr: null,
        );
      case CondType.svtClassLvUpCount:
        return localized(
          jp: () => text('『$classIdsStr』クラスのサーヴァントのLvを合計$targetNum回強化せよ(同一霊基不可) '),
          cn: () => text('『$classIdsStr』职阶从者等级强化累计$targetNum次（不计算相同灵基）'),
          tw: null,
          na: () => text(
              'Accumulatively level up [$classIdsStr] class servants $targetNum times (not include duplicate servants)'),
          kr: null,
        );
      case CondType.svtClassLimitUpCount:
        return localized(
          jp: () => text('『$classIdsStr』クラスのサーヴァントを合計$targetNum回霊基再臨せよ(同一霊基不可) '),
          cn: () => text('『$classIdsStr』职阶从者灵基再临累计$targetNum次（不计算相同灵基）'),
          tw: null,
          na: () => text(
              'Accumulatively ascend [$classIdsStr] class servants $targetNum times (not include duplicate servants)'),
          kr: null,
        );
      case CondType.svtFriendshipClassNumAbove:
        // サーヴァント5騎の絆レベルをLv.6以上にせよ
        // 106, 206, 306, 406, 506
        List<int> clsIds = [];
        List<int> counts = [];
        for (final id in targetIds) {
          clsIds.add(id ~/ 100);
          counts.add(id % 100);
        }
        if (counts.toSet().length == 1) {
          final level = counts.first;
          if (_isPlayableAll(clsIds)) {
            return localized(
              jp: () => text('サーヴァント$targetNum騎の絆レベルをLv.$level以上にせよ'),
              cn: () => text('让$targetNum骑从者的牵绊等级达到Lv.$level以上'),
              tw: null,
              na: () => text('Reach Bond Level $level or above on any $targetNum Servants'),
              kr: null,
            );
          } else {
            return localized(
              jp: () => text('『$classIdsStr』クラスのサーヴァント$targetNum騎の絆レベルをLv.$level以上にせよ'),
              cn: () => text('让$targetNum骑$classIdsStr骑从者的牵绊等级达到Lv.$level以上'),
              tw: null,
              na: () => text('Reach Bond Level $level or above on $targetNum [$classIdsStr] Servants'),
              kr: null,
            );
          }
        } else {
          break;
        }
      case CondType.svtSkillLvClassNumAbove:
        break;
      case CondType.notShopPurchase:
        final countText = targetNum == 1 ? "" : M.of(cn: "$targetNum次", na: '$targetNum times of ');
        return localized(
          jp: null,
          cn: () => combineToRich(context, '未兑换$countText商店', shops(context)),
          tw: null,
          na: () => combineToRich(context, 'Have not purchased ${countText}shop', shops(context)),
          kr: null,
        );
      case CondType.purchaseShop:
        final countText = targetNum <= 1 ? "" : M.of(cn: "$targetNum次", na: '$targetNum times of ');
        return localized(
          jp: null,
          cn: () => combineToRich(context, '已兑换$countText商店', shops(context)),
          tw: null,
          na: () => combineToRich(context, 'Have purchased ${countText}shop', shops(context)),
          kr: null,
        );
      case CondType.notEventShopPurchase:
        return localized(
          jp: null,
          cn: () => combineToRich(context, '未兑换活动商店', events(context)),
          tw: null,
          na: () => combineToRich(context, 'Have not purchased event shop', events(context)),
          kr: null,
        );
      case CondType.shopGroupLimitNum:
        return localized(
          jp: null,
          cn: () => combineToRich(context, '同组(${targetIds.join(",")})商店最多可兑换$targetNum次'),
          tw: null,
          na: () => combineToRich(context, 'Max $targetNum time(s) purchasing shop group ${targetIds.join(",")}'),
          kr: null,
        );
      case CondType.eventTotalPoint:
        return localized(
          jp: () => text('イベントポイントを$targetNum点獲得'),
          cn: () => text('活动点数达到$targetNum点'),
          tw: null,
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
              jp: () => combineToRich(
                context,
                claim ? 'ミッションを達成(報酬を受け取り): ' : 'ミッションをクリア: ',
                missionList(context, missionMap),
              ),
              cn: () => combineToRich(
                context,
                claim ? '达成任务(领取奖励): ' : '完成任务: ',
                missionList(context, missionMap),
              ),
              tw: null,
              na: () => combineToRich(
                context,
                claim ? 'Achieve mission (claim rewards): ' : 'Clear mission: ',
                missionList(context, missionMap),
              ),
              kr: null,
            );
          } else {
            return localized(
              jp: () => combineToRich(
                context,
                claim ? '以下のすべてのミッションを達成せよ(報酬を受け取り): ' : '以下のすべてのミッションをクリアせよ: ',
              ),
              cn: () => combineToRich(
                context,
                claim ? '达成以下全部任务(领取奖励): ' : '完成以下全部任务: ',
                missionList(context, missionMap),
              ),
              tw: null,
              na: () => combineToRich(
                context,
                claim ? 'Achieve all missions (claim rewards) of ' : 'Clear all missions of ',
                missionList(context, missionMap),
              ),
              kr: null,
            );
          }
        } else {
          return localized(
            jp: () => combineToRich(
              context,
              claim ? '以下の異なるクエスト$targetNum個を達成せよ(報酬を受け取り): ' : '以下の異なるクエスト$targetNum個をクリアせよ: ',
              missionList(context, missionMap),
            ),
            cn: () => combineToRich(
              context,
              claim ? '达成$targetNum个不同的任务(领取奖励): ' : '完成$targetNum个不同的任务: ',
              missionList(context, missionMap),
            ),
            tw: null,
            na: () => combineToRich(
              context,
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
          tw: null,
          na: () => text('Start Random Mission: $targets'),
          kr: null,
        );
      case CondType.latestMainScenarioWarClear:
        return localized(
          jp: null,
          cn: () => text('通关最新主线剧情'),
          tw: null,
          na: () => text('Clear latest main scenario'),
          kr: null,
        );
      case CondType.itemGet:
        return localized(
          jp: null,
          cn: () => combineToRich(context, '持有$targetNum个素材', items(context)),
          tw: null,
          na: () => combineToRich(context, 'Have $targetNum item(s)', items(context)),
          kr: null,
        );
      case CondType.notItemGet:
        return localized(
          jp: null,
          cn: () => combineToRich(context, '未持有$targetNum个素材', items(context)),
          tw: null,
          na: () => combineToRich(context, 'Don not have $targetNum item(s)', items(context)),
          kr: null,
        );
      case CondType.date:
        final time = DateTime.fromMillisecondsSinceEpoch(targetNum * 1000).toStringShort(omitSec: true);
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
    if (unknownMsg != null) return text(unknownMsg!);
    return localized(
      jp: () => text('不明な条件(${condType.name}): $targetNum, $targetIds'),
      cn: () => text('未知条件(${condType.name}): $targetNum, $targetIds'),
      tw: null,
      na: () => text('Unknown Cond(${condType.name}): $targetNum, $targetIds'),
      kr: () => text('미확인 (${condType.name}): $targetNum, $targetIds'),
    );
  }
}
