import 'dart:async';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';

import 'package:material_ui/material_ui.dart';

/// Captures a widget that is currently rendered on screen.
///
/// Local replacement for the unmaintained `screenshot` package (last release
/// 3.0.0, May 2024). That package was a thin wrapper over [RepaintBoundary] +
/// [RenderRepaintBoundary.toImage]; this is the same thing, ~35 lines, with the
/// same `Screenshot` / `ScreenshotController` API so call sites stay unchanged.
///
/// Platform views cannot be captured, see flutter/flutter#25306.
class ScreenshotController {
  final GlobalKey _containerKey = GlobalKey();

  /// Renders the wrapped widget and encodes it as PNG.
  Future<Uint8List?> capture({double? pixelRatio, Duration delay = const Duration(milliseconds: 20)}) async {
    // A delay is required before capturing, see flutter/flutter#22308.
    await Future<void>.delayed(delay);
    final ui.Image? image = await captureAsUiImage(delay: Duration.zero, pixelRatio: pixelRatio);
    if (image == null) return null;
    final ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    image.dispose();
    return byteData?.buffer.asUint8List();
  }

  /// Renders the wrapped widget into a raw [ui.Image].
  ///
  /// When [pixelRatio] is null the device pixel ratio of the current view is
  /// used.
  Future<ui.Image?> captureAsUiImage({
    double? pixelRatio = 1,
    Duration delay = const Duration(milliseconds: 20),
  }) async {
    await Future<void>.delayed(delay);
    final BuildContext? context = _containerKey.currentContext;
    if (context == null || !context.mounted) return null;
    final RenderObject? renderObject = context.findRenderObject();
    if (renderObject is! RenderRepaintBoundary) return null;
    pixelRatio ??= MediaQuery.maybeDevicePixelRatioOf(context);
    return renderObject.toImage(pixelRatio: pixelRatio ?? 1);
  }
}

/// Wraps [child] in a [RepaintBoundary] that [controller] can capture.
class Screenshot extends StatelessWidget {
  final Widget? child;
  final ScreenshotController controller;

  const Screenshot({super.key, required this.child, required this.controller});

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(key: controller._containerKey, child: child);
  }
}
