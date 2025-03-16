import 'package:chaldea/app/battle/models/battle.dart';
import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/models/models.dart';
import 'package:chaldea/widgets/widgets.dart';
import '_dialog.dart';

class FuncActSetSelector extends StatelessWidget {
  final BattleData battleData;
  final Map<int, List<NiceFunction>> actSets;
  const FuncActSetSelector({super.key, required this.battleData, required this.actSets});

  static Future<int?> show(BattleData battleData, final Map<int, List<NiceFunction>> actSets) {
    if (!battleData.mounted) return Future.value();
    return showUserConfirm<int?>(
      context: battleData.context!,
      allowNull: true,
      builder: (context, _) => FuncActSetSelector(battleData: battleData, actSets: actSets),
    );
  }

  @override
  Widget build(BuildContext context) {
    final transl = Transl.miscScope('SelectAddInfo');

    List<Widget> children = [];
    final setIds = actSets.keys.toList();
    for (int index = 0; index < setIds.length; index++) {
      final setId = setIds[index];
      final funcs = actSets[setId]!;
      children.add(
        TextButton(
          onPressed: () {
            Navigator.of(context).pop(setId);
            battleData.battleLogger.action('${S.current.battle_select_effect}: ${transl('Option').l} $setId');
          },
          child: Padding(
            padding: const EdgeInsets.all(4.0),
            child: Text(
              '${transl('Option').l} $setId: ${funcs.map((e) => e.lPopupText.l).join(', ')}',
              style: const TextStyle(fontSize: 18),
            ),
          ),
        ),
      );
    }
    children.add(
      TextButton(
        onPressed: () {
          Navigator.of(context).pop(-1);
          battleData.battleLogger.action('${S.current.battle_select_effect}: ${transl('Option').l} ${S.current.skip}');
        },
        child: Padding(
          padding: const EdgeInsets.all(4.0),
          child: Text(S.current.skip, style: const TextStyle(fontSize: 18)),
        ),
      ),
    );
    return SimpleConfirmDialog(
      title: Text(S.current.battle_select_effect),
      scrollable: true,
      content: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: children),
      showOk: false,
      showCancel: false,
    );
  }
}
