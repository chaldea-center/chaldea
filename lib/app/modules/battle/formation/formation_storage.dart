import 'package:flutter_easyloading/flutter_easyloading.dart';

import 'package:chaldea/app/app.dart';
import 'package:chaldea/app/modules/battle/formation/formation_card.dart';
import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/models/db.dart';
import 'package:chaldea/models/userdata/battle.dart';
import 'package:chaldea/utils/utils.dart';
import 'package:chaldea/widgets/widgets.dart';
import '../../common/filter_page_base.dart';
import '../teams/filter.dart';
import '../utils.dart';

/// DO NOT change any field directly except [name] of [BattleTeamFormation]
class FormationEditor extends StatefulWidget {
  final BattleShareData? teamToSave;
  final ValueChanged<BattleShareData>? onSelected;
  const FormationEditor({super.key, this.teamToSave, this.onSelected});

  @override
  State<FormationEditor> createState() => _FormationEditorState();
}

class _FormationEditorState extends State<FormationEditor>
    with SearchableListState<(int, BattleShareData), FormationEditor> {
  BattleSimSetting get settings => db.settings.battleSim;
  BattleSimUserData get userData => db.curUser.battleSim;

  bool sorting = false;
  final filterData = TeamFilterData(false);

  @override
  Iterable<(int, BattleShareData)> get wholeData => userData.teams.indexed;

  @override
  bool filter((int, BattleShareData) record) {
    return filterData.filter(record.$2);
  }

  @override
  String get scrollRestorationId => 'formation_storage';

  @override
  Widget build(final BuildContext context) {
    settings.validate();
    userData.validate();
    if (sorting) {
      shownList
        ..clear()
        ..addAll(wholeData);
    } else {
      filterShownList();
    }
    return scrollListener(
      useGrid: false,
      appBar: AppBar(
        title: Text('${S.current.team_local} (${db.curUser.name})'),
        actions: [
          IconButton(
            onPressed: () {
              setState(() {
                sorting = !sorting;
              });
              if (sorting) EasyLoading.showToast(S.current.drag_to_sort);
            },
            icon: Icon(sorting ? Icons.done : Icons.sort),
            tooltip: S.current.sort_order,
          ),
          IconButton(
            icon: const Icon(Icons.filter_alt),
            tooltip: S.current.filter,
            onPressed: () {
              Set<int> svtIds = {}, ceIds = {}, mcIds = {}, eventWarIds = {};
              for (final record in userData.teams) {
                final eventWarId = db.gameData.quests[record.quest?.id]?.eventIdPriorWarId;
                if (eventWarId != null) eventWarIds.add(eventWarId);
                final svts = record.formation.allSvts;
                svtIds.addAll(svts.map((e) => e?.svtId ?? 0).where((e) => e > 0));
                ceIds.addAll(svts.map((e) => e?.ceId ?? 0).where((e) => e > 0));
                if (record.hasUsedMCSkills()) {
                  mcIds.add(record.formation.mysticCode.mysticCodeId ?? 0);
                }
              }

              return FilterPage.show(
                context: context,
                builder:
                    (context) => TeamFilterPage(
                      filterData: filterData,
                      availableSvts: svtIds,
                      availableCEs: ceIds,
                      availableMCs: mcIds,
                      availableEventWarIds: eventWarIds,
                      onChanged: (_) {
                        if (mounted) {
                          setState(() {});
                        }
                      },
                    ),
              );
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget buildListView({Widget? topHint, Widget? bottomHint, Widget? separator}) {
    if (sorting) {
      return ReorderableListView(
        children: [
          for (final (index, team) in wholeData)
            AbsorbPointer(key: Key('sort_$index'), child: listItemBuilder((index, team))),
        ],
        onReorder: (int oldIndex, int newIndex) {
          setState(() {
            if (oldIndex < newIndex) {
              newIndex -= 1;
            }
            final item = userData.teams.removeAt(oldIndex);
            userData.teams.insert(newIndex, item);
            userData.validate();
          });
        },
      );
    }
    return super.buildListView(topHint: topHint, bottomHint: bottomHint, separator: separator);
  }

  @override
  Widget listItemBuilder((int, BattleShareData) record) {
    final (index, team) = record;
    final formation = team.formation;
    String title = formation.shownName(index);
    final titleStyle = Theme.of(context).textTheme.bodySmall;
    final titleWidget = DividerWithTitle(
      titleWidget: InkWell(
        onTap: () {
          InputCancelOkDialog(
            title: S.current.team,
            onSubmit: (s) {
              if (mounted) {
                setState(() {
                  s = s.trim();
                  formation.name = s.isEmpty ? null : s;
                });
              }
            },
          ).showDialog(context);
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: Text.rich(
            TextSpan(
              children: [
                TextSpan(text: title),
                if (!sorting) ...[
                  const TextSpan(text: ' '),
                  CenterWidgetSpan(child: Icon(Icons.edit, size: 16, color: titleStyle?.color)),
                ],
              ],
            ),
            style: titleStyle,
          ),
        ),
      ),
    );
    Widget child = Column(
      children: [
        titleWidget,
        if (team.quest != null) buildQuest(team.quest!),
        Padding(padding: const EdgeInsets.symmetric(horizontal: 8), child: FormationCard(formation: formation)),
        if (!sorting) buildActions(index, team),
      ],
    );
    if (Theme.of(context).platform.isDesktop && sorting) {
      child = Padding(padding: const EdgeInsetsDirectional.only(end: 24), child: child);
    }
    return child;
  }

  @override
  Widget gridItemBuilder((int, BattleShareData) record) {
    throw UnimplementedError('GridView not supported');
  }

  Widget buildQuest(BattleQuestInfo questInfo) {
    final quest = db.gameData.quests[questInfo.id];
    List<InlineSpan> questName = [];
    if (quest == null) {
      questName.add(TextSpan(text: "Quest ${questInfo.id}/${questInfo.phase}"));
    } else {
      questName.add(TextSpan(text: quest.lDispName));
      final eventName = quest.event?.shownName ?? quest.war?.lShortName;
      if (eventName != null) {
        questName.add(
          TextSpan(
            text: '\n${eventName.setMaxLines(1)}',
            style: TextStyle(fontSize: 12, color: Theme.of(context).textTheme.bodySmall?.color),
          ),
        );
      }
    }
    return ListTile(
      dense: true,
      leading: db.getIconImage(quest?.spot?.shownImage, width: 24),
      minLeadingWidth: 24,
      title: Text.rich(TextSpan(children: questName)),
      trailing: Icon(DirectionalIcons.keyboard_arrow_forward(context)),
      onTap: () {
        router.push(url: Routes.questI(questInfo.id, questInfo.phase));
      },
    );
  }

  Widget buildActions(int index, BattleShareData team) {
    final formation = team.formation;
    List<Widget> children = [
      TextButton(
        onPressed:
            userData.teams.length > 1
                ? () {
                  SimpleConfirmDialog(
                    title: Text(S.current.delete),
                    content: Text('${S.current.team} ${index + 1}'),
                    onTapOk: () {
                      if (mounted) {
                        setState(() {
                          if (userData.teams.length > 1) {
                            userData.teams.remove(team);
                          }
                        });
                      }
                    },
                  ).showDialog(context);
                }
                : null,
        child: Text(S.current.delete, style: TextStyle(color: Theme.of(context).colorScheme.error)),
      ),
      if (widget.teamToSave != null)
        TextButton(
          onPressed: () {
            SimpleConfirmDialog(
              title: Text(S.current.override_),
              content: Text('${S.current.team} ${index + 1}'),
              onTapOk: () {
                setState(() {
                  userData.teams[index] = widget.teamToSave!.copy();
                });
                EasyLoading.showSuccess('${S.current.team} ${index + 1}');
              },
            ).showDialog(context);
          },
          child: Text(S.current.override_),
        ),
      TextButton(
        onPressed:
            team.quest != null && team.actions.isNotEmpty
                ? () {
                  replaySimulation(detail: team);
                }
                : null,
        child: Text(S.current.details),
      ),
      const SizedBox(width: 8),
      if (widget.onSelected != null)
        FilledButton(
          onPressed: () {
            widget.onSelected?.call(team);
            Navigator.pop(context, formation);
          },
          style: FilledButton.styleFrom(
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            visualDensity: VisualDensity.compact,
          ),
          child: Text(S.current.select),
        ),
      IconButton(
        onPressed: () async {
          final shareUri = team.toUriV2().toString();
          await copyToClipboard(shareUri);
          EasyLoading.showSuccess('${shareUri.substring2(0, 200)}...');
        },
        icon: const Icon(Icons.ios_share),
        tooltip: S.current.share,
      ),
    ];

    return Wrap(alignment: WrapAlignment.center, crossAxisAlignment: WrapCrossAlignment.center, children: children);
  }

  @override
  PreferredSizeWidget? get buttonBar {
    if (sorting || widget.teamToSave == null) return null;
    return PreferredSize(
      preferredSize: const Size.fromHeight(48),
      child: OverflowBar(
        alignment: MainAxisAlignment.center,
        children: [
          FilledButton.tonalIcon(
            onPressed:
                widget.teamToSave == null
                    ? null
                    : () {
                      userData.teams.add(widget.teamToSave!.copy());
                      EasyLoading.showSuccess('${S.current.saved}: ${S.current.team} ${userData.teams.length}');
                      setState(() {});
                    },
            icon: const Icon(Icons.person_add),
            label: Text(S.current.save_current_team),
          ),
        ],
      ),
    );
  }
}
