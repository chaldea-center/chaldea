import 'package:flutter_easyloading/flutter_easyloading.dart';

import 'package:chaldea/app/api/atlas.dart';
import 'package:chaldea/app/api/chaldea.dart';
import 'package:chaldea/app/app.dart';
import 'package:chaldea/app/battle/models/battle.dart';
import 'package:chaldea/app/modules/battle/battle_simulation.dart';
import 'package:chaldea/app/modules/battle/formation/formation_card.dart';
import 'package:chaldea/app/modules/battle/simulation_preview.dart';
import 'package:chaldea/app/modules/home/subpage/login_page.dart';
import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/models/api/api.dart';
import 'package:chaldea/models/models.dart';
import 'package:chaldea/utils/utils.dart';
import 'package:chaldea/widgets/widgets.dart';
import '../../common/filter_page_base.dart';
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

    return AppBar(
      title: Text.rich(TextSpan(
        text: S.current.uploaded_teams,
        children: [
          TextSpan(
            text: '(Page ${pageIndex + 1})',
            style: const TextStyle(fontSize: 14),
          )
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
    List<Widget> buttons = [
      ElevatedButton(
        onPressed: pageIndex == 0
            ? null
            : () async {
                pageIndex -= 1;
                await _queryTeams(pageIndex);
              },
        child: Text(S.current.prev_page),
      ),
      if (db.security.isUserLoggedIn || widget.mode == TeamQueryMode.quest)
        ElevatedButton(
          onPressed: () async {
            EasyDebounce.debounce('refresh_laplace_team', const Duration(seconds: 1), () {
              _queryTeams(pageIndex, refresh: true);
            });
          },
          child: Text(S.current.refresh),
        )
      else
        ElevatedButton(
          onPressed: () async {
            await router.pushPage(LoginPage());
            if (mounted) setState(() {});
          },
          child: Text(S.current.login_login),
        ),
      ElevatedButton(
        onPressed: !hasNextPage
            ? null
            : () async {
                pageIndex += 1;
                await _queryTeams(pageIndex);
              },
        child: Text(S.current.next_page),
      ),
    ];
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
        DividerWithTitle(title: '${S.current.team} $shownIndex - ${record.userId}'),
        if (widget.mode == TeamQueryMode.user)
          ListTile(
            dense: true,
            leading: db.getIconImage(quest?.spot?.shownImage, width: 24),
            minLeadingWidth: 24,
            title: Text(quest?.lDispName ?? "Quest ${record.questId}/${record.phase}"),
            trailing: Icon(DirectionalIcons.keyboard_arrow_forward(context)),
            onTap: () {
              router.push(url: Routes.questI(record.questId));
            },
          ),
        if (shareData != null) ...[
          FormationCard(formation: shareData.team),
          TextButton(
            onPressed: () {
              replaySimulation(record, shareData);
            },
            child: Text('>>> ${S.current.details} >>>'),
          ),
        ],
        Wrap(
          alignment: WrapAlignment.center,
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
            if (mode == TeamQueryMode.quest)
              FilledButton(
                onPressed: shareData == null
                    ? null
                    : () {
                        Navigator.pop(context, shareData.team);
                      },
                child: Text(S.current.select),
              ),
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

  Future<void> _showError(Future Function() future) async {
    try {
      return await future();
    } catch (e) {
      EasyLoading.showError(e.toString());
    } finally {
      if (mounted) setState(() {});
    }
  }

  Future<void> _queryTeams(final int page, {bool refresh = false}) async {
    if (widget.mode == TeamQueryMode.user && !db.security.isUserLoggedIn) return;
    return _showError(() async {
      Future<ChaldeaResponse>? future;
      if (mode == TeamQueryMode.user) {
        future = ChaldeaApi.laplaceQueryTeamByUser(
          limit: _pageSize + 1,
          offset: _pageSize * page,
          expireAfter: refresh ? Duration.zero : null,
        );
      } else if (mode == TeamQueryMode.quest) {
        final questPhase = widget.questPhase;
        if (questPhase == null || questPhase.id <= 0) return;
        future = ChaldeaApi.laplaceQueryTeamByQuest(
          questId: questPhase.id,
          phase: questPhase.phase,
          enemyHash: questPhase.enemyHash,
          limit: _pageSize + 1,
          offset: _pageSize * page,
          expireAfter: refresh ? Duration.zero : null,
        );
      }
      if (future == null) return;
      final resp = await ChaldeaResponse.show(future);

      final respBody = resp.body<Map>();
      if (respBody == null) return;
      final d1result = D1Result<UserBattleData>.fromJson(Map.from(respBody));

      if (d1result.success) {
        List<UserBattleData> records = d1result.results;
        hasNextPage = records.length > _pageSize;
        records = hasNextPage ? records.sublist(0, _pageSize) : records;
        battleRecords.clear();
        battleRecords.addAll(records);
        for (final r in battleRecords) {
          r.parse();
        }
      } else {
        EasyLoading.showError(d1result.error.toString());
      }
    });
  }

  Future<void> _deleteUserTeam(UserBattleData battleRecord) async {
    if (!db.security.isUserLoggedIn) return;
    return _showError(() async {
      final resp = await ChaldeaResponse.show(ChaldeaApi.laplaceDeleteTeam(id: battleRecord.id));
      if (resp.success) {
        ChaldeaApi.clearCache((cache) => true);
        await _queryTeams(pageIndex, refresh: true);
      }
    });
  }

  void replaySimulation(final UserBattleData battleRecord, final BattleShareData shareData) async {
    QuestPhase? questPhase = widget.questPhase;

    if (questPhase == null) {
      try {
        EasyLoading.show();
        questPhase ??= await AtlasApi.questPhase(
          battleRecord.questId,
          battleRecord.phase,
          hash: battleRecord.enemyHash,
          region: Region.jp,
        );
        EasyLoading.dismiss();
      } catch (ignored) {
        EasyLoading.dismiss();
      }
    }

    if (questPhase == null) {
      await SimpleCancelOkDialog(
        title: Text(S.current.failed),
        content: Text(S.current.not_found),
        scrollable: false,
      ).showDialog(null);
      return;
    }

    final questCopy = QuestPhase.fromJson(questPhase.toJson());

    final options = BattleOptions();
    final formation = shareData.team;
    for (int index = 0; index < 3; index++) {
      options.team.onFieldSvtDataList[index] =
          await PlayerSvtData.fromStoredData(formation.onFieldSvts.getOrNull(index));
      options.team.backupSvtDataList[index] = await PlayerSvtData.fromStoredData(formation.backupSvts.getOrNull(index));
    }

    options.team.mysticCodeData.loadStoredData(formation.mysticCode);

    if (shareData.disableEvent != null) {
      options.disableEvent = shareData.disableEvent!;
    }

    if (options.disableEvent) {
      questCopy.warId = 0;
      questCopy.individuality.removeWhere((e) => e.isEventField);
    }

    if (options.team.isDracoInTeam && shareData.autoAdd7KnightsTrait == true) {
      for (final enemy in questCopy.allEnemies) {
        if (isEnemy7Knights(enemy) && enemy.traits.every((e) => e.signedId != Trait.standardClassServant.id)) {
          enemy.traits = [...enemy.traits, NiceTrait(id: Trait.standardClassServant.id)];
        }
      }
    }

    router.push(
      url: Routes.laplaceBattle,
      child: BattleSimulationPage(
        questPhase: questCopy,
        options: options,
        replayActions: shareData.actions,
      ),
    );
  }
}
