import 'package:auto_size_text/auto_size_text.dart';

import 'package:chaldea/app/app.dart';
import 'package:chaldea/app/battle/models/battle.dart';
import 'package:chaldea/app/modules/craft_essence/craft_list.dart';
import 'package:chaldea/app/modules/servant/servant_list.dart';
import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/models/models.dart';
import 'package:chaldea/packages/platform/platform.dart';
import 'package:chaldea/utils/utils.dart';
import 'package:chaldea/widgets/widgets.dart';
import 'svt_option_editor.dart';

class _DragSvtData {
  final PlayerSvtData svt;

  _DragSvtData(this.svt);
}

class _DragCEData {
  final PlayerSvtData svt;

  _DragCEData(this.svt);
}

class ServantSelector extends StatefulWidget {
  final PlayerSvtData playerSvtData;
  final Region playerRegion;
  final QuestPhase? questPhase;
  final VoidCallback onChanged;
  final DragTargetAccept<PlayerSvtData>? onDragSvt;
  final DragTargetAccept<PlayerSvtData>? onDragCE;
  final bool enableEdit;

  ServantSelector({
    super.key,
    required this.playerSvtData,
    required this.playerRegion,
    required this.questPhase,
    required this.onChanged,
    this.onDragSvt,
    this.onDragCE,
    this.enableEdit = true,
  });

  @override
  State<ServantSelector> createState() => _ServantSelectorState();
}

class _ServantSelectorState extends State<ServantSelector> {
  bool svtHovered = false;
  bool ceHovered = false;

  PlayerSvtData get playerSvtData => widget.playerSvtData;

  Region get playerRegion => widget.playerRegion;

  QuestPhase? get questPhase => widget.questPhase;

  VoidCallback get onChanged => widget.onChanged;

  DragTargetAccept<PlayerSvtData>? get onDragSvt => widget.onDragSvt;

  DragTargetAccept<PlayerSvtData>? get onDragCE => widget.onDragCE;

  bool get enableEdit => widget.enableEdit;

  static SvtFilterData? svtFilterData;
  static CraftFilterData? craftFilterData;

