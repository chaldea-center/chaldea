import 'package:auto_size_text/auto_size_text.dart';

import 'package:chaldea/app/app.dart';
import 'package:chaldea/app/modules/common/filter_group.dart';
import 'package:chaldea/app/modules/common/misc.dart';
import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/models/gamedata/mst_data.dart';
import 'package:chaldea/models/models.dart';
import 'package:chaldea/packages/logger.dart';
import 'package:chaldea/utils/utils.dart';
import 'package:chaldea/widgets/widgets.dart';

import '../../modules/battle/formation/formation_card.dart';
import '../_shared/select_svt.dart';
import '../runtime.dart';

class SvtCombinePage extends StatefulWidget {
  final FakerRuntime runtime;
  const SvtCombinePage({super.key, required this.runtime});

  @override
  State<SvtCombinePage> createState() => _SvtCombinePageState();
}

class _SvtCombinePageState extends State<SvtCombinePage> with FakerRuntimeStateMixin {
  @override
  late final runtime = widget.runtime;
  late final user = agent.user;
  late final options = user.svtCombine;

  final _selection = _SvtCombineSelection();

  List<UserServantEntity> get _npMaterials {
    _selection.materialUserSvtIds.removeWhere((id) => mstData.userSvt[id] == null);
    return _selection.materialUserSvtIds.map((id) => mstData.userSvt[id]).whereType<UserServantEntity>().toList();
  }

