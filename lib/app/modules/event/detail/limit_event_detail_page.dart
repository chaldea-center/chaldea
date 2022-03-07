import 'package:auto_size_text/auto_size_text.dart';
import 'package:chaldea/app/app.dart';
import 'package:chaldea/app/modules/common/builders.dart';
import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/models/models.dart';
import 'package:chaldea/utils/utils.dart';
import 'package:chaldea/widgets/carousel_util.dart';
import 'package:chaldea/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../common/not_found.dart';

class EventDetailPage extends StatefulWidget {
  final int? eventId;
  final Event? event;

  EventDetailPage({Key? key, this.eventId, this.event}) : super(key: key);

  @override
  _EventDetailPageState createState() => _EventDetailPageState();
}

class _EventDetailPageState extends State<EventDetailPage> {
  Event? _event;

  Event get event => _event!;

  @override
  void initState() {
    super.initState();
    _event = widget.event ?? db2.gameData.events[widget.eventId];
  }

  @override
  void didUpdateWidget(covariant EventDetailPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    _event = widget.event ?? db2.gameData.events[widget.eventId];
  }

  @override
  Widget build(BuildContext context) {
    if (_event == null) {
      return NotFoundPage(
        title: 'Event ${widget.eventId}',
        url: Routes.eventI(widget.eventId ?? 0),
      );
    }
    final plan = db2.curUser.eventPlanOf(event.id);
    final banners = [
      ...event.extra.titleBanner.values.whereType<String>(),
    ];

    List<Widget> children = [
      if (banners.isNotEmpty)
        CarouselUtil.limitHeightWidget(context: context, imageUrls: banners),
    ];

    children.add(CustomTable(children: [
      CustomTableRow(children: [
        TableCellData(
          text: event.lName.l.replaceAll('\n', ' '),
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 12),
          color: TableCellData.resolveHeaderColor(context),
        )
      ]),
      if (!Transl.isJP)
        CustomTableRow(children: [
          TableCellData(
            text: event.lName.l.replaceAll('\n', ' '),
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 12),
            color: TableCellData.resolveHeaderColor(context).withOpacity(0.5),
          )
        ]),
      CustomTableRow(children: [
        TableCellData(text: 'Banner', isHeader: true),
        TableCellData(
          flex: 3,
          child: Center(child: db2.getIconImage(event.banner, height: 48)),
        ),
      ]),
      if (event.warIds.isNotEmpty)
        CustomTableRow(children: [
          TableCellData(isHeader: true, text: 'Wars'),
          TableCellData(
            flex: 3,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (final warId in event.warIds)
                  TextButton(
                    onPressed: () {
                      router.push(url: Routes.warI(warId), detail: true);
                    },
                    child: Text(
                      db2.gameData.wars[warId]?.lLongName.l ?? 'War $warId',
                      textAlign: TextAlign.center,
                    ),
                    style: TextButton.styleFrom(
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                  )
              ],
            ),
          )
        ]),
    ]));

    if (!event.isEmpty) {
      children.add(db2.onUserData(
        (context, snapshot) => SwitchListTile.adaptive(
          title: const Text('ALL'),
          value: plan.enabled,
          onChanged: (v) {
            plan.enabled = v;
            event.updateStat();
          },
          controlAffinity: ListTileControlAffinity.trailing,
        ),
      ));
    }

    if (event.itemWarReward.isNotEmpty) {
      children.addAll(_buildSwitchGroup(
        value: () => plan.questReward,
        enabled: () => plan.enabled,
        onChanged: (v) {
          plan.questReward = v;
          event.updateStat();
        },
        title: S.current.game_rewards,
        items: event.itemWarReward,
      ));
    }
    if (event.itemWarDrop.isNotEmpty) {
      children.addAll(_buildSwitchGroup(
        value: () => plan.fixedDrop,
        enabled: () => plan.enabled,
        onChanged: (v) {
          plan.fixedDrop = v;
          event.updateStat();
        },
        title: S.current.main_record_fixed_drop,
        items: event.itemWarDrop,
      ));
    }
    if (event.shop.isNotEmpty) {
      children.addAll(_buildSwitchGroup(
        value: () => plan.shop,
        enabled: () => plan.enabled,
        onChanged: (v) {
          plan.shop = v;
          event.updateStat();
        },
        title: 'Shop',
        items: event.itemShop,
      ));
    }
    if (event.rewards.isNotEmpty) {
      children.addAll(_buildSwitchGroup(
        value: () => plan.point,
        enabled: () => plan.enabled,
        onChanged: (v) {
          plan.point = v;
          event.updateStat();
        },
        title: 'Point Rewards',
        items: event.itemPointReward,
      ));
    }
    if (event.missions.isNotEmpty) {
      children.addAll(_buildSwitchGroup(
        value: () => plan.mission,
        enabled: () => plan.enabled,
        onChanged: (v) {
          plan.mission = v;
          event.updateStat();
        },
        title: 'Mission Rewards',
        items: event.itemMission,
      ));
    }

    if (event.towers.isNotEmpty) {
      children.addAll(_buildSwitchGroup(
        value: () => plan.tower,
        enabled: () => plan.enabled,
        onChanged: (v) {
          plan.tower = v;
          event.updateStat();
        },
        title: 'Tower Rewards',
        items: event.itemTower,
      ));
    }

    for (final lottery in event.lotteries) {
      children.addAll([
        ListTile(
          title: Text(lottery.limited
              ? S.current.event_lottery_limited
              : S.current.event_lottery_unlimited),
          subtitle: lottery.limited
              ? Text(
                  S.current.event_lottery_limit_hint(lottery.maxBoxIndex + 1))
              : null,
          trailing: _inputGroup(
            value: () => plan.lotteries[lottery.id],
            onChanged: (value) {
              if (value < 0) return;
              if (lottery.limited && value > lottery.maxBoxIndex + 1) return;
              plan.lotteries[lottery.id] = value;
            },
            tag: 'lottery_${lottery.id}',
          ),
        ),
        SharedBuilder.groupItems(
          context: context,
          items: lottery.lastBoxItems,
          width: 48,
        ),
      ]);
      final boxesDetail = event.itemLottery[lottery.id];
      if (boxesDetail == null || boxesDetail.isEmpty) continue;
      List<Widget> boxes = [];
      for (final boxIndex in boxesDetail.keys.toList()..sort()) {
        final boxItems = Map.of(boxesDetail[boxIndex]!);
        lottery.lastBoxItems.forEach((key, value) {
          boxItems.addNum(key, -value);
        });
        boxItems.removeWhere((key, value) => value == 0);
        if (boxItems.isEmpty) continue;
        boxes.add(ListTile(
          leading: Text('No.${boxIndex + 1}'),
          title: SharedBuilder.itemGrid(
            context: context,
            items: boxItems.entries,
            width: 48,
          ),
        ));
      }
      if (boxes.isNotEmpty) {
        children.add(TileGroup(children: boxes));
      }
    }

    for (int boxIndex = 0; boxIndex < event.treasureBoxes.length; boxIndex++) {
      final box = event.treasureBoxes[boxIndex];
      final Map<int, int> boxItems = event.itemTreasureBox[box.id] ?? {};
      children.addAll([
        ListTile(title: Text('Treasure Box ${boxIndex + 1}')),
        TileGroup(
          children: [
            for (final itemId in boxItems.keys)
              ListTile(
                leading: GameCardMixin.anyCardItemBuilder(
                    context: context, id: itemId, width: 36),
                title: Text(
                    '${GameCardMixin.anyCardItemName(itemId).l} x ${boxItems[itemId]}'),
                trailing: _inputGroup(
                  value: () => plan.treasureBoxItems[box.id]?[itemId],
                  onChanged: (value) {
                    plan.treasureBoxItems
                        .putIfAbsent(box.id, () => {})[itemId] = value;
                  },
                  tag: 'treasure_box_${box.id}_$itemId',
                ),
              )
          ],
        )
      ]);
    }

    return Scaffold(
      appBar: AppBar(
        title: AutoSizeText(
          event.lName.l.replaceAll('\n', ' '),
          maxLines: 1,
        ),
        centerTitle: false,
        actions: [
          PopupMenuButton(
            itemBuilder: (context) => [
              ...SharedBuilder.websitesPopupMenuItems(
                atlas: Atlas.dbEvent(event.id),
                mooncell: event.extra.mcLink,
                fandom: event.extra.fandomLink,
              ),
              ...SharedBuilder.noticeLinkPopupMenuItems(
                  noticeLink: event.extra.noticeLink),
            ],
          ),
        ],
      ),
      body: ListView(children: children),
    );
  }

  List<Widget> _buildSwitchGroup({
    required bool Function() value,
    required bool Function() enabled,
    required ValueChanged<bool> onChanged,
    required String title,
    required Map<int, int> items,
  }) {
    return [
      db2.onUserData(
        (context, snapshot) => SwitchListTile.adaptive(
          title: Text(title),
          value: value(),
          onChanged: enabled() ? onChanged : null,
          controlAffinity: ListTileControlAffinity.trailing,
        ),
      ),
      SharedBuilder.groupItems(
        context: context,
        items: items,
        width: 48,
      )
    ];
  }

  Widget _inputGroup({
    required int? Function() value,
    required ValueChanged<int> onChanged,
    required String tag,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        db2.onUserData(
          (context, snapshot) => Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Text(value()?.toString() ?? '0'),
          ),
        ),
        SizedBox(
          width: 64,
          child: TextField(
            onChanged: (v) {
              int? n;
              if (v.trim().isEmpty) {
                n = 0;
              } else {
                n = int.tryParse(v);
              }
              if (n != null && n >= 0) {
                EasyDebounce.debounce(
                  tag,
                  const Duration(milliseconds: 500),
                  () {
                    onChanged(n!);
                    event.updateStat();
                  },
                );
              }
            },
            textAlign: TextAlign.center,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              isDense: true,
            ),
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          ),
        ),
      ],
    );
  }
}
