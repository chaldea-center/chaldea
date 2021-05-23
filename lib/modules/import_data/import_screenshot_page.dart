import 'dart:convert';

import 'package:chaldea/components/components.dart';
import 'package:chaldea/modules/item/item_detail_page.dart';
import 'package:dio/dio.dart';
import 'package:file_picker_cross/file_picker_cross.dart';
import 'package:path/path.dart' as pathlib;

class ImportScreenshotPage extends StatefulWidget {
  ImportScreenshotPage({Key? key}) : super(key: key);

  @override
  ImportScreenshotPageState createState() => ImportScreenshotPageState();
}

class ImportScreenshotPageState extends State<ImportScreenshotPage> {
  late ScrollController _scrollController;
  Map<String, int> output = {};
  late Dio _dio;
  late List<File> imageFiles;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    imageFiles = db.runtimeData.itemRecognizeImageFiles;
    _dio = Dio(BaseOptions(
      // baseUrl: 'http://localhost:8083',
      baseUrl: kServerRoot,
      sendTimeout: 600 * 1000,
      receiveTimeout: 600 * 1000,
      headers: HttpUtils.headersWithUA(),
    ));
  }

  @override
  void dispose() {
    super.dispose();
    _scrollController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      return Column(
        children: [
          Expanded(
            child: Column(
              children: [
                if (imageFiles.isEmpty && output.isEmpty)
                  Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                      child: Text(LocalizedText.of(
                        chs: '理论支持现有所有服务器的素材截图解析，精度有所提升',
                        jpn: '理論的に既存のすべてのサーバーのアイテムスクリーンショット分析をサポートする',
                        eng:
                            'Support item screenshots of all servers with improved accuracy',
                      )),
                    ),
                  ),
                if (imageFiles.isNotEmpty)
                  Expanded(
                    child: ListView(
                      controller: _scrollController,
                      children: imageFiles.map((e) {
                        return Container(
                          width: constraints.biggest.width,
                          padding: EdgeInsets.only(bottom: 6),
                          child: Image.file(e, fit: BoxFit.fitWidth),
                        );
                      }).toList(),
                    ),
                  ),
                if (output.isNotEmpty) Expanded(child: _itemList()),
              ],
            ),
          ),
          kDefaultDivider,
          _buildButtonBar(),
        ],
      );
    });
  }

  Widget _buildButtonBar() {
    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      alignment: WrapAlignment.center,
      spacing: 6,
      children: [
        helpBtn,
        ElevatedButton(
            onPressed: imageFiles.isEmpty ? null : _uploadScreenshots,
            child: Text(S.of(context).upload)),
        ElevatedButton(
            onPressed: _fetchResult,
            child: Text(LocalizedText.of(
                chs: '下载结果', jpn: '結果をダウンロード', eng: 'Download Result'))),
        ElevatedButton(
          onPressed: output.isEmpty
              ? null
              : () {
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
                          child: Text(S.current.update)),
                    ],
                  ).showDialog(context);
                },
          child: Text(S.current.import_screenshot_update_items),
        ),
      ],
    );
  }

  Map<String, TextEditingController> _controllers = {};

  Widget _itemList() {
    List<Widget> children = [];
    output.forEach((key, value) {
      _controllers.putIfAbsent(key, () => TextEditingController());
      _controllers[key]!.text = value.toString();
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
            controller: _controllers[key],
            textAlign: TextAlign.center,
            onChanged: (s) {
              output[key] = int.tryParse(s) ?? output[key]!;
            },
          ),
        ),
      ));
    });
    return ListView(children: children);
  }

  void importImages() async {
    FilePickerCross.importMultipleFromStorage(type: FileTypeCross.image)
        .then((value) {
      output.clear();
      db.runtimeData.itemRecognizeImageFiles =
          imageFiles = value.map((e) => File(e.path)).toList();
      if (mounted) {
        setState(() {});
      }
    }).catchError((error, stackTrace) {
      if (!(error is FileSelectionCanceledError)) {
        print(error.toString());
        print(stackTrace.toString());
        EasyLoading.showError(error.toString());
      }
    });
  }

  Map<String, dynamic> _getBaseAPIParams() {
    final m = Map<String, dynamic>();
    m['userKey'] = AppInfo.uuid;
    m['version'] = AppInfo.version;
    return m;
  }

  void _uploadScreenshots() async {
    print('uuid=${AppInfo.uuid}');
    if (imageFiles.isEmpty) {
      return;
    }
    try {
      final response1 = await _dio
          .get('/requestNewTask', queryParameters: {'userKey': AppInfo.uuid});
      final data1 = jsonDecode(response1.data);
      if (data1['success'] != true) {
        showInformDialog(context,
            title: S.current.success, content: data1['msg']);
        return;
      }

      final map = _getBaseAPIParams();
      for (var file in imageFiles) {
        map[pathlib.basename(file.path)] =
            await MultipartFile.fromFile(file.path);
      }
      var formData = FormData.fromMap(map);
      EasyLoading.show(
          status: 'Uploading', maskType: EasyLoadingMaskType.clear);
      final response2 = await _dio.post('/recognizeItems', data: formData);
      var data2 = jsonDecode(response2.data);
      String title = data2['success'] == true ? '上传成功' : '上传失败';
      String content = data2['msg'].toString();
      showInformDialog(context, title: title, content: content);
    } catch (e, s) {
      print(e);
      print(s);
      showInformDialog(context, title: 'Error', content: e.toString());
    } finally {
      EasyLoading.dismiss();
    }
  }

  void _fetchResult() async {
    try {
      final response = await _dio.get('/downloadItemResult',
          queryParameters: _getBaseAPIParams());
      Map data = jsonDecode(response.data);
      if (!mounted) return;
      if (data['success'] == true) {
        output = Map<String, int>.from(data['msg']);
        output = Item.sortMapById(output);
        print(output);
        setState(() {});
      } else {
        showInformDialog(context,
            title: 'Response', content: data['msg'].toString());
      }
    } catch (e) {
      showInformDialog(context, title: 'Error', content: e.toString());
    }
  }

  Widget get helpBtn {
    return IconButton(
      onPressed: () {
        final helpMsg = LocalizedText.of(
          chs: """1. 目前仅可解析素材信息，理论上所有服都可使用
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
          jpn: """1.現在、解析できるのはアイテムのみであり、理論的にはすべてのサーバーに適用可能
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
              """1. At present, only items can be parsed, all servers should be supported
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
      tooltip: S.of(context).help,
      color: Theme.of(context).colorScheme.primary,
    );
  }
}
