import 'dart:math';

import 'package:flutter/widgets.dart';

import 'package:chaldea/app/battle/utils/battle_utils.dart';
import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/models/models.dart';
import 'package:chaldea/utils/utils.dart';
import '../models/battle.dart';

class BattleCancelException implements Exception {
  final String msg;
  final bool toast;
  const BattleCancelException([this.msg = "", this.toast = false]);

  @override
  String toString() {
    return "BattleCancelException: $msg, $toast";
  }
}

class BattleLogger {
  final List<BattleLog> logs = [];

  void _log(final BattleLogType type, final String log) {
    logs.add(BattleLog(type, log));
  }

  void action(final String log) {
    _log(BattleLogType.action, log);
  }

  void function(final String log) {
    _log(BattleLogType.function, log);
  }

  void debug(final String log) {
    _log(BattleLogType.debug, log);
  }

  void error(String log) {
    _log(BattleLogType.error, log);
  }
}

class BattleLog {
  final BattleLogType type;
  final String log;

  BattleLog(this.type, this.log);

  @override
  String toString() => "BattleLog(${type.name}): $log";
}

enum BattleLogType { debug, function, action, error }

class BattleRecordManager {
  List<BattleRecord> records = [];

  BattleIllegalReasons reasons = BattleIllegalReasons();

  BattleRecordManager();

  BattleRecordManager copy() {
    return BattleRecordManager()
      ..reasons = reasons.copy()
      ..records = records.toList()
      .._cardHistory = _cardHistory.toList();
  }

  void message(String msg, {BattleServantData? target}) {
    records.add(BattleMessageRecord(msg, target: target));
  }

  void messageRich(BattleMessageRecord msg) {
    records.add(msg);
  }

  void progressWave(int wave) {
    records.add(BattleProgressWaveRecord(wave));
  }

  void skipWave(int wave) {
    reasons.setReplay('Skip Wave $wave');
    records.add(BattleSkipWaveRecord(wave));
  }

  void progressTurn(int turn) {
    records.add(BattleProgressTurnRecord(turn));
  }

  void skillActivation(final BattleData battleData, final int? svt, final int skill) {
    records.add(
      BattleSkillActivationRecord(
        playerTarget: battleData.playerTargetIndex,
        enemyTarget: battleData.enemyTargetIndex,
        random: battleData.options.random,
        threshold: battleData.options.threshold,
        tailoredExecution: battleData.options.tailoredExecution,
        svt: svt,
        skill: skill,
      ),
    );
  }

  void skill({
    required BattleData battleData,
    required BattleServantData? activator,
    required BattleSkillInfoData skill,
    required bool fromPlayer,
    required bool uploadEligible,
    String? prefix,
    BattleSkillParams? param,
  }) {
    if (!uploadEligible) {
      reasons.setUpload('${S.current.skill} ${skill.type.name}: ${skill.lName}');
    }

    records.add(
      BattleSkillRecord(
        prefix: prefix,
        activator: activator,
        targetPlayerSvt: battleData.targetedPlayer,
        targetEnemySvt: battleData.targetedEnemy,
        skill: skill,
        fromPlayer: fromPlayer,
        param: param,
      ),
    );
  }

  void orderChange({required BattleServantData onField, required BattleServantData backup}) {
    records.add(BattleOrderChangeRecord(onField: onField, backup: backup));
  }

  List<_BattleCardTempData> _cardHistory = [];

  void initiateAttacks(final BattleData battleData, final List<CombatAction> combatActions) {
    records.add(
      BattleAttacksInitiationRecord(
        playerTarget: battleData.playerTargetIndex,
        enemyTarget: battleData.enemyTargetIndex,
        random: battleData.options.random,
        threshold: battleData.options.threshold,
        tailoredExecution: battleData.options.tailoredExecution,
        attacks: combatActions,
      ),
    );
  }

  void startPlayerCard(BattleServantData activator, CommandCardData card) {
    _cardHistory.add(_BattleCardTempData(activator, card));
  }

