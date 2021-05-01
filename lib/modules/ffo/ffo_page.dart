library ffo;

import 'dart:async';
import 'dart:math';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:catcher/core/catcher.dart';
import 'package:chaldea/components/components.dart';
import 'package:chaldea/components/git_tool.dart';
import 'package:csv/csv.dart';
import 'package:file_picker_cross/file_picker_cross.dart';
import 'package:flutter/foundation.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:open_file/open_file.dart';
import 'package:path/path.dart' show dirname;
import 'package:url_launcher/url_launcher.dart';

part 'ffo_data.dart';

part 'ffo_download_dialog.dart';

part 'ffo_summon_page.dart';

String get _baseDir => join(db.paths.appPath, 'ffo');

class FreedomOrderPage extends StatefulWidget {
  @override
  _FreedomOrderPageState createState() => _FreedomOrderPageState();
}

class _FreedomOrderPageState extends State<FreedomOrderPage> {
  Map<int, FFOPart> parts = {};

  FFOParams params = FFOParams();
  bool sameSvt = false;

  @override
  void initState() {
    super.initState();
    loadCSV();
  }

  @override
  void dispose() {
    super.dispose();
    params.dispose();
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
                child: FFOCardWidget(params: params),
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
              alignment: WrapAlignment.center,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 6,
              runSpacing: 6,
              children: [
                CheckboxWithLabel(
                  value: params.cropNormalizedSize,
                  label: Text(S.current.ffo_crop),
                  onChanged: (v) async {
                    if (v != null) {
                      params.cropNormalizedSize = v;
                    }
                    setState(() {});
                  },
                ),
                CheckboxWithLabel(
                  value: sameSvt,
                  label: Text(S.current.ffo_same_svt),
                  onChanged: (v) async {
                    if (v == null) return;
                    sameSvt = v;
                    if (sameSvt) {
                      FFOPart? _part =
                          params.parts.firstWhereOrNull((e) => e != null);
                      await params.setPart(_part);
                    }
                    setState(() {});
                  },
                ),
                ElevatedButton(
                  onPressed: params.isEmpty
                      ? null
                      : () => params.saveTo(context).catchError((e, s) {
                            EasyLoading.showError('Save picture failed!\n$e');
                            logger.e('save picture failed', e, s);
                          }),
                  child: Text(S.current.save),
                ),
                ElevatedButton(
                  onPressed: () {
                    SplitRoute.push(
                      context: context,
                      builder: (context, _) => FFOSummonPage(partsDta: parts),
                      detail: true,
                    );
                  },
                  child: Text(S.current.summon),
                ),
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
  - 保存：保存PNG图片，移动端可选择是否导入到相册，抽卡页面可单击卡牌全屏/长按保存
4.解包数据来源于icyalala@NGA，稍作修正，从者编号可能与其他来源有所不同（主要是乌冬从者）
5.使用Gitee下载源时两个压缩包均需下载导入"""),
        ).showDialog(context);
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
    final FFOPart? _part = params.parts[where];
    String partName = [
      S.current.ffo_head,
      S.current.ffo_body,
      S.current.ffo_background
    ][where];
    File iconFile = File(join(
        _baseDir,
        'UI',
        [
          'icon_servant_head_on.png',
          'icon_servant_body_on.png',
          'icon_servant_bg_on.png'
        ][where]));
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
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.file(
                iconFile,
                width: 16,
                height: 16,
                errorBuilder: (context, e, s) => Container(),
              ),
              Text(partName),
            ],
          ),
        ],
      ),
      onTap: () {
        final clearBtn = TextButton(
          onPressed: () async {
            await params.setPart(null, sameSvt ? null : where);
            Navigator.of(context).pop();
            setState(() {});
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
            child: Padding(
              padding: EdgeInsets.all(2),
              child: child,
            ),
            onTap: () async {
              await params.setPart(svt, sameSvt ? null : where);
              Navigator.pop(context);
              setState(() {});
            },
          );
          children.add(child);
        });
        showModalBottomSheet(
          context: context,
          builder: (context) => Scaffold(
            appBar: AppBar(
              leading: BackButton(),
              title: Text('Choose $partName'),
              actions: [clearBtn],
            ),
            body: LayoutBuilder(builder: (context, constraints) {
              print(constraints);
              return GridView.count(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                crossAxisCount: constraints.maxWidth ~/ 56,
                children: children,
              );
            }),
          ),
          isScrollControlled: true,
        );
        // SimpleCancelOkDialog(
        //   hideOk: true,
        //   title: Text('Choose $partName'),
        //   actions: [clearBtn],
        //   content: Builder(builder: (context) {
        //     final size = MediaQuery.of(context).size;
        //     return SizedBox.fromSize(
        //       size: size,
        //       child: GridView.count(
        //         crossAxisCount: (MediaQuery.of(context).size.width - 128) ~/ 56,
        //         children: children,
        //       ),
        //     );
        //   }),
        // ).showDialog(context);
      },
    );
  }

  // load and save
  void loadCSV() {
    final csvFile = File(join(_baseDir, 'CSV', 'ServantDB-Parts.csv'));
    if (!csvFile.existsSync()) return;
    try {
      parts.clear();
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
    } catch (e, s) {
      logger.e('load FFO data failed', e, s);
      logger.e(csvFile.readAsStringSync());
      SimpleCancelOkDialog(
        title: Text('Load FFO data error'),
        content: Text('$e\nTry to import data again'),
      ).showDialog(context);
      Catcher.reportCheckedError(e, s);
    }
  }
}
