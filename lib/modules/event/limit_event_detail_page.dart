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
  TextInputsManager<String> manager = TextInputsManager();

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
        manager.components.add(InputComponent(
            data: name,
            controller:
                TextEditingController(text: plan.extra[name]?.toString()),
            focusNode: FocusNode()));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    int grailNum = event.grail + (plan.rerun ? 0 : event.grail2crystal),
        crystalNum = event.crystal + (plan.rerun ? event.grail2crystal : 0);
    List<Widget> children = [];
    if (event.grail2crystal > 0) {
      children.add(SwitchListTile.adaptive(
        title: Text('复刻活动'),
        subtitle: Text('圣杯替换为传承结晶 ${event.grail2crystal} 个'),
        value: plan.rerun,
        onChanged: (v) => setState(() => plan.rerun = v),
      ));
    }
    if (event.lottery != null) {
      children
        ..add(CustomTile(
          title: Text('无限池共计'),
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
                inputFormatters: [
                  WhitelistingTextInputFormatter(RegExp(r'\d'))
                ],
                onChanged: (v) {
                  plan.lottery = int.tryParse(v) ?? 0;
                },
              )),
        ))
        ..add(buildClassifiedItemList(event.lottery, onTap: onTapIcon));
    }
    if (grailNum + crystalNum > 0 || event.items != null) {
      children
        ..add(CustomTile(title: Center(child: Text('商店&任务&点数'))))
        ..add(buildClassifiedItemList(
            {'圣杯': grailNum, '传承结晶': crystalNum}
              ..addAll(event.items)
              ..removeWhere((k, v) => v <= 0),
            onTap: onTapIcon));
    }
    if (event.extra != null) {
      children
        ..add(CustomTile(title: Center(child: Text('Extra items'))))
        ..add(_buildExtraItems(event.extra, plan.extra));
    }
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(),
        title: AutoSizeText(widget.name ?? '', maxLines: 1),
      ),
      body: ListView(
        children: divideTiles(children,
            divider: Divider(
              thickness: 1,
            )),
      ),
    );
  }

  Widget _buildExtraItems(
      Map<String, String> data, Map<String, int> huntingPlan) {
    manager.resetFocusList();
    List<Widget> children = [];
    data.forEach((itemKey, hint) {
      final component = manager.getComponentByData(itemKey);
      manager.addObserver(component);
      children.add(CustomTile(
        leading: GestureDetector(
          onTap: () => onTapIcon(itemKey),
          child: Image(image: db.getIconImage(itemKey), height: 110 * 0.5),
        ),
        title: Text(itemKey),
        subtitle: Text(hint),
        titlePadding: EdgeInsets.fromLTRB(16, 0, 16, 0),
        trailing: SizedBox(
          width: 45,
          child: EnsureVisibleWhenFocused(
              child: TextField(
                maxLength: 4,
                controller: component.controller,
                focusNode: component.focusNode,
                textAlign: TextAlign.center,
                keyboardType: TextInputType.number,
                textInputAction: TextInputAction.next,
                inputFormatters: [NumberInputFormatter()],
                decoration: InputDecoration(counterText: ''),
                onChanged: (v) {
                  if (huntingPlan != null) {
                    int value = int.tryParse(v) ?? 0;
                    huntingPlan[itemKey] = value;
                  }
                },
                onTap: () => component.onTap(context),
                onSubmitted: (_) {
                  manager.moveNextFocus(context, component);
                },
              ),
              focusNode: component.focusNode),
        ),
      ));
    });
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: children,
    );
  }

  void onTapIcon(String itemKey) {
    SplitRoute.push(context, builder: (context) => ItemDetailPage(itemKey));
  }

  @override
  void dispose() {
    super.dispose();
    _lotteryController?.dispose();
    manager.dispose();
  }
}
