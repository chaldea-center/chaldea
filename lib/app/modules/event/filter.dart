import 'package:flutter/material.dart';

import 'package:chaldea/generated/l10n.dart';
import '../../../models/models.dart';
import '../common/filter_group.dart';
import '../common/filter_page_base.dart';

class EventFilterPage extends FilterPage<EventFilterData> {
  const EventFilterPage({
    super.key,
    required super.filterData,
    super.onChanged,
  });

  @override
  _EventFilterPageState createState() => _EventFilterPageState();
}

class _EventFilterPageState
    extends FilterPageState<EventFilterData, EventFilterPage> {
  @override
  Widget build(BuildContext context) {
    return buildAdaptive(
      title: Text(S.current.filter, textScaleFactor: 0.8),
      actions: getDefaultActions(onTapReset: () {
        filterData.reset();
        update();
      }),
      content: getListViewBody(children: [
        SwitchListTile.adaptive(
          value: filterData.showOutdated,
          title: Text(S.current.show_outdated),
          onChanged: (v) {
            filterData.showOutdated = v;
            update();
          },
          controlAffinity: ListTileControlAffinity.trailing,
        ),
        SwitchListTile.adaptive(
          value: filterData.showEmpty,
          title: Text(S.current.show_empty_event),
          onChanged: (v) {
            filterData.showEmpty = v;
            update();
          },
          controlAffinity: ListTileControlAffinity.trailing,
        ),
        FilterGroup<EventCustomType>(
          title: Text(S.current.general_type),
          options: EventCustomType.values,
          values: filterData.type,
          optionBuilder: (v) {
            switch (v) {
              case EventCustomType.lottery:
                return Text(
                    '${S.current.event_lottery}/${S.current.event_lottery_limited}');
              case EventCustomType.hunting:
                return Text(S.current.hunting_quest);
              case EventCustomType.mission:
                return Text(S.current.mission);
              case EventCustomType.point:
                return Text(S.current.event_point);
              case EventCustomType.tower:
                return Text(S.current.event_tower);
              case EventCustomType.treasureBox:
                return Text(S.current.event_treasure_box);
              case EventCustomType.digging:
                return Text(S.current.event_digging);
              case EventCustomType.warBoard:
                return Text(S.current.war_board);
              case EventCustomType.mainInterlude:
                return Text(S.current.main_interlude);
              case EventCustomType.cooltime:
                return Text(S.current.event_cooltime);
              case EventCustomType.bulletinBoard:
                return Text(S.current.event_bulletin_board);
              case EventCustomType.recipe:
                return Text(S.current.event_recipe);
            }
          },
          onFilterChanged: (value, _) {
            update();
          },
        ),
      ]),
    );
  }
}
