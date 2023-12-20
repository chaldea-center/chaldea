import 'package:auto_size_text/auto_size_text.dart';

import 'package:chaldea/app/app.dart';
import 'package:chaldea/app/battle/models/battle.dart';
import 'package:chaldea/app/modules/craft_essence/craft_list.dart';
import 'package:chaldea/app/modules/servant/servant_list.dart';
import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/models/models.dart';
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

class ServantSelector extends StatelessWidget {
  final PlayerSvtData playerSvtData;
  final Region? playerRegion;
  final QuestPhase? questPhase;
  final VoidCallback onChanged;
  final DragTargetAccept<PlayerSvtData>? onDragSvt;
  final DragTargetAccept<PlayerSvtData>? onDragCE;
  final bool enableEdit;
  final ValueNotifier<String?> hovered;

  ServantSelector({
    super.key,
    required this.playerSvtData,
    this.playerRegion,
    required this.questPhase,
    required this.onChanged,
    this.onDragSvt,
    this.onDragCE,
    this.enableEdit = true,
    required this.hovered,
  });

  SvtFilterData get svtFilterData => db.settings.svtFilterData;
  CraftFilterData get craftFilterData => db.settings.craftFilterData;

  @override
  Widget build(final BuildContext context) {
    List<Widget> children = [];

    TextStyle notSelectedStyle = TextStyle(color: Theme.of(context).textTheme.bodySmall?.color);

    // svt icon
    String svtInfo = '';
    if (playerSvtData.svt != null) {
      svtInfo = [
        ' Lv.${playerSvtData.lv} NP${playerSvtData.tdLv}',
        if (playerSvtData.atkFou != 1000 || playerSvtData.hpFou != 1000)
          ' ${playerSvtData.atkFou}/${playerSvtData.hpFou}',
        ' ${playerSvtData.skillLvs.join("/")}',
        ' ${playerSvtData.appendLvs.map((e) => e == 0 ? "-" : e).join("/")}',
      ].join('\n');
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
    svtIcon = Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.topCenter,
      children: [
        svtIcon,
        if (playerSvtData.supportType.isSupport)
          Positioned(
            top: -5,
            right: -5,
            child: db.getIconImage(AssetURL.i.items(12), width: 32, aspectRatio: 1),
          ),
        if (playerSvtData.customPassives.isNotEmpty)
          Positioned(
            top: -5,
            child: db.getIconImage(AssetURL.i.buffIcon(302), width: 24, aspectRatio: 1),
          )
      ],
    );

    svtIcon = _DragHover<_DragSvtData>(
      enableEdit: enableEdit,
      data: _DragSvtData(playerSvtData),
      hovered: hovered,
      hoverKey: '${playerSvtData.hashCode}-svt',
      child: svtIcon,
      hoveredBuilder: (context, child) {
        return _stackActions(
          context: context,
          child: child,
          onTapSelect: () {
            Set<int>? eventSvtIds;
            final event = questPhase?.event;
            if (event != null) {
              eventSvtIds = db.gameData.servantsById.values
                  .where((svt) => svt.eventSkills(eventId: event.id, includeZero: false).isNotEmpty)
                  .map((e) => e.id)
                  .toSet();
            }
            router.pushPage(
              ServantListPage(
                planMode: false,
                onSelected: (selectedSvt) {
                  playerSvtData.onSelectServant(
                    selectedSvt,
                    region: playerRegion,
                    jpTime: questPhase?.jpOpenAt,
                  );
                  onChanged();
                },
                filterData: svtFilterData,
                pinged: db.curUser.battleSim.pingedSvts.toList(),
                showSecondaryFilter: true,
                eventSvtIds: eventSvtIds,
              ),
              detail: true,
            );
          },
          onTapClear: () {
            playerSvtData.svt = null;
            onChanged();
          },
          iconSize: 16,
        );
      },
      onTap: () async {
        if (!enableEdit && playerSvtData.svt == null) return;
        await router.pushPage(ServantOptionEditPage(
          playerSvtData: enableEdit ? playerSvtData : playerSvtData.copy(),
          questPhase: questPhase,
          playerRegion: playerRegion,
          onChange: onChanged,
          svtFilterData: svtFilterData,
        ));
        onChanged();
      },
      onAccept: (data) {
        onDragSvt?.call(data.svt);
      },
    );

    children.add(svtIcon);

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

    ceIcon = _DragHover<_DragCEData>(
      enableEdit: enableEdit,
      data: _DragCEData(playerSvtData),
      hovered: hovered,
      hoverKey: '${playerSvtData.hashCode}-ce',
      child: ceIcon,
      hoveredBuilder: (context, child) {
        return _stackActions(
          context: context,
          child: child,
          onTapSelect: () {
            router.pushPage(
              CraftListPage(
                onSelected: (ce) {
                  playerSvtData.onSelectCE(ce);
                  onChanged();
                },
                filterData: craftFilterData,
                pinged: db.curUser.battleSim.pingedCEsWithEventAndBond(questPhase, playerSvtData.svt).toList(),
              ),
              detail: true,
            );
          },
          onTapClear: () {
            playerSvtData.ce = null;
            onChanged();
          },
          iconSize: 16,
        );
      },
      onTap: () async {
        if (!enableEdit && playerSvtData.ce == null) return;
        await router.pushPage(CraftEssenceOptionEditPage(
          playerSvtData: enableEdit ? playerSvtData : playerSvtData.copy(),
          questPhase: questPhase,
          onChange: onChanged,
          craftFilterData: craftFilterData,
        ));
        onChanged();
      },
      onAccept: (data) {
        onDragCE?.call(data.svt);
      },
    );

    children.add(Center(child: ceIcon));

    // ce info
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
      padding: const EdgeInsets.all(2),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: children,
      ),
    );
  }

  Widget _stackActions({
    required BuildContext context,
    required Widget child,
    required VoidCallback? onTapSelect,
    required VoidCallback? onTapClear,
    double iconSize = 24,
  }) {
    if (!Theme.of(context).platform.isDesktop) return child;
    const double padding = 4;
    return Stack(
      clipBehavior: Clip.none,
      children: [
        child,
        Positioned(
          left: 0,
          top: -iconSize / 2,
          child: Container(
            decoration: ShapeDecoration(
              color: Theme.of(context).colorScheme.primary,
              shape: const CircleBorder(),
            ),
            child: IconButton(
              onPressed: onTapSelect,
              icon: const Icon(Icons.people),
              color: Colors.white,
              iconSize: iconSize,
              constraints: const BoxConstraints(),
              padding: const EdgeInsets.all(padding),
              splashRadius: 20,
            ),
          ),
        ),
        Positioned(
          right: 0,
          top: -iconSize / 2,
          child: Container(
            decoration: ShapeDecoration(
              color: Theme.of(context).colorScheme.errorContainer,
              shape: const CircleBorder(),
            ),
            child: IconButton(
              onPressed: onTapClear,
              icon: const Icon(Icons.remove_circle_outline),
              color: Colors.white,
              iconSize: iconSize,
              constraints: const BoxConstraints(),
              padding: const EdgeInsets.all(padding),
              splashRadius: 20,
            ),
          ),
        ),
      ],
    );
  }
}

