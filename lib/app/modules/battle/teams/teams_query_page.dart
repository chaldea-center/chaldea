import 'package:flutter/foundation.dart';

import 'package:flutter_easyloading/flutter_easyloading.dart';

import 'package:chaldea/app/api/chaldea.dart';
import 'package:chaldea/app/app.dart';
import 'package:chaldea/app/modules/battle/formation/formation_card.dart';
import 'package:chaldea/app/modules/home/subpage/login_page.dart';
import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/models/api/api.dart';
import 'package:chaldea/models/models.dart';
import 'package:chaldea/packages/app_info.dart';
import 'package:chaldea/packages/logger.dart';
import 'package:chaldea/utils/catcher/server_feedback_handler.dart';
import 'package:chaldea/utils/utils.dart';
import 'package:chaldea/widgets/widgets.dart';
import '../../common/filter_page_base.dart';
import '../utils.dart';
import 'filter.dart';

enum TeamQueryMode { user, quest, id }

class TeamsQueryPage extends StatefulWidget {
  final TeamQueryMode mode;
  final QuestPhase? questPhase;
  final List<int>? teamIds;
  final bool noEnemyHash;

  const TeamsQueryPage({super.key, required this.mode, this.questPhase, this.teamIds, this.noEnemyHash = false});

  @override
  State<TeamsQueryPage> createState() => _TeamsQueryPageState();
}

class _TeamsQueryPageState extends State<TeamsQueryPage> with SearchableListState<UserBattleData, TeamsQueryPage> {
  static const _pageSize = 200;

  TeamQueryMode get mode => widget.mode;

  bool hasNextPage = false;
  int pageIndex = 0;
  List<UserBattleData> battleRecords = [];
  final filterData = TeamFilterData();

  @override
  Iterable<UserBattleData> get wholeData => battleRecords;

  @override
  void initState() {
    super.initState();
    _queryTeams(pageIndex);
  }

  @override
  Widget build(BuildContext context) {
    filterShownList();
    return scrollListener(useGrid: false, appBar: appBar);
  }

