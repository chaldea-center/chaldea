import 'package:flutter/material.dart';

import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/models/models.dart';
import 'package:chaldea/utils/utils.dart';

class TraitServantTab extends StatelessWidget {
  final int id;
  const TraitServantTab(this.id, {super.key});

  @override
  Widget build(BuildContext context) {
    List<Servant> servants = db.gameData.servantsNoDup.values
        .where((svt) => svt.traitsAll.contains(id))
        .toList();
    servants.sort2((e) => e.collectionNo);
    if (servants.isEmpty) return const Center(child: Text('No record'));
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemBuilder: (context, index) {
        final svt = servants[index];
        List<String> details = [];
        bool isCommon = _addComment([
          ...svt.traits,
          for (final traitAdd in svt.traitAdd)
            if (traitAdd.idx == 1) ...traitAdd.trait
        ], id, '')
            .isNotEmpty;
        if (!isCommon) {
          for (final asc in svt.ascensionAdd.individuality.ascension.keys) {
            details.addAll(_addComment(
              svt.ascensionAdd.individuality.ascension[asc]!,
              id,
              '${S.current.ascension_short} $asc',
            ));
          }
          for (final costumeId in svt.ascensionAdd.individuality.costume.keys) {
            final costumeName =
                svt.profile.costume[costumeId]?.lName.l ?? costumeId.toString();
            details.addAll(_addComment(
              svt.ascensionAdd.individuality.costume[costumeId]!,
              id,
              costumeName,
            ));
          }
          for (final traitAdd in svt.traitAdd) {
            if (traitAdd.idx == 1) continue;
            final event = db.gameData.events[traitAdd.idx ~/ 100];
            String name = traitAdd.idx.toString();
            if (event != null) {
              name += '(${event.lName.l})';
            }
            details.addAll(_addComment(traitAdd.trait, id, name));
          }
        }

        return ListTile(
          dense: true,
          leading: svt.iconBuilder(context: context),
          title: Text('No.${svt.collectionNo}-${svt.lName.l}'),
          subtitle: details.isEmpty
              ? null
              : Text(details.join(' / '), textScaleFactor: 0.9),
          onTap: () => svt.routeTo(),
        );
      },
      itemCount: servants.length,
    );
  }

  List<String> _addComment(List<NiceTrait> traits, int id, String comment) {
    List<String> comments = [];
    traits = traits.where((e) => e.id == id).toList();
    if (traits.isEmpty) return [];
    if (traits.any((e) => e.negative)) {
      comments.add('$comment(NOT)');
    }
    if (traits.any((e) => !e.negative)) {
      comments.add(comment);
    }
    return comments;
  }
}
