import 'package:chaldea/app/app.dart';
import 'package:chaldea/app/modules/common/not_found.dart';
import 'package:chaldea/app/modules/common/quest_card.dart';
import 'package:flutter/material.dart';
import 'package:chaldea/models/models.dart';

import '../../../generated/l10n.dart';

class QuestDetailPage extends StatefulWidget {
  final int? id;
  final Quest? quest;
  const QuestDetailPage({Key? key, this.id, this.quest}) : super(key: key);

  @override
  State<QuestDetailPage> createState() => _QuestDetailPageState();
}

class _QuestDetailPageState extends State<QuestDetailPage> {
  Quest get quest => _quest!;
  Quest? _quest;

  @override
  void initState() {
    super.initState();
    _quest = widget.quest ?? db2.gameData.quests[widget.id];
  }

  @override
  Widget build(BuildContext context) {
    if (_quest == null) {
      return NotFoundPage(
        title: S.current.quest,
        url: Routes.questI(widget.id ?? 0),
      );
    }
    return Scaffold(
      appBar: AppBar(title: Text(quest.lName.l)),
      body: ListView(
        children: [QuestCard(quest: quest)],
      ),
    );
  }
}
