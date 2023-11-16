import 'package:chaldea/app/app.dart';
import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/models/models.dart';
import 'package:chaldea/utils/utils.dart';
import 'package:chaldea/widgets/widgets.dart';
import 'teams_query_page.dart';

class FavoriteTeamsPage extends StatefulWidget {
  const FavoriteTeamsPage({super.key});

  @override
  State<FavoriteTeamsPage> createState() => _FavoriteTeamsPageState();
}

class _FavoriteTeamsPageState extends State<FavoriteTeamsPage> {
  final favoriteTeams = db.curUser.battleSim.favoriteTeams;

  List<Quest> getQuests() {
    final quests = favoriteTeams.entries
        .where((e) => e.value.isNotEmpty)
        .map((e) => db.gameData.quests[e.key])
        .whereType<Quest>()
        .toList();
    quests.sortByList((e) => [
          e.warId < 1000 ? -e.warId : -(e.war?.event?.startedAt ?? e.questEvent?.startedAt ?? e.openedAt),
          e.priority,
        ]);
    quests.sort((a, b) => Quest.compare(a, b, spotLayer: true));
    return quests;
  }

  @override
  Widget build(BuildContext context) {
    final quests = getQuests();
    return Scaffold(
      appBar: AppBar(
        title: Text.rich(TextSpan(children: [
          const TextSpan(text: '★ ', style: TextStyle(color: Colors.yellow)),
          TextSpan(text: S.current.favorite_teams),
        ])),
      ),
      body: ListView.separated(
        itemBuilder: (context, index) => listItemBuilder(context, quests[index]),
        separatorBuilder: (_, __) => const SizedBox(),
        itemCount: quests.length,
      ),
    );
  }

  Widget listItemBuilder(BuildContext context, Quest quest) {
    final teamIds = favoriteTeams[quest.id]?.toList() ?? [];
    return ListTile(
      dense: true,
      leading: CachedImage(
        imageUrl: quest.spot?.shownImage,
        placeholder: (context, url) => const SizedBox(),
      ),
      title: Text('Lv.${quest.recommendLv} ${quest.lDispName}'),
      subtitle:
          Text(quest.war?.eventReal?.lName.l ?? quest.war?.lName.l ?? quest.questEvent?.lName.l ?? 'Unknown Event'),
      trailing: Text('${teamIds.length} ${S.current.team}'),
      onTap: () async {
        await router.pushPage(TeamsQueryPage(mode: TeamQueryMode.id, teamIds: teamIds));
        if (mounted) setState(() {});
      },
    );
  }
}
