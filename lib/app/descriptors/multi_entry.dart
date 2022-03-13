import 'package:chaldea/models/models.dart';
import 'package:chaldea/utils/utils.dart';
import 'package:flutter/material.dart';

import '../app.dart';

class MultiDescriptor {
  const MultiDescriptor._();

  static const iconSize = 36.0;

  static List<Widget> list(
    BuildContext context,
    List<int> ids,
    Widget Function(BuildContext context, int id) builder,
  ) {
    return [
      for (final id in ids) builder(context, id),
    ];
  }

  static Widget collapsed(
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

  static Widget inkWell({
    required BuildContext context,
    required String text,
    VoidCallback? onTap,
  }) {
    final color = Theme.of(context).colorScheme.secondary;
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
        child: Text(text, style: TextStyle(color: color)),
      ),
    );
  }

  static List<Widget> items(BuildContext context, List<int> targetIds) {
    if (targetIds.length <= 7) {
      return list(
        context,
        targetIds,
        (context, id) => Item.iconBuilder(
          context: context,
          item: null,
          itemId: id,
          width: iconSize,
          padding: const EdgeInsets.all(2),
        ),
      );
    }
    return [
      collapsed(context, targetIds, 'All ${targetIds.length} items',
          (context, id) {
        final item = db2.gameData.items[id];
        return ListTile(
          leading: Item.iconBuilder(context: context, item: item),
          title: Text(item?.lName.l ?? 'Item $id'),
          onTap: item == null ? null : () => item.routeTo(),
        );
      })
    ];
  }

  static List<Widget> servants(BuildContext context, List<int> targetIds) {
    if (targetIds.length <= 7) {
      return list(
        context,
        targetIds,
        (context, id) {
          final svt =
              db2.gameData.servantsById[id] ?? db2.gameData.entities[id];
          return svt?.iconBuilder(context: context, width: iconSize) ??
              Text('SVT $id');
        },
      );
    }
    return [
      collapsed(context, targetIds, 'All ${targetIds.length} servants',
          (context, id) {
        final svt = db2.gameData.servantsById[id] ?? db2.gameData.entities[id];
        return ListTile(
          leading: svt?.iconBuilder(context: context, width: iconSize),
          title: Text(svt?.lName.l ?? 'Servant $id'),
          onTap: svt == null ? null : () => svt.routeTo(),
        );
      })
    ];
  }

  static String classLimits(List<int> targetIds) {
    List<int> clsIds = [];
    List<int> limits = [];
    for (final id in targetIds) {
      clsIds.add(id ~/ 100);
      limits.add(id % 100);
    }
    if (limits.toSet().length == 1) {
      if (clsIds.toSet().equalTo(kSvtIdsPlayable.toSet())) {
        return ' servants to ascension ${limits.first}';
      }
      return '${clsIds.map((e) => kSvtClassIds[e]?.name ?? e).join(',')} to ascension ${limits.first}';
    }
    return List.generate(
            clsIds.length,
            (i) =>
                'Ascension ${limits[i]} ${kSvtClassIds[clsIds[i]]?.name ?? clsIds[i]}')
        .join();
  }

  static List<Widget> quests(BuildContext context, List<int> targetIds) {
    if (targetIds.length == 1) {
      return list(
        context,
        targetIds,
        (context, id) {
          final quest = db2.gameData.quests[id];
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
        final quest = db2.gameData.quests[id];
        final phase = db2.gameData.getQuestPhase(id);
        final warName =
            Transl.warNames(phase?.warLongName ?? quest?.warLongName ?? "?")
                .l
                .replaceAll('\n', ' ');
        final spotName = phase?.lSpot.l ?? quest?.lSpot.l ?? '?';
        return ListTile(
          title: Text(quest?.lName.l ?? 'Quest $id'),
          subtitle:
              Text('$id  $spotName' + (warName.isEmpty ? "" : "\n$warName")),
          onTap: quest == null ? null : () => quest.routeTo(),
        );
      })
    ];
  }

  static List<Widget> traits(BuildContext context, List<int> targetIds) {
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
