import 'package:chaldea/models/models.dart';
import 'package:chaldea/utils/utils.dart';
import 'package:chaldea/widgets/widgets.dart';

class FormationCard extends StatelessWidget {
  final BattleTeamFormation formation;

  const FormationCard({super.key, required this.formation});

  @override
  Widget build(final BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (final onFieldSvt in formation.onFieldSvts) _buildServantIcons(context, onFieldSvt),
        for (final backupSvt in formation.backupSvts) _buildServantIcons(context, backupSvt),
        Flexible(
          child: db.getIconImage(
            formation.mysticCode.level > 0 ? db.gameData.mysticCodes[formation.mysticCode.mysticCodeId]?.icon : null,
            aspectRatio: 1,
            width: 56,
          ),
        ),
      ],
    );
  }

  Widget _buildServantIcons(BuildContext context, final SvtSaveData? storedData) {
    String svtInfo = '', ceInfo = "";
    if (storedData != null) {
      if (storedData.svtId != null && storedData.svtId != 0) {
        svtInfo = ' Lv.${storedData.lv} NP${storedData.tdLv}\n'
            ' ${storedData.skillLvs.join("/")}\n'
            ' ${storedData.appendLvs.map((e) => e == 0 ? "-" : e).join("/")}';
      }
      if (storedData.ceId != null && storedData.ceId != 0) {
        ceInfo = ' Lv.${storedData.ceLv}';
        if (storedData.ceLimitBreak) {
          ceInfo += ' $kStarChar';
        }
      }
    }

    Widget child = Column(
      children: [
        GameCardMixin.cardIconBuilder(
          context: context,
          icon: db.gameData.servantsById[storedData?.svtId]?.ascendIcon(storedData!.limitCount) ??
              Atlas.common.emptySvtIcon,
          // width: 80,
          aspectRatio: 132 / 144,
          text: svtInfo,
          option: ImageWithTextOption(
            textAlign: TextAlign.left,
            fontSize: 8,
            alignment: Alignment.bottomLeft,
            // padding: const EdgeInsets.fromLTRB(22, 0, 2, 4),
            errorWidget: (context, url, error) => CachedImage(imageUrl: Atlas.common.unknownEnemyIcon),
          ),
        ),
        GameCardMixin.cardIconBuilder(
          context: context,
          icon: db.gameData.craftEssencesById[storedData?.ceId]?.extraAssets.equipFace.equip?[storedData!.ceId] ??
              Atlas.common.emptyCeIcon,
          // width: 80,
          aspectRatio: 150 / 68,
          text: ceInfo,
          option: ImageWithTextOption(
            textAlign: TextAlign.left,
            fontSize: 8,
            alignment: Alignment.bottomLeft,
            // padding: const EdgeInsets.fromLTRB(22, 0, 2, 4),
            errorWidget: (context, url, error) => CachedImage(imageUrl: Atlas.common.emptyCeIcon),
          ),
        ),
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
