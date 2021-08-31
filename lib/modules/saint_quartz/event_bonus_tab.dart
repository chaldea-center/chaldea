import 'package:chaldea/components/components.dart';
import 'package:chaldea/modules/event/events_page.dart';
import 'package:flutter/services.dart';

class EventBonusTab extends StatefulWidget {
  const EventBonusTab({Key? key}) : super(key: key);

  @override
  _EventBonusTabState createState() => _EventBonusTabState();
}

class _EventBonusTabState extends State<EventBonusTab> {
  late TextEditingController _textEditingController;

  SaintQuartzPlan get _plan => db.curUser.saintQuartzPlan;

  @override
  void initState() {
    super.initState();
    _textEditingController =
        TextEditingController(text: _plan.eventDateDelta.toString());
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.symmetric(vertical: 16),
      children: [
        ListTile(
          title: Text('时间差'),
          trailing: SizedBox(
            width: 60,
            child: TextField(
              controller: _textEditingController,
              onChanged: (s) {
                setState(() {
                  _plan.eventDateDelta =
                      int.tryParse(s) ?? _plan.eventDateDelta;
                });
              },
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              textAlign: TextAlign.center,
            ),
          ),
        ),
        ListTile(
          title: Text(Item.lNameOf(Items.quartz)),
          trailing:
              Text((db.itemStat.eventItems[Items.quartz] ?? 0).toString()),
        ),
        ListTile(
          title: Text(Item.lNameOf(Items.summonTicket)),
          trailing: Text(
              (db.itemStat.eventItems[Items.summonTicket] ?? 0).toString()),
        ),
        Center(
          child: ElevatedButton(
            onPressed: () {
              SplitRoute.push(context, EventListPage(), detail: false);
            },
            child: Text('GOTO EVENTS'),
          ),
        ),
        SFooter(LocalizedText.of(
          chs: '仅计算了关卡通关奖励，不包含如纪念活动等的赠送的圣晶石',
          jpn: 'クエスト報酬のみが計算され、記念イベントなどの聖晶石の贈り物は含まれていません。',
          eng:
              'Only quest rewards are included, and the gift Saint Quartz such as campaign events is not included.',
        ))
      ],
    );
  }
}
