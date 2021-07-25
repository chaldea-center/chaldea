import 'dart:math' as math;
import 'dart:typed_data';

import 'package:image/image.dart' as libImage;

import 'logger.dart';

Uint8List compressToJpg({
  required Uint8List src,
  int quality = 90,
  int? maxWidth,
  int? maxHeight,
}) {
  assert(maxWidth == null || maxWidth > 0);
  assert(maxHeight == null || maxHeight > 0);
  libImage.Image? srcImage = libImage.decodeImage(src);
  if (srcImage == null) {
    logger.e('decode image failed');
    return src;
  }
  double? r; // src/dest
  if (maxWidth != null && srcImage.width > maxWidth) {
    r = srcImage.width / maxWidth;
  }
  if (maxHeight != null && srcImage.height > maxHeight) {
    double r2 = srcImage.height / maxHeight;
    r = r == null ? r2 : math.min(r, r2);
  }
  libImage.Image destImage = srcImage;
  if (r != null) {
    destImage = libImage.copyResize(srcImage,
        width: (srcImage.width / r).round(),
        height: (srcImage.height / r).round());
  }
  final dest =
      Uint8List.fromList(libImage.encodeJpg(destImage, quality: quality));
  logger.i('compress image(q=$quality): ${src.length ~/ 1024}KB'
      ' ${srcImage.width}x${srcImage.height} ->'
      ' ${dest.length ~/ 1024}KB ${destImage.width}x${destImage.height}');
  return dest;
}
