import 'dart:math';

import 'package:flutter_easyloading/flutter_easyloading.dart';

import 'package:chaldea/app/api/chaldea.dart';
import 'package:chaldea/app/app.dart';
import 'package:chaldea/app/modules/battle/formation/formation_card.dart';
import 'package:chaldea/app/modules/battle/simulation_preview.dart';
import 'package:chaldea/app/modules/common/builders.dart';
import 'package:chaldea/app/modules/home/subpage/login_page.dart';
import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/models/api/api.dart';
import 'package:chaldea/models/models.dart';
import 'package:chaldea/packages/logger.dart';
import 'package:chaldea/utils/catcher/server_feedback_handler.dart';
import 'package:chaldea/utils/utils.dart';
import 'package:chaldea/widgets/widgets.dart';
import '../../common/filter_page_base.dart';
import '../utils.dart';
import 'filter.dart';

enum TeamQueryMode { user, quest, id, ranking }

class TeamsQueryPage extends StatefulWidget {
  final TeamQueryMode mode;
  final Quest? quest;
  final BattleQuestInfo? phaseInfo;
  final List<int>? teamIds;
  final int? userId; // name or id
  final String? username; // name or id
  final ValueChanged<BattleShareData>? onSelect;

  const TeamsQueryPage({
    super.key,
    required this.mode,
    this.quest,
    this.phaseInfo,
    this.teamIds,
    this.userId,
    this.username,
    this.onSelect,
  });

  @override
  State<TeamsQueryPage> createState() => _TeamsQueryPageState();
}

class _TeamsQueryPageState extends State<TeamsQueryPage> with SearchableListState<UserBattleData, TeamsQueryPage> {
  static const _defaultPageSize = 200;
  int pageSize = _defaultPageSize;
  final secrets = db.settings.secrets;
  int? get curUserId => secrets.user?.id;

  TeamQueryMode get mode => widget.mode;

  int offset = 0;
  TeamQueryResult queryResult = TeamQueryResult(data: []);
  final filterData = TeamFilterData(true);

  @override
  Iterable<UserBattleData> get wholeData => queryResult.data;

  @override
  void initState() {
    super.initState();
    _queryTeams(offset);
  }

  @override
  Widget build(BuildContext context) {
    filterShownList();
    if (db.runtimeData.remoteConfig?.versionConstraints?.laplace?.isThisAppInvalid() ?? false) {
      return Center(child: Text(S.current.update_app_hint));
    }
    return scrollListener(useGrid: false, appBar: appBar);
  }

  PreferredSizeWidget? get appBar {
    final username = widget.username ?? widget.userId ?? secrets.user?.name ?? "Not Login";
    return AppBar(
      title: Text(switch (mode) {
        TeamQueryMode.user => '${S.current.team} @$username',
        TeamQueryMode.quest => '${S.current.team} - ${widget.quest?.lDispName.breakWord}',
        TeamQueryMode.id => S.current.team_shared,
        TeamQueryMode.ranking => 'Ranking',
      }),
      actions: [
        IconButton(
          icon: const Icon(Icons.filter_alt),
          tooltip: S.current.filter,
          onPressed: () {
            Set<int> svtIds = {}, ceIds = {}, mcIds = {}, eventWarIds = {};
            for (final record in queryResult.data) {
              final team = record.decoded;
              final eventWarId = db.gameData.quests[team?.quest?.id ?? record.questId]?.eventIdPriorWarId;
              if (eventWarId != null) eventWarIds.add(eventWarId);
              if (team == null) continue;

              final svts = team.formation.svts;
              svtIds.addAll(svts.map((e) => e?.svtId ?? 0).where((e) => e > 0));
              ceIds.addAll(svts.map((e) => e?.equip1.id ?? 0).where((e) => e > 0));
              if (team.hasUsedMCSkills()) {
                mcIds.add(team.formation.mysticCode.mysticCodeId ?? 0);
              }
            }
            return FilterPage.show(
              context: context,
              builder: (context) => TeamFilterPage(
                filterData: filterData,
                availableSvts: svtIds,
                availableCEs: ceIds,
                availableMCs: mcIds,
                availableEventWarIds: eventWarIds,
                onChanged: (_) {
                  if (mounted) {
                    setState(() {});
                  }
                },
              ),
            );
          },
        ),
      ],
    );
  }

