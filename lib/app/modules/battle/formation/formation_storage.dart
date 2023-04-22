import 'package:flutter_easyloading/flutter_easyloading.dart';

import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/models/db.dart';
import 'package:chaldea/models/userdata/battle.dart';
import 'package:chaldea/utils/utils.dart';
import 'package:chaldea/widgets/widgets.dart';

/// DO NOT change any field directly except [name] of [BattleTeamFormation]
class FormationEditor extends StatefulWidget {
  const FormationEditor({super.key});

  @override
  State<FormationEditor> createState() => _FormationEditorState();
}

class _FormationEditorState extends State<FormationEditor> {
  BattleSimSetting get settings => db.settings.battleSim;
  BattleTeamFormation? clipboard;
  bool sorting = false;

  @override
  Widget build(final BuildContext context) {
    settings.validate();
    return Scaffold(
      appBar: AppBar(
        title: Text(S.current.team),
        actions: [
          IconButton(
            onPressed: () {
              setState(() {
                sorting = !sorting;
              });
              if (sorting) EasyLoading.showToast(S.current.drag_to_sort);
            },
            icon: const Icon(Icons.sort),
            color: sorting ? Theme.of(context).colorScheme.primary : null,
            tooltip: S.current.sort_order,
          )
        ],
      ),
      body: buildBody(),
    );
  }

  Widget buildBody() {
    List<Widget> children = [
      for (int index = 0; index < settings.formations.length; index++)
        buildFormation(index, settings.formations[index], settings.curFormationIndex == index),
    ];

    if (sorting) {
      return ReorderableListView(
        children: [
          for (int index = 0; index < children.length; index++)
            AbsorbPointer(key: Key('sort_$index'), child: children[index]),
        ],
        onReorder: (int oldIndex, int newIndex) {
          final prev = settings.curFormation;
          setState(() {
            if (oldIndex < newIndex) {
              newIndex -= 1;
            }
            final item = settings.formations.removeAt(oldIndex);
            settings.formations.insert(newIndex, item);
            settings.curFormationIndex = settings.formations.indexOf(prev);
            settings.validate();
          });
        },
      );
    }

    return ListView(
      children: [
        ...children,
        const Divider(height: 16),
        if (!sorting)
          Center(
            child: FilledButton.tonalIcon(
              onPressed: () {
                settings.formations.add(BattleTeamFormation());
                if (mounted) setState(() {});
              },
              icon: const Icon(Icons.add),
              label: Text(S.current.add),
            ),
          ),
        const SafeArea(child: SizedBox(height: 8))
      ],
    );
  }

  Widget buildFormation(int index, BattleTeamFormation formation, bool selected) {
    String title = formation.shownName(index);
    final titleStyle = Theme.of(context).textTheme.bodySmall;
    Widget child = Column(
      children: [
        DividerWithTitle(
          titleWidget: InkWell(
            onTap: () {
              InputCancelOkDialog(
                title: S.current.team,
                onSubmit: (s) {
                  if (mounted) {
                    setState(() {
                      formation.name = s.isEmpty ? null : s.trim();
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
                    if (index == settings.curFormationIndex)
                      const TextSpan(text: '● ', style: TextStyle(color: Colors.green)),
                    TextSpan(text: title),
                    if (!sorting) ...[
                      const TextSpan(text: ' '),
                      CenterWidgetSpan(
                        child: Icon(
                          Icons.edit,
                          size: 16,
                          color: titleStyle?.color,
                        ),
                      )
                    ],
                  ],
                ),
                style: titleStyle,
              ),
            ),
          ),
          padding: const EdgeInsets.only(top: 8),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: _buildServantRow(formation),
        ),
        const SizedBox(height: 4),
        if (!sorting)
          Wrap(
            alignment: WrapAlignment.center,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              TextButton(
                onPressed: settings.formations.length > 1
                    ? () {
                        SimpleCancelOkDialog(
                          title: Text(S.current.confirm),
                          onTapOk: () {
                            if (mounted) {
                              setState(() {
                                if (settings.formations.length > 1) {
                                  settings.formations.removeAt(index);
                                  if (index <= settings.curFormationIndex) {
                                    settings.curFormationIndex -= 1;
                                  }
                                }
                              });
                            }
                          },
                        ).showDialog(context);
                      }
                    : null,
                child: Text(
                  S.current.remove,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ),
              TextButton(
                onPressed: () {
                  setState(() {
                    clipboard = formation;
                  });
                },
                child: Text(S.current.copy),
              ),
              TextButton(
                onPressed: clipboard == null || clipboard == formation
                    ? null
                    : () {
                        setState(() {
                          settings.formations[index] = BattleTeamFormation.fromJson(clipboard!.toJson());
                          clipboard = null;
                        });
                      },
                child: Text(S.current.paste),
              ),
              FilledButton(
                onPressed: () {
                  settings.curFormationIndex = index;
                  Navigator.pop(context, formation);
                },
                style: FilledButton.styleFrom(
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  visualDensity: VisualDensity.compact,
                ),
                child: Text(S.current.select),
              ),
            ],
          ),
      ],
    );
    if (Theme.of(context).platform.isDesktop && sorting) {
      child = Padding(padding: const EdgeInsetsDirectional.only(end: 24), child: child);
    }
    return child;
  }

  Widget _buildServantRow(final BattleTeamFormation formation) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (final onFieldSvt in formation.onFieldSvts) _buildServantIcons(onFieldSvt),
        for (final backupSvt in formation.backupSvts) _buildServantIcons(backupSvt),
        Flexible(
          child: db.getIconImage(db.gameData.mysticCodes[formation.mysticCode.mysticCodeId]?.icon, aspectRatio: 1),
        ),
      ],
    );
  }

  Widget _buildServantIcons(final SvtSaveData? storedData) {
    Widget child = Column(
      children: [
        db.getIconImage(
          db.gameData.servantsById[storedData?.svtId]?.ascendIcon(storedData!.limitCount, true) ??
              Atlas.common.emptySvtIcon,
          aspectRatio: 132 / 144,
        ),
        db.getIconImage(
          db.gameData.craftEssencesById[storedData?.ceId]?.extraAssets.equipFace.equip?[storedData!.ceId] ??
              Atlas.common.emptyCeIcon,
          aspectRatio: 150 / 68,
        )
      ],
    );
    child = Container(
      padding: const EdgeInsets.symmetric(horizontal: 1),
      constraints: const BoxConstraints(maxWidth: 64),
      child: child,
    );
    return Flexible(child: child);
  }
}
