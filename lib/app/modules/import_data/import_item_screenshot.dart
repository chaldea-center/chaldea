import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';

import 'package:dio/dio.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'package:chaldea/app/api/chaldea.dart';
import 'package:chaldea/app/app.dart';
import 'package:chaldea/app/modules/common/builders.dart';
import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/models/api/recognizer.dart';
import 'package:chaldea/models/models.dart';
import 'package:chaldea/packages/app_info.dart';
import 'package:chaldea/packages/packages.dart';
import 'package:chaldea/utils/img_util.dart';
import 'package:chaldea/utils/utils.dart';
import 'package:chaldea/widgets/widgets.dart';
import '../item/item_select.dart';

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
  ItemResult? output;
  late Dio _dio;

  Set<Uint8List> get imageFiles => db.runtimeData.recognizerItems;

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
        title: Text(S.current.item_screenshot),
        actions: [
          MarkdownHelpPage.buildHelpBtn(context, 'import_item_screenshot.md'),
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

  // detail.hashcode
  final Map<int, TextEditingController> _controllers = {};

  Widget get resultTab {
    List<Widget> children = [];
    if (output == null) return const SizedBox();
    int countUnknown = 0, countDup = 0, countSelected = 0, countValid = 0;
    Map<int, List<ItemDetail>> items = {};
    for (final detail in output!.details) {
      items.putIfAbsent(detail.itemId, () => []).add(detail);
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
    keys.sort2((e) => db.gameData.items[e]?.priority ?? -1);
    countUnknown = items[-1]?.length ?? 0;
    countValid = keys.where((e) => e > 0).length;
    countSelected = items.values
        .where((itemList) => itemList.any((e) => e.checked && e.itemId > 0))
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

  Widget _buildDetailRow(ItemDetail item) {
    final _ctrl =
        _controllers.putIfAbsent(item.hashCode, () => TextEditingController());
    if (_ctrl.text != item.count.toString()) {
      _ctrl.text = item.count.toString();
    }
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        item.imgThumb == null
            ? const SizedBox(width: 56, height: 56)
            : Image.memory(item.imgThumb!, width: 56, height: 56),
        const SizedBox(width: 8),
        Item.iconBuilder(
            context: context, item: null, itemId: item.itemId, width: 48),
        Expanded(
          child: TextButton(
            onPressed: () {
              router.push(
                child: ItemSelectPage(
                  onSelected: (v) {
                    item.itemId = v;
                    if (output!.details
                        .any((e) => e != item && e.itemId == v)) {
                      item.checked = false;
                    }
                    if (mounted) setState(() {});
                  },
                ),
              );
            },
            child: Text(
              Item.getName(item.itemId),
              style: TextStyle(
                color: item.valid && item.checked
                    ? null
                    : Theme.of(context).errorColor,
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        item.imgNum == null
            ? const SizedBox(width: 56)
            : Image.memory(item.imgNum!, width: 56),
        const SizedBox(width: 8),
        SizedBox(
          width: 80,
          child: TextField(
            controller: _ctrl,
            textAlign: TextAlign.center,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            onChanged: (v) {
              final count = int.tryParse(v);
              if (count != null) item.count = count;
              setState(() {});
            },
          ),
        ),
        Checkbox(
          value: item.checked,
          onChanged: item.valid
              ? (v) {
                  if (v == true) {
                    output!.details.forEach((e) {
                      if (e.itemId == item.itemId && e.valid) {
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
                child: Text(S.current.import_screenshot_update_items),
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
      final resp2 = await _dio.post('recognizer/item', data: formData);
      output = ItemResult.fromJson(resp2.data);
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
          if (detail.checked) {
            db.curUser.items[detail.itemId] = detail.count;
          }
        }
        db.itemCenter.updateLeftItems();
        EasyLoading.showSuccess(S.current.import_data_success);
      },
    ).showDialog(context);
  }
}
