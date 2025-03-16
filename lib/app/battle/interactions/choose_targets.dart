import 'dart:async';

import 'package:chaldea/app/battle/utils/battle_logger.dart';
import 'package:chaldea/app/modules/battle/simulation/recorder.dart';
import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/models/models.dart';
import 'package:chaldea/utils/utils.dart';
import 'package:chaldea/widgets/widgets.dart';
import '../models/battle.dart';
import '_dialog.dart';

class ChooseTargetsDialog extends StatefulWidget {
  final BattleData battleData;
  final FuncTargetType targetType;
  final List<BattleServantData> targets;
  final int maxCount;
  final int minCount;
  final bool autoConfirmOneTarget;

  final Completer<List<BattleServantData>> completer;

  const ChooseTargetsDialog({
    super.key,
    required this.battleData,
    required this.targetType,
    this.targets = const [],
    required this.maxCount,
    required this.minCount,
    required this.completer,
    required this.autoConfirmOneTarget,
  });

  @override
  State<ChooseTargetsDialog> createState() => _ChooseTargetsDialogState();

  static Future<List<BattleServantData>?> show(
    final BattleData battleData, {
    required FuncTargetType targetType,
    required List<BattleServantData> targets,
    int maxCount = 1,
    int minCount = 1,
    bool autoConfirmOneTarget = false,
  }) async {
    assert(maxCount >= minCount && minCount >= 0);
    if (!battleData.mounted) return null;
    return showUserConfirm<List<BattleServantData>>(
      context: battleData.context!,
      builder:
          (context, completer) => ChooseTargetsDialog(
            battleData: battleData,
            completer: completer,
            targetType: targetType,
            targets: targets,
            maxCount: maxCount,
            minCount: minCount,
            autoConfirmOneTarget: autoConfirmOneTarget,
          ),
    );
  }
}

class _ChooseTargetsDialogState extends State<ChooseTargetsDialog> {
  BattleData get battleData => widget.battleData;

  Set<BattleServantData> selected = {};

  @override
  Widget build(final BuildContext context) {
    final List<Widget> children = [];
    final playerSvts = widget.targets.where((e) => e.isPlayer).toList(),
        enemies = widget.targets.where((e) => e.isEnemy).toList();
    final showHeader = playerSvts.isNotEmpty && enemies.isNotEmpty;

    children.add(
      Text(
        [
          "${S.current.select} ${{widget.minCount, widget.maxCount}.join('~')} ${S.current.effect_target}",
          if (widget.minCount == 0) S.current.select_skip,
        ].join("\n"),
      ),
    );

    if (playerSvts.isNotEmpty) {
      if (showHeader) {
        children.add(const SHeader("Player Servants", padding: EdgeInsets.only(top: 8.0, bottom: 4.0)));
      }
      children.add(Wrap(spacing: 8, children: playerSvts.map((e) => buildSvt(e)).toList()));
    }

    if (enemies.isNotEmpty) {
      if (showHeader) {
        children.add(const SHeader("Enemies", padding: EdgeInsets.only(top: 8.0, bottom: 4.0)));
      }
      children.add(Wrap(spacing: 8, children: enemies.map((e) => buildSvt(e)).toList()));
    }

    return SimpleConfirmDialog(
      title: Text('${S.current.select}(${Transl.funcTargetType(widget.targetType).l})'),
      scrollable: true,
      content: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: children),
      showCancel: false,
      showOk: false,
      actions: [
        TextButton(
          onPressed: () {
            widget.completer.completeError(const BattleCancelException("Cancel Target Select"));
            Navigator.of(context).pop();
          },
          child: Text(S.current.cancel),
        ),
        TextButton(
          onPressed: selected.length >= widget.minCount && selected.length <= widget.maxCount ? onConfirm : null,
          child: Text(S.current.confirm),
        ),
      ],
    );
  }

  Widget buildSvt(BattleServantData svt) {
    return DecoratedBox(
      decoration:
          selected.contains(svt)
              ? BoxDecoration(
                borderRadius: BorderRadius.circular(5),
                border: Border.all(color: Colors.redAccent, width: 8),
              )
              : const BoxDecoration(),
      child: InkWell(
        child: svt.iconBuilder(
          context: context,
          width: 56,
          onTap: () {
            final containsCurSvt = selected.contains(svt);
            if (widget.maxCount == 1) {
              selected.clear();
              if (!containsCurSvt) {
                selected.add(svt);
              }
            } else if (selected.length < widget.maxCount || containsCurSvt) {
              selected.toggle(svt);
            }
            if (mounted) setState(() {});
            if (widget.maxCount == 1 && widget.minCount == 1 && widget.autoConfirmOneTarget) {
              onConfirm();
            }
          },
        ),
      ),
    );
  }

  void onConfirm() {
    final chosen = selected.toList();
    chosen.sortByList((e) => [e.isPlayer ? -1 : 1, e.fieldIndex]);
    battleData.battleLogger.action(
      '${S.current.select} (${Transl.funcTargetType(widget.targetType).l}):'
      ' ${chosen.map((e) => "${e.fieldIndex}-${e.lBattleName}")}',
    );
    Navigator.of(context).pop(chosen);
  }
}
