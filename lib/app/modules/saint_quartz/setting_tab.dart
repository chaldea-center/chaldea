import 'package:flutter/services.dart';

import 'package:flutter_easyloading/flutter_easyloading.dart';

import 'package:chaldea/app/tools/localized_base.dart';
import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/models/models.dart';
import 'package:chaldea/utils/utils.dart';
import 'package:chaldea/widgets/widgets.dart';
import 'common.dart';

class SQSettingTab extends StatefulWidget {
  SQSettingTab({super.key});

  @override
  _SQSettingTabState createState() => _SQSettingTabState();
}

class _SQSettingTabState extends State<SQSettingTab> {
  late final ScrollController _scrollController = ScrollController();
  late final TextEditingController _curSQController = TextEditingController(text: plan.curSQ.toString());
  late final TextEditingController _curTicketController = TextEditingController(text: plan.curTicket.toString());
  late final TextEditingController _curAppleController = TextEditingController(text: plan.curApple.toString());
  late final TextEditingController _accLoginController = TextEditingController(text: plan.accLogin.toString());

  SaintQuartzPlan get plan => db.curUser.saintQuartzPlan;

  DailyBonusData? get dailyBonusData => db.runtimeData.dailyBonusData;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now().add(Duration(days: 1));
    if (plan.endDate.isAfter(now)) {
      plan.endDate = now;
    }
    if (plan.startDate.isAfter(plan.endDate)) {
      plan.startDate = plan.endDate;
    }
    db.runtimeData.loadDailyBonusData().then((v) => update());
  }

  @override
  void dispose() {
    super.dispose();
    _curSQController.dispose();
    _curTicketController.dispose();
    _curAppleController.dispose();
    _accLoginController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const _decoration = InputDecoration(counter: SizedBox(), isDense: true);
    return ListView(
      controller: _scrollController,
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Text(
              LocalizedText.of(chs: '均为日服时间', jpn: null, eng: 'All are JP time now'),
              textAlign: TextAlign.center,
            ),
          ),
        ),
        ListTile(
          dense: true,
          title: Text('${S.current.dataset_version} (${S.current.login_bonus})'),
          subtitle: Text(dailyBonusData?.lastPresentTime?.sec2date().toStringShort(omitSec: true) ?? 'Not Found'),
          trailing: IconButton(
            onPressed: () {
              SimpleCancelOkDialog(
                title: Text(S.current.update),
                onTapOk: () async {
                  await showEasyLoading(() => db.runtimeData.loadDailyBonusData(refresh: true));
                  update();
                },
              ).showDialog(context);
            },
            icon: const Icon(Icons.replay),
            tooltip: S.current.update,
          ),
        ),
        DividerWithTitle(title: S.current.options),
        SwitchListTile.adaptive(
          dense: true,
          value: plan.campaignLoginBonus,
          onChanged: (v) {
            plan.campaignLoginBonus = v;
            update();
          },
          title: Text('${S.current.login_bonus}(${S.current.event_campaign})'),
          subtitle: Text(
            'JP ${[dailyBonusData?.info.start, dailyBonusData?.lastPresentTime].map((e) => e?.sec2date().toDateString() ?? '???').join(' ~ ')}',
          ),
          controlAffinity: ListTileControlAffinity.trailing,
        ),
        SwitchListTile.adaptive(
          dense: true,
          value: plan.weeklyMission,
          onChanged: (v) {
            plan.weeklyMission = v;
            update();
          },
          title: Text(S.current.master_mission_weekly),
          subtitle: Text(S.current.sq_fragment_convert),
          controlAffinity: ListTileControlAffinity.trailing,
        ),
        SwitchListTile.adaptive(
          dense: true,
          value: plan.limitedMission,
          onChanged: (v) {
            plan.limitedMission = v;
            update();
          },
          title: Text('${S.current.master_mission} (Limited)'),
          controlAffinity: ListTileControlAffinity.trailing,
        ),
        const DividerWithTitle(indent: 16),
        ListTile(
          dense: true,
          title: Text(LocalizedText.of(chs: '起始日期', jpn: '開始日', eng: 'Start Date', kor: '시작일')),
          trailing: TextButton(
            onPressed: () async {
              final newDate = await showDatePicker(
                context: context,
                initialDate: plan.startDate,
                firstDate: DateTime(2015),
                lastDate: DateTime(2040),
              );
              if (newDate == null) return;
              if (newDate.isAfter(DateTime.now().add(const Duration(days: 1)))) {
                EasyLoading.showError(
                  LocalizedText.of(
                    chs: '此为日服时间，结束日期需不晚于今日',
                    jpn: null,
                    eng: 'This is JP date, end time should not be after today.',
                  ),
                );
                return;
              }

              plan.startDate = newDate;
              if (newDate.isAfter(plan.endDate)) {
                plan.endDate = newDate.add(const Duration(days: 365));
              }
              update();
            },
            child: Text(plan.startDate.toDateString()),
          ),
        ),
        ListTile(
          dense: true,
          title: Text(LocalizedText.of(chs: '结束日期', jpn: '最終日', eng: 'End Date', kor: '마지막 일')),
          trailing: TextButton(
            onPressed: () async {
              final newDate = await showDatePicker(
                context: context,
                initialDate: plan.endDate,
                firstDate: DateUtils.addDaysToDate(plan.startDate, 30),
                lastDate: DateTime(2041),
              );
              if (newDate == null) return;
              if (newDate.isAfter(DateTime.now().add(const Duration(days: 1)))) {
                EasyLoading.showError(
                  LocalizedText.of(
                    chs: '此为日服时间，结束日期需不晚于今日',
                    jpn: null,
                    eng: 'This is JP date, end time should not be after today.',
                  ),
                );
                return;
              }

              plan.endDate = newDate;
              if (newDate.isBefore(plan.startDate)) {
                plan.startDate = newDate.subtract(const Duration(days: 365));
              }
              update();
            },
            child: Text(plan.endDate.toDateString()),
          ),
        ),
        DividerWithTitle(title: 'User status at ${plan.startDate.toDateString()}'),
        ListTile(
          dense: true,
          title: Text(LocalizedText.of(chs: '持有圣晶石', jpn: '所持聖晶石', eng: 'Held SQ', kor: '가지고 있는 성정석')),
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
          dense: true,
          title: Text(LocalizedText.of(chs: '持有呼符', jpn: '所持呼符', eng: 'Held Ticket', kor: '가지고 있는 호부')),
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
          dense: true,
          title: Text(LocalizedText.of(chs: '持有苹果', jpn: '所持果実', eng: 'Held Apple', kor: '가지고 있는 사과')),
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
        const DividerWithTitle(indent: 16),
        ListTile(
          dense: true,
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
          dense: true,
          title: Text(SaintLocalized.continuousLogin),
          trailing: DropdownButton<int>(
            isExpanded: false,
            value: plan.continuousLogin,
            items: List.generate(7, (index) => DropdownMenuItem(value: index + 1, child: Text((index + 1).toString()))),
            onChanged: (v) {
              plan.continuousLogin = v ?? plan.continuousLogin;
              update();
            },
          ),
        ),
        DividerWithTitle(title: S.current.display_setting),
        SwitchListTile.adaptive(
          dense: true,
          value: plan.favoriteSummonOnly,
          onChanged: (v) {
            plan.favoriteSummonOnly = v;
            update();
          },
          title: Text(LocalizedText.of(chs: '仅显示已关注卡池', jpn: null, eng: 'Show favorite summons only')),
          controlAffinity: ListTileControlAffinity.trailing,
        ),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Text(
              LocalizedText.of(
                chs: """各日期和奖励可能由于时区不同和0点结算/4点结算不同的原因存在±1天的误差.
实际可获得量应高于计算值：
目前计算：连续登陆奖励、日服2024/1/16以后的纪念活动等登陆奖励、每月魔力棱镜商店5呼符、限时活动的关卡通关报酬、;
纪念活动登陆奖励数据的统计可能由于各种因素造成统计中断/缺失；可能包含不同用户不同的一次性奖励补发（如周年更新灵基再临奖励带来的补发）;
特殊御主任务奖励众多且多分阶段开放没有计入。""",
                jpn: null,
                eng: """Date time may have ±1 day offset due to timezone and different settlement time (JP 0AM/4AM).

Actual obtained resources should be more than predicated.

Current calculated: continuous login bonus, campaign login bonus (started from JP 2024/1/16), monthly 5 prism store tickets, quest rewards from limited events.

Campaign login bonus may lack some days or even be interrupted due to some external reasons. Some one-time rewards may differ from each user (Such as ascension rewards when anniversary update). 

Extra master mission rewards are not included.""",
                kor: null,
              ),
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
        ),
        const Card(
          child: Padding(padding: EdgeInsets.all(12), child: Text('Just for fun', textAlign: TextAlign.center)),
        ),
      ],
    );
  }

  void update() {
    if (mounted) setState(() {});
    plan.validate();
    EasyDebounce.debounce('sq_plan_solve', const Duration(seconds: 1), () {
      plan.solve();
    });
  }
}
