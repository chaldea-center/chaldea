import 'package:chaldea/app/modules/common/filter_group.dart';
import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/models/models.dart';
import 'package:chaldea/utils/utils.dart';
import 'package:chaldea/widgets/widgets.dart';

class TraitServantTab extends StatefulWidget {
  final int id;
  const TraitServantTab(this.id, {super.key});

  @override
  State<TraitServantTab> createState() => _TraitServantTabState();
}

class _TraitServantTabState extends State<TraitServantTab> {
  bool useGrid = false;

  @override
  Widget build(BuildContext context) {
    List<Servant> servants =
        db.gameData.servantsNoDup.values.where((svt) => svt.traitsAll.contains(widget.id)).toList();
    servants.sort2((e) => e.collectionNo);
    BasicServant? entity;
    if (!servants.any((svt) => svt.id == widget.id)) {
      entity = db.gameData.entities[widget.id];
    }
    if (servants.isEmpty && entity == null) return const Center(child: Text('No record'));

    return CustomScrollView(
      slivers: [
        SliverList.list(children: [
          if (servants.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Center(
                child: FilterGroup.display(
                  useGrid: useGrid,
                  onChanged: (v) {
                    if (v != null) useGrid = v;
                    setState(() {});
                  },
                ),
              ),
            ),
          if (entity != null)
            ListTile(
              dense: true,
              leading: entity.iconBuilder(context: context),
              title: Text('No.${entity.id}-${entity.lName.l}'),
              onTap: entity.routeTo,
            )
        ]),
        useGrid
            ? SliverGrid.extent(
                maxCrossAxisExtent: 56,
                childAspectRatio: 132 / 144,
                children: [for (final svt in servants) gridItem(context, svt)],
              )
            : SliverList.builder(
                itemBuilder: (context, index) => listItem(context, servants[index]),
                itemCount: servants.length,
              ),
        if (useGrid)
          SliverList.list(children: const [
            SafeArea(child: SFooter("Highlight: conditional trait")),
          ]),
      ],
    );
  }

  bool isCommonTrait(Servant svt) {
    final comments = _addComment([
      ...svt.traits,
      for (final traitAdd in svt.traitAdd)
        if (traitAdd.idx == 1) ...traitAdd.trait
    ], widget.id, '');
    return comments.isNotEmpty;
  }

  Widget listItem(BuildContext context, Servant svt) {
    List<String> details = [];
    if (!isCommonTrait(svt)) {
      for (final asc in svt.ascensionAdd.individuality.ascension.keys) {
        details.addAll(_addComment(
          svt.ascensionAdd.individuality.ascension[asc]!,
          widget.id,
          '${S.current.ascension_short} $asc',
        ));
      }
      for (final costumeId in svt.ascensionAdd.individuality.costume.keys) {
        final costumeName = svt.profile.costume[costumeId]?.lName.l ?? costumeId.toString();
        details.addAll(_addComment(
          svt.ascensionAdd.individuality.costume[costumeId]!,
          widget.id,
          costumeName,
        ));
      }
      for (final traitAdd in svt.traitAdd) {
        if (traitAdd.idx == 1) continue;
        final event = db.gameData.events[traitAdd.idx ~/ 100];
        String name = traitAdd.idx.toString();
        if (event != null) {
          name += '(${event.lName.l.setMaxLines(1)})';
        }
        details.addAll(_addComment(traitAdd.trait, widget.id, name));
      }
    }

    return ListTile(
      dense: true,
      leading: svt.iconBuilder(context: context),
      title: Text('No.${svt.collectionNo}-${svt.lName.l}'),
      subtitle: details.isEmpty ? null : Text(details.join(' / '), textScaleFactor: 0.9),
      onTap: () => svt.routeTo(),
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

  Widget gridItem(BuildContext context, Servant svt) {
    return Container(
      decoration: BoxDecoration(
        color: isCommonTrait(svt) ? null : Theme.of(context).colorScheme.errorContainer.withOpacity(0.75),
        borderRadius: BorderRadius.circular(4),
      ),
      padding: const EdgeInsets.all(2),
      margin: const EdgeInsets.all(1),
      child: svt.iconBuilder(context: context),
    );
  }
}
