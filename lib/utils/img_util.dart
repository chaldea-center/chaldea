import 'dart:math' as math;
import 'dart:typed_data';

import 'package:image/image.dart' as lib_image;

import 'package:chaldea/packages/logger.dart';

Uint8List compressToJpg({
  required Uint8List src,
  int quality = 90,
  int? maxWidth,
  int? maxHeight,
}) {
  assert(maxWidth == null || maxWidth > 0);
  assert(maxHeight == null || maxHeight > 0);
  lib_image.Image? srcImage = lib_image.decodeImage(src);
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
  lib_image.Image destImage = srcImage;
  if (r != null) {
    destImage = lib_image.copyResize(srcImage,
        width: (srcImage.width / r).round(),
        height: (srcImage.height / r).round());
  }
  final dest =
      Uint8List.fromList(lib_image.encodeJpg(destImage, quality: quality));
  logger.i('compress image(q=$quality): ${src.length ~/ 1024}KB'
      ' ${srcImage.width}x${srcImage.height} ->'
      ' ${dest.length ~/ 1024}KB ${destImage.width}x${destImage.height}');
  return dest;
}
