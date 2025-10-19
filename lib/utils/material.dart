// ignore_for_file: non_constant_identifier_names

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart' show SchedulerPhase;

class DirectionalIcons {
  const DirectionalIcons._();

  static IconData of(BuildContext context, {required IconData ltr, required IconData rtl}) {
    if (Directionality.of(context) == TextDirection.ltr) {
      return ltr;
    } else {
      return rtl;
    }
  }

  static IconData keyboard_arrow_forward(BuildContext context) {
    if (Directionality.of(context) == TextDirection.ltr) {
      return Icons.keyboard_arrow_right;
    } else {
      return Icons.keyboard_arrow_left;
    }
  }

  static IconData keyboard_arrow_back(BuildContext context) {
    if (Directionality.of(context) == TextDirection.ltr) {
      return Icons.keyboard_arrow_left;
    } else {
      return Icons.keyboard_arrow_right;
    }
  }
}

final kTextButtonDenseStyle = TextButton.styleFrom(
  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
  visualDensity: VisualDensity.compact,
);

bool get isBuildingWidget =>
    const [
      SchedulerPhase.transientCallbacks,
      SchedulerPhase.midFrameMicrotasks,
      SchedulerPhase.persistentCallbacks,
    ].contains(WidgetsBinding.instance.schedulerPhase) ||
    WidgetsBinding.instance.rootElement == null;

extension ScrollPositionX on ScrollMetrics {
  double guessPixelsAt(int index, int total) {
    if (index <= 0 || total <= 0) return 0;
    if (maxScrollExtent.isInfinite || maxScrollExtent <= 0 || minScrollExtent.isInfinite || extentTotal <= 0) return 0;
    return (extentTotal * (index + 1 / 2) / total - extentInside / 2).clamp(0, maxScrollExtent);
  }
}
