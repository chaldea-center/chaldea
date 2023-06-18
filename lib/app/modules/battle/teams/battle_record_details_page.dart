import 'package:chaldea/app/modules/quest/quest_card.dart';
import 'package:chaldea/models/api/api.dart';
import 'package:chaldea/widgets/widgets.dart';

class BattleRecordDetailPage extends StatelessWidget {
  final BattleRecord battleRecord;

  const BattleRecordDetailPage({super.key, required this.battleRecord});

  @override
  Widget build(final BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Team Details'),
      ),
      body: QuestCard(
        quest: null,
        questId: battleRecord.questId,
        offline: false,
        displayPhases: [battleRecord.phase],
        battleOnly: true,
      ),
    );
  }
}
