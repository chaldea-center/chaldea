import 'package:chaldea/app/battle/models/battle.dart';
import 'package:chaldea/app/modules/common/misc.dart';
import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/models/models.dart';
import 'package:chaldea/widgets/widgets.dart';
import '_dialog.dart';

class TdTypeChangeSelector extends StatelessWidget {
  final BattleData battleData;
  final List<NiceTd> tds;
  const TdTypeChangeSelector({super.key, required this.battleData, required this.tds});

  static Future<NiceTd?> show(BattleData battleData, List<NiceTd> tds) {
    if (!battleData.mounted) return Future.value();
    tds = tds.toList();
    tds.sort((a, b) => (a.svt.card.index % 3).compareTo(b.svt.card.index % 3)); // Q A B
    return showUserConfirm<NiceTd>(
      context: battleData.context!,
      builder: (context, _) => TdTypeChangeSelector(battleData: battleData, tds: tds),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SimpleCancelOkDialog(
      title: Text(S.current.battle_select_effect),
      content: Row(
        children: List.generate(tds.length, (index) {
          return Flexible(
            child: InkWell(
              onTap: () {
                Navigator.of(context).pop(tds[index]);
                battleData.battleLogger
                    .action('${S.current.battle_select_effect}: ${tds[index].svt.card.name.toUpperCase()}'
                        ' ${S.current.battle_np_card}');
              },
              child: CommandCardWidget(card: tds[index].svt.card, width: 80),
            ),
          );
        }),
      ),
      hideOk: true,
      hideCancel: true,
    );
  }
}
