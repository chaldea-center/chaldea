import 'package:chaldea/components/components.dart';

class ItemInfoTab extends StatelessWidget {
  final String itemKey;

  const ItemInfoTab({Key? key, required this.itemKey}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final itemInfo = db.gameData.items[itemKey];
    if (itemInfo == null)
      return ListTile(
        title: Text('......'),
      );
    return SingleChildScrollView(
      child: CustomTable(
        children: <Widget>[
          CustomTableRow(
            children: [
              TableCellData(
                child: db.getIconImage(itemInfo.name, height: 72),
                flex: 1,
                padding: EdgeInsets.all(3),
              ),
              TableCellData(
                flex: 3,
                padding: EdgeInsets.zero,
                child: CustomTable(
                  hideOutline: true,
                  children: <Widget>[
                    CustomTableRow(children: [
                      TableCellData(
                        child: Text(itemInfo.name,
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        isHeader: true,
                      )
                    ]),
                    CustomTableRow.fromTexts(texts: [itemInfo.nameJp ?? '-']),
                    CustomTableRow.fromTexts(texts: [itemInfo.nameEn ?? '-']),
                    if (kDebugMode)
                      CustomTableRow.fromTexts(texts: [
                        itemInfo.id.toString(),
                        itemInfo.itemId.toString()
                      ])
                  ],
                ),
              ),
            ],
          ),
          if (itemInfo.description != null || itemInfo.descriptionJp != null)
            CustomTableRow(children: [
              TableCellData(
                  text: S.of(context).card_description, isHeader: true)
            ]),
          if (itemInfo.description != null)
            CustomTableRow(
              children: [
                TableCellData(
                  text: itemInfo.description,
                  alignment: Alignment.centerLeft,
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                )
              ],
            ),
          if (itemInfo.descriptionJp != null)
            CustomTableRow(
              children: [
                TableCellData(
                  text: itemInfo.descriptionJp,
                  alignment: Alignment.centerLeft,
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                )
              ],
            ),
          if (itemKey == Items.servantCoin) ..._svtCoinObtain(),
        ],
      ),
    );
  }

  List<Widget> _svtCoinObtain() {
    List<int> bondCoins = [
      ...List.generate(6, (index) => 5),
      ...List.generate(3, (index) => 10),
      ...List.generate(6, (index) => 20),
    ];
    return [
      CustomTableRow.fromTexts(
        texts: [
          S.current.bond,
          LocalizedText.of(chs: '奖励', jpn: '報酬', eng: 'Rewards'),
          'SUM'
        ],
        isHeader: true,
      ),
      for (int index = 0; index < bondCoins.length; index++)
        CustomTableRow.fromTexts(texts: [
          'Lv.${index + 1}',
          bondCoins[index].toString(),
          sum(bondCoins.sublist(0, index + 1)).toString()
        ])
    ];
  }
}
