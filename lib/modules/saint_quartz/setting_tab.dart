import 'package:chaldea/components/components.dart';
import 'package:flutter/services.dart';

import 'common.dart';

class SQSettingTab extends StatefulWidget {
  const SQSettingTab({Key? key}) : super(key: key);

  @override
  _SQSettingTabState createState() => _SQSettingTabState();
}

class _SQSettingTabState extends State<SQSettingTab> {
  late ScrollController _scrollController;
  late TextEditingController _curSQController;
  late TextEditingController _curTicketController;
  late TextEditingController _curAppleController;
  late TextEditingController _accLoginController;
  late TextEditingController _eventDiffController;

  SaintQuartzPlan get plan => db.curUser.saintQuartzPlan;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _curSQController = TextEditingController(text: plan.curSQ.toString());
    _curTicketController =
        TextEditingController(text: plan.curTicket.toString());
    _curAppleController = TextEditingController(text: plan.curApple.toString());
    _accLoginController = TextEditingController(text: plan.accLogin.toString());
    _eventDiffController =
        TextEditingController(text: plan.eventDateDelta.toString());
  }

  @override
  void dispose() {
    super.dispose();
    _curSQController.dispose();
    _curTicketController.dispose();
    _accLoginController.dispose();
    _eventDiffController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      controller: _scrollController,
      children: [
        ListTile(
          title: Text(
              LocalizedText.of(chs: '持有圣晶石', jpn: '所持聖晶石', eng: 'Held SQ')),
          trailing: SizedBox(
            width: 60,
            child: TextField(
              controller: _curSQController,
              onChanged: (s) {
                plan.curSQ = int.tryParse(s) ?? plan.curSQ;
                update();
              },
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              textAlign: TextAlign.center,
            ),
          ),
        ),
        ListTile(
          title: Text(
              LocalizedText.of(chs: '持有呼符', jpn: '所持呼符', eng: 'Held Ticket')),
          trailing: SizedBox(
            width: 60,
            child: TextField(
              controller: _curTicketController,
              onChanged: (s) {
                plan.curTicket = int.tryParse(s) ?? plan.curTicket;
                update();
              },
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              textAlign: TextAlign.center,
            ),
          ),
        ),
        ListTile(
          title: Text(
              LocalizedText.of(chs: '持有苹果', jpn: '所持果実', eng: 'Held Apple')),
          trailing: SizedBox(
            width: 60,
            child: TextField(
              controller: _curAppleController,
              onChanged: (s) {
                plan.curApple = int.tryParse(s) ?? plan.curApple;
                update();
              },
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              textAlign: TextAlign.center,
            ),
          ),
        ),
        ListTile(
          title: Text(
              LocalizedText.of(chs: '起始日期', jpn: '開始日', eng: 'Start Date')),
          trailing: TextButton(
            onPressed: () async {
              final newDate = await showDatePicker(
                context: context,
                initialDate: plan.startDate,
                firstDate: DateTime(2015),
                lastDate: DateTime(2040),
              );
              if (newDate != null) {
                plan.startDate = newDate;
                update();
              }
            },
            child: Text(plan.startDate.toDateString()),
          ),
        ),
        ListTile(
          title:
              Text(LocalizedText.of(chs: '结束日期', jpn: '最終日', eng: 'End Date')),
          trailing: TextButton(
            onPressed: () async {
              final newDate = await showDatePicker(
                context: context,
                initialDate: plan.endDate,
                firstDate: DateUtils.addDaysToDate(plan.startDate, 30),
                lastDate: DateTime(2041),
              );
              if (newDate != null) {
                plan.endDate = newDate;
                update();
              }
            },
            child: Text(plan.endDate.toDateString()),
          ),
        ),
        ListTile(
          title: Text(SaintLocalized.accLogin),
          trailing: SizedBox(
            width: 60,
            child: TextField(
              controller: _accLoginController,
              onChanged: (s) {
                plan.accLogin = int.tryParse(s) ?? plan.accLogin;
                update();
              },
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              textAlign: TextAlign.center,
            ),
          ),
        ),
        ListTile(
          title: Text(SaintLocalized.continuousLogin),
          trailing: DropdownButton<int>(
            isExpanded: false,
            value: plan.continuousLogin,
            items: List.generate(
              7,
              (index) => DropdownMenuItem(
                child: Text((index + 1).toString()),
                value: index + 1,
              ),
            ),
            onChanged: (v) {
              plan.continuousLogin = v ?? plan.continuousLogin;
              update();
            },
          ),
        ),
        ListTile(
          title: Text(LocalizedText.of(
              chs: '与日服的时间差(天)',
              jpn: '日本サーバーとの日付の違い(日)',
              eng: 'Date diff with JP server(Day)')),
          trailing: SizedBox(
            width: 60,
            child: TextField(
              controller: _eventDiffController,
              onChanged: (s) {
                plan.eventDateDelta = int.tryParse(s) ?? plan.eventDateDelta;
                update();
              },
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              textAlign: TextAlign.center,
            ),
          ),
        ),
        SwitchListTile.adaptive(
          value: plan.weeklyMission,
          onChanged: (v) {
            plan.weeklyMission = v;
            update();
          },
          title: Text(LocalizedText.of(
              chs: '周常任务', jpn: 'ウィークリーミッション', eng: 'Weekly Mission')),
          subtitle: Text(LocalizedText.of(
              chs: '21圣晶片=3圣晶石',
              jpn: '21聖晶片=3聖晶石',
              eng: '21 Fragments = 3 Quartzs')),
          controlAffinity: ListTileControlAffinity.trailing,
        ),
        Card(
          child: Padding(
            padding: EdgeInsets.all(12),
            child: Text(
              LocalizedText.of(
                  chs: """仅计算连续登陆奖励、每月魔力棱镜商店呼符、限时活动的关卡通关报酬;
特殊御主任务奖励在最后一天结算;
其余纪念活动、转发达标奖励、维护补偿等直接发放到礼物盒中的奖励均未计算、且无法自动统计。""",
                  jpn: """連続ログイン報酬、毎月のプリスマショップの呼符、および期間限定イベントのクエスト報酬のみが計算されます。
エクストラマスターミッション報酬は最終日に決済されます。
その他の記念イベント、メンテナンス補償、メールボックスに直接配布されるものは計算されず、自動的に数えられないからです。""",
                  eng:
                      """Only the continuous login rewards, monthly prism store tickets, and quest rewards of limited events are calculated.
Extra master mission rewards are settled on the last day.
The other campaign events, maintenance compensation, and other rewards directly sent to the gift box are not calculated because cannot be automatically counted."""),
              style: Theme.of(context).textTheme.caption,
            ),
          ),
        )
      ],
    );
  }

  void update() {
    setState(() {
      plan.solve();
    });
  }
}
