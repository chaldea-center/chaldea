import 'package:chaldea/app/api/chaldea.dart';
import 'package:chaldea/app/app.dart';
import 'package:chaldea/app/modules/battle/formation/formation_card.dart';
import 'package:chaldea/app/modules/home/subpage/login_page.dart';
import 'package:chaldea/app/modules/quest/quest_card.dart';
import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/models/api/api.dart';
import 'package:chaldea/models/models.dart';
import 'package:chaldea/widgets/widgets.dart';
import 'package:flutter/scheduler.dart';

class UserTeamsManagePage extends StatefulWidget {
  const UserTeamsManagePage({super.key});

  @override
  State<UserTeamsManagePage> createState() => _UserTeamsManagePageState();
}

class _UserTeamsManagePageState extends State<UserTeamsManagePage> {
  static const _pageSize = 20;

  bool hasNextPage = false;
  int curPage = 0;
  List<BattleRecord> battleRecords = [];

  @override
  void initState() {
    super.initState();

    SchedulerBinding.instance.addPostFrameCallback((timeStamp) async {
      await _queryUserTeams(curPage);
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
              await _queryUserTeams(curPage);
            },
            child: Text('Click here to login.'),
          ),
        ),
      );
    } else if (battleRecords.isEmpty) {
      children.add(Center(child: Text('No uploaded teams.')));
    } else {
      children.addAll(List.generate(battleRecords.length, (index) => _buildBattleRecord(battleRecords[index], index)));
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Manage Uploaded Teams'),
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
            onPressed: curPage == 0
                ? null
                : () async {
                    curPage -= 1;
                    await _queryUserTeams(curPage);
                  },
            child: Text('Previous Page'),
          ),
          ElevatedButton(
            onPressed: !hasNextPage
                ? null
                : () async {
                    curPage += 1;
                    await _queryUserTeams(curPage);
                  },
            child: Text('Next Page'),
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
            router.push(
              url: '${Routes.quest}/${battleRecord.questId}/${battleRecord.phase}',
              child: Scaffold(
                appBar: AppBar(title: Text(S.current.quest),),
                body: QuestCard(
                  quest: null,
                  questId: battleRecord.questId,
                  offline: false,
                  displayPhases: [battleRecord.phase],
                  battleOnly: true,
                ),
              ),
              detail: true,
            );
          },
          child: Text('>>> ${S.current.quest_detail_btn} >>>'),
        ),
        TextButton(
          onPressed: () async {
            await _deleteUserTeam(battleRecord);
          },
          child: Text(
            S.current.remove,
            style: TextStyle(color: Theme.of(context).colorScheme.error),
          ),
        )
      ],
    );
  }

  Future<void> _queryUserTeams(final int page) async {
    battleRecords.clear();

    if (db.security.isUserLoggedIn) {
      final resp = await ChaldeaResponse.request(
        showSuccess: false,
        caller: (dio) => dio.post('/laplace/query/user', data: {
          'username': db.security.username,
          'auth': db.security.userAuth,
          'limit': _pageSize + 1,
          'offset': _pageSize * page,
        }),
      );

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
        await _queryUserTeams(curPage);
      }
    }
  }
}