  @override
  Widget build(final BuildContext context) {
    List<Widget> children = [];

    TextStyle notSelectedStyle = TextStyle(color: Theme.of(context).textTheme.bodySmall?.color);

    // svt icon
    String svtInfo = '';
    if (playerSvtData.svt != null) {
      svtInfo = ' Lv.${playerSvtData.lv} NP${playerSvtData.tdLv}\n'
          ' ${playerSvtData.skillLvs.join("/")}\n'
          ' ${playerSvtData.appendLvs.map((e) => e == 0 ? "-" : e).join("/")}';
    }
    Widget svtIcon = GameCardMixin.cardIconBuilder(
      context: context,
      icon: playerSvtData.svt?.ascendIcon(playerSvtData.limitCount) ?? Atlas.common.emptySvtIcon,
      width: 80,
      aspectRatio: 132 / 144,
      text: svtInfo,
      option: ImageWithTextOption(
        textAlign: TextAlign.left,
        fontSize: 10,
        alignment: Alignment.bottomLeft,
        // padding: const EdgeInsets.fromLTRB(22, 0, 2, 4),
        errorWidget: (context, url, error) => CachedImage(imageUrl: Atlas.common.unknownEnemyIcon),
      ),
    );
    if (playerSvtData.supportType != SupportSvtType.none) {
      svtIcon = Stack(
        alignment: Alignment.topRight,
        children: [
          svtIcon,
          Positioned(
            top: -5,
            right: -5,
            child: db.getIconImage(AssetURL.i.items(12), width: 32, aspectRatio: 1),
          ),
        ],
      );
    }

    Widget svtIconFrame = InkWell(
      onHover: (hovered) {
        svtHovered = hovered;
        if (mounted) setState(() {});
      },
      onTap: () async {
        svtFilterData ??= SvtFilterData(useGrid: true);
        await router.pushPage(ServantOptionEditPage(
          playerSvtData: enableEdit ? playerSvtData : playerSvtData.copy(),
          questPhase: questPhase,
          playerRegion: playerRegion,
          onChange: onChanged,
          svtFilterData: svtFilterData,
        ));
        onChanged();
      },
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          svtIcon,
          if (PlatformU.isDesktopOrWeb && svtHovered)
            Positioned(
              top: -8,
              left: 0,
              child: Container(
                decoration: ShapeDecoration(
                  color: Theme.of(context).primaryColor,
                  shape: const CircleBorder(),
                ),
                child: IconButton(
                  onPressed: () {
                    svtFilterData ??= SvtFilterData(useGrid: true);
                    router.pushPage(
                      ServantListPage(
                        planMode: false,
                        onSelected: (selectedSvt) {
                          playerSvtData.onSelectServant(selectedSvt, playerRegion);
                          onChanged();
                        },
                        filterData: svtFilterData,
                        pinged: db.settings.battleSim.pingedSvts.toList(),
                      ),
                      detail: true,
                    );
                  },
                  splashRadius: 20,
                  padding: const EdgeInsets.all(4),
                  constraints: const BoxConstraints(minWidth: 0, minHeight: 0),
                  iconSize: 16,
                  icon: const Icon(Icons.people),
                  color: Colors.white,
                ),
              ),
            ),
          if (PlatformU.isDesktopOrWeb && svtHovered)
            Positioned(
              top: -8,
              right: 0,
              child: Container(
                decoration: ShapeDecoration(
                  color: playerSvtData.svt == null ? Colors.grey : Colors.red,
                  shape: const CircleBorder(),
                ),
                child: IconButton(
                  onPressed: playerSvtData.svt == null
                      ? null
                      : () {
                          playerSvtData.svt = null;
                          onChanged();
                        },
                  splashRadius: 20,
                  padding: const EdgeInsets.all(4),
                  constraints: const BoxConstraints(minWidth: 0, minHeight: 0),
                  iconSize: 16,
                  icon: const Icon(Icons.remove_circle_outline),
                  color: Colors.white,
                ),
              ),
            )
        ],
      ),
    );

    if (enableEdit && onDragSvt != null) {
      final svtDraggable = Draggable<_DragSvtData>(
        feedback: svtIcon,
        data: _DragSvtData(playerSvtData),
        child: svtIconFrame,
      );
      svtIconFrame = DragTarget<_DragSvtData>(
        builder: (context, candidateData, rejectedData) {
          return svtDraggable;
        },
        onAccept: (data) {
          onDragSvt?.call(data.svt);
        },
      );
    }

    children.add(svtIconFrame);

    // svt name+btn
    children.add(SizedBox(
      height: 18,
      child: AutoSizeText(
        playerSvtData.svt?.lBattleName(playerSvtData.limitCount).l ?? S.current.servant,
        maxLines: 1,
        minFontSize: 10,
        textAlign: TextAlign.center,
        textScaleFactor: 0.9,
        style: playerSvtData.svt == null ? notSelectedStyle : null,
      ),
    ));
    children.add(const SizedBox(height: 8));

    // ce icon
    Widget ceIcon = db.getIconImage(
      playerSvtData.ce?.extraAssets.equipFace.equip?[playerSvtData.ce?.id] ?? Atlas.common.emptyCeIcon,
      width: 80,
      aspectRatio: 150 / 68,
    );
    if (playerSvtData.ce != null && playerSvtData.ceLimitBreak) {
      ceIcon = Stack(
        alignment: Alignment.bottomRight,
        children: [
          ceIcon,
          Positioned(
            right: 4,
            bottom: 4,
            child: Container(
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.yellow)),
              padding: const EdgeInsets.all(2),
              child: Icon(Icons.auto_awesome, color: Colors.yellow[900], size: 14),
            ),
          )
        ],
      );
    }

    Widget ceIconFrame = InkWell(
      onHover: (hovered) {
        ceHovered = hovered;
        if (mounted) setState(() {});
      },
      onTap: () async {
        craftFilterData ??= CraftFilterData(useGrid: true);
        await router.pushPage(CraftEssenceOptionEditPage(
          playerSvtData: enableEdit ? playerSvtData : playerSvtData.copy(),
          questPhase: questPhase,
          onChange: onChanged,
          craftFilterData: craftFilterData,
        ));
        onChanged();
      },
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          ceIcon,
          if (PlatformU.isDesktopOrWeb && ceHovered)
            Positioned(
              top: -8,
              left: 0,
              child: Container(
                decoration: ShapeDecoration(
                  color: Theme.of(context).primaryColor,
                  shape: const CircleBorder(),
                ),
                child: IconButton(
                  onPressed: () {
                    craftFilterData ??= CraftFilterData(useGrid: true);
                    router.pushPage(
                      CraftListPage(
                        onSelected: (ce) {
                          playerSvtData.onSelectCE(ce);
                          onChanged();
                        },
                        filterData: craftFilterData,
                        pinged: db.settings.battleSim.pingedCEsWithEventAndBond(questPhase, playerSvtData.svt).toList(),
                      ),
                      detail: true,
                    );
                  },
                  splashRadius: 16,
                  padding: const EdgeInsets.all(4),
                  constraints: const BoxConstraints(minWidth: 0, minHeight: 0),
                  iconSize: 12,
                  icon: const Icon(Icons.people),
                  color: Colors.white,
                ),
              ),
            ),
          if (PlatformU.isDesktopOrWeb && ceHovered)
            Positioned(
              top: -8,
              right: 0,
              child: Container(
                decoration: ShapeDecoration(
                  color: playerSvtData.ce == null ? Colors.grey : Colors.red,
                  shape: const CircleBorder(),
                ),
                child: IconButton(
                  onPressed: playerSvtData.ce == null
                      ? null
                      : () {
                          playerSvtData.ce = null;
                          onChanged();
                        },
                  splashRadius: 16,
                  padding: const EdgeInsets.all(4),
                  constraints: const BoxConstraints(minWidth: 0, minHeight: 0),
                  iconSize: 12,
                  icon: const Icon(Icons.remove_circle_outline),
                  color: Colors.white,
                ),
              ),
            ),
        ],
      ),
    );
    if (enableEdit && onDragCE != null) {
      final ceDraggable = Draggable<_DragCEData>(
        feedback: ceIcon,
        data: _DragCEData(playerSvtData),
        child: ceIconFrame,
      );
      ceIconFrame = DragTarget<_DragCEData>(
        builder: (context, candidateData, rejectedData) {
          return ceDraggable;
        },
        onAccept: (data) {
          onDragCE?.call(data.svt);
        },
      );
    }

    children.add(Center(child: ceIconFrame));

    // ce btn
    String ceInfo = '';
    if (playerSvtData.ce != null) {
      ceInfo = 'Lv.${playerSvtData.ceLv}';
      if (playerSvtData.ceLimitBreak) {
        ceInfo += ' ${S.current.max_limit_break}';
      }
    } else {
      ceInfo = 'Lv.-';
    }
    children.add(SizedBox(
      height: 18,
      child: AutoSizeText(
        ceInfo.breakWord,
        maxLines: 1,
        minFontSize: 10,
        textAlign: TextAlign.center,
        textScaleFactor: 0.9,
        style: playerSvtData.ce == null ? notSelectedStyle : null,
      ),
    ));

    return Padding(
      padding: const EdgeInsets.all(4),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: children,
      ),
    );
  }
}
