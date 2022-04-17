import 'package:flutter/material.dart';

import 'package:flutter_easyloading/flutter_easyloading.dart';

import 'package:chaldea/app/tools/localized_base.dart';
import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/models/models.dart';

class SvtTabsSortingSetting extends StatefulWidget {
  SvtTabsSortingSetting({Key? key}) : super(key: key);

  @override
  _SvtTabsSortingSettingState createState() => _SvtTabsSortingSettingState();
}

class _SvtTabsSortingSettingState extends State<SvtTabsSortingSetting> {
  List<SvtTab> get tabs => db.settings.display.sortedSvtTabs;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text(LocalizedText.of(
              chs: '从者详情页排序',
              jpn: 'サーヴァントページ表示順序',
              eng: 'Servant Tabs Sorting',
              kor: '서번트 페이지 표시 순서'))),
      body: ListView(
        children: [
          reorderableList(),
          const SizedBox(height: 8),
          ButtonBar(
            alignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    db.settings.display.sortedSvtTabs = List.of(SvtTab.values);
                    db.saveSettings();
                  });
                },
                child: Text(S.current.reset),
              ),
              ElevatedButton(
                onPressed: db.gameData.servants.isEmpty
                    ? null
                    : () {
                        EasyLoading.showError(S.current.not_implemented);
                        // TODO
                        // final index =
                        //     Random().nextInt(db2.gameData.servants.length);
                        // SplitRoute.push(
                        //   context,
                        //   ServantDetailPage(
                        //       db2.gameData.servants.values.elementAt(index)),
                        // );
                      },
                child: Text(S.current.preview),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget reorderableList() {
    return ReorderableListView(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: <Widget>[
        for (final tab in tabs)
          DecoratedBox(
            key: Key('$tab'),
            decoration: BoxDecoration(
                border: Border(bottom: Divider.createBorderSide(context))),
            child: ListTile(
              leading: Text((tabs.indexOf(tab) + 1).toString()),
              horizontalTitleGap: 0,
              title: Text(tabName(tab)),
            ),
          ),
      ],
      onReorder: (int oldIndex, int newIndex) {
        setState(() {
          if (oldIndex < newIndex) {
            newIndex -= 1;
          }
          final item = tabs.removeAt(oldIndex);
          tabs.insert(newIndex, item);
        });
      },
    );
  }

  String tabName(SvtTab tab) {
    switch (tab) {
      case SvtTab.plan:
        return S.current.plan;
      case SvtTab.skill:
        return S.current.skill;
      case SvtTab.np:
        return S.current.noble_phantasm;
      case SvtTab.info:
        return S.current.svt_basic_info;
      case SvtTab.lore:
        return S.current.svt_profile;
      case SvtTab.illustration:
        return S.current.illustration;
      case SvtTab.relatedCards:
        return S.current.svt_related_ce;
      case SvtTab.summon:
        return S.current.summon;
      case SvtTab.voice:
        return S.current.voice;
      case SvtTab.quest:
        return S.current.quest;
    }
  }
}
