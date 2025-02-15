import 'package:chaldea/app/battle/models/battle.dart';
import 'package:chaldea/models/gamedata/gamedata.dart';

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

  List<NiceTrait> get traits => [..._traits, if (critical) NiceTrait(id: Trait.criticalHit.value)];
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
      ..oc = oc;
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

  CombatAction copy() {
    return CombatAction(actor.copy(), cardData.copy());
  }
}
