import 'package:chaldea/components/localized/localized_base.dart';
import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/models/models.dart';
import 'package:chaldea/widgets/tile_items.dart';
import 'package:flutter/material.dart';

class ClassFilterStyleSetting extends StatefulWidget {
  ClassFilterStyleSetting({Key? key}) : super(key: key);

  @override
  _ClassFilterStyleSettingState createState() =>
      _ClassFilterStyleSettingState();
}

class _ClassFilterStyleSettingState extends State<ClassFilterStyleSetting> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text(LocalizedText.of(
              chs: '从者职阶筛选样式',
              jpn: 'クラスフィルタースタイル ',
              eng: 'Servant Class Filter Style',
              kor: '서번트 클래스 필터 스타일'))),
      body: ListView(
        children: [
          TileGroup(
            children: [
              RadioListTile<SvtListClassFilterStyle>(
                value: SvtListClassFilterStyle.auto,
                groupValue: db2.settings.display.classFilterStyle,
                title: Text(LocalizedText.of(
                    chs: '自动适配', jpn: '自动', eng: 'Auto', kor: '자동')),
                subtitle: Text(LocalizedText.of(
                    chs: '匹配屏幕尺寸',
                    jpn: 'マッチ画面サイズ',
                    eng: 'Match Screen Size',
                    kor: '알맞은 화면 크기')),
                onChanged: onChanged,
              ),
              RadioListTile<SvtListClassFilterStyle>(
                value: SvtListClassFilterStyle.singleRow,
                groupValue: db2.settings.display.classFilterStyle,
                title: Text(LocalizedText.of(
                    chs: '单行不展开Extra职阶',
                    jpn: '「Extraクラス」展開、単一行',
                    eng: '<Extra Class> Collapsed\nSingle Row',
                    kor: '「Extra 클래스」전개, 첫째 줄')),
                onChanged: onChanged,
              ),
              RadioListTile<SvtListClassFilterStyle>(
                value: SvtListClassFilterStyle.singleRowExpanded,
                groupValue: db2.settings.display.classFilterStyle,
                title: Text(LocalizedText.of(
                    chs: '单行并展开Extra职阶',
                    jpn: '単一行、「Extraクラス」を折り畳み',
                    eng: '<Extra Class> Expanded\nSingle Row',
                    kor: '첫째 줄, 「Extra 클래스」 접기')),
                onChanged: onChanged,
              ),
              RadioListTile<SvtListClassFilterStyle>(
                value: SvtListClassFilterStyle.twoRow,
                groupValue: db2.settings.display.classFilterStyle,
                title: Text(LocalizedText.of(
                    chs: 'Extra职阶显示在第二行',
                    jpn: '「Extraクラス」は2行目に表示',
                    eng: '<Extra Class> in Second Row',
                    kor: '「Extra 클래스」은 두번째 줄에 표시')),
                onChanged: onChanged,
              ),
              RadioListTile<SvtListClassFilterStyle>(
                value: SvtListClassFilterStyle.doNotShow,
                groupValue: db2.settings.display.classFilterStyle,
                title: Text(LocalizedText.of(
                    chs: '隐藏', jpn: '非表示', eng: 'Hidden', kor: '숨김')),
                onChanged: onChanged,
              ),
            ],
          ),
          Center(
            child: ElevatedButton(
              onPressed: () {
                // TODO
                // SplitRoute.push(context, ServantListPage(), detail: false);
              },
              child: Text(S.current.preview),
            ),
          )
        ],
      ),
    );
  }

  void onChanged(SvtListClassFilterStyle? v) {
    setState(() {
      if (v != null) db2.settings.display.classFilterStyle = v;
    });
  }
}
