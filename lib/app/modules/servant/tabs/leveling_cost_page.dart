import 'dart:math';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:chaldea/models/models.dart';
import 'package:chaldea/utils/utils.dart';
import 'package:chaldea/widgets/custom_tile.dart';
import 'package:flutter/material.dart';

import '../../../../components/utils.dart';

class LevelingCostPage extends StatefulWidget {
  final Map<int, LvlUpMaterial> costList;
  final int curLv;
  final int targetLv;
  final String title;

  // final String Function(int level)? levelFormatter;

  const LevelingCostPage({
    Key? key,
    required this.costList,
    this.curLv = 0,
    this.targetLv = 0,
    this.title = '',
    // this.levelFormatter,
  })  : assert(curLv <= targetLv),
        super(key: key);

  @override
  State<StatefulWidget> createState() => LevelingCostPageState();
}

class LevelingCostPageState extends State<LevelingCostPage> {
  bool showAll = false;

  @override
  Widget build(BuildContext context) {
    // final int offset = widget.costList.length == 9 ? -1 : 0;
    final bool _showAll = showAll || widget.curLv >= widget.targetLv;
    final int lva = _showAll ? Maths.min(widget.costList.keys) : widget.curLv,
        lvb = _showAll ? Maths.max(widget.costList.keys) + 1 : widget.targetLv;
    final size = MediaQuery.of(context).size;
    return AlertDialog(
      contentPadding: EdgeInsets.zero,
      titlePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      title: Text(
        widget.title,
        style: const TextStyle(fontSize: 16),
      ),
      content: SizedBox(
        width: min(380, size.width * 0.8),
        child: ListView(
          shrinkWrap: true,
          children: List.generate(lvb - lva, (i) {
            return buildOneLevel(
              lva + i,
              widget.costList[lva + i],
            );
          }),
        ),
      ),
      actions: [
        TextButton(
          // minWidth: 120,
          onPressed: () {
            setState(() => showAll = !showAll);
          },
          // style: TextButton.styleFrom(),
          child: Text(showAll ? 'SHOW LESS' : 'SHOW MORE'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('OK'),
        )
      ],
    );
  }

  Widget buildOneLevel(int startLv, LvlUpMaterial? lvCost) {
    List<Widget> items = [];
    if (lvCost != null) {
      for (final itemAmount in [
        ...lvCost.items,
        ItemAmount(amount: lvCost.qp, item: Items.qp)
      ]) {
        if (itemAmount.amount > 0) {
          items.add(ImageWithText(
            image: Item.iconBuilder(
                context: context, icon: itemAmount.item.borderedIcon),
            width: 36,
            text: formatNumber(itemAmount.amount, compact: true),
          ));
        }
      }
    }
    return CustomTile(
      leading: SizedBox(
        width: 42,
        child: AutoSizeText('$startLv→${startLv + 1}', maxLines: 1),
      ),
      contentPadding: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
      title: items.isEmpty
          ? const Text('No item')
          : Wrap(
              spacing: 2,
              runSpacing: 2,
              children: items,
            ),
    );
    // return Padding(
    //   padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 3),
    //   child: Column(
    //     crossAxisAlignment: CrossAxisAlignment.start,
    //     mainAxisSize: MainAxisSize.min,
    //     children: <Widget>[
    //       CustomTile(
    //         title: Text(title),
    //         subtitle: lvCost.isEmpty
    //             ? Text(LocalizedText.of(
    //                 chs: '不消耗素材',
    //                 jpn: '素材消費なし',
    //                 eng: 'No item consumption',
    //                 kor: '소비된 소재 없음'))
    //             : null,
    //         contentPadding: const EdgeInsets.symmetric(horizontal: 0),
    //       ),
    //       if (lvCost.isNotEmpty)
    //         GridView.count(
    //           crossAxisCount: 6,
    //           childAspectRatio: 132 / 144,
    //           shrinkWrap: true,
    //           physics: const NeverScrollableScrollPhysics(),
    //           children: lvCost.entries
    //               .map((entry) => Padding(
    //                     padding: const EdgeInsets.symmetric(
    //                         horizontal: 2, vertical: 2),
    //                     child: ImageWithText(
    //                       image: Item.iconBuilder(
    //                           context: context, itemKey: entry.key),
    //                       text: formatNumber(entry.value, compact: true),
    //                     ),
    //                   ))
    //               .toList(),
    //         ),
    //     ],
    //   ),
    // );
  }
}
