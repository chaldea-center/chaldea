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

  /// 是否显示从者信息（等级、技能等级等），默认为 true。某些只需要选择从者但不关心具体信息的场景可以设置为 false 来隐藏这些信息。
  final bool isShowSvtInfo;

  /// 是否显示从者礼装栏，默认为 true。某些只需要选择从者但不关心礼装的场景可以设置为 false 来隐藏礼装栏。
  final bool isShowCE;

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
    this.isShowSvtInfo = true,
    this.isShowCE = true,
  });

  SvtFilterData get svtFilterData => db.runtimeData.svtFilters.current;
  CraftFilterData get craftFilterData => db.runtimeData.ceFilters.current;

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
      text: isShowSvtInfo ? svtInfo : null,
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
          Positioned(top: -5, right: -5, child: db.getIconImage(AssetURL.i.items(12), width: 32, aspectRatio: 1)),
        if (playerSvtData.customPassives.isNotEmpty ||
            playerSvtData.allowedExtraSkills.isNotEmpty ||
            playerSvtData.classBoardData.isNotEmpty)
          Positioned(top: -5, child: db.getIconImage(AssetURL.i.buffIcon(302), width: 24, aspectRatio: 1)),
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
            router.pushPage(
              ServantListPage(
                planMode: false,
                onSelected: (selectedSvt) {
                  playerSvtData.onSelectServant(selectedSvt, region: playerRegion, jpTime: questPhase?.jpOpenAt);
                  onChanged();
                },
                filterData: svtFilterData,
                pinged: db.curUser.battleSim.pingedSvts.toList(),
                showSecondaryFilter: true,
                eventId: questPhase?.logicEventId,
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
        await router.pushPage(
          ServantOptionEditPage(
            playerSvtData: enableEdit ? playerSvtData : playerSvtData.copy(),
            questPhase: questPhase,
            playerRegion: playerRegion,
            onChange: onChanged,
            svtFilterData: svtFilterData,
          ),
        );
        onChanged();
      },
      onAccept: (detail) {
        onDragSvt?.call(detail.data.svt);
      },
    );

    children.add(svtIcon);

    // svt name+btn
    children.add(
      SizedBox(
        height: 18,
        child: AutoSizeText(
          playerSvtData.svt?.lBattleName(playerSvtData.limitCount).l ?? S.current.servant,
          maxLines: 1,
          minFontSize: 10,
          textAlign: TextAlign.center,
          textScaleFactor: 0.9,
          style: playerSvtData.svt == null ? notSelectedStyle : null,
        ),
      ),
    );
    if (isShowCE) {
      children.add(const SizedBox(height: 8));
    }

    // ce icon
    Widget _buildCeIcon(SvtEquipData equip, {bool showLv = false}) {
      Widget _ceIcon = db.getIconImage(
        equip.ce?.extraAssets.equipFace.equip?[equip.ce?.id] ?? Atlas.common.emptyCeIcon,
        width: 80,
        aspectRatio: 150 / 68,
      );
      List<Widget> _stackChildren = [
        if (equip.ce != null && equip.limitBreak)
          Positioned(
            right: 4,
            bottom: 4,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.yellow),
              ),
              padding: const EdgeInsets.all(2),
              child: Icon(Icons.auto_awesome, color: Colors.yellow[900], size: 14),
            ),
          ),
        if (showLv && equip.ce != null)
          Positioned(left: 1, bottom: 1, child: Text('Lv.${equip.lv}', style: TextStyle(fontSize: 12))),
      ];
      if (_stackChildren.isNotEmpty) {
        _ceIcon = Stack(alignment: Alignment.bottomRight, children: [_ceIcon, ..._stackChildren]);
      }
      return _ceIcon;
    }

    if (isShowCE) {
      Widget equip1Icon = _buildCeIcon(playerSvtData.equip1);

      equip1Icon = _DragHover<_DragCEData>(
        enableEdit: enableEdit,
        data: _DragCEData(playerSvtData),
        hovered: hovered,
        hoverKey: '${playerSvtData.hashCode}-ce',
        child: equip1Icon,
        hoveredBuilder: (context, child) {
          return _stackActions(
            context: context,
            child: child,
            onTapSelect: () {
              router.pushPage(
                CraftListPage(
                  onSelected: (ce) {
                    playerSvtData.onSelectCE(ce, SvtEquipTarget.normal);
                    onChanged();
                  },
                  filterData: craftFilterData,
                  pinged: db.curUser.battleSim.pingedCEsWithEventAndBond(questPhase, playerSvtData.svt).toList(),
                ),
                detail: true,
              );
            },
            onTapClear: () {
              playerSvtData.equip1.ce = null;
              onChanged();
            },
            iconSize: 16,
          );
        },
        onTap: () async {
          if (!enableEdit && playerSvtData.equip1.ce == null) return;
          await router.pushPage(
            CraftEssenceOptionEditPage(
              playerSvtData: enableEdit ? playerSvtData : playerSvtData.copy(),
              equipTarget: SvtEquipTarget.normal,
              questPhase: questPhase,
              onChange: onChanged,
              craftFilterData: craftFilterData,
            ),
          );
          onChanged();
        },
        onAccept: (detail) {
          onDragCE?.call(detail.data.svt);
        },
      );

      children.add(Center(child: equip1Icon));

      // ce info
      String equip1Info = '';
      if (playerSvtData.equip1.ce != null) {
        equip1Info = 'Lv.${playerSvtData.equip1.lv}';
        if (playerSvtData.equip1.limitBreak) {
          equip1Info += ' ${S.current.max_limit_break}';
        }
      } else {
        equip1Info = 'Lv.-';
      }
      children.add(
        SizedBox(
          height: 18,
          child: AutoSizeText(
            equip1Info.breakWord,
            maxLines: 1,
            minFontSize: 10,
            textAlign: TextAlign.center,
            textScaleFactor: 0.9,
            style: playerSvtData.equip1.ce == null ? notSelectedStyle : null,
          ),
        ),
      );
      if (playerSvtData.grandSvt) {
        children.add(_buildCeIcon(playerSvtData.equip2, showLv: true));
        children.add(_buildCeIcon(playerSvtData.equip3, showLv: true));
      }
    }

    return Padding(
      padding: const EdgeInsets.all(2),
      child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.center, children: children),
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
            decoration: ShapeDecoration(color: Theme.of(context).colorScheme.primary, shape: const CircleBorder()),
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
  final DragTargetAcceptWithDetails<T> onAccept;
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
      onAcceptWithDetails: widget.onAccept,
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
      onDraggableCanceled: (_, _) {
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
