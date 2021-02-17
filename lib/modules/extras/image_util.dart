//@dart=2.12
import 'dart:math';
import 'dart:typed_data';

import 'package:image/image.dart' as img;

/// [images] and returned image are binary data of files
Uint8List mergeImages(List<Uint8List> bytesList, {bool vertical = true}) {
  print('merge ${bytesList.length} images');
  List<img.Image> images =
      bytesList.map((e) => img.decodeImage(e.cast<int>())).toList();
  List<int> widths = [], heights = [];
  images.forEach((e) {
    widths.add(e.width);
    heights.add(e.height);
  });
  print(widths);
  print(heights);

  int width, height;
  if (vertical) {
    if (Set.from(widths).length != 1)
      throw ArgumentError('images should have the same width in vertical mode');
    width = widths.first;
    height = sum(heights);
  } else {
    if (Set.from(heights).length != 1)
      throw ArgumentError(
          'images should have the same height in horizontal mode');
    width = sum(widths);
    height = heights.first;
  }
  print('new image: $width*$height');
  int acc = 0; // acc sum for heights or widths
  img.Image mergedImage = img.Image(width, height);
  int xx = 0, yy = 0; // [x,y] for merged image
  for (int imgNo = 0; imgNo < images.length; imgNo++) {
    final image = images[imgNo];
    // final bytes = image.getBytes();
    for (int x = 0; x < image.width; x++) {
      for (int y = 0; y < image.height; y++) {
        xx = (vertical ? 0 : acc) + x;
        yy = (vertical ? acc : 0) + y;
        mergedImage.setPixel(xx, yy, image.getPixel(x, y));
        // mergedBytes[xx + yy * width] = bytes[x + y * image.width];
      }
    }
    acc += vertical ? image.height : image.width;
  }
  // final mergedImage = img.Image.fromBytes(width, height, mergedBytes);
  // print()
  return Uint8List.fromList(img.encodeJpg(mergedImage));
}

void templateMatch(Uint8List srcBytes, Map<String, Uint8List> templatesBytes,
    double aInit, double bInit) {
  final stopwatch = Stopwatch()..start();
  img.Image src = img.decodeImage(srcBytes);
  int left = (aInit * src.width).toInt();
  int right = (bInit * src.width).toInt();
  int width = right - left;
  Map<String, img.Image> tmplImages = {};
  Map<String, List<int>> tmplHists = {};
  templatesBytes.forEach((key, value) {
    tmplImages[key] = img.copyResize(img.decodeImage(value), width: width);
    tmplHists[key] = histogram(tmplImages[key]!);
  });
  for (String key in tmplImages.keys) {
    final tmpl = tmplImages[key]!;
    double simMax = 0;
    int yMax = -1;
    for (int y = 0; y < src.height - tmpl.height; y++) {
      //
      final cropped = img.copyCrop(src, left, y, tmpl.width, tmpl.height);
      double sim = calHistSim(tmplHists[key]!, histogram(cropped));
      if (sim > simMax) {
        simMax = sim;
        yMax = y;
      }
    }
    print('Max: $key\t @ $yMax: ${simMax.toStringAsFixed(3)}');
  }
  print('stopwatch: ${stopwatch.elapsedMilliseconds} ms');
}

List<int> histogram(img.Image image) {
  List<int> hist = List.filled(256 * 3, 0);
  image = img.copyCrop(image, image.width ~/ 4, image.height ~/ 4,
      image.width ~/ 2, image.height ~/ 2);
  for (int x = 0; x < image.width; x++) {
    for (int y = 0; y < image.height; y++) {
      final pixel = image.getPixel(x, y);
      hist[img.getRed(pixel)] += 1;
      hist[img.getGreen(pixel) + 256] += 1;
      hist[img.getGreen(pixel) + 512] += 1;
    }
  }
  return hist;
}

double calHistSim(List<int> hist1, List<int> hist2) {
  // diff = [1 - (0 if _l == _r else float(abs(_l - _r)) / max(_l, _r)) for _l, _r in zip(lh, rh) if _l + _r != 0]
  assert(hist1.length == 256 * 3 && hist2.length == 256 * 3);
  List<double> diff = [];
  for (int i = 0; i < 256; i++) {
    int _l = hist1[i], _r = hist2[i];
    if (_l + _r > 0) {
      if (_l == _r)
        diff.add(0);
      else
        diff.add((_l - _r).abs() / max(_l, _r));
    }
  }
  return sum(diff) / diff.length;
}

T sum<T extends num>(Iterable<T> list) {
  T initVal = T == int ? 0 as T : 0.0 as T;
  return list.fold(initVal, (p, c) => (p + c) as T);
}
