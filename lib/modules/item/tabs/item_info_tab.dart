import 'package:chaldea/components/components.dart';
import 'package:chaldea/modules/enemy/enemy_detail_page.dart';

class ItemInfoTab extends StatelessWidget {
  final String itemKey;

  const ItemInfoTab({Key? key, required this.itemKey}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final itemInfo = db.gameData.items[itemKey];
    if (itemInfo == null) {
      return const ListTile(
        title: Text('......'),
      );
    }
    return SingleChildScrollView(
      child: CustomTable(
        children: <Widget>[
          CustomTableRow(
            children: [
              TableCellData(
                child: db.getIconImage(itemInfo.name, height: 72),
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
                        child: Text(itemInfo.name,
                            style:
                                const TextStyle(fontWeight: FontWeight.bold)),
                        isHeader: true,
                      )
                    ]),
                    CustomTableRow.fromTexts(texts: [itemInfo.nameJp ?? '-']),
                    CustomTableRow.fromTexts(texts: [itemInfo.nameEn ?? '-']),
                    CustomTableRow(children: [
                      TableCellData(text: 'ID', isHeader: true),
                      if (kDebugMode)
                        TableCellData(text: itemInfo.id.toString()),
                      TableCellData(
                        text: itemInfo.itemId.toString(),
                        flex: kDebugMode ? 1 : 2,
                      ),
                    ]),
                  ],
                ),
              ),
            ],
          ),
          if (itemInfo.enemies.isNotEmpty) ...[
            CustomTableRow.fromTexts(
                texts: [S.current.enemy_list], isHeader: true),
            CustomTableRow.fromChildren(children: [
              Wrap(
                spacing: 1,
                runSpacing: 1,
                children: itemInfo.enemies.map((e) {
                  final enemy = db.gameData.enemies[e];
                  if (enemy == null || enemy.icon == null) return Text(e);
                  return GameCardMixin.cardIconBuilder(
                    context: context,
                    icon: enemy.icon!,
                    height: 36,
                    aspectRatio: 1,
                    onTap: () {
                      SplitRoute.push(context, EnemyDetailPage(enemy: enemy));
                    },
                  );
                }).toList(),
              )
            ])
          ],
          if (itemInfo.description != null || itemInfo.descriptionJp != null)
            CustomTableRow.fromTexts(
                texts: [S.current.card_description], isHeader: true),
          if (itemInfo.description != null)
            CustomTableRow(
              children: [
                TableCellData(
                  text: itemInfo.description,
                  alignment: Alignment.centerLeft,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                )
              ],
            ),
          if (itemInfo.descriptionJp != null)
            CustomTableRow(
              children: [
                TableCellData(
                  text: itemInfo.descriptionJp,
                  alignment: Alignment.centerLeft,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
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
          LocalizedText.of(chs: '奖励', jpn: '報酬', eng: 'Rewards', kor: '보수'),
          'SUM'
        ],
        isHeader: true,
      ),
      for (int index = 0; index < bondCoins.length; index++)
        CustomTableRow.fromTexts(texts: [
          'Lv.${index + 1}',
          bondCoins[index].toString(),
          Maths.sum(bondCoins.sublist(0, index + 1)).toString()
        ])
    ];
  }
}
