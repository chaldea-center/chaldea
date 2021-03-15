import 'dart:convert';
import 'dart:io';

import 'package:chaldea/components/components.dart';
import 'package:dio/dio.dart';
import 'package:file_picker_cross/file_picker_cross.dart';
import 'package:path/path.dart' as pathlib;

class ImportScreenshotPage extends StatefulWidget {
  ImportScreenshotPage({Key? key}) : super(key: key);

  @override
  ImportScreenshotPageState createState() => ImportScreenshotPageState();
}

class ImportScreenshotPageState extends State<ImportScreenshotPage> {
  Map<String, int> output = {};
  late Dio _dio;
  late List<File> imageFiles;

  @override
  void initState() {
    imageFiles = db.runtimeData.itemRecognizeImageFiles;
    _dio = Dio(BaseOptions(
      // baseUrl: 'http://localhost:8083',
      baseUrl: db.userData.serverRoot ?? kServerRoot,
      sendTimeout: 600 * 1000,
      receiveTimeout: 600 * 1000,
    ));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      return Column(
        children: [
          Expanded(
              child: Column(
            children: [
              if (imageFiles.isNotEmpty)
                Expanded(
                  child: ListView(
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
              if (imageFiles.isEmpty && output.isEmpty) Center()
            ],
          )),
          kDefaultDivider,
          _buildButtonBar(),
        ],
      );
    });
  }

  Widget _buildButtonBar() {
    List<String> validItems = [];
    db.gameData.items.forEach((itemKey, item) {
      if ([1, 2, 3].contains(item.category)) {
        validItems.add(itemKey);
      }
    });
    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      alignment: WrapAlignment.center,
      spacing: 6,
      children: [
        IconButton(
          onPressed: () => SimpleCancelOkDialog(
            title: Text(S.of(context).help),
            hideCancel: true,
            content: SingleChildScrollView(
              child: Text('0. 实验功能，请注意备份用户数据!!!\n'
                  '1. 目前仅可解析素材信息，仅国服日服经过测试\n'
                  '2. 使用方法: \n'
                  ' - 点击右上角可同时导入多张截图\n'
                  ' - 上传成功后喝口茶再下载结果导入\n'
                  '3. 如识别结果偏差很大，请在反馈中描述下这种偏差，如后两位未能识别等\n'
                  '4. 注意事项\n'
                  ' - 单次上传有大小限制，否则会出现413错误，请分多次上传下载\n'
                  ' - 截图尽量别做修改，滤镜禁止\n'
                  ' - 素材框务必完全显示, 否则对应素材可能识别不到\n'
                  ' - 解析精度有限，下载结果后可自行修正\n'
                  ' - 解析结果保留24h, 24h后可能删除\n'
                  ' - 服务器目前无法保证长期可用，若无法使用请检查新版本或提交反馈\n'),
            ),
          ).show(context),
          icon: Icon(Icons.help),
          tooltip: S.of(context).help,
          color: Colors.blue,
        ),
        ElevatedButton(
            onPressed: imageFiles.isEmpty ? null : _uploadScreenshots,
            child: Text(S.of(context).upload)),
        ElevatedButton(
            onPressed: _fetchResult, child: Text(S.of(context).download)),
        ElevatedButton(
          onPressed: output.isEmpty
              ? null
              : () {
                  SimpleCancelOkDialog(
                    title: Text('更新素材库存'),
                    content: Text('仅更新: 仅更新已识别的素材\n清空并更新: 清空所有素材数据再更新'),
                    hideOk: true,
                    actions: [
                      TextButton(
                          onPressed: () {
                            db.curUser.items..addAll(output);
                            db.itemStat.updateLeftItems();
                            Navigator.of(context).pop();
                          },
                          child: Text('仅更新')),
                      TextButton(
                          onPressed: () {
                            db.curUser.items
                              ..clear()
                              ..addAll(output);
                            db.itemStat.updateLeftItems();
                            Navigator.of(context).pop();
                          },
                          child: Text('清空并更新')),
                    ],
                  ).show(context);
                },
          child: Text('更新素材库存'),
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
          child: db.getIconImage(key),
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

  void _uploadScreenshots() async {
    print('uuid=${AppInfo.uniqueId}');
    if (imageFiles.isEmpty) {
      return;
    }
    Function? canceler;
    try {
      final response1 = await _dio.get('/requestNewTask',
          queryParameters: {'userKey': AppInfo.uniqueId});
      final data1 = jsonDecode(response1.data);
      if (data1['success'] != true) {
        showInformDialog(context, content: data1['msg']);
        return;
      }

      Map<String, dynamic> map = Map();
      map['userKey'] = AppInfo.uniqueId;
      for (var file in imageFiles) {
        map[pathlib.basename(file.path)] =
            await MultipartFile.fromFile(file.path);
      }
      var formData = FormData.fromMap(map);
      canceler = showMyProgress(status: 'Uploading');
      final response2 = await _dio.post('/recognizeItems', data: formData);
      var data2 = jsonDecode(response2.data);
      String title = data2['success'] == true ? '上传成功' : '上传失败';
      String content = data2['msg'].toString();
      canceler();
      showInformDialog(context, title: title, content: content);
    } catch (e, s) {
      print(e);
      print(s);
      showInformDialog(context, content: e.toString());
    } finally {
      canceler?.call();
    }
  }

  void _fetchResult() async {
    try {
      final response = await _dio.get('/downloadItemResult',
          queryParameters: {'userKey': AppInfo.uniqueId});
      Map data = jsonDecode(response.data);
      if (!mounted) return;
      if (data['success'] == true) {
        output = Map<String, int>.from(data['msg']);
        output = Item.sortMapById(output);
        print(output);
        setState(() {});
      } else {
        showInformDialog(context, content: data['msg'].toString());
      }
    } catch (e) {
      showInformDialog(context, title: 'Error', content: e.toString());
    }
  }
}
