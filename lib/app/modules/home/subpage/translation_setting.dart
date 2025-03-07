import 'package:flutter/material.dart';

import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/models/models.dart';
import 'package:chaldea/widgets/tile_items.dart';

class TranslationSetting extends StatefulWidget {
  TranslationSetting({super.key});

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
          Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: 'Auto',
                  style: db.settings.preferredRegions == null ? null : Theme.of(context).textTheme.bodySmall,
                ),
                const TextSpan(text: ' / '),
                TextSpan(
                  text: 'Fixed',
                  style: db.settings.preferredRegions == null ? Theme.of(context).textTheme.bodySmall : null,
                ),
              ],
            ),
            textAlign: TextAlign.center,
            // style: ,
          ),
          SFooter([S.current.drag_to_sort, S.current.preferred_translation_footer].join('/')),
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
          ),
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
          decoration: BoxDecoration(border: Border(bottom: Divider.createBorderSide(context))),
          child: ListTile(
            leading: Text((index + 1).toString()),
            title: Text(region.localName),
            subtitle: Text(region.language.name),
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
