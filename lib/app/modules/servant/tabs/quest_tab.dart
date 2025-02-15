import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/models/models.dart';
import 'package:chaldea/utils/utils.dart';
import 'package:chaldea/widgets/widgets.dart';
import '../../../app.dart';

class SvtQuestTab extends StatelessWidget {
  final Servant svt;

  SvtQuestTab({super.key, required this.svt});

  @override
  Widget build(BuildContext context) {
    List<Widget> children = [];
    if (svt.relateQuestIds.isNotEmpty) {
      children.add(SHeader(S.current.interlude_and_rankup));
      children.addAll(svt.relateQuestIds.map((e) => _buildQuest(context, e)));
    }
    if (svt.trialQuestIds.isNotEmpty) {
      children.add(SHeader(S.current.trial_quest));
      children.addAll(svt.trialQuestIds.map((e) => _buildQuest(context, e)));
    }
    return ListView.separated(
      itemBuilder: (context, index) => children[index],
      separatorBuilder: (context, index) => kDefaultDivider,
      itemCount: children.length,
    );
  }

  Widget _buildQuest(BuildContext context, int questId) {
    final quest = db.gameData.quests[questId];
    return ListTile(
      title: Text(quest?.lName.l ?? 'Quest $questId'),
      trailing: Icon(DirectionalIcons.keyboard_arrow_forward(context)),
      onTap: () {
        router.push(url: Routes.questI(questId));
      },
    );
  }
}
