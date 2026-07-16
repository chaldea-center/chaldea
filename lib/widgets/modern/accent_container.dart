// AccentContainer: a card-like container with an optional thick accent border
// on the left side. Uses a custom ShapeBorder (AccentBorder) to draw
// non-uniform borders — thick accent on left, thin border on other sides —
// with proper rounded corners. Flutter's BoxDecoration requires uniform
// border colors when borderRadius is set, so ShapeBorder via ShapeDecoration
// is the idiomatic way to achieve this visual without gradient hacks or
// nested containers.

import 'package:flutter/material.dart';

/// A card-like container with an optional thick accent border on the left
/// side (primary variant) or a simple uniform border (non-primary variant).
///
/// Uses [AccentBorder] via [ShapeDecoration] to draw non-uniform borders
/// with proper rounded corners — no gradient hacks or nested containers.
class AccentContainer extends StatelessWidget {
  final bool primary;
  final Color? accentColor;
  final Color? borderColor;
  final Color? backgroundColor;
  final double borderRadius;
  final double accentWidth;
  final double borderWidth;
  final EdgeInsets padding;
  final List<BoxShadow>? boxShadow;
  final Widget child;

  const AccentContainer({
    super.key,
    this.primary = false,
    this.accentColor,
    this.borderColor,
    this.backgroundColor,
    this.borderRadius = 12,
    this.accentWidth = 4,
    this.borderWidth = 1,
    this.padding = const EdgeInsets.all(16),
    this.boxShadow,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final accent = accentColor ?? cs.primary;
    final border = borderColor ?? cs.outlineVariant;
    final bg = backgroundColor ?? cs.surfaceContainer;

    // The border/accent occupies space on the edges; add it to the user's
    // padding so the child doesn't overlap with the border.
    final edgeInsets = primary
        ? EdgeInsets.fromLTRB(accentWidth, borderWidth, borderWidth, borderWidth)
        : EdgeInsets.all(borderWidth);

    return DecoratedBox(
      decoration: ShapeDecoration(
        color: bg,
        shadows: boxShadow,
        shape: AccentBorder(
          borderRadius: BorderRadius.circular(borderRadius),
          accentColor: accent,
          borderColor: border,
          accentWidth: primary ? accentWidth : 0,
          borderWidth: borderWidth,
        ),
      ),
      child: Padding(padding: edgeInsets + padding, child: child),
    );
  }
}

/// A [ShapeBorder] that draws a thick accent strip on the left side and a
/// thin uniform border on all sides, with proper rounded corners.
///
/// When [accentWidth] is narrower than [borderRadius], the strip's right
/// edge gets an elliptical corner (x = borderRadius - accentWidth,
/// y = borderRadius) sharing the outer arc's center, so the strip wraps
/// around the corner smoothly instead of being cut flat mid-curve.
/// When [accentWidth] is 0, only the thin uniform border is drawn.
class AccentBorder extends ShapeBorder {
  final BorderRadius borderRadius;
  final Color accentColor;
  final Color borderColor;
  final double accentWidth;
  final double borderWidth;

  const AccentBorder({
    this.borderRadius = const BorderRadius.all(Radius.circular(12)),
    required this.accentColor,
    required this.borderColor,
    this.accentWidth = 0,
    this.borderWidth = 1,
  });

  @override
  EdgeInsetsGeometry get dimensions =>
      EdgeInsets.fromLTRB(accentWidth > borderWidth ? accentWidth : borderWidth, borderWidth, borderWidth, borderWidth);

  @override
  Path getInnerPath(Rect rect, {TextDirection? textDirection}) {
    return getOuterPath(rect.deflate(borderWidth), textDirection: textDirection);
  }

  @override
  Path getOuterPath(Rect rect, {TextDirection? textDirection}) {
    return Path()..addRRect(borderRadius.resolve(textDirection).toRRect(rect));
  }