  @override
  PreferredSizeWidget? get buttonBar {
    final List<Widget> buttons;
    if (widget.mode == TeamQueryMode.user && !secrets.isLoggedIn) {
      buttons = [
        ElevatedButton(
          onPressed: () async {
            await router.pushPage(LoginPage());
            if (mounted) setState(() {});
          },
          child: Text(S.current.login_login),
        ),
      ];
    } else {
      String rangeHint;
      if (queryResult.data.isEmpty && queryResult.offset == 0 && (queryResult.total ?? 0) == 0) {
        rangeHint = '-';
      } else {
        rangeHint = MaterialLocalizations.of(context).pageRowsInfoTitle(
          queryResult.offset + 1,
          queryResult.offset + queryResult.data.length,
          queryResult.total ?? -1,
          false,
        );
      }
      buttons = [
        Text(rangeHint, style: Theme.of(context).textTheme.bodySmall),
        const SizedBox(width: 8),
        TextButton(
          onPressed: offset == 0 ? null : () => _queryTeams(offset - pageSize),
          style: kTextButtonDenseStyle,
          child: Text(S.current.prev_page),
        ),
        TextButton(
          onPressed: !queryResult.hasNextPage ? null : () => _queryTeams(offset + pageSize),
          style: kTextButtonDenseStyle,
          child: Text(S.current.next_page),
        ),
        TextButton(
          onPressed: () async {
            EasyThrottle.throttle('team_query_refresh', const Duration(seconds: 2), () {
              _queryTeams(offset, refresh: true);
            });
          },
          style: kTextButtonDenseStyle,
          child: Text(S.current.refresh),
        ),
      ];
    }

    return PreferredSize(
      preferredSize: const Size.fromHeight(48),
      child: SizedBox(
        height: 48,
        child: ListView(
          reverse: true,
          shrinkWrap: true,
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsetsDirectional.fromSTEB(0, 8, 0, 12),
          children: [for (final child in buttons.reversed) Center(child: child)],
        ),
      ),
    );
  }

