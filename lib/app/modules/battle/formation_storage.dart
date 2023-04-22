import 'package:chaldea/models/db.dart';
import 'package:chaldea/models/userdata/battle.dart';
import 'package:chaldea/utils/atlas.dart';
import 'package:chaldea/widgets/widgets.dart';

class FormationEditor extends StatefulWidget {
  final void Function(Formation formation)? onSelected;
  final Formation? currentFormation;

  const FormationEditor({super.key, this.onSelected, this.currentFormation});

  @override
  State<FormationEditor> createState() => _FormationEditorState();
}

class _FormationEditorState extends State<FormationEditor> {
  static const int maxFormations = 10;

  @override
  Widget build(final BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Formation Selection'),
      ),
      body: ListView(
        children: [
          ...List.generate(db.settings.battleSim.formations.length, (index) {
            final formation = db.settings.battleSim.formations[index];
            return Column(
              children: [
                Row(
                  children: [
                    IconButton(
                      onPressed: () {
                        db.settings.battleSim.formations.removeAt(index);
                        if (mounted) setState(() {});
                      },
                      icon: const Icon(Icons.remove_circle_outline),
                      color: Colors.red,
                      tooltip: 'Add Formation',
                    ),
                    IconButton(
                      onPressed: () {
                        Navigator.pop(context);
                        if (widget.onSelected != null) {
                          widget.onSelected!(formation);
                        }
                      },
                      icon: const Icon(Icons.check),
                      tooltip: 'Select Formation',
                    ),
                    Text(formation.name ?? 'Formation + ${index + 1}'),
                  ],
                ),
                _buildServantRow(formation),
              ],
            );
          }),
          if (widget.currentFormation != null && db.settings.battleSim.formations.length < maxFormations)
            IconButton(
              onPressed: () {
                db.settings.battleSim.formations.add(widget.currentFormation!);
                if (mounted) setState(() {});
              },
              icon: const Icon(Icons.add),
              tooltip: 'Add Formation',
            ),
        ],
      ),
    );
  }

  Widget _buildServantRow(final Formation formation) {
    return Row(
      children: [
        for (final onFieldSvt in formation.onFieldSvtDataList) _buildServantIcons(onFieldSvt),
        for (final backupSvt in formation.backupSvtDataList) _buildServantIcons(backupSvt),
        db.gameData.mysticCodes[formation.mysticCodeData.mysticCodeId]
                ?.iconBuilder(context: context, width: 40, jumpToDetail: false) ??
            db.getIconImage(null, width: 40),
      ],
    );
  }

  Widget _buildServantIcons(final StoredSvtData storedData) {
    return Column(
      children: [
        db.getIconImage(
          db.gameData.servantsById[storedData.svtId]?.ascendIcon(storedData.limitCount, true) ??
              Atlas.common.emptySvtIcon,
          width: 40,
          aspectRatio: 132 / 144,
        ),
        db.getIconImage(
          db.gameData.craftEssencesById[storedData.ceId]?.extraAssets.equipFace.equip?[storedData.ceId] ??
              Atlas.common.emptyCeIcon,
          width: 40,
          aspectRatio: 150 / 68,
        )
      ],
    );
  }
}
