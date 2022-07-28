import 'package:flutter/material.dart';

import 'package:chaldea/models/models.dart';
import 'package:chaldea/utils/utils.dart';

class ChaldeaGateTab extends StatefulWidget {
  ChaldeaGateTab({Key? key}) : super(key: key);

  @override
  State<ChaldeaGateTab> createState() => _ChaldeaGateTabState();
}

class _ChaldeaGateTabState extends State<ChaldeaGateTab> {
  @override
  Widget build(BuildContext context) {
    final wars = db.gameData.wars.values
        .where((war) => war.id > 400 && war.eventId == 0)
        .toList();
    wars.sort2((e) => -e.priority);
    return ListView.builder(
      itemBuilder: (context, index) => buildWar(context, wars[index]),
      itemCount: wars.length,
    );
  }

  Widget buildWar(BuildContext context, NiceWar war) {
    return ListTile(
      leading:
          war.banner == null ? null : db.getIconImage(war.banner, width: 150),
      title:
          Text(war.lLongName.l, maxLines: 1, overflow: TextOverflow.ellipsis),
      horizontalTitleGap: 8,
      onTap: () {
        war.routeTo();
      },
    );
  }
}