  @override
  Widget listItemBuilder(UserBattleData record) {
    final index = queryResult.data.indexOf(record);
    final shareData = record.decoded;
    final shownIndex = offset + index + 1;

    Widget child = Column(
      children: [
        const SizedBox(height: 6),
        buildHeader(shownIndex, record),
        buildExtraInfo(record),
        if (widget.mode == TeamQueryMode.user || widget.mode == TeamQueryMode.id) buildQuest(record),
        if (shareData != null)
          FormationCard(
            formation: shareData.formation,
            fadeOutMysticCode: shareData.actions.isNotEmpty && !shareData.hasUsedMCSkills(),
          ),
        buildTeamActions(record),
        const SizedBox(height: 6),
      ],
    );
    return Material(
      color: shownList.indexOf(record).isOdd ? Theme.of(context).hoverColor : null,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 80 * 8),
          child: child,
        ),
      ),
    );
  }

  Widget buildHeader(int index, UserBattleData record) {
    final themeData = Theme.of(context);
    final style = themeData.textTheme.bodySmall;
    Future<void> onVote(bool isUpVote) async {
      if (!secrets.isLoggedIn) return;
      if (record.userId == secrets.user?.id) {
        EasyLoading.showInfo("Do not vote your own team.");
        return;
      }
      record.tempVotes ??= record.votes.copy();
      record.tempVotes!.updateMyVote(isUpVote);
      if (mounted) setState(() {});
      EasyDebounce.debounce('team_vote_${record.id}', const Duration(seconds: 1), () async {
        final result = await ChaldeaWorkerApi.teamVote(
          teamId: record.id,
          voteValue: (record.tempVotes ?? record.votes).mine,
        );
        record.tempVotes = null;
        if (result != null) {
          record.votes = result;
          ChaldeaWorkerApi.clearTeamCache();
        }
        if (mounted) setState(() {});
      });
    }

    final votes = record.tempVotes ?? record.votes;
    final username = record.username ?? "User ${record.userId}";
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(width: 16),
        Expanded(
          child: Text.rich(
            TextSpan(
              children: [
                TextSpan(text: '${S.current.team} $index - '),
                mode == TeamQueryMode.user
                    ? TextSpan(text: username)
                    : SharedBuilder.textButtonSpan(
                        context: context,
                        text: username,
                        onTap: () {
                          router.push(
                            url: Routes.laplaceManageTeam,
                            child: TeamsQueryPage(
                              mode: TeamQueryMode.user,
                              userId: record.userId,
                              username: record.username,
                            ),
                          );
                        },
                      ),
                TextSpan(text: ' [${record.id}]'),
                // if (widget.phaseInfo?.enemyHash == null)
                //   TextSpan(text: '\n${S.current.version} ${record.enemyHash.substring2(2)}'),
              ],
            ),
            style: style,
          ),
        ),
        if (record.decoded?.isCritTeam == true)
          Tooltip(
            message: S.current.critical_team,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: db.getIconImage(AssetURL.i.buffIcon(324), width: 18, height: 18),
            ),
          ),
        if (record.decoded?.options.simulateAi == true)
          Tooltip(
            message: S.current.simulate_simple_ai,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Icon(Icons.smart_toy_outlined, size: 18, color: Theme.of(context).colorScheme.primary),
            ),
          ),
        InkWell(
          onTap: secrets.isLoggedIn ? () => onVote(true) : null,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(
                Icons.thumb_up_alt,
                size: 16,
                color: votes.mine == 1 ? themeData.colorScheme.primary : themeData.unselectedWidgetColor,
              ),
              Text(votes.up.toString().padRight(4, ' '), style: style),
            ],
          ),
        ),
        InkWell(
          onTap: secrets.isLoggedIn ? () => onVote(false) : null,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(
                Icons.thumb_down_alt,
                size: 16,
                color: votes.mine == -1 ? themeData.colorScheme.primaryContainer : themeData.unselectedWidgetColor,
              ),
              Text(votes.down.toString().padRight(4, ' '), style: style),
            ],
          ),
        ),
        const SizedBox(width: 4),
        InkWell(
          onTap: () {
            ReportTeamDialog(record: record, isMyTeam: record.userId == curUserId).showDialog(context);
          },
          child: Icon(
            Icons.report_outlined,
            size: 18,
            color: Theme.of(context).colorScheme.errorContainer.withAlpha(204),
          ),
        ),
        const SizedBox(width: 24),
      ],
    );
  }

  Widget buildExtraInfo(UserBattleData record) {
    List<InlineSpan> spans = [];
    final team = record.decoded;
    if (team == null) return const SizedBox.shrink();

    if (team.isCritTeam) {
      spans.add(TextSpan(text: S.current.critical_team));
    }

    final maxRandom = Maths.max(team.actions.map((e) => e.options.random));
    if (maxRandom > ConstData.constants.attackRateRandomMin) {
      spans.add(TextSpan(text: '${S.current.battle_random} ${maxRandom / 1000}'));
    }
    final minThreshold = Maths.min(team.actions.map((e) => e.options.threshold));
    if (minThreshold < 1000) {
      spans.add(
        TextSpan(text: '${S.current.battle_probability_threshold} ${minThreshold.format(percent: true, base: 10)}'),
      );
    }

    Map<ClassBoard, String> classBoardValues = {};
    for (final svtData in team.formation.svts) {
      final svt = db.gameData.servantsById[svtData?.svtId];
      final classBoardData = svtData?.classBoardData;
      if (svtData == null || svt == null || classBoardData == null) continue;
      final board = ClassBoard.getClassBoard(svt.classId), grandBoard = ClassBoard.getGrandClassBoard(svt.classId);
      if (classBoardData.classBoardSquares.isNotEmpty && board != null) {
        classBoardValues[board] ??= '${classBoardData.classBoardSquares.length}/${board.getSkillSquares().length}';
      }
      if (svtData.grandSvt && classBoardData.grandClassBoardSquares.isNotEmpty && grandBoard != null) {
        classBoardValues[grandBoard] ??=
            '${classBoardData.grandClassBoardSquares.length}/${grandBoard.getSkillSquares().length}';
      }
    }
    if (classBoardValues.isNotEmpty) {
      spans.add(
        TextSpan(
          text: S.current.class_board,
          children: [
            TextSpan(
              style: const TextStyle(fontSize: 10),
              children: [
                const TextSpan(text: '('),
                ...divideList([
                  for (final (board, value) in classBoardValues.items) TextSpan(text: '${board.dispName} $value'),
                ], const TextSpan(text: ', ')),
                const TextSpan(text: ')'),
              ],
            ),
          ],
        ),
      );
    }

    final normalAttackCount = team.normalAttackCount;
    if (normalAttackCount > 0) {
      spans.add(TextSpan(text: '$normalAttackCount ${S.current.battle_command_card}'));
    }

    // team.options.pointBuffs;
    final enemyRateUp = team.options.enemyRateUp?.toList() ?? [];
    if (enemyRateUp.isNotEmpty) {
      for (final indiv in enemyRateUp) {
        spans.add(
          TextSpan(
            children: [
              CenterWidgetSpan(
                child: db.getIconImage(
                  AssetURL.i.buffIcon(Theme.of(context).isDarkMode ? 1014 : 1015),
                  width: 18,
                  height: 18,
                ),
              ),
              TextSpan(text: Transl.traitName(indiv)),
            ],
          ),
        );
      }
    }

    if (team.formation.svts.any((e) => e != null && e.allowedExtraSkills.isNotEmpty)) {
      spans.add(TextSpan(text: S.current.optional_event_passive));
    }
    //
    final quest = db.gameData.quests[team.quest?.id];
    if (quest != null) {
      Set<String> unreleasedSvts = {};
      for (final svtData in team.formation.svts) {
        final svt = db.gameData.servantsById[svtData?.svtId];
        if (svt == null) continue;
        final releasedAt = svt.extra.getReleasedAt();
        if (quest.closedAt < releasedAt && releasedAt > 0) {
          unreleasedSvts.add(svt.lName.l);
        }
      }
      if (unreleasedSvts.isNotEmpty) {
        spans.add(TextSpan(text: '${S.current.svt_not_release_hint}(${unreleasedSvts.join(" / ")})'));
      }
    }

    if (spans.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      alignment: Alignment.centerLeft,
      child: Text.rich(
        TextSpan(children: divideList(spans, const TextSpan(text: ', '))),
        style: TextStyle(color: Theme.of(context).textTheme.bodySmall?.color, fontSize: 14),
      ),
    );
  }

  Widget buildQuest(UserBattleData record) {
    final quest = db.gameData.quests[record.questId];
    List<InlineSpan> questName = [];
    if (quest == null) {
      questName.add(TextSpan(text: "Quest ${record.questId}/${record.phase}"));
    } else {
      questName.add(TextSpan(text: quest.lDispName.setMaxLines(1)));
      final eventName = quest.event?.shownName ?? quest.war?.lShortName;
      if (eventName != null) {
        questName.add(
          TextSpan(
            text: '\n${eventName.setMaxLines(1)}',
            style: TextStyle(fontSize: 12, color: Theme.of(context).textTheme.bodySmall?.color),
          ),
        );
      }
    }
    return ListTile(
      dense: true,
      leading: db.getIconImage(quest?.spot?.shownImage, width: 24),
      minLeadingWidth: 24,
      title: Text.rich(TextSpan(children: questName), maxLines: 2, overflow: TextOverflow.ellipsis),
      trailing: Icon(DirectionalIcons.keyboard_arrow_forward(context)),
      onTap: () {
        router.push(url: Routes.questI(record.questId, record.phase));
      },
    );
  }

  Widget buildTeamActions(UserBattleData record) {
    List<Widget> actions = [];
    final teamData = record.decoded;
    actions.add(
      IconButton(
        onPressed: () {
          setState(() {
            db.curUser.battleSim.favoriteTeams.putIfAbsent(record.questId, () => {}).toggle(record.id);
          });
        },
        icon: db.curUser.battleSim.isTeamFavorite(record.questId, record.id)
            ? const Icon(Icons.star, color: Colors.amber)
            : const Icon(Icons.star_border, color: Colors.grey),
        tooltip: S.current.favorite_teams,
      ),
    );

    if (mode == TeamQueryMode.user || record.userId == curUserId || secrets.user?.isTeamMod == true) {
      actions.add(
        TextButton(
          onPressed: () {
            final isOthers = record.userId != curUserId;
            SimpleConfirmDialog(
              title: Text(S.current.confirm),
              content: Text(
                [
                  '${S.current.delete} No.${record.id}',
                  if (isOthers) "Waring: ${record.userId}'s, not your team",
                ].join('\n'),
              ),
              onTapOk: () {
                _deleteUserTeam(record);
              },
            ).showDialog(context);
          },
          style: TextButton.styleFrom(foregroundColor: Theme.of(context).colorScheme.error),
          child: Text(S.current.delete),
        ),
      );
    }
    if (teamData != null) {
      actions.add(
        TextButton(
          onPressed: () {
            replaySimulation(detail: teamData, replayTeamId: record.id);
          },
          child: Text(S.current.details),
        ),
      );
    }
    actions.add(const SizedBox(width: 8));
    actions.addAll([
      FilledButton(
        onPressed: teamData == null
            ? null
            : () {
                if (widget.onSelect != null) {
                  Navigator.pop(context);
                  widget.onSelect!(teamData);
                } else {
                  final data2 = teamData.copy();
                  data2
                    ..actions.clear()
                    ..delegate = null;
                  router.pushPage(SimulationPreview(shareUri: data2.toUriV2()));
                }
              },
        child: Text(S.current.select),
      ),
      IconButton(
        onPressed: teamData == null
            ? null
            : () => showDialog(
                context: context,
                useRootNavigator: false,
                builder: (context) => buildShareDialog(context, record),
              ),
        icon: const Icon(Icons.ios_share),
        tooltip: S.current.share,
      ),
    ]);

    return Wrap(alignment: WrapAlignment.center, crossAxisAlignment: WrapCrossAlignment.center, children: actions);
  }

  @override
  Widget gridItemBuilder(UserBattleData record) {
    throw UnimplementedError("Do not support GridView");
  }

  @override
  bool filter(UserBattleData record) {
    final data = record.decoded;
    if (data == null) return true;
    if (filterData.favorite && !db.curUser.battleSim.isTeamFavorite(record.questId, record.id)) {
      return false;
    }
    return filterData.filter(data);
  }

  Future<void> _queryTeams(int offset, {bool refresh = false}) async {
    offset = max(0, offset);

    if (widget.mode == TeamQueryMode.user && !secrets.isLoggedIn) return;
    Future<TeamQueryResult?> task;
    switch (mode) {
      case TeamQueryMode.user:
        final userId = widget.userId ?? (widget.username != null ? int.tryParse(widget.username!) : null);
        task = showEasyLoading(
          () => ChaldeaWorkerApi.teamsByUser(
            limit: pageSize,
            offset: offset,
            expireAfter: refresh ? Duration.zero : const Duration(days: 2),
            userId: userId,
            username: widget.username,
          ),
        );
      case TeamQueryMode.quest:
        final quest = widget.quest;
        final phase = widget.phaseInfo?.phase ?? quest?.phases.lastOrNull;
        if (quest == null || !quest.isLaplaceSharable || phase == null) return;
        task = showEasyLoading(
          () => ChaldeaWorkerApi.teamsByQuest(
            questId: quest.id,
            phase: phase,
            enemyHash: widget.phaseInfo?.enemyHash,
            limit: pageSize,
            offset: offset,
            expireAfter: refresh ? Duration.zero : null,
          ),
        );
      case TeamQueryMode.id:
        task = showEasyLoading(() async {
          final teamIds = widget.teamIds ?? [];
          if (teamIds.isEmpty) {
            return null;
          } else if (teamIds.length == 1) {
            final team = await ChaldeaWorkerApi.team(teamIds.single, expireAfter: refresh ? Duration.zero : null);
            if (team == null) return null;
            return TeamQueryResult(offset: 0, limit: 1, total: 1, data: [team]);
          } else {
            return ChaldeaWorkerApi.teams(teamIds: teamIds);
          }
        });
      case TeamQueryMode.ranking:
        task = showEasyLoading(
          () => ChaldeaWorkerApi.teamsRanking(
            limit: pageSize,
            offset: offset,
            expireAfter: refresh ? Duration.zero : null,
          ),
        );
    }
    TeamQueryResult? result = await task;
    if (result != null) {
      if ((result.total ?? 0) > result.limit) {
        pageSize = result.limit;
      }
      if (mode != TeamQueryMode.ranking) {
        result.data.sortByList(
          (e) => [
            e.userId == curUserId ? 0 : 1,
            db.curUser.battleSim.favoriteTeams[e.questId]?.contains(e.id) == true ? 0 : 1,
            -e.votes.up + e.votes.down,
            e.id,
          ],
        );
      }
      for (final r in result.data) {
        r.parse();
      }
      queryResult = result;
      this.offset = result.offset;
    }
    if (mounted) setState(() {});
  }

  Future<void> _deleteUserTeam(UserBattleData battleRecord) async {
    if (!secrets.isLoggedIn) return;
    final resp = await showEasyLoading(() => ChaldeaWorkerApi.teamDelete(id: battleRecord.id));
    if (resp == null) return;
    queryResult.data.remove(battleRecord);
    ChaldeaWorkerApi.clearTeamCache();
    resp.showToast();
    if (mounted) setState(() {});
  }

  Widget buildShareDialog(BuildContext context, UserBattleData record) {
    final urls = <String?>[record.toShortUri().toString(), record.toUriV2().toString()].whereType<String>().toList();

    return SimpleDialog(
      title: Text(S.current.share),
      children: [
        for (int index = 0; index < urls.length; index++)
          ListTile(
            dense: true,
            horizontalTitleGap: 8,
            minLeadingWidth: 16,
            contentPadding: const EdgeInsets.symmetric(horizontal: 24),
            leading: Text((index + 1).toString()),
            title: Text(urls[index], maxLines: 2, overflow: TextOverflow.ellipsis),
            onTap: () {
              copyToClipboard(urls[index]);
              EasyLoading.showToast(S.current.copied);
              Navigator.pop(context);
            },
          ),
        ListTile(
          dense: true,
          horizontalTitleGap: 8,
          minLeadingWidth: 16,
          contentPadding: const EdgeInsets.symmetric(horizontal: 24),
          leading: Text(3.toString()),
          title: const Text("Copy Replay Steps", maxLines: 2, overflow: TextOverflow.ellipsis),
          onTap: () {
            db.runtimeData.clipBoard.teamData = record;
            EasyLoading.showToast(S.current.copied);
            Navigator.pop(context);
          },
        ),
      ],
    );
  }
}

