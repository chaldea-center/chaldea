import 'package:flutter/material.dart';

import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/models/db.dart';
import 'package:chaldea/packages/split_route/split_route.dart';
import 'package:chaldea/utils/utils.dart';
import 'package:chaldea/widgets/tile_items.dart';

class MasterRatioSetting extends StatefulWidget {
  MasterRatioSetting({Key? key}) : super(key: key);

  @override
  _MasterRatioSettingState createState() => _MasterRatioSettingState();
}

class _MasterRatioSettingState extends State<MasterRatioSetting> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(S.current.setting_split_ratio)),
      body: ListView(
        children: [
          TileGroup(
            children: [
              ListTile(
                title: Text(S.current.current_),
                trailing: Text(
                  '${SplitRoute.defaultMasterRatio}:${100 - SplitRoute.defaultMasterRatio}',
                  style: kMonoStyle,
                ),
              ),
              Slider.adaptive(
                value: SplitRoute.defaultMasterRatio.toDouble(),
                min: 30,
                max: 60,
                divisions: 60 - 30,
                onChanged: (v) {
                  setState(() {
                    SplitRoute.defaultMasterRatio = v.toInt();
                    db.settings.splitMasterRatio =
                        SplitRoute.defaultMasterRatio;
                  });
                },
                onChangeEnd: (v) {
                  EasyDebounce.debounce(
                    'split_master_ratio_change',
                    const Duration(seconds: 1),
                    () {
                      db.notifyAppUpdate();
                    },
                  );
                },
              ),
            ],
          ),
          SFooter(S.current.setting_split_ratio_hint),
          Center(
            child: ElevatedButton(
              onPressed: () {
                setState(() {
                  db.settings.splitMasterRatio =
                      SplitRoute.defaultMasterRatio = null;
                });
              },
              child: Text(S.current.reset),
            ),
          )
        ],
      ),
    );
  }
}
