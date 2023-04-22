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

  @override
  Widget build(final BuildContext context) {
    settings.curFormationIndex = settings.curFormationIndex.clamp(0, settings.formations.length - 1);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Formation Selection'),
      ),
      body: ListView(
        children: [
          for (int index = 0; index < settings.formations.length; index++)
            buildFormation(index, settings.formations[index], settings.curFormationIndex == index),
          const Divider(height: 16),
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
        ],
      ),
    );
  }

  Widget buildFormation(int index, BattleTeamFormation formation, bool selected) {
    String title = 'Team ${index + 1}';
    if (formation.name != null) {
      title += ': ${formation.name}';
    }
    final titleStyle = Theme.of(context).textTheme.bodySmall;
    return Column(
      children: [
        DividerWithTitle(
          titleWidget: InkWell(
            onTap: () {
              InputCancelOkDialog(
                title: 'Team Name',
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
                TextSpan(text: title, children: [
                  const TextSpan(text: ' '),
                  CenterWidgetSpan(
                    child: Icon(
                      Icons.edit,
                      size: 16,
                      color: titleStyle?.color,
                    ),
                  )
                ]),
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
