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
    final grid = Wrap(
      spacing: 4,
      runSpacing: 4,
      children: block.ids.map((id) {
        Widget child;
        if (block.isSvt) {
          final svt = db.gameData.servantsNoDup[id];
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
        return child;
      }).toList(),
    );
    if (!showRarity) {
      return grid;
    } else {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SHeader(
            '$kStarChar${block.rarity}',
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
    double? width,
    String? extraText,
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
          width: width,
          extraText: extraText,
        ),
        if (favorite || star)
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (favorite)
                Container(
                  padding: const EdgeInsets.all(1.5),
                  margin: const EdgeInsets.only(bottom: 1),
                  decoration: BoxDecoration(color: Colors.blueAccent, borderRadius: BorderRadius.circular(3)),
                  child: const Icon(
                    Icons.favorite,
                    color: Colors.white,
                    size: 10,
                  ),
                ),
              if (star)
                Container(
                  padding: const EdgeInsets.all(1.5),
                  decoration: BoxDecoration(color: Colors.blueAccent[400], borderRadius: BorderRadius.circular(3)),
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
    double? width,
    String? extraText,
  }) {
    if (card == null) return Container();
    List<String> texts = [];
    if (extraText != null) {
      texts.add(extraText);
    }
    if (showNpLv && card is Servant && card.status.cur.favorite) {
      texts.add('NP${card.status.cur.npLv}');
    }

    if (weight != null) {
      texts.add('${_removeDoubleTrailing(weight)}%');
    }
    if (showCategory && card is Servant) {
      for (final obtain in [SvtObtain.limited, SvtObtain.story]) {
        if (card.obtains.contains(obtain)) {
          texts.add(Transl.svtObtain(obtain).l);
          break;
        }
      }
    }
    width ??= 56;
    return InkWell(
      onTap: () {
        card.routeTo();
      },
      child: ImageWithText(
        image: db.getIconImage(card.borderedIcon, width: width, aspectRatio: 132 / 144),
        text: texts.join('\n'),
        option: ImageWithTextOption(
          width: width,
          fontSize: width * 0.2,
          textAlign: TextAlign.right,
          textStyle: const TextStyle(fontSize: 12),
        ),
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
    List<String> names = castBracket(origin.replaceAll('・', '·'))?.split('+') ?? [];
    return names.map((e) {
      String name2 = db.gameData.servantsNoDup.values
              .firstWhereOrNull((svt) => castBracket(svt.extra.mcLink) == e || castBracket(svt.lName.cn) == e)
              ?.lName
              .l ??
          e;
      if (name2 == e && SvtClass.values.every((cls) => cls.name.toLowerCase() != e.toLowerCase())) {
        List<String> fragments = e.split('(');
        fragments[0] = fragments[0].trim();
        fragments[0] = db.gameData.servantsNoDup.values
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
