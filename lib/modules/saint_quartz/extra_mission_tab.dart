import 'package:chaldea/components/components.dart';

class ExtraMissionTab extends StatefulWidget {
  const ExtraMissionTab({Key? key}) : super(key: key);

  @override
  _ExtraMissionTabState createState() => _ExtraMissionTabState();
}

class _ExtraMissionTabState extends State<ExtraMissionTab> {
  SaintQuartzPlan get plan => db.curUser.saintQuartzPlan;

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: db.gameData.events.extraMasterMissions.map((mission) {
        List<Widget> rewards = [
          Text(
            mission.startedDateTime.toDateString(),
            textScaleFactor: 0.9,
            style: kMonoStyle,
          )
        ];
        mission.itemRewards.forEach((itemKey, count) {
          final item = db.gameData.items[itemKey];
          if (item != null) {
            rewards.add(Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Item.iconBuilder(
                    context: context,
                    itemKey: item.name,
                    width: 20,
                    jumpToDetail: false),
                Text('*$count'),
              ],
            ));
          }
        });
        return SwitchListTile.adaptive(
          value: plan.extraMissions[mission.id] ?? false,
          title: Text(
            mission.name,
            textScaleFactor: 0.8,
            style: plan.isInRange(mission.startedDateTime)
                ? null
                : TextStyle(
                    color: Theme.of(context).textTheme.caption?.color,
                    fontStyle: FontStyle.italic,
                  ),
          ),
          subtitle: Wrap(
            spacing: 4,
            runSpacing: 4,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: rewards,
          ),
          controlAffinity: ListTileControlAffinity.trailing,
          onChanged: (v) {
            setState(() {
              plan.extraMissions[mission.id] = v;
              plan.solve();
            });
          },
        );
      }).toList(),
    );
  }
}
