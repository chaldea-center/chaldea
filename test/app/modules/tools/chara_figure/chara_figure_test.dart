import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';

import 'package:chaldea/app/modules/tools/chara_figure/custom_chara_figure.dart';
import 'package:chaldea/app/modules/tools/chara_figure/layout.dart';
import 'package:chaldea/app/modules/tools/chara_figure/source.dart';
import 'package:chaldea/models/models.dart';

Future<Image> createFigureImage({
  required int width,
  required int height,
  required Rect faceRect,
  int baseFigureHeight = 768,
}) async {
  final recorder = PictureRecorder();
  final canvas = Canvas(recorder);
  canvas.drawRect(
    Rect.fromLTWH(0, 0, width.toDouble(), baseFigureHeight.toDouble()),
    Paint()..color = const Color(0xFFFF0000),
  );
  canvas.drawRect(faceRect, Paint()..color = const Color(0xFF0000FF));
  return recorder.endRecording().toImage(width, height);
}

Future<Color> readPixel(Image image, int x, int y) async {
  final data = await image.toByteData(format: ImageByteFormat.rawRgba);
  final bytes = data!.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
  final offset = (y * image.width + x) * 4;
  return Color.fromARGB(bytes[offset + 3], bytes[offset], bytes[offset + 1], bytes[offset + 2]);
}