  @override
  void paint(Canvas canvas, Rect rect, {TextDirection? textDirection}) {
    final resolvedRadius = borderRadius.resolve(textDirection);

    // Stroke is centered on the path; deflate by half the width so the border
    // sits entirely inside the rect (matching BoxDecoration's behavior).
    if (borderWidth > 0) {
      final strokeRect = rect.deflate(borderWidth / 2);
      canvas.drawPath(
        Path()..addRRect(resolvedRadius.toRRect(strokeRect)),
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = borderWidth
          ..color = borderColor,
      );
    }

    // Accent strip on the left. When the strip is narrower than the corner
    // radius, build a dedicated path whose right edge has a smaller rounded
    // corner (radius R - W) so the strip wraps around the corner smoothly
    // instead of being cut flat mid-curve. When the strip is wider than (or
    // equal to) the radius, the right edge sits in the straight section and
    // a simple clipped rectangle suffices.
    if (accentWidth > 0) {
      final R = resolvedRadius.topLeft.x;
      final W = accentWidth;
      final L = rect.left;
      final T = rect.top;
      final B = rect.bottom;
      final accentPaint = Paint()..color = accentColor;

      if (W >= R || R <= 0) {
        canvas.save();
        canvas.clipPath(Path()..addRRect(resolvedRadius.toRRect(rect)));
        canvas.drawRect(Rect.fromLTWH(L, T, W, rect.height), accentPaint);
        canvas.restore();
      } else {
        final path = Path();
        // Start at the top of the outer left straight edge.
        path.moveTo(L, T + R);
        // Outer top-left arc (clockwise) to the top edge.
        path.arcToPoint(Offset(L + R, T), radius: Radius.circular(R), clockwise: true);
        // Inner top-left arc (counter-clockwise) back to the straight right
        // edge. Elliptical with x=R-W, y=R — shares the same center (L+R,
        // T+R) as the outer arc, so the strip maintains full width W down
        // to y=T+R and curves smoothly to meet the top edge at the corner.
        path.arcToPoint(Offset(L + W, T + R), radius: Radius.elliptical(R - W, R), clockwise: false);
        // Straight right edge down to where the bottom inner arc begins.
        path.lineTo(L + W, B - R);
        // Inner bottom-left arc (counter-clockwise) to the bottom edge.
        path.arcToPoint(Offset(L + R, B), radius: Radius.elliptical(R - W, R), clockwise: false);
        // Outer bottom-left arc (clockwise) back to the left straight edge.
        path.arcToPoint(Offset(L, B - R), radius: Radius.circular(R), clockwise: true);
        // Close with the straight left edge back to the start.
        path.close();
        canvas.drawPath(path, accentPaint);
      }
    }
  }

  @override
  ShapeBorder scale(double t) {
    return AccentBorder(
      borderRadius: borderRadius * t,
      accentColor: accentColor,
      borderColor: borderColor,
      accentWidth: accentWidth * t,
      borderWidth: borderWidth * t,
    );
  }

  @override
  ShapeBorder? lerpFrom(ShapeBorder? a, double t) {
    if (a is AccentBorder) {
      return AccentBorder(
        borderRadius: BorderRadius.lerp(a.borderRadius, borderRadius, t)!,
        accentColor: Color.lerp(a.accentColor, accentColor, t)!,
        borderColor: Color.lerp(a.borderColor, borderColor, t)!,
        accentWidth: a.accentWidth + (accentWidth - a.accentWidth) * t,
        borderWidth: a.borderWidth + (borderWidth - a.borderWidth) * t,
      );
    }
    return super.lerpFrom(a, t);
  }

  @override
  ShapeBorder? lerpTo(ShapeBorder? b, double t) {
    if (b is AccentBorder) {
      return AccentBorder(
        borderRadius: BorderRadius.lerp(borderRadius, b.borderRadius, t)!,
        accentColor: Color.lerp(accentColor, b.accentColor, t)!,
        borderColor: Color.lerp(borderColor, b.borderColor, t)!,
        accentWidth: accentWidth + (b.accentWidth - accentWidth) * t,
        borderWidth: borderWidth + (b.borderWidth - borderWidth) * t,
      );
    }
    return super.lerpTo(b, t);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! AccentBorder) return false;
    return borderRadius == other.borderRadius &&
        accentColor == other.accentColor &&
        borderColor == other.borderColor &&
        accentWidth == other.accentWidth &&
        borderWidth == other.borderWidth;
  }

  @override
  int get hashCode => Object.hash(borderRadius, accentColor, borderColor, accentWidth, borderWidth);
}
