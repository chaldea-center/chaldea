import 'package:chaldea/app/battle/models/battle.dart';
import 'package:chaldea/models/db.dart';
import 'package:chaldea/models/gamedata/gamedata.dart';

enum BattleChainType {
  none(0),
  arts(1),
  buster(2),
  quick(3),
  brave(4),
  braveAndArts(5),
  braveAndBuster(6),
  braveAndQuick(7),
  treasureDvc(8),
  mighty(9),
  braveAndMighty(10),
  error(99); // not in dw enum

  const BattleChainType(this.value);
  final int value;

  bool isValidChain() => this != none && this != error;
  bool isArtsChain() => this == arts || this == braveAndArts;
  bool isBusterChain() => this == buster || this == braveAndBuster;
  bool isQuickChain() => this == quick || this == braveAndQuick;
  bool isSameColorChain() => isArtsChain() || isBusterChain() || isQuickChain();
  bool isBraveChain() =>
      this == brave ||
      this == braveAndArts ||
      this == braveAndBuster ||
      this == braveAndQuick ||
      this == braveAndMighty;
  bool isMightyChain() => this == mighty || this == braveAndMighty;
  bool isChainError() => this == error;

  List<int> get individuality {
    final constants = ConstData.constants;
    return [
      if (isArtsChain()) constants.artsChainIndividuality,
      if (isBusterChain()) constants.busterChainIndividuality,
      if (isQuickChain()) constants.quickChainIndividuality,
      if (isBraveChain()) constants.braveChainIndividuality,
      if (isMightyChain()) constants.mightyChainIndividuality,
      if (isChainError()) constants.chainErrorIndividuality,
    ];
  }

  static BattleChainType fromBasicChains({
    required bool artsChain,
    required bool busterChain,
    required bool quickChain,
    required bool mightyChain,
    required bool braveChain,
  }) {
    assert(<bool>[artsChain, busterChain, quickChain, mightyChain].where((e) => e).length <= 1);
    if (mightyChain) {
      return braveChain ? braveAndMighty : mighty;
    }
    if (artsChain) {
      return braveChain ? braveAndArts : arts;
    }
    if (busterChain) {
      return braveChain ? braveAndBuster : buster;
    }
    if (quickChain) {
      return braveChain ? braveAndQuick : quick;
    }
    if (braveChain) return brave;
    return none;
  }
}

class BattleCommandData {
  int type = 0; // player enemy
  int svtId = 0;
  int svtlimit = 0;
  int attri = 0;
  int follower = 0;

  // ignore: unused_field
  final int _loadSvtLimit = -1;

  // static const PASS_STAR_DENOMINATOR = 100;
  int uniqueId = 0;
  int markindex = 0;
  int treasureDvc = 0;
  bool flgEventJoin = false;
  int starBonus = 0;
  int starcount = 0;
  int passStarCount = 0;
  bool critical = false;
  bool isCriticalMiss = false;
  int userCommandCodeId = -1;
  int commandCodeId = -1;
  bool flash = false;
  bool sameflg = false; // same svt, brave?
  int samecount = 0;
  int actionIndex = 0;
  int addAtk = 0;
  int addCritical = 0;
  int addTdGauge = 0;
  int chainCount = 0;
}

class CommandCardData {
  final int svtId;
  final int svtLimit;
  final int uniqueId;
  final CardType cardType;
  final CardDetail cardDetail;
  final int cardIndex;
  int cardStrengthen = 0;
  int npGain = 0;
  List<NiceTrait> _traits = [];
  bool isTD = false;
  int np = 0;
  bool critical = false;
  CommandCode? commandCode;
  NiceTd? td;
  BuffData? counterBuff;
  int? oc;
  BattleChainType chainType = BattleChainType.none;

  List<NiceTrait> get traits => [
    ..._traits,
    if (critical) NiceTrait(id: Trait.criticalHit.value),
    for (final v in chainType.individuality) NiceTrait(id: v),
  ];
  set traits(List<NiceTrait> traits) => _traits = traits;

  CommandCardData._(this.svtId, this.svtLimit, this.uniqueId, this.cardType, this.cardDetail, this.cardIndex);

  CommandCardData(BattleServantData svt, this.cardType, this.cardDetail, this.cardIndex)
    : svtId = svt.svtId,
      svtLimit = svt.limitCount,
      uniqueId = svt.uniqueId;

  CommandCardData copy() {
    return CommandCardData._(svtId, svtLimit, uniqueId, cardType, cardDetail, cardIndex)
      ..cardStrengthen = cardStrengthen
      ..npGain = npGain
      .._traits = _traits.toList()
      ..isTD = isTD
      ..np = np
      ..critical = critical
      ..commandCode = commandCode
      ..td = td
      ..counterBuff = counterBuff
      ..oc = oc
      ..chainType = chainType;
  }
}

class CombatAction {
  BattleServantData actor;
  CommandCardData cardData;

  CombatAction(this.actor, this.cardData);

  bool isValid(final BattleData battleData) {
    if (cardData.isTD) {
      return battleData.delegate?.whetherTd?.call(actor) ?? actor.canNP();
    } else {
      return actor.canCommandCard(cardData);
    }
  }

  bool isValidCounter(final BattleData battleData) {
    if (cardData.isTD) {
      final delegateResult = battleData.delegate?.whetherTd?.call(actor);
      if (delegateResult != null) {
        return delegateResult;
      }
      return actor.canCommandCard(cardData) && !actor.isNPSealed();
    } else {
      return actor.canCommandCard(cardData);
    }
  }

  CombatAction copy() {
    return CombatAction(actor.copy(), cardData.copy());
  }
}
