import 'dart:async';

import 'package:chaldea/app/battle/models/battle.dart';
import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/models/models.dart';
import 'package:chaldea/widgets/widgets.dart';
import '../utils/battle_logger.dart';
import '_dialog.dart';

class SkillActSelectDialog extends StatelessWidget {
  final BattleData battleData;
  final BattleServantData? activator;
  final BaseSkill skill;
  final int skillLevel;
  final Completer<int> completer;

  const SkillActSelectDialog({
    super.key,
    required this.battleData,
    required this.activator,
    required this.skill,
    required this.skillLevel,
    required this.completer,
  });

  static Future<int> show(
    final BattleData battleData,
    final BattleServantData? activator,
    final BaseSkill skill,
    final int skillLevel,
  ) {
    if (!battleData.mounted) return Future.value(-1);
    return showUserConfirm<int>(
      context: battleData.context!,
      builder: (context, completer) => SkillActSelectDialog(
        battleData: battleData,
        activator: activator,
        skill: skill,
        skillLevel: skillLevel,
        completer: completer,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final selectAddInfo = skill.script!.SelectAddInfo![skillLevel - 1];
    final buttons = selectAddInfo.btn;
    final transl = Transl.miscScope('SelectAddInfo');

    return SimpleConfirmDialog(
      title: Text(S.current.battle_select_effect),
      scrollable: true,
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: divideTiles([
          Padding(
            padding: const EdgeInsets.all(4.0),
            child: Text(
              '${transl('Optional').l}: ${transl(selectAddInfo.title).l}',
              textScaler: const TextScaler.linear(0.85),
            ),
          ),
          ...List.generate(buttons.length, (index) {
            final button = buttons[index];
            final textWidget = Padding(padding: const EdgeInsets.all(4.0), child: Text.rich(button.buildSpan(index)));
            return TextButton(
              onPressed:
                  button.conds.every(
                    (cond) =>
                        !BattleSkillInfoData.checkSkillScriptCondition(battleData, activator, cond.cond, cond.value),
                  )
                  ? null
                  : () {
                      Navigator.of(context).pop(index);
                      battleData.battleLogger.action(
                        '${S.current.battle_select_effect}: ${transl('Option').l} ${index + 1}',
                      );
                    },
              child: textWidget,
            );
          }),
          TextButton(
            onPressed: () {
              completer.completeError(const BattleCancelException("Cancel SelectActSelect"));
              Navigator.of(context).pop();
            },
            child: Text(S.current.cancel),
          ),
        ]),
      ),
      showOk: false,
      showCancel: false,
    );
  }
}
