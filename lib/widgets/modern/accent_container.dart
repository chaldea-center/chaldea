import 'package:material_ui/material_ui.dart';

/// A rounded container with an optional left accent border.
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

    // Include border widths in padding to keep the child clear of the border.
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

/// A rounded border with a left accent strip; zero [accentWidth] draws only the border.
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

    // Narrow strips use elliptical inner corners to follow the outer border.
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
        path.moveTo(L, T + R);
        path.arcToPoint(Offset(L + R, T), radius: Radius.circular(R), clockwise: true);
        // The inner ellipse shares the outer corner's center.
        path.arcToPoint(Offset(L + W, T + R), radius: Radius.elliptical(R - W, R), clockwise: false);
        path.lineTo(L + W, B - R);
        path.arcToPoint(Offset(L + R, B), radius: Radius.elliptical(R - W, R), clockwise: false);
        path.arcToPoint(Offset(L, B - R), radius: Radius.circular(R), clockwise: true);
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
