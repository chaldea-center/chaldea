import 'dart:async';

import 'package:chaldea/app/battle/models/battle.dart';
import 'package:chaldea/app/battle/utils/battle_logger.dart';
import 'package:chaldea/app/modules/common/misc.dart';
import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/models/models.dart';
import 'package:chaldea/utils/utils.dart';
import 'package:chaldea/widgets/widgets.dart';
import '_dialog.dart';

class TdTypeChangeSelector extends StatelessWidget {
  final BattleData battleData;
  final List<CardType> tdTypes;
  final Completer<CardType?> completer;
  const TdTypeChangeSelector({super.key, required this.battleData, required this.tdTypes, required this.completer});

  static Future<CardType?> show(BattleData battleData, List<CardType> tdTypes) {
    if (!battleData.mounted) return Future.value();
    return showUserConfirm<CardType>(
      context: battleData.context!,
      builder: (context, completer) =>
          TdTypeChangeSelector(battleData: battleData, tdTypes: tdTypes, completer: completer),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tdTypes = this.tdTypes.toList();
    tdTypes.sort2((e) => [CardType.quick, CardType.arts, CardType.buster].indexOf(e));
    return SimpleCancelOkDialog(
      title: Text(S.current.battle_select_effect),
      content: Row(
        children: [
          for (final tdType in tdTypes)
            Flexible(
              child: InkWell(
                onTap: () {
                  Navigator.of(context).pop(tdType);
                  battleData.battleLogger.action('${S.current.battle_select_effect}: ${tdType.name.toUpperCase()}'
                      ' ${S.current.battle_np_card}');
                },
                child: CommandCardWidget(card: tdType, width: 80),
              ),
            )
        ],
      ),
      hideOk: true,
      hideCancel: true,
      actions: [
        TextButton(
          onPressed: () {
            completer.completeError(const BattleCancelException("Cancel TdTypeChange"));
            Navigator.pop(context);
          },
          child: Text(S.current.cancel),
        )
      ],
    );
  }
}
