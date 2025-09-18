import 'package:chaldea/app/api/atlas.dart';
import 'package:chaldea/app/app.dart';
import 'package:chaldea/app/modules/common/builders.dart';
import 'package:chaldea/app/modules/faker/state.dart';
import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/models/gamedata/toplogin.dart';
import 'package:chaldea/models/models.dart';
import 'package:chaldea/utils/utils.dart';
import 'package:chaldea/widgets/widgets.dart';
import '../card_enhance/svt_combine.dart';
import '../present_box/present_box.dart';

class BoxGachaDrawPage extends StatefulWidget {
  final FakerRuntime runtime;
  const BoxGachaDrawPage({super.key, required this.runtime});

  @override
  State<BoxGachaDrawPage> createState() => _BoxGachaDrawPageState();
}

class _BoxGachaDrawPageState extends State<BoxGachaDrawPage> with FakerRuntimeStateMixin {
  @override
  late final runtime = widget.runtime;
  late final user = agent.user;
  late final jpBoxGachaEvents = <int, ({Event event, EventLottery lottery})>{
    for (final e in db.gameData.events.values)
      for (final lottery in e.lotteries)
        if (mstData.userBoxGacha.dict.containsKey(lottery.id)) lottery.id: (event: e, lottery: lottery),
  };
  ({Event event, EventLottery lottery})? curEvent;
  int boxGachaId = 0;

  final loopCount = Ref<int>(0);
  int drawNumOnce = 100;

  @override
  void initState() {
    super.initState();
    initData().then((_) {
      if (mounted) setState(() {});
    });
  }