void main() {
  group('CharaFigureSource', () {
    test('parses numeric IDs as JP form 0', () {
      final source = CharaFigureSource.tryParse('1065000');

      expect(source?.region, Region.jp);
      expect(source?.id, 1065000);
      expect(source?.form, 0);
      expect(source?.imageCandidates, [
        'https://static.atlasacademy.io/JP/CharaFigure/1065000/1065000_merged.png',
        'https://static.atlasacademy.io/JP/CharaFigure/1065000/1065000.png',
      ]);
    });

    test('parses form 0 merged and non-merged URLs identically', () {
      final merged = CharaFigureSource.tryParse(
        'https://static.atlasacademy.io/NA/CharaFigure/1065000/1065000_merged.png',
      );
      final nonMerged = CharaFigureSource.tryParse('https://static.atlasacademy.io/NA/CharaFigure/1065000/1065000.png');

      expect(merged?.region, Region.na);
      expect(merged?.id, 1065000);
      expect(merged?.form, 0);
      expect(nonMerged?.region, merged?.region);
      expect(nonMerged?.id, merged?.id);
      expect(nonMerged?.form, merged?.form);
      expect(nonMerged?.imageCandidates.first, endsWith('/1065000_merged.png'));
    });

    test('parses positive forms and generates canonical candidates', () {
      final merged = CharaFigureSource.tryParse(
        'https://static.atlasacademy.io/JP/CharaFigure/Form/10/4053001/4053001_merged.png',
      );
      final nonMerged = CharaFigureSource.tryParse('/CharaFigure/Form/10/4053001/4053001.png');

      expect(merged?.region, Region.jp);
      expect(merged?.id, 4053001);
      expect(merged?.form, 10);
      expect(nonMerged?.region, merged?.region);
      expect(nonMerged?.id, merged?.id);
      expect(nonMerged?.form, merged?.form);
      expect(merged?.imageCandidates, [
        'https://static.atlasacademy.io/JP/CharaFigure/Form/10/4053001/4053001_merged.png',
        'https://static.atlasacademy.io/JP/CharaFigure/Form/10/4053001/4053001.png',
      ]);
    });

    test('resets form-bound state but keeps ID-bound scripts', () {
      final source = CharaFigureSource(region: Region.tw, id: 4053001, form: 10)
        ..face = 3
        ..figureWidth = 2048
        ..faceCount = 12
        ..baseFigureHeight = 2048
        ..isBaseFigureHeightDetected = true
        ..script = SvtScript(id: 4053001, form: 10)
        ..scripts = [SvtScript(id: 4053001, form: 10)];

      source.form = 2;
      source.reset();

      expect(source.form, 2);
      expect(source.face, 0);
      expect(source.figureWidth, 1024);
      expect(source.faceCount, 0);
      expect(source.baseFigureHeight, 768);
      expect(source.isBaseFigureHeightDetected, isNull);
      expect(source.script, isNull);
      expect(source.scripts, hasLength(1));
    });

    test('rejects unrelated input and the reversed form path', () {
      expect(CharaFigureSource.tryParse('not a figure'), isNull);
      expect(CharaFigureSource.tryParse('/CharaFigure/4053001/Form/10/4053001.png'), isNull);
      expect(CharaFigureSource.tryParse('/CharaFigure/4053001/1065000.png'), isNull);
    });
  });

  group('SvtScriptExtendData.getFaceSize', () {
    test('normalizes default, scalar, and rectangular values', () {
      expect(SvtScriptExtendData().getFaceSize(), [256, 256]);
      expect(SvtScriptExtendData(faceSize: 320).getFaceSize(), [320, 320]);
      expect(SvtScriptExtendData(faceSize: [309, 256]).getFaceSize(), [309, 256]);
    });

    test('falls back for malformed or non-positive values', () {
      expect(SvtScriptExtendData(faceSize: [309]).getFaceSize(), [256, 256]);
      expect(SvtScriptExtendData(faceSize: [309, 0]).getFaceSize(), [256, 256]);
      expect(SvtScriptExtendData(faceSize: '309x256').getFaceSize(), [256, 256]);
    });

    test('reads rectangular face size returned by the API', () {
      final data = SvtScriptExtendData.fromJson({
        'faceSize': 320,
        'faceSizeRect': [309, 256],
      });

      expect(data.getFaceSize(), [309, 256]);
      expect(data.toJson()['faceSizeRect'], [309, 256]);
    });
  });

  group('CharaFigureLayout', () {
    test('lays out rectangular expressions across page boundaries', () {
      final layout = CharaFigureLayout(imageWidth: 1024, imageHeight: 2560, faceSize: [309, 256]);

      expect(layout.faceRects, hasLength(18));
      expect(layout.faceRects[0], const Rect.fromLTWH(0, 1024, 309, 256));
      expect(layout.faceRects[2], const Rect.fromLTWH(618, 1024, 309, 256));
      expect(layout.faceRects[12], const Rect.fromLTWH(0, 2048, 309, 256));
      expect(layout.faceRects[17], const Rect.fromLTWH(618, 2304, 309, 256));
    });

    test('trims only trailing fully transparent expressions', () {
      const imageWidth = 1024;
      const imageHeight = 1024;
      final layout = CharaFigureLayout(imageWidth: imageWidth, imageHeight: imageHeight, faceSize: [256, 256]);
      final rgba = Uint8List(imageWidth * imageHeight * 4);
      rgba[((768 * imageWidth) * 4) + 3] = 255;
      rgba[((768 * imageWidth + 512) * 4) + 3] = 255;

      expect(layout.availableFaceCount(rgba), 3);
      expect(layout.availableFaceCount(Uint8List(imageWidth * imageHeight * 4)), 0);
    });

    test('keeps a 2048-wide figure while packing faces into 1024 pixels', () {
      final layout = CharaFigureLayout(imageWidth: 2048, imageHeight: 1536, faceSize: [256, 256]);

      expect(layout.outputSize, const Size(2048, 768));
      expect(layout.faceRects, hasLength(12));
      expect(layout.faceRects[3], const Rect.fromLTWH(768, 768, 256, 256));
      expect(layout.faceRects[4], const Rect.fromLTWH(0, 1024, 256, 256));
    });

    test('starts tall faces at P2 and never crosses a page boundary', () {
      final layout = CharaFigureLayout(imageWidth: 2048, imageHeight: 3584, faceSize: [256, 284]);

      expect(layout.faceRects, hasLength(28));
      expect(layout.faceRects.first, const Rect.fromLTWH(0, 1024, 256, 284));
      expect(layout.faceRects[8], const Rect.fromLTWH(0, 1592, 256, 284));
      expect(layout.faceRects[12], const Rect.fromLTWH(0, 2048, 256, 284));
      expect(layout.faceRects.last, const Rect.fromLTWH(768, 3072, 256, 284));
    });

    test('uses a full-height base texture and starts faces after it', () {
      final layout = CharaFigureLayout(
        imageWidth: 2048,
        imageHeight: 4096,
        faceSize: [256, 256],
        baseFigureHeight: 2048,
      );

      expect(layout.outputSize, const Size(2048, 2048));
      expect(layout.faceRects, hasLength(32));
      expect(layout.faceRects.first, const Rect.fromLTWH(0, 2048, 256, 256));
      expect(layout.faceRects.last, const Rect.fromLTWH(768, 3840, 256, 256));
    });
  });

  test('CharaFigurePainter composes a 2048-wide figure in original pixel coordinates', () async {
    final source = await createFigureImage(width: 2048, height: 1536, faceRect: const Rect.fromLTWH(0, 768, 256, 256));
    addTearDown(source.dispose);
    final script = SvtScript(id: 1, faceX: 1000, faceY: 100);
    final recorder = PictureRecorder();
    final canvas = Canvas(recorder);

    CharaFigurePainter(
      figure: source,
      face: 1,
      script: script,
      faceOnly: false,
      applyOffset: false,
    ).paint(canvas, const Size(2048, 768));
    final output = await recorder.endRecording().toImage(2048, 768);
    addTearDown(output.dispose);

    expect(await readPixel(output, 1128, 228), const Color(0xFF0000FF));
    expect(await readPixel(output, 999, 228), const Color(0xFFFF0000));
  });

  test('CharaFigurePainter deflates the base figure by one logical pixel', () async {
    final source = await createFigureImage(width: 1024, height: 1024, faceRect: Rect.zero);
    addTearDown(source.dispose);
    final recorder = PictureRecorder();
    final canvas = Canvas(recorder);

    CharaFigurePainter(
      figure: source,
      face: 0,
      script: SvtScript(id: 1),
      faceOnly: false,
      applyOffset: false,
    ).paint(canvas, const Size(1024, 768));
    final output = await recorder.endRecording().toImage(1024, 768);
    addTearDown(output.dispose);

    expect(await readPixel(output, 512, 766), const Color(0xFFFF0000));
    expect((await readPixel(output, 512, 767)).a, 0);
  });

  test('CharaFigurePainter renders the full detected base height', () async {
    final source = await createFigureImage(
      width: 2048,
      height: 4096,
      faceRect: const Rect.fromLTWH(0, 2048, 256, 256),
      baseFigureHeight: 2048,
    );
    addTearDown(source.dispose);
    final recorder = PictureRecorder();

    CharaFigurePainter(
      figure: source,
      face: 0,
      script: SvtScript(id: 1),
      faceOnly: false,
      applyOffset: false,
      baseFigureHeight: 2048,
    ).paint(Canvas(recorder), const Size(2048, 2048));
    final output = await recorder.endRecording().toImage(2048, 2048);
    addTearDown(output.dispose);

    expect(await readPixel(output, 1024, 2046), const Color(0xFFFF0000));
    expect((await readPixel(output, 1024, 2047)).a, 0);
  });

  test('CharaFigurePainter keeps rectangular faces proportional in square thumbnails', () async {
    final source = await createFigureImage(width: 1024, height: 1280, faceRect: const Rect.fromLTWH(0, 1024, 309, 256));
    addTearDown(source.dispose);
    final script = SvtScript(id: 1, extendData: SvtScriptExtendData(faceSize: [309, 256]));
    final recorder = PictureRecorder();
    final canvas = Canvas(recorder);

    CharaFigurePainter(figure: source, face: 1, script: script, faceOnly: true).paint(canvas, const Size(100, 100));
    final output = await recorder.endRecording().toImage(100, 100);
    addTearDown(output.dispose);

    expect((await readPixel(output, 50, 2)).a, 0);
    expect(await readPixel(output, 50, 50), const Color(0xFF0000FF));
  });
}
