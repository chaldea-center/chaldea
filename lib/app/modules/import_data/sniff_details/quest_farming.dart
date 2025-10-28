import 'package:chaldea/app/app.dart';
import 'package:chaldea/app/modules/common/filter_group.dart';
import 'package:chaldea/app/modules/master_mission/solver/input_tab.dart';
import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/models/gamedata/mst_data.dart';
import 'package:chaldea/models/models.dart';
import 'package:chaldea/packages/language.dart';
import 'package:chaldea/utils/utils.dart';
import 'package:chaldea/widgets/widgets.dart';

class UserQuestFarmingStatPage extends StatefulWidget {
  final List<UserQuestEntity> userQuests;
  const UserQuestFarmingStatPage({super.key, required this.userQuests});

  @override
  State<UserQuestFarmingStatPage> createState() => _UserQuestFarmingStatPageState();
}

class _QuestInfo {
  UserQuestEntity userQuest;
  Quest? quest;
  int winNum;
  int loseNum;
  _QuestInfo(this.userQuest, this.quest, this.winNum, this.loseNum);
}

enum _UserQuestSort { clearNum, challengeNum }

class _UserQuestFarmingStatPageState extends State<UserQuestFarmingStatPage> with SingleTickerProviderStateMixin {
  late final _tabController = TabController(length: 4, vsync: this);
  List<_QuestInfo> allQuests = []; // Main Free Quests only count the last phase
  List<_QuestInfo> freeQuests = []; // Main Free Quests only count the last phase
  List<_QuestInfo> failedQuests = [];
  int warId = 0;
  _UserQuestSort userQuestSortType = _UserQuestSort.challengeNum;

