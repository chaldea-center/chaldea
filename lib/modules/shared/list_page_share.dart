import 'package:chaldea/components/components.dart';

Widget buildSwitchPlanButton(
    {required BuildContext context, ValueChanged<int>? onChange}) {
  return IconButton(
    onPressed: () {
      FocusScope.of(context).unfocus();
      onSwitchPlan(context: context, onChange: onChange);
    },
    tooltip: '${S.current.plan_title} ${db.curUser.curSvtPlanNo + 1}',
    icon: Center(
      child: Stack(
        alignment: Alignment.bottomRight,
        children: [
          Icon(Icons.list),
          ImageWithText.paintOutline(
            text: (db.curUser.curSvtPlanNo + 1).toString(),
            shadowSize: 5,
            shadowColor: Theme.of(context).primaryColor,
          )
        ],
      ),
    ),
  );
}

void onSwitchPlan(
    {required BuildContext context, ValueChanged<int>? onChange}) {
  showDialog(
    context: context,
    builder: (context) => SimpleDialog(
      title: Text(S.of(context).select_plan),
      children: List.generate(db.curUser.servantPlans.length, (index) {
        return ListTile(
          title: Text(S.of(context).plan_x(index + 1)),
          selected: index == db.curUser.curSvtPlanNo,
          onTap: () {
            Navigator.of(context).pop();
            if (onChange != null) {
              onChange(index);
            }
          },
        );
      }),
    ),
  );
}
