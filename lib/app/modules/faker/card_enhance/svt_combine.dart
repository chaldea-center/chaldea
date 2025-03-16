import 'package:chaldea/app/app.dart';
import 'package:chaldea/app/modules/common/builders.dart';
import 'package:chaldea/app/modules/common/filter_group.dart';
import 'package:chaldea/app/modules/faker/state.dart';
import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/models/gamedata/toplogin.dart';
import 'package:chaldea/models/models.dart';
import 'package:chaldea/packages/logger.dart';
import 'package:chaldea/utils/utils.dart';
import 'package:chaldea/widgets/widgets.dart';
import '../../battle/formation/formation_card.dart';
import '../../servant/servant_list.dart';
import '../history.dart';

class SvtCombinePage extends StatefulWidget {
  final FakerRuntime runtime;
  const SvtCombinePage({super.key, required this.runtime});

  @override
  State<SvtCombinePage> createState() => _SvtCombinePageState();
}

class _SvtCombinePageState extends State<SvtCombinePage> {
  late final runtime = widget.runtime;
  late final agent = runtime.agent;
  late final mstData = runtime.mstData;
  late final user = agent.user;
  late final options = user.svtCombine;

  @override
  void initState() {
    super.initState();
    runtime.addDependency(this);
  }

  @override
  void dispose() {
    super.dispose();
    runtime.removeDependency(this);
  }

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
            onPressed: () {
              router.pushPage(FakerHistoryViewer(agent: agent));
            },
            icon: const Icon(Icons.history),
          ),
        ],
      ),
      body: PopScope(
        canPop: !runtime.runningTask.value,
        child: ListTileTheme.merge(
          dense: true,
          visualDensity: VisualDensity.compact,
          child: Column(children: [headerInfo, Expanded(child: body), const Divider(height: 1), buttonBar]),
        ),
      ),
    );
  }

  Widget get headerInfo {
    final userGame = mstData.user ?? agent.user.userGame;
    final cardCounts = mstData.countSvtKeep();
    String subtitle = [
      '${S.current.servant} ${cardCounts.svtCount}/${userGame?.svtKeep}',
      '${S.current.craft_essence_short} ${cardCounts.svtEquipCount}/${userGame?.svtEquipKeep}',
      '${S.current.command_code_short} ${cardCounts.ccCount}/${runtime.gameData.constants.maxUserCommandCode}',
      if (cardCounts.unknownCount != 0) '${S.current.unknown} ${cardCounts.unknownCount}',
    ].join(' ');
    subtitle +=
        '\nQP ${userGame?.qp.format(compact: false, groupSeparator: ",")}  ${S.current.present_box}  '
        '${mstData.userPresentBox.length}/${runtime.gameData.constants.maxPresentBoxNum}';
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
            builder:
                (context, running, _) =>
                    CircularProgressIndicator(value: running ? null : 1.0, color: running ? Colors.red : Colors.green),
          ),
        ),
        title: Text('[${agent.user.serverName}] ${userGame?.name}'),
        subtitle: Text(subtitle),
      ),
    );
  }

  Widget get body {
    final baseUserSvt = mstData.userSvt[options.baseUserSvtId];
    String? svtTitle, svtSubtitle;
    final svt = baseUserSvt?.dbSvt;
    final curLvExp = svt?.expGrowth.getOrNull((baseUserSvt?.lv ?? 0) - 1),
        nextLvExp = svt?.expGrowth.getOrNull(baseUserSvt?.lv ?? -1);
    if (baseUserSvt != null) {
      svtTitle = 'No.${svt?.collectionNo} ${svt?.lName.l}';
      svtSubtitle =
          '${baseUserSvt.locked ? "🔐 " : ""}Lv.${baseUserSvt.lv}/${baseUserSvt.maxLv}'
          ' limit ${baseUserSvt.limitCount} exceed ${baseUserSvt.exceedCount}'
          ' skill ${baseUserSvt.skillLv1}/${baseUserSvt.skillLv2}/${baseUserSvt.skillLv3}\n'
          'exp ${nextLvExp == null ? "?" : (baseUserSvt.exp - nextLvExp).format(compact: false, groupSeparator: ",")}';
    }
    Map<int, int> materialCounts = {};
    for (final userSvt in mstData.userSvt) {
      final svt = userSvt.dbEntity;
      if (userSvt.locked || svt == null) continue;
      if (svt.type == SvtType.combineMaterial) {
        materialCounts.addNum(svt.id, 1);
      }
    }
    materialCounts = Item.sortMapByPriority(materialCounts, removeZero: false, reversed: false);
    List<Widget> children = [
      TileGroup(
        header: 'Base Servant',
        children: [
          ListTile(
            dense: true,
            title: Text('Change Base Servant'),
            onTap: selectBaseUserSvt,
            trailing: Icon(Icons.change_circle),
          ),
          ListTile(
            leading: baseUserSvt?.dbSvt?.iconBuilder(context: context) ?? db.getIconImage(Atlas.common.emptySvtIcon),
            title: Text(svtTitle ?? 'id ${options.baseUserSvtId}'),
            subtitle: svtSubtitle == null ? null : Text(svtSubtitle),
          ),
          if (curLvExp != null &&
              nextLvExp != null &&
              baseUserSvt != null &&
              baseUserSvt.exp >= curLvExp &&
              baseUserSvt.exp <= nextLvExp)
            BondProgress(
              value: baseUserSvt.exp - curLvExp,
              total: nextLvExp - curLvExp,
              padding: EdgeInsets.symmetric(horizontal: 16),
            ),
        ],
      ),
      FilterGroup<int>(
        title: Text('种火 Rarity'),
        options: const [1, 2, 3, 4, 5],
        values: FilterGroupData(options: options.svtMaterialRarities),
        onFilterChanged: (v, __) async {
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
            InputCancelOkDialog(
              title: 'Max Material Count',
              text: options.maxMaterialCount.toString(),
              keyboardType: TextInputType.number,
              validate: (s) {
                final v = int.parse(s);
                return v > 0 && v <= 20;
              },
              onSubmit: (s) {
                runtime.lockTask(() => options.maxMaterialCount = int.parse(s));
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
            InputCancelOkDialog(
              title: 'Loop Count',
              text: options.loopCount.toString(),
              keyboardType: TextInputType.number,
              validate: (s) => (int.tryParse(s) ?? -1) >= 0,
              onSubmit: (s) {
                runtime.lockTask(() {
                  options.loopCount = int.parse(s);
                });
              },
            ).showDialog(context);
          },
          child: Text(options.loopCount.toString()),
        ),
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

      final mats = svt.ascensionMaterials[baseUserSvt.limitCount];
      final Map<int, int> limitCombineItems = {
        if (mats != null)
          for (final item in mats.items) item.itemId: item.amount,
        if (mats != null) Items.qpId: mats.qp,
      };
      String combineTitle = '灵基再临 ';
      combineTitle += [baseUserSvt.limitCount, if (limitCombineItems.isNotEmpty) baseUserSvt.limitCount + 1].join('→');
      children.addAll([
        DividerWithTitle(title: '突破'),
        ListTile(
          title: Text(combineTitle),
          trailing: Wrap(
            spacing: 2,
            children: [for (final (itemId, amount) in limitCombineItems.items) _item(itemId, amount)],
          ),
        ),
        if (baseUserSvt.exceedCount == 0 && baseUserSvt.lv == baseUserSvt.maxLv && baseUserSvt.limitCount < 4)
          Center(
            child: FilledButton(
              onPressed: () {
                SimpleConfirmDialog(
                  title: Text('灵基再临'),
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
              },
              child: Text('灵基再临'),
            ),
          ),
        ListTile(
          title: Text('圣杯转临'),
          trailing: Wrap(
            spacing: 2,
            children: [
              _item(Items.grailId, 1),
              if (baseUserSvt.lv >= 100)
                if (svt.coin != null) _item(svt.coin!.item.id, 30),
            ],
          ),
        ),
        if ((baseUserSvt.exceedCount > 0 || baseUserSvt.lv >= svt.lvMax) &&
            baseUserSvt.lv == baseUserSvt.maxLv &&
            baseUserSvt.lv < 120)
          Center(
            child: FilledButton(
              onPressed: () {
                SimpleConfirmDialog(
                  title: Text('圣杯转临'),
                  onTapOk: () {
                    runtime.runTask(() {
                      if (mstData.getItemOrSvtNum(Items.grailId) < 1) {
                        throw SilentException('Grail not enough');
                      }
                      return runtime.agent.servantLevelExceed(baseUserSvtId: baseUserSvt.id);
                    });
                  },
                ).showDialog(context);
              },
              child: Text('圣杯转临'),
            ),
          ),
      ]);
    }
    return ListView(children: children);
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

    final baseUserSvt = mstData.userSvt[options.baseUserSvtId];

    List<List<Widget>> btnGroups = [
      [
        buildButton(
          enabled: baseUserSvt != null,
          onPressed: () {
            runtime.runTask(() async {
              await runtime.svtCombine(loopCount: 1);
              if (mounted) setState(() {});
            });
          },
          text: 'combine',
        ),
        buildButton(
          enabled: options.loopCount > 0 && baseUserSvt != null,
          onPressed: () {
            SimpleConfirmDialog(
              title: Text('Loop ×${options.loopCount}'),
              onTapOk: () {
                runtime.runTask(() => runtime.svtCombine());
              },
            ).showDialog(context);
          },
          text: 'Loop ×${options.loopCount}',
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

  void selectBaseUserSvt() {
    Widget buildSvt(UserServantEntity userSvt) {
      final svt = userSvt.dbSvt;
      return ListTile(
        dense: true,
        leading: svt?.iconBuilder(context: context),
        title: Text('Lv.${userSvt.lv}, ${userSvt.limitCount}/4, ${userSvt.lv}/${userSvt.maxLv}'),
        subtitle: Text('No.${userSvt.id} ${userSvt.locked ? "locked" : "unlocked"}'),
        enabled: userSvt.locked,
        onTap: () {
          runtime.lockTask(() {
            options.baseUserSvtId = userSvt.id;
            if (mounted) setState(() {});
            Navigator.pop(context);
          });
        },
      );
    }

    router.showDialog(
      builder: (context) {
        final notLvMaxSvts =
            mstData.userSvt.where((userSvt) {
              final svt = userSvt.dbSvt;
              if (!userSvt.locked || svt == null || svt.type != SvtType.normal) return false;
              if (userSvt.lv >= (userSvt.maxLv ?? 0)) return false;
              return true;
            }).toList();
        notLvMaxSvts.sort2((e) => -e.lv);

        return SimpleDialog(
          title: Text('Select Servant'),
          children: [
            ListTile(
              title: Text('From servant list'),
              trailing: Icon(DirectionalIcons.keyboard_arrow_forward(context)),
              onTap: () {
                Navigator.pop(context);
                router.pushPage(
                  ServantListPage(
                    onSelected: (selectedSvt) {
                      final userSvts =
                          mstData.userSvt.where((userSvt) {
                            final svt = userSvt.dbSvt;
                            if (svt == null || userSvt.svtId != selectedSvt.id || svt.type != SvtType.normal) {
                              return false;
                            }
                            // if (userSvt.lv >= (userSvt.maxLv ?? 0)) return false;
                            // if (userSvt.lv <= 1) return false;
                            return true;
                          }).toList();
                      userSvts.sortByList((e) => <int>[-e.limitCount, -e.lv, -e.exp]);
                      router.showDialog(
                        builder: (context) {
                          return StatefulBuilder(
                            builder: (context, update) {
                              return SimpleDialog(
                                title: Text('Choose User Servant'),
                                children: [for (final userSvt in userSvts) buildSvt(userSvt)],
                              );
                            },
                          );
                        },
                      );
                    },
                  ),
                );
              },
            ),
            for (final userSvt in notLvMaxSvts.take(20)) buildSvt(userSvt),
          ],
        );
      },
    );
  }
}
