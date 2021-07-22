import 'package:auto_size_text/auto_size_text.dart';
import 'package:chaldea/components/components.dart';
import 'package:chaldea/modules/item/item_detail_page.dart';
import 'package:chaldea/modules/shared/item_related_builder.dart';
import 'package:flutter/services.dart';

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
  Map<String, TextEditingController> _controllers = {};

  List<Summon> _associatedSummons = [];

  @override
  void initState() {
    super.initState();
    _lotteryController = TextEditingController(text: plan.lottery.toString());
    for (var name in event.extra.keys) {
      _controllers[name] =
          TextEditingController(text: plan.extra[name]?.toString());
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
    children.addAll(this.buildHeaders(context: context, event: event));
    children.add(db.streamBuilder((context) => TileGroup(children: [
          SwitchListTile.adaptive(
            title: Text(S.of(context).plan),
            value: plan.enable,
            onChanged: (v) {
              plan.enable = v;
              db.itemStat.updateEventItems();
            },
          ),
          if (event.grail2crystal > 0)
            SwitchListTile.adaptive(
              title: Text(S.of(context).rerun_event),
              subtitle: Text(
                  S.of(context).event_rerun_replace_grail(event.grail2crystal)),
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
                  chs: '活动从者', jpn: '配布サーヴァント', eng: 'Welfare Servant')),
              trailing: svt.iconBuilder(context: context),
            )
        ])));

    // 无限池
    if (event.lottery.isNotEmpty == true) {
      children
        ..add(ListTile(
          title: Text(event.lotteryLimit > 0
              ? S.of(context).event_lottery_limited
              : S.of(context).event_lottery_unlimited),
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
        ))
        ..add(kDefaultDivider)
        ..add(buildClassifiedItemList(context: context, data: event.lottery));
    }

    // 商店任务点数
    final Map<String, int> items = event.itemsWithRare(plan);
    if (items.isNotEmpty) {
      children.addAll([
        ListTile(title: Center(child: Text(S.current.event_item_default))),
        kDefaultDivider,
        buildClassifiedItemList(context: context, data: items)
      ]);
    }

    // 狩猎 无限池终本掉落等
    if (event.extra.isNotEmpty == true) {
      children.addAll([
        ListTile(title: Center(child: Text(S.current.event_item_extra))),
        kDefaultDivider,
        _buildExtraItems(event.extra, plan.extra)
      ]);
    }

    // summons
    children.addAll(
        this.buildSummons(context: context, summons: _associatedSummons));

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
        leading: BackButton(),
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
                value: 'jump_mc',
                child: Text(S.current.jump_to('Mooncell')),
              )
            ],
            onSelected: (v) {
              if (v == 'jump_mc') {
                jumpToExternalLinkAlert(
                  url: WikiUtil.mcFullLink(widget.event.indexKey),
                  name: 'Mooncell',
                );
              }
            },
          )
        ],
      ),
      body: ListView(children: children),
      floatingActionButton: floatingActionButton,
    );
  }

  Widget get floatingActionButton {
    return FloatingActionButton(
      child: Icon(Icons.archive_outlined),
      tooltip: S.of(context).event_collect_items,
      onPressed: () {
        if (!plan.enable) {
          showInformDialog(context, content: S.of(context).event_not_planned);
        } else {
          SimpleCancelOkDialog(
            title: Text(S.of(context).confirm),
            content: Text(S.of(context).event_collect_item_confirm),
            onTapOk: () {
              sumDict([db.curUser.items, event.getItems(plan)], inPlace: true);
              plan.enable = false;
              db.itemStat.updateEventItems();
              setState(() {});
            },
          ).showDialog(context);
        }
      },
    );
  }

  Widget _buildExtraItems(
      Map<String, String> data, Map<String, int> extraPlan) {
    List<Widget> children = [];
    data.forEach((itemKey, hint) {
      final controller = _controllers[itemKey];
      children.add(ListTile(
        leading:
            Item.iconBuilder(context: context, itemKey: itemKey, width: 48),
        title: Text(Item.localizedNameOf(itemKey)),
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
            decoration: InputDecoration(counterText: ''),
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

  void onTapIcon(String itemKey) {
    SplitRoute.push(context, ItemDetailPage(itemKey: itemKey));
  }

  @override
  void dispose() {
    super.dispose();
    _lotteryController.dispose();
    _controllers.values.forEach((c) => c.dispose());
  }
}