  void setOverCharge(BattleServantData activator, CommandCardData card, int oc) {
    final last = _cardHistory.lastOrNull;
    assert(last != null && last.actor == activator && last.card == card);
    if (last != null && last.actor == activator && last.card == card) {
      card.oc = oc;
    } else {
      assert(() {
        throw Exception("last card is not desired");
      }());
    }
  }

  void attack(BattleServantData activator, BattleAttackRecord record) {
    final _last = _cardHistory.lastOrNull;
    assert(_last == null || _last.actor.uniqueId == activator.uniqueId);
    if (_last != null) {
      record.card = _last.card;
      _last.hasAttack = true;
    }
    if (record.targets.isNotEmpty) records.add(record);
  }

  void endPlayerCard(BattleServantData activator, CommandCardData card) {
    final _last = _cardHistory.removeLast();
    assert(_last.actor.uniqueId == activator.uniqueId && _last.card?.cardIndex == card.cardIndex);
    if (!_last.hasAttack) {
      // supporter TD
      records.add(
        BattleAttackRecord(
          activator: activator,
          card: card,
          targets: [],
          damage: 0,
          attackNp: 0,
          defenseNp: 0,
          star: 0,
        ),
      );
    }
  }

  void instantDeath(BattleInstantDeathRecord record) {
    final card = _cardHistory.lastWhereOrNull((card) => card.actor.uniqueId == record.activator?.uniqueId);
    record.card = card?.card;
    records.add(record);
  }

  // move to somewhere else
  void determineUploadEligibility(final QuestPhase questPhase, final BattleOptions options) {
    if (questPhase.id <= 0) {
      reasons.setReplay('${S.current.general_custom}: ${S.current.quest} ${questPhase.id}');
    }
    if (!questPhase.isLaplaceSharable) {
      reasons.setUpload(S.current.quest_disallow_laplace_share_hint);
    }
    if (options.pointBuffs.isNotEmpty) {
      // setIllegal(S.current.event_point);
    }
    if (options.disableEvent) {
      reasons.setUpload('${S.current.options}: ${S.current.disable_event_effects}');
    }
    if (options.simulateEnemy) {
      reasons.setUpload('${S.current.options}: ${S.current.simulate_enemy_actions}');
    }
    final shouldMightyChain = questPhase.shouldEnableMightyChain();
    if (options.mightyChain != shouldMightyChain) {
      reasons.setUpload("Mighty Chain(QAB Chain) should be ${shouldMightyChain ? 'ON' : 'OFF'}");
    }
    if (questPhase.isLaplaceNeedAi) {
      if (!options.simulateAi) {
        reasons.setUpload("${S.current.options}: ${S.current.simulate_simple_ai} must be enabled");
      }
    } else {
      if (options.simulateAi) {
        reasons.setUpload('${S.current.options}: ${S.current.simulate_simple_ai}');
      }
    }

    if (options.formation.allSvts.where((e) => e.supportType != SupportSvtType.none).length > 1) {
      reasons.setUpload('${S.current.support_servant}: ＞1');
    }
    final maxCost = Maths.max(ConstData.userLevel.values.map((e) => e.maxCost), 115);
    if (options.formation.totalCost > maxCost) {
      reasons.setUpload('COST ${options.formation.totalCost}>$maxCost');
    }

    Map<int, int> svtCounts = {};
    for (final svtData in options.formation.allSvts) {
      final svtId = svtData.svt?.id ?? 0;
      if (svtId != 0) svtCounts.addNum(svtId, 1);
      _checkSvtEligible(svtData, questPhase);
    }
    svtCounts.removeWhere((k, v) => v < 2);
    if (svtCounts.length > 1) {
      reasons.setUpload(
        svtCounts.entries.map((e) => '${e.value} ${db.gameData.servantsById[e.key]?.lName.l ?? e.key}').join(', '),
      );
    }
  }

