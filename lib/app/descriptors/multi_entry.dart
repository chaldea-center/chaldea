import 'package:flutter/gestures.dart';

import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/models/models.dart';
import 'package:chaldea/utils/utils.dart';
import 'package:chaldea/widgets/widgets.dart';
import '../app.dart';

class MultiDescriptor {
  const MultiDescriptor._();

  static const iconSize = 36.0;

  static List<InlineSpan> list(
    BuildContext context,
    List<int> ids,
    InlineSpan Function(BuildContext context, int id) builder,
    bool? useAnd,
  ) {
    final children = [
      for (final id in ids) builder(context, id),
    ];
    if (useAnd == null) return children;
    return divideList(children, TextSpan(text: useAnd ? ' & ' : ' / '));
  }

  static InlineSpan collapsed(
    BuildContext context,
    List<int> ids,
    String title,
    Widget Function(BuildContext context, int id) builder,
    bool? useAnd,
  ) {
    title = useAnd == false
        ? 'Any of ${ids.length} $title'
        : 'All ${ids.length} $title';
    return inkWell(
      context: context,
      onTap: () {
        router.push(
          child: _MultiEntriesList(
            ids: ids,
            builder: builder,
            title: title,
          ),
          detail: true,
        );
      },
      text: title,
    );
  }

  static TextSpan inkWell({
    required BuildContext context,
    required String text,
    VoidCallback? onTap,
  }) {
    return TextSpan(
      text: ' $text ',
      style: TextStyle(color: Theme.of(context).colorScheme.secondary),
      recognizer:
          onTap == null ? null : (TapGestureRecognizer()..onTap = onTap),
    );
  }

  static List<InlineSpan> items(BuildContext context, List<int> targetIds,
      {bool? useAnd}) {
    if (targetIds.length <= 7) {
      return list(
        context,
        targetIds,
        (context, id) => CenterWidgetSpan(
            child: Item.iconBuilder(
          context: context,
          item: null,
          itemId: id,
          width: iconSize,
          padding: const EdgeInsets.all(2),
        )),
        useAnd,
      );
    }
    return [
      collapsed(
        context,
        targetIds,
        S.current.item,
        (context, id) {
          final item = db.gameData.items[id];
          return ListTile(
            leading: Item.iconBuilder(context: context, item: item),
            title: Text(item?.lName.l ?? 'Item $id'),
            onTap: item == null ? null : () => item.routeTo(),
          );
        },
        useAnd,
      )
    ];
  }

  static List<InlineSpan> servants(BuildContext context, List<int> targetIds,
      {bool? useAnd}) {
    if (targetIds.length <= 7) {
      return list(
        context,
        targetIds,
        (context, id) {
          final svt = db.gameData.servantsById[id] ?? db.gameData.entities[id];
          return svt == null
              ? TextSpan(
                  text: 'SVT $id',
                  recognizer: TapGestureRecognizer()
                    ..onTap = () {
                      router.push(url: Routes.servantI(id));
                    },
                )
              : CenterWidgetSpan(
                  child: svt.iconBuilder(context: context, width: iconSize));
        },
        useAnd,
      );
    }
    return [
      collapsed(
        context,
        targetIds,
        S.current.servant,
        (context, id) {
          final svt = db.gameData.servantsById[id] ?? db.gameData.entities[id];
          return ListTile(
            leading: svt?.iconBuilder(context: context, width: iconSize),
            title: Text(svt?.lName.l ?? 'Servant $id'),
            onTap: () {
              router.push(url: Routes.servantI(id));
            },
          );
        },
        useAnd,
      )
    ];
  }

  static List<InlineSpan> quests(BuildContext context, List<int> targetIds,
      {bool? useAnd}) {
    if (targetIds.length == 1) {
      return list(
        context,
        targetIds,
        (context, id) {
          final quest = db.gameData.quests[id];
          return inkWell(
            context: context,
            onTap: () => router.push(url: Routes.questI(id)),
            text: quest?.lName.l ?? 'Quest $id',
          );
        },
        useAnd,
      );
    }
    return [
      collapsed(
        context,
        targetIds,
        S.current.quest,
        (context, id) {
          final quest = db.gameData.quests[id];
          final phase = db.gameData.getQuestPhase(id);
          final warName =
              Transl.warNames(phase?.warLongName ?? quest?.warLongName ?? "?")
                  .l
                  .replaceAll('\n', ' ');
          final spotName = phase?.lSpot.l ?? quest?.lSpot.l ?? '?';
          return ListTile(
            title: Text(quest?.lName.l ?? 'Quest $id'),
            subtitle:
                Text('$id  $spotName${warName.isEmpty ? "" : "\n$warName"}'),
            onTap: () => router.push(url: Routes.questI(id)),
          );
        },
        useAnd,
      )
    ];
  }

