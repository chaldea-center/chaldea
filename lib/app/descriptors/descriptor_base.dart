import 'package:flutter/material.dart';

import 'package:chaldea/models/models.dart';

abstract class DescriptorBase {
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

  RichText combineToRich(
    BuildContext context,
    String? text1, [
    List<Widget>? children2,
    String? text3,
    List<Widget>? children4,
    String? text5,
  ]) {
    return RichText(
      text: TextSpan(
        text: text1,
        style: Theme.of(context).textTheme.bodyText2,
        children: [
          if (children2 != null)
            for (final child in children2) WidgetSpan(child: child),
          if (text3 != null) TextSpan(text: text3),
          if (children4 != null)
            for (final child in children4) WidgetSpan(child: child),
          if (text5 != null) TextSpan(text: text5),
        ],
      ),
    );
  }
}
