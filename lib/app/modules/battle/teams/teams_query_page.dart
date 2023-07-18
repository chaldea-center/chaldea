import 'package:flutter_easyloading/flutter_easyloading.dart';

import 'package:chaldea/app/api/chaldea.dart';
import 'package:chaldea/app/app.dart';
import 'package:chaldea/app/modules/battle/formation/formation_card.dart';
import 'package:chaldea/app/modules/home/subpage/login_page.dart';
import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/models/api/api.dart';
import 'package:chaldea/models/models.dart';
import 'package:chaldea/utils/utils.dart';
import 'package:chaldea/widgets/widgets.dart';
import '../../common/filter_page_base.dart';
import '../utils.dart';
import 'filter.dart';

enum TeamQueryMode { user, quest }

class TeamsQueryPage extends StatefulWidget {
  final TeamQueryMode mode;
  final QuestPhase? questPhase;

  const TeamsQueryPage({super.key, required this.mode, this.questPhase});

  @override
  State<TeamsQueryPage> createState() => _TeamsQueryPageState();
}

class _TeamsQueryPageState extends State<TeamsQueryPage> with SearchableListState<UserBattleData, TeamsQueryPage> {
  static const _pageSize = 50;

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
    return scrollListener(
      useGrid: false,
      appBar: appBar,
    );
  }

  PreferredSizeWidget? get appBar {
    Set<int> svtIds = {};
    for (final record in battleRecords) {
      final svts = record.decoded?.team.allSvts ?? [];
      svtIds.addAll(svts.map((e) => e?.svtId ?? 0).where((e) => e > 0));
    }
    if (!svtIds.contains(filterData.useSvts.radioValue)) {
      filterData.useSvts.options.clear();
    }

    final username = db.security.username;

    return AppBar(
      title: Text.rich(TextSpan(
        children: [
          if (mode == TeamQueryMode.user)
            TextSpan(
                text: '${S.current.uploaded_teams} @'
                    '${username != null && username.isNotEmpty ? username.breakWord : "Not Login"}'),
          if (mode == TeamQueryMode.quest && widget.questPhase != null)
            TextSpan(text: '${S.current.team_shared} - ${widget.questPhase?.lName.l.breakWord}')
        ],
      )),
      actions: [
        IconButton(
          icon: const Icon(Icons.filter_alt),
          tooltip: S.current.filter,
          onPressed: () => FilterPage.show(
            context: context,
            builder: (context) => TeamFilter(
              filterData: filterData,
              availableSvts: svtIds,
              onChanged: (_) {
                if (mounted) {
                  setState(() {});
                }
              },
            ),
          ),
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
    return Column(
      children: [
        DividerWithTitle(title: '${S.current.team} $shownIndex - ${record.userId} [${record.id}]'),
        if (widget.mode == TeamQueryMode.user)
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
          spacing: 8,
          children: [
            if (mode == TeamQueryMode.user || record.userId == db.security.username)
              FilledButton(
                onPressed: () {
                  SimpleCancelOkDialog(
                    title: Text(S.current.confirm),
                    content: Text(S.current.delete),
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
    for (final svtCollectionNo in filterData.blockedSvts.options) {
      if (data.team.allSvts.any((svt) => db.gameData.servantsById[svt?.svtId]?.collectionNo == svtCollectionNo)) {
        return false;
      }
    }
    if (filterData.useSvts.options.isNotEmpty &&
        data.team.allSvts.every((svt) => !filterData.useSvts.options.contains(svt?.svtId))) {
      return false;
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

    bool checkCE(SvtSaveData? svt, int ceId, CELimitType limit) {
      if (svt == null || (svt.svtId ?? 0) <= 0) return true;
      if (svt.ceId != ceId) return true;
      return limit.check(svt.ceLimitBreak);
    }

    if (data.team.allSvts.any((svt) =>
        !checkCE(svt, 9400340, filterData.kaleidoCELimit.radioValue!) ||
        !checkCE(svt, 9400480, filterData.blackGrailLimit.radioValue!))) {
      return false;
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
        task = showEasyLoading(() => ChaldeaWorkerApi.laplaceQueryTeamByUser(
              limit: _pageSize + 1,
              offset: _pageSize * page,
              expireAfter: refresh ? Duration.zero : const Duration(minutes: 60),
            ));
      case TeamQueryMode.quest:
        final questPhase = widget.questPhase;
        if (questPhase == null || !questPhase.isLaplaceSharable) return;
        task = showEasyLoading(() => ChaldeaWorkerApi.laplaceQueryTeamByQuest(
              questId: questPhase.id,
              phase: questPhase.phase,
              enemyHash: questPhase.enemyHash,
              limit: _pageSize + 1,
              offset: _pageSize * page,
              expireAfter: refresh ? Duration.zero : const Duration(minutes: 60),
            ));
    }
    List<UserBattleData>? records = await task;
    if (records != null) {
      hasNextPage = records.length > _pageSize;
      records = hasNextPage ? records.sublist(0, _pageSize) : records;
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
    final resp = await showEasyLoading(() => ChaldeaWorkerApi.laplaceDeleteTeam(id: battleRecord.id));
    if (resp.success) {
      ChaldeaWorkerApi.clearCache((cache) => true);
      await _queryTeams(pageIndex, refresh: true);
    } else {
      resp.showToast();
    }
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
