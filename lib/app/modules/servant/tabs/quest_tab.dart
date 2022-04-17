import 'package:chaldea/models/models.dart';
import 'package:chaldea/utils/utils.dart';
import 'package:flutter/material.dart';

import '../../../app.dart';

class SvtQuestTab extends StatelessWidget {
  final Servant svt;

  SvtQuestTab({
    Key? key,
    required this.svt,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      itemBuilder: (context, index) {
        final questId = svt.relateQuestIds[index];
        final quest = db.gameData.quests[questId];
        return ListTile(
          title: Text(quest?.lName.l ?? 'Quest $questId'),
          trailing: Icon(DirectionalIcons.keyboard_arrow_forward(context)),
          onTap: () {
            router.push(url: Routes.questI(questId));
          },
        );
      },
      separatorBuilder: (context, index) => kDefaultDivider,
      itemCount: svt.relateQuestIds.length,
    );
  }
}
