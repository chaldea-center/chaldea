import 'dart:math';

import 'package:flutter/material.dart';

import 'package:chaldea/models/models.dart';
import 'package:chaldea/utils/utils.dart';
import 'package:chaldea/widgets/widgets.dart';

class SummonUtil {
  static Widget buildBlock({
    required BuildContext context,
    required ProbGroup block,
    bool showRarity = true,
    bool showProb = true,
    bool showStar = true,
    bool showFavorite = true,
    bool showCategory = true,
    bool showNpLv = true,
  }) {
    return cardGrid(
      ids: block.ids,
      header: showRarity ? '$kStarChar${block.rarity}' : null,
      childBuilder: (id) {
        Widget child;
        if (block.isSvt) {
          final svt = db.gameData.servants[id];
          if (svt == null) return Text('No.$id');
          child = svtAvatar(
            context: context,
            card: svt,
            weight: showProb ? block.weight / block.ids.length : null,
            star: showStar && block.ids.length == 1,
            favorite: showFavorite && db.curUser.svtStatusOf(id).favorite,
            npLv: showNpLv,
          );
        } else {
          final ce = db.gameData.craftEssences[id];
          if (ce == null) return Text('No.$id');
          child = buildCard(
            context: context,
            card: ce,
            weight: showProb ? block.weight / block.ids.length : null,
          );
        }
        return Center(
            child: Padding(padding: const EdgeInsets.all(2), child: child));
      },
    );
  }

  static Widget cardGrid({
    required Iterable<int> ids,
    required String? header,
    required Widget Function(int id) childBuilder,
  }) {
    final grid = LayoutBuilder(
      builder: (context, constraints) {
        int count = max(constraints.maxWidth ~/ 72, 5);
        double childWidth = constraints.maxWidth / count;
        return GridView.count(
          crossAxisCount: count,
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          childAspectRatio: childWidth / min(72, childWidth * 144 / 132),
          children: ids.map((id) {
            return childBuilder(id);
          }).toList(),
        );
      },
    );
    if (header == null) {
      return grid;
    } else {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SHeader(
            header,
            padding: const EdgeInsets.only(left: 0, top: 4, bottom: 2),
          ),
          grid,
        ],
      );
    }
  }

  static Widget svtAvatar({
    required BuildContext context,
    required GameCardMixin? card,
    double? weight,
    bool star = false,
    bool favorite = false,
    bool category = true,
    bool npLv = true,
  }) {
    return Stack(
      alignment: Alignment.topRight,
      children: [
        buildCard(
          context: context,
          card: card,
          weight: weight,
          showCategory: category,
          showNpLv: npLv,
        ),
        if (favorite || star)
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (favorite)
                Container(
                  padding: const EdgeInsets.all(1.5),
                  margin: const EdgeInsets.only(bottom: 1),
                  decoration: BoxDecoration(
                      color: Colors.blueAccent,
                      borderRadius: BorderRadius.circular(3)),
                  child: const Icon(
                    Icons.favorite,
                    color: Colors.white,
                    size: 10,
                  ),
                ),
              if (star)
                Container(
                  padding: const EdgeInsets.all(1.5),
                  decoration: BoxDecoration(
                      color: Colors.blueAccent[400],
                      borderRadius: BorderRadius.circular(3)),
                  child: Icon(
                    Icons.star,
                    color: Colors.yellowAccent[400],
                    size: 10,
                  ),
                ),
            ],
          ),
      ],
    );
  }

  static Widget buildCard({
    required BuildContext context,
    required GameCardMixin? card,
    double? weight,
    bool showCategory = false,
    bool showNpLv = true,
  }) {
    if (card == null) return Container();
    List<String> texts = [];
    if (showNpLv && card is Servant) {
      texts.add('NP${card.status.cur.npLv}');
    }

    if (weight != null) {
      texts.add('${_removeDoubleTrailing(weight)}%');
    }
    if (showCategory && card is Servant) {
      for (final obtain in [SvtObtain.limited, SvtObtain.story]) {
        if (card.extra.obtains.contains(obtain)) {
          texts.add(Transl.svtObtain(obtain).l);
          break;
        }
      }
    }

    return InkWell(
      onTap: () {
        card.routeTo();
      },
      child: ImageWithText(
        image: db.getIconImage(card.borderedIcon, aspectRatio: 132 / 144),
        text: texts.join('\n'),
        width: 56,
        textAlign: TextAlign.right,
        textStyle: const TextStyle(fontSize: 11),
        padding: const EdgeInsets.only(bottom: 0, left: 15, right: 4),
      ),
    );
  }

  static String _removeDoubleTrailing(double weight) {
    String s = double.parse(weight.toStringAsFixed(5)).toStringAsFixed(4);
    if (s.contains('.')) {
      s = s.replaceFirst(RegExp(r'\.?0+$'), '');
    }
    return s;
  }

  static String? castBracket(String? s) {
    return s?.replaceAll('〔', '(').replaceAll('〕', ')');
  }

  static String summonNameLocalize(String origin) {
    List<String> names =
        castBracket(origin.replaceAll('・', '·'))?.split('+') ?? [];
    return names.map((e) {
      String name2 = db.gameData.servants.values
              .firstWhereOrNull((svt) =>
                  castBracket(svt.extra.mcLink) == e ||
                  castBracket(svt.lName.cn) == e)
              ?.lName
              .l ??
          e;
      if (name2 == e &&
          SvtClass.values
              .every((cls) => cls.name.toLowerCase() != e.toLowerCase())) {
        List<String> fragments = e.split('(');
        fragments[0] = fragments[0].trim();
        fragments[0] = db.gameData.servants.values
                .firstWhereOrNull((svt) =>
                    castBracket(svt.extra.mcLink) == fragments[0] ||
                    castBracket(svt.lName.cn) == fragments[0] ||
                    svt.extra.nicknames.cn?.contains(fragments[0]) == true)
                ?.lName
                .l ??
            e;
        name2 = fragments.join('(');
      }
      // if (!RegExp(r'[\s\da-zA-Z]+').hasMatch(name2) && !Language.isCN) {
      //   print(name2);
      // }
      return name2;
    }).join('+');
  }
}
