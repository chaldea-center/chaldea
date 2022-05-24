import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:chaldea/app/tools/localized_base.dart';
import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/models/models.dart';
import 'package:chaldea/utils/utils.dart';
import 'common.dart';

class SQSettingTab extends StatefulWidget {
  SQSettingTab({Key? key}) : super(key: key);

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
    const _decoration = InputDecoration(counter: SizedBox());
    return ListView(
      controller: _scrollController,
      children: [
        ListTile(
          title: Text(LocalizedText.of(
              chs: '持有圣晶石', jpn: '所持聖晶石', eng: 'Held SQ', kor: '가지고 있는 성정석')),
          trailing: SizedBox(
            width: 60,
            child: TextFormField(
              controller: _curSQController,
              onChanged: (s) {
                plan.curSQ = int.tryParse(s) ?? plan.curSQ;
                update();
              },
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              textAlign: TextAlign.center,
              maxLength: 4,
              decoration: _decoration,
            ),
          ),
        ),
        ListTile(
          title: Text(LocalizedText.of(
              chs: '持有呼符', jpn: '所持呼符', eng: 'Held Ticket', kor: '가지고 있는 호부')),
          trailing: SizedBox(
            width: 60,
            child: TextFormField(
              controller: _curTicketController,
              onChanged: (s) {
                plan.curTicket = int.tryParse(s) ?? plan.curTicket;
                update();
              },
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              textAlign: TextAlign.center,
              maxLength: 4,
              decoration: _decoration,
            ),
          ),
        ),
        ListTile(
          title: Text(LocalizedText.of(
              chs: '持有苹果', jpn: '所持果実', eng: 'Held Apple', kor: '가지고 있는 사과')),
          trailing: SizedBox(
            width: 60,
            child: TextFormField(
              controller: _curAppleController,
              onChanged: (s) {
                plan.curApple = int.tryParse(s) ?? plan.curApple;
                update();
              },
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              textAlign: TextAlign.center,
              maxLength: 4,
              decoration: _decoration,
            ),
          ),
        ),
        ListTile(
          title: Text(LocalizedText.of(
              chs: '起始日期', jpn: '開始日', eng: 'Start Date', kor: '시작일')),
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
          title: Text(LocalizedText.of(
              chs: '结束日期', jpn: '最終日', eng: 'End Date', kor: '마지막 일')),
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
            child: TextFormField(
              controller: _accLoginController,
              onChanged: (s) {
                plan.accLogin = int.tryParse(s) ?? plan.accLogin;
                update();
              },
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              textAlign: TextAlign.center,
              maxLength: 4,
              decoration: _decoration,
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
                value: index + 1,
                child: Text((index + 1).toString()),
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
              eng: 'Date diff with JP server(Day)',
              kor: '일본 서버와의 날짜 차이(일)')),
          trailing: SizedBox(
            width: 60,
            child: TextFormField(
              controller: _eventDiffController,
              onChanged: (s) {
                plan.eventDateDelta = int.tryParse(s) ?? plan.eventDateDelta;
                update();
              },
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              textAlign: TextAlign.center,
              maxLength: 4,
              decoration: _decoration,
            ),
          ),
        ),
        SwitchListTile.adaptive(
          value: plan.weeklyMission,
          onChanged: (v) {
            plan.weeklyMission = v;
            update();
          },
          title: Text(S.current.master_mission_weekly),
          subtitle: Text(S.current.sq_fragment_convert),
          controlAffinity: ListTileControlAffinity.trailing,
        ),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Text(
              LocalizedText.of(
                chs: """实际可获得量远高于计算值：
仅计算连续登陆奖励、每月魔力棱镜商店呼符、限时活动的关卡通关报酬;
特殊御主任务奖励在最后一天结算;
其余纪念活动、转发达标奖励、维护补偿等直接发放到礼物盒中的奖励均未计算、且无法自动统计。""",
                jpn: """実際に取得したリソースは、計算よりもはるかに多いはずです。
連続ログイン報酬、毎月のプリスマショップの呼符、および期間限定イベントのクエスト報酬のみが計算されます。
エクストラマスターミッション報酬は最終日に決済されます。
その他の記念イベント、メンテナンス補償、メールボックスに直接配布されるものは計算されず、自動的に数えられないからです。""",
                eng:
                    """Actual obtained resources should be MUCH MORE than calculated.

Only the continuous login rewards, monthly prism store tickets, and quest rewards of limited events are calculated.

Extra master mission rewards are settled on the last day.

The other campaign events, maintenance compensation, and other rewards directly sent to the gift box are not calculated because cannot be automatically counted.""",
                kor: """실제 획득된 자원은 계산된 것보다 훨씬 더 많아야 합니다.
연속 로그인 보상, 월별 마나 프리즘 상점 호부, 한정 이벤트의 퀘스트 보상만 계산됩니다.
엑스트라 마스터 미션 보상은 마지막 날에 추가로 지급됩니다.
기타 캠페인 이벤트, 유지 보수, 기타 기프트 박스로 직접 발송되는 보상은 자동 집계가 불가능하여 계산되지 않습니다. """,
              ),
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
