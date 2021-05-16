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
                child: _fullscreenAndSave(context, params),
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
                  onPressed:
                      params.isEmpty ? null : () => params.saveTo(context),
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
          content: Text(LocalizedText.of(
            chs: """1.初次使用请点击右上角导入按钮，从gitee/github releases下载ffo-data资源包并导入
2.可自定义任意头部、身体、背景，注意部分从者可能没有某些部件，如boss龙娘、Beast
3.功能说明
  - 裁剪：不显示超出背景框的部分
  - 同一从者：头部/身体/背景使用同一从者资源
  - 保存：保存PNG图片，移动端可选择是否导入到相册
  - 也可以点击图片进入全屏查看，长按图片可保存(包括抽卡页面)
4.解包数据来源于icyalala@NGA，稍作修正，从者编号可能与其他来源有所不同（主要是乌冬从者）
5.使用Gitee下载源时两个压缩包均需下载导入""",
            jpn:
                """1.初めて使用する場合は、右上隅にあるインポートボタンをクリックし、github/giteeリリースからffo-dataをダウンロードしてインポートしてください。
2.頭、体、背景は自由にカスタマイズできます。ボスエリちゃんとビーストなど、一部のサーヴァントにはパーツがない場合がありますのでご注意ください。
3.機能の説明
   -切り抜き：背景を超える部分を表示しません
   -同じサーヴァント：頭/体/背景は同じサーヴァントを使用します
   -保存：PNG画像を保存します。モバイル端末はそれをアルバムにインポートするかどうかを選択できます
   -画像をクリックして全画面表示にし、画像を長押しして保存することもできます（ガチャページも含む）
4.データはicyalala@NGAからですが、一部の修正により、他のソースと異なる場合があります（主にうどんサーヴァント）。
5.Giteeを使用してソースをダウンロードする場合は、二つのzip圧縮パッケージをダウンロードしてインポートする必要があります。""",
            eng:
                """1. For the first use, you need to download the ffo-data resource from github/gitee releases then import it
2. Any HEAD, BODY, and BACKGROUND can be customized. Note that some servants may not have some parts, such as the boss Eli-chan and Beast
3. Function description
   - Crop: Do not display the part that exceeds the background frame
   - Same servant: head/body/background use the same servant parts
   - Save: Save the PNG image, the mobile platforms can choose whether to export it to the album,
   - You can also tap the card to view in full screen and long press to save(the same for summon page)
4. The decrypted data comes from icyalala@NGA, with a slight modification, the servant number may be different from other sources (mainly Udon servant)
5. When using Gitee to download the source, both zip files need to be downloaded and imported""",
          )),
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
        SplitRoute.push(
          context: context,
          detail: true,
          builder: (context, _) => _PartChooserPage(
            title: 'Choose $partName',
            parts: parts,
            onChanged: (svt) async {
              await params.setPart(svt, sameSvt ? null : where);
              setState(() {});
            },
          ),
        );
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

class _PartChooserPage extends StatefulWidget {
  final String title;
  final Map<int, FFOPart> parts;
  final ValueChanged<FFOPart?> onChanged;

  const _PartChooserPage({
    Key? key,
    required this.title,
    required this.parts,
    required this.onChanged,
  }) : super(key: key);

  @override
  _PartChooserPageState createState() => _PartChooserPageState();
}

class _PartChooserPageState extends State<_PartChooserPage> {
  late List<FFOPart> parts;
  int sortType = 0;

  @override
  void initState() {
    super.initState();
    final _sortType = db.cfg.get('ffo_sort');
    if (_sortType is int && sortType >= 0 && sortType <= 2) {
      sortType = _sortType;
    }
    parts = widget.parts.values.toList();
    sort();
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> children = [];
    parts.forEach((svt) {
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
        onTap: () {
          widget.onChanged(svt);
          Navigator.pop(context);
        },
      );
      children.add(child);
    });
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(),
        title: Text(widget.title),
        titleSpacing: 0,
      ),
      body: Column(
        children: [
          Expanded(child: LayoutBuilder(builder: (context, constraints) {
            return GridView.count(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              crossAxisCount: constraints.maxWidth ~/ 56,
              children: children,
            );
          })),
          kDefaultDivider,
          buttonBar,
        ],
      ),
    );
  }

  Widget get buttonBar {
    return ButtonBar(
      alignment: MainAxisAlignment.center,
      children: [
        Text(S.current.filter_sort),
        DropdownButton<int>(
          value: sortType,
          items: [
            DropdownMenuItem(value: 0, child: Text('ID')),
            DropdownMenuItem(value: 1, child: Text(S.current.rarity)),
            DropdownMenuItem(
                value: 2, child: Text(S.current.filter_sort_class)),
          ],
          onChanged: (v) {
            if (v != null) {
              sortType = v;
              sort();
              setState(() {});
              db.cfg.put('ffo_sort', sortType);
            }
          },
        ),
        TextButton(
          onPressed: () async {
            widget.onChanged(null);
            Navigator.of(context).pop();
          },
          child: Text(S.current.clear),
        ),
      ],
    );
  }

  void sort() {
    parts.sort((a, b) {
      if (sortType == 0) {
        return a.id - b.id;
      }
      final sa = db.gameData.servants[a.id], sb = db.gameData.servants[b.id];
      if (sa != null && sb != null) {
        if (sortType == 1) {
          return Servant.compare(sa, sb,
              keys: [SvtCompare.rarity, SvtCompare.className, SvtCompare.no],
              reversed: [true, false, false]);
        } else if (sortType == 2) {
          return Servant.compare(sa, sb,
              keys: [SvtCompare.className, SvtCompare.rarity, SvtCompare.no],
              reversed: [false, true, false]);
        }
      }
      return a.id - b.id;
    });
  }
}
