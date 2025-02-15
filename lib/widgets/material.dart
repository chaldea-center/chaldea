import 'dart:math';

import 'package:flutter/material.dart';

class FixedHeight extends StatelessWidget implements PreferredSizeWidget {
  final double height;
  final Widget child;

  const FixedHeight({super.key, required this.height, required this.child});

  const FixedHeight.tabBar(Widget child, {Key? key, double height = 32}) : this(key: key, height: height, child: child);

  @override
  Size get preferredSize => Size.fromHeight(height);

  @override
  Widget build(BuildContext context) {
    return SizedBox(height: preferredSize.height, child: child);
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
    this.padding = const EdgeInsets.fromLTRB(0, 6, 0, 4),
  });

  @override
  Widget build(BuildContext context) {
    Widget? titleWidget = this.titleWidget;
    if (title != null) {
      titleWidget ??= Text(title!, style: Theme.of(context).textTheme.bodySmall);
    }
    Widget child;
    if (titleWidget == null) {
      child = Divider(height: height, thickness: thickness, indent: indent, endIndent: endIndent, color: color);
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
          ),
        ],
      );
    }
    if (padding != null) {
      child = Padding(padding: padding!, child: child);
    }
    return child;
  }
}

class DashedLinePainter extends CustomPainter {
  final double dashWidth;
  final double space;
  final double indent;
  final double strokeWidth;

  const DashedLinePainter({this.dashWidth = 9, this.space = 5, this.indent = 0, this.strokeWidth = 1});

  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = Colors.grey
          ..strokeWidth = strokeWidth;
    double startX = indent;
    final maxX = max(startX, size.width - indent);
    final y = size.height / 2;
    while (startX < maxX) {
      canvas.drawLine(Offset(startX, y), Offset(min(startX + dashWidth, maxX), y), paint);
      startX += dashWidth + space;
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

typedef WidgetDataBuilder<T> = Widget Function(BuildContext context, T data);

class FutureBuilder2<K, V> extends StatefulWidget {
  final K id;
  final Future<V> Function() loader;
  final WidgetDataBuilder<V> builder;
  final WidgetBuilder? onFailed;
  final WidgetBuilder? onLoading;

  const FutureBuilder2({
    super.key,
    required this.id,
    required this.loader,
    required this.builder,
    this.onFailed,
    this.onLoading,
  });

  @override
  State<FutureBuilder2<K, V>> createState() => _FutureBuilder2State<K, V>();
}

class _FutureBuilder2State<K, V> extends State<FutureBuilder2<K, V>> {
  V? _data;
  K? _loading;

  Future<void> load(K id) async {
    _data = null;
    _loading = id;
    if (mounted) setState(() {});
    final data = await widget.loader();
    if (_loading == id) _loading = null;
    if (id == widget.id) {
      _data = data;
    }
    if (mounted) setState(() {});
  }

  @override
  void initState() {
    super.initState();
    load(widget.id);
  }

  @override
  void didUpdateWidget(covariant FutureBuilder2<K, V> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.id != oldWidget.id) {
      load(widget.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    return _loading == widget.id
        ? widget.onLoading?.call(context) ?? const SizedBox()
        : _data is V
        ? widget.builder(context, _data as V)
        : widget.onFailed?.call(context) ?? const SizedBox();
  }
}
