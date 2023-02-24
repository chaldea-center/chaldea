import 'package:chaldea/app/battle/utils/battle_utils.dart';
import 'package:chaldea/models/db.dart';
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
