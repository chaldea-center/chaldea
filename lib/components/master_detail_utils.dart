import 'package:flutter/widgets.dart';

const kTabletMasterContainerRatio = 30; // total 100

bool isTablet(BuildContext context) {
  return MediaQuery.of(context).size.width >= 768.0;
}