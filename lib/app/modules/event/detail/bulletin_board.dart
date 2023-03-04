import 'package:flutter/services.dart';

import 'package:flutter_easyloading/flutter_easyloading.dart';

import 'package:chaldea/app/descriptors/cond_target_value.dart';
import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/models/models.dart';
import 'package:chaldea/utils/utils.dart';
import 'package:chaldea/widgets/widgets.dart';

class EventBulletinBoardPage extends HookWidget {
  final Event event;
  const EventBulletinBoardPage({super.key, required this.event});

  @override
  Widget build(BuildContext context) {
    final bulletins = event.bulletinBoards.toList();
    bulletins.sort2((e) => e.bulletinBoardId);
    return ListView.separated(
      controller: useScrollController(),
      itemBuilder: (context, index) => itemBuilder(context, bulletins[index]),
      separatorBuilder: (_, __) => const Divider(indent: 48, height: 1),
      itemCount: bulletins.length,
    );
  }

  Widget itemBuilder(BuildContext context, EventBulletinBoard bulletin) {
    return ListTile(
      key: Key('event_bulletin_${bulletin.bulletinBoardId}'),
      leading: Text(bulletin.bulletinBoardId.toString(), textAlign: TextAlign.center),
      title: Text(bulletin.message, textScaleFactor: 0.8),
      horizontalTitleGap: 4,
      onLongPress: () async {
        await Clipboard.setData(ClipboardData(text: bulletin.message));
        EasyLoading.showInfo(S.current.copied);
      },
      onTap: () {
        showDialog(
          context: context,
          useRootNavigator: false,
          builder: (context) => showConditions(context, bulletin),
        );
      },
    );
  }

  Widget showConditions(BuildContext context, EventBulletinBoard bulletin) {
    return SimpleCancelOkDialog(
      hideCancel: true,
      scrollable: true,
      title: Text('No.${bulletin.bulletinBoardId} ${S.current.open_condition}'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final cond in bulletin.releaseConditions)
            CondTargetValueDescriptor(
              condType: cond.condType,
              target: cond.condTargetId,
              value: cond.condNum,
              leading: const TextSpan(text: kULLeading),
            ),
        ],
      ),
    );
  }
}
