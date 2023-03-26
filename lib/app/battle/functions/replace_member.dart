import 'package:chaldea/app/battle/models/battle.dart';
import 'package:chaldea/app/battle/models/svt_entity.dart';
import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/models/gamedata/gamedata.dart';
import 'package:chaldea/widgets/widgets.dart';

class ReplaceMember {
  ReplaceMember._();

  static Future<bool> replaceMember(
    final BattleData battleData,
    final DataVals dataVals,
  ) async {
    final functionRate = dataVals.Rate ?? 1000;
    if (functionRate < battleData.probabilityThreshold) {
      return false;
    }

    if (battleData.nonnullAllies.where((svt) => svt.canOrderChange(battleData)).isEmpty ||
        battleData.nonnullBackupAllies.where((svt) => svt.canOrderChange(battleData)).isEmpty) {
      return false;
    }

    battleData.nonnullAllies.forEach((svt) {
      svt.removeBuffWithTrait(NiceTrait(id: Trait.buffLockCardsDeck.id));
    });

    final List<BattleServantData?> onFieldList = battleData.onFieldAllyServants;
    final List<BattleServantData?> backupList = battleData.playerDataList;

    final List<BattleServantData> selections = [];
    selections.addAll(await getSelectedServants(battleData));

    onFieldList[onFieldList.indexOf(selections.first)] = selections.last;
    backupList[backupList.indexOf(selections.last)] = selections.first;

    selections.last.enterField(battleData);

    return true;
  }

  static Future<List<BattleServantData>> getSelectedServants(final BattleData battleData) async {
    if (battleData.context?.mounted != true) return [];
    return await showDialog(
      context: battleData.context!,
      useRootNavigator: false,
      barrierDismissible: false,
      builder: (context) {
        return ReplaceMemberSelectionDialog(battleData: battleData);
      },
    );
  }
}

class ReplaceMemberSelectionDialog extends StatefulWidget {
  final BattleData battleData;

  const ReplaceMemberSelectionDialog({super.key, required this.battleData});

  @override
  State<ReplaceMemberSelectionDialog> createState() => _ReplaceMemberSelectionDialogState();
}

class _ReplaceMemberSelectionDialogState extends State<ReplaceMemberSelectionDialog> {
  BattleServantData? onFieldSelection;
  BattleServantData? backupSelection;

  BattleData get battleData => widget.battleData;

  @override
  Widget build(final BuildContext context) {
    final List<Widget> children = [];

    final List<BattleServantData> selectableOnField =
        battleData.nonnullAllies.where((svt) => svt.canOrderChange(battleData)).toList();
    children.addAll([
      SHeader(
        S.current.battle_select_battle_servants,
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
                overrideIcon: svt.niceSvt!.ascendIcon(svt.ascensionPhase, true),
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
        battleData.nonnullBackupAllies.where((svt) => svt.canOrderChange(battleData)).toList();
    children.addAll([
      SHeader(
        S.current.battle_select_backup_servants,
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
                overrideIcon: svt.niceSvt!.ascendIcon(svt.ascensionPhase, true),
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
            if (onFieldSelection == null || backupSelection == null) {
              return;
            }

            final List<BattleServantData> results = [];
            results.add(onFieldSelection!);
            results.add(backupSelection!);

            battleData.logger.action('${S.current.battle_select_battle_servants}: ${onFieldSelection!.lBattleName} - '
                '${S.current.battle_select_backup_servants}: ${backupSelection!.lBattleName}');
            Navigator.of(context).pop(results);
          },
          child: Text(S.current.confirm),
        )
      ],
    );
  }
}
