//@dart=2.12
import 'package:chaldea/components/components.dart';
import 'package:chaldea/modules/shared/quest_card.dart';
import 'package:getwidget/components/accordian/gf_accordian.dart';

import '../servant_detail_page.dart';
import 'svt_tab_base.dart';

class SvtQuestTab extends SvtTabBaseWidget {
  SvtQuestTab(
      {Key? key,
      ServantDetailPageState? parent,
      Servant? svt,
      ServantStatus? status})
      : super(key: key, parent: parent, svt: svt, status: status);

  @override
  _SvtQuestTabState createState() =>
      _SvtQuestTabState(parent: parent, svt: svt, plan: status);
}

class _SvtQuestTabState extends SvtTabBaseState<SvtQuestTab> {
  _SvtQuestTabState(
      {ServantDetailPageState? parent, Servant? svt, ServantStatus? plan})
      : super(parent: parent, svt: svt, status: plan);

  @override
  Widget build(BuildContext context) {
    super.build(context);
    if (db.gameData.svtQuests[svt.no]?.isNotEmpty != true) {
      return ListTile(title: Text(S.of(context).no_servant_quest_hint));
    }
    final List<Quest> quests = db.gameData.svtQuests[svt.no]!;
    return ListView(
      children: quests.map((quest) {
        return GFAccordion(
          title: quest.localizedName,
          margin: EdgeInsets.symmetric(vertical: 3),
          // titlePadding: EdgeInsets.zero,
          // contentPadding: EdgeInsets.zero,
          contentChild: QuestCard(quest: quest),
        );
      }).toList(),
    );
  }
}
