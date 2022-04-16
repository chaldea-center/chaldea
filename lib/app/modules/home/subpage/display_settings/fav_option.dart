import 'package:chaldea/app/app.dart';
import 'package:chaldea/app/tools/localized_base.dart';
import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/models/db.dart';
import 'package:chaldea/models/userdata/filter_data.dart';
import 'package:chaldea/widgets/tile_items.dart';
import 'package:flutter/material.dart';

class FavOptionSetting extends StatefulWidget {
  FavOptionSetting({Key? key}) : super(key: key);

  @override
  _FavOptionSettingState createState() => _FavOptionSettingState();
}

class _FavOptionSettingState extends State<FavOptionSetting> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text(LocalizedText.of(
        chs: '「关注」按钮默认筛选',
        jpn: '「フォロー」ボタンディフォルト',
        eng: '「Favorite」Button Default',
        kor: '「즐겨찾기」 버튼 디폴트',
      ))),
      body: ListView(
        children: [
          TileGroup(
            children: [
              RadioListTile<FavoriteState?>(
                value: null,
                groupValue: db2.settings.favoritePreferred,
                title: Text(LocalizedText.of(
                    chs: '记住选择', jpn: '前の選択', eng: 'Remember', kor: '이전 선택')),
                onChanged: (v) {
                  setState(() {
                    db2.settings.favoritePreferred = null;
                    db2.saveSettings();
                  });
                },
              ),
              RadioListTile<FavoriteState?>(
                value: FavoriteState.owned,
                groupValue: db2.settings.favoritePreferred,
                title: Text(LocalizedText.of(
                    chs: '显示已关注',
                    jpn: 'フォロー表示',
                    eng: 'Show Favorite',
                    kor: '즐겨찾기 표시')),
                secondary: const Icon(Icons.favorite),
                onChanged: (v) {
                  setState(() {
                    db2.settings.favoritePreferred = FavoriteState.owned;
                    db2.saveSettings();
                  });
                },
              ),
              RadioListTile<FavoriteState?>(
                value: FavoriteState.all,
                groupValue: db2.settings.favoritePreferred,
                title: Text(LocalizedText.of(
                    chs: '显示全部', jpn: 'すべて表示', eng: 'Show All', kor: '전부 표시')),
                secondary: const Icon(Icons.remove_circle_outline),
                onChanged: (v) {
                  setState(() {
                    db2.settings.favoritePreferred = FavoriteState.all;
                    db2.saveSettings();
                  });
                },
              ),
            ],
          ),
          Center(
            child: ElevatedButton(
              onPressed: () {
                router.push(url: Routes.servants);
              },
              child: Text(S.current.preview),
            ),
          )
        ],
      ),
    );
  }
}