  void _checkSvtEligible(PlayerSvtData svtData, QuestPhase questPhase) {
    final svt = svtData.svt;
    if (svt == null) return;
    final svtName = svt.lName.l;
    if (svtData.supportType == SupportSvtType.npc) {
      reasons.setReplay('Guest Support/NPC: $svtName');
    }
    if (!svt.isUserSvt) {
      reasons.setUpload('Not player servant: $svtName');
    }
    if (svtData.customPassives.isNotEmpty) {
      reasons.setUpload('${S.current.extra_passive}(${S.current.general_custom})');
    }
    if (svtData.disabledExtraSkills.isNotEmpty) {
      reasons.setUpload("${svtData.disabledExtraSkills.length} disabled extra skills");
    }
    if (svtData.fixedAtk != null || svtData.fixedHp != null) {
      reasons.setReplay('Fixed HP or ATK (mainly Guest Support). If you see this msg, tell me the bug.');
    }
    final dbSvt = db.gameData.servantsById[svt.id];
    if (dbSvt == null) {
      reasons.setReplay('Servant not in database: ${svt.id}-${svt.lName.l}');
      return;
    }
    for (final skillNum in kActiveSkillNums) {
      final skillId = svtData.skills.getOrNull(skillNum - 1)?.id;
      if (skillId == null) continue;
      final validSkills = BattleUtils.getShownSkills(dbSvt, svtData.limitCount, skillNum).map((e) => e.id).toSet();
      if (!validSkills.contains(skillId)) {
        reasons.setUpload('${S.current.custom_skill} $skillNum - ID $skillId, valid: $validSkills');
      }
    }
    final validTds = BattleUtils.getShownTds(dbSvt, svtData.limitCount).map((e) => e.id).toSet();
    if (svtData.td != null && !validTds.contains(svtData.td?.id)) {
      reasons.setUpload(
        '${S.current.general_custom} ${S.current.noble_phantasm}: ID ${svtData.td!.id}, valid: $validTds',
      );
    }
    if (svtData.equip1.ce != null && svtData.equip1.ce!.collectionNo <= 0) {
      reasons.setUpload('${S.current.craft_essence}: ID ${svtData.equip1.ce!.id}, not player CE');
    }
    if (svtData.grandSvt || svtData.equip2.ce != null || svtData.equip3.ce != null) {
      reasons.setUpload('Grand Graph system not supported to upload yet');
    }

    // coin
    int requiredCoins = 0, maxCoins = 0;
    int? summonCoin = svt.coin?.summonNum ?? 0;
    if (summonCoin > 0 && svt.rarity >= 4 && svtData.tdLv < 5) {
      // 9th Anniversary
      maxCoins = summonCoin * svtData.tdLv + (questPhase.closedAt < DateTime(2024, 8, 4).timestamp ? 180 : 420);
      requiredCoins += max(((svtData.lv - 100) / 2).ceil() * 30, 0);
      requiredCoins += svtData.appendLvs.where((e) => e > 0).length * 120;
      if (requiredCoins > maxCoins) {
        reasons.setUpload(
          '${S.current.servant_coin}(${svt.lName.l}): required $requiredCoins, '
          'but max $maxCoins at ${S.current.np_short}${svtData.tdLv} & ${S.current.bond}15 ',
        );
      }
    }
  }

