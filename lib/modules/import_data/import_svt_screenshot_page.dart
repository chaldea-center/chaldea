import 'dart:convert';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:chaldea/components/components.dart';
import 'package:chaldea/modules/servant/servant_list_page.dart';
import 'package:dio/dio.dart';
import 'package:file_picker_cross/file_picker_cross.dart';
import 'package:path/path.dart' as pathlib;

class ImportSvtScreenshotPage extends StatefulWidget {
  ImportSvtScreenshotPage({Key? key}) : super(key: key);

  @override
  ImportSvtScreenshotPageState createState() => ImportSvtScreenshotPageState();
}

class ImportSvtScreenshotPageState extends State<ImportSvtScreenshotPage> {
  late ScrollController _scrollController;

  // Map<String, int> output = {};
  List<OneSvtRecResult> results = [];
  late Dio _dio;
  late List<File> imageFiles;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    imageFiles = db.runtimeData.svtRecognizeImageFiles;
    _dio = Dio(BaseOptions(
      baseUrl: 'http://localhost:8083',
      // baseUrl: kServerRoot,
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
                if (imageFiles.isEmpty && results.isEmpty)
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
                if (results.isNotEmpty) Expanded(flex: 2, child: _resultList()),
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
    List<OneSvtRecResult> usedResults =
        results.where((e) => e.isValid && e.checked).toList();
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
          child: Text(S.current.import_data),
          onPressed: usedResults.isEmpty
              ? null
              : () => SimpleCancelOkDialog(
                    title: Text(S.current.import_data),
                    content: Text(
                        '${usedResults.length}/${results.length} ${S.current.servant} -> '
                        '${db.curUser.name} - ${S.current.plan_x(db.curUser.curSvtPlanNo + 1)}'),
                    onTapOk: () {
                      usedResults.forEach((result) {
                        final status = db.curUser.svtStatusOf(result.svtNo!);
                        status
                          ..favorite = true
                          ..curVal.skills = [
                            result.skill1!,
                            result.skill2!,
                            result.skill3!
                          ];
                      });
                      db.itemStat.update();
                      EasyLoading.showSuccess(S.current.import_data_success);
                    },
                  ).showDialog(context),
        ),
      ],
    );
  }

  Widget _resultList() {
    List<Widget> children = [];
    results.forEach((svtResult) {
      if (svtResult.imgBytes == null) return;
      Servant? svt;
      if (svtResult.svtNo != null) {
        svt = db.gameData.servantsWithUser[svtResult.svtNo];
      }
      bool valid = svt != null && svtResult.isValid;
      Widget nameBtn = TextButton(
        child: AutoSizeText(
          svt != null ? 'No.${svt.no} ${svt.info.localizedName}' : 'unknown',
          maxLines: 2,
          minFontSize: 6,
          maxFontSize: 14,
        ),
        style: TextButton.styleFrom(alignment: Alignment.centerLeft),
        onPressed: () async {
          // use Servant.no rather Servant.originNo
          await SplitRoute.push(
            context: context,
            detail: false,
            builder: (ctx, _) => ServantListPage(
              onSelected: (_svt) {
                svtResult.svtNo = _svt.no;
                Navigator.of(context).pop();
              },
            ),
          );
          setState(() {});
        },
      );
      List<Widget> skillBtns = List.generate(
        3,
        (index) => SizedBox(
          width: 25,
          child: DropdownButton<int?>(
            value: MathUtils.inRange(svtResult.skills[index], 1, 10)
                ? svtResult.skills[index]
                : null,
            hint: Text('-1'),
            items: List.generate(
              10,
              (index) => DropdownMenuItem(
                  value: index + 1,
                  child: Text((index + 1).toString().padLeft(2))),
            ),
            icon: Container(),
            underline: Container(),
            dropdownColor: Theme.of(context).cardColor,
            onChanged: (v) {
              switch (index) {
                case 0:
                  svtResult.skill1 = v;
                  break;
                case 1:
                  svtResult.skill2 = v;
                  break;
                case 2:
                  svtResult.skill3 = v;
                  break;
              }
              setState(() {});
            },
          ),
        ),
      );
      children.add(ListTile(
        leading: Padding(
          padding: EdgeInsets.symmetric(vertical: 3),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.memory(svtResult.imgBytes!, width: 40),
              svt?.iconBuilder(context: context, width: 40) ??
                  db.getIconImage(null, width: 40, aspectRatio: 132 / 144),
            ],
          ),
        ),
        title: Row(
          children: [
            Expanded(flex: 4, child: nameBtn),
            ...divideTiles(skillBtns, divider: Text('/')),
          ],
        ),
        trailing: Checkbox(
          value: valid && svtResult.checked,
          onChanged: valid
              ? (v) => setState(() {
                    if (v != null) svtResult.checked = v;
                  })
              : null,
        ),
      ));
    });
    return ListView(children: children);
  }

  void importImages() async {
    FilePickerCross.importMultipleFromStorage(type: FileTypeCross.image)
        .then((value) {
      results.clear();
      db.runtimeData.svtRecognizeImageFiles =
          imageFiles = value.map((e) => File(e.path!)).toList();
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
      final response1 = await _dio.get('/requestSvtTask',
          queryParameters: _getBaseAPIParams());
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
      final response2 = await _dio.post('/recognizeServants', data: formData);
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
      final response = await _dio.get('/downloadSvtResult',
          queryParameters: _getBaseAPIParams());
      Map data = jsonDecode(response.data);
      if (!mounted) return;
      if (data['success'] == true) {
        results = SvtRecResults.fromJson(Map.from(data['body'])).results;
        // output = Map<String, int>.from(data['msg']);
        // output = Item.sortMapById(output);
        // print(output);
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
    S.current.ascension;
    return IconButton(
      onPressed: () {
        final helpMsg = LocalizedText.of(
          chs: """0. 测试阶段：有任何问题欢迎反馈交流！！！
1. 功能：解析截图中的从者技能等级（不包括灵基等级），应该不限服务器
2. 使用方法: 
 - 点击右上角可同时导入多张截图
 - 上传成功后稍等片刻再下载结果
 - 每行识别结果从左到右分别是：
   - 识别到的从者头像
   - 本地从者头像：可点击进入详情
   - 识别的从者编号姓名：点击进入列表页更改从者（若存在识别错误或识别失败）
   - 三个技能数值：点击可修改数值
   - 复选框：是否选择导入，仅识别出且技能数值正确时可用
3. 必要条件!!!重要!!!
  - 技能升级页的截图，头像缩放最好为中或大，小头像识别失败率高。通过左下角切换。
  - 仅识别被“锁定锁定锁定”的从者，不会有人不锁吧
  - 头像框务必完整显示，至少保证职阶图标、技能数字等完全显示
4. 其他注意事项
 - 单次上传总大小有限制(~15MB)，否则会出现413错误，请分多次上传下载
 - 截图请勿裁剪等修改，请勿分屏
 - 解析结果保留24h, 24h后可能删除
 - 新从者/灵衣需要服务器更新头像数据，如有未能识别的，请积极反馈""",
          jpn: """""",
          eng: """""",
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
