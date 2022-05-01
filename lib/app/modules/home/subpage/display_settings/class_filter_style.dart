import 'package:flutter/material.dart';

import 'package:chaldea/app/app.dart';
import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/models/models.dart';
import 'package:chaldea/widgets/tile_items.dart';

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
      appBar: AppBar(title: Text(S.current.setting_servant_class_filter_style)),
      body: ListView(
        children: [
          TileGroup(
            children: [
              RadioListTile<SvtListClassFilterStyle>(
                value: SvtListClassFilterStyle.auto,
                groupValue: db.settings.display.classFilterStyle,
                title: Text(S.current.svt_class_filter_auto),
                onChanged: onChanged,
              ),
              RadioListTile<SvtListClassFilterStyle>(
                value: SvtListClassFilterStyle.singleRow,
                groupValue: db.settings.display.classFilterStyle,
                title: Text(S.current.svt_class_filter_single_row),
                onChanged: onChanged,
              ),
              RadioListTile<SvtListClassFilterStyle>(
                value: SvtListClassFilterStyle.singleRowExpanded,
                groupValue: db.settings.display.classFilterStyle,
                title: Text(S.current.svt_class_filter_single_row_expanded),
                onChanged: onChanged,
              ),
              RadioListTile<SvtListClassFilterStyle>(
                value: SvtListClassFilterStyle.twoRow,
                groupValue: db.settings.display.classFilterStyle,
                title: Text(S.current.svt_class_filter_two_row),
                onChanged: onChanged,
              ),
              RadioListTile<SvtListClassFilterStyle>(
                value: SvtListClassFilterStyle.doNotShow,
                groupValue: db.settings.display.classFilterStyle,
                title: Text(S.current.svt_class_filter_hide),
                onChanged: onChanged,
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

  void onChanged(SvtListClassFilterStyle? v) {
    setState(() {
      if (v != null) db.settings.display.classFilterStyle = v;
      db.saveSettings();
    });
  }
}
