import 'package:flutter/material.dart';

import 'package:chaldea/app/app.dart';
import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/models/db.dart';
import 'package:chaldea/models/userdata/filter_data.dart';
import 'package:chaldea/widgets/tile_items.dart';

class FavOptionSetting extends StatefulWidget {
  FavOptionSetting({super.key});

  @override
  _FavOptionSettingState createState() => _FavOptionSettingState();
}

class _FavOptionSettingState extends State<FavOptionSetting> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text(S.current.setting_setting_favorite_button_default)),
      body: ListView(
        children: [
          TileGroup(
            children: [
              RadioListTile<FavoriteState?>(
                value: null,
                groupValue: db.settings.favoritePreferred,
                title: Text(S.current.svt_fav_btn_remember),
                onChanged: (v) {
                  setState(() {
                    db.settings.favoritePreferred = null;
                    db.saveSettings();
                  });
                },
              ),
              RadioListTile<FavoriteState?>(
                value: FavoriteState.owned,
                groupValue: db.settings.favoritePreferred,
                title: Text(S.current.svt_fav_btn_show_favorite),
                secondary: const Icon(Icons.favorite),
                onChanged: (v) {
                  setState(() {
                    db.settings.favoritePreferred = FavoriteState.owned;
                    db.saveSettings();
                  });
                },
              ),
              RadioListTile<FavoriteState?>(
                value: FavoriteState.all,
                groupValue: db.settings.favoritePreferred,
                title: Text(S.current.svt_fav_btn_show_all),
                secondary: const Icon(Icons.remove_circle_outline),
                onChanged: (v) {
                  setState(() {
                    db.settings.favoritePreferred = FavoriteState.all;
                    db.saveSettings();
                  });
                },
              ),
            ],
          ),
          Center(
            child: ElevatedButton(
              onPressed: db.gameData.isValid
                  ? () => router.push(url: Routes.servants)
                  : null,
              child: Text(S.current.preview),
            ),
          )
        ],
      ),
    );
  }
}