class ReportTeamDialog extends StatefulWidget {
  final UserBattleData record;
  final bool isMyTeam;
  const ReportTeamDialog({super.key, required this.record, required this.isMyTeam});

  @override
  State<ReportTeamDialog> createState() => _ReportTeamDialogState();
}

class _ReportTeamDialogState extends State<ReportTeamDialog> {
  late final UserBattleData record = widget.record;
  late final controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return SimpleConfirmDialog(
      scrollable: true,
      title: Text(S.current.about_feedback),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            dense: true,
            title: Text(S.current.team),
            contentPadding: EdgeInsets.zero,
            trailing: Text(
              "No.${record.id}\n@${record.username ?? record.userId}",
              textScaler: const TextScaler.linear(0.8),
              textAlign: TextAlign.end,
            ),
            subtitle: Text(
              [
                record.createdAt.sec2date().toDateString(),
                if ((record.appVer ?? "").isNotEmpty) record.appVer,
              ].join('  '),
            ),
          ),
          const SizedBox(height: 8),
          if (!widget.isMyTeam)
            TextFormField(
              controller: controller,
              decoration: InputDecoration(
                border: const OutlineInputBorder(),
                labelText: S.current.delete_reason,
                floatingLabelBehavior: FloatingLabelBehavior.always,
                hintText: S.current.team_report_reason_hint,
              ),
              style: const TextStyle(fontSize: 14),
              maxLines: 5,
            ),
        ],
      ),
      showOk: false,
      actions: [if (!widget.isMyTeam) TextButton(onPressed: onSend, child: Text(S.current.feedback_send))],
    );
  }

  Future<void> onSend() async {
    final reason = controller.text.trim();
    if (reason.isEmpty) {
      EasyLoading.showInfo(S.current.empty_hint);
      return;
    }

    try {
      String subject = '[Team] ${reason.substring2(0, 20)}';

      final handler = ServerFeedbackHandler(emailTitle: subject, senderName: 'Team Report');

      final buffer = StringBuffer();
      final quest = db.gameData.quests[record.questId];
      buffer.writeAll([
        "Team: https://worker.chaldea.center/api/v4/team/${record.id}?decode=1",
        "Team: https://link.chaldea.center/laplace/share/?id=${record.id}",
        "Quest: https://apps.atlasacademy.io/db/JP/quest/${record.questId}/${record.phase}?hash=${record.enemyHash}",
        "Lv. ${quest?.recommendLv} ${quest?.dispName}",
        "War: ${quest?.war?.longName.setMaxLines(1)}",
        "ID: ${record.id}",
        "Uploader: ${record.username}",
        "Reporter: ${db.settings.secrets.user?.name}",
        "Reason:\n$reason",
      ], '\n');

      final result = await showEasyLoading(() => handler.handle(FeedbackReport(null, buffer.toString()), null));
      if (!result) {
        throw S.current.sending_failed;
      }
      EasyLoading.showSuccess(S.current.sent);
      await Future.delayed(const Duration(milliseconds: 400));
      if (mounted) Navigator.pop(context);
    } catch (e, s) {
      logger.e('send team feedback failed', e, s);
      EasyLoading.showError(escapeDioException(e));
    }
  }
}
