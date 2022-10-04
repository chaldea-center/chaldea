import 'package:flutter/material.dart';

import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/models/models.dart';
import '../common/filter_page_base.dart';

class ScriptReaderFilterPage extends FilterPage<ScriptReaderFilterData> {
  const ScriptReaderFilterPage({
    super.key,
    required super.filterData,
    super.onChanged,
  });

  @override
  _ScriptReaderFilterPageState createState() => _ScriptReaderFilterPageState();
}

class _ScriptReaderFilterPageState
    extends FilterPageState<ScriptReaderFilterData, ScriptReaderFilterPage> {
  @override
  Widget build(BuildContext context) {
    return buildAdaptive(
      title: Text(S.current.settings_tab_name, textScaleFactor: 0.8),
      actions: getDefaultActions(onTapReset: () {
        filterData.reset();
        update();
      }),
      content: getListViewBody(children: [
        SwitchListTile.adaptive(
          value: filterData.scene,
          onChanged: (v) {
            filterData.scene = v;
            update();
          },
          title: const Text('Images'),
        ),
        SwitchListTile.adaptive(
          value: filterData.soundEffect,
          onChanged: (v) {
            filterData.soundEffect = v;
            update();
          },
          title: const Text('Sound Effect'),
        ),
        SwitchListTile.adaptive(
          value: filterData.bgm,
          onChanged: (v) {
            filterData.bgm = v;
            update();
          },
          title: const Text('BGM'),
        ),
        SwitchListTile.adaptive(
          value: filterData.voice,
          onChanged: (v) {
            filterData.voice = v;
            update();
          },
          title: Text(S.current.voice),
          subtitle: Text(S.current.valentine_script),
        ),
      ]),
    );
  }
}
