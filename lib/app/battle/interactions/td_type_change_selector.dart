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
  final List<int> tdTypeChangeIds;
  final List<int> tdIndexes;
  final SelectTreasureDeviceInfo? selectTdInfo;
  final Completer<int?> completer;

  const TdTypeChangeSelector({
    super.key,
    required this.battleData,
    required this.tdTypeChangeIds,
    required this.tdIndexes,
    required this.selectTdInfo,
    required this.completer,
  });

  static Future<int?> show(
    BattleData battleData,
    List<int> tdTypeChangeIds,
    List<int> tdIndexes,
    SelectTreasureDeviceInfo? selectTdInfo,
  ) {
    if (!battleData.mounted) return Future.value();
    return showUserConfirm<int>(
      context: battleData.context!,
      builder:
          (context, completer) => TdTypeChangeSelector(
            battleData: battleData,
            tdTypeChangeIds: tdTypeChangeIds,
            tdIndexes: tdIndexes,
            selectTdInfo: selectTdInfo,
            completer: completer,
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tdIndexes = this.tdIndexes.toList();
    if (selectTdInfo == null) {
      tdIndexes.sort2((e) => [CardType.quick.value, CardType.arts.value, CardType.buster.value].indexOf(e));
    }
    List<Widget> children = [];
    final transl = Transl.miscScope('selectTreasureDeviceInfo');
    for (final tdIndex in tdIndexes) {
      final tdId = tdTypeChangeIds.getOrNull(tdIndex - 1);
      SelectTdInfoTdChangeParam? tdInfo;
      if (selectTdInfo != null) {
        tdInfo = selectTdInfo!.treasureDevices.firstWhereOrNull((e) => e.id == tdId);
      }
      CardType cardType = tdInfo?.type ?? CardType.fromId(tdIndex)!;
      Widget child = CommandCardWidget(card: cardType, width: 80);
      if (tdInfo != null && tdInfo.message.isNotEmpty) {
        child = Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            child,
            Text(transl(tdInfo.message).l, textAlign: TextAlign.center, style: const TextStyle(fontSize: 12)),
          ],
        );
      }
      children.add(
        Flexible(
          child: InkWell(
            onTap: () {
              Navigator.of(context).pop(tdIndex);
              battleData.battleLogger.action(
                '${S.current.battle_select_effect}: $tdIndex/${cardType.name.toTitle()}'
                ' ${S.current.battle_np_card}',
              );
            },
            child: child,
          ),
        ),
      );
    }

    // String? title;
    // if (selectTdInfo != null) {
    //   title = transl(selectTdInfo!.title).l;
    //   title = title.replaceAll('\n', '');
    // }
    return SimpleConfirmDialog(
      title: Text(S.current.battle_select_effect),
      content: Row(mainAxisAlignment: MainAxisAlignment.center, children: children),
      showOk: false,
      showCancel: false,
      actions: [
        TextButton(
          onPressed: () {
            completer.completeError(const BattleCancelException("Cancel TdTypeChange"));
            Navigator.pop(context);
          },
          child: Text(S.current.cancel),
        ),
      ],
    );
  }
}
