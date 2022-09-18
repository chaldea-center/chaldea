import 'package:flutter/material.dart';

typedef AccordionHeaderBuilder = Widget Function(
    BuildContext context, bool expanded);

class SimpleAccordion extends StatefulWidget {
  final bool expanded;
  final AccordionHeaderBuilder headerBuilder;
  final WidgetBuilder contentBuilder;
  final void Function(bool expanded)? expandCallback;
  final bool canTapOnHeader;
  final AccordionHeaderBuilder? expandIconBuilder;
  final bool disableAnimation;
  final double? elevation;
  final double? expandElevation;
  final BorderSide topBorderSide;
  final Color? headerTileColor;

  SimpleAccordion({
    super.key,
    this.expanded = false,
    required this.headerBuilder,
    required this.contentBuilder,
    this.expandCallback,
    this.canTapOnHeader = true,
    this.expandIconBuilder,
    this.disableAnimation = false,
    this.elevation,
    this.expandElevation,
    this.topBorderSide = BorderSide.none,
    this.headerTileColor,
  });

  @override
  _SimpleAccordionState createState() => _SimpleAccordionState();
}

class _SimpleAccordionState extends State<SimpleAccordion> {
  bool expanded = false;
  bool _onceLoaded = false;

  @override
  void initState() {
    super.initState();
    expanded = widget.expanded;
  }

  void toggle() {
    setState(() {
      expanded = !expanded;
    });
  }

  @override
  Widget build(BuildContext context) {
    late Widget expandIcon;
    if (widget.expandIconBuilder != null) {
      expandIcon = widget.expandIconBuilder!(context, expanded);
      if (!widget.canTapOnHeader) {
        expandIcon = GestureDetector(onTap: toggle, child: expandIcon);
      }
    } else {
      expandIcon = ExpandIcon(
        isExpanded: expanded,
        onPressed: widget.canTapOnHeader ? null : (_) => toggle(),
      );
    }
    Widget header = widget.headerBuilder(context, expanded);
    header = Row(children: [Expanded(child: header), expandIcon]);
    if (widget.canTapOnHeader) {
      header = InkWell(onTap: toggle, child: header);
    }
    if (widget.headerTileColor != null) {
      header = Material(color: widget.headerTileColor, child: header);
    }
    Widget content;
    if (expanded) _onceLoaded = true;
    Widget secondChild =
        _onceLoaded ? widget.contentBuilder(context) : Container();
    if (widget.disableAnimation) {
      content = expanded ? secondChild : Container();
    } else {
      content = AnimatedCrossFade(
        firstChild: Container(height: 0.0),
        secondChild: secondChild,
        firstCurve: const Interval(0.0, 0.6, curve: Curves.fastOutSlowIn),
        secondCurve: const Interval(0.4, 1.0, curve: Curves.fastOutSlowIn),
        sizeCurve: Curves.fastOutSlowIn,
        crossFadeState:
            expanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
        duration: kThemeAnimationDuration,
      );
    }

    return Padding(
      padding: expanded ? const EdgeInsets.only(bottom: 6) : EdgeInsets.zero,
      child: Material(
        elevation:
            expanded ? (widget.expandElevation ?? 2) : (widget.elevation ?? 0),
        color: Material.of(context)?.color,
        child: DecoratedBox(
          decoration: BoxDecoration(border: Border(top: widget.topBorderSide)),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [header, content],
          ),
        ),
      ),
    );
  }
}
