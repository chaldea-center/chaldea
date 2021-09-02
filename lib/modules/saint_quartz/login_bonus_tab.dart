import 'package:chaldea/components/components.dart';

import 'common.dart';

class LoginBonusTab extends StatefulWidget {
  const LoginBonusTab({Key? key}) : super(key: key);

  @override
  _LoginBonusTabState createState() => _LoginBonusTabState();
}

class _LoginBonusTabState extends State<LoginBonusTab> {
  SaintQuartzPlan get plan => db.curUser.saintQuartzPlan;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Widget _cell({required String text, int flex = 1, TextStyle? style}) {
      return Expanded(
        flex: flex,
        child: Text(text,
            textAlign: TextAlign.center,
            style: style?.copyWith(fontFamily: kMonoFont) ?? kMonoStyle),
      );
    }

    return Column(
      children: [
        topAccordion,
        Container(
          color: Theme.of(context).cardColor,
          padding: EdgeInsets.symmetric(vertical: 8, horizontal: 8),
          child: Row(
            children: [
              _cell(text: SaintLocalized.date, flex: 2),
              _cell(text: SaintLocalized.accLoginShort),
              _cell(text: SaintLocalized.continuousLoginShort),
              _cell(text: Items.quartz),
              _cell(text: Items.summonTicket),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: EdgeInsets.fromLTRB(8, 0, 8, 8),
            itemCount: 365 * 2 + 30,
            itemBuilder: (context, index) {
              final date = plan.startDate.add(Duration(days: index));
              int accLogin = plan.accLogin + index;
              int conLogin = (plan.continuousLogin + index - 1) % 7 + 1;
              final r = _cQ(index);
              final row = Row(
                children: [
                  _cell(text: date.toDateString(), flex: 2),
                  _cell(
                    text: accLogin.toString(),
                    style: accLogin % 50 == 0
                        ? TextStyle(color: Theme.of(context).errorColor)
                        : null,
                  ),
                  _cell(text: conLogin.toString()),
                  _cell(text: r[0].toString()),
                  _cell(text: r[1].toString()),
                ],
              );
              return Container(
                color: index.isOdd
                    ? Theme.of(context).highlightColor.withAlpha(50)
                    : null,
                padding: EdgeInsets.symmetric(vertical: 2),
                child: row,
              );
            },
          ),
        )
      ],
    );
  }

  Widget get topAccordion {
    return SimpleAccordion(
      headerBuilder: (context, _) => ListTile(
        title: Text('${plan.startDate.toDateString()}'),
        subtitle: Text('${SaintLocalized.accLogin}: ${plan.accLogin},'
            '${SaintLocalized.continuousLogin}: ${plan.continuousLogin}'),
      ),
      contentBuilder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            title: Text(SaintLocalized.startDate),
            trailing: Text(plan.startDate.toDateString()),
            onTap: () async {
              final a = await showDatePicker(
                context: context,
                initialDate: plan.startDate,
                firstDate: DateTime(2015),
                lastDate: DateTime(2040),
              );
              if (a != null) {
                if (mounted)
                  setState(() {
                    plan.startDate = a;
                  });
              }
            },
          ),
        ],
      ),
    );
  }

  List<int> _cQ(int days) {
    // int cl = continuousLogin + days;
    // int tl = totalLogin + days;
    // 连续登陆
    int weeks = days ~/ 7;
    int q = weeks * 4;
    int p = weeks;
    for (int i = plan.continuousLogin + weeks * 7 + 1;
        i <= plan.continuousLogin + days;
        i++) {
      int c = (i - 1) % 7 + 1;
      if (c == 2 || c == 4)
        q += 1;
      else if (c == 6)
        q += 2;
      else if (c == 7) p += 1;
    }
    // 50天
    q += days ~/ 50 * 30;
    for (int i = plan.accLogin + days ~/ 50 * 50 + 1;
        i <= plan.accLogin + days;
        i++) {
      if (i % 50 == 0) q += 30;
    }
    return [q, p];
  }
}