class _DragHover<T extends Object> extends StatefulWidget {
  final bool enableEdit;
  final T data;
  final String hoverKey;
  final Widget child;
  final Widget Function(BuildContext context, Widget child) hoveredBuilder;
  final VoidCallback onTap;
  final DragTargetAccept<T> onAccept;
  final ValueNotifier<String?> hovered;

  const _DragHover({
    super.key,
    required this.enableEdit,
    required this.data,
    required this.hoverKey,
    required this.child,
    required this.hoveredBuilder,
    required this.onTap,
    required this.onAccept,
    required this.hovered,
  });

  @override
  State<_DragHover<T>> createState() => __DragHoverState<T>();
}

class __DragHoverState<T extends Object> extends State<_DragHover<T>> {
  static bool dragging = false;

  @override
  Widget build(BuildContext context) {
    Widget base = InkWell(
      onHover: (hovered) {
        setState(() {
          if (hovered) {
            widget.hovered.value = widget.hoverKey;
          } else if (widget.hovered.value == widget.hoverKey) {
            widget.hovered.value = null;
          }
        });
      },
      onTap: widget.onTap,
      child: widget.child,
    );

    if (!widget.enableEdit) return base;

    Widget child = DragTarget<T>(
      builder: (context, candidateData, rejectedData) {
        return base;
      },
      onAccept: widget.onAccept,
    );
    child = Draggable<T>(
      data: widget.data,
      feedback: child,
      child: child,
      onDragStarted: () {
        setState(() {
          dragging = true;
        });
      },
      onDragCompleted: () {
        setState(() {
          dragging = false;
        });
      },
      onDraggableCanceled: (_, __) {
        if (mounted) {
          setState(() {
            dragging = false;
          });
        }
      },
      onDragEnd: (details) {
        setState(() {
          dragging = false;
        });
      },
    );
    if (!dragging && widget.hoverKey == widget.hovered.value) {
      child = widget.hoveredBuilder(context, child);
    }
    return child;
  }
}
