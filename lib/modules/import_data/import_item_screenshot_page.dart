import 'package:chaldea/components/components.dart';
import 'package:chaldea/modules/item/item_detail_page.dart';
import 'package:chaldea/modules/shared/common_builders.dart';
import 'package:dio/dio.dart';
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

  Set<String> get imageFiles => db.runtimeData.itemRecognizeImageFiles;

  @override
  void initState() {
    super.initState();
    _tabController =
        TabController(length: AppInfo.isDebugDevice ? 3 : 2, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) setState(() {});
    });
    _scrollController1 = ScrollController();
    _scrollController2 = ScrollController();
    _scrollController3 = ScrollController();
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
        titleSpacing: 0,
        title: Text(LocalizedText.of(
            chs: '素材截图解析',
            jpn: 'アイテムのスクリーンショット',
            eng: 'Items Screenshots',
            kor: '아이템 스크린샷')),
        actions: [
          MarkdownHelpPage.buildHelpBtn(context, 'import_item_screenshot.md'),
          IconButton(
            onPressed: importImages,
            icon: const FaIcon(FontAwesomeIcons.fileImport),
            tooltip: S.current.import_screenshot,
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
                kor: '스크린샷',
              ),
            ),
            Tab(
                text: LocalizedText.of(
                    chs: '识别结果', jpn: '結果', eng: 'Results', kor: '결과')),
            if (AppInfo.isDebugDevice) const Tab(text: 'Debug')
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
                      children: const [Text('test')],
                    ),
                  )
              ],
            ),
          ),
          kDefaultDivider,
          if (kDebugMode) Center(child: Text(_dio.options.baseUrl)),
          buttonBar,
        ],
      ),
    );
  }

  Widget get screenshotsTab {
    if (imageFiles.isEmpty) {
      return Container();
    }
    return ListView(
      controller: _scrollController1,
      children: imageFiles.map((e) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 6),
          child: Image.file(File(e), fit: BoxFit.fitWidth),
        );
      }).toList(),
    );
  }

  final Map<String, TextEditingController> _controllers = {};

  Widget get resultTab {
    List<Widget> children = [];
    output.forEach((key, value) {
      final _ctrl =
          _controllers.putIfAbsent(key, () => TextEditingController());
      _ctrl.text = value.toString();
      children.add(ListTile(
        leading: Padding(
          padding: const EdgeInsets.symmetric(vertical: 3),
          child: InkWell(
            child: db.getIconImage(key),
            onTap: () {
              SplitRoute.push(context, ItemDetailPage(itemKey: key));
            },
          ),
        ),
        title: Text(Item.lNameOf(key)),
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

  bool get _isUploadTab => _tabController.index == 0;

  bool get _isResultTab => _tabController.index == 1;

  Widget get buttonBar {
    return ButtonBar(
      alignment: MainAxisAlignment.center,
      children: [
        Wrap(
          crossAxisAlignment: WrapCrossAlignment.center,
          alignment: WrapAlignment.center,
          spacing: 6,
          runSpacing: 4,
          children: [
            if (_isUploadTab)
              IconButton(
                onPressed: () {
                  setState(() {
                    imageFiles.clear();
                  });
                },
                icon: const Icon(Icons.clear_all),
                tooltip: S.current.clear,
                constraints: const BoxConstraints(minWidth: 36, maxHeight: 24),
                padding: EdgeInsets.zero,
              ),
            if (_isUploadTab)
              ElevatedButton.icon(
                  onPressed: imageFiles.isEmpty ? null : _uploadScreenshots,
                  icon: const Icon(Icons.upload),
                  label: Text(S.current.upload)),
            if (_isUploadTab || _isResultTab)
              ElevatedButton.icon(
                  onPressed: _fetchResult,
                  icon: const Icon(Icons.download),
                  label: Text(LocalizedText.of(
                      chs: '结果', jpn: '結果', eng: 'Result', kor: '결과'))),
            if (_isResultTab)
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
    CommonBuilder.pickImageOrFiles(context: context).then((result) {
      output.clear();
      final paths = result?.paths.whereType<String>();
      if (paths != null) {
        imageFiles.addAll(paths);
      }
      if (mounted) {
        setState(() {});
      }
    }).catchError((e, s) async {
      logger.e('import images error', e, s);
      EasyLoading.showError(e.toString());
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
      for (var fp in imageFiles) {
        final file = File(fp);
        var bytes = await file.readAsBytes();
        // compress if size > 1.0M
        if (bytes.length / 1024 > 1.0) {
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
      MobStat.logEvent('import_data',
          {"from": "item_snap", "count": imageFiles.length.toString()});
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
            eng: 'The recognition result is empty',
            kor: '인식 결과 비었습니다'));
      }
      _tabController.index = 1;
      await Future.delayed(const Duration(milliseconds: 300));
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
            db.curUser.items.addAll(output);
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
