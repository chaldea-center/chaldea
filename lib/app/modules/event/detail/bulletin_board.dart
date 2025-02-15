import 'package:flutter/services.dart';

import 'package:flutter_easyloading/flutter_easyloading.dart';

import 'package:chaldea/app/descriptors/cond_target_value.dart';
import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/models/models.dart';
import 'package:chaldea/utils/utils.dart';
import 'package:chaldea/widgets/widgets.dart';

class EventBulletinBoardPage extends HookWidget {
  final Event event;
  final VoidCallback? onSwitchRegion;
  const EventBulletinBoardPage({super.key, required this.event, this.onSwitchRegion});

  @override
  Widget build(BuildContext context) {
    final bulletins = event.bulletinBoards.toList();
    bulletins.sort2((e) => e.bulletinBoardId);
    List<Widget> children = [
      if (onSwitchRegion != null) TextButton(onPressed: onSwitchRegion, child: Text(S.current.switch_region)),
      for (final bulletin in bulletins) itemBuilder(context, bulletin),
    ];
    return ListView.separated(
      padding: const EdgeInsets.symmetric(vertical: 8),
      controller: useScrollController(),
      itemBuilder: (context, index) => children[index],
      separatorBuilder:
          (_, index) =>
              onSwitchRegion != null && index == 0 ? const Divider(height: 1) : const Divider(indent: 48, height: 1),
      itemCount: children.length,
    );
  }

  Widget itemBuilder(BuildContext context, EventBulletinBoard bulletin) {
    final scripts = bulletin.script ?? const [];
    Widget title = Text(bulletin.message, textScaler: const TextScaler.linear(0.8));

    List<InlineSpan> spans = [];
    for (final script in scripts) {
      if (script.icon != null) {
        spans.add(CenterWidgetSpan(child: db.getIconImage(script.icon, width: 28, height: 32)));
      }
      if (script.name != null) {
        spans.add(TextSpan(text: ' ${Transl.svtNames(script.name!).l}  '));
      }
    }
    if (spans.isNotEmpty) {
      title = Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [Text.rich(TextSpan(children: spans), style: Theme.of(context).textTheme.bodySmall), title],
      );
    }

    return ListTile(
      key: Key('event_bulletin_${bulletin.bulletinBoardId}'),
      leading: Text(bulletin.bulletinBoardId.toString(), textAlign: TextAlign.center),
      title: title,
      horizontalTitleGap: 4,
      onLongPress: () async {
        await Clipboard.setData(ClipboardData(text: bulletin.message));
        EasyLoading.showInfo(S.current.copied);
      },
      onTap: () {
        showDialog(context: context, useRootNavigator: false, builder: (context) => showConditions(context, bulletin));
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
