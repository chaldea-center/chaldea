//@dart=2.12
import 'package:chaldea/components/components.dart';

Widget buildSwitchPlanButton(
    {required BuildContext context, ValueChanged? onChange}) {
  return IconButton(
    icon: Icon(Icons.list),
    tooltip: '规划 ${db.curUser.curSvtPlanNo + 1}',
    onPressed: () {
      showDialog(
        context: context,
        builder: (context) => SimpleDialog(
          title: Text('选择规划'),
          children: List.generate(db.curUser.servantPlans.length, (index) {
            return ListTile(
              title: Text('规划 ${index + 1}'),
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
    },
  );
}
