import 'package:auto_size_text/auto_size_text.dart';
import 'package:chaldea/components/components.dart';
import 'package:chaldea/modules/item/item_detail_page.dart';
import 'package:chaldea/modules/shared/item_related_builder.dart';
import 'package:flutter/services.dart';

class LimitEventDetailPage extends StatefulWidget {
  final String name;

  const LimitEventDetailPage({Key key, this.name}) : super(key: key);

  @override
  _LimitEventDetailPageState createState() => _LimitEventDetailPageState();
}

class _LimitEventDetailPageState extends State<LimitEventDetailPage> {
  LimitEvent event;
  LimitEventPlan plan;
  TextEditingController _lotteryController;

  Map<String, TextEditingController> _controllers = {};

  @override
  void initState() {
    super.initState();
    event = db.gameData.events.limitEvents[widget.name] ??
        LimitEvent(name: 'empty event');
    plan = db.curUser.events.limitEvents
        .putIfAbsent(event.name, () => LimitEventPlan());
    if (event.lottery != null) {
      _lotteryController = TextEditingController(text: plan.lottery.toString());
    }
    if (event.extra != null) {
      for (var name in event.extra.keys) {
        _controllers[name] =
            TextEditingController(text: plan.extra[name]?.toString());
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> children = [];
    // 复刻
    int grailNum = event.grail + (plan.rerun ? 0 : event.grail2crystal),
        crystalNum = event.crystal + (plan.rerun ? event.grail2crystal : 0);
    if (event.grail2crystal > 0) {
      children.add(SwitchListTile.adaptive(
        title: Text('复刻活动'),
        subtitle: Text('圣杯替换为传承结晶 ${event.grail2crystal} 个'),
        value: plan.rerun,
        onChanged: (v) => setState(() => plan.rerun = v),
      ));
    }

    // 无限池
    if (event.lottery?.isNotEmpty == true) {
      children
        ..add(ListTile(
          title: Text(event.lotteryLimit > 0 ? '有限池' : '无限池'),
          subtitle: Text(
              event.lotteryLimit > 0 ? '最多${event.lotteryLimit}池' : '共计池数'),
          trailing: SizedBox(
              width: 80,
              child: TextField(
                maxLength: 4,
                textAlign: TextAlign.center,
                keyboardType: TextInputType.number,
                scrollPadding: EdgeInsets.zero,
                decoration: InputDecoration(
                  counterText: '',
                  suffixText: '池',
                  isDense: true,
                ),
                controller: _lotteryController,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                onChanged: (v) {
                  plan.lottery = int.tryParse(v) ?? 0;
                },
              )),
        ))
        ..add(buildClassifiedItemList(
            context: context, data: event.lottery, onTap: onTapIcon));
    }

    // 商店任务点数
    if (grailNum + crystalNum > 0 || event.items?.isNotEmpty == true) {
      final Map<String, int> items = Map.from(event.items)
        ..addAll({'圣杯': grailNum, '传承结晶': crystalNum})
        ..removeWhere((key, value) => value <= 0);
      children
        ..add(ListTile(title: Text('商店&任务&点数')))
        ..add(buildClassifiedItemList(
            context: context, data: items, onTap: onTapIcon));
    }

    // 狩猎 无限池终本掉落等
    if (event.extra?.isNotEmpty == true) {
      children
        ..add(ListTile(title: Text('Extra items')))
        ..add(_buildExtraItems(event.extra, plan.extra));
    }
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(),
        title: AutoSizeText(widget.name ?? '', maxLines: 1),
        actions: [
          IconButton(
            icon: Icon(Icons.archive_outlined),
            tooltip: '收取素材',
            onPressed: () {
              if (plan?.enable != true) {
                showInformDialog(context, content: '活动未列入规划');
              } else {
                SimpleCancelOkDialog(
                  title: Text('确定收取素材'),
                  content: Text('所有素材添加到素材仓库，并将该活动移出规划'),
                  onTapOk: () {
                    sumDict([db.curUser.items, event.getItems(plan)],
                        inPlace: true);
                    plan.enable = false;
                    db.itemStat.updateEventItems();
                    setState(() {});
                  },
                ).show(context);
              }
            },
          ),
        ],
      ),
      body: ListView(
        children: divideTiles(children),
      ),
    );
  }

  Widget _buildExtraItems(
      Map<String, String> data, Map<String, int> extraPlan) {
    List<Widget> children = [];
    data.forEach((itemKey, hint) {
      final controller = _controllers[itemKey];
      children.add(ListTile(
        leading: GestureDetector(
          onTap: () => onTapIcon(itemKey),
          child: Image(image: db.getIconImage(itemKey), height: 110 * 0.5),
        ),
        title: Text(itemKey),
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
              if (extraPlan != null) {
                extraPlan[itemKey] = int.tryParse(v) ?? 0;
              }
            },
            onSubmitted: (_) {},
            onEditingComplete: () {
              FocusScope.of(context).nextFocus();
            },
          ),
        ),
      ));
    });
    return TileGroup(children: children);
  }

  void onTapIcon(String itemKey) {
    SplitRoute.push(
      context: context,
      builder: (context, _) => ItemDetailPage(itemKey),
    );
  }

  @override
  void dispose() {
    super.dispose();
    _lotteryController?.dispose();
    _controllers.values.forEach((c) => c.dispose());
  }
}
