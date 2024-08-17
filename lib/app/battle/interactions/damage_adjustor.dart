import 'package:chaldea/app/battle/utils/battle_utils.dart';
import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/models/models.dart';
import 'package:chaldea/utils/catcher/catcher_util.dart';
import 'package:chaldea/utils/utils.dart';
import 'package:chaldea/widgets/widgets.dart';
import '../models/battle.dart';
import '../utils/battle_exception.dart';
import '_dialog.dart';

class DamageAdjustor extends StatefulWidget {
  final BattleData battleData;
  final BattleServantData activator;
  final BattleServantData target;
  final DamageParameters damageParameters;
  final CommandCardData currentCard;
  final int? multiAttack;

  const DamageAdjustor({
    super.key,
    required this.battleData,
    required this.activator,
    required this.target,
    required this.damageParameters,
    required this.currentCard,
    this.multiAttack,
  });

  @override
  State<DamageAdjustor> createState() => _DamageAdjustorState();

  static Future<int> show(
    final BattleData battleData,
    final BattleServantData activator,
    final BattleServantData target,
    final DamageParameters damageParameters,
    final CommandCardData currentCard,
    final int? multiAttack,
  ) async {
    int damage = 0;
    try {
      damage = calculateDamage(damageParameters);
    } catch (e) {
      battleData.battleLogger.error(e.toString());
    }

    if (battleData.options.tailoredExecution) {
      if (battleData.delegate?.damageRandom != null) {
        return await battleData.delegate!.damageRandom!.call(damage);
      } else if (battleData.mounted) {
        final damage = await showUserConfirm<int>(
          context: battleData.context!,
          barrierDismissible: false,
          builder: (context, _) {
            return DamageAdjustor(
                battleData: battleData, activator: activator, target: target, damageParameters: damageParameters, currentCard: currentCard, multiAttack: multiAttack,);
          },
        );
        battleData.replayDataRecord.damageSelections.add(damage);
        return damage;
      }
    }

    return damage;
  }
}

class _DamageAdjustorState extends State<DamageAdjustor> {
  bool exceptionThrown = false;

  @override
  Widget build(BuildContext context) {
    int totalDamage = 0;
    try {
      totalDamage = calculateDamage(widget.damageParameters);
    } on BattleException catch (e) {
      if (!exceptionThrown) {
        widget.battleData.battleLogger.error(e.toString());
      }
      exceptionThrown = true;
    } catch (e, s) {
      if (!exceptionThrown) {
        widget.battleData.battleLogger.error(e.toString());
        CatcherUtil.reportError(e, s);
      }
      exceptionThrown = true;
    }

    final List<int> hitDamages = [];
    final List<int> hits = [];
    int remainingDamage = totalDamage;
    if (widget.multiAttack != null && widget.multiAttack! > 0) {
      for (final hit in widget.currentCard.cardDetail.hitsDistribution) {
        for (int count = 1; count <= widget.multiAttack!; count += 1) {
          hits.add(hit);
        }
      }
    } else {
      hits.addAll(widget.currentCard.cardDetail.hitsDistribution);
    }
    final totalHits = Maths.sum(hits);
    for (int i = 0; i < hits.length; i += 1) {
      final hitsPercentage = hits[i];
      final int hitDamage;
      if (i < hits.length - 1) {
        hitDamage = totalDamage * hitsPercentage ~/ totalHits;
      } else {
        hitDamage = remainingDamage;
      }
      hitDamages.add(hitDamage);
      remainingDamage -= hitDamage;
    }

    return SimpleCancelOkDialog(
      title: Text(S.current.battle_select_effect),
      scrollable: true,
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${widget.activator.lBattleName} - '
            '${widget.damageParameters.currentCardType.name.toTitle()} - '
            '${widget.damageParameters.isNp ? S.current.battle_np_card : S.current.battle_command_card}'
            '\nvs ${widget.target.lBattleName} (HP: ${widget.target.hp})',
            style: Theme.of(context).textTheme.bodyMedium,
            textScaler: const TextScaler.linear(0.9),
          ),
          const SizedBox(height: 8),
          Text('${S.current.battle_damage}: $totalDamage'),
          Text(hitDamages.join(', '), style: Theme.of(context).textTheme.bodySmall),
          SliderWithPrefix(
            titled: true,
            label: S.current.battle_random,
            min: ConstData.constants.attackRateRandomMin,
            max: ConstData.constants.attackRateRandomMax - 1,
            value: widget.damageParameters.random,
            valueFormatter: (v) => toModifier(v).toStringAsFixed(3),
            onChange: (v) {
              widget.damageParameters.random = v.round();
              if (mounted) setState(() {});
            },
          ),
        ],
      ),
      hideOk: true,
      hideCancel: true,
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop(totalDamage);
          },
          child: Text(S.current.confirm),
        )
      ],
    );
  }
}
