import 'package:auto_size_text/auto_size_text.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:chaldea/components/components.dart';
import 'package:chaldea/modules/servant/servant_detail_page.dart';

class CostumeDetailPage extends StatelessWidget {
  final Costume costume;

  const CostumeDetailPage({Key? key, required this.costume}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final svt = db.gameData.servants[costume.svtNo];
    final illustrations = [
      costume.illustration,
      ...costume.models,
      costume.avatar,
    ];
    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(),
        title: AutoSizeText(costume.lName, minFontSize: 10, maxLines: 1),
        titleSpacing: 0,
      ),
      body: SingleChildScrollView(
        child: CustomTable(
          children: <Widget>[
            CustomTableRow(
              children: [
                TableCellData(
                  child: db.getIconImage(costume.icon, height: 90),
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
                            costume.name,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center,
                          ),
                          isHeader: true,
                        )
                      ]),
                      CustomTableRow(children: [
                        TableCellData(
                            text: costume.nameJp, textAlign: TextAlign.center)
                      ]),
                      CustomTableRow(children: [
                        TableCellData(
                            text: costume.nameEn, textAlign: TextAlign.center)
                      ]),
                      CustomTableRow(children: [
                        TableCellData(text: 'No. ${costume.no}'),
                        TableCellData(
                          flex: 2,
                          child: TextButton(
                            child: Text(svt?.info.localizedName ?? '-'),
                            onPressed: svt == null
                                ? null
                                : () => SplitRoute.push(
                                    context, ServantDetailPage(svt)),
                            style: TextButton.styleFrom(
                                minimumSize: const Size(24, 28),
                                tapTargetSize:
                                    MaterialTapTargetSize.shrinkWrap),
                          ),
                        )
                      ]),
                    ],
                  ),
                ),
              ],
            ),
            CustomTableRow(children: [
              TableCellData(text: S.current.item, isHeader: true)
            ]),
            CustomTableRow(children: [
              TableCellData(
                child: costume.itemCost.isEmpty
                    ? const Text('-')
                    : Wrap(
                        spacing: 4,
                        runSpacing: 2,
                        alignment: WrapAlignment.center,
                        children: costume.itemCost.entries
                            .map((e) => Item.iconBuilder(
                                  context: context,
                                  itemKey: e.key,
                                  text: formatNumber(e.value, compact: true),
                                  width: 44,
                                ))
                            .toList(),
                      ),
              )
            ]),
            CustomTableRow(children: [
              TableCellData(text: S.current.obtain_methods, isHeader: true)
            ]),
            CustomTableRow(
                children: [TableCellData(child: Text(costume.lObtain))]),
            CustomTableRow(children: [
              TableCellData(text: S.current.card_description, isHeader: true)
            ]),
            if (costume.descriptionJp?.isNotEmpty == true)
              CustomTableRow(
                children: [
                  TableCellData(
                    text: costume.descriptionJp,
                    alignment: Alignment.centerLeft,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  )
                ],
              ),
            if (costume.description?.isNotEmpty == true)
              CustomTableRow(
                children: [
                  TableCellData(
                    text: costume.description,
                    alignment: Alignment.centerLeft,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  )
                ],
              ),
            CustomTableRow(children: [
              TableCellData(
                  text: LocalizedText.of(
                      chs: '< 立绘/模型 >',
                      jpn: '< イラスト・バトルキャラ >',
                      eng: '< Illustration/Sprites >'),
                  isHeader: true)
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
            ])
          ],
        ),
      ),
    );
  }
}
