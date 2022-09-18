import 'package:flutter/material.dart';

class FixedHeight extends StatelessWidget implements PreferredSizeWidget {
  final double height;
  final Widget child;

  const FixedHeight({super.key, required this.height, required this.child});

  const FixedHeight.tabBar(Widget child, {Key? key, double height = 32})
      : this(key: key, height: height, child: child);

  @override
  Size get preferredSize => Size.fromHeight(height);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: preferredSize.height,
      child: child,
    );
  }
}
