import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:flutter_easyloading/flutter_easyloading.dart';

import 'package:chaldea/models/api/recognizer.dart';
import 'package:chaldea/models/db.dart';
import 'package:chaldea/packages/packages.dart';
import 'package:chaldea/utils/utils.dart';
import 'item_result.dart';
import 'skill_result.dart';

enum RecognizerType { item, skill }

class RecognizerViewerTab extends StatefulWidget {
  final RecognizerType type;
  RecognizerViewerTab({super.key, required this.type});

  @override
  State<RecognizerViewerTab> createState() => _RecognizerViewerTabState();
}

class _RecognizerViewerTabState extends State<RecognizerViewerTab> {
  int count = 10;
  List<String> recentFiles = [];
  int? selected;
  dynamic result;

  @override
  Widget build(BuildContext context) {
    return Column(children: [topBar, kDefaultDivider, if (result != null) Expanded(child: details)]);
  }

  Widget get details {
    switch (widget.type) {
      case RecognizerType.item:
        return ItemResultTab(result: result, viewMode: true);
      case RecognizerType.skill:
        return SkillResultTab(isAppend: true, result: result, viewMode: true);
    }
  }

  Widget get topBar {
    if (selected != null) {
      selected = selected!.clamp(0, recentFiles.length);
    }
    if (recentFiles.isEmpty) {
      selected = null;
    }
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        const SizedBox(width: 8),
        Expanded(
          child: DropdownButton<int>(
            value: selected,
            underline: const SizedBox(),
            hint: Text(recentFiles.isEmpty ? 'No result' : 'Not selected'),
            items: List.generate(recentFiles.length, (index) {
              return DropdownMenuItem(
                value: index,
                child: Text(
                  '${index + 1} - ${recentFiles[index]}',
                  maxLines: 1,
                  textScaler: const TextScaler.linear(0.8),
                  softWrap: false,
                ),
              );
            }),
            onChanged: (v) {
              if (v != null && recentFiles.isNotEmpty) {
                selected = v;
                loadOne(recentFiles[v]);
              }
              setState(() {});
            },
            isExpanded: true,
          ),
        ),
        SizedBox(
          width: 72,
          child: TextFormField(
            textAlign: TextAlign.center,
            decoration: InputDecoration(hintText: count.toString()),
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            onChanged: (v) {
              count = int.tryParse(v) ?? count;
            },
          ),
        ),
        IconButton(onPressed: loadList, icon: const Icon(Icons.search)),
      ],
    );
  }

  Future<void> loadList() async {
    try {
      EasyLoading.show();
      recentFiles = List.from(
        (await db.apiServerDio.get(
          '/recognizer/viewer/${widget.type.name}/list',
          queryParameters: {"count": count},
        )).data,
      );
      EasyLoading.dismiss();
    } catch (e, s) {
      logger.e('read recognizer skill list failed', e, s);
      EasyLoading.showError(escapeDioException(e));
    }
    if (mounted) setState(() {});
  }

  Future<void> loadOne(String filename) async {
    try {
      EasyLoading.show();
      final resp = await db.apiServerDio.get(
        '/recognizer/viewer/${widget.type.name}/result',
        queryParameters: {"filename": filename},
      );
      switch (widget.type) {
        case RecognizerType.item:
          result = ItemResult.fromJson(resp.data);
          break;
        case RecognizerType.skill:
          result = SkillResult.fromJson(resp.data);
          break;
      }
      EasyLoading.dismiss();
    } catch (e, s) {
      logger.e('read recognizer ${widget.type.name} result failed', e, s);
      EasyLoading.showError(escapeDioException(e));
    }
    if (mounted) setState(() {});
  }
}