  PreferredSizeWidget? get appBar {
    final username = db.security.username;

    return AppBar(
      title: Text.rich(TextSpan(
        children: [
          if (mode == TeamQueryMode.user)
            TextSpan(
                text: '${S.current.team} @'
                    '${username != null && username.isNotEmpty ? username.breakWord : "Not Login"}'),
          if (mode == TeamQueryMode.quest && widget.questPhase != null)
            TextSpan(text: '${S.current.team} - ${widget.questPhase?.lName.l.breakWord}'),
          if (mode == TeamQueryMode.id) TextSpan(text: S.current.team_shared),
        ],
      )),
      actions: [
        IconButton(
          icon: const Icon(Icons.filter_alt),
          tooltip: S.current.filter,
          onPressed: () {
            Set<int> svtIds = {}, ceIds = {};
            for (final record in battleRecords) {
              final svts = record.decoded?.team.allSvts ?? [];
              svtIds.addAll(svts.map((e) => e?.svtId ?? 0).where((e) => e > 0));
              ceIds.addAll(svts.map((e) => e?.ceId ?? 0).where((e) => e > 0));
            }
            return FilterPage.show(
              context: context,
              builder: (context) => TeamFilter(
                filterData: filterData,
                availableSvts: svtIds,
                availableCEs: ceIds,
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
    List<Widget> buttons;
    if (!db.security.isUserLoggedIn && widget.mode == TeamQueryMode.user) {
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
      buttons = [
        IconButton(
          onPressed: pageIndex == 0
              ? null
              : () async {
                  pageIndex -= 1;
                  await _queryTeams(pageIndex);
                },
          icon: Icon(DirectionalIcons.keyboard_arrow_back(context)),
          color: Theme.of(context).colorScheme.primary,
          tooltip: S.current.prev_page,
        ),
        ElevatedButton(
          onPressed: () async {
            EasyThrottle.throttle('team_query_refresh', const Duration(seconds: 2), () {
              _queryTeams(pageIndex, refresh: true);
            });
          },
          child: Text('${S.current.refresh}(P${pageIndex + 1})'),
        ),
        IconButton(
          onPressed: !hasNextPage
              ? null
              : () async {
                  pageIndex += 1;
                  await _queryTeams(pageIndex);
                },
          icon: Icon(DirectionalIcons.keyboard_arrow_forward(context)),
          color: Theme.of(context).colorScheme.primary,
          tooltip: S.current.next_page,
        ),
      ];
    }

    return PreferredSize(
      preferredSize: const Size.fromHeight(48),
      child: ButtonBar(
        alignment: MainAxisAlignment.center,
        children: [
          Wrap(
            alignment: WrapAlignment.center,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 8,
            runSpacing: 8,
            children: buttons,
          ),
        ],
      ),
    );
  }

  @override
  Widget listItemBuilder(UserBattleData record) {
    final index = battleRecords.indexOf(record);
    final shareData = record.decoded;
    final quest = db.gameData.quests[record.questId];
    final shownIndex = _pageSize * pageIndex + index + 1;
    Widget child = Column(
      children: [
        const SizedBox(height: 6),
        _getHeader(shownIndex, record),
        if (widget.mode == TeamQueryMode.user || widget.mode == TeamQueryMode.id)
          ListTile(
            dense: true,
            leading: db.getIconImage(quest?.spot?.shownImage, width: 24),
            minLeadingWidth: 24,
            title: Text(quest?.lDispName ?? "Quest ${record.questId}/${record.phase}"),
            trailing: Icon(DirectionalIcons.keyboard_arrow_forward(context)),
            onTap: () {
              router.push(url: Routes.questI(record.questId, record.phase));
            },
          ),
        if (shareData != null) FormationCard(formation: shareData.team),
        const SizedBox(height: 8),
        Wrap(
          alignment: WrapAlignment.center,
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 2,
          children: [
            if (widget.mode != TeamQueryMode.user)
              IconButton(
                onPressed: () {
                  setState(() {
                    db.curUser.battleSim.favoriteTeams.putIfAbsent(record.questId, () => {}).toggle(record.id);
                  });
                },
                icon: db.curUser.battleSim.isTeamFavorite(record.questId, record.id)
                    ? const Icon(Icons.star, color: Colors.amber)
                    : const Icon(Icons.star_border, color: Colors.grey),
                tooltip: S.current.favorite,
              ),
            if (mode == TeamQueryMode.user ||
                record.userId == db.security.username ||
                AppInfo.isDebugDevice ||
                kDebugMode)
              FilledButton(
                onPressed: () {
                  final isOthers = record.userId != db.security.username;
                  SimpleCancelOkDialog(
                    title: Text(S.current.confirm),
                    content: Text([
                      '${S.current.delete} No.${record.id}',
                      if (isOthers) "Waring: ${record.userId}'s, not your team",
                    ].join('\n')),
                    onTapOk: () {
                      _deleteUserTeam(record);
                    },
                  ).showDialog(context);
                },
                style: FilledButton.styleFrom(backgroundColor: Theme.of(context).colorScheme.error),
                child: Text(S.current.delete),
              ),
            if (shareData != null)
              FilledButton(
                onPressed: () {
                  replaySimulation(detail: shareData, questInfo: record.questInfo);
                },
                child: Text(S.current.details),
              ),
            if (mode == TeamQueryMode.quest)
              FilledButton(
                onPressed: shareData == null
                    ? null
                    : () {
                        Navigator.pop(context, shareData.team);
                      },
                child: Text(S.current.select),
              ),
            IconButton(
              onPressed: shareData == null
                  ? null
                  : () => showDialog(
                        context: context,
                        useRootNavigator: false,
                        builder: (context) => buildShareDialog(context, record),
                      ),
              icon: const Icon(Icons.ios_share),
              tooltip: S.current.share,
            )
          ],
        ),
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

  Widget _getHeader(int index, UserBattleData record) {
    final style = Theme.of(context).textTheme.bodySmall;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(width: 16),
        Expanded(
          child: Text(
            [
              '${S.current.team} $index - ${record.userId} [${record.id}]',
              if (widget.noEnemyHash) '${S.current.version} ${record.enemyHash.substring2(2)}',
            ].join('\n'),
            style: style,
          ),
        ),
        // InkWell(
        //   onTap: () {},
        //   child: Icon(
        //     Icons.thumb_up_alt,
        //     size: 16,
        //     color: Theme.of(context).unselectedWidgetColor,
        //   ),
        // ),
        // Text('10 '.padRight(4, ' '), style: style),
        // InkWell(
        //   onTap: () {},
        //   child: Icon(
        //     Icons.thumb_down_alt,
        //     size: 16,
        //     color: Theme.of(context).unselectedWidgetColor,
        //   ),
        // ),
        // Text('0 '.padRight(6, ' '), style: style),
        InkWell(
          onTap: () {
            ReportTeamDialog(record: record).showDialog(context);
          },
          child: Icon(
            Icons.report_outlined,
            size: 18,
            color: Theme.of(context).colorScheme.errorContainer.withOpacity(0.8),
          ),
        ),
        const SizedBox(width: 24),
      ],
    );
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
    for (final svtId in filterData.blockSvts.options) {
      if (data.team.allSvts.any((svt) => svt?.svtId == svtId)) {
        return false;
      }
    }
    if (filterData.useSvts.options.isNotEmpty &&
        !filterData.useSvts.options.every((svtId) => data.team.allSvts.any((e) => e?.svtId == svtId))) {
      return false;
    }

    bool _isCEMismatch(SvtSaveData? svt, int ceId) {
      if (svt == null || (svt.svtId ?? 0) <= 0) return false;
      if (svt.ceId != ceId) return false;
      final mlbOnly = filterData.blockCEMLBOnly[ceId] ?? false;
      return mlbOnly ? svt.ceLimitBreak : true;
    }

    for (final ceId in filterData.blockCEs.options) {
      if (data.team.allSvts.any((svt) => _isCEMismatch(svt, ceId))) {
        return false;
      }
    }

    final attackerTdCard = filterData.attackerTdCardType.radioValue;
    if (attackerTdCard != null) {
      final tdCheck = data.actions?.containsTdCardType(attackerTdCard);
      if (tdCheck == false) {
        return false;
      }
    }

    int maxNormalAttackCount = filterData.normalAttackCount.radioValue!;
    int maxCriticalAttackCount = filterData.criticalAttackCount.radioValue!;

    if (maxNormalAttackCount >= 0 || maxCriticalAttackCount >= 0) {
      int normalAttackCount = data.actions?.normalAttackCount ?? 0;
      if (maxNormalAttackCount >= 0 && normalAttackCount > maxNormalAttackCount) {
        return false;
      }

      int criticalAttackCount = data.actions?.critsCount ?? 0;
      if (maxCriticalAttackCount >= 0 && criticalAttackCount > maxCriticalAttackCount) {
        return false;
      }
    }

    for (final miscOption in filterData.miscOptions.options) {
      switch (miscOption) {
        case TeamFilterMiscType.noOrderChange:
          if ([20, 210].contains(data.team.mysticCode.mysticCodeId) && data.actions?.usedMysticCodeSkill(2) == true) {
            return false;
          }
        case TeamFilterMiscType.noSameSvt:
          final svtIds = data.team.allSvts.map((e) => e?.svtId ?? 0).where((e) => e > 0).toList();
          if (svtIds.length != svtIds.toSet().length) {
            return false;
          }
        case TeamFilterMiscType.noAppendSkill:
          for (final svt in data.team.allSvts) {
            final dbSvt = db.gameData.servantsById[svt?.svtId];
            if (svt == null || dbSvt == null) continue;
            if (svt.appendLvs.any((lv) => lv > 0)) {
              return false;
            }
          }
        case TeamFilterMiscType.noGrailFou:
          for (final svt in data.team.allSvts) {
            final dbSvt = db.gameData.servantsById[svt?.svtId];
            if (svt == null || dbSvt == null) continue;
            if (dbSvt.type != SvtType.heroine && svt.lv > dbSvt.lvMax) {
              return false;
            }
            if (svt.hpFou > 1000 || svt.atkFou > 1000) {
              return false;
            }
          }
        case TeamFilterMiscType.noLv100:
          for (final svt in data.team.allSvts) {
            final dbSvt = db.gameData.servantsById[svt?.svtId];
            if (svt == null || dbSvt == null) continue;
            if (svt.lv > 100) {
              return false;
            }
          }
          break;
      }
    }
    return true;
  }

  Future<void> _queryTeams(final int page, {bool refresh = false}) async {
    if (widget.mode == TeamQueryMode.user && !db.security.isUserLoggedIn) return;
    Future<List<UserBattleData>?> task;
    switch (mode) {
      case TeamQueryMode.user:
        task = showEasyLoading(() => ChaldeaWorkerApi.teamsByUser(
              limit: _pageSize + 1,
              offset: _pageSize * page,
              expireAfter: refresh ? Duration.zero : const Duration(minutes: 60),
            ));
      case TeamQueryMode.quest:
        final questPhase = widget.questPhase;
        if (questPhase == null || !questPhase.isLaplaceSharable) return;
        task = showEasyLoading(() => ChaldeaWorkerApi.teamsByQuest(
              questId: questPhase.id,
              phase: questPhase.phase,
              enemyHash: widget.noEnemyHash ? null : questPhase.enemyHash,
              limit: _pageSize + 1,
              offset: _pageSize * page,
              expireAfter: refresh ? Duration.zero : const Duration(minutes: 60),
            ));
      case TeamQueryMode.id:
        task = showEasyLoading(() async {
          final teams = <UserBattleData>[];
          for (final id in widget.teamIds ?? <int>[]) {
            final team = await ChaldeaWorkerApi.laplaceQueryById(id);
            if (team != null) teams.add(team);
          }
          return teams;
        });
    }
    List<UserBattleData>? records = await task;
    if (records != null) {
      hasNextPage = records.length > _pageSize;
      records = hasNextPage ? records.sublist(0, _pageSize) : records;
      records.sortByList((e) => [e.userId == db.security.username ? 0 : 1, e.id]);
      battleRecords.clear();
      battleRecords.addAll(records);
      for (final r in battleRecords) {
        r.parse();
      }
    }
    if (mounted) setState(() {});
  }

  Future<void> _deleteUserTeam(UserBattleData battleRecord) async {
    if (!db.security.isUserLoggedIn) return;
    final resp = await showEasyLoading(() => ChaldeaWorkerApi.teamDelete(id: battleRecord.id));
    if (resp.success) {
      battleRecords.remove(battleRecord);
      ChaldeaWorkerApi.clearCache((cache) => true);
    }
    resp.showToast();
    if (mounted) setState(() {});
  }

  Widget buildShareDialog(BuildContext context, UserBattleData record) {
    final urls = <String?>[
      record.toShortUri().toString(),
      record.toUriV2().toString(),
    ].whereType<String>().toList();

    return SimpleDialog(
      title: Text(S.current.share),
      children: [
        for (int index = 0; index < urls.length; index++)
          ListTile(
            dense: true,
            horizontalTitleGap: 0,
            minLeadingWidth: 32,
            contentPadding: const EdgeInsets.symmetric(horizontal: 24),
            leading: Text((index + 1).toString()),
            title: Text(
              urls[index],
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            onTap: () {
              copyToClipboard(urls[index]);
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
  const ReportTeamDialog({super.key, required this.record});

  @override
  State<ReportTeamDialog> createState() => _ReportTeamDialogState();
}

class _ReportTeamDialogState extends State<ReportTeamDialog> {
  late final UserBattleData record = widget.record;
  late final controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return SimpleCancelOkDialog(
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
              "No.${record.id}\n@${record.userId}",
              textScaleFactor: 0.8,
              textAlign: TextAlign.end,
            ),
          ),
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
      hideOk: true,
      actions: [
        TextButton(
          onPressed: onSend,
          child: Text(S.current.feedback_send),
        ),
      ],
    );
  }

  Future<void> onSend() async {
    final reason = controller.text.trim();
    if (reason.isEmpty) {
      EasyLoading.showInfo(S.current.empty_hint);
      return;
    }

    try {
      EasyLoading.show(maskType: EasyLoadingMaskType.clear);
      String subject = '[Team] ${reason.substring2(0, 20)}';

      final handler = ServerFeedbackHandler(
        emailTitle: subject,
        senderName: 'Team Report',
      );

      final buffer = StringBuffer();
      final quest = db.gameData.quests[record.questId];
      buffer.writeAll([
        "Quest: https://apps.atlasacademy.io/db/JP/quest/${record.questId}/${record.phase}?hash=${record.enemyHash}",
        "Lv. ${quest?.recommendLv} ${quest?.name}",
        "Spot: ${quest?.spotName}",
        "War: ${quest?.war?.longName}",
        "Team: https://chaldea.center/laplace/share?id=${record.id}",
        "Version: ${record.ver}",
        "ID: ${record.id}",
        "Uploader: ${record.userId}",
        // "Stars: x up, y down\n",
        "Reporter: ${db.security.username}",
        "Reason:\n$reason"
      ], '\n');

      final result = await handler.handle(FeedbackReport(null, buffer.toString()), null);
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
