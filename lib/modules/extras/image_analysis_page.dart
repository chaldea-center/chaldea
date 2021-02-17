//@dart=2.12
import 'dart:convert';
import 'dart:io';

import 'package:chaldea/components/components.dart';
import 'package:dio/dio.dart';
import 'package:file_picker_cross/file_picker_cross.dart';
import 'package:path/path.dart' as pathlib;

class ImageAnalysisPage extends StatefulWidget {
  @override
  _ImageAnalysisPageState createState() => _ImageAnalysisPageState();
}

class _ImageAnalysisPageState extends State<ImageAnalysisPage> {
  // List<File> imageFiles = [];
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
    return Scaffold(
      appBar: AppBar(
        title: Text(S.of(context).image_analysis),
        leading: BackButton(),
        actions: [
          IconButton(
            icon: Icon(Icons.download_rounded),
            onPressed: _importImages,
            tooltip: '导入截图',
          )
        ],
      ),
      body: LayoutBuilder(builder: (context, constraints) {
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
            _buildButtonBar(),
          ],
        );
      }),
    );
  }

  String? preferItem;

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
      children: [
        IconButton(
          onPressed: () => showInformDialog(
            context,
            title: S.of(context).help,
            content: '1. 目前仅可解析素材信息，仅国服日服经过测试\n'
                '2. 使用方法: \n'
                ' - 点击右上角可同时导入多张截图\n'
                ' - 选择"首张"图片中出现的一个素材(加快服务器定位分析)\n'
                ' - 上传成功后等待几分钟下载结果导入\n'
                '3. 注意事项\n'
                ' - 所有截图保证尺寸一致，无分屏/裁剪/拼接/滤镜/长截屏等操作\n'
                ' - 素材框务必完全显示, 否则可能解析失败\n'
                ' - 解析精度有限，下载结果后可自行修正\n'
                ' - 服务器带宽CPU等资源受限, 请勿重复大量上传\n'
                ' - 解析结果保留24h, 24h后可能删除\n'
                ' - 服务器目前无法保证长期可用，若无法使用请检查新版本或联系本人\n',
          ),
          icon: Icon(Icons.help),
          tooltip: S.of(context).help,
          color: Colors.blue,
        ),
        DropdownButton<String>(
          items: validItems.map((e) {
            return DropdownMenuItem(
                value: e, child: Text(Item.localizedNameOf(e)));
          }).toList(),
          value: preferItem,
          hint: Text('首张图片包含'),
          onChanged: (s) {
            setState(() {
              preferItem = s;
            });
          },
        ),
        TextButton(
            onPressed: imageFiles.isEmpty ? null : _uploadScreenshots,
            child: Text(S.of(context).upload)),
        TextButton(
            onPressed: _fetchResult, child: Text(S.of(context).download)),
        TextButton(
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
                            db.curUser.items
                              ..clear()
                              ..addAll(output);
                            Navigator.of(context).pop();
                          },
                          child: Text('仅更新')),
                      TextButton(
                          onPressed: () {
                            db.curUser.items.addAll(output);
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

  void _importImages() async {
    FilePickerCross.importMultipleFromStorage(type: FileTypeCross.image)
        .then((value) {
      output.clear();
      db.runtimeData.itemRecognizeImageFiles =
          imageFiles = value.map((e) => File(e.path)).toList();
      if (mounted) {
        setState(() {});
      }
    }).onError((error, stackTrace) {
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
    Map<String, dynamic> map = Map();
    map['userKey'] = AppInfo.uniqueId;
    for (var file in imageFiles) {
      map[pathlib.basename(file.path)] =
          await MultipartFile.fromFile(file.path);
    }
    if (preferItem != null) {
      map['preferItem'] = preferItem;
    }
    var formData = FormData.fromMap(map);
    var canceler = showMyProgress(status: 'Uploading');
    _dio.post('/recognizeItems', data: formData).then((response) {
      if (response.statusCode == 200) {
        var data = jsonDecode(response.data);
        String title = data['success'] == true ? '上传成功' : '上传失败';
        String content = data['msg'].toString();
        canceler();
        showInformDialog(context, title: title, content: content);
      }
    }).onError((error, stackTrace) {
      print(error);
      canceler();
      showInformDialog(context, content: error.toString());
    });
  }

  void _fetchResult() async {
    final response = await _dio
        .get('/downloadItemResult', queryParameters: {'key': AppInfo.uniqueId});
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
  }
}
