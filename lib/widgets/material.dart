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

class DividerWithTitle extends StatelessWidget {
  final String? title;
  final Widget? titleWidget;
  final double? height;
  final double? thickness;
  final double? indent;
  final double? endIndent;
  final Color? color;
  final EdgeInsetsGeometry? padding;

  const DividerWithTitle({
    this.title,
    this.titleWidget,
    super.key,
    this.height,
    this.thickness,
    this.indent,
    this.endIndent,
    this.color,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    Widget? titleWidget = this.titleWidget;
    if (title != null) {
      titleWidget ??=
          Text(title!, style: Theme.of(context).textTheme.bodySmall);
    }
    Widget child;
    if (titleWidget == null) {
      child = Divider(
        height: height,
        thickness: thickness,
        indent: indent,
        endIndent: endIndent,
        color: color,
      );
    } else {
      child = Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Divider(
              height: height,
              thickness: thickness,
              indent: indent,
              endIndent: endIndent ?? 8,
              color: color,
            ),
          ),
          titleWidget,
          Expanded(
            child: Divider(
              height: height,
              thickness: thickness,
              indent: endIndent ?? 8,
              endIndent: indent,
              color: color,
            ),
          )
        ],
      );
    }
    if (padding != null) {
      child = Padding(padding: padding!, child: child);
    }
    return child;
  }
}
