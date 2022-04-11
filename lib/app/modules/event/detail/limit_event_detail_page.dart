import 'package:auto_size_text/auto_size_text.dart';
import 'package:chaldea/app/api/atlas.dart';
import 'package:chaldea/app/app.dart';
import 'package:chaldea/app/modules/common/builders.dart';
import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/models/models.dart';
import 'package:chaldea/utils/utils.dart';
import 'package:chaldea/widgets/carousel_util.dart';
import 'package:chaldea/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

import '../../common/not_found.dart';
import '../../quest/quest_list.dart';
import 'event_missions.dart';
import 'event_shops.dart';
import 'points.dart';
import 'towers.dart';

class EventDetailPage extends StatefulWidget {
  final int? eventId;
  final Event? event;

  EventDetailPage({Key? key, this.eventId, this.event}) : super(key: key);

  @override
  _EventDetailPageState createState() => _EventDetailPageState();
}

class _EventDetailPageState extends State<EventDetailPage> {
  Event? _event;
  Region _region = Region.jp;

  Event get event => _event!;

  @override
  void initState() {
    super.initState();
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
    List<Widget> rows = [
      CustomTableRow(children: [
        TableCellData(
          text: event.shownName,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 14),
          color: TableCellData.resolveHeaderColor(context),
        )
      ]),
      if (!Transl.isJP)
        CustomTableRow(children: [
          TableCellData(
            text: event.name,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 14),
            color: TableCellData.resolveHeaderColor(context).withOpacity(0.5),
          )
        ]),
      if (event.banner != null)
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
    ];
    String _timeText(Region r, int? start, int? end) =>
        '${r.name.toUpperCase()}: ${start?.toDateTimeString() ?? "?"} ~ '
        '${end?.toDateTimeString() ?? "?"}';
    final eventJp = db2.gameData.events[_event?.id];
    List<String> timeInfo = [
      _timeText(_region, event.startedAt, event.endedAt),
      if (_region != db2.curUser.region)
        _timeText(
            db2.curUser.region,
            event.extra.startTime.ofRegion(db2.curUser.region),
            event.extra.endTime.ofRegion(db2.curUser.region)),
      if (Region.jp != _region && Region.jp != _region)
        _timeText(Region.jp, eventJp?.startedAt, eventJp?.endedAt)
    ];
    for (final time in timeInfo) {
      rows.add(CustomTableRow(
        children: [
          TableCellData(
            text: time,
            maxLines: 1,
            style: const TextStyle(fontSize: 14),
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.fromLTRB(16, 4, 4, 4),
          )
        ],
      ));
    }

    children.add(CustomTable(children: rows));

    if (event.extra.huntingQuestIds.isNotEmpty) {
      children.add(TileGroup(
        header: '',
        children: [
          ListTile(
            title: const Text('Hunting Quests'),
            trailing: Icon(DirectionalIcons.keyboard_arrow_forward(context)),
            onTap: () {
              router.push(
                child: QuestListPage(
                  title: 'Event Quest',
                  quests: event.extra.huntingQuestIds
                      .map((e) => db2.gameData.quests[e])
                      .whereType<Quest>()
                      .toList(),
                ),
              );
            },
          )
        ],
      ));
    }

    if (!event.isEmpty) {
      children.add(db2.onUserData(
        (context, snapshot) => CheckboxListTile(
          title: const Text('ALL'),
          value: plan.enabled,
          onChanged: (v) {
            if (v != null) plan.enabled = v;
            event.updateStat();
          },
          controlAffinity: ListTileControlAffinity.leading,
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
        onDetail: () {
          router.push(child: EventShopsPage(event: event));
        },
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
        onDetail: () {
          router.push(child: EventPointsPage(event: event));
        },
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
        onDetail: () {
          router.push(child: EventMissionsPage(event: event));
        },
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
        onDetail: () {
          router.push(child: EventTowersPage(event: event));
        },
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
            readOnly: !plan.enabled,
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
                  readOnly: !plan.enabled,
                ),
              )
          ],
        )
      ]);
    }

    final eventId = widget.event?.id ?? widget.eventId;

    return Scaffold(
      appBar: AppBar(
        title: AutoSizeText(
          event.shownName.replaceAll('\n', ' '),
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
              if (eventId != null && eventId > 0)
                PopupMenuItem(
                  child: const Text('Switch Region'),
                  onTap: () async {
                    await null;
                    final jpEvent = db2.gameData.events[eventId];
                    final startTime = jpEvent?.extra.startTime
                        .copyWith(jp: jpEvent.startedAt);
                    showDialog(
                      context: context,
                      builder: (context) {
                        return SimpleDialog(
                          children: [
                            for (final region in Region.values)
                              ListTile(
                                title: Text(region.name.toUpperCase()),
                                enabled: startTime?.ofRegion(region) != null,
                                onTap: () async {
                                  Navigator.pop(context);
                                  _changeRegion(region, eventId);
                                },
                              ),
                            IconButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              icon: const Icon(Icons.clear),
                            )
                          ],
                        );
                      },
                    );
                  },
                ),
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
    VoidCallback? onDetail,
  }) {
    return [
      db2.onUserData(
        (context, snapshot) => ListTile(
          leading: Checkbox(
            value: value(),
            onChanged: enabled()
                ? (v) {
                    if (v != null) onChanged(v);
                  }
                : null,
          ),
          title: Text(title),
          trailing: onDetail == null
              ? null
              : IconButton(
                  tooltip: 'Details',
                  onPressed: onDetail,
                  icon: Icon(DirectionalIcons.keyboard_arrow_forward(context)),
                  color: Theme.of(context).colorScheme.secondary,
                ),
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
    required bool readOnly,
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
            readOnly: readOnly,
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

  void _changeRegion(Region region, int eventId) async {
    EasyLoading.show(status: 'Loading', maskType: EasyLoadingMaskType.clear);
    Event? newEvent;
    if (region == Region.jp) {
      newEvent = db2.gameData.events[eventId];
    } else {
      newEvent = await AtlasApi.event(eventId, region: region);
      newEvent?.calcItems(db2.gameData);
    }
    _region = region;
    _event = newEvent;
    if (mounted) {
      setState(() {});
    }
    EasyLoading.dismiss();
  }
}
