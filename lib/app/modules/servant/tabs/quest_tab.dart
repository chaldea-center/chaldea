import 'package:chaldea/models/models.dart';
import 'package:chaldea/utils/utils.dart';
import 'package:chaldea/widgets/widgets.dart';
import 'package:flutter/material.dart';

import '../../common/quest_card.dart';

class SvtQuestTab extends StatelessWidget {
  final Servant svt;

  SvtQuestTab({
    Key? key,
    required this.svt,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    List<Widget> children = [];
    for (final questId in svt.relateQuestIds) {
      final quest = db2.gameData.quests[questId];
      if (quest == null) {
        children.add(ListTile(title: Text('Quest $questId')));
      } else {
        children.add(SimpleAccordion(
          headerBuilder: (context, expanded) =>
              ListTile(title: Text(quest.lName.l)),
          contentBuilder: (context) => QuestCard(quest: quest),
        ));
      }
    }
    return ListView.separated(
      itemBuilder: (context, index) => children[index],
      separatorBuilder: (context, index) => kDefaultDivider,
      itemCount: children.length,
    );
  }
}
