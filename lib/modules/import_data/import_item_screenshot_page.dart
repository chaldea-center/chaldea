import 'package:chaldea/components/components.dart';
import 'package:chaldea/modules/item/item_detail_page.dart';
import 'package:dio/dio.dart';
import 'package:file_picker_cross/file_picker_cross.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:path/path.dart' as pathlib;

class ImportItemScreenshotPage extends StatefulWidget {
  ImportItemScreenshotPage({Key? key}) : super(key: key);

  @override
  ImportItemScreenshotPageState createState() =>
      ImportItemScreenshotPageState();
}

class ImportItemScreenshotPageState extends State<ImportItemScreenshotPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late ScrollController _scrollController1;
  late ScrollController _scrollController2;
  late ScrollController _scrollController3;
  Map<String, int> output = {};
  late Dio _dio;
  late List<File> imageFiles;

  @override
  void initState() {
    super.initState();
    _tabController =
        TabController(length: AppInfo.isDebugDevice ? 3 : 2, vsync: this);
    _scrollController1 = ScrollController();
    _scrollController2 = ScrollController();
    _scrollController3 = ScrollController();
    imageFiles = db.runtimeData.itemRecognizeImageFiles;
    _dio = Dio(db.serverDio.options.copyWith(
      // baseUrl: kDebugMode ? 'http://localhost:8183' : null,
      sendTimeout: 600 * 1000,
      receiveTimeout: 600 * 1000,
      headers: Map.from(db.serverDio.options.headers)
        ..remove(Headers.contentTypeHeader),
    ));
  }

  @override
  void dispose() {
    super.dispose();
    _tabController.dispose();
    _scrollController1.dispose();
    _scrollController2.dispose();
    _scrollController3.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(),
        title: Text(LocalizedText.of(
            chs: '素材截图解析', jpn: 'アイテムのスクリーンショット', eng: 'Items Screenshots')),
        actions: [
          MarkdownHelpPage.buildHelpBtn(context, 'import_item_screenshot.md'),
          IconButton(
            onPressed: importImages,
            icon: FaIcon(FontAwesomeIcons.fileImport),
            tooltip: S.current.import_source_file,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(
              text: LocalizedText.of(
                chs: '截图',
                jpn: 'スクリーンショット',
                eng: 'Screenshots',
              ),
            ),
            Tab(text: LocalizedText.of(chs: '识别结果', jpn: '結果', eng: 'Results')),
            if (AppInfo.isDebugDevice) Tab(text: 'Debug')
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                KeepAliveBuilder(builder: (ctx) => screenshotsTab),
                KeepAliveBuilder(builder: (ctx) => resultTab),
                if (AppInfo.isDebugDevice)
                  KeepAliveBuilder(
                    builder: (ctx) => ListView(
                      controller: _scrollController3,
                      children: [Text('test')],
                    ),
                  )
              ],
            ),
          ),
          kDefaultDivider,
          buttonBar,
        ],
      ),
    );
  }

  Widget get screenshotsTab {
    if (imageFiles.isEmpty) {
      return Center(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Text(LocalizedText.of(
            chs: '理论支持现有所有服务器的素材截图解析，精度有所提升',
            jpn: '理論的に既存のすべてのサーバーのアイテムスクリーンショット分析をサポートする',
            eng:
                'Support item screenshots of all servers with improved accuracy',
          )),
        ),
      );
    }
    return ListView(
      controller: _scrollController1,
      children: imageFiles.map((e) {
        return Padding(
          padding: EdgeInsets.only(bottom: 6),
          child: Image.file(e, fit: BoxFit.fitWidth),
        );
      }).toList(),
    );
  }

  Map<String, TextEditingController> _controllers = {};

  Widget get resultTab {
    List<Widget> children = [];
    output.forEach((key, value) {
      final _ctrl =
          _controllers.putIfAbsent(key, () => TextEditingController());
      _ctrl.text = value.toString();
      children.add(ListTile(
        leading: Padding(
          padding: EdgeInsets.symmetric(vertical: 3),
          child: InkWell(
            child: db.getIconImage(key),
            onTap: () {
              SplitRoute.push(
                context: context,
                builder: (_, __) => ItemDetailPage(itemKey: key),
              );
            },
          ),
        ),
        title: Text(Item.localizedNameOf(key)),
        trailing: SizedBox(
          width: 80,
          child: TextField(
            controller: _ctrl,
            textAlign: TextAlign.center,
            onChanged: (s) {
              output[key] = int.tryParse(s) ?? output[key]!;
            },
          ),
        ),
      ));
    });
    return ListView(
      controller: _scrollController2,
      children: children,
    );
  }

  Widget get buttonBar {
    return ButtonBar(
      alignment: MainAxisAlignment.center,
      children: [
        Wrap(
          crossAxisAlignment: WrapCrossAlignment.center,
          alignment: WrapAlignment.center,
          spacing: 6,
          children: [
            ElevatedButton(
                onPressed: imageFiles.isEmpty ? null : _uploadScreenshots,
                child: Text(S.current.upload)),
            ElevatedButton(
                onPressed: _fetchResult,
                child: Text(LocalizedText.of(
                    chs: '下载结果', jpn: '結果をダウンロード', eng: 'Download Result'))),
            ElevatedButton(
              onPressed: output.isEmpty ? null : _doImportResult,
              child: Text(S.current.import_screenshot_update_items),
            ),
          ],
        )
      ],
    );
  }

  void importImages() async {
    FilePickerCross.importMultipleFromStorage(type: FileTypeCross.image)
        .then((value) {
      output.clear();
      db.runtimeData.itemRecognizeImageFiles =
          imageFiles = value.map((e) => File(e.path!)).toList();
      if (mounted) {
        setState(() {});
      }
    }).catchError((e, s) {
      if (!(e is FileSelectionCanceledError)) {
        logger.e('import images error', e, s);
        EasyLoading.showError(e.toString());
      }
    });
  }

  void _uploadScreenshots() async {
    if (imageFiles.isEmpty) {
      return;
    }
    try {
      EasyLoading.show(
          status: 'Uploading', maskType: EasyLoadingMaskType.clear);
      final resp1 = ChaldeaResponse.fromResponse(
          await _dio.get('/recognizer/item/request'));
      if (!resp1.success) {
        resp1.showMsg(context);
        return;
      }

      final Map<String, dynamic> map = {};
      for (var file in imageFiles) {
        var bytes = await file.readAsBytes();
        // compress if size > 1.0M
        if (bytes.length ~/ 1024 > 1.0) {
          bytes = compressToJpg(
              src: bytes, maxWidth: 1920, maxHeight: 1080, quality: 90);
        }

        /// MUST pass filename
        final filename = pathlib.basename(file.path);
        map[filename] = MultipartFile.fromBytes(bytes, filename: filename);
      }
      var formData = FormData.fromMap(map);
      final resp2 = ChaldeaResponse.fromResponse(
          await _dio.post('/recognizer/item/new', data: formData));
      resp2.showMsg(context);
    } catch (e, s) {
      logger.e('upload item screenshots to server error', e, s);
      showInformDialog(context, title: 'Error', content: e.toString());
    } finally {
      EasyLoadingUtil.dismiss();
    }
  }

  void _fetchResult() async {
    try {
      EasyLoading.show(maskType: EasyLoadingMaskType.clear);
      final resp = ChaldeaResponse.fromResponse(
          await _dio.get('/recognizer/item/result'));
      if (!mounted) return;
      if (!resp.success) {
        resp.showMsg(context);
        return;
      }

      output = Item.sortMapById(Map<String, int>.from(resp.body));
      if (output.isEmpty) {
        EasyLoading.showInfo(LocalizedText.of(
            chs: '识别结果为空',
            jpn: '認識結果が空です',
            eng: 'The recognition result is empty'));
      }
      _tabController.index = 1;
      await Future.delayed(Duration(milliseconds: 300));
      if (mounted) setState(() {});
    } catch (e, s) {
      logger.e('fetch item result error', e, s);
      showInformDialog(context, title: 'Error', content: e.toString());
    } finally {
      EasyLoadingUtil.dismiss(null);
    }
  }

  void _doImportResult() {
    SimpleCancelOkDialog(
      title: Text(S.current.import_screenshot_update_items),
      content: Text(S.current.import_screenshot_hint),
      hideOk: true,
      actions: [
        TextButton(
          onPressed: () {
            db.curUser.items..addAll(output);
            db.itemStat.updateLeftItems();
            Navigator.of(context).pop();
            EasyLoading.showSuccess('Updated');
          },
          child: Text(S.current.update),
        ),
      ],
    ).showDialog(context);
  }
}
