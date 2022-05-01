import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:flutter_easyloading/flutter_easyloading.dart';

import 'package:chaldea/app/api/chaldea.dart';
import 'package:chaldea/models/api/recognizer.dart';
import 'package:chaldea/packages/packages.dart';
import 'package:chaldea/utils/utils.dart';
import 'item_result.dart';
import 'skill_result.dart';

enum RecognizerType {
  item,
  skill,
}

class RecognizerViewerTab extends StatefulWidget {
  final RecognizerType type;
  RecognizerViewerTab({Key? key, required this.type}) : super(key: key);

  @override
  State<RecognizerViewerTab> createState() => _RecognizerViewerTabState();
}

class _RecognizerViewerTabState extends State<RecognizerViewerTab> {
  int count = 10;
  List<String> recentFiles = [];
  int selected = 0;
  dynamic result;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        topBar,
        kDefaultDivider,
        if (result != null) Expanded(child: details),
      ],
    );
  }

  Widget get details {
    switch (widget.type) {
      case RecognizerType.item:
        return ItemResultTab(
          result: result,
          viewMode: true,
        );
      case RecognizerType.skill:
        return SkillResultTab(
          isAppend: true,
          result: result,
          viewMode: true,
        );
    }
  }

  Widget get topBar {
    selected = selected.clamp(0, recentFiles.length);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        const SizedBox(width: 8),
        Expanded(
          child: DropdownButton<int>(
            value: selected,
            underline: const SizedBox(),
            items: recentFiles.isEmpty
                ? const [
                    DropdownMenuItem(
                      child: Text('No result'),
                      value: 0,
                    )
                  ]
                : List.generate(recentFiles.length, (index) {
                    return DropdownMenuItem(
                      child: Text(
                        '${index + 1} - ${recentFiles[index]}',
                        maxLines: 1,
                        textScaleFactor: 0.8,
                      ),
                      value: index,
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
          child: TextField(
            textAlign: TextAlign.center,
            decoration: InputDecoration(hintText: count.toString()),
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            onChanged: (v) {
              count = int.tryParse(v) ?? count;
            },
          ),
        ),
        IconButton(onPressed: loadList, icon: const Icon(Icons.search))
      ],
    );
  }

  Future<void> loadList() async {
    try {
      EasyLoading.show();
      recentFiles = List.from((await ChaldeaApi.dio.get(
              '/recognizer/viewer/${widget.type.name}/list',
              queryParameters: {"count": count}))
          .data);
      EasyLoading.dismiss();
    } catch (e, s) {
      logger.e('read recognizer skill list failed', e, s);
      EasyLoading.showError(escapeDioError(e));
    }
    if (mounted) setState(() {});
  }

  Future<void> loadOne(String filename) async {
    try {
      EasyLoading.show();
      final resp = await ChaldeaApi.dio.get(
          '/recognizer/viewer/${widget.type.name}/result',
          queryParameters: {"filename": filename});
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
      EasyLoading.showError(escapeDioError(e));
    }
    if (mounted) setState(() {});
  }
}
