import 'package:flutter/material.dart';

import 'package:chaldea/app/descriptors/multi_entry.dart';
import 'package:chaldea/models/models.dart';

mixin DescriptorBase {
  List<int> get targetIds;
  bool? get useAnd;
  String? get unknownMsg;
  TextStyle? get style;
  double? get textScaleFactor;
  InlineSpan? get leading;
  EdgeInsetsGeometry? get padding;

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
    Widget child = Text.rich(
      TextSpan(
        children: [
          if (leading != null) leading!,
          ...buildContent(context),
          // in case the last [GestureRecognizer] use the remaining space
          const TextSpan(text: ' '),
        ],
      ),
      textScaler: textScaleFactor == null ? null : TextScaler.linear(textScaleFactor!),
      style: style,
    );
    if (padding != null) {
      child = Padding(padding: padding!, child: child);
    }
    return child;
  }

  List<InlineSpan> text(String data) {
    return [TextSpan(text: data)];
  }

  List<InlineSpan> rich(
    BuildContext? context,
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

  List<InlineSpan> wrapMsg(List<InlineSpan> spans) {
    if (unknownMsg != null && unknownMsg!.isNotEmpty) {
      spans = [
        ...spans,
        TextSpan(
          text: ' ($unknownMsg)',
          style: TextStyle(fontSize: (style?.fontSize ?? 14.0) * (textScaleFactor ?? 1.0) * 0.8),
        ),
      ];
    }
    return spans;
  }

  List<InlineSpan> emptyHint(List<InlineSpan> spans) {
    if (spans.isEmpty && targetIds.isEmpty) return [const TextSpan(text: '[]')];
    return spans;
  }

  List<InlineSpan> quests(BuildContext context) =>
      emptyHint(MultiDescriptor.quests(context, targetIds, useAnd: useAnd));
  List<InlineSpan> traits(BuildContext context) =>
      emptyHint(MultiDescriptor.traits(context, targetIds, useAnd: useAnd));
  List<InlineSpan> svtClasses(BuildContext context) =>
      emptyHint(MultiDescriptor.svtClass(context, targetIds, useAnd: useAnd));
  List<InlineSpan> servants(BuildContext context) =>
      emptyHint(MultiDescriptor.servants(context, targetIds, useAnd: useAnd));
  List<InlineSpan> items(BuildContext context) => emptyHint(MultiDescriptor.items(context, targetIds, useAnd: useAnd));
  List<InlineSpan> missionList(BuildContext context, Map<int, EventMission> missions, {bool sort = true}) =>
      emptyHint(MultiDescriptor.missions(context, targetIds, missions, useAnd: useAnd, sort: sort));
  List<InlineSpan> events(BuildContext context) =>
      emptyHint([TextSpan(children: MultiDescriptor.events(context, targetIds), style: const TextStyle(fontSize: 14))]);
  List<InlineSpan> wars(BuildContext context) => emptyHint(MultiDescriptor.wars(context, targetIds));
  List<InlineSpan> shops(BuildContext context) => emptyHint(MultiDescriptor.shops(context, targetIds));
  String classIds(List<int> clsIds) => clsIds.map((e) => Transl.svtClassId(e).l).join("/");
  String get targetClassIds => classIds(targetIds);
}
