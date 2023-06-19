import 'package:chaldea/app/battle/models/battle.dart';
import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/models/models.dart';
import 'package:chaldea/widgets/widgets.dart';
import '_dialog.dart';

class SkillActSelectDialog extends StatelessWidget {
  final BattleData battleData;
  final BaseSkill skill;
  final int skillLevel;

  const SkillActSelectDialog({super.key, required this.battleData, required this.skill, required this.skillLevel});

  static Future<int> show(
    final BattleData battleData,
    final BaseSkill skill,
    final int skillLevel,
  ) {
    if (!battleData.mounted) return Future.value(-1);
    return showUserConfirm<int>(
      context: battleData.context!,
      builder: (context, _) => SkillActSelectDialog(battleData: battleData, skill: skill, skillLevel: skillLevel),
    );
  }

  @override
  Widget build(BuildContext context) {
    final selectAddInfo = skill.script!.SelectAddInfo![skillLevel - 1];
    final buttons = selectAddInfo.btn;
    final transl = Transl.miscScope('SelectAddInfo');

    return SimpleCancelOkDialog(
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
              textScaleFactor: 0.85,
            ),
          ),
          ...List.generate(buttons.length, (index) {
            final button = buttons[index];
            final textWidget = Padding(
              padding: const EdgeInsets.all(4.0),
              child: Text(
                '${transl('Option').l} ${index + 1}: ${transl(button.name).l}',
                style: const TextStyle(fontSize: 18),
              ),
            );
            return TextButton(
              onPressed: button.conds
                      .every((cond) => !BattleSkillInfoData.checkSkillScripCondition(battleData, cond.cond, cond.value))
                  ? null
                  : () {
                      Navigator.of(context).pop(index);
                      battleData.battleLogger
                          .action('${S.current.battle_select_effect}: ${transl('Option').l} ${index + 1}');
                    },
              child: textWidget,
            );
          })
        ]),
      ),
      hideOk: true,
      hideCancel: true,
    );
  }
}