  @override
  void initState() {
    super.initState();
    for (final userQuest in widget.userQuests) {
      final quest = db.gameData.quests[userQuest.questId];
      if (quest == null) {
        allQuests.add(_QuestInfo(userQuest, quest, 0, 0));
        continue;
      }
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
        if (quest.isAnyRaid || quest.flags.contains(QuestFlag.superBoss)) {
          //
        } else {
          failedQuests.add(info);
        }
      }
      allQuests.add(info);
    }
    freeQuests.sort2((e) => -e.winNum);
    failedQuests.sort2((e) => -e.loseNum);
  }

  List<_QuestInfo> getShownQuests(List<_QuestInfo> quests) {
    if (warId == 0) return quests;
    return quests.where((quest) => quest.quest?.warId == warId).toList();
  }

  String get hint {
    return Language.isZH
        ? """- clearNum=通关次数(仅关卡最后一个进度)。challengeNum=挑战次数，所有进度，包括失败撤退。
- 除“所有”这一页外，仅包含当前数据库中存在的关卡。例如早期每日关卡曾多次变更、重置，非常早期的部分活动关卡等均不显示。
- Free本周回数: 仅显示当前数据库存在的关卡，不显示部分收菜关卡。
- 战败: 不计算团体战(柱子战的战败)"""
        : """- clearNum: clear times of last phase. challengeNum: include all phases and battle lose/withdraw.
- all tabs except "ALL" tab didn't include quests which are not in db
- Free Quest: assume daily quests always win, didn't include outdated daily quests because of reset/changed multiple times
- Failed/lose: didn't count Raid battle, assume always win.""";
  }

  @override
  Widget build(BuildContext context) {
    final war = db.gameData.wars[warId];
    return Scaffold(
      appBar: AppBar(
        title: Text(S.current.quest),
        bottom: FixedHeight.tabBar(
          TabBar(
            controller: _tabController,
            tabs: [
              Tab(text: S.current.general_all),
              Tab(text: S.current.free_quest),
              Tab(text: S.current.failed),
              Tab(text: S.current.general_others),
            ],
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {
              SimpleConfirmDialog(
                title: Text(S.current.help),
                content: Text(hint, style: const TextStyle(fontSize: 14)),
              ).showDialog(context);
            },
            icon: const Icon(Icons.help_outline),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                buildAllTab(),
                buildFreeTab(),
                buildFailTab(),
                Builder(builder: buildOthers),
              ],
            ),
          ),
          kDefaultDivider,
          ListTile(
            dense: true,
            title: Text(S.current.war),
            subtitle: Text(war?.lShortName.setMaxLines(1) ?? S.current.general_all, maxLines: 1),
            tileColor: Theme.of(context).cardColor,
            onTap: () async {
              final selected = await router.pushPage<int>(
                EventChooser(initTab: warId < 1000 ? 0 : 1, showChaldeaGate: true, hasFreeQuest: false),
              );
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
      ),
    );
  }

  Widget buildAllTab() {
    final shownQuests = getShownQuests(allQuests);
    switch (userQuestSortType) {
      case _UserQuestSort.clearNum:
        shownQuests.sortByList((e) => [-e.userQuest.clearNum, -e.userQuest.challengeNum]);
      case _UserQuestSort.challengeNum:
        shownQuests.sortByList((e) => [-e.userQuest.challengeNum, -e.userQuest.clearNum]);
    }
    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            itemCount: shownQuests.length,
            itemBuilder: (context, index) {
              final info = shownQuests[index];
              String primary, secondary;
              switch (userQuestSortType) {
                case _UserQuestSort.clearNum:
                  primary = info.userQuest.clearNum.toString();
                  secondary = info.userQuest.challengeNum.toString();
                case _UserQuestSort.challengeNum:
                  primary = info.userQuest.challengeNum.toString();
                  secondary = info.userQuest.clearNum.toString();
              }
              final trailing = Text.rich(
                TextSpan(
                  children: [
                    TextSpan(text: primary),
                    TextSpan(
                      text: '\n$secondary',
                      style: TextStyle(color: Theme.of(context).textTheme.bodySmall?.color, fontSize: 10),
                    ),
                  ],
                ),
                style: const TextStyle(fontSize: 12),
                textAlign: TextAlign.end,
              );
              return buildQuest(context, info, trailing);
            },
          ),
        ),
        kDefaultDivider,
        SafeArea(
          child: OverflowBar(
            alignment: MainAxisAlignment.center,
            children: [
              FilterGroup<_UserQuestSort>(
                combined: true,
                options: _UserQuestSort.values,
                values: FilterRadioData.nonnull(userQuestSortType),
                optionBuilder: (value) => Text(value.name),
                onFilterChanged: (v, _) {
                  setState(() {
                    userQuestSortType = v.radioValue!;
                  });
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget buildFreeTab() {
    final shownQuests = getShownQuests(freeQuests);
    return ListView.builder(
      itemCount: shownQuests.length,
      itemBuilder: (context, index) => buildQuest(
        context,
        shownQuests[index],
        Text(Transl.special.funcValCountTimes(shownQuests[index].winNum), style: const TextStyle(fontSize: 12)),
      ),
    );
  }

  Widget buildFailTab() {
    final shownQuests = getShownQuests(failedQuests);
    return ListView.builder(
      itemCount: shownQuests.length,
      itemBuilder: (context, index) => buildQuest(
        context,
        shownQuests[index],
        Text(Transl.special.funcValCountTimes(shownQuests[index].loseNum), style: const TextStyle(fontSize: 12)),
      ),
    );
  }

  Widget buildQuest(BuildContext context, _QuestInfo info, Widget trailing) {
    return ListTile(
      dense: true,
      horizontalTitleGap: 8,
      leading: CachedImage(
        imageUrl: info.quest?.spot?.shownImage,
        width: 32,
        height: 32,
        placeholder: (_, _) => const SizedBox.shrink(),
      ),
      title: Text(info.quest?.lDispName ?? info.userQuest.questId.toString()),
      subtitle: Text(
        info.quest == null
            ? S.current.unknown
            : (info.quest?.event?.shownName ??
                      info.quest?.war?.eventReal?.shownName ??
                      info.quest?.war?.lShortName ??
                      "War ${info.quest?.warId}")
                  .setMaxLines(1),
      ),
      trailing: trailing,
      onTap: () {
        router.push(url: Routes.questI(info.userQuest.questId));
      },
      onLongPress: () {
        SimpleConfirmDialog(
          title: Text(info.quest?.dispName ?? info.userQuest.questId.toString()),
          content: Text(
            'phase: ${info.userQuest.questPhase}/${info.quest?.phases.lastOrNull}\n'
            'clearNum: ${info.userQuest.clearNum}\n'
            'challengeNum: ${info.userQuest.challengeNum}',
          ),
          showCancel: false,
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
        ListTile(dense: true, title: Text(S.current.rankup_quest), trailing: Text(rankups.toString())),
      ],
    );
  }
}
