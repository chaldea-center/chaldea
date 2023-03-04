import 'package:flutter/gestures.dart';

import 'package:chaldea/app/app.dart';
import 'package:chaldea/app/descriptors/cond_target_value.dart';
import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/models/models.dart';
import 'package:chaldea/utils/utils.dart';
import 'package:chaldea/widgets/widgets.dart';

class EventFortificationPage extends HookWidget {
  final Event event;
  const EventFortificationPage({super.key, required this.event});

  @override
  Widget build(BuildContext context) {
    final controller = useScrollController();
    List<Widget> children = [];
    children.add(const SHeader('Summary'));
    void _withColor(Widget child) {
      children.add(Material(
        color: Theme.of(context).cardColor,
        child: child,
      ));
    }

    for (final type in EventWorkType.values) {
      if (type == EventWorkType.unknown) continue;
      final fortifications = event.fortifications.where((e) => e.workType == type);
      int spotCount = fortifications.length;
      int positionCount = Maths.sum(fortifications.map((e) => e.details.length));
      // int totalPoints =
      //     Maths.sum(fortifications.map((e) => e.maxFortificationPoint));
      _withColor(ListTile(
        dense: true,
        horizontalTitleGap: 8,
        leading: db.getIconImage(type.icon, width: 28),
        title: Text(Transl.enums(type, (enums) => enums.eventWorkType).l),
        subtitle: Text('$spotCount Spots, $positionCount Positions'),
      ));
    }
    if (event.id == 80400) {
      children.add(SHeader(S.current.background));
      for (final bgId in [1, 2, 3]) {
        final bgStr = bgId.toString().padLeft(2, '0');
        _withColor(ListTile(
          dense: true,
          title: Text('${S.current.background} $bgId'),
          trailing: const Icon(Icons.photo),
          onTap: () {
            FullscreenImageViewer.show(
                context: context,
                urls: ['https://static.atlasacademy.io/JP/EventUI/Prefabs/80400/event_bg_80400$bgStr.png']);
          },
        ));
      }
    }
    children.add(const SHeader('Details'));
    for (final fortification in event.fortifications) {
      _withColor(itemBuilder(context, fortification));
    }
    return ListView.separated(
      controller: controller,
      itemBuilder: (context, index) => children[index],
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemCount: children.length,
    );
  }

