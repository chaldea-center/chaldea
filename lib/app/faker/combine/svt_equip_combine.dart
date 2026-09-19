import 'package:flutter_easyloading/flutter_easyloading.dart';

import 'package:chaldea/app/app.dart';
import 'package:chaldea/app/modules/common/filter_group.dart';
import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/models/gamedata/mst_tables.dart';
import 'package:chaldea/models/models.dart';
import 'package:chaldea/packages/packages.dart';
import 'package:chaldea/utils/utils.dart';
import 'package:chaldea/widgets/widgets.dart';

import '../../modules/battle/formation/formation_card.dart';
import '../_shared/select_svt_equip.dart';
import '../runtime.dart';
import '../runtimes/combine.dart';

class _SvtEquipCombineData {
  int targetUserSvtId = 0;
  List<int> combineUserSvtIds = [];
}

class SvtEquipCombinePage extends StatefulWidget {
  final FakerRuntime runtime;
  const SvtEquipCombinePage({super.key, required this.runtime});

  @override
  State<SvtEquipCombinePage> createState() => _SvtEquipCombinePageState();
}

class _SvtEquipCombinePageState extends State<SvtEquipCombinePage> with FakerRuntimeStateMixin {
  @override
  late final runtime = widget.runtime;
  late final user = agent.user;
  final options = _SvtEquipCombineData();
  final batchLimitBreakRarity = FilterGroupData<int>(options: {4});
  final Map<int, Set<int>> _limitBreakMaterialIds = {};
  int? _limitBreakInventoryHash;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('礼装强化'),
        actions: [
          IconButton(
            onPressed: () {
              router.pushBuilder(
                builder: (context) => SelectUserSvtEquipPage(
                  runtime: runtime,
                  inUseUserSvtIds: [options.targetUserSvtId],
                  onSelected: (userSvt) {
                    runtime.lockTask(() {
                      options.targetUserSvtId = userSvt.id;
                      options.combineUserSvtIds.remove(userSvt.id);
                      if (mounted) setState(() {});
                    });
                  },
                ),
              );
            },
            icon:
                mstData.userSvt[options.targetUserSvtId]?.dbCE?.iconBuilder(context: context, jumpToDetail: false) ??
                Icon(Icons.change_circle),
          ),
          runtime.buildHistoryButton(context),
          runtime.buildMenuButton(context),
        ],
      ),
      body: ListTileTheme.merge(
        dense: true,
        visualDensity: VisualDensity.compact,
        child: Column(
          children: [
            headerInfo,
            Expanded(child: body),
            const Divider(height: 1),
            buttonBar,
          ],
        ),
      ),
    );
  }

  Widget get headerInfo {
    final baseUserSvt = mstData.userSvt[options.targetUserSvtId];
    final ce = baseUserSvt?.dbCE;
    final expData = ce?.getCurLvExpData(baseUserSvt?.lv ?? 0, baseUserSvt?.exp ?? 0);

    final userGame = mstData.user ?? agent.user.userGame;
    final keepData = mstData.countSvtKeep();
    final storageKeepData = mstData.countSvtKeep(isStorage: true);
    return Container(
      color: Theme.of(context).secondaryHeaderColor,
      padding: const EdgeInsets.only(bottom: 4),
      child: ListTile(
        // dense: true,
        // minTileHeight: 48,
        // visualDensity: VisualDensity.compact,
        minLeadingWidth: 20,
        leading: ce?.iconBuilder(context: context) ?? db.getIconImage(Atlas.common.emptySvtIcon),
        title: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '[${agent.user.serverName}] ${userGame?.displayName}   QP ${userGame?.qp.format(compact: false, groupSeparator: ",")}'
              '\n所持 ${keepData.svtEquipCount}/${runtime.gameData.timerData.constants.maxUserSvtEquip}'
              ' 保管室 ${storageKeepData.svtEquipCount}/${(userGame?.svtEquipStorageAdjust ?? 0) + runtime.gameData.timerData.constants.maxUserSvtEquipStorage}',
            ),
            if (baseUserSvt != null) ...[
              Text(
                '${baseUserSvt.isLocked() ? "🔐 " : ""}Lv.${baseUserSvt.lv}/${baseUserSvt.maxLv}'
                ' limit ${baseUserSvt.limitCount}/4   exp next ${expData?.next.formatSep()}',
              ),
              if (expData != null) BondProgress(value: expData.elapsed, total: expData.total),
            ],
            //
          ],
        ),
      ),
    );
  }

  Widget get body {
    final baseUserSvt = mstData.userSvt[options.targetUserSvtId];
    List<Widget> children = [
      DividerWithTitle(title: 'Status'),
      TileGroup(
        children: [
          ListTile(
            title: Text('🔐 isLock = ${baseUserSvt?.isLocked()}'),
            trailing: IconButton(
              onPressed: () {
                runtime.runTask(() {
                  final userSvt =
                      mstData.userSvt[options.targetUserSvtId] ?? mstData.userSvtStorage[options.targetUserSvtId];
                  if (userSvt == null) {
                    throw SilentException('Card not found');
                  }
                  return runtime.agent.cardStatusSync(
                    changeUserSvtIds: userSvt.isLocked() ? [] : [userSvt.id],
                    revokeUserSvtIds: userSvt.isLocked() ? [userSvt.id] : [],
                    isStorage: mstData.userSvtStorage.containsKey(options.targetUserSvtId),
                    isLock: true,
                    isChoice: false,
                  );
                });
              },
              icon: Icon(Icons.change_circle_outlined),
            ),
          ),
          ListTile(
            title: Text('✴️ isChoice = ${baseUserSvt?.isChoice()}'),
            trailing: IconButton(
              onPressed: () {
                runtime.runTask(() {
                  final userSvt =
                      mstData.userSvt[options.targetUserSvtId] ?? mstData.userSvtStorage[options.targetUserSvtId];
                  if (userSvt == null) {
                    throw SilentException('Card not found');
                  }
                  return runtime.agent.cardStatusSync(
                    changeUserSvtIds: userSvt.isChoice() ? [] : [userSvt.id],
                    revokeUserSvtIds: userSvt.isChoice() ? [userSvt.id] : [],
                    isStorage: mstData.userSvtStorage.containsKey(options.targetUserSvtId),
                    isLock: false,
                    isChoice: true,
                  );
                });
              },
              icon: Icon(Icons.change_circle_outlined),
            ),
          ),
        ],
      ),
      DividerWithTitle(title: 'Manual Enhance'),
      TileGroup(
        header: 'Materials',
        children: [
          ListTile(
            title: options.combineUserSvtIds.isEmpty
                ? Text('None selected')
                : Wrap(
                    spacing: 2,
                    runSpacing: 2,
                    children: options.combineUserSvtIds.map((userSvtId) {
                      final userSvt = mstData.userSvt[userSvtId];
                      final ce = userSvt?.dbCE;
                      Widget child;
                      if (userSvt == null) {
                        child = Text('id $userSvtId');
                      } else if (ce == null) {
                        child = Text('ID $userSvtId');
                      } else {
                        child = ce.iconBuilder(
                          context: context,
                          width: 48,
                          text: SelectUserSvtEquipPage.defaultGetStatus(userSvt, mstData, [options.targetUserSvtId]),
                          jumpToDetail: false,
                        );
                      }
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            runtime.lockTask(() {
                              options.combineUserSvtIds.remove(userSvtId);
                            });
                          });
                        },
                        child: child,
                      );
                    }).toList(),
                  ),
            trailing: IconButton(
              onPressed: () {
                router.pushBuilder(
                  builder: (context) => SelectUserSvtEquipPage(
                    runtime: runtime,
                    inUseUserSvtIds: [options.targetUserSvtId, ...options.combineUserSvtIds],
                    onSelected: (userSvt) {
                      if (userSvt.id == options.targetUserSvtId) return;
                      if (options.combineUserSvtIds.contains(userSvt.id)) return;
                      if (userSvt.isChoice()) {
                        EasyLoading.showInfo('In choice! DO NOT select it');
                        return;
                      }
                      runtime.lockTask(() {
                        options.combineUserSvtIds.add(userSvt.id);
                        if (mounted) setState(() {});
                      });
                    },
                  ),
                );
              },
              icon: Icon(Icons.add),
            ),
          ),
        ],
      ),
      Wrap(
        spacing: 8,
        runSpacing: 6,
        alignment: WrapAlignment.center,
        children: [
          FilledButton(
            onPressed: baseUserSvt == null || options.combineUserSvtIds.isEmpty
                ? null
                : () async {
                    for (final userSvtId in options.combineUserSvtIds) {
                      final userSvt = mstData.userSvt[userSvtId];
                      if (userSvt == null) {
                        EasyLoading.showError('ID $userSvtId not found');
                        return;
                      }
                    }
                    if (options.combineUserSvtIds.any((e) {
                      final _userCe = mstData.userSvt[e];
                      final _ce = _userCe?.dbCE;
                      if ((_userCe?.lv ?? 0) > 1) {
                        if (_ce != null && _ce.flags.contains(SvtFlag.svtEquipChocolate)) {
                          return false;
                        }
                        return true;
                      }
                      return false;
                    })) {
                      final confirm = await const SimpleConfirmDialog(title: Text('Some card Lv>1!'))
                          .showDialog(context);
                      if (confirm != true) return;
                    }
                    runtime.runTask(() async {
                      await runtime.combine.svtEquipCombine(
                        targetUserSvtId: options.targetUserSvtId,
                        combineMaterials: options.combineUserSvtIds,
                      );
                      options.combineUserSvtIds.removeWhere((e) => !mstData.userSvt.containsKey(e));
                      if (mounted) setState(() {});
                    });
                  },
            child: Text('combine'),
          ),
          FilledButton(
            onPressed: options.combineUserSvtIds.any((e) => mstData.userSvt[e]?.isLocked() == true)
                ? () {
                    final unlockIds = options.combineUserSvtIds
                        .where((e) => mstData.userSvt[e]?.isLocked() == true)
                        .toList();
                    if (unlockIds.isEmpty) {
                      EasyLoading.showInfo('None to unlock');
                      return;
                    }
                    runtime.runTask(() {
                      return runtime.agent.cardStatusSync(
                        changeUserSvtIds: [],
                        revokeUserSvtIds: unlockIds,
                        isStorage: false,
                        isLock: true,
                        isChoice: false,
                      );
                    });
                  }
                : null,
            child: Text('Unlock'),
          ),
          FilledButton(
            onPressed: baseUserSvt == null
                ? null
                : () {
                    final materials = runtime.combine.getMaterialSvtEquips(baseUserSvtId: baseUserSvt.id);
                    runtime.lockTask(() {
                      options.combineUserSvtIds = materials.map((e) => e.id).toList();
                    });
                  },
            child: Text('AutoFill'),
          ),
          FilledButton(onPressed: baseUserSvt == null ? null : _autofillChoco, child: Text('AutoFill Choco')),
          // FilledButton(
          //   onPressed: baseUserSvt == null
          //       ? null
          //       : () {
          //           SimpleConfirmDialog(
          //             title: Text('Loop ×${options.loopCount}'),
          //             onTapOk: () {
          //               runtime.runTask(() => runtime.combine.svtCombine());
          //             },
          //           ).showDialog(context);
          //         },
          //   child: Text('Loop ×${options.loopCount}'),
          // ),
        ],
      ),
      const SizedBox(height: 8),
      DividerWithTitle(
        titleWidget: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('批量突破', style: Theme.of(context).textTheme.bodySmall),
            IconButton(
              icon: const Icon(Icons.refresh, size: 18),
              onPressed: runtime.runningTask.value ? null : _resetLimitBreakSelection,
            ),
          ],
        ),
      ),
      FilterGroup<int>(
        options: const [2, 3, 4, 5],
        values: batchLimitBreakRarity,
        enabled: !runtime.runningTask.value,
        optionBuilder: (rarity) => Text('$rarity★'),
        onFilterChanged: (_, _) => setState(() {}),
      ),
      // const Padding(
      //   padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      //   child: Text('高亮边框为本次强化材料；仅使用 Lv.1、未突破副本。强化时自动锁定目标并解锁选中材料。'),
      // ),
      ..._limitBreakRows(),
    ];

    return ListView(padding: EdgeInsets.only(bottom: 72), children: children);
  }

  List<Widget> _limitBreakRows() {
    _syncLimitBreakSelection();
    final groups = runtime.combine
        .getSvtEquipLimitBreakGroups()
        .where((group) => batchLimitBreakRarity.matchOne(group.target.dbCE?.rarity ?? 0))
        .toList();
    if (groups.isEmpty) {
      return [
        const Padding(
          padding: EdgeInsets.all(16),
          child: Center(child: Text('暂无可突破的礼装')),
        ),
      ];
    }
    return [for (final group in groups) _buildLimitBreakRow(group)];
  }

  void _syncLimitBreakSelection() {
    final ids = mstData.userSvt.map((card) => card.id).toList(); // no need sort
    final hash = Object.hashAll(ids);
    if (_limitBreakInventoryHash == hash) return;
    _limitBreakInventoryHash = hash;
    _limitBreakMaterialIds.clear();
  }

  void _resetLimitBreakSelection() {
    setState(() {
      _limitBreakInventoryHash = null;
      _limitBreakMaterialIds.clear();
    });
  }

  Set<int> _selectedLimitBreakIds(SvtEquipLimitBreakGroup group) {
    return _limitBreakMaterialIds.putIfAbsent(
      group.target.svtId,
      () => group.materials.take(group.maxMaterialCount).map((card) => card.id).toSet(),
    );
  }

  Widget _buildLimitBreakRow(SvtEquipLimitBreakGroup group) {
    final selectedIds = _selectedLimitBreakIds(group);
    final selected = group.selectedFrom(selectedIds);
    return Padding(
      key: ValueKey('limit-break-${group.target.svtId}'),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _limitBreakCard(group.target, target: true),
          const Padding(
            padding: EdgeInsets.only(top: 24, left: 2, right: 2),
            child: Icon(Icons.chevron_right, size: 16),
          ),
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (var index = 0; index < group.copies.length; index++)
                    _limitBreakCard(
                      group.copies[index],
                      selected: selectedIds.contains(group.copies[index].id),
                      isMaterial: group.isMaterial(group.copies[index]),
                      onTap: group.isMaterial(group.copies[index])
                          ? () => _toggleLimitBreakMaterial(group, group.copies[index].id)
                          : () {},
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              buildCompactButton(
                enabled: !runtime.runningTask.value,
                onPressed: selected.isEmpty ? null : () => _enhanceLimitBreak(group, selectedIds),
                text: S.current.enhance,
              ),
              const SizedBox(height: 4),
              Text(
                '${selected.length}/${group.maxMaterialCount}\n可用 ${group.materials.length}\n总 ${group.totalCount}',
                style: Theme.of(context).textTheme.labelSmall,
                textAlign: .center,
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _toggleLimitBreakMaterial(SvtEquipLimitBreakGroup group, int id) {
    setState(() {
      final ids = _selectedLimitBreakIds(group);
      if (ids.contains(id)) {
        ids.remove(id);
      } else if (ids.length < group.maxMaterialCount) {
        ids.add(id);
      }
    });
  }

  Widget _limitBreakCard(
    UserServantEntity card, {
    bool target = false,
    bool selected = false,
    bool isMaterial = false,
    VoidCallback? onTap,
  }) {
    final ce = card.dbCE;
    final colors = Theme.of(context).colorScheme;
    final notSelectable = !target && !isMaterial;
    Widget child = SizedBox(
      width: 60,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 2),
            padding: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              border: Border.all(color: selected ? colors.primary : Colors.transparent, width: 2),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Opacity(
              opacity: notSelectable ? 0.55 : 1,
              child:
                  ce?.iconBuilder(context: context, width: 48, jumpToDetail: onTap == null) ??
                  const Icon(Icons.image_not_supported),
            ),
          ),
          Text(
            '${card.isLocked() ? "🔐" : ""}Lv.${card.lv}\n${card.limitCount}/4${card.isChoice() ? " ✴️" : ""}',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.labelSmall,
          ),
          Text(
            card.createdAt
                .sec2date()
                .toStringShort(omitSec: true)
                .replaceFirstMapped(RegExp(r'^20\d\d'), (repl) => repl.group(0)!.substring(2)),
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.labelSmall,
          ),
          if (target || notSelectable)
            Text(target ? S.current.target : '不可选', style: Theme.of(context).textTheme.labelSmall),
        ],
      ),
    );
    if (onTap != null) {
      child = GestureDetector(onTap: onTap, child: child);
    }
    return child;
  }

  Future<void> _enhanceLimitBreak(SvtEquipLimitBreakGroup group, Set<int> selectedIds) async {
    final lockedMaterials = group.selectedFrom(selectedIds).where((card) => card.isLocked()).toList();
    if (lockedMaterials.isNotEmpty) {
      final confirmed = await SimpleConfirmDialog(
        title: const Text('将解锁材料'),
        content: Text('将先解锁 ${lockedMaterials.length} 张选中材料，再进行强化。'),
      ).showDialog(context);
      if (confirmed != true) return;
      if (!mounted) return;
    }
    await runtime.runTask(() async {
      try {
        await runtime.combine.svtEquipLimitBreak(preview: group, materialIds: selectedIds);
      } finally {
        options.combineUserSvtIds.removeWhere((id) => !mstData.userSvt.containsKey(id));
        if (!mstData.userSvt.containsKey(options.targetUserSvtId)) options.targetUserSvtId = 0;
        _limitBreakMaterialIds.clear();
        _limitBreakInventoryHash = null;
        if (mounted) setState(() {});
      }
    });
  }

  Widget get buttonBar {
    List<List<Widget>> btnGroups = [
      [
        runtime.buildCircularProgress(context: context, padding: EdgeInsets.symmetric(horizontal: 8)),
        buildCompactButton(
          onPressed: () {
            agent.network.stopFlag = true;
          },
          text: 'Stop',
        ),
      ],
    ];
    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (final btns in btnGroups)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              child: Wrap(
                alignment: WrapAlignment.center,
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 4,
                runSpacing: 2,
                children: btns,
              ),
            ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  bool checkSvtLvExceed(int userSvtId) {
    final baseUserSvt = mstData.userSvt[userSvtId];
    final ce = baseUserSvt?.dbCE;
    if (baseUserSvt == null || ce == null) return false;
    if (baseUserSvt.lv != baseUserSvt.maxLv) return false;
    return true;
  }

  void _autofillChoco() {
    const int kMaxMaterialCount = 5;
    options.combineUserSvtIds.clear();
    for (final userSvt in mstData.userSvt) {
      if (options.combineUserSvtIds.length >= kMaxMaterialCount) continue;
      if (userSvt.isChoice() || userSvt.isWithdraw()) continue;
      final ce = userSvt.dbCE;
      if (ce == null || ce.collectionNo <= 0 || !ce.flags.contains(SvtFlag.svtEquipChocolate)) continue;
      final owner = db.gameData.servantsById[ce.valentineEquipOwner];
      if (owner == null || owner.type == .heroine) continue;
      options.combineUserSvtIds.add(userSvt.id);
    }
    if (mounted) setState(() {});
  }
}
