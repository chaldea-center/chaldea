import 'package:flutter_easyloading/flutter_easyloading.dart';

import 'package:chaldea/app/app.dart';
import 'package:chaldea/models/models.dart';
import 'package:chaldea/packages/packages.dart';
import 'package:chaldea/utils/utils.dart';
import 'package:chaldea/widgets/widgets.dart';
import '../../modules/battle/formation/formation_card.dart';
import '../_shared/svt_equip_select.dart';
import '../runtime.dart';

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
              '[${agent.user.serverName}] ${userGame?.name}   QP ${userGame?.qp.format(compact: false, groupSeparator: ",")}'
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
                        onTap: ce?.routeTo,
                        onLongPress: () {
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
        alignment: WrapAlignment.center,
        children: [
          FilledButton(
            onPressed: baseUserSvt == null || options.combineUserSvtIds.isEmpty
                ? null
                : () {
                    for (final userSvtId in options.combineUserSvtIds) {
                      final userSvt = mstData.userSvt[userSvtId];
                      if (userSvt == null) {
                        EasyLoading.showError('ID $userSvtId not found');
                        return;
                      }
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
    ];

    return ListView(padding: EdgeInsets.only(bottom: 72), children: children);
  }

  Widget get buttonBar {
    final buttonStyle = FilledButton.styleFrom(
      minimumSize: const Size(64, 32),
      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      padding: const EdgeInsets.symmetric(horizontal: 12),
    );

    FilledButton buildButton({bool enabled = true, required VoidCallback onPressed, required String text}) {
      return FilledButton.tonal(onPressed: enabled ? onPressed : null, style: buttonStyle, child: Text(text));
    }

    List<List<Widget>> btnGroups = [
      [
        runtime.buildCircularProgress(context: context, padding: EdgeInsets.symmetric(horizontal: 8)),

        buildButton(
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
}
