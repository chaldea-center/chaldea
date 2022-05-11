import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import 'package:dio/dio.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

import 'package:chaldea/app/api/chaldea.dart';
import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/models/api/recognizer.dart';
import 'package:chaldea/models/models.dart';
import 'package:chaldea/packages/app_info.dart';
import 'package:chaldea/packages/packages.dart';
import 'package:chaldea/utils/img_util.dart';
import 'package:chaldea/utils/utils.dart';
import 'package:chaldea/widgets/widgets.dart';
import 'screenshot/screenshots.dart';
import 'screenshot/skill_result.dart';
import 'screenshot/viewer.dart';

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
  SkillResult? output;
  late Dio _dio;

  Set<Uint8List> get imageFiles => widget.isAppend
      ? db.runtimeData.recognizerAppend
      : db.runtimeData.recognizerActive;

  SkillResult? get result => widget.isAppend
      ? db.runtimeData.recognizerAppendResult
      : db.runtimeData.recognizerActiveResult;
  set result(SkillResult? v) {
    if (widget.isAppend) {
      db.runtimeData.recognizerAppendResult = v;
    } else {
      db.runtimeData.recognizerActiveResult = v;
    }
  }

  @override
  void initState() {
    super.initState();
    _tabController =
        TabController(length: AppInfo.isDebugDevice ? 3 : 2, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) setState(() {});
    });

    _dio = Dio(ChaldeaApi.dio.options.copyWith(
      sendTimeout: 600 * 1000,
      receiveTimeout: 600 * 1000,
    ));
  }

  @override
  void dispose() {
    super.dispose();
    _tabController.dispose();
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
      body: TabBarView(
        controller: _tabController,
        children: [
          KeepAliveBuilder(
            builder: (ctx) => ScreenshotsTab(
              images: imageFiles,
              onUpload: _uploadScreenshots,
              debugServerRoot: _dio.options.baseUrl,
            ),
          ),
          KeepAliveBuilder(
              builder: (ctx) =>
                  SkillResultTab(isAppend: widget.isAppend, result: output)),
          if (AppInfo.isDebugDevice)
            KeepAliveBuilder(
              builder: (ctx) => RecognizerViewerTab(type: RecognizerType.skill),
            )
        ],
      ),
    );
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
          bytes = await compressToJpgAsync(
              src: bytes, maxWidth: 1920, maxHeight: 1080, quality: 90);
        }
        files.add(MultipartFile.fromBytes(bytes, filename: 'file$index'));
      }
      map['files'] = files;
      var formData = FormData.fromMap(map);
      final resp2 = await _dio.post('/recognizer/skill', data: formData);
      output = SkillResult.fromJson(resp2.data);
      logger.i('received recognized: ${output?.details.length} servants');

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
        content: Text(escapeDioError(e)),
        hideCancel: true,
      ).showDialog(context);
    } finally {
      EasyLoading.dismiss();
    }
  }
}