  static List<InlineSpan> traits(BuildContext context, List<int> targetIds,
      {bool? useAnd}) {
    if (targetIds.length <= 10) {
      return list(
        context,
        targetIds,
        (context, id) {
          return inkWell(
            context: context,
            onTap: () => router.push(url: Routes.traitI(id)),
            text: '[${Transl.trait(id).l}]',
          );
        },
        useAnd,
      );
    }
    return [
      collapsed(
        context,
        targetIds,
        S.current.info_trait,
        (context, id) {
          return ListTile(
            title: Text('Trait $id - ${Transl.trait(id).l}'),
            subtitle: Text(id.toString()),
            onTap: () => router.push(url: Routes.traitI(id)),
          );
        },
        useAnd,
      )
    ];
  }

  static List<InlineSpan> svtClass(BuildContext context, List<int> targetIds,
      {bool? useAnd}) {
    return list(
      context,
      targetIds,
      (context, id) {
        return inkWell(
          context: context,
          onTap: null,
          text: '[${Transl.svtClassId(id).l}]',
        );
      },
      useAnd,
    );
  }

  static List<InlineSpan> missions(
    BuildContext context,
    List<int> targetIds,
    Map<int, EventMission> missions, {
    bool? useAnd,
    bool sort = true,
  }) {
    if (targetIds.length == 1) {
      return list(
        context,
        targetIds,
        (context, id) {
          final mission = missions[id];
          return TextSpan(text: '${mission?.dispNo} - ${mission?.name}');
        },
        useAnd,
      );
    } else {
      if (sort) {
        targetIds = targetIds.toList();
        targetIds.sort2((e) => missions[e]?.dispNo ?? e);
      }
      return [
        MultiDescriptor.collapsed(
          context,
          targetIds,
          S.current.mission,
          (context, id) {
            final mission = missions[id];
            return ListTile(
              leading: Text('${mission?.dispNo}'),
              title: Text('${mission?.name}'),
              horizontalTitleGap: 0,
              dense: true,
            );
          },
          useAnd,
        ),
      ];
    }
  }

  static List<InlineSpan> wars(BuildContext context, List<int> targetIds) {
    if (targetIds.length == 1) {
      return list(
        context,
        targetIds,
        (context, id) {
          final war = db.gameData.wars[id];
          return inkWell(
            context: context,
            text: war?.lShortName.setMaxLines(1) ?? id.toString(),
            onTap: () => router.push(url: Routes.warI(id)),
          );
        },
        false,
      );
    } else {
      return [
        MultiDescriptor.collapsed(
          context,
          targetIds,
          S.current.war_title,
          (context, id) {
            final war = db.gameData.wars[id];
            return ListTile(
              title: Text(war?.lLongName.l.setMaxLines(1) ?? 'War $id'),
              horizontalTitleGap: 0,
              dense: true,
              onTap: () => router.push(url: Routes.warI(id)),
            );
          },
          false,
        ),
      ];
    }
  }

  static List<InlineSpan> events(BuildContext context, List<int> targetIds) {
    if (targetIds.length == 1) {
      return list(
        context,
        targetIds,
        (context, id) {
          final event = db.gameData.events[id];
          return inkWell(
            context: context,
            text: event?.lShortName.l.setMaxLines(1) ?? id.toString(),
            onTap: () => router.push(url: Routes.eventI(id)),
          );
        },
        false,
      );
    } else {
      return [
        MultiDescriptor.collapsed(
          context,
          targetIds,
          S.current.event_title,
          (context, id) {
            final event = db.gameData.events[id];
            return ListTile(
              title: Text(event?.lName.l.setMaxLines(1) ?? 'Event $id'),
              horizontalTitleGap: 0,
              dense: true,
              onTap: () => router.push(url: Routes.eventI(id)),
            );
          },
          false,
        ),
      ];
    }
  }

  static List<InlineSpan> shops(BuildContext context, List<int> targetIds,
      {bool? useAnd}) {
    if (targetIds.length < 3) {
      return list(
        context,
        targetIds,
        (context, id) {
          return inkWell(
            context: context,
            onTap: () => router.push(url: Routes.shopI(id)),
            text: '$id',
          );
        },
        useAnd,
      );
    }
    return [
      collapsed(
        context,
        targetIds,
        S.current.event_shop,
        (context, id) {
          return ListTile(
            dense: true,
            title: Text('Shop $id'),
            onTap: () => router.push(url: Routes.shopI(id)),
          );
        },
        useAnd,
      )
    ];
  }
}

class _MultiEntriesList extends StatelessWidget {
  final String? title;
  final List<int> ids;
  final Widget Function(BuildContext context, int id) builder;

  const _MultiEntriesList(
      {this.title, required this.ids, required this.builder});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title ?? 'All ${ids.length}')),
      body: ListView.builder(
        itemBuilder: (context, index) => builder(context, ids[index]),
        itemCount: ids.length,
      ),
    );
  }
}
