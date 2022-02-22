import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/models/models.dart';
import 'package:chaldea/widgets/tile_items.dart';
import 'package:flutter/material.dart';

class TranslationSetting extends StatefulWidget {
  TranslationSetting({Key? key}) : super(key: key);

  @override
  _TranslationSettingState createState() => _TranslationSettingState();
}

class _TranslationSettingState extends State<TranslationSetting> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Preferred Translation')),
      body: ListView(
        children: [
          orderableList,
          const SFooter('Drag to change the order.\n'
              'Used for game data description, not UI language. '
              'Not all game data is translated for all 5 official languages'),
          Center(
            child: ElevatedButton(
              child: Text(S.current.reset),
              onPressed: () {
                setState(() {
                  db2.settings.preferredRegions = null;
                });
              },
            ),
          )
        ],
      ),
    );
  }

  Widget get orderableList {
    List<Region> regions = db2.settings.resolvedPreferredRegions;
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
            title: Text(region.toUpper()),
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
          db2.settings.preferredRegions = regions;
        });
      },
    );
  }
}
