import 'package:flutter/material.dart';

import '../utils/basic.dart';
import 'tile_items.dart';

enum _SizeType {
  small,
  middle,
  large,
}

class ResponsiveLayout extends StatelessWidget {
  final List<Responsive> children;
  final Widget? horizontalDivider;
  final Widget? verticalDivider;
  final double sm;
  final double ml;
  final int maxFlex;
  // styles
  final CrossAxisAlignment verticalAlign;
  final CrossAxisAlignment horizontalAlign;

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
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      final _SizeType type;
      if (constraints.maxWidth > ml) {
        type = _SizeType.large;
      } else if (constraints.maxWidth > sm) {
        type = _SizeType.middle;
      } else {
        type = _SizeType.small;
      }
      List<Widget> rows = [];
      List<Responsive> cells = [];
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
      }
      if (horizontalDivider != null) {
        rows = divideList(rows, horizontalDivider!);
      }
      return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: rows,
      );
    });
  }

  Widget insertRow(List<Responsive> cells, _SizeType type) {
    List<Widget> children = [];
    for (int index = 0; index < cells.length; index++) {
      final cell = cells[index];
      final flex = cell.getFlex(type);
      children.add(flex == null ? cell : Expanded(flex: flex, child: cell));
      if (verticalDivider != null) children.add(verticalDivider!);
    }
    return Row(
      crossAxisAlignment: verticalAlign,
      children: children,
    );
  }
}

class Responsive extends StatelessWidget {
  final int? small;
  final int? middle;
  final int? large;
  final Widget child;

  const Responsive({super.key, this.small, this.middle, this.large, required this.child});

  int? getFlex(_SizeType type) {
    switch (type) {
      case _SizeType.small:
        return small ?? middle ?? large;
      case _SizeType.middle:
        return middle ?? small ?? large;
      case _SizeType.large:
        return large ?? middle ?? small;
    }
  }

  @override
  Widget build(BuildContext context) {
    return child;
  }
}
