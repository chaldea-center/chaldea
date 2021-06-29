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
          helpBtn,
          IconButton(
            onPressed: importImages,
            icon: FaIcon(FontAwesomeIcons.fileImport),
            tooltip: S.current.import_source_file,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: '截图'),
            Tab(text: '结果'),
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
        map[pathlib.basename(file.path)] =
            await MultipartFile.fromFile(file.path);
      }
      var formData = FormData.fromMap(map);
      final resp2 = ChaldeaResponse.fromResponse(
          await _dio.post('/recognizer/item/new', data: formData));
      resp2.showMsg(context);
    } catch (e, s) {
      logger.e('upload item screenshots to server error', e, s);
      showInformDialog(context, title: 'Error', content: e.toString());
    } finally {
      EasyLoading.dismiss();
    }
  }

  void _fetchResult() async {
    try {
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

  Widget get helpBtn {
    return IconButton(
      onPressed: () {
        final helpMsg = LocalizedText.of(
          chs: """1. 功能: 从素材截图中解析素材数量，理论上所有服都可使用
2. 使用方法: 
 - 点击右上角可同时导入多张截图
 - 上传成功后悠然得喝口茶再下载结果导入
3. 如识别结果偏差很大，请在反馈中描述下这种偏差，以便改进
4. 注意事项
 - 单次上传总大小有限制(~15MB)，否则会出现413错误，请分多次上传下载
 - 截图尽量别做裁剪等修改
 - 素材框务必完全显示, 否则对应素材可能识别不到
 - 解析精度应该可能或许还可以，下载结果后可自行修正
 - 解析结果保留24h, 24h后可能删除""",
          jpn: """1.機能：アイテムのスクリーンショットからアイテムの量を分析します、理論的にはすべてのサーバーに適用可能
2.使用方法：
  - 右上隅をクリックして、複数のスクリーンショットを同時にインポートします
  - アップロードが成功したら、しばらく待って、結果をダウンロードして、インポートする
3.認識結果に大きな偏差がある場合は、改善のためにフィードバックに記述してください
4.注意が必要な事項
  - 1回のアップロードの合計サイズは制限されています（〜15MB）。そうしないと、413エラーが発生します。複数回アップロードおよびダウンロードしてください。
  - スクリーンショットを変更しないようにしてください
  - アイテムを完全に表示する必要があります。そうしないと、対応するマテリアルが認識されない場合があります。
  - 解析の偏差はそれ手動で修正することができます。
  - 分析結果は24時間保持され、24時間後に削除される場合があります """,
          eng:
          """1. Feature: recognize item counts from screenshots, all servers should be supported
2. How to use:
  - Click the import button on upper right corner to import multiple screenshots at the same time
  - Wait a few minutes after the upload is successful, then download the result and import it
3. If the recognition result has a large deviation, please describe the deviation in the feedback for future improvement
4. Attentions
  - The total size of a single upload is limited (~15MB), otherwise a 413 error will occur, please upload and download multiple times
  - Don't crop/modify the screenshots
  - The item must be fully displayed, otherwise the it may not be recognized
  - You can correct the result after downloading if any recognition mistake
  - The result will be retained for about 24h, and may be deleted after 24h""",
        );
        SimpleCancelOkDialog(
          title: Text(S.of(context).help),
          hideCancel: true,
          scrollable: true,
          content: Text(helpMsg),
        ).showDialog(context);
      },
      icon: Icon(Icons.help),
      tooltip: S.current.help,
    );
  }
}
