import 'package:chaldea/components/components.dart';
import 'package:chaldea/modules/shared/quest_card.dart';

import '../servant_detail_page.dart';
import 'svt_tab_base.dart';

class SvtQuestTab extends SvtTabBaseWidget {
  const SvtQuestTab(
      {Key? key,
      ServantDetailPageState? parent,
      Servant? svt,
      ServantStatus? status})
      : super(key: key, parent: parent, svt: svt, status: status);

  @override
  _SvtQuestTabState createState() => _SvtQuestTabState();
}

class _SvtQuestTabState extends SvtTabBaseState<SvtQuestTab> {
  @override
  Widget build(BuildContext context) {
    if (db.gameData.svtQuests[svt.no]?.isNotEmpty != true) {
      return ListTile(title: Text(S.of(context).no_servant_quest_hint));
    }
    final List<Quest> quests = db.gameData.svtQuests[svt.no]!;

    return ListView.separated(
      itemBuilder: (context, index) => SimpleAccordion(
        headerBuilder: (context, expanded) =>
            ListTile(title: Text(quests[index].localizedName)),
        contentBuilder: (context) => QuestCard(quest: quests[index]),
      ),
      separatorBuilder: (context, index) => kDefaultDivider,
      itemCount: quests.length,
    );
  }
}
