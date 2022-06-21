import 'package:flutter/material.dart';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:carousel_slider/carousel_slider.dart';

import 'package:chaldea/app/app.dart';
import 'package:chaldea/app/modules/common/not_found.dart';
import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/models/models.dart';
import 'package:chaldea/utils/utils.dart';
import 'package:chaldea/widgets/widgets.dart';

class CostumeDetailPage extends StatelessWidget {
  final int? id;
  final NiceCostume? _costume;

  const CostumeDetailPage({Key? key, this.id, NiceCostume? costume})
      : _costume = costume,
        super(key: key);

  @override
  Widget build(BuildContext context) {
    final costume = _costume ??
        db.gameData.costumes[id] ??
        db.gameData.costumes.values
            .firstWhereOrNull((e) => e.battleCharaId == id);
    if (costume == null) {
      return NotFoundPage(
          url: Routes.costumeI(id ?? 0), title: S.current.costume);
    }
    final svt = costume.owner;
    final List<String?> illustrations = [
      svt?.extraAssets.charaGraph.costume?[costume.battleCharaId],
      svt?.extraAssets.charaGraphEx.costume?[costume.battleCharaId],
      svt?.extraAssets.charaFigure.costume?[costume.battleCharaId],
      svt?.extraAssets.narrowFigure.costume?[costume.battleCharaId],
    ];
    final unlockMats = svt?.costumeMaterials[costume.battleCharaId];
    final table = CustomTable(
      children: <Widget>[
        CustomTableRow(
          children: [
            TableCellData(
              child: db.getIconImage(costume.icon, height: 72),
              flex: 1,
              padding: const EdgeInsets.all(3),
            ),
            TableCellData(
              flex: 3,
              padding: EdgeInsets.zero,
              child: CustomTable(
                hideOutline: true,
                children: <Widget>[
                  CustomTableRow(children: [
                    TableCellData(
                      child: Text(
                        costume.lName.l,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                      isHeader: true,
                    )
                  ]),
                  if (!Transl.isJP)
                    CustomTableRow(children: [
                      TableCellData(
                          text: costume.name, textAlign: TextAlign.center)
                    ]),
                  if (!Transl.isEN)
                    CustomTableRow(children: [
                      TableCellData(
                          text: costume.lName.na, textAlign: TextAlign.center)
                    ]),
                  CustomTableRow.fromTexts(texts: [
                    'No. ${costume.costumeCollectionNo}',
                    'No. ${costume.battleCharaId}'
                  ])
                ],
              ),
            ),
          ],
        ),
        TextButton(
          onPressed: svt == null ? null : () => svt.routeTo(),
          style: kTextButtonDenseStyle,
          child: Text(svt?.lName.l ?? '-'),
        ),
        CustomTableRow(
            children: [TableCellData(text: S.current.item, isHeader: true)]),
        CustomTableRow(children: [
          TableCellData(
            child: unlockMats == null
                ? const Text('-')
                : Wrap(
                    spacing: 4,
                    runSpacing: 2,
                    alignment: WrapAlignment.center,
                    children: unlockMats
                        .toItemDict()
                        .entries
                        .map((e) => Item.iconBuilder(
                              context: context,
                              itemId: e.key,
                              text: e.value.format(),
                              width: 44,
                              item: null,
                            ))
                        .toList(),
                  ),
          )
        ]),
        // CustomTableRow(children: [
        //   TableCellData(text: S.current.obtain_methods, isHeader: true)
        // ]),
        // CustomTableRow(
        //     children: [TableCellData(child: Text(costume.lObtain))]),
        CustomTableRow(children: [
          TableCellData(text: S.current.card_description, isHeader: true)
        ]),
        if (costume.lDetail.l != costume.detail)
          CustomTableRow(
            children: [
              TableCellData(
                text: costume.lDetail.l,
                alignment: Alignment.centerLeft,
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              )
            ],
          ),
        CustomTableRow(
          children: [
            TableCellData(
              text: costume.detail,
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            )
          ],
        ),
        CustomTableRow(children: [
          TableCellData(text: S.current.illustration, isHeader: true)
        ]),
        CustomTableRow(children: [
          TableCellData(
            child: CarouselSlider(
              items: List.generate(
                illustrations.length,
                (index) => GestureDetector(
                  child: CachedImage(imageUrl: illustrations[index]),
                  onTap: () {
                    FullscreenImageViewer.show(
                      context: context,
                      urls: illustrations,
                      initialPage: index,
                    );
                  },
                ),
              ),
              options: CarouselOptions(
                height: 400,
                viewportFraction: 1.0,
                enableInfiniteScroll: false,
              ),
            ),
          )
        ]),
      ],
    );
    return Scaffold(
      appBar: AppBar(
          title: AutoSizeText(costume.lName.l, minFontSize: 10, maxLines: 1)),
      body: SingleChildScrollView(child: SafeArea(child: table)),
    );
  }
}
