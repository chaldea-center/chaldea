import 'package:flutter/material.dart';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:sliver_tools/sliver_tools.dart';

import 'package:chaldea/models/models.dart';
import 'package:chaldea/utils/utils.dart';
import 'package:chaldea/widgets/image_with_text.dart';

class SkippedSvtIdPage extends StatefulWidget {
  const SkippedSvtIdPage({super.key});

  @override
  State<SkippedSvtIdPage> createState() => _SkippedSvtIdPageState();
}

class _SkippedSvtIdPageState extends State<SkippedSvtIdPage> {
  bool showCollectionNo = false;

  @override
  Widget build(BuildContext context) {
    Map<int, List<Servant>> svtGroups = {};
    for (final svt in db.gameData.servantsNoDup.values) {
      if (svt.collectionNo > 0 && svt.type != SvtType.enemyCollectionDetail) {
        svtGroups.putIfAbsent(svt.id ~/ 100000, () => []).add(svt);
      }
    }
    final groupKeys = svtGroups.keys.toList();
    groupKeys.sort();

    List<Widget> slivers = [];
    for (final key in groupKeys) {
      final group = svtGroups[key]!;
      group.sort2((e) => e.id);
      List<Widget> svtIcons = [];

      int lastPos = 0;
      for (final svt in group) {
        int pos = svt.id ~/ 100;
        if (pos > lastPos + 1 && lastPos > 0) {
          int minId = lastPos + 1, maxId = pos - 1;
          if (maxId - minId > 3) {
            svtIcons.add(buildSvtIcon(null, '$minId~$maxId'));
          } else {
            for (int id = minId; id <= maxId; id++) {
              svtIcons.add(buildSvtIcon(null, '$id'));
            }
          }
        }
        svtIcons.add(buildSvtIcon(svt, svt.id % 100 == 0 ? '${svt.id ~/ 100}' : '${svt.id}'));
        lastPos = pos;
      }
      slivers.add(
        SliverGrid.extent(
          maxCrossAxisExtent: 48,
          childAspectRatio: 30 / 45,
          mainAxisSpacing: 2,
          crossAxisSpacing: 3,
          children: svtIcons,
        ),
      );
      slivers.add(SliverToBoxAdapter(child: const Divider()));
    }

    return Scaffold(
      appBar: AppBar(
        title: Text("Svt ID"),
        actions: [
          IconButton(
            onPressed: () {
              setState(() {
                showCollectionNo = !showCollectionNo;
              });
            },
            icon: Icon(Icons.numbers),
          ),
        ],
      ),
      body: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            sliver: MultiSliver(children: slivers),
          ),
        ],
      ),
    );
  }

  Widget buildSvtIcon(Servant? servant, String text) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          flex: 3,
          child:
              servant?.iconBuilder(
                context: context,
                text: showCollectionNo ? '${servant.collectionNo}' : null,
                option: ImageWithTextOption(
                  fontSize: 12,
                  alignment: Alignment.topRight,
                  padding: EdgeInsets.only(top: 3, right: 3),
                ),
              ) ??
              db.getIconImage(Atlas.common.unknownEnemyIcon),
        ),
        Expanded(flex: 1, child: AutoSizeText(text, maxLines: 2, minFontSize: 6, maxFontSize: 12)),
      ],
    );
  }
}
