import 'package:auto_size_text/auto_size_text.dart';

import 'package:chaldea/app/app.dart';
import 'package:chaldea/app/descriptors/cond_target_value.dart';
import 'package:chaldea/app/modules/common/not_found.dart';
import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/models/models.dart';
import 'package:chaldea/packages/audio.dart';
import 'package:chaldea/utils/utils.dart';
import 'package:chaldea/widgets/widgets.dart';

class BgmDetailPage extends StatefulWidget {
  final int? id;
  final Bgm? _bgm;

  const BgmDetailPage({super.key, this.id, Bgm? bgm}) : _bgm = bgm;

  @override
  State<BgmDetailPage> createState() => _BgmDetailPageState();
}

class _BgmDetailPageState extends State<BgmDetailPage> {
  late final player = MyAudioPlayer<String>();

  @override
  void dispose() {
    super.dispose();
    player.stop();
  }

  @override
  Widget build(BuildContext context) {
    final bgm = widget._bgm ?? db.gameData.bgms[widget.id];
    if (bgm == null) {
      return NotFoundPage(url: Routes.costumeI(widget.id ?? 0), title: 'BGM');
    }
    final BgmEntity? bgmEntity =
        bgm is BgmEntity ? bgm : db.gameData.bgms[bgm.id];
    final table = CustomTable(
      selectable: true,
      children: <Widget>[
        if (bgmEntity?.logo != null)
          CustomTableRow.fromChildren(
              children: [db.getIconImage(bgmEntity?.logo, height: 72)]),
        CustomTableRow(children: [
          TableCellData(
            child: Text(
              bgm.lName.l,
              style: const TextStyle(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            isHeader: true,
          )
        ]),
        if (!Transl.isJP)
          CustomTableRow(children: [
            TableCellData(text: bgm.name, textAlign: TextAlign.center)
          ]),
        // if (!Transl.isEN)
        //   CustomTableRow(children: [
        //     TableCellData(text: bgm.lName.na, textAlign: TextAlign.center)
        //   ]),
        CustomTableRow.fromTexts(texts: ['No. ${bgm.id}']),
        CustomTableRow.fromChildren(children: [
          SoundPlayButton(
            url: bgm.audioAsset,
            name: bgm.fileName,
            player: player,
          ),
        ]),
        if (bgmEntity != null) ...[
          CustomTableRow(
              children: [TableCellData(text: S.current.item, isHeader: true)]),
          CustomTableRow(children: [
            TableCellData(
              child: bgmEntity.shop == null
                  ? const Text('-')
                  : Item.iconBuilder(
                      context: context,
                      item: bgmEntity.shop!.cost.item,
                      text: bgmEntity.shop!.cost.amount.format(),
                    ),
            )
          ]),
        ],
        if (bgmEntity?.releaseConditions.isNotEmpty == true) ...[
          CustomTableRow.fromTexts(
              texts: [S.current.open_condition], isHeader: true),
          CustomTableRow(children: [
            TableCellData(
              alignment: AlignmentDirectional.centerStart,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (final release in bgmEntity!.releaseConditions) ...[
                    for (int index = 0;
                        index < release.targetIds.length;
                        index++)
                      CondTargetValueDescriptor(
                        condType: release.type,
                        target: release.targetIds[index],
                        value: release.vals.getOrNull(index) ?? 0,
                        leading: const TextSpan(text: kULLeading),
                        textScaleFactor: 0.85,
                      ),
                    if (release.closedMessage.isNotEmpty)
                      Text(
                        release.closedMessage,
                        style: Theme.of(context)
                            .textTheme
                            .bodySmall
                            ?.copyWith(fontStyle: FontStyle.italic),
                      )
                  ]
                ],
              ),
            )
          ]),
        ],
      ],
    );
    return Scaffold(
      appBar: AppBar(
        title: AutoSizeText(bgm.tooltip.setMaxLines(1),
            minFontSize: 10, maxLines: 1),
        actions: [
          if (bgm.audioAsset != null)
            IconButton(
              onPressed: () {
                launch(bgm.audioAsset!, external: true);
              },
              icon: const Icon(Icons.download),
              tooltip: S.current.download,
            )
        ],
      ),
      body: SingleChildScrollView(child: SafeArea(child: table)),
    );
  }
}