  Widget itemBuilder(BuildContext context, EventFortification fortification) {
    return SimpleAccordion(
      headerBuilder: (context, _) {
        final point = fortification.maxFortificationPoint.format(compact: false, groupSeparator: ",");
        return ListTile(
          contentPadding: const EdgeInsetsDirectional.only(start: 16),
          horizontalTitleGap: 8,
          leading: db.getIconImage(fortification.workType.icon, width: 32),
          title: Text('${fortification.idx}. ${fortification.name}', textScaleFactor: 0.9),
          subtitle: Wrap(
            spacing: 2,
            runSpacing: 2,
            alignment: WrapAlignment.start,
            children: [
              Text(
                '${fortification.details.length} Positions, Max Point: $point',
                textScaleFactor: 0.9,
              ),
            ],
          ),
          trailing: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 180),
            child: Wrap(
              spacing: 2,
              runSpacing: 2,
              alignment: WrapAlignment.start,
              children: [
                for (final gift in fortification.gifts)
                  gift.iconBuilder(
                    context: context,
                    width: 32,
                    showOne: false,
                  )
              ],
            ),
          ),
        );
      },
      contentBuilder: (context) {
        const headerPadding = EdgeInsetsDirectional.only(start: 0.0, top: 8.0, bottom: 4.0);
        List<Widget> children = [
          Text('${S.current.general_type}: ${fortification.workType.shownName}'),
          const SHeader('Positions', padding: headerPadding),
        ];
        final details = fortification.details.toList();
        details.sort2((e) => e.position);
        List<Widget> posChildren = [];
        for (int index = 0; index < details.length; index++) {
          final detail = details[index];
          List<InlineSpan> spans = [];
          spans.add(TextSpan(
            text: detail.name,
            style: TextStyle(color: Theme.of(context).colorScheme.primary),
            recognizer: TapGestureRecognizer()
              ..onTap = () {
                showDialog(
                  context: context,
                  useRootNavigator: false,
                  builder: (context) {
                    return SimpleCancelOkDialog(
                      hideCancel: true,
                      scrollable: true,
                      title: Text('${detail.position} - ${detail.name}', textScaleFactor: 0.9),
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ListTile(
                            dense: true,
                            contentPadding: EdgeInsets.zero,
                            title: Text(S.current.svt_class),
                            trailing: Text(detail.className.name.toTitle()),
                          ),
                          if (detail.releaseConditions.isNotEmpty)
                            SHeader(
                              S.current.open_condition,
                              padding: headerPadding,
                            ),
                          for (final release in detail.releaseConditions)
                            CondTargetValueDescriptor.commonRelease(
                              commonRelease: release,
                              textScaleFactor: 0.85,
                              leading: const TextSpan(text: kULLeading),
                            ),
                        ],
                      ),
                    );
                  },
                );
              },
          ));
          for (final svt in fortification.servants) {
            if (svt.position != detail.position) continue;
            final dbSvt = db.gameData.servantsById[svt.svtId] ?? db.gameData.entities[svt.svtId];
            String? icon = dbSvt?.borderedIcon;
            spans.add(CenterWidgetSpan(
              child: GameCardMixin.cardIconBuilder(
                context: context,
                icon: icon,
                width: 32,
                aspectRatio: 132 / 144,
                text: svt.type == EventFortificationSvtType.npc ? 'Lv.${svt.lv}' : null,
                onTap: () {
                  showDialog(
                    context: context,
                    useRootNavigator: false,
                    builder: (context) {
                      return SimpleCancelOkDialog(
                        hideCancel: true,
                        scrollable: true,
                        title: Text('${svt.position} - ${svt.type.name}', textScaleFactor: 0.9),
                        content: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ListTile(
                              horizontalTitleGap: 8,
                              leading: db.getIconImage(icon),
                              contentPadding: EdgeInsets.zero,
                              title: Text(dbSvt?.lName.l ?? 'SVT ${svt.svtId}'),
                              subtitle: Text([
                                'No.${svt.svtId}',
                                svt.type == EventFortificationSvtType.userSvt ? 'Lv.-' : 'Lv.${svt.lv}'
                              ].join(' ')),
                              trailing: Icon(DirectionalIcons.keyboard_arrow_forward(context)),
                              onTap: () {
                                router.push(url: Routes.servantI(svt.svtId));
                              },
                            ),
                            if (svt.releaseConditions.isNotEmpty)
                              SHeader(
                                S.current.open_condition,
                                padding: headerPadding,
                              ),
                            for (final release in svt.releaseConditions)
                              CondTargetValueDescriptor.commonRelease(
                                commonRelease: release,
                                textScaleFactor: 0.85,
                                leading: const TextSpan(text: kULLeading),
                              ),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            ));
          }
          posChildren.add(Text.rich(TextSpan(children: spans)));
          if (index != details.length - 1) {
            posChildren.add(const Text('/'));
          }
        }
        children.add(Wrap(
          spacing: 2,
          runSpacing: 2,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: posChildren,
        ));

        if (fortification.releaseConditions.isNotEmpty) {
          children.add(SHeader(S.current.open_condition, padding: headerPadding));
          for (final release in fortification.releaseConditions) {
            children.add(CondTargetValueDescriptor.commonRelease(
              commonRelease: release,
              leading: const TextSpan(text: kULLeading),
              textScaleFactor: 0.9,
            ));
          }
        }
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: children,
          ),
        );
      },
    );
  }
}
