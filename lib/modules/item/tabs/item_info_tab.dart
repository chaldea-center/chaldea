import 'package:auto_size_text/auto_size_text.dart';
import 'package:chaldea/components/components.dart';
import 'package:chaldea/modules/enemy/enemy_detail_page.dart';

class ItemInfoTab extends StatefulWidget {
  final String itemKey;

  const ItemInfoTab({Key? key, required this.itemKey}) : super(key: key);

  @override
  _ItemInfoTabState createState() => _ItemInfoTabState();
}

class _ItemInfoTabState extends State<ItemInfoTab> {
  String get itemKey => widget.itemKey;

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

  final validCoins = const [2, 6, 15, 30, 50, 90];
  List<int> bondCoins = <int>[
    ...List.generate(6, (index) => 5),
    ...List.generate(3, (index) => 10),
    ...List.generate(6, (index) => 20),
  ];
  int _summonCoin = 90;
  int _baseNp = 1;

  List<Widget> _svtCoinObtain() {
    return [
      CustomTableRow.fromTexts(
        isHeader: true,
        texts: [
          LocalizedText.of(
            chs: '表格设置：硬币数/宝具 & 显示范围',
            jpn: 'テーブル設定：コイン/宝具&表示範囲',
            eng: 'Table Setting: coins/NP & NP range',
          )
        ],
      ),
      SizedBox(
        height: 36,
        child: CustomTableRow.fromChildren(
          children: List.generate(
            validCoins.length,
            (index) => InkWell(
              onTap: () {
                setState(() {
                  _summonCoin = validCoins[index];
                });
              },
              child: SizedBox.expand(
                child: Center(
                  child: AutoSizeText(
                    '${validCoins[index]}',
                    textAlign: TextAlign.center,
                    style: _summonCoin == validCoins[index]
                        ? TextStyle(
                            color: Theme.of(context).errorColor,
                            fontWeight: FontWeight.bold,
                          )
                        : null,
                    maxLines: 1,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
      SizedBox(
        height: 36,
        child: CustomTableRow.fromChildren(
          children: [
            Text(LocalizedText.of(chs: '范围', jpn: 'Range', eng: 'Range')),
            ...List.generate(
              5,
              (index) {
                int baseNp = 1 + 5 * index;
                return InkWell(
                  onTap: () {
                    setState(() {
                      _baseNp = baseNp;
                    });
                  },
                  child: SizedBox.expand(
                    child: Center(
                      child: AutoSizeText(
                        '$baseNp~${baseNp + 4}',
                        textAlign: TextAlign.center,
                        style: baseNp == _baseNp
                            ? TextStyle(
                                color: Theme.of(context).errorColor,
                                fontWeight: FontWeight.bold,
                              )
                            : null,
                        maxLines: 1,
                      ),
                    ),
                  ),
                );
              },
            )
          ],
        ),
      ),
      CustomTableRow.fromTexts(
        texts: [
          (S.current.bond),
          for (int np = _baseNp; np < _baseNp + 5; np++) 'NP $np',
        ],
        isHeader: true,
      ),
      for (int index = 0; index < bondCoins.length; index++)
        CustomTableRow(
          children: List.generate(
            6,
            (np) {
              if (np == 0) {
                return TableCellData(text: 'Lv.${index + 1}');
              }
              int coins = Maths.sum(bondCoins.sublist(0, index + 1)) +
                  (np + _baseNp) * _summonCoin;
              return TableCellData(
                text: coins.toString(),
                style: coins > 480
                    ? TextStyle(
                        color: Theme.of(context).hintColor,
                        fontStyle: FontStyle.italic,
                      )
                    : const TextStyle(fontWeight: FontWeight.bold),
                maxLines: 1,
              );
            },
          ),
        ),
    ];
  }
}
