// ignore_for_file: non_constant_identifier_names

import 'package:flutter/material.dart';

class DirectionalIcons {
  const DirectionalIcons._();

  static IconData of(
    BuildContext context, {
    required IconData ltr,
    required IconData rtl,
  }) {
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
