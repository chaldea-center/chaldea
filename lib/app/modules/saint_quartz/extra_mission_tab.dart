import 'package:flutter/material.dart';

import 'package:chaldea/models/models.dart';
import 'package:chaldea/utils/utils.dart';
import '../../descriptors/cond_target_num.dart';

class ExtraMissionTab extends StatefulWidget {
  ExtraMissionTab({super.key});

  @override
  _ExtraMissionTabState createState() => _ExtraMissionTabState();
}

class _ExtraMissionTabState extends State<ExtraMissionTab> {
  SaintQuartzPlan get plan => db.curUser.saintQuartzPlan;

  @override
  Widget build(BuildContext context) {
    final missions = plan.extraMission?.missions ?? [];
    missions.sort2((e) => e.dispNo);
    final hasNoDate = missions.every((e) => e.startedAt == 0);
    return ListView.builder(
      itemCount: missions.length,
      itemBuilder: (context, index) {
        final mission = missions[index];
        List<Widget> rewards = [];
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
        final cond = mission.conds.firstWhereOrNull((cond) => cond.missionProgressType == MissionProgressType.clear);
        Widget title;
        final style = hasNoDate || plan.isInRange(mission.startedAt)
            ? null
            : TextStyle(
                color: Theme.of(context).textTheme.bodySmall?.color,
                fontStyle: FontStyle.italic,
              );
        if (cond == null) {
          title = Text('${mission.dispNo} - ${mission.name}', style: style, textScaleFactor: 0.8);
        } else {
          title = CondTargetNumDescriptor(
            condType: cond.condType,
            targetNum: cond.targetNum,
            targetIds: cond.targetIds,
            details: cond.details,
            leading: TextSpan(text: '${mission.dispNo} - '),
            style: style,
            textScaleFactor: 0.8,
          );
        }

        return SwitchListTile.adaptive(
          value: plan.extraMissions[mission.id] ?? false,
          title: title,
          subtitle: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                mission.name,
                style: Theme.of(context).textTheme.bodySmall,
                textScaleFactor: 0.9,
              ),
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
