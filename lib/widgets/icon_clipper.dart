import 'package:flutter/material.dart';

/// Clip top-left and top-right corner
class TopCornerClipper extends CustomClipper<Path> {
  /// If null, auto-detect size, clip if size is 132*144
  final bool? clip;

  TopCornerClipper({this.clip});

  @override
  Path getClip(Size size) {
    // 132*144, 10*10 corner
    final path = Path();
    double ratio = size.width / size.height;
    bool shouldClip;
    if (clip != null) {
      shouldClip = clip!;
    } else {
      shouldClip = (ratio / (132 / 144) - 1).abs() < 0.05;
    }
    if (shouldClip) {
      double dx = 10 / 132 * size.width;
      path.moveTo(0, size.height);
      path.lineTo(size.width, size.height);
      path.lineTo(size.width, dx);
      path.lineTo(size.width - dx, 0);
      path.lineTo(dx, 0);
      path.lineTo(0, dx);
      path.close();
    } else {
      path.moveTo(0, 0);
      path.lineTo(size.width, 0);
      path.lineTo(size.width, size.height);
      path.lineTo(0, size.height);
      path.close();
    }
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) {
    return oldClipper is! TopCornerClipper ||
        oldClipper.clip != oldClipper.clip;
  }
}
