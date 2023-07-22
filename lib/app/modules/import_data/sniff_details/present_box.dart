import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/models/gamedata/toplogin.dart';
import 'package:chaldea/models/models.dart';
import 'package:chaldea/utils/utils.dart';
import 'package:chaldea/widgets/widgets.dart';

class SniffPresentBoxDetailPage extends StatelessWidget {
  final List<UserPresentBox> presents;
  const SniffPresentBoxDetailPage({super.key, required this.presents});

  @override
  Widget build(BuildContext context) {
    final presents = this.presents.toList();
    presents.sort2((e) => -e.createdAt);
    final counts = <int, int>{};
    for (final present in presents) {
      //  // servant/item
      if (present.giftType == 1 || present.giftType == 2) {
        counts.addNum(present.objectId, present.num);
      }
    }
    sortDict(counts, inPlace: true);

    List<Widget> children = [];
    if (presents.isEmpty) {
      children.add(Center(child: Text(S.current.empty_hint)));
    } else {
      children.add(TileGroup(
        header: S.current.total,
        children: [
          if (counts.isEmpty)
            const ListTile(title: Text('Only servant/ember/item are counted'))
          else
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Wrap(
                spacing: 4,
                runSpacing: 4,
                children: [
                  for (final entry in counts.entries)
                    GameCardMixin.anyCardItemBuilder(
                      context: context,
                      id: entry.key,
                      text: entry.value.format(),
                      width: 40,
                      aspectRatio: 132 / 144,
                    ),
                ],
              ),
            )
        ],
      ));
      children.add(SHeader(S.current.details));
      children.addAll(presents.map((e) => buildPresent(context, e)));
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(S.current.present_box),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 16),
        children: children,
      ),
    );
  }

  Widget buildPresent(BuildContext context, UserPresentBox present) {
    final gift = BaseGift(type: GiftType.fromId(present.giftType), objectId: present.objectId, num: present.num);
    return ListTile(
      dense: true,
      leading: gift.iconBuilder(context: context),
      title: Text('${gift.shownName} ×${gift.num}'),
      subtitle: Text([
        present.message,
        present.createdAt.sec2date().toStringShort(omitSec: true),
      ].join('\n')),
      tileColor: Theme.of(context).hoverColor,
      onTap: () {
        gift.routeTo();
      },
    );
  }
}
