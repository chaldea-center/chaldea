import 'package:chaldea/app/modules/quest/quest.dart';
import 'package:chaldea/models/models.dart';
import 'package:chaldea/utils/utils.dart';
import 'package:flutter/material.dart';

import '../../app.dart';

class QuestListPage extends StatefulWidget {
  final List<Quest> quests;
  final String? title;
  const QuestListPage({Key? key, this.quests = const [], this.title})
      : super(key: key);

  @override
  State<QuestListPage> createState() => _QuestListPageState();
}

class _QuestListPageState extends State<QuestListPage> {
  @override
  Widget build(BuildContext context) {
    final quests = List.of(widget.quests);
    quests.sort2((e) => e.id);
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title ?? '${quests.length} Quests'),
      ),
      body: ListView.builder(
        itemBuilder: (context, index) {
          final quest = quests[index];
          return ListTile(
            leading: Text(
              '${index + 1}',
              textAlign: TextAlign.center,
            ),
            title: Text(quest.dispName),
            subtitle: Text(quest.lSpot.l),
            horizontalTitleGap: 0,
            onTap: () {
              router.push(
                url: Routes.questI(quest.id),
                child: QuestDetailPage(quest: quest),
                detail: true,
              );
            },
          );
        },
        itemCount: quests.length,
      ),
    );
  }
}
