import 'package:flutter/material.dart';

class SliverTabBarDelegate extends SliverPersistentHeaderDelegate {
  SliverTabBarDelegate(this.preferredSizeWidget);

  final PreferredSizeWidget preferredSizeWidget;

  @override
  double get minExtent => preferredSizeWidget.preferredSize.height;

  @override
  double get maxExtent => preferredSizeWidget.preferredSize.height;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return new Container(
      child: preferredSizeWidget,
    );
  }

  @override
  bool shouldRebuild(SliverTabBarDelegate oldDelegate) {
    return false;
  }
}
