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
  final DamageParameters damageParameters;

  const DamageAdjustor({super.key, required this.battleData, required this.damageParameters});

  @override
  State<DamageAdjustor> createState() => _DamageAdjustorState();

  static Future<int> show(final BattleData battleData, final DamageParameters damageParameters) async {
    if (battleData.options.tailoredExecution && battleData.mounted) {
      return showUserConfirm<int>(
        context: battleData.context!,
        barrierDismissible: false,
        builder: (context, _) {
          return DamageAdjustor(battleData: battleData, damageParameters: damageParameters);
        },
      );
    }

    int damage = 0;
    try {
      damage = calculateDamage(damageParameters);
    } catch (e) {
      battleData.battleLogger.error(e.toString());
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

    return SimpleCancelOkDialog(
      title: Text(S.current.battle_select_effect),
      scrollable: true,
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${widget.battleData.activator!.lBattleName} - '
            '${widget.damageParameters.currentCardType.name.toTitle()} - '
            '${widget.damageParameters.isNp ? S.current.battle_np_card : S.current.battle_command_card}'
            '\nvs ${widget.battleData.target!.lBattleName} (HP: ${widget.battleData.target!.hp})',
            style: Theme.of(context).textTheme.bodyMedium,
            textScaleFactor: 0.9,
          ),
          const SizedBox(height: 8),
          Text('${S.current.battle_damage}: $totalDamage'),
          SliderWithTitle(
            leadingText: S.current.battle_random,
            min: ConstData.constants.attackRateRandomMin,
            max: ConstData.constants.attackRateRandomMax - 1,
            value: widget.damageParameters.fixedRandom,
            label: toModifier(widget.damageParameters.fixedRandom).toStringAsFixed(3),
            onChange: (v) {
              widget.damageParameters.fixedRandom = v.round();
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
