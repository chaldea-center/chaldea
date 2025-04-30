import 'package:auto_size_text/auto_size_text.dart';

import 'package:chaldea/app/app.dart';
import 'package:chaldea/app/modules/common/extra_assets_page.dart';
import 'package:chaldea/app/modules/common/not_found.dart';
import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/models/models.dart';
import 'package:chaldea/utils/utils.dart';
import 'package:chaldea/widgets/widgets.dart';

class CostumeDetailPage extends StatelessWidget {
  final int? id;
  final NiceCostume? _costume;

  const CostumeDetailPage({super.key, this.id, NiceCostume? costume}) : _costume = costume;

  @override
  Widget build(BuildContext context) {
    final costume = _costume ?? db.gameData.costumes[id] ?? db.gameData.costumesByCharaId[id];
    if (costume == null) {
      return NotFoundPage(url: Routes.costumeI(id ?? 0), title: S.current.costume);
    }
    final svt = costume.owner;
    final unlockMats = svt?.costumeMaterials[costume.battleCharaId];
    final table = CustomTable(
      selectable: true,
      children: <Widget>[
        CustomTableRow(
          children: [
            TableCellData(child: db.getIconImage(costume.icon, height: 72), flex: 1, padding: const EdgeInsets.all(3)),
            TableCellData(
              flex: 3,
              padding: EdgeInsets.zero,
              child: CustomTable(
                hideOutline: true,
                children: <Widget>[
                  CustomTableRow(
                    children: [
                      TableCellData(
                        child: Text(
                          costume.lName.l,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,
                        ),
                        isHeader: true,
                      ),
                    ],
                  ),
                  if (!Transl.isJP)
                    CustomTableRow(children: [TableCellData(text: costume.name, textAlign: TextAlign.center)]),
                  if (!Transl.isEN)
                    CustomTableRow(children: [TableCellData(text: costume.lName.na, textAlign: TextAlign.center)]),
                  CustomTableRow(
                    children: [
                      TableCellData(text: 'No. ${costume.costumeCollectionNo}'),
                      TableCellData(text: 'No. ${costume.battleCharaId} (${costume.id})', flex: 2),
                    ],
                  ),
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
        CustomTableRow(children: [TableCellData(text: S.current.item, isHeader: true)]),
        CustomTableRow(
          children: [
            TableCellData(
              child:
                  unlockMats == null
                      ? const Text('-')
                      : Wrap(
                        spacing: 4,
                        runSpacing: 2,
                        alignment: WrapAlignment.center,
                        children:
                            unlockMats
                                .toItemDict()
                                .entries
                                .map(
                                  (e) => Item.iconBuilder(
                                    context: context,
                                    itemId: e.key,
                                    text: e.value.format(),
                                    width: 44,
                                    item: null,
                                  ),
                                )
                                .toList(),
                      ),
            ),
          ],
        ),
        // CustomTableRow(children: [
        //   TableCellData(text: S.current.obtain_methods, isHeader: true)
        // ]),
        // CustomTableRow(
        //     children: [TableCellData(child: Text(costume.lObtain))]),
        CustomTableRow(children: [TableCellData(text: S.current.card_description, isHeader: true)]),
        if (costume.lDetail.l != costume.detail)
          CustomTableRow(
            children: [
              TableCellData(
                text: costume.lDetail.l,
                alignment: Alignment.centerLeft,
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              ),
            ],
          ),
        CustomTableRow(
          children: [
            TableCellData(
              text: costume.detail,
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            ),
          ],
        ),
        CustomTableRow(children: [TableCellData(text: S.current.illustration, isHeader: true)]),
        if (svt != null)
          ExtraAssetsPage(
            scrollable: false,
            assets: svt.extraAssets,
            getUrls: (urls) {
              final url = urls.costume?[costume.battleCharaId];
              return url == null ? [] : [url];
            },
            charaGraphPlaceholder: (_, __) => db.getIconImage(svt.classCard),
          ),
      ],
    );
    return Scaffold(
      appBar: AppBar(title: AutoSizeText(costume.lName.l, minFontSize: 10, maxLines: 1)),
      body: SingleChildScrollView(child: SafeArea(child: table)),
    );
  }
}
