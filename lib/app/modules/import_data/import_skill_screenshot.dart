import 'dart:math';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import 'package:dio/dio.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'package:chaldea/app/api/chaldea.dart';
import 'package:chaldea/app/app.dart';
import 'package:chaldea/app/modules/common/builders.dart';
import 'package:chaldea/app/modules/servant/servant_list.dart';
import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/models/api/recognizer.dart';
import 'package:chaldea/models/models.dart';
import 'package:chaldea/packages/app_info.dart';
import 'package:chaldea/packages/packages.dart';
import 'package:chaldea/utils/img_util.dart';
import 'package:chaldea/utils/utils.dart';
import 'package:chaldea/widgets/widgets.dart';

class ImportSkillScreenshotPage extends StatefulWidget {
  final bool isAppend;

  ImportSkillScreenshotPage({Key? key, this.isAppend = false})
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
  SkillResult? output;
  late Dio _dio;

  Set<Uint8List> get imageFiles => widget.isAppend
      ? db.runtimeData.recognizerAppend
      : db.runtimeData.recognizerActive;

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

    _dio = Dio(ChaldeaApi.dio.options.copyWith(
      sendTimeout: 600 * 1000,
      receiveTimeout: 600 * 1000,
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
        title: Text(widget.isAppend
            ? S.current.import_append_skill_screenshots
            : S.current.import_active_skill_screenshots),
        actions: [
          MarkdownHelpPage.buildHelpBtn(context, 'import_skill_screenshot.md'),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: S.current.screenshots),
            Tab(text: S.current.results),
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
          SafeArea(child: buttonBar),
        ],
      ),
    );
  }

  Widget get screenshotsTab {
    if (imageFiles.isEmpty) {
      return const SizedBox();
    }
    return ListView(
      controller: _scrollController1,
      children: imageFiles.map((e) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 6),
          child: InkWell(
            child: Image.memory(e, fit: BoxFit.fitWidth),
            onTap: () {
              SimpleCancelOkDialog(
                title: Text(S.current.clear),
                onTapOk: () {
                  imageFiles.remove(e);
                  if (mounted) setState(() {});
                },
              ).showDialog(context);
            },
          ),
        );
      }).toList(),
    );
  }

  Widget get resultTab {
    List<Widget> children = [];
    if (output == null) return const SizedBox();
    int countUnknown = 0, countDup = 0, countSelected = 0, countValid = 0;
    Map<int, List<SkillDetail>> items = {};
    for (final detail in output!.details) {
      items.putIfAbsent(detail.svtId, () => []).add(detail);
    }
    items.values.forEach((itemList) {
      itemList.sort2((e) => -e.score);
      final selected = itemList.firstWhereOrNull((e) => e.checked);
      if (selected != null) {
        itemList.forEach((e) {
          e.checked = e == selected;
        });
      }
    });
    final keys = items.keys.toList();
    keys.sort();
    countUnknown = items[-1]?.length ?? 0;
    countValid = keys.where((e) => e > 0).length;
    countSelected = items.values
        .where((itemList) => itemList.any((e) => e.valid && e.checked))
        .length;
    countDup = output!.details.length - countUnknown - countValid;

    for (final itemId in keys) {
      final itemList = items[itemId]!;
      for (final item in itemList) {
        children.add(Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: _buildDetailRow(item),
        ));
      }
    }

    return Column(
      children: [
        ListTile(
          title: Text(
            '$countUnknown unknown, $countDup dup, $countSelected selected,'
            ' $countValid/${output?.details.length} valid',
            textAlign: TextAlign.center,
          ),
        ),
        Expanded(
          child: ListView.builder(
            controller: _scrollController2,
            itemCount: children.length,
            itemBuilder: (context, index) => children[index],
          ),
        )
      ],
    );
  }

  Widget _buildDetailRow(SkillDetail item) {
    final svt = db.gameData.servants[item.svtId];
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        item.imgThumb == null
            ? const SizedBox(width: 56, height: 56)
            : InkWell(
                child: Image.memory(item.imgThumb!, width: 56, height: 56),
                onTap: () {
                  SimpleCancelOkDialog(
                    content: Image.memory(item.imgThumb!, width: 200),
                    hideCancel: true,
                  ).showDialog(context);
                },
              ),
        const SizedBox(width: 8),
        svt?.iconBuilder(context: context, width: 48) ??
            db.getIconImage(null, width: 48),
        Expanded(
          child: TextButton(
            onPressed: () {
              router.pushPage(ServantListPage(
                onSelected: (v) {
                  item.svtId = v.collectionNo;
                  if (output!.details
                      .any((e) => e != item && e.svtId == item.svtId)) {
                    item.checked = false;
                  }
                  if (mounted) setState(() {});
                },
              ), detail: false);
            },
            child: Text(
              '${item.svtId} - ' + (svt == null ? 'Unknown' : svt.lName.l),
              style: TextStyle(
                color: item.valid && item.checked
                    ? null
                    : Theme.of(context).errorColor,
              ),
              maxLines: 2,
              textAlign: TextAlign.center,
            ),
          ),
        ),
        const SizedBox(width: 8),
        ...divideTiles(
          [
            for (int index = 0; index < 3; index++)
              DropdownButton<int>(
                icon: const SizedBox(),
                value: item.skills[index],
                items: List.generate(12, (index) {
                  return DropdownMenuItem(
                    value: index - 1,
                    child: Text((index - 1).toString()),
                  );
                }),
                onChanged: (v) {
                  setState(() {
                    if (v != null) item.setSkill(index, v);
                  });
                },
              ),
          ],
          divider: const Text(' / '),
        ),
        Checkbox(
          value: item.checked,
          onChanged: item.valid
              ? (v) {
                  if (v == true) {
                    output!.details.forEach((e) {
                      if (e.svtId == item.svtId && e.valid) {
                        e.checked = e == item;
                      }
                    });
                  } else if (v == false) {
                    item.checked = false;
                  }
                  setState(() {});
                }
              : null,
        )
      ],
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
              IconButton(
                onPressed: importImages,
                icon: const FaIcon(FontAwesomeIcons.image),
                tooltip: S.current.import_screenshot,
              ),
            if (_isUploadTab)
              ElevatedButton.icon(
                onPressed: imageFiles.isEmpty ? null : _uploadScreenshots,
                icon: const Icon(Icons.upload),
                label: Text(S.current.upload),
              ),
            if (_isResultTab)
              ElevatedButton(
                onPressed:
                    output?.details.isNotEmpty == true ? _doImportResult : null,
                child: Text(S.current.update),
              ),
          ],
        )
      ],
    );
  }

  void importImages() async {
    SharedBuilder.pickImageOrFiles(context: context, withData: true)
        .then((result) {
      output = null;
      final files = result?.files;
      if (files != null) {
        for (final file in files) {
          if (file.bytes != null) {
            imageFiles.add(file.bytes!);
          }
        }
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

      final Map<String, dynamic> map = {};
      List<MultipartFile> files = [];
      for (int index = 0; index < imageFiles.length; index++) {
        var bytes = imageFiles.elementAt(index);
        // compress if size > 1.0M
        if (bytes.length / 1024 > 1.0) {
          bytes = compressToJpg(
              src: bytes, maxWidth: 1920, maxHeight: 1080, quality: 90);
        }
        files.add(MultipartFile.fromBytes(bytes, filename: 'file$index'));
      }
      map['files'] = files;
      var formData = FormData.fromMap(map);
      final t = StopwatchX('recognizer');
      final resp2 = await _dio.post('recognizer/skill', data: formData);
      output = SkillResult.fromJson(resp2.data);
      t.log('full');
      print('calc: ${output?.lapse}');

      if (mounted) {
        setState(() {});
        SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
          if (mounted) {
            _tabController.index = 1;
          }
        });
      }
    } catch (e, s) {
      logger.e('upload item screenshots to server error', e, s);
      SimpleCancelOkDialog(
        title: const Text('Error'),
        content: Text(e.toString()),
        hideCancel: true,
      ).showDialog(context);
    } finally {
      EasyLoading.dismiss();
    }
  }

  void _doImportResult() {
    SimpleCancelOkDialog(
      title: Text(S.current.import_screenshot_update_items),
      content: Text(S.current.import_screenshot_hint),
      confirmText: S.current.update,
      onTapOk: () {
        if (output == null) return;
        for (final detail in output!.details) {
          if (detail.valid && detail.checked) {
            final status = db.curUser.svtStatusOf(detail.svtId);
            // status.cur.ascension = 0;
            status.cur.favorite = true;
            if (widget.isAppend) {
              status.cur.appendSkills = List.of(detail.skills, growable: false);
            } else {
              status.cur.skills =
                  List.of(detail.skills.map((e) => max(1, e)), growable: false);
            }
          }
        }
        db.itemCenter.updateSvts(all: true);
        EasyLoading.showSuccess(S.current.import_data_success);
      },
    ).showDialog(context);
  }
}
