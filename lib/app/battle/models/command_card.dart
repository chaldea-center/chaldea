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
  CardType cardType;
  CardDetail cardDetail;
  int cardStrengthen = 0;
  int npGain = 0;
  List<NiceTrait> traits = [];
  bool isNP = false;
  int np = 0;
  int cardIndex = -1;
  bool isCritical = false;
  CommandCode? commandCode;
  NiceTd? td;
  BuffData? counterBuff;
  int? oc;

  CommandCardData(this.cardType, this.cardDetail);

  CommandCardData copy() {
    return CommandCardData(cardType, cardDetail)
      ..cardStrengthen = cardStrengthen
      ..npGain = npGain
      ..traits = traits.toList()
      ..isNP = isNP
      ..np = np
      ..cardIndex = cardIndex
      ..isCritical = isCritical
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
    if (cardData.isNP) {
      return battleData.delegate?.whetherTd?.call(actor) ?? actor.canNP(battleData);
    } else {
      return actor.canCommandCard(battleData, cardData);
    }
  }
}
