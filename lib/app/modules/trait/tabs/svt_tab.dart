import 'package:chaldea/app/modules/common/filter_group.dart';
import 'package:chaldea/app/modules/common/filter_page_base.dart';
import 'package:chaldea/app/modules/servant/filter.dart';
import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/models/models.dart';
import 'package:chaldea/utils/utils.dart';
import 'package:chaldea/widgets/widgets.dart';

class TraitServantTab extends StatefulWidget {
  final List<int> ids;
  const TraitServantTab(this.ids, {super.key});

  @override
  State<TraitServantTab> createState() => _TraitServantTabState();
}

class _TraitServantTabState extends State<TraitServantTab> {
  bool useGrid = false;
  late final _id = widget.ids.firstOrNull ?? 0;
  final svtFilter = SvtFilterData();

  @override
  Widget build(BuildContext context) {
    List<Servant> servants =
        db.gameData.servantsNoDup.values.where((svt) => svt.traitsAll.containSubset(widget.ids.toSet())).toList();
    servants.sort2((e) => e.collectionNo);
    BasicServant? entity;
    if (widget.ids.length == 1 && !servants.any((svt) => svt.id == _id)) {
      entity = db.gameData.entities[_id];
    }
    if (servants.isEmpty && entity == null) return const Center(child: Text('No record'));
    final shownServants = servants.where((e) => ServantFilterPage.filter(svtFilter, e)).toList();
    return CustomScrollView(
      slivers: [
        SliverList.list(children: [
          if (servants.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  FilterGroup.display(
                    useGrid: useGrid,
                    onChanged: (v) {
                      if (v != null) useGrid = v;
                      setState(() {});
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.filter_alt),
                    tooltip: '${S.current.filter} (${S.current.servant})',
                    onPressed: () => FilterPage.show(
                      context: context,
                      builder: (context) => ServantFilterPage(
                        filterData: svtFilter,
                        onChanged: (_) {
                          if (mounted) {
                            setState(() {});
                          }
                        },
                        planMode: false,
                      ),
                    ),
                  ),
                ],
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
                children: [for (final svt in shownServants) gridItem(context, svt)],
              )
            : SliverList.builder(
                itemBuilder: (context, index) => listItem(context, shownServants[index]),
                itemCount: shownServants.length,
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
        if (traitAdd.eventId == 0 && traitAdd.limitCount == -1) ...traitAdd.trait
    ], _id, '');
    return comments.isNotEmpty;
  }

  Widget listItem(BuildContext context, Servant svt) {
    List<String> details = [];
    if (widget.ids.length == 1 && !isCommonTrait(svt)) {
      for (final asc in svt.ascensionAdd.individuality.ascension.keys) {
        details.addAll(_addComment(
          svt.ascensionAdd.individuality.ascension[asc]!,
          _id,
          '${S.current.ascension_short} $asc',
        ));
      }
      for (final costumeId in svt.ascensionAdd.individuality.costume.keys) {
        final costumeName = svt.profile.costume[costumeId]?.lName.l ?? costumeId.toString();
        details.addAll(_addComment(
          svt.ascensionAdd.individuality.costume[costumeId]!,
          _id,
          costumeName,
        ));
      }
      for (final traitAdd in svt.traitAdd) {
        if (traitAdd.isAlwaysValid) continue;
        final event = db.gameData.events[traitAdd.eventId];
        String name = traitAdd.idx.toString();
        if (event != null) {
          name += '(${event.lName.l.setMaxLines(1)})';
        }
        if (traitAdd.limitCount != -1) {
          name += '(${S.current.ascension_stage_short} ${traitAdd.limitCount})';
        }
        details.addAll(_addComment(traitAdd.trait, _id, name));
      }
    }

    return ListTile(
      dense: true,
      leading: svt.iconBuilder(context: context),
      title: Text('No.${svt.collectionNo}-${svt.lName.l}'),
      trailing: svt.status.cur.favorite ? Text('NP${svt.status.cur.npLv}', style: const TextStyle(fontSize: 12)) : null,
      subtitle: details.isEmpty ? null : Text(details.join(' / '), textScaler: const TextScaler.linear(0.9)),
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
        color: isCommonTrait(svt) ? null : Theme.of(context).colorScheme.errorContainer.withAlpha(191),
        borderRadius: BorderRadius.circular(4),
      ),
      padding: const EdgeInsets.all(2),
      margin: const EdgeInsets.all(1),
      child: svt.iconBuilder(
        context: context,
        text: svt.status.cur.favorite ? 'NP${svt.status.cur.npLv}' : null,
        option: ImageWithTextOption(
          fontSize: 10,
          padding: const EdgeInsets.fromLTRB(0, 0, 2, 12),
        ),
      ),
    );
  }
}
