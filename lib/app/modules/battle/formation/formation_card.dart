import 'package:chaldea/app/app.dart';
import 'package:chaldea/app/battle/models/battle.dart';
import 'package:chaldea/models/gamedata/toplogin.dart';
import 'package:chaldea/models/models.dart';
import 'package:chaldea/utils/utils.dart';
import 'package:chaldea/widgets/widgets.dart';
import 'svt_option_editor.dart';

class FormationCard extends StatelessWidget {
  final BattleTeamFormation formation;
  final bool showAllMysticCodeIcon;
  final bool fadeOutMysticCode;
  final Map<int, UserServantCollectionEntity>? userSvtCollections;
  final bool showBond;

  const FormationCard({
    super.key,
    required this.formation,
    this.showAllMysticCodeIcon = false,
    this.fadeOutMysticCode = false,
    this.userSvtCollections,
    this.showBond = false,
  });

  @override
  Widget build(final BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (final onFieldSvt in formation.onFieldSvts) _buildServantIcons(context, onFieldSvt),
        for (final backupSvt in formation.backupSvts) _buildServantIcons(context, backupSvt),
        _buildMysticCode(context),
      ],
    );
  }

  Widget _buildServantIcons(BuildContext context, final SvtSaveData? storedData) {
    String svtInfo = '';
    final svtCollection = userSvtCollections?[storedData?.svtId];
    if (storedData != null) {
      if (storedData.svtId != null && storedData.svtId != 0) {
        svtInfo = [
          if (showBond && svtCollection != null) ' ◈ ${svtCollection.friendshipRank}',
          ' Lv.${storedData.lv} NP${storedData.tdLv} ',
          if (storedData.atkFou != 1000 || storedData.hpFou != 1000) ' ${storedData.atkFou}/${storedData.hpFou}',
          ' ${storedData.skillLvs.join("/")}',
          ' ${storedData.appendLvs.map((e) => e == 0 ? "-" : e).join("/")} ',
        ].join('\n');
      }
    }

    final svt = db.gameData.servantsById[storedData?.svtId];
    final basicSvt = db.gameData.entities[storedData?.svtId];
    Widget svtIcon = GameCardMixin.cardIconBuilder(
      context: context,
      icon: svt?.ascendIcon(storedData!.limitCount) ?? basicSvt?.icon ?? Atlas.common.emptySvtIcon,
      // width: 80,
      aspectRatio: 132 / 144,
      text: svtInfo,
      option: ImageWithTextOption(
        textAlign: TextAlign.left,
        fontSize: 14,
        alignment: Alignment.bottomLeft,
        // padding: const EdgeInsets.fromLTRB(22, 0, 2, 4),
        errorWidget: (context, url, error) => CachedImage(imageUrl: Atlas.common.unknownEnemyIcon),
      ),
      onTap: () async {
        final data = await PlayerSvtData.fromStoredData(storedData);
        if (data.svt == null) return;
        router.pushPage(
          ServantOptionEditPage(
            playerSvtData: data,
            questPhase: null,
            playerRegion: null,
            onChange: null,
            svtFilterData: null,
          ),
        );
      },
    );

    List<Widget> extraInfoIcons = [
      if (storedData?.customPassives.isNotEmpty == true)
        db.getIconImage(AssetURL.i.buffIcon(302), width: 18, aspectRatio: 1),
      if (userSvtCollections?[storedData?.svtId]?.isReachBondLimit == true)
        db.getIconImage(
          'https://static.atlasacademy.io/file/aa-fgo-extract-jp/Battle/Common/CommonUIAtlas/img_bond_category.png',
          width: 16,
          aspectRatio: 1,
        ),
      if (storedData?.supportType.isSupport == true) db.getIconImage(AssetURL.i.items(12), width: 24, aspectRatio: 1),
    ];
    Widget? grandSvtIcon;
    if (storedData != null && storedData.grandSvt && svt != null) {
      final grandClassId = db.gameData.grandGraphDetails[svt.classId]?.grandClassId;
      if (grandClassId != null) {
        grandSvtIcon = db.getIconImage(SvtClassX.clsIcon(grandClassId, 5), width: 24, aspectRatio: 1);
      }
    }
    if (extraInfoIcons.isNotEmpty || grandSvtIcon != null) {
      svtIcon = Stack(
        clipBehavior: Clip.none,
        children: [
          svtIcon,
          if (grandSvtIcon != null) Positioned(top: -1, left: -1, child: grandSvtIcon),
          if (extraInfoIcons.isNotEmpty)
            Positioned.fill(
              top: -5,
              right: -5,
              child: Wrap(
                alignment: WrapAlignment.end,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: extraInfoIcons,
              ),
            ),
        ],
      );
    }

    final bonds =
        svtCollection == null ? null : svt?.getPastNextBonds(svtCollection.friendshipRank, svtCollection.friendship);

    Widget child = Column(
      children: [
        svtIcon,
        _buildCeIcon(context, storedData, SvtEquipTarget.normal),
        if (storedData != null && storedData.grandSvt) ...[
          if ((storedData.equip2?.id ?? 0) != 0) _buildCeIcon(context, storedData, SvtEquipTarget.bond),
          if ((storedData.equip3?.id ?? 0) != 0) _buildCeIcon(context, storedData, SvtEquipTarget.reward),
        ],
        if (showBond && bonds != null)
          BondProgress(value: bonds.$1, total: bonds.$1 + bonds.$2, padding: EdgeInsets.only(top: 1.5), minHeight: 3),
      ],
    );
    child = Container(
      padding: const EdgeInsets.symmetric(horizontal: 1),
      constraints: const BoxConstraints(maxWidth: 80),
      child: child,
    );
    return Flexible(flex: 10, child: child);
  }

  Widget _buildCeIcon(BuildContext context, SvtSaveData? storedData, SvtEquipTarget equipTarget) {
    SvtEquipSaveData? equip = switch (equipTarget) {
      SvtEquipTarget.normal => storedData?.equip1,
      SvtEquipTarget.bond => storedData?.equip2,
      SvtEquipTarget.reward => storedData?.equip3,
    };
    final ce = db.gameData.craftEssencesById[equip?.id];
    final basicCe = db.gameData.entities[equip?.id];

    String ceInfo = "";
    if (equip != null && (equip.id ?? 0) != 0) {
      ceInfo = ' Lv.${equip.lv}';
      if (equip.limitBreak) {
        ceInfo += ' $kStarChar2';
      }
      ceInfo = ceInfo.padRight(11);
    }

    return GameCardMixin.cardIconBuilder(
      context: context,
      icon:
          ce?.extraAssets.equipFace.equip?[equip?.id] ??
          basicCe?.icon?.replaceFirst('/Faces/', '/EquipFaces/') ??
          Atlas.common.emptyCeIcon,
      // width: 80,
      aspectRatio: 150 / 68,
      text: ceInfo,
      option: ImageWithTextOption(
        textAlign: TextAlign.left,
        fontSize: 14,
        alignment: Alignment.bottomLeft,
        // padding: const EdgeInsets.fromLTRB(22, 0, 2, 4),
        errorWidget: (context, url, error) => CachedImage(imageUrl: Atlas.common.emptyCeIcon),
      ),
      onTap: () async {
        final data = await PlayerSvtData.fromStoredData(storedData);
        if (data.getEquip(equipTarget).ce == null) return;
        router.pushPage(
          CraftEssenceOptionEditPage(
            playerSvtData: data,
            equipTarget: equipTarget,
            questPhase: null,
            onChange: null,
            craftFilterData: null,
          ),
        );
      },
    );
  }

  Widget _buildMysticCode(BuildContext context) {
    final enabled = formation.mysticCode.mysticCodeId != null && formation.mysticCode.level > 0;
    final mc = enabled ? db.gameData.mysticCodes[formation.mysticCode.mysticCodeId] : null;
    final Set<String?> mcIcons = {};
    if (showAllMysticCodeIcon) {
      mcIcons.add(mc?.extraAssets.item.male);
      mcIcons.add(mc?.extraAssets.item.female);
    } else {
      mcIcons.add(mc?.icon);
    }

    Widget child = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final icon in mcIcons)
              Flexible(
                child: db.getIconImage(
                  enabled ? icon : null,
                  aspectRatio: 1,
                  width: 56,
                  onTap:
                      enabled
                          ? () => router.push(url: Routes.mysticCodeI(formation.mysticCode.mysticCodeId ?? 0))
                          : null,
                ),
              ),
          ],
        ),
        Text(
          "Lv.${enabled ? formation.mysticCode.level : '-'}",
          style: fadeOutMysticCode ? const TextStyle(decoration: TextDecoration.lineThrough) : null,
          textScaler: const TextScaler.linear(0.9),
        ),
        Text(
          formation.getTotalCost().toString(),
          style: TextStyle(color: Theme.of(context).textTheme.bodySmall?.color),
          textScaler: const TextScaler.linear(0.9),
        ),
      ],
    );
    if (fadeOutMysticCode) {
      child = Opacity(opacity: 0.5, child: child);
    }

    return Flexible(flex: mcIcons.length > 1 ? 12 : 8, child: child);
  }
}

class BondProgress extends StatelessWidget {
  final int value;
  final int total;
  final double? minHeight;
  final EdgeInsetsGeometry? padding;
  const BondProgress({super.key, required this.value, required this.total, this.padding, this.minHeight});

  @override
  Widget build(BuildContext context) {
    final highlight = value == 0 || value == total;
    Widget child = LinearProgressIndicator(
      minHeight: minHeight,
      value: value / total,
      color: highlight ? Colors.green : Colors.blue,
      backgroundColor: highlight ? Colors.amber.shade800 : Colors.red,
    );
    if (padding != null) {
      child = Padding(padding: padding!, child: child);
    }
    return child;
  }
}
