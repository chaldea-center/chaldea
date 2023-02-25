import 'dart:typed_data';

import 'package:chaldea/app/battle/utils/battle_utils.dart';
import 'package:chaldea/models/db.dart';
import 'package:chaldea/models/gamedata/gamedata.dart';
import 'package:chaldea/models/gamedata/servant.dart';
import 'package:chaldea/utils/basic.dart';
import 'package:chaldea/widgets/widgets.dart';

class NpDamageCalculator extends StatelessWidget {
  const NpDamageCalculator({super.key});

  @override
  Widget build(BuildContext context) {
    Servant? servant = db.gameData.servantsById[100100];

    BasicServant? baseEnemy = db.gameData.entities[9933600];

    var niceTd = servant!.noblePhantasms.last;
    var dataVal = niceTd.functions.first.svals.first;

    DamageParameters parameters = DamageParameters()
      ..attack = servant.atkGrowth[89]
      ..damageRate = dataVal.Value!
      ..totalHits = Maths.sum(niceTd.npDistribution)
      ..npSpecificAttackRate = 1000
      ..attackerClass = servant.className
      ..defenderClass = baseEnemy!.className
      ..classAdvantage = 1000
      ..attackerAttribute = servant.attribute
      ..defenderAttribute = baseEnemy.attribute
      ..isNp = true
      ..currentCardType = niceTd.card
      ..firstCardType = niceTd.card
      ..fixedRandom = 0.9;

    // TODO: Gather the following to a test
    var perHit = 25;
    var byteData = ByteData(4);
    byteData.setFloat32(0, 800 / 1000.0);
    byteData.setFloat32(0, 1 + byteData.getFloat32(0));
    byteData.setFloat32(0, 6 * byteData.getFloat32(0));
    byteData.setFloat32(0, 1 + byteData.getFloat32(0));
    var cardBonus = byteData.getFloat32(0);
    byteData.setFloat32(0, 300 / 1000.0);
    byteData.setFloat32(0, 1 + byteData.getFloat32(0));
    var gainBonus = byteData.getFloat32(0);
    var crit = 2;
    var base = perHit * cardBonus * 1 * gainBonus * crit;

    byteData.setFloat32(0, perHit.toDouble());
    byteData.setFloat32(0, cardBonus * byteData.getFloat32(0));
    byteData.setFloat32(0, 1 * byteData.getFloat32(0));
    byteData.setFloat32(0, gainBonus * byteData.getFloat32(0));
    byteData.setFloat32(0, crit * byteData.getFloat32(0));
    var base2 = byteData.getFloat32(0);

    byteData.setFloat32(0, 800 / 1000.0);
    byteData.setFloat32(0, 6 * (1 + byteData.getFloat32(0)));
    var cardBonus2 = 1 + byteData.getFloat32(0);
    byteData.setFloat32(0, 300 / 1000.0);
    var gainBonus2 = 1 + byteData.getFloat32(0);
    byteData.setFloat32(0, cardBonus2 * gainBonus2);
    var floatCalFirst = byteData.getFloat32(0);

    byteData.setFloat32(0, (perHit  * 1  * crit) * floatCalFirst);
    var base3 = byteData.getFloat32(0);

    print("base: ");
    print(base);
    print(base.floor());
    print("base2: ");
    print(base2);
    print(base2.floor());
    print("base3: ");
    print(base3);
    print(base3.floor());

    var atkNpParam = AttackNpGainParameters()
      ..firstCardType = CardType.quick
      ..isMightyChain = true
      ..currentCardType = CardType.arts
      ..chainPos = 3
      ..attackerNpCharge = 25
      ..defenderNpRate = 1000
      ..cardBuff = 1600
      ..cardResist = 800
      ..npGainBuff = 300
      ..isCritical = true;

    print(calculateAttackNpGain(atkNpParam)); // 766

    return Scaffold(
      body: Center(
        child: Column(
          children: [
            Text("Attacker: ${servant.battleName}, Class: ${servant.className}"),
            Text("Defender: ${baseEnemy.name}, Class: ${baseEnemy.className}"),
            Text("Parameters: $parameters"),
            Text("Damage: ${calculateDamage(parameters)}"),
          ],
        ),
      ),
    );
  }
}
