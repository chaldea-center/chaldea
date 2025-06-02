import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/models/db.dart';
import 'package:chaldea/packages/split_route/split_route.dart';
import 'package:chaldea/utils/utils.dart';
import 'package:chaldea/widgets/tile_items.dart';

class MasterRatioSetting extends StatefulWidget {
  MasterRatioSetting({super.key});

  @override
  _MasterRatioSettingState createState() => _MasterRatioSettingState();
}

class _MasterRatioSettingState extends State<MasterRatioSetting> {
  final display = db.settings.display;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(S.current.setting_split_ratio)),
      body: ListView(
        children: [
          ratioTile,
          if (kIsWeb || kDebugMode) maxWidthTile,
          Center(
            child: ElevatedButton(
              onPressed: () {
                setState(() {
                  display.splitMasterRatio = SplitRoute.defaultMasterRatio = null;
                  display.maxWindowWidth = null;
                });
                db.notifyAppUpdate();
              },
              child: Text(S.current.reset),
            ),
          ),
        ],
      ),
    );
  }

  Widget get ratioTile {
    return TileGroup(
      header: S.current.setting_split_ratio,
      footer: S.current.setting_split_ratio_hint,
      children: [
        SwitchListTile.adaptive(
          title: Text(S.current.enable_split_view),
          value: display.enableSplitView,
          onChanged: (v) {
            setState(() {
              display.enableSplitView = SplitRoute.enableSplitView = v;
            });
            db.notifyAppUpdate();
          },
        ),
        ListTile(
          title: Text(S.current.setting_split_ratio),
          trailing: Text('${SplitRoute.defaultMasterRatio}:${100 - SplitRoute.defaultMasterRatio}', style: kMonoStyle),
        ),
        Slider.adaptive(
          value: SplitRoute.defaultMasterRatio.toDouble(),
          min: 30,
          max: 60,
          divisions: 60 - 30,
          activeColor: display.enableSplitView ? null : Theme.of(context).disabledColor,
          onChanged: display.enableSplitView
              ? (v) {
                  setState(() {
                    SplitRoute.defaultMasterRatio = v.toInt();
                    display.splitMasterRatio = SplitRoute.defaultMasterRatio;
                  });
                }
              : null,
          onChangeEnd: display.enableSplitView
              ? (v) {
                  EasyDebounce.debounce('split_master_ratio_change', const Duration(seconds: 1), () {
                    db.notifyAppUpdate();
                  });
                }
              : null,
        ),
      ],
    );
  }

  Widget get maxWidthTile {
    String widthText;
    if (display.maxWindowWidth == null || display.maxWindowWidth! >= 1920) {
      widthText = "Unlimited";
    } else {
      widthText = display.maxWindowWidth.toString();
    }
    double? width;
    if (kAppKey.currentContext != null) {
      width = MediaQuery.maybeSizeOf(kAppKey.currentContext!)?.width;
    }
    width ??= MediaQuery.sizeOf(context).width;
    widthText += '/$width';
    return TileGroup(
      header: S.current.max_window_width,
      footer: "Web only",
      children: [
        ListTile(
          title: Text(S.current.max_window_width),
          trailing: Text(widthText, style: kMonoStyle),
          onTap: () => setState(() {}),
        ),
        Slider.adaptive(
          value: (display.maxWindowWidth ?? 1920).toDouble().clamp(400.0, 1930.0),
          min: 400,
          max: 1930,
          divisions: 193 - 40,
          onChanged: (v) {
            setState(() {
              display.maxWindowWidth = v.round();
            });
          },
          onChangeEnd: (v) {
            EasyDebounce.debounce('max_window_width_change', const Duration(seconds: 1), () {
              db.notifyAppUpdate();
            });
          },
        ),
      ],
    );
  }
}
