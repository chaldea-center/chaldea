import 'package:chaldea/models/models.dart';
import 'package:chaldea/utils/atlas.dart';
import 'package:chaldea/widgets/widgets.dart';

class FormationCard extends StatelessWidget {
  final BattleTeamFormation formation;

  const FormationCard({super.key, required this.formation});

  @override
  Widget build(final BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (final onFieldSvt in formation.onFieldSvts) _buildServantIcons(onFieldSvt),
        for (final backupSvt in formation.backupSvts) _buildServantIcons(backupSvt),
        Flexible(
          child: db.getIconImage(
            db.gameData.mysticCodes[formation.mysticCode.mysticCodeId]?.icon,
            aspectRatio: 1,
            width: 56,
          ),
        ),
      ],
    );
  }

  Widget _buildServantIcons(final SvtSaveData? storedData) {
    Widget child = Column(
      children: [
        db.getIconImage(
          db.gameData.servantsById[storedData?.svtId]?.ascendIcon(storedData!.limitCount) ?? Atlas.common.emptySvtIcon,
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