  void checkExtraIllegalReason(BattleIllegalReasons reasons2, BattleRuntime runtime) {
    final region = runtime.region;
    if (region != null && region != Region.jp) {
      reasons2.setUpload('Only JP quest supports team sharing. (current: ${region.localName})');
    }

    const kMaxRNG = 950, kMinProb = 80;
    int countLargeRng = 0, countProb = 0;
    final delegate = runtime.battleData.replayDataRecord;
    bool tailoredExecution = delegate.damageSelections.isNotEmpty || delegate.canActivateDecisions.isNotEmpty;
    for (final record in toUploadRecords()) {
      if (record.options.random >= kMaxRNG) {
        countLargeRng += 1;
      }
      tailoredExecution |= record.options.tailoredExecution;
      if (record.options.threshold <= kMinProb) {
        countProb += 1;
      }
    }
    if (tailoredExecution) {
      reasons2.setUpload('${S.current.options}: ${S.current.battle_tailored_execution}');
    }

    if (countLargeRng > 3) {
      reasons2.setUpload('${S.current.battle_random}≥0.95: count $countLargeRng>3');
    }
    if (countProb > 3) {
      reasons2.setUpload('${S.current.battle_probability_threshold}≤80: count $countProb>3');
    }
    //
    final records = runtime.battleData.recorder.records;

    final multiDmgFuncSvts = records
        .whereType<BattleAttackRecord>()
        .where((e) => e.card?.isTD == true && (e.card?.td?.dmgNpFuncCount ?? 0) > 1)
        .map((e) => e.attacker.lBattleName)
        .toSet();
    if (multiDmgFuncSvts.isNotEmpty) {
      reasons2.setWarning('${S.current.laplace_upload_td_multi_dmg_func_hint}: ${multiDmgFuncSvts.join(" / ")}');
    }

    List<String> unreleasedSvts = [];
    int r5td5 = 0;
    for (final svtData in runtime.originalOptions.formation.allSvts) {
      final svt = svtData.svt;
      if (svt == null) continue;
      final releasedAt = svt.extra.getReleasedAt();
      if (runtime.originalQuest.closedAt < releasedAt && releasedAt > 0) {
        unreleasedSvts.add(svt.lName.l);
      }

      if (svt.rarity == 5 && svtData.tdLv >= 5) {
        r5td5 += 1;
      }
    }
    if (unreleasedSvts.isNotEmpty) {
      reasons2.setWarning(
        '$kStarChar2 ${S.current.svt_not_release_hint} $kStarChar2:\n   $kStarChar2 ${unreleasedSvts.join(" / ")}',
      );
    }
    if (r5td5 >= 2) {
      reasons2.setWarning(S.current.too_many_td5_svts_warning(r5td5));
    }

    int totalCards = 0, attackedCards = 0;
    for (final record in records) {
      if (record is BattleAttacksInitiationRecord) {
        final selectedCards = record.attacks.where((e) => !e.cardData.cardType.isExtra()).toList();
        totalCards += selectedCards.length;
        // totalNormalCards += selectedCards.where((e) => !e.cardData.isTD).length;
      } else if (record is BattleAttackRecord) {
        if (record.card?.cardType.isQAB() ?? true) {
          attackedCards += 1;
        }
      } else if (record is BattleInstantDeathRecord) {
        if (record.card?.isTD == true) {
          attackedCards += 1;
        }
      }
    }
    if (totalCards > attackedCards) {
      reasons2.setWarning(S.current.card_not_attack_warning(totalCards - attackedCards, totalCards));
    }
    if (runtime.originalQuest.enemyHashes.length > 1 &&
        runtime.originalQuest.allEnemies.any((e) => e.isRareOrAddition)) {
      reasons2.setWarning(S.current.team_rare_enemy_warning);
    }
  }

  List<BattleRecordData> toUploadRecords() {
    final List<BattleRecordData> uploadRecords = [];
    for (final record in records) {
      final uploadRecord = record.toUploadRecord();
      if (uploadRecord != null) {
        uploadRecords.add(uploadRecord);
      }
    }
    return uploadRecords;
  }
}

class BattleIllegalReasons {
  final Set<String> notReplayable;
  final Set<String> notUploadable;
  final Set<String> warnings;

  BattleIllegalReasons({Set<String>? reproduces, Set<String>? uploads, Set<String>? warnings})
    : notReplayable = reproduces ?? {},
      notUploadable = uploads ?? {},
      warnings = warnings ?? {};

  void setReplay(String msg) => notReplayable.add(msg);
  void setUpload(String msg) => notUploadable.add(msg);
  void setWarning(String msg) => warnings.add(msg);

  BattleIllegalReasons copy() {
    return BattleIllegalReasons(
      reproduces: notReplayable.toSet(),
      uploads: notUploadable.toSet(),
      warnings: warnings.toSet(),
    );
  }
}

