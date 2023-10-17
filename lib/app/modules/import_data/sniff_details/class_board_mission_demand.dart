import 'package:flutter/material.dart';

import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/models/gamedata/toplogin.dart';
import 'package:chaldea/models/models.dart';
import 'package:chaldea/utils/utils.dart';

class ClassBoardMissionDemand extends StatefulWidget {
  final List<UserSvtCollection> userSvtCollection;
  const ClassBoardMissionDemand({super.key, required this.userSvtCollection});

  @override
  State<ClassBoardMissionDemand> createState() => _ClassBoardMissionDemandState();
}

class _ClassBoardMissionDemandState extends State<ClassBoardMissionDemand> {
  Map<int, List<UserSvtCollection>> groups = {};
  Map<int, int> clsIdToBoardId = {};

  @override
  void initState() {
    super.initState();
    for (final board in db.gameData.classBoards.values) {
      for (final cls in board.classes) {
        clsIdToBoardId[cls.classId] = board.id;
      }
    }
    for (final userSvt in widget.userSvtCollection) {
      if (!userSvt.isOwned) continue;
      final svt = db.gameData.servantsById[userSvt.svtId];
      if (svt == null) continue;
      final boardId = clsIdToBoardId[svt.classId];
      if (boardId == null) continue;
      groups.putIfAbsent(boardId, () => []).add(userSvt);
    }
  }

  @override
  Widget build(BuildContext context) {
    final boards = db.gameData.classBoards.values.toList();
    boards.sort2((e) => e.id);
    return Scaffold(
      appBar: AppBar(
        title: Text(S.current.class_score),
      ),
      body: ListView.separated(
        itemBuilder: (context, index) => buildOne(context, boards[index]),
        separatorBuilder: (_, __) => const Divider(),
        itemCount: boards.length,
      ),
    );
  }

  Widget buildOne(BuildContext context, ClassBoard board) {
    int bond = 0, skillLv = 0, svtLv = 0, svtLimit = 0;
    final servants = groups[board.id] ?? [];
    for (final svt in servants) {
      bond += svt.friendshipRank;
      skillLv += svt.skillLv1 + svt.skillLv2 + svt.skillLv3 - 3;
      svtLv += svt.maxLv - 1;
      svtLimit += svt.maxLimitCount;
    }
    return ListTile(
      dense: true,
      leading: db.getIconImage(board.btnIcon),
      title: Text('${S.current.bond} $bond  ${S.current.skill} $skillLv'
          '  ${S.current.level} $svtLv  ${S.current.ascension} $svtLimit'),
      subtitle: Text('${board.dispName} ×${servants.length}'),
      onTap: board.routeTo,
    );
  }
}
