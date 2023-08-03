import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/models/gamedata/toplogin.dart';
import 'package:chaldea/models/models.dart';
import 'package:chaldea/utils/utils.dart';
import 'package:chaldea/widgets/widgets.dart';

class SniffPresentBoxDetailPage extends StatelessWidget {
  final List<UserPresentBox> presents;
  final List<UserEventMission> missions;
  final List<UserItem> items;
  final UserGame? userGame;
  const SniffPresentBoxDetailPage(
      {super.key, required this.presents, required this.missions, required this.items, required this.userGame});

  @override
  Widget build(BuildContext context) {
    final Map<int, int> ownedItems = {}, missionItems = {}, presentItems = {};

    // present box
    final presents = this.presents.toList();
    presents.sort2((e) => -e.createdAt);
    for (final present in presents) {
      //  // servant/item
      if (present.giftType == 1 || present.giftType == 2) {
        presentItems.addNum(present.objectId, present.num);
      }
    }

    // extra mission
    final extraMissions = {
      for (final m in db.gameData.extraMasterMission[MasterMission.kExtraMasterMissionId]?.missions ?? <EventMission>[])
        m.id: m,
    };
    for (final mission in missions) {
      if (mission.missionProgressType != MissionProgressType.clear.id) continue;
      final eventMission = extraMissions[mission.missionId];
      if (eventMission == null) continue;
      Gift.checkAddGifts(missionItems, eventMission.gifts);
    }

    // own items
    for (final item in items) {
      if (const [
        Items.summonTicketId,
        Items.quartzFragmentId,
      ].contains(item.itemId)) {
        ownedItems[item.itemId] = item.num;
      }
    }
    if (userGame != null) {
      ownedItems[Items.stoneId] = userGame!.stone;
    }
    final allItems = Maths.sumDict([presentItems, missionItems, ownedItems]);
    final summonCount = Maths.sum([
      (allItems[Items.stoneId] ?? 0) / 3,
      (allItems[Items.quartzFragmentId] ?? 0) / 7 / 3,
      allItems[Items.summonTicketId] ?? 0,
    ]);

    List<Widget> children = [];
    children.addAll([
      oneGroup(context, S.current.present_box, presentItems),
      oneGroup(context, '${S.current.master_mission}(Extra, cleared but not claimed)', missionItems),
      oneGroup(context, '${S.current.item_own}(Summon items only)', ownedItems),
      oneGroup(
          context, '${S.current.total}: ${summonCount.toStringAsFixed(1)} ${S.current.summon_pull_unit}', allItems),
    ]);
    children.add(SHeader('${S.current.details}(${S.current.present_box})'));
    children.addAll(presents.map((e) => buildPresent(context, e)));

    return Scaffold(
      appBar: AppBar(title: Text(S.current.present_box)),
      body: ListView(children: children),
    );
  }

  Widget oneGroup(BuildContext context, String header, Map<int, int> items) {
    items = sortDict(items);
    return TileGroup(
      header: header,
      padding: EdgeInsets.zero,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: Wrap(
            spacing: 4,
            runSpacing: 4,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              if (items.isEmpty) const Text('NONE'),
              for (final entry in items.entries)
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
