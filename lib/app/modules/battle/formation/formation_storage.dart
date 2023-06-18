import 'package:flutter_easyloading/flutter_easyloading.dart';

import 'package:chaldea/app/modules/battle/formation/formation_card.dart';
import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/models/db.dart';
import 'package:chaldea/models/userdata/battle.dart';
import 'package:chaldea/utils/utils.dart';
import 'package:chaldea/widgets/widgets.dart';

/// DO NOT change any field directly except [name] of [BattleTeamFormation]
class FormationEditor extends StatefulWidget {
  final bool isSaving;
  final ValueChanged<BattleTeamFormation>? onSelected;
  const FormationEditor({super.key, required this.isSaving, this.onSelected});

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
        title: Text('${widget.isSaving ? S.current.save : S.current.select} ${S.current.team}'),
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
      for (int index = 0; index < settings.formations.length; index++) buildFormation(index),
    ];

    if (sorting) {
      return ReorderableListView(
        children: [
          for (int index = 0; index < children.length; index++)
            AbsorbPointer(key: Key('sort_$index'), child: children[index]),
        ],
        onReorder: (int oldIndex, int newIndex) {
          setState(() {
            if (oldIndex < newIndex) {
              newIndex -= 1;
            }
            final item = settings.formations.removeAt(oldIndex);
            settings.formations.insert(newIndex, item);
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

  Widget buildFormation(int index) {
    BattleTeamFormation formation = settings.formations[index];
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
          child: FormationCard(formation: formation),
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
                  if (widget.isSaving) {
                    settings.formations[index] = settings.curFormation.copy();
                    EasyLoading.showSuccess("${S.current.saved}: ${S.current.team} ${index + 1}");
                  } else {
                    settings.curFormation = formation.copy();
                    widget.onSelected?.call(settings.curFormation);
                  }
                  Navigator.pop(context, formation);
                },
                style: FilledButton.styleFrom(
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  visualDensity: VisualDensity.compact,
                ),
                child: Text(widget.isSaving ? S.current.save : S.current.select),
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
}
