import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui';

/// Calculates face rectangles in a merged CharaFigure image.
///
/// Source-image layout rules:
/// - A normal base texture is 1024 pixels high: its visible figure region is
///   y=0..768, at the image's actual width. Face packing is always limited to
///   x=0..1024.
/// - Legacy/default 256x256 faces use the four P1 slots at y=768. Their later
///   texture pages begin at P2 (y=1024).
/// - A non-default face size uses a separate `f` texture from face 1, so its
///   first page begins at P2 even when its height is <= 256. Each following
///   texture page is 1024 pixels high and starts packing at its top edge.
/// - If the non-merged base texture's height is not 1024, the whole texture is
///   the base figure. It contributes no face slots; face pages start after it.
/// - A face never crosses a texture-page boundary; bottom-cropped slots are
///   ignored. [availableFaceCount] removes only trailing all-transparent slots,
///   preserving transparent gaps before the last visible expression.
///
/// Examples verified from JP assets:
/// - 1024 wide: `1098297000` ([280,256]) starts at P2 although h=256;
///   `1047300` ([266,256]) does the same. `1064300` ([256,322]) starts at P2.
/// - No current JP script has faceSize.height < 256; this branch must still
///   start at P2 because the source is a separate `f` texture.
/// - 2048 wide: `1065000` (null) uses legacy P1 slots; `1065000` Form 1 is
///   also 2048 wide with the same default layout.
/// - Form examples: `10017910` Form 1 ([309,256]) starts at P2; `1064000`
///   Form 1 is 2048 wide with [256,284] and starts at P2.
/// - Full-height base: `11023000` Forms 1-4 use a 2048x2048 base texture, so
///   the merged sheet's face packing begins at y=2048.
///
/// The P1/P2 decision comes from the source texture type, not from deflating
/// the draw rectangle. Sampling deflation only prevents edge bleeding.
class CharaFigureLayout {
  static const int pageHeight = 1024;
  static const int defaultBaseFigureHeight = 768;
  static const int maxFacePackingWidth = 1024;

  final int imageWidth;
  final int imageHeight;
  final int baseFigureHeight;
  final int faceWidth;
  final int faceHeight;

  late final bool isDefaultFaceSize = faceWidth == 256 && faceHeight == 256;

  CharaFigureLayout({
    required this.imageWidth,
    required this.imageHeight,
    required List<int> faceSize,
    this.baseFigureHeight = defaultBaseFigureHeight,
  }) : faceWidth = faceSize[0],
       faceHeight = faceSize[1];

  Size get outputSize => Size(imageWidth.toDouble(), baseFigureHeight.toDouble());

  late final List<Rect> faceRects = List.unmodifiable(_buildFaceRects());

  int availableFaceCount(Uint8List rgbaBytes) {
    final expectedLength = imageWidth * imageHeight * 4;
    if (rgbaBytes.lengthInBytes < expectedLength) {
      throw ArgumentError.value(
        rgbaBytes.lengthInBytes,
        'rgbaBytes.lengthInBytes',
        'Expected at least $expectedLength',
      );
    }

    for (int index = faceRects.length - 1; index >= 0; index--) {
      final rect = faceRects[index];
      final left = rect.left.toInt();
      final top = rect.top.toInt();
      final right = rect.right.toInt();
      final bottom = rect.bottom.toInt();
      for (int y = top; y < bottom; y++) {
        int alphaOffset = (y * imageWidth + left) * 4 + 3;
        for (int x = left; x < right; x++, alphaOffset += 4) {
          if (rgbaBytes[alphaOffset] != 0) return index + 1;
        }
      }
    }
    return 0;
  }

  List<Rect> _buildFaceRects() {
    if (imageWidth <= 0 || imageHeight <= 0 || faceWidth <= 0 || faceHeight <= 0) return const [];

    final packingWidth = math.min(maxFacePackingWidth, imageWidth);
    final columnCount = packingWidth ~/ faceWidth;
    if (columnCount <= 0) return const [];

    final rects = <Rect>[];
    final firstPageTop = baseFigureHeight != defaultBaseFigureHeight
        ? baseFigureHeight
        : (isDefaultFaceSize ? 0 : pageHeight);
    for (int pageTop = firstPageTop; pageTop < imageHeight; pageTop += pageHeight) {
      final rowStart = pageTop == 0 ? baseFigureHeight : pageTop;
      final pageBottom = math.min(pageTop + pageHeight, imageHeight);
      for (int y = rowStart; y + faceHeight <= pageBottom; y += faceHeight) {
        for (int column = 0; column < columnCount; column++) {
          rects.add(
            Rect.fromLTWH((column * faceWidth).toDouble(), y.toDouble(), faceWidth.toDouble(), faceHeight.toDouble()),
          );
        }
      }
    }
    return rects;
  }
}
