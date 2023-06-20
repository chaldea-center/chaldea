import 'package:auto_size_text/auto_size_text.dart';
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

enum TeamQueryMode { user, quest }

class TeamsQueryPage extends StatefulWidget {
  final TeamQueryMode mode;
  final QuestPhase? questPhase;

  const TeamsQueryPage({super.key, required this.mode, this.questPhase});

  @override
  State<TeamsQueryPage> createState() => _TeamsQueryPageState();
}

class _TeamsQueryPageState extends State<TeamsQueryPage> {
  static const _pageSize = 50;

  TeamQueryMode get mode => widget.mode;

  bool hasNextPage = false;
  int pageIndex = 0;
  String? errorMessage;
  List<UserBattleData> battleRecords = [];

  @override
  void initState() {
    super.initState();
    _queryTeams(pageIndex);
  }

  @override
  Widget build(final BuildContext context) {
    final List<Widget> children = [];

    if (!db.security.isUserLoggedIn) {
      children.add(
        Center(
          child: TextButton(
            onPressed: () async {
              await router.pushPage(LoginPage());
              await _queryTeams(pageIndex);
            },
            child: Text(S.current.login_first_hint),
          ),
        ),
      );
    } else if (errorMessage != null) {
      children.add(Center(child: Text('${S.current.error}: $errorMessage')));
    } else if (battleRecords.isEmpty) {
      children.add(Center(child: Text(S.current.no_uploaded_teams)));
    } else {
      children.addAll(List.generate(battleRecords.length, (index) => _buildBattleRecord(battleRecords[index], index)));
    }

    return Scaffold(
      appBar: AppBar(
        title: AutoSizeText(
          '${S.current.uploaded_teams} (Page ${pageIndex + 1})',
          maxLines: 1,
          minFontSize: 10,
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              children: children,
            ),
          ),
          const Divider(height: 16),
          SafeArea(child: _buttonBar)
        ],
      ),
    );
  }

  Widget get _buttonBar {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: Wrap(
        alignment: WrapAlignment.center,
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: 6,
        runSpacing: 6,
        children: [
          ElevatedButton(
            onPressed: pageIndex == 0
                ? null
                : () async {
                    pageIndex -= 1;
                    await _queryTeams(pageIndex);
                  },
            child: Text(S.current.prev_page),
          ),
          ElevatedButton(
            onPressed: () async {
              EasyDebounce.debounce('refresh_laplace_team', const Duration(seconds: 10), () {
                _queryTeams(pageIndex, refresh: true);
              });
            },
            child: Text(S.current.refresh),
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
        ],
      ),
    );
  }

  Widget _buildBattleRecord(final UserBattleData record, final int index) {
    final shareData = BattleShareData.parseGzip(record.record);
    final quest = db.gameData.quests[record.questId];
    return Column(
      children: [
        DividerWithTitle(
          title: shareData.team.shownName(index),
        ),
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
        FormationCard(formation: shareData.team),
        TextButton(
          onPressed: () {
            replaySimulation(record, shareData);
          },
          child: Text('>>> ${S.current.details} >>>'),
        ),
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
                onPressed: () {
                  Navigator.pop(context, shareData.team);
                },
                child: Text(S.current.select),
              ),
          ],
        ),
      ],
    );
  }

  Future<void> _showError(Future Function() future) async {
    try {
      return await future();
    } catch (e) {
      EasyLoading.showError(e.toString());
      errorMessage = e.toString();
    } finally {
      if (mounted) setState(() {});
    }
  }

  Future<void> _queryTeams(final int page, {bool refresh = false}) async {
    if (!db.security.isUserLoggedIn) return;
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
        errorMessage = null;
        List<UserBattleData> records = d1result.results;
        hasNextPage = records.length > _pageSize;
        records = hasNextPage ? records.sublist(0, _pageSize) : records;
        battleRecords.clear();
        battleRecords.addAll(records);
      } else {
        errorMessage = d1result.error;
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
