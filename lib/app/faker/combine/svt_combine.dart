import 'package:chaldea/app/app.dart';
import 'package:chaldea/app/modules/common/builders.dart';
import 'package:chaldea/app/modules/common/filter_group.dart';
import 'package:chaldea/app/modules/common/misc.dart';
import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/models/models.dart';
import 'package:chaldea/packages/logger.dart';
import 'package:chaldea/utils/utils.dart';
import 'package:chaldea/widgets/widgets.dart';
import '../../modules/battle/formation/formation_card.dart';
import '../_shared/svt_select.dart';
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

  @override
  Widget build(BuildContext context) {
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
                mstData.userSvt[options.baseUserSvtId]?.dbSvt?.iconBuilder(context: context, jumpToDetail: false) ??
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
        leading: svt?.iconBuilder(context: context) ?? db.getIconImage(Atlas.common.emptySvtIcon),
        subtitle: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '[${agent.user.serverName}] ${userGame?.name}   QP ${userGame?.qp.format(compact: false, groupSeparator: ",")}',
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
                ' append ${mstData.getSvtAppendSkillLv(baseUserSvt).join("/")}',
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
      final svt = userSvt.dbEntity;
      if (userSvt.isLocked() || svt == null) continue;
      if (svt.type == SvtType.combineMaterial) {
        materialCounts.addNum(svt.id, 1);
      }
    }
    materialCounts = Item.sortMapByPriority(materialCounts, removeZero: false, reversed: false);
    List<Widget> children = [
      DividerWithTitle(title: S.current.enhance),
      FilterGroup<int>(
        title: Text('种火 Rarity'),
        options: const [1, 2, 3, 4, 5],
        values: FilterGroupData(options: options.svtMaterialRarities),
        onFilterChanged: (v, _) async {
          runtime.lockTask(() => options.svtMaterialRarities = v.options);
          if (mounted) setState(() {});
        },
      ),
      Padding(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        child: SharedBuilder.itemGrid(context: context, items: materialCounts.entries, width: 36),
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
            onPressed: baseUserSvt == null
                ? null
                : () {
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
                      content: Text('Grail $grailNum-1, coin $coinNum-30'),
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
                    collection.friendshipRank < 15 &&
                    collection.friendshipRank == collection.maxFriendshipRank
                ? () {
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
              final curLv = mstData.getSvtAppendSkillLv(baseUserSvt).getOrNull(skillNum - 1);
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
              final combineDisabled = isLacking || curLv == null || curLv == 10;
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

                              await runtime.runTask(
                                () => runtime.agent.appendSkillCombine(
                                  baseUsrSvtId: baseUserSvt.id,
                                  skillNum: skillNum2,
                                  currentSkillLv: curLv,
                                ),
                              );
                            },
                      onLongPress: skill.skill.routeTo,
                      child: Opacity(
                        opacity: combineDisabled ? 0.3 : 1,
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
                if (skill.condQuestId > 0 && !mstData.isQuestCleared(skill.condQuestId)) return false;
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
                      onLongPress: skill.routeTo,
                      child: Opacity(
                        opacity: combineDisabled ? 0.3 : 1,
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

      // command code
      final userSvtCmdCode = mstData.userSvtCommandCode[baseUserSvt.svtId];
      children.addAll([
        DividerWithTitle(title: '${S.current.command_code} ${S.current.unlock}'),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ...List.generate(5, (index) {
              final cardType = svt.cards.getOrNull(index);
              final status = userSvtCmdCode?.userCommandCodeIds.getOrNull(index) ?? -1;
              Widget child;
              if (cardType == null) {
                child = Text('$index:UnknownCard');
              } else {
                child = CommandCardWidget(card: cardType, width: 42);
                child = ImageWithText(
                  image: child,
                  text: (mstData.userItem[_getCommandCodeUnlockKey(cardType)]?.num ?? 0).toString(),
                  option: ImageWithTextOption(fontSize: 12),
                );
                if (status == -1) {
                  child = InkWell(
                    onTap: () async {
                      await runtime.runTask(() => unlockIndex(svt.id, [index]));
                    },
                    child: Opacity(opacity: 0.5, child: child),
                  );
                }
              }
              return Flexible(child: child);
            }),
            IconButton(
              onPressed: () {
                runtime.runTask(() => unlockIndex(svt.id, List.generate(5, (i) => i)));
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
          leading: db.getIconImage(svt.ascendIcon(Servant.dispLimitCountToLimitCount(baseUserSvt.dispLimitCount))),
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
                          svt.ascendIcon(Servant.dispLimitCountToLimitCount(dispLimitCount)),
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

  void selectBaseUserSvt() {
    router.pushBuilder(
      builder: (context) => SelectUserSvtPage(
        runtime: runtime,
        onSelected: (userSvt) {
          runtime.lockTask(() {
            options.baseUserSvtId = userSvt.id;
            if (mounted) setState(() {});
          });
        },
      ),
    );
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
      final status = mstData.userSvtCommandCode[svtId]?.userCommandCodeIds.getOrNull(index) ?? -1;
      final cardType = svt?.cards.getOrNull(index);
      if (cardType == null) {
        throw SilentException('Unknown Svt or index');
      }
      if (status >= 0) continue;
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
