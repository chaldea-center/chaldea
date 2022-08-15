import 'package:flutter/material.dart';

import 'package:chaldea/models/models.dart';
import 'package:chaldea/utils/utils.dart';
import 'package:chaldea/widgets/widgets.dart';

class EventBulletinBoardPage extends StatelessWidget with PrimaryScrollMixin {
  final Event event;
  const EventBulletinBoardPage({Key? key, required this.event})
      : super(key: key);

  @override
  Widget buildContent(BuildContext context) {
    final bulletins = event.bulletinBoards.toList();
    bulletins.sort2((e) => e.bulletinBoardId);
    return db.onUserData(
      (context, snapshot) => ListView.separated(
        itemBuilder: (context, index) => itemBuilder(context, bulletins[index]),
        separatorBuilder: (_, __) => const Divider(indent: 48, height: 1),
        itemCount: bulletins.length,
      ),
    );
  }

  Widget itemBuilder(BuildContext context, EventBulletinBoard bulletin) {
    return ListTile(
      key: Key('event_bulletin_${bulletin.bulletinBoardId}'),
      leading: Text(bulletin.bulletinBoardId.toString(),
          textAlign: TextAlign.center),
      title: Text(bulletin.message, textScaleFactor: 0.8),
      horizontalTitleGap: 4,
    );
  }
}
