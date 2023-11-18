import 'dart:async';

import 'package:tuple/tuple.dart';

import 'package:chaldea/app/battle/utils/battle_logger.dart';
import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/widgets/widgets.dart';
import '../models/battle.dart';
import '_dialog.dart';

class ReplaceMemberSelectionDialog extends StatefulWidget {
  final BattleData battleData;

  final Completer<Tuple2<BattleServantData, BattleServantData>> completer;

  const ReplaceMemberSelectionDialog({super.key, required this.battleData, required this.completer});

  @override
  State<ReplaceMemberSelectionDialog> createState() => _ReplaceMemberSelectionDialogState();

  static Future<Tuple2<BattleServantData, BattleServantData>?> show(final BattleData battleData) async {
    if (!battleData.mounted) return null;
    return showUserConfirm<Tuple2<BattleServantData, BattleServantData>>(
      context: battleData.context!,
      builder: (context, completer) => ReplaceMemberSelectionDialog(
        battleData: battleData,
        completer: completer,
      ),
    );
  }
}

class _ReplaceMemberSelectionDialogState extends State<ReplaceMemberSelectionDialog> {
  BattleServantData? onFieldSelection;
  BattleServantData? backupSelection;

  BattleData get battleData => widget.battleData;

  @override
  Widget build(final BuildContext context) {
    final List<Widget> children = [];

    final List<BattleServantData> selectableOnField =
        battleData.nonnullPlayers.where((svt) => svt.canOrderChange()).toList();
    children.addAll([
      SHeader(
        S.current.team_starting_member,
        padding: const EdgeInsets.only(top: 8.0, bottom: 4.0),
      ),
      Wrap(
        children: List.generate(selectableOnField.length, (index) {
          final svt = selectableOnField[index];
          return DecoratedBox(
            decoration: onFieldSelection == svt
                ? BoxDecoration(
                    borderRadius: BorderRadius.circular(5),
                    border: Border.all(color: Colors.redAccent, width: 4),
                  )
                : const BoxDecoration(),
            child: InkWell(
              child: svt.niceSvt!.iconBuilder(
                context: context,
                jumpToDetail: false,
                width: 56,
                overrideIcon: svt.niceSvt!.ascendIcon(svt.limitCount),
              ),
              onTap: () {
                onFieldSelection = svt;
                if (mounted) setState(() {});
              },
            ),
          );
        }),
      )
    ]);

    final List<BattleServantData> selectableBackup =
        battleData.nonnullBackupPlayers.where((svt) => svt.canOrderChange()).toList();
    children.addAll([
      SHeader(
        S.current.team_backup_member,
        padding: const EdgeInsets.only(top: 8.0, bottom: 4.0),
      ),
      Wrap(
        children: List.generate(selectableBackup.length, (index) {
          final svt = selectableBackup[index];
          return DecoratedBox(
            decoration: backupSelection == svt
                ? BoxDecoration(
                    borderRadius: BorderRadius.circular(5),
                    border: Border.all(color: Colors.redAccent, width: 4),
                  )
                : const BoxDecoration(),
            child: InkWell(
              child: svt.niceSvt!.iconBuilder(
                context: context,
                jumpToDetail: false,
                width: 56,
                overrideIcon: svt.niceSvt!.ascendIcon(svt.limitCount),
              ),
              onTap: () {
                backupSelection = svt;
                if (mounted) setState(() {});
              },
            ),
          );
        }),
      )
    ]);

    return SimpleCancelOkDialog(
      title: Text(S.current.battle_click_to_select_servants),
      scrollable: true,
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
      hideCancel: true,
      hideOk: true,
      actions: [
        TextButton(
          onPressed: () {
            widget.completer.completeError(const BattleCancelException("Cancel Change Order"));
            Navigator.of(context).pop();
          },
          child: Text(S.current.cancel),
        ),
        TextButton(
          onPressed: onFieldSelection == null || backupSelection == null
              ? null
              : () {
                  final result = Tuple2(onFieldSelection!, backupSelection!);

                  battleData.battleLogger
                      .action('${S.current.team_starting_member}: ${onFieldSelection!.lBattleName} - '
                          '${S.current.team_backup_member}: ${backupSelection!.lBattleName}');
                  Navigator.of(context).pop(result);
                },
          child: Text(S.current.confirm),
        ),
      ],
    );
  }
}
