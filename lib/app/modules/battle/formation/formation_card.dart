import 'package:chaldea/models/models.dart';
import 'package:chaldea/utils/utils.dart';
import 'package:chaldea/widgets/widgets.dart';

class FormationCard extends StatelessWidget {
  final BattleTeamFormation formation;
  final bool showAllMysticCodeIcon;

  const FormationCard({super.key, required this.formation, this.showAllMysticCodeIcon = false});

  @override
  Widget build(final BuildContext context) {
    final mc = db.gameData.mysticCodes[formation.mysticCode.mysticCodeId];
    final Set<String?> mcIcons = {};
    if (showAllMysticCodeIcon) {
      mcIcons.add(mc?.extraAssets.item.male);
      mcIcons.add(mc?.extraAssets.item.female);
    } else {
      mcIcons.add(mc?.icon);
    }
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (final onFieldSvt in formation.onFieldSvts) _buildServantIcons(context, onFieldSvt),
        for (final backupSvt in formation.backupSvts) _buildServantIcons(context, backupSvt),
        Flexible(
          flex: mcIcons.length > 1 ? 12 : 8,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  for (final icon in mcIcons)
                    Flexible(
                      child: db.getIconImage(
                        formation.mysticCode.level > 0 ? icon : null,
                        aspectRatio: 1,
                        width: 56,
                      ),
                    )
                ],
              ),
              if (formation.mysticCode.level > 0) Text("Lv.${formation.mysticCode.level}", textScaleFactor: 0.9)
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildServantIcons(BuildContext context, final SvtSaveData? storedData) {
    String svtInfo = '', ceInfo = "";
    if (storedData != null) {
      if (storedData.svtId != null && storedData.svtId != 0) {
        svtInfo = [
          ' Lv.${storedData.lv} NP${storedData.tdLv}',
          if (storedData.atkFou != 1000 || storedData.hpFou != 1000) ' ${storedData.atkFou}/${storedData.hpFou}',
          ' ${storedData.skillLvs.join("/")}',
          ' ${storedData.appendLvs.map((e) => e == 0 ? "-" : e).join("/")}',
        ].join('\n');
      }
      if (storedData.ceId != null && storedData.ceId != 0) {
        ceInfo = ' Lv.${storedData.ceLv}';
        if (storedData.ceLimitBreak) {
          ceInfo += ' $kStarChar2';
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
    return Flexible(flex: 10, child: child);
  }
}
