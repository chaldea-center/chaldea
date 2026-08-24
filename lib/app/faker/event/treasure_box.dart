import 'dart:math' show max, min;

import 'package:flutter_easyloading/flutter_easyloading.dart';

import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/models/gamedata/mst_data.dart';
import 'package:chaldea/models/models.dart';
import 'package:chaldea/packages/packages.dart';
import 'package:chaldea/utils/utils.dart';
import 'package:chaldea/widgets/widgets.dart';
import '../runtime.dart';

class TreasureBoxDrawPage extends StatefulWidget {
  final FakerRuntime runtime;
  const TreasureBoxDrawPage({super.key, required this.runtime});

  @override
  State<TreasureBoxDrawPage> createState() => _TreasureBoxDrawPageState();
}

class _TreasureBoxDrawPageState extends State<TreasureBoxDrawPage> with FakerRuntimeStateMixin {
  @override
  late final runtime = widget.runtime;
  late final stat = runtime.agentData.treasureBoxStat;
  Event? event;
  List<EventTreasureBox> treasureBoxes = [];

  @override
  void initState() {
    super.initState();

    event = runtime.gameData.timerData.events.values.firstWhereOrNull(
      (e) => e.treasureBoxes.isNotEmpty && isTimeOpen(e.startedAt, e.shopClosedAt, null),
    );
    treasureBoxes = event?.treasureBoxes ?? [];
    treasureBoxes.sort2((e) => e.slot * 100 + e.idx);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(S.current.event_treasure_box),
        actions: [
          IconButton(onPressed: event?.routeTo, icon: Icon(Icons.flag), tooltip: S.current.event),
          runtime.buildHistoryButton(context),
        ],
      ),
      body: ListView(
        children: [
          for (final box in treasureBoxes) ...[buildBox(box), const Divider()],
          Center(
            child: Padding(padding: .symmetric(vertical: 16), child: Text(S.current.statistics_title)),
          ),
          const Divider(indent: 16, endIndent: 16),
          for (final box in treasureBoxes) ...[buildStatBox(box), const Divider(indent: 16, endIndent: 16)],
          ?buildEventPoint(),
        ],
      ),
    );
  }

  Widget buildBox(EventTreasureBox box) {
    return ListTile(
      leading: Wrap(
        children: [
          for (final consume in box.consumes)
            switch (consume.type) {
              .ap => Text(' AP ${consume.num} '),
              .item => Item.iconBuilder(
                context: context,
                item: null,
                itemId: consume.objectId,
                width: 40,
                text: [
                  mstData.getItemOrSvtNum(consume.objectId).format(),
                  if (consume.num != 1) '×${consume.num.format()}',
                ].join('\n'),
                icon: db.gameData.items[consume.objectId]?.icon,
              ),
            },
        ],
      ),
      title: Wrap(
        spacing: 4,
        runSpacing: 4,
        children: [
          for (final boxGift in box.treasureBoxGifts)
            for (final gift in boxGift.gifts)
              gift.iconBuilder(
                context: context,
                width: 32,
                showOne: false,
                text: [
                  mstData.getItemOrSvtNum(gift.objectId),
                  if (mstData.isCurPlanUser) (db.itemCenter.itemLeft[gift.objectId] ?? 0).format(),
                ].join('\n'),
              ),
        ],
      ),
      trailing: FilledButton(
        onPressed: getMaxDrawNumOne(box) > 0 ? () => onTapDraw(box) : null,
        child: Text(S.current.open),
      ),
    );
  }

  Widget buildStatBox(EventTreasureBox box) {
    int drawNum = stat.treasureBoxDrawNums[box.id] ?? 0;
    return ListTile(
      leading: Wrap(
        children: [
          for (final consume in box.consumes)
            switch (consume.type) {
              .ap => Text(' AP ${consume.num}×$drawNum '),
              .item => Item.iconBuilder(
                context: context,
                item: null,
                itemId: consume.objectId,
                width: 40,
                text: [drawNum, if (consume.num != 1) '×${consume.num.format()}'].join(''),
                icon: db.gameData.items[consume.objectId]?.icon,
              ),
            },
        ],
      ),
      title: Wrap(
        spacing: 4,
        runSpacing: 4,
        children: [
          for (final boxGift in box.treasureBoxGifts)
            for (final gift in boxGift.gifts)
              gift.iconBuilder(
                context: context,
                width: 32,
                showOne: false,
                text: (stat.giftCounts[gift.id] ?? 0).toString(),
              ),
        ],
      ),
    );
  }

  Widget? buildEventPoint() {
    final pointRewards = event?.pointRewards ?? [];
    Map<int, int> maxGroupPoints = {};
    for (final reward in pointRewards) {
      maxGroupPoints[reward.groupId] = max(maxGroupPoints[reward.groupId] ?? 0, reward.point);
    }
    final userEventPoints = {
      for (final userEventPoint in mstData.userEventPoint)
        if (userEventPoint.eventId == event?.id) userEventPoint.groupId: userEventPoint,
    };
    List<Widget> children = [];
    String fmtPoint(int? v) => v?.formatSep() ?? '?';
    for (final groupId in <int>{...maxGroupPoints.keys, ...userEventPoints.keys}) {
      final maxPoint = maxGroupPoints[groupId];
      final userPointValue = userEventPoints[groupId]?.value;
      children.add(
        ListTile(
          title: Text(S.current.event_point),
          subtitle: Text('Group $groupId'),
          trailing: Text(
            [
              '${fmtPoint(userPointValue)}/${fmtPoint(maxPoint)}',
              if (userPointValue != null && maxPoint != null) (userPointValue / maxPoint).format(percent: true),
            ].join('\n'),
            textAlign: .end,
          ),
        ),
      );
    }
    if (children.isEmpty) return null;
    return Column(
      mainAxisSize: .min,
      children: [
        DividerWithTitle(indent: 16, title: S.current.event_point),
        ...children,
      ],
    );
  }

  int getMaxDrawNumOne(EventTreasureBox box) {
    int maxDrawNum = box.maxDrawNumOnce;
    for (final consume in box.consumes) {
      switch (consume.type) {
        case CommonConsumeType.item:
          maxDrawNum = min(maxDrawNum, mstData.getItemOrSvtNum(consume.objectId) ~/ consume.num);
        case CommonConsumeType.ap:
          maxDrawNum = min(maxDrawNum, mstData.user?.calCurAp() ?? 0);
      }
    }
    return max(0, maxDrawNum);
  }

  Future<void> onTapDraw(EventTreasureBox box) async {
    final maxDrawNum = getMaxDrawNumOne(box);
    if (!mounted) return;
    await InputCancelOkDialog.number(
      title: 'Draw Num',
      initValue: maxDrawNum,
      validate: (v) => v > 0 && v <= maxDrawNum,
      onSubmit: (v) {
        showEasyLoading(() => runtime.runTask(() => startDraw(box, v)));
      },
    ).showDialog(context);
  }

  Future<void> startDraw(EventTreasureBox box, int drawNum) async {
    final resp = await runtime.agent.eventTreasureBoxDraw(treasureBoxId: box.id, drawNum: drawNum);
    try {
      final success = resp.data.getResponseNull('treasure_box_draw')?.success;
      if (success == null) return;
      final giftIds = MstValues.toIntList(success['giftIds']);
      stat.treasureBoxDrawNums.addNum(box.id, drawNum);
      for (final giftId in giftIds) {
        stat.giftCounts.addNum(giftId, 1);
      }
    } catch (e, s) {
      logger.e('parse treasure box resp failed', e, s);
      EasyLoading.showError(e.toString());
    }
  }
}