class _BattleCardTempData {
  final BattleServantData actor;
  CommandCardData? card;
  BattleAttackRecord? attack;
  bool hasAttack = false;

  _BattleCardTempData(this.actor, this.card);
}

const _kOneRowRecordHeight = 32.0; // with svt icon

/// Only record user visible actions
/// make sealed when dart 2.19 enabled
abstract class BattleRecord {
  BattleRecord();

  BattleRecord copy();

  BattleRecordData? toUploadRecord() {
    return null;
  }

  double get estimatedHeight;
}

class BattleMessageRecord extends BattleRecord {
  final String message;
  final AlignmentGeometry? alignment;
  final TextStyle? style;
  final TextAlign? textAlign;
  final BattleServantData? target;
  BattleMessageRecord(this.message, {BattleServantData? target, this.alignment, this.style, this.textAlign})
    : target = target?.copy();

  @override
  BattleMessageRecord copy() {
    return BattleMessageRecord(
      message,
      target: target?.copy(),
      alignment: alignment,
      style: style?.copyWith(),
      textAlign: textAlign,
    );
  }

  @override
  double get estimatedHeight => _kOneRowRecordHeight;
}

class BattleSkipWaveRecord extends BattleRecord {
  // skip [wave], then start [wave+1]
  final int wave;
  BattleSkipWaveRecord(this.wave);

  @override
  String toString() {
    return 'Skip Wave $wave';
  }

  @override
  BattleSkipWaveRecord copy() {
    return BattleSkipWaveRecord(wave);
  }

  @override
  double get estimatedHeight => 21.0;
}

class BattleProgressWaveRecord extends BattleRecord {
  // start [wave]
  final int wave;
  BattleProgressWaveRecord(this.wave);

  @override
  String toString() {
    return 'Start Wave $wave';
  }

  @override
  BattleProgressWaveRecord copy() {
    return BattleProgressWaveRecord(wave);
  }

  @override
  double get estimatedHeight => 36;
}

class BattleProgressTurnRecord extends BattleRecord {
  // start [wave]
  final int turn;
  BattleProgressTurnRecord(this.turn);

  @override
  String toString() {
    return 'Start Turn $turn';
  }

  @override
  BattleProgressWaveRecord copy() {
    return BattleProgressWaveRecord(turn);
  }

  @override
  double get estimatedHeight => 21;
}

class BattleSkillActivationRecord extends BattleRecord {
  final BattleRecordData recordData;

  BattleSkillActivationRecord({
    required final int playerTarget,
    required final int enemyTarget,
    required final int random,
    required final int threshold,
    required final bool tailoredExecution,
    required final int? svt,
    required final int skill,
  }) : recordData = BattleRecordData.skill(
         options: BattleActionOptions(
           playerTarget: playerTarget,
           enemyTarget: enemyTarget,
           random: random,
           threshold: threshold,
           tailoredExecution: tailoredExecution,
         ),
         svt: svt,
         skill: skill,
       );

  @override
  BattleRecord copy() {
    return BattleSkillActivationRecord(
      playerTarget: recordData.options.playerTarget,
      enemyTarget: recordData.options.enemyTarget,
      random: recordData.options.random,
      threshold: recordData.options.threshold,
      tailoredExecution: recordData.options.tailoredExecution,
      svt: recordData.svt,
      skill: recordData.skill!,
    );
  }

  @override
  BattleRecordData? toUploadRecord() {
    return recordData;
  }

  @override
  double get estimatedHeight => 0;
}

class BattleSkillParams {
  int? selectAddIndex;
  int? actSet;
  int? tdTypeChange;

  BattleSkillParams({this.selectAddIndex, this.actSet, this.tdTypeChange});

  BattleSkillParams copy() {
    return BattleSkillParams(selectAddIndex: selectAddIndex, actSet: actSet, tdTypeChange: tdTypeChange);
  }
}