  @override
  Widget build(BuildContext context) {
    final baseUserSvt = mstData.userSvt[options.baseUserSvtId];
    return Scaffold(
      appBar: AppBar(
        title: Text('从者强化'),
        leading: BackButton(
          onPressed: () async {
            if (runtime.runningTask.value) {
              final confirm = await const SimpleConfirmDialog(title: Text("Exit?")).showDialog(context);
              if (confirm == true && context.mounted) Navigator.pop(context);
            } else {
              Navigator.pop(context);
            }
          },
        ),
        actions: [
          IconButton(
            onPressed: selectBaseUserSvt,
            icon:
                baseUserSvt?.dbSvt?.iconBuilder(
                  context: context,
                  jumpToDetail: false,
                  overrideIcon: baseUserSvt.icon,
                ) ??
                Icon(Icons.change_circle),
          ),
          runtime.buildHistoryButton(context),
          runtime.buildMenuButton(context),
        ],
      ),
      body: PopScope(
        canPop: !runtime.runningTask.value,
        child: ListTileTheme.merge(
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
      ),
    );
  }

  Widget get headerInfo {
    final baseUserSvt = mstData.userSvt[options.baseUserSvtId];
    final collection = mstData.userSvtCollection[baseUserSvt?.svtId];
    final svt = baseUserSvt?.dbSvt;
    final expData = svt?.getCurLvExpData(baseUserSvt?.lv ?? 0, baseUserSvt?.exp ?? 0);
    final bondData = svt?.getCurLvBondData(collection?.friendshipRank ?? 0, collection?.friendship ?? 0);

    final userGame = mstData.user ?? agent.user.userGame;
    return Container(
      color: Theme.of(context).secondaryHeaderColor,
      padding: const EdgeInsets.only(bottom: 4),
      child: ListTile(
        dense: true,
        minTileHeight: 48,
        visualDensity: VisualDensity.compact,
        minLeadingWidth: 20,
        leading:
            svt?.iconBuilder(context: context, overrideIcon: baseUserSvt?.icon) ??
            db.getIconImage(Atlas.common.emptySvtIcon),
        subtitle: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '[${agent.user.serverName}] ${userGame?.displayName}   QP ${userGame?.qp.format(compact: false, groupSeparator: ",")}',
            ),
            if (baseUserSvt != null) ...[
              Text(
                '${baseUserSvt.isLocked() ? "🔐 " : ""}Lv.${baseUserSvt.lv}/${baseUserSvt.maxLv}'
                ' limit ${[baseUserSvt.limitCount, if (baseUserSvt.exceedCount > 0) baseUserSvt.exceedCount].join("+")}'
                ' NP${baseUserSvt.treasureDeviceLv1} exp next ${expData?.next.formatSep()}',
              ),
              if (expData != null) BondProgress(value: expData.elapsed, total: expData.total),
              Text(
                'bond ${collection?.friendshipRank}/${collection?.maxFriendshipRank}  next ${bondData?.next.formatSep()}',
              ),
              if (bondData != null) BondProgress(value: bondData.elapsed, total: bondData.total),
              Text(
                'skill ${baseUserSvt.skillLv1}/${baseUserSvt.skillLv2}/${baseUserSvt.skillLv3} '
                ' append ${mstData.getSvtAppendSkillLvs(baseUserSvt).join("/")}',
              ),
            ],
            //
          ],
        ),
      ),
    );
  }

  Widget get body {
    final baseUserSvt = mstData.userSvt[options.baseUserSvtId];
    final collection = mstData.userSvtCollection[baseUserSvt?.svtId];
    final svt = baseUserSvt?.dbSvt;
    Map<int, int> materialCounts = {};
    for (final userSvt in mstData.userSvt) {
      final materialSvt = userSvt.dbEntity;
      if (userSvt.isLocked() || materialSvt == null) continue;
      if (materialSvt.type == SvtType.combineMaterial) {
        materialCounts.addNum(materialSvt.id, 1);
      } else if (materialSvt.type == SvtType.statusUp) {
        if (materialSvt.classId == SvtClass.ALL.value || materialSvt.classId == svt?.classId) {
          materialCounts.addNum(materialSvt.id, 1);
        }
      }
    }
    materialCounts = Item.sortMapByPriority(materialCounts, removeZero: false, reversed: false);
    List<Widget> children = [
      ListTile(
        dense: true,
        title: Text(baseUserSvt == null ? '🔐 isLock' : '🔐 isLock = ${baseUserSvt.isLocked()}'),
        trailing: IconButton(
          onPressed: baseUserSvt == null
              ? null
              : () async {
                  final userSvt =
                      mstData.userSvt[options.baseUserSvtId] ?? mstData.userSvtStorage[options.baseUserSvtId];
                  if (userSvt == null) return;
                  if (userSvt.isLocked()) {
                    final confirm = await SimpleConfirmDialog(
                      title: const Text('解锁从者'),
                      content: Text('确定解锁 ${userSvt.dbSvt?.lName.l ?? "#${userSvt.svtId}"}？'),
                    ).showDialog(context);
                    if (!mounted || confirm != true) return;
                  }
                  await runtime.runTask(
                    () => runtime.agent.cardStatusSync(
                      changeUserSvtIds: userSvt.isLocked() ? [] : [userSvt.id],
                      revokeUserSvtIds: userSvt.isLocked() ? [userSvt.id] : [],
                      isStorage: mstData.userSvtStorage.containsKey(options.baseUserSvtId),
                      isLock: true,
                      isChoice: false,
                    ),
                  );
                },
          icon: const Icon(Icons.change_circle_outlined),
        ),
      ),
      DividerWithTitle(title: S.current.enhance),
      FilterGroup<int>(
        title: Text(S.current.rarity),
        options: const [1, 2, 3, 4, 5],
        values: FilterGroupData(options: options.svtMaterialRarities),
        onFilterChanged: (v, _) async {
          runtime.lockTask(() => options.svtMaterialRarities = v.options);
          if (mounted) setState(() {});
        },
      ),
      ListTile(
        dense: true,
        title: Text('Max Material Count'),
        trailing: TextButton(
          onPressed: () {
            InputCancelOkDialog.number(
              title: 'Max Material Count',
              initValue: options.maxMaterialCount,
              validate: (v) => v > 0 && v <= 20,
              onSubmit: (v) {
                runtime.lockTask(() => options.maxMaterialCount = v);
              },
            ).showDialog(context);
          },
          child: Text(options.maxMaterialCount.toString()),
        ),
      ),
      SwitchListTile.adaptive(
        dense: true,
        title: Text('Double EXP'),
        value: options.doubleExp,
        onChanged: (v) {
          runtime.lockTask(() => options.doubleExp = v);
        },
      ),

      Padding(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        child: Wrap(
          spacing: 1,
          runSpacing: 1,
          children: [
            for (final (itemId, count) in materialCounts.items)
              ?db.gameData.entities[itemId]?.iconBuilder(
                context: context,
                text: count.format(),
                height: 36 * 144 / 132,
                width: 36,
                option: ImageWithTextOption(padding: const EdgeInsets.only(bottom: 10, left: 2, right: 2)),
              ),
          ],
        ),
      ),

      if (baseUserSvt != null)
        ListTile(
          title: Text('${S.current.foukun} 3'),
          subtitle: Text('HP+${baseUserSvt.adjustHp * 10}  ATK+${baseUserSvt.adjustAtk * 10}'),
          trailing: TextButton(
            onPressed: baseUserSvt.adjustHp < 100 || baseUserSvt.adjustAtk < 100
                ? () {
                    if (runtime.runningTask.value) return;
                    runtime.runTask(runtime.combine.svtStatusUp);
                  }
                : null,
            child: Text(S.current.enhance),
          ),
        ),
      ListTile(
        dense: true,
        title: Text('Loop Count'),
        trailing: TextButton(
          onPressed: () {
            InputCancelOkDialog.number(
              title: 'Loop Count',
              initValue: options.loopCount,
              validate: (v) => v >= 0,
              onSubmit: (v) {
                runtime.lockTask(() => options.loopCount = v);
              },
            ).showDialog(context);
          },
          child: Text(options.loopCount.toString()),
        ),
      ),
      Wrap(
        spacing: 8,
        alignment: WrapAlignment.center,
        children: [
          FilledButton(
            onPressed: baseUserSvt == null || baseUserSvt.lv >= (baseUserSvt.maxLv ?? 9999)
                ? null
                : () {
                    if (runtime.runningTask.value) return;
                    runtime.runTask(() async {
                      await runtime.combine.svtCombine(loopCount: 1);
                      if (mounted) setState(() {});
                    });
                  },
            child: Text('combine'),
          ),
          FilledButton(
            onPressed: baseUserSvt == null
                ? null
                : () {
                    SimpleConfirmDialog(
                      title: Text('Loop ×${options.loopCount}'),
                      onTapOk: () {
                        runtime.runTask(() => runtime.combine.svtCombine());
                      },
                    ).showDialog(context);
                  },
            child: Text('Loop ×${options.loopCount}'),
          ),
        ],
      ),
    ];
    if (baseUserSvt != null && svt != null) {
      Widget _item(int itemId, int requiredNum) {
        return Item.iconBuilder(
          context: context,
          item: null,
          itemId: itemId,
          text: [requiredNum, mstData.getItemOrSvtNum(itemId)].map((e) => e.format()).join('\n'),
          width: 36,
        );
      }

      final ascensionMats = svt.ascensionMaterials[baseUserSvt.limitCount];
      final Map<int, int> limitCombineItems = {
        if (ascensionMats != null)
          for (final item in ascensionMats.items) item.itemId: item.amount,
        if (ascensionMats != null) Items.qpId: ascensionMats.qp,
      };
      String combineTitle = '灵基再临 ';
      combineTitle += [baseUserSvt.limitCount, if (limitCombineItems.isNotEmpty) baseUserSvt.limitCount + 1].join('→');
      children.addAll([
        DividerWithTitle(title: '突破'),
        ListTile(
          title: Text(combineTitle),
          subtitle: Wrap(
            spacing: 2,
            children: [for (final (itemId, amount) in limitCombineItems.items) _item(itemId, amount)],
          ),
          trailing: FilledButton(
            onPressed: baseUserSvt.exceedCount == 0 && baseUserSvt.lv == baseUserSvt.maxLv && baseUserSvt.limitCount < 4
                ? () {
                    SimpleConfirmDialog(
                      title: Text(S.current.ascension_up),
                      onTapOk: () {
                        runtime.runTask(() {
                          for (final (itemId, amount) in limitCombineItems.items) {
                            if (mstData.getItemOrSvtNum(itemId) < amount) {
                              throw SilentException('Item not enough: ${Item.getName(itemId)}');
                            }
                          }
                          return runtime.agent.servantLimitCombine(baseUserSvtId: baseUserSvt.id);
                        });
                      },
                    ).showDialog(context);
                  }
                : null,
            child: Text('灵基再临'),
          ),
        ),
        ListTile(
          title: Text('圣杯转临'),
          subtitle: Wrap(
            spacing: 2,
            children: [
              _item(Items.grailId, 1),
              if (baseUserSvt.lv >= 100 && svt.coin != null) _item(svt.coin!.item.id, 30),
            ],
          ),
          trailing: FilledButton(
            onPressed: checkSvtLvExceed(baseUserSvt.id)
                ? () {
                    final grailNum = mstData.getItemOrSvtNum(Items.grailId),
                        coinNum = mstData.userSvtCoin[baseUserSvt.svtId]?.num ?? 0;
                    SimpleConfirmDialog(
                      title: Text('圣杯转临'),
                      content: Text(
                        [
                          'Grail $grailNum-1=${grailNum - 1}',
                          if (baseUserSvt.lv >= 100) 'coin $coinNum-30=${coinNum - 30}',
                        ].join(', '),
                      ),
                      onTapOk: () {
                        runtime.runTask(() {
                          if (grailNum < 1) {
                            throw SilentException('Grail not enough');
                          }
                          if (baseUserSvt.lv >= 100 && coinNum < 30) {
                            throw SilentException('Svt Coin not enough');
                          }
                          return runtime.agent.servantLevelExceed(baseUserSvtId: baseUserSvt.id);
                        });
                      },
                    ).showDialog(context);
                  }
                : null,
            child: Text('圣杯转临'),
          ),
        ),
        ListTile(
          title: Text('羁绊等级上限提升'),
          subtitle: Wrap(children: [_item(Items.lanternId, 1)]),
          trailing: FilledButton(
            onPressed:
                collection != null &&
                    collection.friendshipRank < kBondLvMax &&
                    collection.friendshipRank == collection.maxFriendshipRank
                ? () {
                    if (collection.friendshipRank >= kNormalLanternBondLvMax) {
                      SimpleConfirmDialog(
                        title: Text('Bond Lv ${collection.friendshipRank}>=$kNormalLanternBondLvMax'),
                        content: Text('Unlock bond limit in game!'),
                      ).showDialog(context);
                      return;
                    }
                    final lanternNum = mstData.getItemOrSvtNum(Items.lanternId);
                    SimpleConfirmDialog(
                      title: Text('羁绊等级上限提升'),
                      content: Text('${Items.lantern?.lName.l} $lanternNum-1'),
                      onTapOk: () {
                        runtime.runTask(() {
                          if (lanternNum < 1) {
                            throw SilentException('${Items.lantern?.lName.l} not enough');
                          }
                          return runtime.agent.servantFriendshipExceed(baseUserSvtId: baseUserSvt.id);
                        });
                      },
                    ).showDialog(context);
                  }
                : null,
            child: Text('解放'),
          ),
        ),
      ]);

      //append skill
      children.addAll([
        DividerWithTitle(title: S.current.append_skill),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(width: 16),
            ...kAppendSkillNums.map((skillNum) {
              final skillNum2 = skillNum + 100 - 1;
              final skill = svt.appendPassive.firstWhereOrNull((e) => e.num == skillNum2);
              if (skill == null) {
                return Expanded(child: Text('${S.current.append_skill_short} $skillNum'));
              }
              final curLv = mstData.getSvtAppendSkillLv(baseUserSvt, skillNum2);
              final appendMats = <int, int>{};
              if (curLv == 0) {
                for (final amount in skill.unlockMaterials) {
                  appendMats[amount.itemId] = amount.amount;
                }
              } else if (svt.appendSkillMaterials.containsKey(curLv)) {
                final lvMats = svt.appendSkillMaterials[curLv]!;
                appendMats[Items.qpId] = lvMats.qp;
                for (final amount in lvMats.items) {
                  appendMats[amount.itemId] = amount.amount;
                }
              }
              final bool isLacking = appendMats.entries.any((e) => mstData.getItemOrSvtNum(e.key) < e.value);
              final combineDisabled = isLacking || curLv == 10;
              return Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    InkWell(
                      onTap: combineDisabled
                          ? null
                          : () async {
                              if (runtime.runningTask.value) return;
                              if (curLv == 0 || curLv == 9) {
                                final confirm = await SimpleConfirmDialog(
                                  title: Text('${S.current.warning}: ${S.current.append_skill_short} $skillNum'),
                                  content: Text(
                                    [
                                      if (curLv == 0) S.current.unlock,
                                      if (curLv == 9) Items.crystal?.lName.l,
                                      '\n\n\n',
                                      'Sure?',
                                    ].join('\n'),
                                    style: TextStyle(color: Theme.of(context).colorScheme.error),
                                  ),
                                ).showDialog(context);
                                if (!mounted || confirm != true) return;
                              }
                              final confirm = await SimpleConfirmDialog(
                                title: Text('${S.current.append_skill_short} $skillNum'),
                                content: Text('Lv.$curLv → Lv.${curLv + 1}'),
                              ).showDialog(context);
                              if (!mounted || confirm != true) return;

                              if (mstData.getSvtAppendSkillLv(baseUserSvt, skillNum2) != curLv) {
                                return;
                              }

                              await runtime.runTask(
                                () => runtime.agent.appendSkillCombine(
                                  baseUsrSvtId: baseUserSvt.id,
                                  skillNum: skillNum2,
                                  currentSkillLv: curLv,
                                ),
                              );
                            },
                      onLongPress: () {
                        if (combineDisabled) return;
                        final startLv = mstData.getSvtAppendSkillLv(baseUserSvt, skillNum2);
                        if (startLv <= 0) return;
                        _SkillCombineMultiLevelDialog(
                          title: Text(
                            '${S.current.append_skill_short} $skillNum - ${skill.skill.dispName}',
                            maxLines: 1,
                            overflow: .ellipsis,
                          ),
                          runtime: runtime,
                          skillMaterials: svt.appendSkillMaterials,
                          getCurLv: () => mstData.getSvtAppendSkillLv(baseUserSvt, skillNum2),
                          maxLevel: 9,
                          callCombine: (curLv) => runtime.agent.appendSkillCombine(
                            baseUsrSvtId: baseUserSvt.id,
                            skillNum: skillNum2,
                            currentSkillLv: curLv,
                          ),
                        ).showDialog(context);
                      },
                      child: Opacity(
                        opacity: combineDisabled ? 0.5 : 1,
                        child: ImageWithText(
                          image: db.getIconImage(skill.skill.icon, width: 48, height: 48),
                          text: 'Lv.$curLv',
                        ),
                      ),
                    ),
                    Wrap(
                      alignment: WrapAlignment.center,
                      children: [
                        for (final (itemId, itemNum) in appendMats.items)
                          Item.iconBuilder(
                            context: context,
                            item: null,
                            itemId: itemId,
                            width: 28,
                            text: [itemNum, mstData.getItemOrSvtNum(itemId)].map((e) => e.format()).join('\n'),
                          ),
                      ],
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ]);

      // active skill
      children.addAll([
        DividerWithTitle(title: S.current.active_skill),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(width: 16),
            ...kActiveSkillNums.map((skillNum) {
              final skills = svt.groupedActiveSkills[skillNum]?.toList() ?? [];
              skills.retainWhere((skill) {
                if (collection == null) return false;
                if (baseUserSvt.lv < skill.condLv) return false;
                if (baseUserSvt.limitCount < skill.condLimitCount) return false;
                if (skill.condQuestId > 0 && !mstData.isQuestClear(skill.condQuestId)) return false;
                return true;
              });
              skills.sort2((e) => e.svt.priority);
              final skill = skills.lastOrNull;
              if (skill == null || svt.type == SvtType.heroine) {
                return Expanded(child: Text('${S.current.active_skill_short} $skillNum'));
              }
              final curLv = baseUserSvt.skillLvs[skillNum - 1];
              final activeMats = <int, int>{};
              if (svt.skillMaterials.containsKey(curLv)) {
                final lvMats = svt.skillMaterials[curLv]!;
                activeMats[Items.qpId] = lvMats.qp;
                for (final amount in lvMats.items) {
                  activeMats[amount.itemId] = amount.amount;
                }
              }
              final bool isLacking = activeMats.entries.any((e) => mstData.getItemOrSvtNum(e.key) < e.value);
              final combineDisabled = isLacking || curLv == 10;
              return Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    InkWell(
                      onTap: combineDisabled
                          ? null
                          : () async {
                              if (runtime.runningTask.value) return;
                              if (curLv == 9) {
                                final confirm = await SimpleConfirmDialog(
                                  title: Text('${S.current.warning}: ${S.current.active_skill_short} $skillNum'),
                                  content: Text(
                                    [Items.crystal?.lName.l, '\n\n\n', 'Sure?'].join('\n'),
                                    style: TextStyle(color: Theme.of(context).colorScheme.error),
                                  ),
                                ).showDialog(context);
                                if (!mounted || confirm != true) return;
                              }
                              final confirm = await SimpleConfirmDialog(
                                title: Text('${S.current.active_skill_short} $skillNum'),
                                content: Text('Lv.$curLv → Lv.${curLv + 1}'),
                              ).showDialog(context);
                              if (!mounted || confirm != true) return;

                              await runtime.runTask(
                                () => runtime.agent.servantSkillCombine(
                                  baseUsrSvtId: baseUserSvt.id,
                                  selectSkillIndex: skillNum,
                                  selectSkillId: skill.id,
                                ),
                              );
                            },
                      onLongPress: () {
                        if (combineDisabled) return;
                        final userSvt = mstData.userSvt[options.baseUserSvtId];
                        final startLv = userSvt?.skillLvs[skillNum - 1];
                        if (startLv == null || startLv <= 0) return;
                        _SkillCombineMultiLevelDialog(
                          title: Text(
                            '${S.current.active_skill_short} $skillNum - ${skill.dispName}',
                            maxLines: 1,
                            overflow: .ellipsis,
                          ),
                          runtime: runtime,
                          skillMaterials: svt.skillMaterials,
                          getCurLv: () => mstData.userSvt[options.baseUserSvtId]?.skillLvs[skillNum - 1],
                          maxLevel: 9,
                          callCombine: (curLv) => runtime.agent.servantSkillCombine(
                            baseUsrSvtId: baseUserSvt.id,
                            selectSkillIndex: skillNum,
                            selectSkillId: skill.id,
                          ),
                        ).showDialog(context);
                      },
                      child: Opacity(
                        opacity: combineDisabled ? 0.5 : 1,
                        child: ImageWithText(
                          image: db.getIconImage(skill.icon, width: 48, height: 48),
                          text: 'Lv.$curLv',
                        ),
                      ),
                    ),
                    Wrap(
                      alignment: WrapAlignment.center,
                      children: [
                        for (final (itemId, itemNum) in activeMats.items)
                          Item.iconBuilder(
                            context: context,
                            item: null,
                            itemId: itemId,
                            width: 28,
                            text: [itemNum, mstData.getItemOrSvtNum(itemId)].map((e) => e.format()).join('\n'),
                          ),
                      ],
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ]);

      // NP upgrade: consumes same servant dupes; target lv = base lv + sum of material NP lvs
      final tdCandidates = svt.noblePhantasms.where((td) => td.num == 1).toList();
      final availableTds = tdCandidates.where((td) => _isTdAvailable(td, baseUserSvt, collection)).toList();
      if (availableTds.isNotEmpty && svt.type == SvtType.normal) {
        final npTd =
            availableTds.firstWhereOrNull((td) => td.id == _selection.treasureDeviceId) ??
            availableTds.reduce((a, b) => b.priority > a.priority ? b : a);
        _selection.treasureDeviceId = npTd.id;
        final npLv = baseUserSvt.treasureDeviceLv1;
        final npMaterials = _npMaterials;
        final gainLv = npMaterials.fold<int>(0, (sum, e) => sum + e.treasureDeviceLv1);
        final targetLv = npLv + gainLv > 5 ? 5 : npLv + gainLv;
        final qpCost = _npCombineQp(svt.rarity, npLv, targetLv);
        final userGame = mstData.user ?? agent.user.userGame;
        final qpEnough = (userGame?.qp ?? 0) >= qpCost;
        final lockedCount = npMaterials.where((e) => e.isLocked()).length;
        children.addAll([
          DividerWithTitle(title: S.current.noble_phantasm_level),
          AddRemoveList<UserServantEntity>(
            leading: CommandCardWidget(card: npTd.card, width: 42),
            title: Text.rich(
              TextSpan(
                children: [
                  TextSpan(text: 'Lv. $npLv/5'),
                  if (npMaterials.isNotEmpty) ...[
                    const TextSpan(text: ' → '),
                    TextSpan(
                      text: 'Lv. $targetLv/5',
                      style: targetLv > 5
                          ? TextStyle(color: Theme.of(context).colorScheme.error, fontWeight: FontWeight.bold)
                          : null,
                    ),
                  ],
                ],
              ),
            ),
            subtitle: npMaterials.isEmpty ? null : 'QP ${qpCost.formatSep()}${qpEnough ? "" : "（不足）"}',
            items: npMaterials,
            onAdd: npLv >= 5 ? null : _selectNpMaterials,
            onRemove: (e) => setState(() => _selection.materialUserSvtIds.remove(e.id)),
            itemBuilder: (context, item, onRemove) => InkWell(
              onLongPress: onRemove,
              child:
                  item.dbSvt?.iconBuilder(
                    context: context,
                    overrideIcon: item.icon,
                    text: '${item.isLocked() ? "🔐" : ""}Lv${item.lv}\nNP${item.treasureDeviceLv1}',
                    width: 42,
                    option: ImageWithTextOption(fontSize: 10),
                  ) ??
                  Text('#${item.svtId}'),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              alignment: WrapAlignment.center,
              children: [
                for (final td in tdCandidates)
                  _buildTdButton(td, selected: td.id == npTd.id, enabled: availableTds.contains(td)),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Center(
              child: Wrap(
                spacing: 8,
                alignment: WrapAlignment.center,
                children: [
                  TextButton(
                    onPressed: lockedCount == 0 ? null : _unlockNpMaterials,
                    child: Text('${S.current.unlock} ($lockedCount)'),
                  ),
                  FilledButton(
                    onPressed: npMaterials.isEmpty || npLv >= 5 || !qpEnough || lockedCount > 0
                        ? null
                        : () => _npCombine(npTd, npMaterials, targetLv, qpCost),
                    child: Text(S.current.enhance),
                  ),
                ],
              ),
            ),
          ),
        ]);
      }

      // command code
      final userSvtCmdCode = mstData.userSvtCommandCode[baseUserSvt.svtId];
      children.addAll([
        DividerWithTitle(title: '${S.current.command_code} ${S.current.unlock}'),
        Wrap(
          alignment: .center,
          crossAxisAlignment: .center,
          children: [
            ...svt.cards.indexed.map((item) {
              final (index, cardType) = item;
              final userCCId = userSvtCmdCode?.userCommandCodeIds.getOrNull(index) ?? -1;
              final keyNum = mstData.userItem[_getCommandCodeUnlockKey(cardType)]?.num ?? 0;
              Widget cardWidget = ImageWithText(
                image: Opacity(opacity: 0.8, child: CommandCardWidget(card: cardType, width: 42)),
                text: keyNum.toString(),
                option: ImageWithTextOption(fontSize: 12),
              );
              Widget? btn;
              if (userCCId == -1) {
                btn = InkWell(
                  child: Icon(Icons.lock, color: Theme.of(context).colorScheme.surfaceTint),
                  onTap: () {
                    runtime.runTask(() => unlockIndex(svt.id, [index]));
                  },
                );
              } else if (userCCId == 0) {
                btn = Icon(Icons.lock_open, color: Theme.of(context).disabledColor);
              } else if (userCCId > 0) {
                final cc = db.gameData.commandCodesById[mstData.userCommandCode[userCCId]?.commandCodeId];
                btn = cc?.iconBuilder(context: context) ?? Text(userCCId.toString());
              }

              return Column(
                mainAxisSize: .min,
                spacing: 2,
                children: [
                  cardWidget,
                  SizedBox.square(dimension: 36, child: Center(child: btn ?? const SizedBox.shrink())),
                ],
              );
            }),
            const SizedBox(width: 8),
            IconButton(
              onPressed: userSvtCmdCode?.userCommandCodeIds.every((e) => e >= 0) == true
                  ? null
                  : () {
                      SimpleConfirmDialog(
                        title: Text('Unlock All'),
                        onTapOk: () {
                          runtime.runTask(() => unlockIndex(svt.id, List.generate(svt.cards.length, (i) => i)));
                        },
                      ).showDialog(context);
                    },
              icon: Icon(Icons.done_all),
            ),
          ],
        ),
      ]);

      // dispLimitCount
      final validDispLimitCounts = <int>{
        for (int limit = 0; limit <= baseUserSvt.limitCount; limit++) Servant.limitCountToDispLimitCount(limit),
        ...?collection?.costumeIds.where((id) {
          if (id <= 0) return false;
          final collectionNo = svt.costume.values.firstWhereOrNull((e) => e.id == id)?.costumeCollectionNo;
          return collectionNo != null && collectionNo > 0;
        }),
        baseUserSvt.dispLimitCount,
      }.toList()..sort();
      children.addAll([
        DividerWithTitle(title: '${S.current.ascension_stage} (battle model)'),
        ListTile(
          dense: true,
          leading: db.getIconImage(svt.ascendIcon(Servant.dispLimitCountToMinLimitCount(baseUserSvt.dispLimitCount))),
          title: Text('${S.current.current_}: ${S.current.ascension_stage} ${baseUserSvt.dispLimitCount}'),
          subtitle: Text(validDispLimitCounts.join(' / ')),
        ),
        DropdownButton<int>(
          isExpanded: true,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          value: baseUserSvt.dispLimitCount,
          items: [
            for (final dispLimitCount in validDispLimitCounts)
              DropdownMenuItem(
                value: dispLimitCount,
                child: Text.rich(
                  TextSpan(
                    children: [
                      CenterWidgetSpan(
                        child: db.getIconImage(
                          svt.ascendIcon(Servant.dispLimitCountToMinLimitCount(dispLimitCount)),
                          width: 32,
                        ),
                      ),
                      TextSpan(
                        text: dispLimitCount < 10
                            ? '${S.current.ascension_stage} $dispLimitCount'
                            : svt.getLimitName(dispLimitCount),
                      ),
                    ],
                  ),
                  textScaler: const TextScaler.linear(0.8),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
          ],
          onChanged: (dispLimit) async {
            if (dispLimit == null) return;
            print('chose dispLimit $dispLimit');
            await runtime.runTask(() {
              return runtime.agent.cardFavoriteWith(targetUsrSvtId: baseUserSvt.id, dispLimitCount: dispLimit);
            });
          },
        ),
      ]);
    }
    return ListView(padding: EdgeInsets.only(bottom: 72), children: children);
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

  void selectBaseUserSvt() {
    router.pushBuilder(
      builder: (context) => SelectUserSvtPage(
        runtime: runtime,
        onSelected: (userSvt) {
          runtime.lockTask(() {
            options.baseUserSvtId = userSvt.id;
            _selection.clear();
            if (mounted) setState(() {});
          });
        },
      ),
    );
  }

  bool _isTdAvailable(NiceTd td, UserServantEntity baseUserSvt, UserServantCollectionEntity? collection) {
    if (td.num != 1) return false;
    if (td.condQuestId > 0 && !mstData.isQuestPhaseClear(td.condQuestId, td.condQuestPhase)) return false;
    if (baseUserSvt.lv < td.condLv) return false;
    if ((collection?.friendshipRank ?? 0) < td.condFriendshipRank) return false;
    return SvtSkillRelease.check(
          td.releaseConditions,
          (cond) => switch (cond.condType) {
            CondType.questClear => mstData.isQuestClear(cond.condTargetId),
            CondType.questClearPhase => mstData.isQuestPhaseClear(cond.condTargetId, cond.condNum),
            CondType.equipWithTargetCostume => collection?.costumeIds.contains(cond.condNum) == true,
            _ => null,
          },
        ) !=
        false;
  }

  Widget _buildTdButton(NiceTd td, {required bool selected, required bool enabled}) {
    final colorScheme = Theme.of(context).colorScheme;
    final style = OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4));
    return OutlinedButton(
      onPressed: enabled ? () => setState(() => _selection.treasureDeviceId = td.id) : null,
      style: selected
          ? style.copyWith(
              backgroundColor: WidgetStatePropertyAll(colorScheme.secondaryContainer),
              foregroundColor: WidgetStatePropertyAll(colorScheme.onSecondaryContainer),
            )
          : style,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          CommandCardWidget(card: td.card, width: 36),
          const SizedBox(width: 6),
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('${td.lName.l} ${td.rank}'.trim(), maxLines: 1, overflow: TextOverflow.ellipsis),
              Text(
                '${td.id}/${td.num}/${td.priority}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Theme.of(context).colorScheme.outline),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _selectNpMaterials() async {
    final baseUserSvt = mstData.userSvt[options.baseUserSvtId];
    if (baseUserSvt == null) return;
    // svtMaterialTd svtId = baseSvtId + 1
    final materialTdSvtId = db.gameData.servantsById[baseUserSvt.svtId + 1]?.type == SvtType.svtMaterialTd
        ? baseUserSvt.svtId + 1
        : null;
    await router.pushBuilder(
      builder: (context) => SelectUserSvtPage(
        runtime: runtime,
        filterOverride: (userSvt, mstData) {
          return userSvt.id != baseUserSvt.id &&
              (userSvt.svtId == baseUserSvt.svtId || userSvt.svtId == materialTdSvtId) &&
              _isCleanNpMaterial(userSvt, mstData);
        },
        onSelected: (userSvt) {
          if (!mounted) return;
          final npLv = mstData.userSvt[options.baseUserSvtId]?.treasureDeviceLv1 ?? 0;
          final gainLv = _selection.materialUserSvtIds.fold<int>(
            0,
            (sum, id) => sum + (mstData.userSvt[id]?.treasureDeviceLv1 ?? 0),
          );
          if (npLv + gainLv + userSvt.treasureDeviceLv1 > 5) {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('宝具等级上限为 5，该从者会超出上限')));
            return;
          }
          setState(() => _selection.materialUserSvtIds.add(userSvt.id));
        },
      ),
    );
  }

  Future<void> _unlockNpMaterials() async {
    final lockedIds = _npMaterials.where((e) => e.isLocked()).map((e) => e.id).toList();
    if (lockedIds.isEmpty) return;
    await runtime.runTask(
      () => runtime.agent.cardStatusSync(
        changeUserSvtIds: const [],
        revokeUserSvtIds: lockedIds,
        isStorage: false,
        isLock: true,
        isChoice: false,
      ),
    );
  }

  Future<void> _npCombine(NiceTd td, List<UserServantEntity> materials, int targetLv, int qpCost) async {
    final baseUserSvt = mstData.userSvt[options.baseUserSvtId];
    if (baseUserSvt == null) return;
    final confirm = await SimpleConfirmDialog(
      title: const Text('宝具强化'),
      content: Text(
        'NP Lv.${baseUserSvt.treasureDeviceLv1} → Lv.$targetLv\n'
        '材料 ${materials.length} 张（将被消耗）\n'
        'QP ${qpCost.formatSep()}',
      ),
    ).showDialog(context);
    if (!mounted || confirm != true) return;
    await runtime.runTask(() async {
      final lockedIds = materials.where((e) => e.isLocked()).map((e) => e.id).toList();
      if (lockedIds.isNotEmpty) {
        throw SilentException('Unlock ${lockedIds.length}/${materials.length} cards first');
      }
      await runtime.agent.servantTreasureDeviceCombine(
        baseUsrSvtId: baseUserSvt.id,
        selectTdIndex: td.num,
        selectTdId: td.id,
        materialSvtIds: materials.map((e) => e.id).toList(),
      );
    });
  }

  bool checkSvtLvExceed(int userSvtId) {
    final baseUserSvt = mstData.userSvt[userSvtId];
    final svt = baseUserSvt?.dbSvt;
    if (baseUserSvt == null || svt == null) return false;
    if (baseUserSvt.lv < svt.lvMax || baseUserSvt.lv >= 120 || baseUserSvt.lv != baseUserSvt.maxLv) return false;
    if (mstData.getItemOrSvtNum(Items.grailId) < 1) return false;
    if (baseUserSvt.lv >= 100 && (mstData.userSvtCoin[baseUserSvt.svtId]?.num ?? 0) < 30) return false;
    return true;
  }

  Future<void> unlockIndex(int svtId, List<int> indexes) async {
    for (final index in indexes) {
      final svt = db.gameData.servantsById[svtId];
      final userCCId = mstData.userSvtCommandCode[svtId]?.userCommandCodeIds.getOrNull(index) ?? -1;
      final cardType = svt?.cards.getOrNull(index);
      if (cardType == null) {
        throw SilentException('Unknown Svt or index');
      }
      if (userCCId >= 0) continue;
      final itemNum = mstData.userItem[_getCommandCodeUnlockKey(cardType)]?.num ?? 0;
      if (itemNum <= 0) continue;
      await runtime.agent.commandCodeUnlock(servantId: svtId, idx: index);
      if (mounted) setState(() {});
    }
  }
}

int _getCommandCodeUnlockKey(int cardType) {
  int? keyId = {CardType.quick.value: 5000, CardType.arts.value: 5001, CardType.buster.value: 5002}[cardType];
  if (keyId != null) return keyId;
  throw UnimplementedError('Unknown CardType $cardType');
}

class _SvtCombineSelection {
  final Set<int> materialUserSvtIds = {};
  int? treasureDeviceId;

  void clear() {
    materialUserSvtIds.clear();
    treasureDeviceId = null;
  }
}

class _SkillCombineMultiLevelDialog extends StatefulWidget {
  // final bool isActive;
  final Widget title;
  final FakerRuntime runtime;
  final Map<int, LvlUpMaterial> skillMaterials;
  final int? Function() getCurLv;
  final int maxLevel;
  final Future Function(int curLv) callCombine;

  const _SkillCombineMultiLevelDialog({
    // required this.isActive,
    required this.title,
    required this.runtime,
    required this.skillMaterials,
    required this.getCurLv,
    required this.maxLevel,
    required this.callCombine,
  });

  @override
  State<_SkillCombineMultiLevelDialog> createState() => __SkillCombineMultiLevelStateDialog();
}

class __SkillCombineMultiLevelStateDialog extends State<_SkillCombineMultiLevelDialog> {
  late final runtime = widget.runtime;

  // int? _displayStartLv;

  int getItemNum(int itemId) => runtime.mstData.getItemOrSvtNum(itemId);

  @override
  void initState() {
    super.initState();
    // _displayStartLv = widget.getCurLv();
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> children = [];
    final curLv = widget.getCurLv();
    if (curLv != null) {
      for (int endLv = widget.maxLevel; endLv > curLv; endLv--) {
        children.add(buildOne(curLv, endLv));
      }
    }
    return SimpleDialog(
      title: widget.title,
      children: [
        Center(child: runtime.buildCircularProgress(context: context)),
        ...children,
        Center(
          child: IconButton(
            onPressed: () {
              if (runtime.runningTask.value) {
                runtime.agent.network.stopFlag = true;
              }
              Navigator.pop(context);
            },
            icon: Icon(Icons.clear),
          ),
        ),
      ],
    );
  }

  Widget buildOne(int startLv, int endLv) {
    final leading = SizedBox(width: 32, child: AutoSizeText('$startLv→$endLv', maxLines: 1, minFontSize: 4));
    Map<int, int> costItems = {};
    for (int lv = startLv; lv < endLv; lv++) {
      final materials = widget.skillMaterials[lv];
      if (materials == null) {
        return ListTile(dense: true, leading: leading, title: Text('No skill level up material found'), enabled: false);
      }
      costItems.addDict(materials.toItemDict());
    }
    List<Widget> itemWidgets = [];
    bool isLackingItem = false;
    for (final (itemId, itemNum) in costItems.items) {
      final ownNum = getItemNum(itemId);
      isLackingItem = isLackingItem || ownNum < itemNum;
      itemWidgets.add(
        Item.iconBuilder(
          context: context,
          item: null,
          itemId: itemId,
          width: 32,
          text: '${itemNum.format()}\n${ownNum.format()}',
          option: ownNum < itemNum ? ImageWithTextOption(textStyle: TextStyle(color: Colors.red)) : null,
        ),
      );
    }

    Widget? trailing;

    trailing = IconButton(
      onPressed: isLackingItem
          ? null
          : () {
              SimpleConfirmDialog(
                title: widget.title,
                content: Text('${S.current.level} $startLv→$endLv'),
                onTapOk: () {
                  runtime.runTask(() => doLevelUpgrade(endLv));
                },
              ).showDialog(context);
            },
      icon: Icon(Icons.upgrade),
    );

    return ListTile(
      dense: true,
      leading: leading,
      title: Wrap(spacing: 2, runSpacing: 2, children: itemWidgets),
      trailing: trailing,
    );
  }

  Future<void> doLevelUpgrade(int endLv) async {
    int maxLoop = endLv - (widget.getCurLv() ?? endLv);
    while (maxLoop > 0) {
      maxLoop -= 1;
      await Future.delayed(Duration(seconds: 1));
      int? curLv = widget.getCurLv();
      if (curLv == null) {
        throw SilentException('Unexpected curLv=$curLv');
      }
      if (curLv >= endLv) return;
      for (final (itemId, itemNum) in widget.skillMaterials[curLv]!.toItemDict().items) {
        if (getItemNum(itemId) < itemNum) {
          throw SilentException('Item ${Item.getName(itemId)} not enough: ${getItemNum(itemId)}<$itemNum');
        }
      }
      if (!mounted) {
        throw SilentException('Skill multi level up page exited');
      }
      await widget.callCombine(curLv);
      if (mounted) setState(() {});
    }
  }
}

/// Estimated QP cost of NP level-up; display only — the server is authoritative.
/// 5000 QP at ★1 Lv.1, doubling per rarity and per NP level; ★0 follows the ★2 tier.
int _npCombineQp(int rarity, int curLv, int targetLv) =>
    (5000 << ((rarity <= 0 ? 2 : rarity) - 1) << (curLv - 1)) * ((1 << (targetLv - curLv)) - 1);

/// A "clean" NP material: lv 1, no foukun, active skills at lv 1, no append skill investment.
/// Append skill lv 1 = shared per-svtId unlock only; lv > 1 = per-instance investment.
bool _isCleanNpMaterial(UserServantEntity userSvt, MasterDataManager mstData) {
  final svt = userSvt.dbEntity;
  return svt != null &&
      (svt.type == SvtType.normal || svt.type == SvtType.svtMaterialTd) &&
      userSvt.lv == 1 &&
      userSvt.adjustHp == 0 &&
      userSvt.adjustAtk == 0 &&
      userSvt.skillLvs.every((lv) => lv == 1) &&
      mstData.getSvtAppendSkillLvs(userSvt).every((lv) => lv <= 1);
}
