import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import 'package:chaldea/models/models.dart';
import 'package:chaldea/widgets/widgets.dart';
import '../app.dart';

class MultiDescriptor {
  const MultiDescriptor._();

  static const iconSize = 36.0;

  static List<InlineSpan> list(
    BuildContext context,
    List<int> ids,
    InlineSpan Function(BuildContext context, int id) builder,
  ) {
    return [
      for (final id in ids) builder(context, id),
    ];
  }

  static InlineSpan collapsed(
    BuildContext context,
    List<int> ids,
    String title,
    Widget Function(BuildContext context, int id) builder,
  ) {
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

  static List<InlineSpan> items(BuildContext context, List<int> targetIds) {
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
      );
    }
    return [
      collapsed(context, targetIds, 'All ${targetIds.length} items',
          (context, id) {
        final item = db.gameData.items[id];
        return ListTile(
          leading: Item.iconBuilder(context: context, item: item),
          title: Text(item?.lName.l ?? 'Item $id'),
          onTap: item == null ? null : () => item.routeTo(),
        );
      })
    ];
  }

  static List<InlineSpan> servants(BuildContext context, List<int> targetIds) {
    if (targetIds.length <= 7) {
      return list(
        context,
        targetIds,
        (context, id) {
          final svt = db.gameData.servantsById[id] ?? db.gameData.entities[id];
          return svt == null
              ? TextSpan(text: 'SVT $id')
              : CenterWidgetSpan(
                  child: svt.iconBuilder(context: context, width: iconSize));
        },
      );
    }
    return [
      collapsed(context, targetIds, 'All ${targetIds.length} servants',
          (context, id) {
        final svt = db.gameData.servantsById[id] ?? db.gameData.entities[id];
        return ListTile(
          leading: svt?.iconBuilder(context: context, width: iconSize),
          title: Text(svt?.lName.l ?? 'Servant $id'),
          onTap: svt == null ? null : () => svt.routeTo(),
        );
      })
    ];
  }

  static List<InlineSpan> quests(BuildContext context, List<int> targetIds) {
    if (targetIds.length == 1) {
      return list(
        context,
        targetIds,
        (context, id) {
          final quest = db.gameData.quests[id];
          return inkWell(
            context: context,
            onTap: () => quest?.routeTo(),
            text: quest?.lName.l ?? 'Quest $id',
          );
        },
      );
    }
    return [
      collapsed(context, targetIds, 'All ${targetIds.length} quests',
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
          onTap: quest == null ? null : () => quest.routeTo(),
        );
      })
    ];
  }

  static List<InlineSpan> traits(BuildContext context, List<int> targetIds) {
    if (targetIds.length <= 7) {
      return list(
        context,
        targetIds,
        (context, id) {
          return inkWell(
            context: context,
            onTap: null,
            text: '[${Transl.trait(id).l}]',
          );
        },
      );
    }
    return [
      collapsed(context, targetIds, 'All ${targetIds.length} Traits',
          (context, id) {
        return ListTile(
          title: Text('Trait $id - ${Transl.trait(id)}'),
          subtitle: Text(id.toString()),
          onTap: null,
        );
      })
    ];
  }

  static List<InlineSpan> svtClass(BuildContext context, List<int> targetIds) {
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
    );
  }

  static List<InlineSpan> missions(BuildContext context, List<int> targetIds,
      Map<int, EventMission> missions) {
    if (targetIds.length == 1) {
      return list(context, targetIds, (context, id) {
        final mission = missions[id];
        return TextSpan(text: '${mission?.dispNo} - ${mission?.name}');
      });
    } else {
      return [
        MultiDescriptor.collapsed(
            context, targetIds, 'All ${targetIds.length} missions',
            (context, id) {
          final mission = missions[id];
          return ListTile(title: Text('${mission?.dispNo} - ${mission?.name}'));
        }),
      ];
    }
  }
}

class _MultiEntriesList extends StatelessWidget {
  final String? title;
  final List<int> ids;
  final Widget Function(BuildContext context, int id) builder;

  const _MultiEntriesList(
      {Key? key, this.title, required this.ids, required this.builder})
      : super(key: key);

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
