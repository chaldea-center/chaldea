part of '../state.dart';

extension FakerRuntimeBattle on FakerRuntime {
  Future<bool> checkSkillShift(BattleEntity battleEntity) async {
    final battleInfo = battleEntity.battleInfo;
    if (battleInfo == null) {
      throw SilentException("battle ${battleEntity.id}: null battleInfo");
    }
    final skillShiftEnemies = [
      ...battleInfo.enemyDeck,
      ...battleInfo.callDeck,
      ...battleInfo.shiftDeck,
    ].expand((e) => e.svts).where((e) => e.isSkillShift()).toList();

    if (skillShiftEnemies.isEmpty) return true;

    if (!battleOption.enableSkillShift) {
      throw SilentException('skillShift not enabled: ${skillShiftEnemies.length} skillShift enemies');
    }

    if (!mounted) {
      throw SilentException('found skillShift but not mounted');
    }

    final skillShiftEnemyUniqueIds = await showLocalDialog<List<int>?>(
      _SkillShiftEnemySelectDialog(
        battleInfo: battleInfo,
        skillShiftEnemies: skillShiftEnemies,
        skillShiftEnemyUniqueIds: battleOption.skillShiftEnemyUniqueIds,
      ),
    );
    if (skillShiftEnemyUniqueIds == null) {
      throw SilentException('cancel skillShift');
    }

    final itemDroppedSkillShiftEnemies = skillShiftEnemies
        .where((e) => skillShiftEnemyUniqueIds.contains(e.uniqueId))
        .toList();
    if (itemDroppedSkillShiftEnemies.length != skillShiftEnemyUniqueIds.length) {
      throw SilentException(
        'valid skillShift uniqueIds: ${skillShiftEnemies.map((e) => e.uniqueId).toSet()}, '
        'but received $skillShiftEnemyUniqueIds',
      );
    }

    battleOption.skillShiftEnemyUniqueIds = skillShiftEnemyUniqueIds.toList();
    return true;
  }
}

class _SkillShiftEnemySelectDialog extends StatefulWidget {
  final BattleInfoData battleInfo;
  final List<BattleDeckServantData> skillShiftEnemies;
  final List<int> skillShiftEnemyUniqueIds;
  const _SkillShiftEnemySelectDialog({
    required this.battleInfo,
    required this.skillShiftEnemies,
    required this.skillShiftEnemyUniqueIds,
  });

  @override
  State<_SkillShiftEnemySelectDialog> createState() => __SkillShiftEnemySelectDialogState();
}

class __SkillShiftEnemySelectDialogState extends State<_SkillShiftEnemySelectDialog> {
  late final skillShiftEnemies = widget.skillShiftEnemies.toList();
  late Set<int> selectedUniqueIds = skillShiftEnemies.map((e) => e.uniqueId).toSet();
  late final userSvtMap = widget.battleInfo.userSvtMap;

  @override
  void initState() {
    super.initState();
    final intersection = selectedUniqueIds.intersection(widget.skillShiftEnemyUniqueIds.toSet());
    if (intersection.isNotEmpty) {
      selectedUniqueIds = intersection;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('skillShift enemies'),
      scrollable: true,
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [for (final enemy in skillShiftEnemies) buildEnemy(enemy)],
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: Text(S.current.cancel),
        ),
        TextButton(
          onPressed: () {
            Navigator.pop(context, [
              for (final enemy in skillShiftEnemies)
                if (selectedUniqueIds.contains(enemy.uniqueId)) enemy.uniqueId,
            ]);
          },
          child: Text(S.current.confirm),
        ),
      ],
    );
  }

  Widget buildEnemy(BattleDeckServantData enemy) {
    final userSvt = userSvtMap[enemy.userSvtId];
    final svt = db.gameData.entities[userSvt?.svtId];
    return CheckboxListTile.adaptive(
      dense: true,
      controlAffinity: ListTileControlAffinity.trailing,
      value: selectedUniqueIds.contains(enemy.uniqueId),
      secondary: svt?.iconBuilder(context: context, width: 32),
      title: Text(enemy.name ?? svt?.lName.l ?? userSvt?.svtId.toString() ?? 'UNKNOWN'),
      subtitle: Text('uniqueId ${enemy.uniqueId} npcId ${enemy.npcId}, id ${enemy.id} userSvtId ${enemy.userSvtId}'),
      onChanged: (v) {
        setState(() {
          selectedUniqueIds.toggle(enemy.uniqueId);
        });
      },
    );
  }
}
