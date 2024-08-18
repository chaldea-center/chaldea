import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/widgets/widgets.dart';
import '../../../models/gamedata/func.dart';
import '../../../models/gamedata/mappings.dart';
import '../models/battle.dart';
import '_dialog.dart';

class DamageValueAdjustor extends StatefulWidget {
  final BattleServantData? activator;
  final BattleServantData target;
  final FuncType funcType;
  final int minDamage;
  final int maxDamage;

  const DamageValueAdjustor({
    super.key,
    required this.activator,
    required this.target,
    required this.funcType,
    required this.minDamage,
    required this.maxDamage,
  });

  @override
  State<DamageValueAdjustor> createState() => _DamageValueAdjustorState();

  static Future<int> show(
    final BattleData battleData,
    final BattleServantData? activator,
    final BattleServantData target,
    final FuncType funcType,
    final int minDamage,
    final int maxDamage,
  ) async {
    int damage = minDamage;

    if (battleData.options.tailoredExecution) {
      if (battleData.delegate?.damageRandom != null) {
        return await battleData.delegate!.damageRandom!.call(damage);
      } else if (battleData.mounted) {
        final damage = await showUserConfirm<int>(
          context: battleData.context!,
          barrierDismissible: false,
          builder: (context, _) {
            return DamageValueAdjustor(
              activator: activator,
              target: target,
              funcType: funcType,
              minDamage: minDamage,
              maxDamage: maxDamage,
            );
          },
        );
        battleData.replayDataRecord.damageSelections.add(damage);
        return damage;
      }
    }

    return damage;
  }
}

class _DamageValueAdjustorState extends State<DamageValueAdjustor> {
  bool exceptionThrown = false;
  int damage = 0;

  @override
  void initState() {
    super.initState();
    damage = damage.clamp(widget.minDamage, widget.maxDamage);
  }

  @override
  Widget build(BuildContext context) {
    return SimpleCancelOkDialog(
      title: Text(S.current.battle_select_effect),
      scrollable: true,
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${widget.activator?.lBattleName ?? S.current.battle_no_source} - ${Transl.funcType(widget.funcType).l}'
            '\nvs ${widget.target.lBattleName} (HP: ${widget.target.hp})',
            style: Theme.of(context).textTheme.bodyMedium,
            textScaler: const TextScaler.linear(0.9),
          ),
          const SizedBox(height: 8),
          Text('${widget.minDamage} - ${widget.maxDamage}', style: Theme.of(context).textTheme.bodySmall),
          SliderWithPrefix(
            titled: true,
            label: S.current.damage,
            min: widget.minDamage,
            max: widget.maxDamage,
            value: damage,
            onChange: (v) {
              damage = v.toInt();
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
            Navigator.of(context).pop(damage);
          },
          child: Text(S.current.confirm),
        )
      ],
    );
  }
}
