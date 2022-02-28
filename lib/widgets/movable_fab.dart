import 'package:flutter/material.dart';

class MovableFab extends StatefulWidget {
  final Widget icon;
  final double initialX;
  final double initialY;
  final VoidCallback? onPressed;
  final Function(double x, double y)? onMoved;
  final bool enabled;
  final double opacity;
  final Color? backgroundColor;

  MovableFab({
    Key? key,
    required this.icon,
    this.initialX = 1.0,
    this.initialY = 1.0,
    this.onPressed,
    this.onMoved,
    this.enabled = true,
    this.opacity = 1.0,
    this.backgroundColor,
  }) : super(key: key);

  @override
  _MovableFabState createState() => _MovableFabState();
}

class _MovableFabState extends State<MovableFab> {
  Rect rect = Rect.zero;

  late Offset _ratio;
  late Offset _offset;

  @override
  void initState() {
    super.initState();
    _ratio = Offset(widget.initialX, widget.initialY);
    _offset = ratio2Offset();
  }

  @override
  Widget build(BuildContext context) {
    updateRect();
    ratio2Offset();
    return Positioned(
      left: _offset.dx,
      top: _offset.dy,
      child: GestureDetector(
        onPanUpdate: (DragUpdateDetails details) {
          setState(() {
            setState(() {
              limitOffset(details.delta);
              offset2Ratio();
            });
            if (widget.onMoved != null) {
              widget.onMoved!(_ratio.dx, _ratio.dy);
            }
          });
        },
        child: Opacity(
          opacity: widget.opacity,
          child: FloatingActionButton(
            mini: true,
            onPressed: widget.enabled ? widget.onPressed : null,
            child: widget.icon,
            backgroundColor: widget.backgroundColor,
          ),
        ),
      ),
    );
  }

  Rect updateRect() {
    final screenSize = MediaQuery.of(context).size;
    Size btnSize =
        (context.findRenderObject() as RenderBox?)?.size ?? const Size(40, 40);
    final padding = MediaQuery.of(context).padding;
    return rect = Rect.fromLTRB(
      -8.0 + padding.left,
      padding.top + kToolbarHeight,
      screenSize.width + 8 - padding.right - btnSize.width,
      screenSize.height -
          padding.bottom -
          btnSize.height / 2 -
          kBottomNavigationBarHeight,
    );
  }

  Offset ratio2Offset() {
    return _offset = Offset(
        rect.width * _ratio.dx + rect.left, rect.height * _ratio.dy + rect.top);
  }

  Offset offset2Ratio() {
    return _ratio = Offset((_offset.dx - rect.left) / rect.width,
        (_offset.dy - rect.top) / rect.height);
  }

  Offset limitOffset([Offset delta = Offset.zero]) {
    _offset = _offset + delta;
    return _offset = Offset(_offset.dx.clamp(rect.left, rect.right),
        _offset.dy.clamp(rect.top, rect.bottom));
  }
}