class BattleSkillRecord extends BattleRecord {
  final String? prefix;
  final BattleServantData? activator;
  final BattleServantData? targetPlayerSvt;
  final BattleServantData? targetEnemySvt;
  final BattleSkillInfoData skill;
  final bool fromPlayer;
  final BattleSkillParams param;

  BattleSkillRecord({
    this.prefix,
    required BattleServantData? activator,
    required BattleServantData? targetPlayerSvt,
    required BattleServantData? targetEnemySvt,
    required BattleSkillInfoData skill,
    required this.fromPlayer,
    BattleSkillParams? param,
  }) : activator = activator?.copy(),
       targetPlayerSvt = targetPlayerSvt?.copy(),
       targetEnemySvt = targetEnemySvt?.copy(),
       skill = skill.copy(),
       param = param ?? BattleSkillParams();

  @override
  String toString() {
    return '${skill.type.name}: ${activator?.lBattleName} Skill: ${skill.lName}';
  }

  @override
  BattleSkillRecord copy() {
    return BattleSkillRecord(
      prefix: prefix,
      activator: activator,
      targetPlayerSvt: targetPlayerSvt,
      targetEnemySvt: targetEnemySvt,
      skill: skill,
      fromPlayer: fromPlayer,
      param: param.copy(),
    );
  }

  @override
  double get estimatedHeight => _kOneRowRecordHeight;
}

class BattleOrderChangeRecord extends BattleRecord {
  final BattleServantData onField;
  final BattleServantData backup;
  BattleOrderChangeRecord({required BattleServantData onField, required BattleServantData backup})
    : onField = onField.copy(),
      backup = backup.copy();

  @override
  String toString() {
    return 'Order Change: ${onField.lBattleName} ↔ ${backup.lBattleName}';
  }

  @override
  BattleOrderChangeRecord copy() {
    return BattleOrderChangeRecord(onField: onField, backup: backup);
  }

  @override
  double get estimatedHeight => _kOneRowRecordHeight;
}

class BattleAttacksInitiationRecord extends BattleRecord {
  final int playerTarget;
  final int enemyTarget;
  final int random;
  final int threshold;
  final bool tailoredExecution;
  final List<CombatAction> attacks;

  BattleAttacksInitiationRecord({
    required this.playerTarget,
    required this.enemyTarget,
    required this.random,
    required this.threshold,
    required this.tailoredExecution,
    required List<CombatAction> attacks,
  }) : attacks = attacks.map((e) => e.copy()).toList();

  @override
  BattleRecord copy() {
    return BattleAttacksInitiationRecord(
      playerTarget: playerTarget,
      enemyTarget: enemyTarget,
      random: random,
      threshold: threshold,
      tailoredExecution: tailoredExecution,
      attacks: attacks.map((e) => e.copy()).toList(),
    );
  }

  @override
  BattleRecordData? toUploadRecord() {
    return BattleRecordData.attack(
      options: BattleActionOptions(
        playerTarget: playerTarget,
        enemyTarget: enemyTarget,
        random: random,
        threshold: threshold,
        tailoredExecution: tailoredExecution,
      ),
      attacks: [
        for (final attack in attacks)
          BattleAttackRecordData(
            svt: attack.actor.fieldIndex,
            card: attack.cardData.cardIndex,
            isTD: attack.cardData.isTD,
            critical: attack.cardData.critical,
            cardType: attack.cardData.cardType,
          ),
      ],
    );
  }

  @override
  double get estimatedHeight => _kOneRowRecordHeight;
}

class BattleAttackRecord extends BattleRecord {
  final BattleServantData attacker;
  CommandCardData? card;
  final List<AttackResultDetail> targets;
  final int damage;
  final int attackNp;
  final int defenseNp;
  final int star;

  BattleAttackRecord({
    required BattleServantData activator,
    required CommandCardData? card,
    required this.targets,
    required this.damage,
    required this.attackNp,
    required this.defenseNp,
    required this.star,
  }) : attacker = activator.copy(),
       card = card?.copy();
  @override
  String toString() {
    return '${attacker.lBattleName} Play ${card?.cardType.name.toTitle()} Card.'
        ' damage=$damage, NP=$attackNp, defNp=$defenseNp, star=$star';
  }

