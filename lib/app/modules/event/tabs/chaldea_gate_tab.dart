import 'package:flutter/material.dart';

import 'package:chaldea/models/models.dart';
import 'package:chaldea/utils/utils.dart';

class ChaldeaGateTab extends StatefulWidget {
  ChaldeaGateTab({super.key});

  @override
  State<ChaldeaGateTab> createState() => _ChaldeaGateTabState();
}

class _ChaldeaGateTabState extends State<ChaldeaGateTab> {
  @override
  Widget build(BuildContext context) {
    final wars = db.gameData.wars.values.where((war) {
      if (war.id < 1000 || war.eventId != 0) return false;
      if (war.id >= 11000 && war.id < 20000) {
        return db.gameData.wars.values.any((e) => e.warAdds.any((add) =>
            add.type == WarOverwriteType.parentWar &&
            add.overwriteId == war.id));
      }
      return true;
    }).toList();
    wars.sort2((e) => -e.priority);
    return ListView.builder(
      itemBuilder: (context, index) => buildWar(context, wars[index]),
      itemCount: wars.length,
    );
  }

  Widget buildWar(BuildContext context, NiceWar war) {
    return ListTile(
      leading: war.shownBanner == null
          ? null
          : db.getIconImage(war.shownBanner, width: 150),
      title: Text(
        war.lLongName.l,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        textScaleFactor: 0.9,
      ),
      horizontalTitleGap: 8,
      onTap: () {
        war.routeTo(popDetails: true);
      },
    );
  }
}
