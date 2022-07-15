import 'dart:math' as math;
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:image/image.dart' as lib_image;
import 'package:worker_manager/worker_manager.dart';

import 'package:chaldea/packages/logger.dart';
import 'package:chaldea/utils/utils.dart';

Future<Uint8List> compressToJpgAsync({
  required Uint8List src,
  int quality = 90,
  int? maxWidth,
  int? maxHeight,
}) async {
  return Executor().execute(
      fun4: _compressToJpg,
      arg1: src,
      arg2: quality,
      arg3: maxWidth,
      arg4: maxHeight);
}

Uint8List compressToJpg({
  required Uint8List src,
  int quality = 90,
  int? maxWidth,
  int? maxHeight,
}) =>
    _compressToJpg(src, quality, maxWidth, maxHeight, null);

Uint8List _compressToJpg(Uint8List src, int quality, int? maxWidth,
    int? maxHeight, TypeSendPort? port) {
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

class ImageUtil {
  const ImageUtil._();

  static const ColorFilter greyscalBeast = ColorFilter.matrix(<double>[
    // grey scale for beast icon
    0.8, 0.15, 0.05, 0, 0,
    0.8, 0.15, 0.05, 0, 0,
    0.8, 0.15, 0.05, 0, 0,
    0, 0, 0, 1, 0,
  ]);

  static Widget getChaldeaBackground(BuildContext context,
      {double height = 240}) {
    Widget img = Image(
      image: const AssetImage("res/img/chaldea.png"),
      filterQuality: FilterQuality.high,
      height: height,
    );
    if (Utility.isDarkMode(context)) {
      // assume r=g=b
      int b = Theme.of(context).scaffoldBackgroundColor.blue;
      if (!kIsWeb) {
        double v = (255 - b) / 255;
        img = ColorFiltered(
          colorFilter: ColorFilter.matrix([
            //R G  B  A  Const
            -v, 0, 0, 0, 255,
            0, -v, 0, 0, 255,
            0, 0, -v, 0, 255,
            0, 0, 0, 0.8, 0,
          ]),
          child: img,
        );
      } else {
        img = ColorFiltered(
          colorFilter: const ColorFilter.matrix([
            // R    G       B       A  Const
            0.2126, 0.5152, 0.0722, 0, 0,
            0.2126, 0.5152, 0.0722, 0, 0,
            0.2126, 0.5152, 0.0722, 0, 0,
            0, 0, 0, 1, 0,
          ]),
          child: img,
        );
      }
    }
    return img;
  }
}
