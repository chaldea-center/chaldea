import 'package:auto_size_text/auto_size_text.dart';

import 'package:chaldea/app/app.dart';
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
  final Region playerRegion;
  final QuestPhase? questPhase;
  final VoidCallback onChange;
  final DragTargetAccept<PlayerSvtData> onDragSvt;
  final DragTargetAccept<PlayerSvtData> onDragCE;

  ServantSelector({
    super.key,
    required this.playerSvtData,
    required this.playerRegion,
    required this.questPhase,
    required this.onChange,
    required this.onDragSvt,
    required this.onDragCE,
  });

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
      icon: playerSvtData.svt?.ascendIcon(playerSvtData.limitCount, true) ?? Atlas.common.emptySvtIcon,
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
    if (playerSvtData.isSupportSvt) {
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

    svtIcon = InkWell(
      onTap: () async {
        await router.pushPage(ServantOptionEditPage(
          playerSvtData: playerSvtData,
          questPhase: questPhase,
          playerRegion: playerRegion,
          onChange: onChange,
        ));
        onChange();
      },
      child: svtIcon,
    );

    final svtDraggable = Draggable<_DragSvtData>(
      feedback: svtIcon,
      data: _DragSvtData(playerSvtData),
      child: svtIcon,
    );
    svtIcon = DragTarget<_DragSvtData>(
      builder: (context, candidateData, rejectedData) {
        return svtDraggable;
      },
      onAccept: (data) {
        onDragSvt(data.svt);
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
    ceIcon = InkWell(
      onTap: () async {
        await router.pushPage(CraftEssenceOptionEditPage(
          playerSvtData: playerSvtData,
          questPhase: questPhase,
          onChange: onChange,
        ));
        onChange();
      },
      child: ceIcon,
    );

    final ceDraggable = Draggable<_DragCEData>(
      feedback: ceIcon,
      data: _DragCEData(playerSvtData),
      child: ceIcon,
    );
    ceIcon = DragTarget<_DragCEData>(
      builder: (context, candidateData, rejectedData) {
        return ceDraggable;
      },
      onAccept: (data) {
        onDragCE(data.svt);
      },
    );

    children.add(Center(child: ceIcon));

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
