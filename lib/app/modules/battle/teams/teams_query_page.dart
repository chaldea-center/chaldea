import 'package:flutter/scheduler.dart';

import 'package:chaldea/app/api/chaldea.dart';
import 'package:chaldea/app/app.dart';
import 'package:chaldea/app/modules/battle/formation/formation_card.dart';
import 'package:chaldea/app/modules/battle/teams/battle_record_details_page.dart';
import 'package:chaldea/app/modules/home/subpage/login_page.dart';
import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/models/api/api.dart';
import 'package:chaldea/models/models.dart';
import 'package:chaldea/widgets/widgets.dart';

enum TeamQueryMode { user, quest }

class TeamsQueryPage extends StatefulWidget {
  final TeamQueryMode mode;
  final int? questId;
  final int? phase;
  final String? enemyHash;

  const TeamsQueryPage({super.key, required this.mode, this.questId, this.phase, this.enemyHash});

  @override
  State<TeamsQueryPage> createState() => _TeamsQueryPageState();
}

class _TeamsQueryPageState extends State<TeamsQueryPage> {
  static const _pageSize = 20;

  TeamQueryMode get mode => widget.mode;

  bool hasNextPage = false;
  int pageIndex = 0;
  List<BattleRecord> battleRecords = [];

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

  Widget _buildBattleRecord(final BattleRecord battleRecord, final int index) {
    final shareData = BattleShareData.parseGzip(battleRecord.record);

    return Column(
      children: [
        DividerWithTitle(
          title: shareData.team.shownName(index),
        ),
        FormationCard(formation: shareData.team),
        TextButton(
          onPressed: () {
            router.pushPage(BattleRecordDetailPage(battleRecord: battleRecord));
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
      } else if (mode == TeamQueryMode.quest && widget.questId != null) {
        resp = await ChaldeaResponse.request(
          showSuccess: false,
          caller: (dio) => dio.post('/laplace/query/quest', data: {
            'username': db.security.username,
            'auth': db.security.userAuth,
            'questId': widget.questId,
            if (widget.phase != null) 'phase': widget.phase,
            if (widget.enemyHash != null) 'enemyHash': widget.enemyHash,
            'limit': _pageSize + 1,
            'offset': _pageSize * page,
          }),
        );
      }

      final responseMap = resp?.json()?['body'];
      if (responseMap != null) {
        List<BattleRecord> records =
            D1Result<BattleRecord>.fromJson(Map<String, dynamic>.from(responseMap as Map)).results;
        hasNextPage = records.length > _pageSize;

        records = hasNextPage ? records.sublist(0, _pageSize) : records;
        battleRecords.addAll(records);
      }

      if (mounted) setState(() {});
    }
  }

  Future<void> _deleteUserTeam(final BattleRecord battleRecord) async {
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
}
