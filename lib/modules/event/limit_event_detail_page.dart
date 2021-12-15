import 'package:auto_size_text/auto_size_text.dart';
import 'package:chaldea/components/components.dart';
import 'package:chaldea/modules/shared/common_builders.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

import 'event_base_page.dart';

class LimitEventDetailPage extends StatefulWidget {
  final LimitEvent event;

  const LimitEventDetailPage({Key? key, required this.event}) : super(key: key);

  @override
  _LimitEventDetailPageState createState() => _LimitEventDetailPageState();
}

class _LimitEventDetailPageState extends State<LimitEventDetailPage>
    with EventBasePage {
  LimitEvent get event => widget.event;

  LimitEventPlan get plan => db.curUser.events.limitEventOf(event.indexKey);

  late TextEditingController _lotteryController;
  final Map<String, TextEditingController> _extraControllers = {};
  final Map<String, TextEditingController> _extra2Controllers = {};

  final List<Summon> _associatedSummons = [];

  @override
  void initState() {
    super.initState();
    _lotteryController = TextEditingController(text: plan.lottery.toString());
    for (var name in event.extra.keys) {
      _extraControllers[name] =
          TextEditingController(text: plan.extra[name]?.toString());
    }
    for (var name in event.extra2.keys) {
      _extra2Controllers[name] =
          TextEditingController(text: plan.extra2[name]?.toString());
    }
    db.gameData.summons.values.forEach((summon) {
      for (var eventName in summon.associatedEvents) {
        if (event.isSameEvent(eventName)) {
          _associatedSummons.add(summon);
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final svt = db.gameData.servants[event.welfareServant];

    List<Widget> children = [];
    children.addAll(buildHeaders(context: context, event: event));
    children.add(db.streamBuilder((context) => TileGroup(children: [
          SwitchListTile.adaptive(
            title: Text(S.current.plan),
            value: plan.enabled,
            onChanged: (v) {
              plan.enabled = v;
              db.itemStat.updateEventItems();
            },
          ),
          if (event.grail2crystal > 0)
            SwitchListTile.adaptive(
              title: Text(S.current.rerun_event),
              subtitle: Text(
                  S.current.event_rerun_replace_grail(event.grail2crystal)),
              value: plan.rerun,
              onChanged: (v) {
                plan.rerun = v;
                db.notifyDbUpdate();
                setState(() {
                  // update grail and crystal num
                });
              },
            ),
          if (svt != null)
            ListTile(
              title: Text(LocalizedText.of(
                  chs: '活动从者', jpn: '配布サーヴァント', eng: 'Welfare Servant', kor: '배포 서번트')),
              trailing: svt.iconBuilder(context: context),
            )
        ])));
    children.addAll(buildQuests(context: context, event: event));

    // 无限池
    if (event.lottery.isNotEmpty == true) {
      children.add(const SizedBox(height: 8));
      children.add(ListTile(
        title: Text(
          event.lotteryLimit > 0
              ? S.current.event_lottery_limited
              : S.current.event_lottery_unlimited,
          textScaleFactor: 0.95,
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
        subtitle: event.lotteryLimit > 0
            ? Text(S.of(context).event_lottery_limit_hint(event.lotteryLimit))
            : null,
        trailing: SizedBox(
            width: 80,
            child: TextField(
              maxLength: 4,
              textAlign: TextAlign.center,
              keyboardType: TextInputType.number,
              scrollPadding: EdgeInsets.zero,
              decoration: InputDecoration(
                counterText: '',
                suffixText: S.of(context).event_lottery_unit,
                isDense: true,
              ),
              controller: _lotteryController,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              onChanged: (v) {
                plan.lottery = int.tryParse(v) ?? 0;
                db.itemStat.updateEventItems();
              },
            )),
      ));
      children
          .add(buildClassifiedItemList(context: context, data: event.lottery));
    }

    // 商店任务点数
    final Map<String, int> items = event.itemsWithRare(plan);
    if (items.isNotEmpty) {
      children.addAll([
        blockHeader(S.current.event_item_default),
        buildClassifiedItemList(context: context, data: items)
      ]);
    }

    // 狩猎 无限池终本掉落等
    if (event.extra.isNotEmpty == true) {
      children.addAll([
        blockHeader(S.current.event_item_extra),
        _buildExtraItems(event.extra, plan.extra, _extraControllers)
      ]);
    }

    if (event.extra2.isNotEmpty == true) {
      children.addAll([
        blockHeader(S.current.event_item_extra + ' 2'),
        _buildExtraItems(event.extra2, plan.extra2, _extra2Controllers)
      ]);
    }

    // summons
    children
        .addAll(buildSummons(context: context, summons: _associatedSummons));

    children.add(SizedBox(
      height: 72,
      child: Center(
        child: Text(
          '.',
          style: Theme.of(context).textTheme.caption,
        ),
      ),
    ));
    return Scaffold(
      appBar: AppBar(
        title: AutoSizeText(
          event.localizedName,
          maxLines: 1,
          overflow: TextOverflow.fade,
        ),
        titleSpacing: 0,
        centerTitle: false,
        actions: [
          PopupMenuButton<String>(
            itemBuilder: (context) => [
              PopupMenuItem(
                child: Text(S.current.jump_to('Mooncell')),
                onTap: () {
                  launch(WikiUtil.mcFullLink(widget.event.indexKey));
                },
              )
            ],
          )
        ],
      ),
      body: ListView(children: children),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.archive_outlined),
        tooltip: S.of(context).event_collect_items,
        onPressed: onArchive,
      ),
    );
  }

  Future<void> onArchive() async {
    if (!plan.enabled) {
      showInformDialog(context, content: S.current.event_not_planned);
    } else {
      await showDialog(
        context: context,
        builder: (context) => _ArchiveDialog(event: event, plan: plan),
      );
      _lotteryController.text = plan.lottery.toString();
      _extraControllers.forEach((key, controller) {
        controller.text = plan.extra[key]?.toString() ?? '';
      });
      _extra2Controllers.forEach((key, controller) {
        controller.text = plan.extra2[key]?.toString() ?? '';
      });
      if (mounted) setState(() {});
    }
  }

  Widget _buildExtraItems(Map<String, String> data, Map<String, int> extraPlan,
      Map<String, TextEditingController> controllers) {
    List<Widget> children = [];
    data.forEach((itemKey, hint) {
      final controller = controllers[itemKey];
      children.add(ListTile(
        leading:
            Item.iconBuilder(context: context, itemKey: itemKey, height: 46),
        title: Text(Item.lNameOf(itemKey)),
        subtitle: Text(hint),
        trailing: SizedBox(
          width: 50,
          child: TextField(
            maxLength: 4,
            controller: controller,
            textAlign: TextAlign.center,
            keyboardType: TextInputType.number,
            textInputAction: TextInputAction.next,
            inputFormatters: [NumberInputFormatter()],
            decoration: const InputDecoration(counterText: ''),
            onChanged: (v) {
              extraPlan[itemKey] = int.tryParse(v) ?? 0;
              db.itemStat.updateEventItems();
            },
            onSubmitted: (_) {},
            onEditingComplete: () {
              FocusScope.of(context).nextFocus();
            },
          ),
        ),
      ));
    });
    return TileGroup(padding: EdgeInsets.zero, children: children);
  }

  @override
  void dispose() {
    super.dispose();
    _lotteryController.dispose();
    _extra2Controllers.values.forEach((c) => c.dispose());
  }
}

class _ArchiveDialog extends StatefulWidget {
  final LimitEvent event;
  final LimitEventPlan plan;

  const _ArchiveDialog({Key? key, required this.event, required this.plan})
      : super(key: key);

  @override
  _ArchiveDialogState createState() => _ArchiveDialogState();
}

class _ArchiveDialogState extends State<_ArchiveDialog> {
  LimitEvent get event => widget.event;

  LimitEventPlan get plan => widget.plan;

  bool _shop = true;
  bool _lottery = true;
  bool _extra = true;
  bool _extra2 = true;

  bool get _shopEnabled => event.itemsWithRare(plan).isNotEmpty;

  bool get _lotteryEnabled => event.lottery.isNotEmpty;

  bool get _extraEnabled => event.extra.isNotEmpty;

  bool get _extra2Enabled => event.extra2.isNotEmpty;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (event.itemsWithRare(plan).isNotEmpty)
            SwitchListTile.adaptive(
              value: _shop,
              title: Text(S.current.event_item_default),
              onChanged: (v) {
                setState(() {
                  _shop = v;
                });
              },
            ),
          if (event.lottery.isNotEmpty)
            SwitchListTile.adaptive(
              value: _lottery,
              title: Text(event.lotteryLimit > 0
                  ? S.current.event_lottery_limited
                  : S.current.event_lottery_unlimited),
              onChanged: (v) {
                setState(() {
                  _lottery = v;
                });
              },
            ),
          if (event.extra.isNotEmpty)
            SwitchListTile.adaptive(
              value: _extra,
              title: Text(S.current.event_item_extra),
              onChanged: (v) {
                setState(() {
                  _extra = v;
                });
              },
            ),
          if (event.extra2.isNotEmpty)
            SwitchListTile.adaptive(
              value: _extra2,
              title: Text(S.current.event_item_extra + ' 2'),
              onChanged: (v) {
                setState(() {
                  _extra2 = v;
                });
              },
            ),
          ListTile(
            subtitle: Text(
              LocalizedText.of(
                chs: '注意:\n收取每部分素材，无限池及额外部分在收取后将清零，若收取全部则本活动在收取后将移出规划',
                jpn: '知らせ：\n各部分が収集され、"ボックスガチャ"と"その他"は受領後にクリアされます。'
                    'すべてが収集された場合、このイベントはプランから削除されます。',
                eng:
                    'Hint:\nArchive each part of items, reset lottery and extra parts after archived, '
                    'remove event from plan if all selected',
              ),
              textScaleFactor: 0.8,
            ),
          )
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: Text(S.current.cancel),
        ),
        TextButton(
          onPressed: (_shop && _shopEnabled) ||
                  (_lottery && _lotteryEnabled) ||
                  (_extra && _extraEnabled) ||
                  (_extra2 && _extra2Enabled)
              ? archive
              : null,
          child: Text(S.current.confirm),
        )
      ],
    );
  }

  void archive() {
    Map<String, int> _archived = {};
    if (_shopEnabled && _shop) {
      sumDict([_archived, event.itemsWithRare(plan)], inPlace: true);
    }
    if (_lotteryEnabled && _lottery) {
      sumDict([_archived, multiplyDict(event.lottery, plan.lottery)],
          inPlace: true);
      plan.lottery = 0;
    }
    if (_extraEnabled && _extra) {
      sumDict([
        _archived,
        plan.extra..removeWhere((key, value) => !event.extra.containsKey(key)),
      ], inPlace: true);
      plan.extra.clear();
    }
    if (_extra2Enabled && _extra2) {
      sumDict([
        _archived,
        plan.extra2
          ..removeWhere((key, value) => !event.extra2.containsKey(key)),
      ], inPlace: true);
      plan.extra2.clear();
    }
    _archived.removeWhere((key, value) => value <= 0);
    sumDict([db.curUser.items, _archived], inPlace: true);
    if (_shop && _lottery && _extra && _extra2) {
      plan.enabled = false;
    }
    db.itemStat.updateEventItems();
    Navigator.of(context).pop();
    showDialog(
      context: context,
      builder: (context) => SimpleCancelOkDialog(
        title: Text(_archived.isEmpty ? 'Nothing' : S.current.success),
        content: Wrap(
          spacing: 3,
          runSpacing: 3,
          children: _archived.entries
              .map((e) => Item.iconBuilder(
                    context: context,
                    itemKey: e.key,
                    text: formatNumber(e.value,
                        compact: true, groupSeparator: ''),
                    height: 42,
                  ))
              .toList(),
        ),
        hideCancel: true,
      ),
    );
  }
}
