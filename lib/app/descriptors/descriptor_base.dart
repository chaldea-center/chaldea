import 'package:flutter/material.dart';

import 'package:chaldea/app/descriptors/multi_entry.dart';
import 'package:chaldea/models/models.dart';

abstract class DescriptorBase {
  TextStyle? get style;
  double? get textScaleFactor;
  List<int> get targetIds;
  InlineSpan? get leading;

  List<InlineSpan> localized({
    required List<InlineSpan> Function()? jp,
    required List<InlineSpan> Function()? cn,
    required List<InlineSpan> Function()? tw,
    required List<InlineSpan> Function()? na,
    required List<InlineSpan> Function()? kr,
  }) {
    assert(jp != null || cn != null || na != null);
    return MappingBase.of(jp: jp, cn: cn, tw: tw, na: na, kr: kr)?.call() ?? [];
  }

  List<InlineSpan> buildContent(BuildContext context);

  Widget build(BuildContext context) {
    return Text.rich(
      TextSpan(
        children: [
          if (leading != null) leading!,
          ...buildContent(context),
        ],
      ),
      textScaleFactor: textScaleFactor,
      style: style,
    );
  }

  List<InlineSpan> text(String data) {
    return [TextSpan(text: data)];
  }

  List<InlineSpan> combineToRich(
    BuildContext context,
    String? text1, [
    List<InlineSpan>? children2,
    String? text3,
    List<InlineSpan>? children4,
    String? text5,
  ]) {
    return [
      if (text1 != null) TextSpan(text: text1),
      if (children2 != null) ...children2,
      if (text3 != null) TextSpan(text: text3),
      if (children4 != null) ...children4,
      if (text5 != null) TextSpan(text: text5),
    ];
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
