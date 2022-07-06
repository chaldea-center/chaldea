import 'package:flutter/material.dart';

import 'package:chaldea/app/descriptors/multi_entry.dart';
import 'package:chaldea/models/models.dart';
import '../../widgets/widget_builders.dart';

abstract class DescriptorBase {
  TextStyle? get style;
  double? get textScaleFactor;
  List<int> get targetIds;

  Widget localized({
    required Widget Function()? jp,
    required Widget Function()? cn,
    required Widget Function()? tw,
    required Widget Function()? na,
    required Widget Function()? kr,
  }) {
    assert(jp != null || cn != null || na != null);
    return MappingBase.of(jp: jp, cn: cn, tw: tw, na: na, kr: kr)?.call() ??
        const SizedBox();
  }

  Text text(String data) {
    return Text(data, textScaleFactor: textScaleFactor, style: style);
  }

  Text combineToRich(
    BuildContext context,
    String? text1, [
    List<Widget>? children2,
    String? text3,
    List<Widget>? children4,
    String? text5,
  ]) {
    return Text.rich(
      TextSpan(
        text: text1,
        // style: Theme.of(context).textTheme.bodyText2,
        children: [
          if (children2 != null)
            for (final child in children2) CenterWidgetSpan(child: child),
          if (text3 != null) TextSpan(text: text3),
          if (children4 != null)
            for (final child in children4) CenterWidgetSpan(child: child),
          if (text5 != null) TextSpan(text: text5),
        ],
      ),
      style: style,
      textScaleFactor: textScaleFactor,
    );
  }

  List<Widget> quests(BuildContext context) =>
      MultiDescriptor.quests(context, targetIds);
  List<Widget> traits(BuildContext context) =>
      MultiDescriptor.traits(context, targetIds);
  List<Widget> svtClasses(BuildContext context) =>
      MultiDescriptor.svtClass(context, targetIds);
  List<Widget> servants(BuildContext context) =>
      MultiDescriptor.servants(context, targetIds);
  List<Widget> items(BuildContext context) =>
      MultiDescriptor.items(context, targetIds);
  List<Widget> missionList(
          BuildContext context, Map<int, EventMission> missions) =>
      MultiDescriptor.missions(context, targetIds, missions);
  List<Widget> event(BuildContext context) {
    final _event = db.gameData.events[targetIds.first];
    return [
      MultiDescriptor.inkWell(
        context: context,
        text: _event?.shownName ?? targetIds.first.toString(),
        onTap: () => _event?.routeTo(),
      )
    ];
  }
}
