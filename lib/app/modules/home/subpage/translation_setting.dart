import 'package:flutter/material.dart';

import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/models/models.dart';
import 'package:chaldea/widgets/tile_items.dart';

class TranslationSetting extends StatefulWidget {
  TranslationSetting({Key? key}) : super(key: key);

  @override
  _TranslationSettingState createState() => _TranslationSettingState();
}

class _TranslationSettingState extends State<TranslationSetting> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(S.current.preferred_translation)),
      body: ListView(
        children: [
          orderableList,
          SFooter(S.current.preferred_translation_footer),
          Center(
            child: ElevatedButton(
              child: Text(S.current.reset),
              onPressed: () {
                setState(() {
                  db.settings.preferredRegions = null;
                  db.saveSettings();
                  db.notifySettings();
                });
              },
            ),
          )
        ],
      ),
    );
  }

  Widget get orderableList {
    List<Region> regions = db.settings.resolvedPreferredRegions;
    return ReorderableListView(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: List.generate(regions.length, (index) {
        final region = regions[index];
        return DecoratedBox(
          key: Key(region.toString()),
          decoration: BoxDecoration(
              border: Border(bottom: Divider.createBorderSide(context))),
          child: ListTile(
            leading: Text((index + 1).toString()),
            horizontalTitleGap: 0,
            title: Text(region.localName),
            subtitle: Text(region.toLanguage().name),
          ),
        );
      }),
      onReorder: (int oldIndex, int newIndex) {
        setState(() {
          if (oldIndex < newIndex) {
            newIndex -= 1;
          }
          final item = regions.removeAt(oldIndex);
          regions.insert(newIndex, item);
          db.settings.preferredRegions = regions;
          db.saveSettings();
          db.notifySettings();
        });
      },
    );
  }
}
