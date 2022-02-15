// ignore_for_file: non_constant_identifier_names

import 'package:flutter/material.dart';

class DirectionalIcons {
  static IconData keyboard_arrow_forward(BuildContext context) {
    if (Directionality.of(context) == TextDirection.ltr) {
      return Icons.keyboard_arrow_right;
    } else {
      return Icons.keyboard_arrow_left;
    }
  }
}
