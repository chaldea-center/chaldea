import 'package:flutter/scheduler.dart';

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
import 'package:chaldea/utils/extension.dart';
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
  static const _pageSize = 20;

  TeamQueryMode get mode => widget.mode;

  bool hasNextPage = false;
  int pageIndex = 0;
  String? errorMessage;
  List<UserBattleData> battleRecords = [];

  @override
  void initState() {
    super.initState();

    SchedulerBinding.instance.addPostFrameCallback((timeStamp) async {
      await _queryTeams(pageIndex);
    });
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
      children.add(
        Center(
          child: TextButton(
            onPressed: () async {
              await _queryTeams(pageIndex);
            },
            child: Text(S.current.refresh),
          ),
        ),
      );
    } else if (battleRecords.isEmpty) {
      children.add(Center(child: Text(S.current.no_uploaded_teams)));
    } else {
      children.addAll(List.generate(battleRecords.length, (index) => _buildBattleRecord(battleRecords[index], index)));
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(S.current.uploaded_teams),
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

  Widget _buildBattleRecord(final UserBattleData battleRecord, final int index) {
    final shareData = BattleShareData.parseGzip(battleRecord.record);

    return Column(
      children: [
        DividerWithTitle(
          title: shareData.team.shownName(index),
        ),
        FormationCard(formation: shareData.team),
        TextButton(
          onPressed: () {
            replaySimulation(battleRecord, shareData);
          },
          child: Text('>>> ${S.current.details} >>>'),
        ),
        if (mode == TeamQueryMode.user)
          TextButton(
            onPressed: () async {
              await _deleteUserTeam(battleRecord);
            },
            child: Text(
              S.current.remove,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ),
        if (mode == TeamQueryMode.quest)
          TextButton(
            onPressed: () {
              Navigator.pop(context, shareData.team);
            },
            child: Text(S.current.select),
          ),
      ],
    );
  }

  Future<void> _queryTeams(final int page) async {
    battleRecords.clear();

    if (db.security.isUserLoggedIn) {
      ChaldeaResponse? resp;

      if (mode == TeamQueryMode.user) {
        resp = await ChaldeaResponse.request(
          showSuccess: false,
          caller: (dio) => dio.post('/laplace/query/user', data: {
            'username': db.security.username,
            'auth': db.security.userAuth,
            'limit': _pageSize + 1,
            'offset': _pageSize * page,
          }),
        );
      } else if (mode == TeamQueryMode.quest && widget.questPhase != null) {
        final questPhase = widget.questPhase!;
        resp = await ChaldeaResponse.request(
          showSuccess: false,
          caller: (dio) => dio.post('/laplace/query/quest', data: {
            'username': db.security.username,
            'auth': db.security.userAuth,
            'questId': questPhase.id,
            'phase': questPhase.phase,
            if (questPhase.enemyHash != null) 'enemyHash': questPhase.enemyHash,
            'limit': _pageSize + 1,
            'offset': _pageSize * page,
          }),
        );
      }

      final responseMap = resp?.json()?['body'];
      if (responseMap != null) {
        final D1Result<UserBattleData> d1result = D1Result<UserBattleData>.fromJson(Map<String, dynamic>.from(responseMap as Map));

        if (d1result.success) {
          errorMessage = null;
          List<UserBattleData?> records = d1result.results;
          hasNextPage = records.length > _pageSize;

          records = hasNextPage ? records.sublist(0, _pageSize) : records;
          for (final record in records) {
            if (record != null) {
              battleRecords.add(record);
            }
          }
        } else {
          errorMessage = d1result.error;
        }
      }

      if (mounted) setState(() {});
    }
  }

  Future<void> _deleteUserTeam(final UserBattleData battleRecord) async {
    if (db.security.isUserLoggedIn) {
      final resp = await ChaldeaResponse.request(
        caller: (dio) => dio.post('/laplace/delete', data: {
          'username': db.security.username,
          'auth': db.security.userAuth,
          'id': battleRecord.id,
        }),
      );

      if (resp?.success == true) {
        await _queryTeams(pageIndex);
      }
    }
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
