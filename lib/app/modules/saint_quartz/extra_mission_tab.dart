import 'package:flutter/material.dart';

import 'package:chaldea/models/models.dart';
import 'package:chaldea/utils/utils.dart';
import '../../descriptors/mission_conds.dart';

class ExtraMissionTab extends StatefulWidget {
  ExtraMissionTab({Key? key}) : super(key: key);

  @override
  _ExtraMissionTabState createState() => _ExtraMissionTabState();
}

class _ExtraMissionTabState extends State<ExtraMissionTab> {
  SaintQuartzPlan get plan => db.curUser.saintQuartzPlan;

  @override
  Widget build(BuildContext context) {
    final missions = plan.extraMission?.missions ?? [];
    missions.sort2((e) => e.dispNo);
    return ListView.builder(
      itemCount: missions.length,
      itemBuilder: (context, index) {
        final mission = missions[index];
        List<Widget> rewards = [
          Text(
            [
              mission.startedAt.sec2date().toDateString() + '(JP)',
              DateUtils.addDaysToDate(
                      mission.startedAt.sec2date(), plan.eventDateDelta)
                  .toDateString()
            ].join('\n'),
            textScaleFactor: 0.9,
            style: kMonoStyle,
          ),
        ];
        for (final gift in mission.gifts) {
          final item = db.gameData.items[gift.objectId];
          if (item != null) {
            rewards.add(Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Item.iconBuilder(
                  context: context,
                  item: item,
                  width: 20,
                  jumpToDetail: false,
                ),
                Text('*${gift.num}'),
              ],
            ));
          }
        }
        return SwitchListTile.adaptive(
          value: plan.extraMissions[mission.id] ?? false,
          title: Text(
            '${mission.dispNo} - ${mission.name}',
            textScaleFactor: 0.8,
            style: plan.isInRange(mission.startedAt)
                ? null
                : TextStyle(
                    color: Theme.of(context).textTheme.caption?.color,
                    fontStyle: FontStyle.italic,
                  ),
          ),
          subtitle: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              MissionCondsDescriptor(mission: mission, onlyShowClear: true),
              Wrap(
                spacing: 4,
                runSpacing: 4,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: rewards,
              )
            ],
          ),
          controlAffinity: ListTileControlAffinity.trailing,
          onChanged: (v) {
            setState(() {
              plan.extraMissions[mission.id] = v;
              plan.solve();
            });
          },
        );
      },
    );
  }
}