  Future<void> initData() async {
    if (mstData.userBoxGacha.isEmpty) {
      return;
    } else if (mstData.userBoxGacha.length > 1 && mounted) {
      final gacha = await router.showDialog<UserBoxGachaEntity>(
        builder: (context) => SimpleDialog(
          title: Text('Select Lottery'),
          children: [
            for (final gacha in mstData.userBoxGacha)
              SimpleDialogOption(
                child: Text('${gacha.boxGachaId}: ${gacha.resetNum} ${S.current.event_lottery_unit}'),
                onPressed: () => Navigator.pop(context, gacha),
              ),
          ],
        ),
      );
      if (gacha != null) {
        boxGachaId = gacha.boxGachaId;
      }
    } else {
      boxGachaId = mstData.userBoxGacha.first.boxGachaId;
    }
    if (boxGachaId == 0) return;
    if ((mstData.userBoxGacha[boxGachaId]?.resetNum ?? 0) <= 10) {
      drawNumOnce = 10;
    }

    final jpEvent = jpBoxGachaEvents[boxGachaId];
    if (user.region == Region.jp) {
      curEvent = jpEvent;
    } else if (jpEvent != null) {
      final _event = await showEasyLoading(() => AtlasApi.event(jpEvent.event.id, region: user.region));
      final _lottery = _event?.lotteries.firstWhereOrNull((e) => e.id == boxGachaId);
      if (_event != null && _lottery != null) {
        curEvent = (event: _event, lottery: _lottery);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(S.current.event_lottery),
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
          runtime.buildHistoryButton(context),
          PopupMenuButton(
            itemBuilder: (context) => [
              PopupMenuItem(
                // enabled: !runtime.runningTask.value,
                onTap: () {
                  router.pushPage(UserPresentBoxManagePage(runtime: runtime));
                },
                child: Text(S.current.present_box),
              ),
              PopupMenuItem(
                // enabled: !runtime.runningTask.value,
                onTap: () {
                  router.pushPage(SvtCombinePage(runtime: runtime));
                },
                child: Text('从者强化'),
              ),
            ],
          ),
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
    final userGame = mstData.user ?? agent.user.userGame;
    final cardCounts = mstData.countSvtKeep();
    String subtitle = [
      '${S.current.servant} ${cardCounts.svtCount}/${userGame?.svtKeep}',
      '${S.current.craft_essence_short} ${cardCounts.svtEquipCount}/${userGame?.svtEquipKeep}',
      '${S.current.command_code_short} ${cardCounts.ccCount}/${runtime.gameData.timerData.constants.maxUserCommandCode}',
      if (cardCounts.unknownCount != 0) '${S.current.unknown} ${cardCounts.unknownCount}',
    ].join(' ');
    subtitle +=
        '\nQP ${userGame?.qp.format(compact: false, groupSeparator: ",")}  ${S.current.present_box}  '
        '${mstData.userPresentBox.length}/${runtime.gameData.timerData.constants.maxPresentBoxNum}';
    return Container(
      color: Theme.of(context).secondaryHeaderColor,
      padding: const EdgeInsets.only(bottom: 4),
      child: ListTile(
        dense: true,
        minTileHeight: 48,
        visualDensity: VisualDensity.compact,
        minLeadingWidth: 20,
        leading: runtime.buildCircularProgress(context: context),
        title: Text('[${agent.user.serverName}] ${userGame?.name}'),
        subtitle: Text(subtitle),
      ),
    );
  }

  Widget get body {
    final event = curEvent?.event, lottery = curEvent?.lottery;
    final userBoxGacha = mstData.userBoxGacha[boxGachaId];
    final boxPerLottery = lottery?.getMaxNum(userBoxGacha?.boxIndex ?? -99) ?? 300;
    final ownItemCount = mstData.userItem[lottery?.cost.itemId]?.num ?? 0;
    final leftLotteryCount = lottery == null ? 0 : ownItemCount / lottery.cost.amount / boxPerLottery;
    final curBoxIndex = userBoxGacha?.boxIndex ?? 0;
    final itemIds = <int>{
      if (lottery != null)
        for (final box in lottery.boxes)
          if (box.boxIndex >= curBoxIndex)
            for (final gift in box.gifts) gift.objectId,
    };
    final itemCounts = Item.sortMapByPriority(
      {
        for (final itemId in itemIds)
          itemId: db.gameData.items[itemId]?.type == ItemType.itemSelect
              ? Maths.sum(mstData.userPresentBox.where((e) => e.objectId == itemId).map((e) => e.num))
              : mstData.getItemOrSvtNum(itemId),
      },
      reversed: true,
      removeZero: false,
    );
    return ListView(
      children: [
        ListTile(
          dense: true,
          title: Text('Box Gacha $boxGachaId'),
          subtitle: Text(event?.lShortName.l ?? "Unknown Event"),
          trailing: Text(
            '${userBoxGacha?.resetNum}${S.current.event_lottery_unit}\n'
            '${userBoxGacha?.drawNum}/$boxPerLottery',
            textAlign: TextAlign.end,
          ),
          onTap: event?.routeTo,
        ),
        ListTile(
          dense: true,
          title: Text.rich(
            TextSpan(
              text: 'COST ',
              children: [
                if (lottery != null) ...[
                  CenterWidgetSpan(
                    child: Item.iconBuilder(
                      context: context,
                      item: lottery.cost.item,
                      itemId: lottery.cost.itemId,
                      width: 24,
                    ),
                  ),
                  TextSpan(text: ' ×${lottery.cost.amount}'),
                ],
              ],
            ),
          ),
          trailing: Text(
            lottery == null
                ? '$ownItemCount'
                : '$ownItemCount/(${lottery.cost.amount}×$boxPerLottery)=${leftLotteryCount.format(precision: 1)}',
          ),
        ),
        ListTile(
          dense: true,
          title: Text('Draw Count Once'),
          trailing: DropdownButton<int>(
            alignment: AlignmentDirectional.centerEnd,
            value: drawNumOnce,
            items: [
              for (final v in const [1, 10, 100]) DropdownMenuItem(value: v, child: Text(v.toString())),
            ],
            onChanged: (v) {
              runtime.lockTask(() {
                if (v != null) drawNumOnce = v;
              });
            },
          ),
        ),
        ListTile(
          dense: true,
          title: Text('Loop Count'),
          trailing: TextButton(
            onPressed: () {
              InputCancelOkDialog.number(
                title: 'Loop Count',
                initValue: loopCount.value,
                validate: (v) => v >= 0,
                onSubmit: (v) {
                  runtime.lockTask(() => loopCount.value = v);
                },
              ).showDialog(context);
            },
            child: Text(loopCount.value.toString()),
          ),
        ),
        DividerWithTitle(title: S.current.item),
        ListTile(
          leading: Item.iconBuilder(context: context, item: Items.qp),
          title: Text(mstData.user?.qp.format(compact: false, groupSeparator: ',') ?? '0'),
        ),
        ListTile(
          title: SharedBuilder.itemGrid(context: context, items: itemCounts.entries, width: 36, showZero: true),
        ),
      ],
    );
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

    final lottery = curEvent?.lottery;

    List<List<Widget>> btnGroups = [
      [
        buildButton(
          enabled: lottery != null && !runtime.runningTask.value,
          onPressed: () {
            if (runtime.runningTask.value) return;
            runtime.runTask(() async {
              await runtime.boxGachaDraw(lottery: lottery!, num: drawNumOnce, loopCount: Ref(1));
              if (mounted) setState(() {});
            });
          },
          text: 'draw',
        ),
        buildButton(
          enabled: loopCount.value > 0 && lottery != null,
          onPressed: () {
            SimpleConfirmDialog(
              title: Text('Loop ×${loopCount.value}'),
              onTapOk: () {
                runtime.runTask(
                  () => runtime.withWakeLock(
                    'loop-box-gacha-$hashCode',
                    () => runtime.boxGachaDraw(lottery: lottery!, num: drawNumOnce, loopCount: loopCount),
                  ),
                );
              },
            ).showDialog(context);
          },
          text: 'Loop ×${loopCount.value}',
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
