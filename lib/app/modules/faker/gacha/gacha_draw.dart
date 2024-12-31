import 'package:flutter_easyloading/flutter_easyloading.dart';

import 'package:chaldea/app/api/atlas.dart';
import 'package:chaldea/app/app.dart';
import 'package:chaldea/app/modules/enemy/enemy_list.dart';
import 'package:chaldea/app/modules/faker/state.dart';
import 'package:chaldea/app/modules/servant/servant_list.dart';
import 'package:chaldea/app/modules/summon/gacha/gacha_banner.dart';
import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/models/models.dart';
import 'package:chaldea/utils/utils.dart';
import 'package:chaldea/widgets/widgets.dart';
import '../../common/builders.dart';
import '../../craft_essence/craft_list.dart';
import '../history.dart';
import 'select_sub.dart';
import 'user_status_flag.dart';

class GachaDrawPage extends StatefulWidget {
  final FakerRuntime runtime;
  const GachaDrawPage({super.key, required this.runtime});

  @override
  State<GachaDrawPage> createState() => _GachaDrawPageState();
}

class _GachaDrawPageState extends State<GachaDrawPage> {
  late final runtime = widget.runtime;
  late final agent = runtime.agent;
  late final mstData = runtime.mstData;
  late final user = agent.user;
  late final gachaOption = user.gacha;

  final Map<int, NiceGacha> _cachedGachas = {};

  int get curFriendPoint => mstData.tblUserGame[mstData.user?.userId]?.friendPoint ?? 0;

  @override
  void initState() {
    super.initState();
    runtime.addDependency(this);
    initData();
  }

  @override
  void dispose() {
    super.dispose();
    runtime.removeDependency(this);
  }

