import 'package:flutter/material.dart';

import 'package:chaldea/app/app.dart';
import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/models/models.dart';
import 'package:chaldea/widgets/tile_items.dart';

class ClassFilterStyleSetting extends StatefulWidget {
  ClassFilterStyleSetting({super.key});

  @override
  _ClassFilterStyleSettingState createState() => _ClassFilterStyleSettingState();
}

class _ClassFilterStyleSettingState extends State<ClassFilterStyleSetting> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(S.current.setting_servant_class_filter_style)),
      body: ListView(
        children: [
          RadioGroup<SvtListClassFilterStyle>(
            groupValue: db.settings.display.classFilterStyle,
            onChanged: onChanged,
            child: TileGroup(
              children: [
                for (final style in SvtListClassFilterStyle.values)
                  RadioListTile<SvtListClassFilterStyle>(value: style, title: Text(style.shownName)),
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

  void onChanged(SvtListClassFilterStyle? v) {
    setState(() {
      if (v != null) db.settings.display.classFilterStyle = v;
      db.saveSettings();
    });
  }
}
