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
      appBar: AppBar(title: Text(S.current.setting_setting_favorite_button_default)),
      body: ListView(
        children: [
          RadioGroup<FavoriteState?>(
            groupValue: db.settings.preferredFavorite,
            onChanged: (v) {
              setState(() {
                db.settings.preferredFavorite = null;
                db.saveSettings();
              });
            },
            child: TileGroup(
              children: [
                RadioListTile<FavoriteState?>(value: null, title: Text(S.current.svt_fav_btn_remember)),
                RadioListTile<FavoriteState?>(
                  value: FavoriteState.owned,
                  title: Text(S.current.svt_fav_btn_show_favorite),
                  secondary: const Icon(Icons.favorite),
                ),
                RadioListTile<FavoriteState?>(
                  value: FavoriteState.all,
                  title: Text(S.current.svt_fav_btn_show_all),
                  secondary: const Icon(Icons.remove_circle_outline),
                ),
              ],
            ),
          ),
          Center(
            child: ElevatedButton(
              onPressed: db.gameData.isValid ? () => router.push(url: Routes.servants) : null,
              child: Text(S.current.preview),
            ),
          ),
        ],
      ),
    );
  }
}
