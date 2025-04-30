import 'package:flutter/material.dart';

import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/models/gamedata/toplogin.dart';
import 'package:chaldea/models/models.dart';
import 'package:chaldea/utils/extension.dart';

class RandomMissionEnableQuestPage extends StatefulWidget {
  final RandomMissionOption option;
  final List<Quest> quests;
  final MasterDataManager mstData;
  const RandomMissionEnableQuestPage({super.key, required this.option, required this.quests, required this.mstData});

  @override
  State<RandomMissionEnableQuestPage> createState() => _RandomMissionEnableQuestPageState();
}

class _RandomMissionEnableQuestPageState extends State<RandomMissionEnableQuestPage> {
  @override
  Widget build(BuildContext context) {
    final quests = widget.quests.toList();
    quests.sort2((e) => e.priority);
    return Scaffold(
      appBar: AppBar(title: Text(S.current.quest)),
      body: ListView.builder(
        itemBuilder: (context, index) {
          final quest = quests[index];
          return CheckboxListTile(
            dense: true,
            secondary: db.getIconImage(quest.spot?.shownImage),
            title: Text(quest.lName.l),
            subtitle: Text('Lv.${quest.recommendLv} ${quest.lSpot.l}'),
            value: widget.option.enabledQuests.contains(quest.id),
            onChanged: (v) {
              setState(() {
                widget.option.enabledQuests.toggle(quest.id);
              });
            },
          );
        },
        itemCount: quests.length,
      ),
    );
  }
}
