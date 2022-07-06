import 'package:flutter/material.dart';

import 'package:chaldea/app/descriptors/multi_entry.dart';
import 'package:chaldea/models/models.dart';

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
    List<InlineSpan>? children2,
    String? text3,
    List<InlineSpan>? children4,
    String? text5,
  ]) {
    return Text.rich(
      TextSpan(
        text: text1,
        // style: Theme.of(context).textTheme.bodyText2,
        children: [
          if (children2 != null) ...children2,
          if (text3 != null) TextSpan(text: text3),
          if (children4 != null) ...children4,
          if (text5 != null) TextSpan(text: text5),
        ],
      ),
      style: style,
      textScaleFactor: textScaleFactor,
    );
  }

  List<InlineSpan> quests(BuildContext context) =>
      MultiDescriptor.quests(context, targetIds);
  List<InlineSpan> traits(BuildContext context) =>
      MultiDescriptor.traits(context, targetIds);
  List<InlineSpan> svtClasses(BuildContext context) =>
      MultiDescriptor.svtClass(context, targetIds);
  List<InlineSpan> servants(BuildContext context) =>
      MultiDescriptor.servants(context, targetIds);
  List<InlineSpan> items(BuildContext context) =>
      MultiDescriptor.items(context, targetIds);
  List<InlineSpan> missionList(
          BuildContext context, Map<int, EventMission> missions) =>
      MultiDescriptor.missions(context, targetIds, missions);
  List<InlineSpan> event(BuildContext context) {
    final _event = db.gameData.events[targetIds.first];
    return [
      MultiDescriptor.inkWell(
        context: context,
        text: _event?.shownName.replaceAll('\n', ' ') ??
            targetIds.first.toString(),
        onTap: () => _event?.routeTo(),
      )
    ];
  }
}
