import 'dart:convert';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:chaldea/components/components.dart';
import 'package:chaldea/modules/servant/servant_list_page.dart';
import 'package:dio/dio.dart';
import 'package:file_picker_cross/file_picker_cross.dart';
import 'package:flutter/services.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:path/path.dart' as pathlib;

class ImportSkillScreenshotPage extends StatefulWidget {
  ImportSkillScreenshotPage({Key? key}) : super(key: key);

  @override
  ImportSkillScreenshotPageState createState() =>
      ImportSkillScreenshotPageState();
}

class ImportSkillScreenshotPageState extends State<ImportSkillScreenshotPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late ScrollController _scrollController1;
  late ScrollController _scrollController2;
  late ScrollController _scrollController3;

  List<OneSvtRecResult> results = [];
  late Dio _dio;
  late List<File> imageFiles;

  // update every build
  Map<int, List<OneSvtRecResult>> resultsMap = {};

  @override
  void initState() {
    super.initState();
    _tabController =
        TabController(length: AppInfo.isDebugDevice ? 3 : 2, vsync: this);
    _scrollController1 = ScrollController();
    _scrollController2 = ScrollController();
    _scrollController3 = ScrollController();
    imageFiles = db.runtimeData.svtRecognizeImageFiles;
    _dio = Dio(db.serverDio.options.copyWith(
      // baseUrl: kDebugMode ? 'http://localhost:8183' : null,
      sendTimeout: 600 * 1000,
      receiveTimeout: 600 * 1000,
      headers: Map.from(db.serverDio.options.headers)
        ..remove(Headers.contentTypeHeader),
    ));
    _debugCountController = TextEditingController(text: '10');
  }

  @override
  void dispose() {
    super.dispose();
    _tabController.dispose();
    _scrollController1.dispose();
    _scrollController2.dispose();
    _scrollController3.dispose();
    _debugCountController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Navigator.pop(context);
    resultsMap.clear();
    results.forEach((e) {
      if (e.svtNo != null) resultsMap.putIfAbsent(e.svtNo!, () => []).add(e);
    });

    return Scaffold(
      appBar: AppBar(
        leading: BackButton(),
        titleSpacing: 0,
        title: Text(LocalizedText.of(
            chs: '技能截图解析', jpn: 'スキルのスクリーンショット', eng: 'Skill Screenshots')),
        actions: [
          MarkdownHelpPage.buildHelpBtn(context, 'import_skill_screenshot.md'),
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
                  KeepAliveBuilder(builder: (ctx) => debugTab)
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
    if (imageFiles.isEmpty)
      return Center(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Text(''),
        ),
      );
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

  Widget get resultTab {
    int totalNum = results.length,
        validNum = results.where((e) => e.isValid).length,
        selectedNum = results.where((e) => e.isValid && e.checked).length,
        dupNum = resultsMap.values
            .where((e) =>
                e.length > 1 &&
                e.where((ee) => ee.isValid && ee.checked).length > 1)
            .length;

    final summary = Padding(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Text(
        LocalizedText.of(
            chs: '共$totalNum, 有效$validNum, 已选$selectedNum, 重复$dupNum',
            jpn: '合計$totalNum, 有効$validNum, 選択済み$selectedNum, 重複$dupNum',
            eng:
                'Total $totalNum, valid $validNum, selected $selectedNum, duplicated $dupNum'),
      ),
    );
    List<Widget> children = [];
    results.forEach((svtResult) {
      if (svtResult.imgBytes == null) return;

      Servant? svt;
      if (svtResult.svtNo != null) {
        svt = db.gameData.servantsWithUser[svtResult.svtNo];
      }
      bool valid = svt != null && svtResult.isValid;
      int? dupNum = resultsMap[svtResult.svtNo]
          ?.where((e) => e.isValid && e.checked)
          .length;
      Widget nameBtn = TextButton(
        child: AutoSizeText(
          svt != null ? 'No.${svt.no} ${svt.info.localizedName}' : 'unknown',
          maxLines: 2,
          minFontSize: 6,
          maxFontSize: 14,
          style: TextStyle(
              color: dupNum != null && dupNum > 1 ? Colors.redAccent : null),
        ),
        style: TextButton.styleFrom(
            alignment: Alignment.centerLeft,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            padding: EdgeInsets.symmetric(horizontal: 0)),
        onPressed: () async {
          // use Servant.no rather Servant.originNo
          await SplitRoute.push(
            context,
            ServantListPage(
              onSelected: (_svt) {
                svtResult.svtNo = _svt.no;
                Navigator.of(context).pop();
              },
            ),
            detail: false,
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
              GestureDetector(
                child: Image.memory(svtResult.imgBytes!, width: 44),
                onTap: () {
                  SimpleCancelOkDialog(
                    hideCancel: true,
                    content: Image.memory(svtResult.imgBytes!),
                  ).showDialog(context);
                },
              ),
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
    return Column(
      children: [
        summary,
        Expanded(
          child: ListView(
            controller: _scrollController2,
            children: children,
          ),
        )
      ],
    );
  }

  late TextEditingController _debugCountController;
  List<String> _debugFilenames = [];

  Widget get debugTab {
    List<Widget> children = [];
    children.add(Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          width: 80,
          child: TextField(
            controller: _debugCountController,
            textAlign: TextAlign.center,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          ),
        ),
        ElevatedButton(
          onPressed: () async {
            final resp = ChaldeaResponse.fromResponse(await _dio.get(
              '/recognizer/skill/debug/list',
              queryParameters: {
                'count': int.tryParse(_debugCountController.text) ?? 10
              },
            ));
            _debugFilenames = List.from(resp.body);
            if (mounted) setState(() {});
          },
          child: Text('Download List'),
        )
      ],
    ));
    for (String fn in _debugFilenames) {
      children.add(Padding(
        padding: EdgeInsets.fromLTRB(8, 8, 8, 0),
        child: Text(fn),
      ));
      String url = '${_dio.options.baseUrl}/recognizer/skill/debug/file/$fn';
      children.add(_SkillResultLoader(url: url));
    }
    return ListView(
      controller: _scrollController3,
      children: children,
    );
  }

  Widget get buttonBar {
    List<OneSvtRecResult> usedResults =
        results.where((e) => e.isValid && e.checked).toList();
    return ButtonBar(
      alignment: MainAxisAlignment.center,
      children: [
        Wrap(
          crossAxisAlignment: WrapCrossAlignment.center,
          alignment: WrapAlignment.center,
          spacing: 6,
          runSpacing: 4,
          children: [
            ElevatedButton(
                onPressed: imageFiles.isEmpty ? null : _uploadScreenshots,
                child: Text(S.current.upload)),
            ElevatedButton(
                onPressed: _fetchResult,
                child: Text(LocalizedText.of(
                    chs: '下载结果', jpn: '結果をダウンロード', eng: 'Download Result'))),
            ElevatedButton(
              child: Text(S.current.import_data),
              onPressed:
                  usedResults.isEmpty ? null : () => _doImport(usedResults),
            ),
          ],
        )
      ],
    );
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
    }).catchError((e, s) {
      if (!(e is FileSelectionCanceledError)) {
        logger.e('import image failed', e, s);
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
          await _dio.get('/recognizer/skill/request'));
      if (!resp1.success) {
        resp1.showMsg(context);
        return;
      }

      Map<String, dynamic> map = {};
      for (var file in imageFiles) {
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
          await _dio.post('/recognizer/skill/new', data: formData));
      resp2.showMsg(context);
    } catch (e, s) {
      logger.e('upload skill screenshots to server error', e, s);
      showInformDialog(context, title: 'Error', content: e.toString());
    } finally {
      EasyLoadingUtil.dismiss();
    }
  }

  void _fetchResult() async {
    try {
      EasyLoading.show(maskType: EasyLoadingMaskType.clear);
      final resp = ChaldeaResponse.fromResponse(
          await _dio.get('/recognizer/skill/result'));
      if (!mounted) return;
      if (!resp.success) {
        resp.showMsg(context);
        return;
      }

      results = SvtRecResults.fromJson(Map.from(resp.body)).results;
      if (results.isEmpty) {
        EasyLoading.showInfo(LocalizedText.of(
            chs: '识别结果为空',
            jpn: '認識結果が空です',
            eng: 'The recognition result is empty'));
      }
      _tabController.index = 1;
      await Future.delayed(Duration(milliseconds: 300));
      if (mounted) setState(() {});
    } catch (e, s) {
      logger.e('fetch svt result', e, s);
      showInformDialog(context, title: 'Error', content: e.toString());
    } finally {
      EasyLoadingUtil.dismiss(null);
    }
  }

  void _doImport(List<OneSvtRecResult> usedResults) {
    SimpleCancelOkDialog(
      title: Text(S.current.import_data),
      content: Text('${usedResults.length} ${S.current.servant}'
          ' -> ${db.curUser.name}'),
      onTapOk: () {
        usedResults.forEach((result) {
          final status = db.curUser.svtStatusOf(result.svtNo!);
          status
            ..favorite = true
            ..curVal.skills = [result.skill1!, result.skill2!, result.skill3!];
        });
        db.itemStat.update();
        EasyLoading.showSuccess(S.current.import_data_success);
      },
    ).showDialog(context);
  }
}

class _SkillResultLoader extends StatefulWidget {
  final String url;

  const _SkillResultLoader({Key? key, required this.url}) : super(key: key);

  @override
  __SkillResultLoaderState createState() => __SkillResultLoaderState();
}

class __SkillResultLoaderState extends State<_SkillResultLoader> {
  static final _cacheManager = CacheManager(Config('debug'));
  List<OneSvtRecResult> results = [];
  String? _lastUrl;
  static Map<String, File> _cachedFiles = {};

  bool get isJson => widget.url.toLowerCase().endsWith('.json');

  void _parse(File file) {
    if (isJson)
      results =
          SvtRecResults.fromJson(jsonDecode(file.readAsStringSync())).results;
  }

  File? _getFile() {
    final file = _cachedFiles[widget.url];
    // cached
    if (file != null) {
      if (_lastUrl != widget.url) _parse(file);
      _lastUrl = widget.url;
      return file;
    }
    // caching
    if (widget.url == _lastUrl) return null;

    // cache it
    _lastUrl = widget.url;
    final url = widget.url;
    _cacheManager.getSingleFile(url).then((file) {
      _cachedFiles[url] = file;
      _parse(file);
      if (mounted) setState(() {});
    }).catchError((e, s) {
      logger.e('load skill result json file failed', e, s);
    });
  }

  @override
  Widget build(BuildContext context) {
    final file = _getFile();
    if (file == null) {
      return Center(child: CircularProgressIndicator());
    }
    if (!isJson) {
      return Image.file(file);
    }
    if (results.isEmpty) {
      return Text(widget.url);
    }

    return Column(
      children: results.map((e) {
        final svt = db.gameData.servants[e.svtNo];
        return ListTile(
          leading: Padding(
            padding: EdgeInsets.symmetric(vertical: 3),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                GestureDetector(
                  child: Image.memory(e.imgBytes!, width: 44),
                  onTap: () {
                    SimpleCancelOkDialog(
                      hideCancel: true,
                      content: Image.memory(e.imgBytes!),
                    ).showDialog(context);
                  },
                ),
                svt?.iconBuilder(context: context, width: 40) ??
                    db.getIconImage(null, width: 40, aspectRatio: 132 / 144),
              ],
            ),
          ),
          title: AutoSizeText(
            '${e.svtNo} - ${svt?.mcLink}',
            maxLines: 2,
          ),
          trailing: Text(e.skills.join('/')),
        );
      }).toList(),
    );
  }
}
