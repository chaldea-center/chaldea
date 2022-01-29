import 'dart:convert';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:chaldea/components/components.dart';
import 'package:chaldea/modules/servant/servant_list_page.dart';
import 'package:dio/dio.dart';
import 'package:flutter/services.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:path/path.dart' as pathlib;

import 'import_item_screenshot_page.dart';

class ImportSkillScreenshotPage extends StatefulWidget {
  final bool isAppendSkill;

  ImportSkillScreenshotPage({Key? key, this.isAppendSkill = false})
      : super(key: key);

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

  Set<String> get imageFiles => widget.isAppendSkill
      ? db.runtimeData.appendSkillRecognizeImageFiles
      : db.runtimeData.activeSkillRecognizeImageFiles;

  // update every build
  Map<int, List<OneSvtRecResult>> resultsMap = {};

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
      sendTimeout: 600 * 1000,
      receiveTimeout: 600 * 1000,
      headers: Map.from(db.serverDio.options.headers)
        ..remove(Headers.contentTypeHeader),
      queryParameters: {'is_append_skill': widget.isAppendSkill}
        ..addAll(db.serverDio.options.queryParameters),
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
        titleSpacing: 0,
        title: Text(widget.isAppendSkill
            ? S.current.append_skill
            : S.current.active_skill),
        actions: [
          MarkdownHelpPage.buildHelpBtn(context, 'import_skill_screenshot.md'),
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
                  KeepAliveBuilder(builder: (ctx) => debugTab)
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
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: widget.isAppendSkill
              ? Text(
                  LocalizedText.of(
                    chs: '注意! 此页面是附加技能，不是主动技能！！！',
                    jpn: '注意！このページはアペンドスキルであり、保有スキルではありません！',
                    eng:
                        'Warning! For APPEND skills only! Not for active skills!',
                    kor: '주의! 어펜드 스킬만! 액티브 스킬은 안됩니다!',
                  ),
                  style: Theme.of(context).textTheme.headline6,
                )
              : Text(S.current.active_skill),
        ),
      );
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
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Text(
        LocalizedText.of(
            chs: '共$totalNum, 有效$validNum, 已选$selectedNum, 重复$dupNum',
            jpn: '合計$totalNum, 有効$validNum, 選択済み$selectedNum, 重複$dupNum',
            eng:
                'Total $totalNum, valid $validNum, selected $selectedNum, duplicated $dupNum',
            kor: '합계 $totalNum, 유효 $validNum, 선택된 $selectedNum, 복사 $dupNum'),
      ),
    );
    List<Widget> children = [];
    List<OneSvtRecResult> sortedResults = List.of(results);
    switch (_sortType) {
      case SvtCompare.no:
        sortedResults.sort((a, b) {
          return (a.svtNo ?? -1).compareTo(b.svtNo ?? -1);
        });
        break;
      case SvtCompare.className:
        sortedResults.sort((a, b) {
          final svtA = db.gameData.servants[a.svtNo],
              svtB = db.gameData.servants[b.svtNo];
          return Servant.compare(svtA, svtB,
              keys: [SvtCompare.className, SvtCompare.rarity, SvtCompare.no],
              reversed: [false, true, true]);
        });
        break;
      case SvtCompare.rarity:
        sortedResults.sort((a, b) {
          final svtA = db.gameData.servants[a.svtNo],
              svtB = db.gameData.servants[b.svtNo];
          return Servant.compare(svtA, svtB,
              keys: [SvtCompare.rarity, SvtCompare.className, SvtCompare.no],
              reversed: [true, false, true]);
        });
        break;
      default:
        break;
    }
    sortedResults.forEach((svtResult) {
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
          svt != null ? 'No.${svt.no}\n${svt.info.localizedName}' : 'unknown',
          maxLines: 3,
          minFontSize: 6,
          maxFontSize: 14,
          style: TextStyle(
            color: (dupNum != null && dupNum > 1) || svt == null
                ? Theme.of(context).errorColor
                : null,
          ),
        ),
        style: TextButton.styleFrom(
            alignment: Alignment.centerLeft,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            padding: const EdgeInsets.symmetric(horizontal: 0)),
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

      int minSkill = widget.isAppendSkill ? 0 : 1;
      List<Widget> skillBtns = List.generate(
        3,
        (index) => SizedBox(
          width: 25,
          child: DropdownButton<int?>(
            value: Maths.inRange(svtResult.skills[index], minSkill, 10)
                ? svtResult.skills[index]
                : null,
            hint: const Text('-1'),
            items: List.generate(
              10 - minSkill + 1,
              (i) => DropdownMenuItem(
                  value: i + minSkill,
                  child: Text((i + minSkill).toString().padLeft(2))),
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
      children.add(CustomTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 8),
        leading: Padding(
          padding: const EdgeInsets.symmetric(vertical: 3),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              GestureDetector(
                child: Image.memory(svtResult.imgBytes!, width: 56),
                onTap: () {
                  SimpleCancelOkDialog(
                    hideCancel: true,
                    content: Image.memory(svtResult.imgBytes!),
                  ).showDialog(context);
                },
              ),
              const SizedBox(width: 4),
              svt?.iconBuilder(context: context, width: 40) ??
                  db.getIconImage(null, width: 40, aspectRatio: 132 / 144),
            ],
          ),
        ),
        title: Row(
          children: [
            Expanded(flex: 4, child: nameBtn),
            ...divideTiles(skillBtns, divider: const Text('/')),
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
          child: const Text('Download List'),
        )
      ],
    ));
    for (String fn in _debugFilenames) {
      children.add(Padding(
        padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
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

  bool get _isUploadTab => _tabController.index == 0;

  bool get _isResultTab => _tabController.index == 1;
  SvtCompare? _sortType;

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
            if (_isResultTab)
              DropdownButton<SvtCompare?>(
                value: _sortType,
                isDense: true,
                items: [
                  DropdownMenuItem(
                    child: Text(LocalizedText.of(
                        chs: '不排序',
                        jpn: 'Unsorted',
                        eng: 'Unsorted',
                        kor: '정렬되지 않음')),
                    value: null,
                  ),
                  DropdownMenuItem(
                    child: Text(S.current.filter_sort_number),
                    value: SvtCompare.no,
                  ),
                  DropdownMenuItem(
                    child: Text(S.current.filter_sort_class),
                    value: SvtCompare.className,
                  ),
                  DropdownMenuItem(
                    child: Text(S.current.filter_sort_rarity),
                    value: SvtCompare.rarity,
                  ),
                ],
                onChanged: (v) {
                  setState(() {
                    _sortType = v;
                  });
                },
              ),
            if (_isUploadTab || _isResultTab)
              ElevatedButton.icon(
                  onPressed: _fetchResult,
                  icon: const Icon(Icons.download),
                  label: Text(LocalizedText.of(
                      chs: '结果', jpn: '結果', eng: 'Result', kor: '결과'))),
            if (_isResultTab)
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
    pickImageFiles(context: context).then((result) {
      results.clear();
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
          await _dio.get('/recognizer/skill/request'));
      if (!resp1.success) {
        resp1.showMsg(context);
        return;
      }

      Map<String, dynamic> map = {};
      for (var fp in imageFiles) {
        final file = File(fp);
        var bytes = await file.readAsBytes();
        // compress if size > 1.0M
        if (bytes.length > 1024 * 1024) {
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
      MobStat.logEvent('import_data', {
        "from": widget.isAppendSkill ? 'append_snap' : 'active_snap',
        "count": imageFiles.length.toString()
      });
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
          eng: 'The recognition result is empty',
          kor: '인식 결과 비었습니다',
        ));
      }
      results.forEach((e) => e.isAppendSkill = widget.isAppendSkill);
      _tabController.index = 1;
      await Future.delayed(const Duration(milliseconds: 300));
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
          if (!result.isValid) return;
          final status = db.curUser.svtStatusOf(result.svtNo!);
          status.favorite = true;
          if (widget.isAppendSkill) {
            status.curVal.appendSkills = [
              result.skill1!,
              result.skill2!,
              result.skill3!
            ];
          } else {
            status.curVal.skills = [
              result.skill1!,
              result.skill2!,
              result.skill3!
            ];
          }
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
  static final Map<String, File> _cachedFiles = {};

  bool get isJson => widget.url.toLowerCase().endsWith('.json');

  void _parse(File file) {
    if (isJson) {
      results =
          SvtRecResults.fromJson(jsonDecode(file.readAsStringSync())).results;
    }
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
    }).catchError((e, s) async {
      logger.e('load skill result json file failed', e, s);
    });
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final file = _getFile();
    if (file == null) {
      return const Center(child: CircularProgressIndicator());
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
        return CustomTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 8),
          leading: Padding(
            padding: const EdgeInsets.symmetric(vertical: 3),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                GestureDetector(
                  child: Image.memory(e.imgBytes!, width: 56),
                  onTap: () {
                    SimpleCancelOkDialog(
                      hideCancel: true,
                      content: Image.memory(e.imgBytes!),
                    ).showDialog(context);
                  },
                ),
                const SizedBox(width: 4),
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
