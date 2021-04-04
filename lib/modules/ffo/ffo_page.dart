library ffo;

import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:chaldea/components/components.dart';
import 'package:chaldea/components/git_tool.dart';
import 'package:csv/csv.dart';
import 'package:file_picker_cross/file_picker_cross.dart';
import 'package:image/image.dart' as IMAGE;
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:url_launcher/url_launcher.dart';

part 'ffo_data.dart';

part 'ffo_download_dialog.dart';

String get _baseDir => join(db.paths.appPath, 'ffo');

class FreedomOrderPage extends StatefulWidget {
  @override
  _FreedomOrderPageState createState() => _FreedomOrderPageState();
}

class _FreedomOrderPageState extends State<FreedomOrderPage> {
  bool crop = false;
  bool sameSvt = false;

  // 1024x1024
  // 512*720
  FFOPart? headPart;
  FFOPart? bodyPart;
  FFOPart? landPart;

  Map<int, FFOPart> parts = {};
  final List<ui.Image?> images = List.filled(8, null, growable: false);

  Uint8List? imgData;

  @override
  void initState() {
    super.initState();
    loadCSV();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(),
        title: Text('Freedom Order'),
        centerTitle: true,
        actions: [
          helpButton,
          importButton,
        ],
      ),
      body: Column(
        children: [
          if (parts.isEmpty)
            Expanded(
              child: Center(
                child: Text(S.current.ffo_missing_data_hint),
              ),
            ),
          if (parts.isNotEmpty)
            Expanded(
              child: Center(
                child: imgData == null
                    ? null
                    : FittedBox(
                        fit: BoxFit.contain,
                        child: Container(
                          // decoration: BoxDecoration(border: Border.all()),
                          width: 1024,
                          height: 1024,
                          child: Image.memory(
                            imgData!,
                          ),
                        ),
                      ),
              ),
            ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: Wrap(
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 6,
              runSpacing: 6,
              children: [
                partChooser(0),
                partChooser(1),
                partChooser(2),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: Wrap(
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 6,
              runSpacing: 6,
              children: [
                CheckboxWithLabel(
                  value: crop,
                  label: Text(S.current.ffo_crop),
                  onChanged: (v) {
                    setState(() {
                      crop = v ?? crop;
                    });
                    drawCanvas();
                  },
                ),
                CheckboxWithLabel(
                  value: sameSvt,
                  label: Text(S.current.ffo_same_svt),
                  onChanged: (v) async {
                    sameSvt = v ?? sameSvt;
                    if (sameSvt) {
                      FFOPart? _part = [headPart, bodyPart, landPart]
                          .firstWhereOrNull((e) => e != null);
                      await setPart(_part);
                      await drawCanvas();
                    }
                    setState(() {});
                  },
                ),
                ElevatedButton(
                  onPressed: (headPart == null &&
                              bodyPart == null &&
                              landPart == null) ||
                          imgData == null
                      ? null
                      : saveImage,
                  child: Text(S.current.save),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget get helpButton {
    return IconButton(
      onPressed: () {
        SimpleCancelOkDialog(
          scrollable: true,
          title: Text(S.current.help),
          content:
              Text("""1.初次使用请点击右上角导入按钮，从gitee/github releases下载ffo-data资源包并导入
2.可自定义任意头部、身体、背景，注意部分从者可能没有某些部件，如boss龙娘
3.功能说明
  - 裁剪：不显示超出背景框的部分
  - 同一从者：头部/身体/背景使用同一从者资源
  - 保存：保存PNG图片，移动端可选择是否导入到相册
4.解包数据来源于icyalala@NGA，稍作修正，从者编号可能与其他来源有所不同（主要是乌冬从者）"""),
        ).show(context);
      },
      icon: Icon(Icons.help_outline),
      tooltip: S.current.help,
    );
  }

  Widget get importButton {
    return IconButton(
      tooltip: 'Import FFO data',
      onPressed: () async {
        showDialog(
          context: context,
          builder: (context) => FfoDownloadDialog(
            onSuccess: () => loadCSV(),
          ),
        );
      },
      icon: Icon(Icons.download_sharp),
    );
  }

  Widget partChooser(int where) {
    assert(where >= 0 && where < 3);
    final FFOPart? _part = [headPart, bodyPart, landPart][where];
    String partName = [
      S.current.ffo_head,
      S.current.ffo_body,
      S.current.ffo_background
    ][where];
    return InkWell(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _part == null
              ? db.getIconImage(null, height: 72)
              : Image.file(
                  File(join(_baseDir, 'Sprite',
                      'icon_servant_${padSvtId(_part.svtId)}.png')),
                  height: 72),
          Text(partName),
        ],
      ),
      onTap: () {
        final clearBtn = TextButton(
          onPressed: () async {
            await setPart(null, sameSvt ? null : where);
            await drawCanvas();
            Navigator.of(context).pop();
          },
          child: Text(S.current.clear),
        );

        List<Widget> children = [];
        parts.values.forEach((svt) {
          String idString = svt.svtId.toString().padLeft(3, '0');
          File file = File(join(
              db.paths.appPath, 'ffo', 'Sprite', 'icon_servant_$idString.png'));
          if (!file.existsSync()) return;
          Widget child = ImageWithText(
            width: 54,
            text: idString,
            image: Container(
              width: 54,
              height: 54,
              child: Image.file(file, fit: BoxFit.contain),
            ),
            textStyle: TextStyle(fontSize: 12),
          );
          child = GestureDetector(
            child: child,
            onTap: () async {
              await setPart(svt, sameSvt ? null : where);
              await drawCanvas();
              Navigator.pop(context);
            },
          );
          children.add(child);
        });
        SimpleCancelOkDialog(
          hideOk: true,
          title: Text('Choose $partName'),
          actions: [clearBtn],
          content: SingleChildScrollView(
            child: Wrap(
              spacing: 3,
              runSpacing: 3,
              alignment: WrapAlignment.center,
              children: children.reversed.toList(),
            ),
          ),
        ).show(context);
      },
    );
  }

  /// if [where] is null, set all parts
  Future<void> setPart(FFOPart? svt, [int? where]) async {
    if (where == null) {
      await setPart(svt, 0);
      await setPart(svt, 1);
      await setPart(svt, 2);
      return;
    }
    if (svt == null) {
      switch (where) {
        case 0:
          headPart = null;
          images[_HEAD_FRONT_5] = null;
          images[_HEAD_BACK_2] = null;
          break;
        case 1:
          bodyPart = null;
          images[_BODY_FRONT_6] = null;
          images[_BODY_MIDDLE_4] = null;
          images[_BODY_BACK_1] = null;
          images[_BODY_BACK2_3] = null;
          break;
        case 2:
          landPart = null;
          images[_LAND_0] = null;
          images[_LAND_FRONT_7] = null;
          break;
        default:
          throw 'part=$where, not in 0,1,2';
      }
    } else {
      String strId = padSvtId(svt.svtId);
      switch (where) {
        case 0:
          headPart = svt;
          images[_HEAD_FRONT_5] = await _loadImage(
              join(_baseDir, 'Head', 'sv${strId}_head_front.png'));
          images[_HEAD_BACK_2] = await _loadImage(
              join(_baseDir, 'Head', 'sv${strId}_head_back.png'));
          break;
        case 1:
          bodyPart = svt;
          images[_BODY_FRONT_6] = await _loadImage(
              join(_baseDir, 'Body', 'sv${strId}_body_front.png'));
          images[_BODY_MIDDLE_4] = await _loadImage(
              join(_baseDir, 'Body', 'sv${strId}_body_middle.png'));
          images[_BODY_BACK_1] = await _loadImage(
              join(_baseDir, 'Body', 'sv${strId}_body_back.png'));
          images[_BODY_BACK2_3] = await _loadImage(
              join(_baseDir, 'Body', 'sv${strId}_body_back2.png'));
          break;
        case 2:
          landPart = svt;
          images[_LAND_0] =
              await _loadImage(join(_baseDir, 'Land', 'bg_$strId.png'));
          images[_LAND_FRONT_7] =
              await _loadImage(join(_baseDir, 'Land', 'bg_${strId}_front.png'));
          break;
        default:
          throw 'part=$where, not in 0,1,2';
      }
    }
  }

  // drawing
  Future<void> drawCanvas() async {
    final recorder = ui.PictureRecorder();
    final canvas =
        Canvas(recorder, Rect.fromPoints(Offset(0, 0), Offset(1024, 1024)));

    double headScale = 1;
    if (headPart != null && bodyPart != null && headPart!.scale != 0) {
      headScale = bodyPart!.scale / headPart!.scale;
    }

    bool flip = false;
    if ((headPart?.direction == 0 && bodyPart?.direction == 2) ||
        (headPart?.direction == 2 && bodyPart?.direction == 0)) {
      flip = true;
    }

    int headX2 =
        (bodyPart?.headX2 == 0 ? bodyPart?.headX : bodyPart?.headX2) ?? 512;
    int headY2 =
        (bodyPart?.headY2 == 0 ? bodyPart?.headY : bodyPart?.headY2) ?? 512;

    // draw
    if (crop) {
      canvas.clipRect(
          Rect.fromCenter(center: Offset(512, 512), width: 512, height: 720));
    }
    if (images[_LAND_0] != null) {
      canvas.drawImage(images[_LAND_0]!,
          Offset((1024 - 512) / 2, (1024 - 720) / 2), Paint());
    }
    if (images[_BODY_BACK_1] != null) {
      _drawImage(
        canvas: canvas,
        img: images[_BODY_BACK_1]!,
      );
    }
    if (images[_HEAD_BACK_2] != null) {
      _drawImage(
        canvas: canvas,
        img: images[_HEAD_BACK_2]!,
        flip: flip,
        scale: headScale,
        x: headX2 - 512,
        y: headY2 - 512,
      );
    }
    if (images[_BODY_BACK2_3] != null) {
      _drawImage(
        canvas: canvas,
        img: images[_BODY_BACK2_3]!,
      );
    }
    if (images[_BODY_MIDDLE_4] != null) {
      _drawImage(
        canvas: canvas,
        img: images[_BODY_MIDDLE_4]!,
      );
    }
    if (images[_HEAD_FRONT_5] != null) {
      _drawImage(
        canvas: canvas,
        img: images[_HEAD_FRONT_5]!,
        flip: flip,
        scale: headScale,
        x: headX2 - 512,
        y: headY2 - 512,
      );
    }

    if (images[_BODY_FRONT_6] != null) {
      _drawImage(
        canvas: canvas,
        img: images[_BODY_FRONT_6]!,
        // direction: headPart?.direction ?? 0,
      );
    }

    if (images[_LAND_FRONT_7] != null) {
      canvas.drawImage(images[_LAND_FRONT_7]!,
          Offset((1024 - 512) / 2, (1024 - 720) / 2), Paint());
    }
    final picture = recorder.endRecording();
    ui.Image img = await picture.toImage(1024, 1024);
    final byteData = await img.toByteData(format: ui.ImageByteFormat.png);
    imgData = byteData?.buffer.asUint8List();
    if (imgData != null) {
      await precacheImage(MemoryImage(imgData!), context);
    }
    if (mounted) setState(() {});
  }

  void _drawImage({
    required Canvas canvas,
    required ui.Image img,
    bool flip = false,
    double scale = 1,
    int x = 0,
    int y = 0,
  }) {
    double x2 = scale == 1 ? x.toDouble() : x - ((scale - 1) / 2 * img.width);
    double y2 = scale == 1 ? y.toDouble() : y - ((scale - 1) / 2 * img.height);
    int orgX = x;
    // render
    if (flip) {
      canvas.save();
      canvas.translate(img.width + orgX * 2, 0);
      canvas.scale(-1, 1);
    }
    if (scale == 1) {
      canvas.drawImage(img, Offset(x2, y2), Paint());
    } else {
      canvas.drawImageRect(
        img,
        Rect.fromLTWH(0, 0, img.width.toDouble(), img.height.toDouble()),
        Rect.fromLTWH(x2, y2, img.width * scale, img.height * scale),
        Paint(),
      );
    }
    if (flip) {
      canvas.restore();
    }
  }

  // load and save
  void loadCSV() {
    final csvFile = File(join(_baseDir, 'ServantDB-Parts.csv'));
    if (!csvFile.existsSync()) return;
    CsvToListConverter(eol: '\n')
        .convert(csvFile.readAsStringSync().replaceAll('\r\n', '\n'))
        .forEach((row) {
      if (row[0] == 'id') {
        assert(row.length == 10, row.toString());
        return;
      }
      final item = FFOPart.fromList(row);
      parts[item.id] = item;
    });
    print('loaded csv: ${parts.length}');
  }

  Future<ui.Image?> _loadImage(String fp) async {
    final _f = File(fp);
    if (!_f.existsSync()) {
      // print('$fp not exist');
      return null;
    }
    final stream = FileImage(_f).resolve(ImageConfiguration.empty);
    final Completer<ui.Image> completer = Completer();
    stream.addListener(ImageStreamListener((info, _) {
      completer.complete(info.image);
    }, onError: (e, s) {
      EasyLoading.showError(e.toString());
      logger.e('load ui.Image error', e, s);
      completer.complete(null);
    }));
    return completer.future;
  }

  Future<void> saveImage() async {
    final img = IMAGE.decodePng(imgData!.cast<int>());
    final img2 =
        IMAGE.copyCrop(img!, (1024 - 512) ~/ 2, (1024 - 720) ~/ 2, 512, 720);
    String dir = join(db.paths.appPath, 'ffo_output');
    Directory(dir).createSync(recursive: true);
    String fp = join(dir,
        '${headPart?.svtId ?? 0}-${bodyPart?.svtId ?? 0}-${landPart?.svtId ?? 0}.png');
    final file = File(fp);
    await file.writeAsBytes(IMAGE.encodePng(img2));
    SimpleCancelOkDialog(
      title: Text(S.current.saved),
      content: Text(fp),
      hideCancel: true,
      actions: [
        if (Platform.isMacOS || Platform.isWindows)
          TextButton(
            onPressed: () {
              openDesktopPath(dir);
            },
            child: Text(S.current.open),
          ),
        if (Platform.isAndroid || Platform.isIOS)
          TextButton(
            onPressed: () async {
              final result = await ImageGallerySaver.saveFile(fp);
              logger.i('save to gallery: $result');
              if (result['isSuccess'] == true) {
                EasyLoading.showSuccess('Saved to Photos');
                Navigator.pop(context);
              } else {
                EasyLoading.showError(
                    'Save to Photos failed\n${result["errorMessage"]}');
              }
            },
            child: Text(S.current.save_to_photos),
          ),
      ],
    ).show(context);
  }
}
