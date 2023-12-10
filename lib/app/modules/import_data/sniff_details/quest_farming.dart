import 'package:chaldea/app/app.dart';
import 'package:chaldea/app/modules/master_mission/solver/input_tab.dart';
import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/models/gamedata/toplogin.dart';
import 'package:chaldea/models/models.dart';
import 'package:chaldea/utils/utils.dart';
import 'package:chaldea/widgets/widgets.dart';

class UserQuestFarmingStatPage extends StatefulWidget {
  final List<UserQuest> userQuests;
  const UserQuestFarmingStatPage({super.key, required this.userQuests});

  @override
  State<UserQuestFarmingStatPage> createState() => _UserQuestFarmingStatPageState();
}

class _QuestInfo {
  UserQuest userQuest;
  Quest quest;
  int winNum;
  int loseNum;
  _QuestInfo(this.userQuest, this.quest, this.winNum, this.loseNum);
}

class _UserQuestFarmingStatPageState extends State<UserQuestFarmingStatPage> with SingleTickerProviderStateMixin {
  late final _tabController = TabController(length: 3, vsync: this);
  List<_QuestInfo> freeQuests = []; // Main Free Quests only count the last phase
  List<_QuestInfo> failedQuests = [];
  int warId = 0;

  @override
  void initState() {
    super.initState();
    for (final userQuest in widget.userQuests) {
      final quest = db.gameData.quests[userQuest.questId];
      if (quest == null) continue;
      // 邪馬台国 収穫クエスト
      if (quest.afterClear == QuestAfterClearType.resetInterval) continue;
      if (userQuest.questPhase == 0 && userQuest.challengeNum == 1 && userQuest.clearNum == 1) continue;

      int successNum, failedNum;
      if (quest.warId == WarId.daily) {
        // assume all success. clearNum is not accurate because once reset
        successNum = userQuest.challengeNum;
        failedNum = 0;
      } else {
        successNum = userQuest.clearNum > 0 ? userQuest.clearNum + userQuest.questPhase - 1 : userQuest.questPhase;
        failedNum = userQuest.challengeNum - successNum;
      }
      final info = _QuestInfo(userQuest, quest, successNum, failedNum);
      if (successNum > 0 && quest.afterClear != QuestAfterClearType.close) {
        freeQuests.add(info);
      }
      if (failedNum > 0) {
        if (quest.flags.any((flag) => flag.name.toLowerCase().contains('raid') || flag == QuestFlag.superBoss)) {
          //
        } else {
          failedQuests.add(info);
        }
      }
    }
    freeQuests.sort2((e) => -e.winNum);
    failedQuests.sort2((e) => -e.loseNum);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(S.current.quest),
        bottom: FixedHeight.tabBar(TabBar(controller: _tabController, tabs: [
          Tab(text: S.current.free_quest),
          Tab(text: S.current.failed),
          Tab(text: S.current.general_others),
        ])),
        actions: [
          IconButton(
            onPressed: () {
              const SimpleCancelOkDialog(
                title: Text("Notes"),
                content: Text("1. didn't count lose for Raid\n"
                    "2. assume daily quests all win"),
              ).showDialog(context);
            },
            icon: const Icon(Icons.help),
          )
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          buildFreeTab(),
          ListView.builder(
            itemCount: failedQuests.length,
            itemBuilder: (context, index) => buildQuest(context, failedQuests[index], failedQuests[index].loseNum),
          ),
          Builder(builder: buildOthers),
        ],
      ),
    );
  }

  Widget buildFreeTab() {
    final war = db.gameData.wars[warId];
    final shownQuests = freeQuests.toList();
    if (warId != 0) {
      shownQuests.retainWhere((quest) => quest.quest.warId == warId);
    }
    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            itemCount: shownQuests.length,
            itemBuilder: (context, index) => buildQuest(context, shownQuests[index], shownQuests[index].winNum),
          ),
        ),
        kDefaultDivider,
        ListTile(
          title: Text(S.current.war),
          subtitle: Text(war?.lShortName ?? S.current.general_all),
          tileColor: Theme.of(context).cardColor,
          onTap: () async {
            final selected = await router.pushPage<int>(EventChooser(initTab: warId < 1000 ? 0 : 1));
            if (selected != null) {
              warId = selected;
            }
            if (mounted) setState(() {});
          },
          trailing: IconButton(
            onPressed: () {
              setState(() {
                warId = 0;
              });
            },
            icon: const Icon(Icons.clear),
          ),
        ),
      ],
    );
  }

  Widget buildQuest(BuildContext context, _QuestInfo info, int count) {
    return ListTile(
      dense: true,
      horizontalTitleGap: 8,
      leading: CachedImage(
        imageUrl: info.quest.spot?.shownImage,
        width: 32,
        height: 32,
        placeholder: (_, __) => const SizedBox.shrink(),
      ),
      title: Text(info.quest.lDispName),
      subtitle: Text((info.quest.questEvent?.shownName ??
              info.quest.war?.eventReal?.shownName ??
              info.quest.war?.lShortName ??
              "War ${info.quest.warId}")
          .setMaxLines(1)),
      trailing: Text(
        Transl.special.funcValCountTimes(count),
        textAlign: TextAlign.end,
        style: const TextStyle(fontSize: 12),
      ),
      onTap: info.quest.routeTo,
      onLongPress: () {
        SimpleCancelOkDialog(
          title: Text(info.quest.dispName),
          content: Text('phase: ${info.userQuest.questPhase}/${info.quest.phases.lastOrNull}\n'
              'clearNum: ${info.userQuest.clearNum}\n'
              'challengeNum: ${info.userQuest.challengeNum}'),
          hideCancel: true,
        ).showDialog(context);
      },
    );
  }

  Widget buildOthers(BuildContext context) {
    int interludes = 0, rankups = 0, spiritReleases = 0;
    for (final userQuest in widget.userQuests) {
      if (userQuest.clearNum <= 0) continue;
      final quest = db.gameData.quests[userQuest.questId];
      if (quest == null) continue;
      if (quest.type == QuestType.friendship) {
        if (quest.name.contains('霊基解放クエスト')) {
          spiritReleases += 1;
        } else {
          interludes += 1;
        }
      } else if (quest.warId == WarId.rankup) {
        rankups += 1;
      }
    }
    return ListView(
      children: [
        ListTile(
          dense: true,
          title: Text('${S.current.interlude} + ${S.current.spirit_origin_release_quest}'),
          trailing: Text('$interludes+$spiritReleases=${interludes + spiritReleases}'),
        ),
        ListTile(
          dense: true,
          title: Text(S.current.rankup_quest),
          trailing: Text(rankups.toString()),
        )
      ],
    );
  }
}