  Future<void> initData() async {
    if (gachaOption.gachaId <= 0) return;
    await runtime.runTask(() async {
      final _gacha = await AtlasApi.gacha(gachaOption.gachaId, region: runtime.region);
      if (_gacha != null) _cachedGachas[_gacha.id] = _gacha;
      await runtime.gameData.loadConstants();
    }, check: false);
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(S.current.gacha),
        leading: BackButton(
          onPressed: () async {
            if (runtime.runningTask.value) {
              final confirm = await const SimpleCancelOkDialog(title: Text("Exit?")).showDialog(context);
              if (confirm == true && context.mounted) Navigator.pop(context);
            } else {
              Navigator.pop(context);
            }
          },
        ),
        actions: [
          IconButton(
            onPressed: () {
              router.pushPage(FakerHistoryViewer(agent: agent));
            },
            icon: const Icon(Icons.history),
          ),
        ],
      ),
      body: PopScope(
        canPop: false,
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
    final userGame = mstData.user ?? agent.user.userGame;
    final cardCounts = mstData.countSvtKeep();
    return Container(
      color: Theme.of(context).secondaryHeaderColor,
      padding: const EdgeInsets.only(bottom: 4),
      child: ListTile(
        dense: true,
        minTileHeight: 48,
        visualDensity: VisualDensity.compact,
        minLeadingWidth: 20,
        leading: Container(
          constraints: const BoxConstraints(maxWidth: 16, maxHeight: 16),
          child: ValueListenableBuilder(
            valueListenable: runtime.runningTask,
            builder: (context, running, _) => CircularProgressIndicator(
              value: running ? null : 1.0,
              color: running ? Colors.red : Colors.green,
            ),
          ),
        ),
        title: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(child: Text('[${agent.user.serverName}] ${userGame?.name}')),
            Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                db.getIconImage(Items.friendPoint?.icon, width: 20),
                Text(' ${curFriendPoint.format(compact: false, groupSeparator: ",")}'),
              ],
            ),
          ],
        ),
        subtitle: Text([
          '${S.current.servant} ${cardCounts.svtCount}/${userGame?.svtKeep}',
          '${S.current.craft_essence_short} ${cardCounts.svtEquipCount}/${userGame?.svtEquipKeep}',
          '${S.current.command_code_short} ${cardCounts.ccCount}/${runtime.gameData.constants.maxUserCommandCode}',
          if (cardCounts.unknownCount != 0) '${S.current.unknown} ${cardCounts.unknownCount}',
        ].join(' ')),
      ),
    );
  }

  Widget get body {
    final gacha = _cachedGachas[gachaOption.gachaId];
    return ListView(
      children: [
        ListTile(
          dense: true,
          title: Text('Gacha ID'),
          subtitle: Text([
            gacha?.lName ?? "Unknown",
            if (gacha != null)
              [gacha.openedAt, gacha.closedAt].map((e) => e.sec2date().toStringShort(omitSec: true)).join(' ~ '),
          ].join('\n')),
          trailing: TextButton(
            onPressed: () {
              InputCancelOkDialog(
                title: 'Gacha ID',
                text: gachaOption.gachaId.toString(),
                keyboardType: TextInputType.number,
                validate: (s) => (int.tryParse(s) ?? -1) > 0,
                onSubmit: (s) async {
                  final id = int.parse(s);
                  final _gacha = await showEasyLoading(() => AtlasApi.gacha(id, region: runtime.region));
                  if (_gacha == null) {
                    EasyLoading.showError('Gacha ID $s not found');
                    return;
                  }
                  _cachedGachas[_gacha.id] = _gacha;
                  runtime.lockTask(() {
                    gachaOption.gachaId = id;
                    final subs = _gacha.getValidGachaSubs();
                    subs.sort2((e) => -e.priority);
                    if (subs.isEmpty) {
                      gachaOption.gachaSubId = 0;
                    } else if (subs.every((e) => e.id != gachaOption.gachaSubId)) {
                      gachaOption.gachaSubId = subs.first.id;
                    }
                  });
                },
              ).showDialog(context);
            },
            child: Text(gachaOption.gachaId.toString()),
          ),
        ),
        ListTile(
          dense: true,
          title: Text('Gacha Sub Id'),
          subtitle: Text(gacha?.getValidGachaSubs().map((e) => e.id).join('/') ?? 'null'),
          trailing: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              TextButton(
                onPressed: gacha == null
                    ? null
                    : () {
                        InputCancelOkDialog(
                          title: 'Gacha Sub Id',
                          text: gachaOption.gachaSubId.toString(),
                          keyboardType: TextInputType.number,
                          validate: (s) => (int.tryParse(s) ?? -1) >= 0,
                          onSubmit: (s) async {
                            final subId = int.parse(s);
                            final subs = gacha.getValidGachaSubs();
                            if ((subs.isEmpty && subId == 0) || subs.any((e) => e.id == subId)) {
                              runtime.lockTask(() {
                                gachaOption.gachaSubId = subId;
                              });
                            }
                          },
                        ).showDialog(context);
                      },
                child: Text(gachaOption.gachaSubId.toString()),
              ),
              IconButton(
                onPressed: gacha == null
                    ? null
                    : () => router.pushPage(SelectGachaSubPage(
                          region: runtime.region,
                          mstData: mstData,
                          gacha: gacha,
                          onSelected: (sub) {
                            runtime.lockTask(() {
                              gachaOption.gachaSubId = sub?.id ?? 0;
                            });
                          },
                        )),
                icon: Icon(Icons.change_circle),
              )
            ],
          ),
        ),
        if (gacha != null)
          GachaBanner(
            region: runtime.region,
            imageId: gacha.getImageId(gachaOption.gachaSubId),
          ),
        ListTile(
          dense: true,
          title: Text('Loop Count'),
          trailing: TextButton(
            onPressed: () {
              InputCancelOkDialog(
                title: 'Loop Count',
                text: gachaOption.loopCount.toString(),
                keyboardType: TextInputType.number,
                validate: (s) => (int.tryParse(s) ?? -1) >= 0,
                onSubmit: (s) {
                  runtime.lockTask(() {
                    gachaOption.loopCount = int.parse(s);
                  });
                },
              ).showDialog(context);
            },
            child: Text(gachaOption.loopCount.toString()),
          ),
        ),
        buildLastResult(),
        buildGachaStat(),
        TileGroup(
          header: '${S.current.enhance} - ${S.current.craft_essence}',
          children: [
            ListTile(
              title: Text('Base User CEs'),
              subtitle: Wrap(
                children: [
                  for (final userSvtId in gachaOption.ceEnhanceBaseUserSvtIds) buildEnhanceBaseUserSvt(userSvtId),
                ],
              ),
              trailing: IconButton(
                onPressed: addEnhanceBaseUserSvt,
                icon: Icon(Icons.add),
              ),
            ),
            ListTile(
              title: Text('Base CEs'),
              subtitle: Wrap(
                children: [
                  for (final svtId in gachaOption.ceEnhanceBaseSvtIds) buildEnhanceBaseSvt(svtId),
                ],
              ),
              trailing: IconButton(
                onPressed: addEnhanceBaseSvt,
                icon: Icon(Icons.add),
              ),
            ),
            SwitchListTile.adaptive(
              dense: true,
              title: Text('Feed EXP ${kStarChar2}4'),
              value: gachaOption.feedExp4,
              onChanged: (v) {
                setState(() {
                  runtime.lockTask(() {
                    gachaOption.feedExp4 = v;
                  });
                });
              },
            ),
            SwitchListTile.adaptive(
              dense: true,
              title: Text('Feed EXP ${kStarChar2}3'),
              value: gachaOption.feedExp3,
              onChanged: (v) {
                setState(() {
                  runtime.lockTask(() {
                    gachaOption.feedExp3 = v;
                  });
                });
              },
            ),
          ],
        ),
        TileGroup(
          header: 'Sell - ${S.current.servant} & ${S.current.command_code}',
          children: [
            ListTile(
              title: Text('Auto Sell/自动变还'),
              trailing: Icon(DirectionalIcons.keyboard_arrow_forward(context)),
              onTap: () async {
                await router.pushPage(UserStatusFlagSetPage(runtime: runtime));
                if (mounted) setState(() {});
              },
            ),
            ListTile(
              title: Text('Keep Servants'),
              subtitle: Wrap(
                children: [
                  for (final svtId in gachaOption.sellKeepSvtIds)
                    GestureDetector(
                      onLongPress: () {
                        setState(() {
                          runtime.lockTask(() {
                            gachaOption.sellKeepSvtIds.remove(svtId);
                          });
                        });
                      },
                      child: GameCardMixin.anyCardItemBuilder(context: context, id: svtId, width: 32),
                    ),
                ],
              ),
              trailing: IconButton(
                onPressed: addSellKeepSvts,
                icon: Icon(Icons.add),
              ),
            ),
          ],
        )
      ],
    );
  }

  Widget buildEnhanceBaseUserSvt(int userSvtId) {
    final userSvt = mstData.userSvt[userSvtId];
    Widget child;
    if (userSvt == null) {
      child = Text(userSvtId.toString());
    } else {
      final svt = db.gameData.craftEssencesById[userSvt.svtId];
      if (svt == null) {
        child = Text(userSvtId.toString());
      } else {
        child = svt.iconBuilder(
          context: context,
          width: 36,
          text: '${userSvt.locked ? "🔐" : ""} ${userSvt.limitCount}/4\n${userSvt.lv}/${userSvt.maxLv}',
        );
      }
    }
    child = GestureDetector(
      onLongPress: () {
        setState(() {
          runtime.lockTask(() {
            gachaOption.ceEnhanceBaseUserSvtIds.remove(userSvtId);
          });
        });
      },
      child: child,
    );
    return child;
  }

  CraftFilterData ceFilterData = CraftFilterData();

  void addEnhanceBaseUserSvt() {
    router.pushPage(CraftListPage(
      filterData: ceFilterData,
      onSelected: (selectedCE) {
        final userSvts = mstData.userSvt.where((userSvt) {
          final ce = userSvt.dbCE;
          if (ce == null || userSvt.svtId != selectedCE.id) return false;
          if (userSvt.lv >= (userSvt.maxLv ?? 0)) return false;
          if (userSvt.lv <= 1) return false;
          return true;
        }).toList();
        userSvts.sortByList((e) => <int>[-e.limitCount, -e.lv, -e.exp]);
        router.showDialog(builder: (context) {
          return StatefulBuilder(
            builder: (context, update) {
              return SimpleDialog(
                title: Text('Choose User CE'),
                children: userSvts.map((userSvt) {
                  final ce = userSvt.dbCE;
                  return ListTile(
                    dense: true,
                    leading: ce?.iconBuilder(context: context),
                    title: Text('Lv.${userSvt.lv}, ${userSvt.limitCount}/4, ${userSvt.lv}/${userSvt.maxLv}'),
                    subtitle: Text('No.${userSvt.id} ${userSvt.locked ? "locked" : "unlocked"}'),
                    enabled: userSvt.locked && !gachaOption.ceEnhanceBaseUserSvtIds.contains(userSvt.id),
                    onTap: () {
                      runtime.lockTask(() {
                        gachaOption.ceEnhanceBaseUserSvtIds.add(userSvt.id);
                        EasyLoading.showSuccess("Added ${userSvt.id}");
                        if (mounted) setState(() {});
                        update(() {});
                      });
                    },
                  );
                }).toList(),
              );
            },
          );
        });
      },
    ));
  }

  Widget buildEnhanceBaseSvt(int svtId) {
    final svt = db.gameData.craftEssencesById[svtId];
    Widget child;

    if (svt == null) {
      child = Text(svtId.toString());
    } else {
      child = svt.iconBuilder(
        context: context,
        width: 36,
        text: mstData.userSvt.where((e) => e.svtId == svtId).length.toString(),
      );
    }
    child = GestureDetector(
      onLongPress: () {
        setState(() {
          runtime.lockTask(() {
            gachaOption.ceEnhanceBaseSvtIds.remove(svtId);
          });
        });
      },
      child: child,
    );
    return child;
  }

  void addEnhanceBaseSvt() {
    router.pushPage(CraftListPage(
      filterData: ceFilterData,
      onSelected: (selectedCE) {
        final userSvts = mstData.userSvt.where((userSvt) {
          final ce = userSvt.dbCE;
          if (ce == null || userSvt.svtId != selectedCE.id) return false;
          if (userSvt.lv >= (userSvt.maxLv ?? 0)) return false;
          if (userSvt.lv <= 1) return false;
          return true;
        }).toList();
        if (userSvts.isEmpty) {
          EasyLoading.showError('No valid CE (locked & ${S.current.max_limit_break} & lv>1)');
          return;
        }
        runtime.lockTask(() {
          gachaOption.ceEnhanceBaseSvtIds.add(selectedCE.id);
          if (mounted) setState(() {});
        });
      },
    ));
  }

  void addSellKeepSvts() {
    router.showDialog(
      builder: (context) => SimpleDialog(
        title: Text('Sell Keep'),
        children: [
          ListTile(
            title: Text(S.current.servant),
            onTap: () {
              Navigator.pop(context);
              router.pushPage(ServantListPage(
                onSelected: (svt) {
                  runtime.lockTask(() {
                    gachaOption.sellKeepSvtIds.add(svt.id);
                  });
                  if (mounted) setState(() {});
                },
              ));
            },
          ),
          ListTile(
            title: Text(S.current.craft_essence),
            onTap: () {
              Navigator.pop(context);
              router.pushPage(CraftListPage(
                onSelected: (ce) {
                  runtime.lockTask(() {
                    gachaOption.sellKeepSvtIds.add(ce.id);
                  });
                  if (mounted) setState(() {});
                },
              ));
            },
          ),
          ListTile(
            title: Text('種火/英霊結晶'),
            onTap: () {
              Navigator.pop(context);
              router.pushPage(EnemyListPage(
                filterData: EnemyFilterData()..svtType.options = {SvtType.combineMaterial, SvtType.statusUp},
                onSelected: (svt) {
                  if (svt.type == SvtType.combineMaterial || svt.type == SvtType.statusUp) {
                    runtime.lockTask(() {
                      gachaOption.sellKeepSvtIds.add(svt.id);
                    });
                  } else {
                    EasyLoading.showToast('Invalid choice');
                  }
                  if (mounted) setState(() {});
                },
              ));
            },
          ),
        ],
      ),
    );
  }

  Widget buildLastResult() {
    final cards = runtime.gachaResultStat.lastDrawResult;
    final row1 = cards.take(6).toList();
    final row2 = cards.skip(6).toList();
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (final row in [row1, row2])
          if (row.isNotEmpty)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: row.map((card) {
                Widget child = card.toGift().iconBuilder(
                      context: context,
                      width: 48,
                      text: card.userSvtId == 0 ? 'sold' : null,
                      showOne: false,
                    );
                if (card.userSvtId == 0) {
                  child = Stack(
                    children: [
                      child,
                      Positioned.fill(
                        child: IgnorePointer(
                          child: Container(
                            color: Colors.grey.withAlpha(153),
                            margin: EdgeInsets.all(2),
                          ),
                        ),
                      ),
                    ],
                  );
                }
                return Flexible(child: child);
              }).toList(),
            )
      ],
    );
  }

  Widget buildGachaStat() {
    final stat = runtime.gachaResultStat;
    Set<int> shownSvtIds = {}, shownCeIds = {};
    shownCeIds.addAll(gachaOption.sellKeepSvtIds.where((e) => db.gameData.craftEssencesById.containsKey(e)));
    for (final svtId in stat.servants.keys) {
      final svt = db.gameData.servantsById[svtId];
      if (svt != null) {
        if (svt.isUserSvt &&
            (svt.rarity > 3 || svt.obtains.contains(SvtObtain.limited) || svt.obtains.contains(SvtObtain.unknown))) {
          shownSvtIds.add(svtId);
        }
      }
      final ce = db.gameData.craftEssencesById[svtId];
      if (ce != null) {
        if (ce.obtain == CEObtain.limited || ce.obtain == CEObtain.exp || ce.obtain == CEObtain.unknown) {
          shownCeIds.add(svtId);
        }
      }
    }

    List<Widget> shownCards = [];
    for (final svtId in shownSvtIds.followedBy(shownCeIds)) {
      final entity = db.gameData.servantsById[svtId] ?? db.gameData.craftEssencesById[svtId];
      if (entity == null) continue;
      shownCards.add(entity.iconBuilder(
        context: context,
        width: 32,
        text: '+${stat.servants[svtId] ?? 0}\n${mstData.getItemOrSvtNum(svtId, sumEquipLimitCount: false)}',
      ));
    }
    for (final svtId in shownSvtIds) {
      final item = db.gameData.servantsById[svtId]?.coin?.item;
      if (item == null) continue;
      shownCards.add(Item.iconBuilder(
        context: context,
        item: item,
        text: '+${stat.coins[svtId] ?? 0}\n${mstData.getItemOrSvtNum(item.id)}',
        width: 32,
      ));
    }

    List<Widget> children = [
      ListTile(
        title: Text('${stat.totalCount.format(compact: false, groupSeparator: ",")} ${S.current.summon_pull_unit},'
            ' ${((stat.totalCount * 200).format(compact: false, groupSeparator: ","))} ${Items.friendPoint?.lName.l}'),
      ),
      ListTile(
        title: Text('${Maths.sum(stat.coins.values)} ${S.current.servant_coin_short}'),
      ),
      ListTile(
        title: Text('Cards/Coins'),
        subtitle: Wrap(
          spacing: 2,
          runSpacing: 2,
          children: shownCards,
        ),
      ),
      if (stat.lastEnhanceBaseCE != null)
        SizedBox(
          height: 36,
          child: ListView.builder(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 2),
            scrollDirection: Axis.horizontal,
            itemCount: 1 + 1 + stat.lastEnhanceMaterialCEs.length,
            itemBuilder: (context, index) {
              if (index == 0) {
                return Text(S.current.enhance, style: Theme.of(context).textTheme.bodySmall);
              }
              final userSvt = index == 1 ? stat.lastEnhanceBaseCE : stat.lastEnhanceMaterialCEs.getOrNull(index - 2);
              Widget child = userSvt?.dbCE?.iconBuilder(
                    height: 32,
                    context: context,
                    text: ' ${userSvt.lv}/${userSvt.maxLv}',
                  ) ??
                  Text('${userSvt?.svtId}(${userSvt?.id})');
              if (index == 1) {
                child = Padding(padding: EdgeInsets.symmetric(horizontal: 8), child: child);
              }
              return child;
            },
          ),
        ),
    ];
    if (stat.lastSellServants.isNotEmpty) {
      final soldServants = <int, int>{};
      for (final svt in stat.lastSellServants) {
        soldServants.addNum(svt.svtId, 1);
      }
      final svtIds = soldServants.keys.toList();
      children.add(SizedBox(
        height: 36,
        child: ListView.builder(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 2),
          scrollDirection: Axis.horizontal,
          itemCount: 1 + svtIds.length,
          itemBuilder: (context, index) {
            if (index == 0) {
              return Text('Sell   ', style: Theme.of(context).textTheme.bodySmall);
            }
            final svtId = svtIds[index - 1];
            final soldNum = soldServants[svtId] ?? 0;
            Widget child = GameCardMixin.anyCardItemBuilder(
              context: context,
              height: 32,
              text: soldNum.format(),
              id: svtId,
              onDefault: () => Text(' $svtId×$soldNum '),
            );
            if (index == 0) {
              child = Padding(padding: EdgeInsetsDirectional.only(end: 16), child: child);
            }
            return child;
          },
        ),
      ));
    }

    return TileGroup(
      headerWidget: SHeader.rich(TextSpan(
        text: S.current.statistics_title,
        children: [
          SharedBuilder.textButtonSpan(
            context: context,
            text: '  clear',
            onTap: () {
              SimpleCancelOkDialog(
                title: Text(S.current.clear),
                onTapOk: () {
                  stat.reset();
                  if (mounted) setState(() {});
                },
              ).showDialog(context);
            },
          )
        ],
      )),
      children: children,
    );
  }

  Widget get buttonBar {
    final buttonStyle = FilledButton.styleFrom(
      minimumSize: const Size(64, 32),
      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      padding: const EdgeInsets.symmetric(horizontal: 12),
    );

    FilledButton buildButton({
      bool enabled = true,
      required VoidCallback onPressed,
      required String text,
    }) {
      return FilledButton.tonal(
        onPressed: enabled ? onPressed : null,
        style: buttonStyle,
        child: Text(text),
      );
    }

    List<List<Widget>> btnGroups = [
      [
        buildButton(
          onPressed: () {
            router.showDialog(builder: (context) {
              return AlertDialog(
                title: Text('Draw'),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text(S.current.cancel),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                      runtime.runTask(() async {
                        return runtime.fpGachaDraw();
                      });
                    },
                    child: Text('Draw×1'),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                      runtime.runTask(() async {
                        for (final _ in range(10)) {
                          await runtime.fpGachaDraw();
                          if (mounted) setState(() {});
                        }
                      });
                    },
                    child: Text('Draw×10'),
                  ),
                ],
              );
            });
          },
          text: 'draw',
        ),
        buildButton(
          onPressed: () {
            SimpleCancelOkDialog(
              title: const Text('sell'),
              onTapOk: () {
                runtime.runTask(() async {
                  return runtime.sellServant();
                });
              },
            ).showDialog(context);
          },
          text: 'sell',
        ),
        buildButton(
          onPressed: () {
            router.showDialog(builder: (context) {
              return AlertDialog(
                title: Text('Enhance CE'),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text(S.current.cancel),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                      runtime.runTask(() async {
                        return runtime.svtEquipCombine();
                      });
                    },
                    child: Text('${S.current.enhance}×1'),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                      runtime.runTask(() async {
                        return runtime.svtEquipCombine(10);
                      });
                    },
                    child: Text('${S.current.enhance}×10'),
                  ),
                ],
              );
            });
          },
          text: 'enhance-ce',
        ),
      ],
      [
        buildButton(
          enabled: agent.user.gacha.loopCount > 0,
          onPressed: () {
            SimpleCancelOkDialog(
              title: Text('Loop ×${agent.user.gacha.loopCount}'),
              onTapOk: () {
                runtime.runTask(() => runtime.withWakeLock('loop-fp-$hashCode', runtime.loopFpGachaDraw));
              },
            ).showDialog(context);
          },
          text: 'Loop',
        ),
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
}
