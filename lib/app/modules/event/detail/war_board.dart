import 'package:chaldea/app/app.dart';
import 'package:chaldea/app/modules/common/builders.dart';
import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/models/models.dart';
import 'package:chaldea/widgets/widgets.dart';

class EventWarBoardTab extends HookWidget {
  final Event event;
  const EventWarBoardTab({super.key, required this.event});

  @override
  Widget build(BuildContext context) {
    final warBoards = List.of(event.warBoards);
    return ListView.separated(
      controller: useScrollController(),
      itemBuilder: (context, index) => buildOne(context, warBoards[index], index),
      separatorBuilder: (_, __) => const Divider(height: 16),
      itemCount: warBoards.length,
    );
  }

  Widget buildOne(BuildContext context, WarBoard warBoard, int index) {
    List<Widget> children = [
      DividerWithTitle(title: 'No.${warBoard.warBoardId}'),
    ];
    for (final stage in warBoard.stages) {
      final quest = db.gameData.quests[stage.questId];
      children.add(ListTile(
        dense: true,
        leading: db.getIconImage(quest?.spot?.shownImage),
        title: Text(quest?.lName.l ?? 'Quest ${stage.questId}/${stage.questPhase}'),
        subtitle: Text('COST ${stage.formationCost}  ${stage.boardMessage}'),
        onTap: () {
          router.push(url: Routes.questI(stage.questId));
        },
      ));
      final gifts = stage.squares.expand((e) => e.treasures).expand((e) => e.gifts).toList();
      if (gifts.isNotEmpty) {
        children.add(ListTile(
          dense: true,
          title: Text(S.current.event_treasure_box),
          subtitle: SharedBuilder.giftGrid(context: context, gifts: gifts, width: 36),
        ));
      }
      if (quest != null && quest.gifts.isNotEmpty) {
        children.add(ListTile(
          dense: true,
          title: Text(S.current.quest_reward),
          subtitle: SharedBuilder.giftGrid(context: context, gifts: quest.gifts, width: 36),
        ));
      }
    }
    return Column(mainAxisSize: MainAxisSize.min, children: children);
  }
}
