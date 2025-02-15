import 'package:flutter/material.dart';

import '../utils/basic.dart';
import 'tile_items.dart';

enum ResponsiveSizeType { small, middle, large }

class ResponsiveLayout extends StatelessWidget {
  final List<Responsive> children;
  final List<Responsive> Function(BuildContext context, ResponsiveSizeType type)? builder;
  final Widget? horizontalDivider;
  final Widget? verticalDivider;
  final double sm;
  final double ml;
  final int maxFlex;
  // styles
  final CrossAxisAlignment verticalAlign;
  final CrossAxisAlignment horizontalAlign;
  final FlexFit flexFit;
  final TextDirection? rowDirection;
  final VerticalDirection verticalDirection;

  static const _defaultHorizontalDivider = Divider(thickness: 1, height: 8);
  // static const _defaultVerticalDivider = VerticalDivider(thickness: 1, width: 8);

  const ResponsiveLayout({
    super.key,
    required this.children,
    this.horizontalDivider = _defaultHorizontalDivider,
    this.verticalDivider,
    this.sm = 576.0,
    this.ml = 768.0,
    this.maxFlex = 12,
    this.verticalAlign = CrossAxisAlignment.start,
    this.horizontalAlign = CrossAxisAlignment.center,
    this.flexFit = FlexFit.tight,
    this.rowDirection,
    this.verticalDirection = VerticalDirection.down,
  }) : builder = null;

  const ResponsiveLayout.builder({
    super.key,
    required this.builder,
    this.horizontalDivider = _defaultHorizontalDivider,
    this.verticalDivider,
    this.sm = 576.0,
    this.ml = 768.0,
    this.maxFlex = 12,
    this.verticalAlign = CrossAxisAlignment.start,
    this.horizontalAlign = CrossAxisAlignment.center,
    this.flexFit = FlexFit.tight,
    this.rowDirection,
    this.verticalDirection = VerticalDirection.down,
  }) : children = const [];

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final ResponsiveSizeType type;
        if (constraints.maxWidth > ml) {
          type = ResponsiveSizeType.large;
        } else if (constraints.maxWidth > sm) {
          type = ResponsiveSizeType.middle;
        } else {
          type = ResponsiveSizeType.small;
        }
        List<Widget> rows = [];
        List<Responsive> cells = [];
        final children = builder != null ? builder!(context, type) : this.children;
        for (final child in children) {
          if (Maths.sum(cells.map((e) => e.getFlex(type))) + (child.getFlex(type) ?? 0) > maxFlex) {
            // insert one row
            rows.add(insertRow(cells, type));
            cells = [child];
          } else {
            cells.add(child);
          }
        }
        if (cells.isNotEmpty) {
          rows.add(insertRow(cells, type));
          cells = [];
        }
        if (horizontalDivider != null) {
          rows = divideList(rows, horizontalDivider!);
        }
        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          verticalDirection: verticalDirection,
          children: rows,
        );
      },
    );
  }

  Widget insertRow(List<Responsive> cells, ResponsiveSizeType type) {
    List<Widget> children = [];
    for (int index = 0; index < cells.length; index++) {
      final cell = cells[index];
      final flex = cell.getFlex(type);
      children.add(flex == null ? cell : Flexible(flex: flex, fit: flexFit, child: cell));
    }
    if (verticalDivider != null) children = divideList(children, verticalDivider!);
    return Row(textDirection: rowDirection, crossAxisAlignment: verticalAlign, children: children);
  }
}

class Responsive extends StatelessWidget {
  final int? small;
  final int? middle;
  final int? large;
  final Widget child;

  const Responsive({super.key, this.small, this.middle, this.large, required this.child});

  int? getFlex(ResponsiveSizeType type) {
    switch (type) {
      case ResponsiveSizeType.small:
        return small ?? middle ?? large;
      case ResponsiveSizeType.middle:
        return middle ?? small ?? large;
      case ResponsiveSizeType.large:
        return large ?? middle ?? small;
    }
  }

  @override
  Widget build(BuildContext context) {
    return child;
  }
}
