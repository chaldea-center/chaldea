import 'dart:math';

import 'package:chaldea/components/components.dart';
import 'package:chaldea/modules/servant/servant_detail_page.dart';

class SvtTabsSortingSetting extends StatefulWidget {
  SvtTabsSortingSetting({Key? key}) : super(key: key);

  @override
  _SvtTabsSortingSettingState createState() => _SvtTabsSortingSettingState();
}

class _SvtTabsSortingSettingState extends State<SvtTabsSortingSetting> {
  List<SvtTab> get tabs => db.appSetting.sortedSvtTabs;

  @override
  Widget build(BuildContext context) {
    db.appSetting.validateSvtTabs();

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
                    db.appSetting.sortedSvtTabs = List.of(SvtTab.values);
                  });
                },
                child: Text(S.current.reset),
              ),
              ElevatedButton(
                onPressed: db.gameData.servants.isEmpty
                    ? null
                    : () {
                        final index =
                            Random().nextInt(db.gameData.servants.length);
                        SplitRoute.push(
                          context,
                          ServantDetailPage(
                              db.gameData.servants.values.elementAt(index)),
                        );
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
        return S.current.card_info;
      case SvtTab.illustration:
        return S.current.illustration;
      case SvtTab.sprite:
        return S.current.sprites;
      case SvtTab.summon:
        return S.current.summon;
      case SvtTab.voice:
        return S.current.voice;
      case SvtTab.quest:
        return S.current.quest;
    }
  }
}
