import 'dart:math';

import 'package:flutter/material.dart';

import 'package:auto_size_text/auto_size_text.dart';

import 'package:chaldea/app/modules/common/builders.dart';
import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/models/models.dart';
import 'package:chaldea/utils/utils.dart';
import 'package:chaldea/widgets/widgets.dart';
import '../../../app.dart';

class ItemInfoTab extends StatefulWidget {
  final int itemId;

  const ItemInfoTab({super.key, required this.itemId});

  @override
  _ItemInfoTabState createState() => _ItemInfoTabState();
}

class _ItemInfoTabState extends State<ItemInfoTab> {
  int get itemId => widget.itemId;

  @override
  Widget build(BuildContext context) {
    if (Items.specialSvtMat.contains(itemId)) {
      final svt = db.gameData.entities[itemId];
      return ListTile(
        title: Center(
          child: ElevatedButton(
            onPressed: () {
              router.push(url: Routes.enemyI(itemId));
            },
            child: Text('${S.current.servant} - ${svt?.lName.l}'),
          ),
        ),
      );
    }
    final item = db.gameData.items[itemId];
    if (item == null) {
      return ListTile(
        title: Text('NotFound: $itemId'),
      );
    }
    return SingleChildScrollView(
      child: SafeArea(
        child: CustomTable(
          children: <Widget>[
            CustomTableRow(
              children: [
                TableCellData(
                  child: db.getIconImage(item.borderedIcon, height: 72),
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
                          child: Text(item.lName.l,
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold)),
                          isHeader: true,
                          textAlign: TextAlign.center,
                        )
                      ]),
                      if (!Transl.isJP)
                        CustomTableRow.fromTexts(texts: [item.name]),
                      if (!Transl.isEN)
                        CustomTableRow.fromTexts(texts: [item.lName.na]),
                      CustomTableRow.fromTexts(
                          texts: ['No.${item.id}', item.type.name]),
                    ],
                  ),
                ),
              ],
            ),
            if (svtCoinOwner != null)
              TextButton(
                onPressed: () => svtCoinOwner!.routeTo(),
                style: kTextButtonDenseStyle,
                child: Text(svtCoinOwner!.lName.l),
              ),
            if (item.individuality.isNotEmpty) ...[
              CustomTableRow.fromTexts(
                  texts: [S.current.info_trait], isHeader: true),
              CustomTableRow.fromChildren(children: [
                SharedBuilder.traitList(
                    context: context, traits: item.individuality)
              ])
            ],
            CustomTableRow.fromTexts(
                texts: [S.current.card_description], isHeader: true),
            CustomTableRow(
              children: [
                TableCellData(
                  text: item.detail,
                  alignment: Alignment.centerLeft,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                )
              ],
            ),
            if (item.type == ItemType.svtCoin) ..._svtCoinObtain(),
            if (item.type == ItemType.itemSelect) ...[
              CustomTableRow.fromTexts(
                texts: [S.current.exchange_ticket],
                isHeader: true,
              ),
              CustomTableRow.fromChildren(children: [
                SharedBuilder.giftGrid(context: context, gifts: [
                  for (final select in item.itemSelects) ...select.gifts
                ])
              ]),
              CustomTableRow.fromTexts(
                  texts: const ['Warning: JP info only!!!']),
            ],
          ],
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    svtCoinOwner = db.gameData.servantsNoDup.values
        .firstWhereOrNull((svt) => svt.coin?.item.id == itemId);
    if (svtCoinOwner != null) {
      _summonCoin = svtCoinOwner!.coin!.summonNum;
    }
  }

  Servant? svtCoinOwner;
  final validCoins = const [2, 6, 15, 30, 50, 90];
  List<int> bondCoins = <int>[
    ...List.generate(6, (index) => 5),
    ...List.generate(3, (index) => 10),
    ...List.generate(6, (index) => 20),
  ];
  int _summonCoin = 90;
  int _baseNp = 1;
  int _offsetNp = 0;

  List<Widget> _svtCoinObtain() {
    return [
      CustomTableRow.fromTexts(
        isHeader: true,
        texts: const ['Table Setting: coins/NP & NP range'],
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
                    style: TextStyle(
                      color: _summonCoin == validCoins[index]
                          ? Theme.of(context).errorColor
                          : null,
                      fontWeight: _summonCoin == validCoins[index]
                          ? FontWeight.bold
                          : null,
                      decoration:
                          svtCoinOwner?.coin?.summonNum == validCoins[index]
                              ? TextDecoration.underline
                              : null,
                    ),
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
            const Text('Range'),
            ...List.generate(
              5,
              (index) {
                int baseNp = 1 + 5 * (index + max(0, _offsetNp));
                return InkWell(
                  onTap: () {
                    setState(() {
                      _baseNp = baseNp;
                      if (index == 4) _offsetNp += 1;
                      if (index == 0) _offsetNp = max(0, _offsetNp - 1);
                    });
                  },
                  child: SizedBox.expand(
                    child: Center(
                      child: AutoSizeText(
                        '$baseNp~${baseNp + 4}',
                        textAlign: TextAlign.center,
                        minFontSize: 6,
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
      for (int index = 0; index < bondCoins.length + 1; index++)
        CustomTableRow(
          children: List.generate(
            6,
            (np) {
              if (np == 0) {
                return TableCellData(text: 'Lv.$index');
              }
              int coins = Maths.sum(bondCoins.sublist(0, index)) +
                  (np + _baseNp - 1) * _summonCoin;
              return TableCellData(
                text: coins.toString(),
                style: coins > 660
                    ? TextStyle(
                        color: Theme.of(context).hintColor,
                        fontStyle: FontStyle.italic,
                      )
                    : coins > 480
                        ? const TextStyle(fontWeight: FontWeight.w300)
                        : const TextStyle(fontWeight: FontWeight.bold),
                maxLines: 1,
              );
            },
          ),
        ),
    ];
  }
}