  @override
  BattleAttackRecord copy() {
    return BattleAttackRecord(
      activator: attacker,
      card: card,
      targets: targets.map((e) => e.copy()).toList(),
      damage: damage,
      attackNp: attackNp,
      defenseNp: defenseNp,
      star: star,
    );
  }

  @override
  double get estimatedHeight {
    if (targets.isEmpty) return 95.0;
    final maxFieldIndex = Maths.max(targets.map((e) => e.target.fieldIndex));
    final rows = max((maxFieldIndex + 1 / 3).ceil(), 1);
    return rows * 140;
  }
}

class AttackResultDetail {
  final BattleServantData target;
  final BattleServantData targetBefore;
  final DamageParameters damageParams;
  final AttackNpGainParameters attackNpParams;
  final DefendNpGainParameters defenseNpParams;
  final StarParameters starParams;
  final DamageResult result;
  final DamageResult? minResult;
  final DamageResult? maxResult;

  AttackResultDetail({
    required BattleServantData target,
    required BattleServantData targetBefore,
    required DamageParameters damageParams,
    required AttackNpGainParameters attackNpParams,
    required DefendNpGainParameters defenseNpParams,
    required StarParameters starParams,
    required DamageResult result,
    required DamageResult? minResult,
    required DamageResult? maxResult,
  }) : target = target.copy(),
       targetBefore = targetBefore.copy(),
       damageParams = damageParams.copy(),
       attackNpParams = attackNpParams.copy(),
       defenseNpParams = defenseNpParams.copy(),
       starParams = starParams.copy(),
       result = result.copy(),
       minResult = minResult?.copy(),
       maxResult = maxResult?.copy();

  AttackResultDetail copy() {
    return AttackResultDetail(
      target: target,
      targetBefore: targetBefore,
      damageParams: damageParams,
      attackNpParams: attackNpParams,
      defenseNpParams: defenseNpParams,
      starParams: starParams,
      result: result,
      minResult: minResult,
      maxResult: maxResult,
    );
  }
}

class BattleLossHpRecord extends BattleRecord {
  @override
  BattleRecord copy() => this;

  @override
  double get estimatedHeight => _kOneRowRecordHeight;
}

class BattleReduceHpRecord extends BattleRecord {
  @override
  BattleRecord copy() => this;

  @override
  double get estimatedHeight => _kOneRowRecordHeight;
}

class BattleInstantDeathRecord extends BattleRecord {
  final bool forceInstantDeath;
  final BattleServantData? activator;
  CommandCardData? card;
  final List<InstantDeathResultDetail> targets;

  BattleInstantDeathRecord({
    required this.forceInstantDeath,
    required BattleServantData? activator,
    CommandCardData? card,
    required this.targets,
  }) : activator = activator?.copy(),
       card = card?.copy();

  @override
  BattleInstantDeathRecord copy() {
    return BattleInstantDeathRecord(
      forceInstantDeath: forceInstantDeath,
      activator: activator?.copy(),
      card: card,
      targets: targets.map((e) => e.copy()).toList(),
    );
  }

  bool get hasSuccess {
    return targets.any((e) => e.params.success);
  }

  @override
  double get estimatedHeight {
    final maxFieldIndex = Maths.max(targets.map((e) => e.target.fieldIndex));
    final rows = max((maxFieldIndex + 1 / 3).ceil(), 1);
    return rows * 103;
  }
}

class InstantDeathResultDetail {
  final BattleServantData target;
  final InstantDeathParameters params;

  InstantDeathResultDetail({required BattleServantData target, required InstantDeathParameters params})
    : target = target.copy(),
      params = params.copy();

  InstantDeathResultDetail copy() {
    return InstantDeathResultDetail(target: target, params: params.copy());
  }
}
