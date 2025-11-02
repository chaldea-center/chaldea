import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'package:chaldea/app/app.dart';
import 'package:chaldea/app/modules/quest/quest_list.dart';
import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/models/gamedata/mst_data.dart';
import 'package:chaldea/models/models.dart';
import 'package:chaldea/utils/utils.dart';
import 'package:chaldea/widgets/widgets.dart';
import '../gacha/gacha_draw.dart';
import '../mission/mission_receive.dart';
import '../present_box/present_box.dart';
import '../runtime.dart';
import '../shop/shop.dart';

class FakerReminders extends StatelessWidget {
  final FakerRuntime runtime;
  final MasterDataManager mstData;
  FakerReminders({super.key, required this.runtime}) : mstData = runtime.mstData;

  @override
  Widget build(BuildContext context) {
    if (!mstData.isLoggedIn) return const SizedBox.shrink();

    final now = DateTime.now().timestamp;
    List<Widget> children = [
      ...getGachas(context, now),
      ...getShops(context, now),
      ...getMissions(context, now),
      ...getPresents(context, now),
      ...getQuests(context, now),
      ...getOthers(context, now),
    ];

    if (children.isEmpty) return const SizedBox.shrink();
    return TileGroup(header: S.current.hint, children: children);
  }

  Iterable<Widget> getGachas(BuildContext context, int now) sync* {
    const conflictGachaGroups = [
      [2, 3],
      [4, 5],
    ];
    for (final gacha in runtime.gameData.timerData.gachas.values) {
      if (gacha.freeDrawFlag == 0 || gacha.openedAt > now || gacha.closedAt <= now) continue;
      if (conflictGachaGroups.any((group) {
        return group.contains(gacha.id) &&
            group.any((gachaId) => gachaId != gacha.id && mstData.userGacha[gachaId] != null);
      })) {
        continue;
      }
      int resetHourUTC;
      switch (gacha.gachaType) {
        case GachaType.freeGacha:
          resetHourUTC = runtime.region.fpFreeGachaResetUTC;
        case GachaType.payGacha:
          resetHourUTC = runtime.region.storyFreeGachaResetUTC;
        default:
          continue;
      }
      int? nextFreeDrawAt;
      final userGacha = mstData.userGacha[gacha.id];
      nextFreeDrawAt = DateTimeX.findNextHourAt(userGacha?.freeDrawAt ?? gacha.openedAt, resetHourUTC);
      bool hasFreeDraw = nextFreeDrawAt < now;
      if (!hasFreeDraw) continue;

      yield ListTile(
        dense: true,
        title: Text('[${gacha.id}] ${gacha.lName}'),
        subtitle: Text(
          'Free ${userGacha?.freeDrawAt.sec2date().toCustomString(year: false)}'
          ' → ${nextFreeDrawAt.sec2date().toCustomString(year: false)}',
        ),
        trailing: TextButton(
          onPressed: hasFreeDraw
              ? () {
                  if (runtime.runningTask.value) return;
                  runtime.agent.user.gacha.gachaId = gacha.id;
                  router.pushPage(GachaDrawPage(runtime: runtime));
                }
              : null,
          child: Text(S.current.summon),
        ),
      );
    }
  }

  List<Widget> getShops(BuildContext context, int now) {
    List<Widget> children = [];
    List<NiceShop> _shownShops = [];
    for (final shop in runtime.gameData.timerData.shops.values) {
      if (shop.openedAt > now || now >= shop.closedAt) continue;
      final userShop = mstData.userShop[shop.id];
      if (userShop != null && userShop.num >= shop.limitNum) continue;
      final targetIds = shop.getItemAndCardIds().where((targetId) {
        if (runtime.agent.user.shopTargetIds.contains(targetId)) return true;
        final item = runtime.gameData.teapots[targetId] ?? db.gameData.items[targetId];
        if (item != null) {
          if (item.type == ItemType.friendshipUpItem || item.type == ItemType.stormpod) return true;
          if (shop.shopType == ShopType.mana && item.type == ItemType.commandCardPrmUp) return true;
        }
        final entity = db.gameData.entities[targetId];
        if (entity != null) {
          if (entity.flags.contains(SvtFlag.svtEquipManaExchange)) return true;
          if (shop.shopType == ShopType.mana && entity.type == SvtType.statusUp && entity.rarity >= 4) return true;
        }
        return false;
      }).toSet();
      if (targetIds.isEmpty) continue;
      _shownShops.add(shop);
      children.add(
        ListTile(
          dense: true,
          leading: GameCardMixin.anyCardItemBuilder(context: context, id: targetIds.first, width: 32),
          title: Text(shop.name),
          subtitle: Text.rich(
            TextSpan(
              children: [
                CenterWidgetSpan(
                  child: Item.iconBuilder(
                    context: context,
                    item: shop.cost?.item,
                    width: 16,
                    text: shop.setNum > 1 ? '×${shop.setNum}' : null,
                  ),
                ),
                TextSpan(text: ' ${shop.cost?.amount}'),
                if (shop.limitNum > 1) TextSpan(text: '×${shop.limitNum}'),
                TextSpan(text: ',  ${shop.closedAt.sec2date().toCustomString(year: false, second: false)}'),
              ],
            ),
          ),
          trailing: Text('${userShop?.num ?? 0}/${shop.limitNum}'),
          onTap: () {
            router.pushPage(UserShopsPage(runtime: runtime, title: S.current.shop, shops: _shownShops));
          },
        ),
      );
    }
    return children;
  }

  Iterable<Widget> getMissions(BuildContext context, int now) sync* {
    const int _kMissionWarningDay = 2;
    for (final mm in runtime.gameData.timerData.masterMissions.values) {
      if (const [MissionType.none, MissionType.daily].contains(mm.type)) continue;
      if (mm.missions.isEmpty) continue;
      if (mm.closedAt < now || mm.startedAt > now || mm.endedAt - now > _kMissionWarningDay * kSecsPerDay) continue;
      Map<MissionProgressType, int> progresses = {};
      for (final mission in mm.missions) {
        final int progress =
            mstData.userEventMission[mission.id]?.missionProgressType ?? MissionProgressType.none.value;
        progresses.addNum(MissionProgressType.fromValue(progress), 1);
      }
      bool needWarning = mm.endedAt > now
          ? progresses.keys.any((e) => e != MissionProgressType.achieve)
          : progresses.containsKey(MissionProgressType.clear);
      if (needWarning) {
        String subtitle = [
          mm.endedAt.sec2date().toCustomString(year: false, second: false),
          for (final type in progresses.keys.toList()..sort2((e) => e.value)) '${type.name} ${progresses[type]}',
        ].join(', ');

        yield ListTile(
          leading: const FaIcon(FontAwesomeIcons.listCheck, size: 18),
          title: Text('[${Transl.enums(mm.type, (e) => e.missionType).l}] ${mm.getDispName()}'),
          subtitle: Text(subtitle),
          trailing: Icon(DirectionalIcons.keyboard_arrow_forward(context)),
          onTap: () {
            router.pushPage(UserEventMissionReceivePage(runtime: runtime, initId: mm.id));
          },
        );
      }
    }
  }

  Iterable<Widget> getPresents(BuildContext context, int now) sync* {
    for (final present in mstData.userPresentBox) {
      final expireAt = present.getExpireAt(runtime.gameData.timerData.items[present.objectId]);
      if (expireAt < now + 30 * kSecsPerDay) {
        final gift = present.toGift();

        yield ListTile(
          leading: Icon(Icons.card_giftcard),
          title: Text.rich(
            TextSpan(
              children: [
                CenterWidgetSpan(child: gift.iconBuilder(context: context, width: 24)),
                TextSpan(text: ' ${gift.shownName} ×${gift.num}'),
              ],
            ),
          ),
          subtitle: Text(expireAt.sec2date().toCustomString()),
          trailing: Icon(DirectionalIcons.keyboard_arrow_forward(context)),
          onTap: () => router.pushPage(UserPresentBoxManagePage(runtime: runtime)),
        );
      }
    }
  }

  Iterable<Widget> getQuests(BuildContext context, int now) sync* {
    Map<int, Servant> svtQuests = {
      for (final svt in db.gameData.servantsNoDup.values)
        for (final questId in svt.relateQuestIds) questId: svt,
    };
    bool _isQuestNeedClear(int questId, {Quest? quest, bool checkSvt = true}) {
      if (mstData.isQuestCleared(questId)) return false;
      quest ??= db.gameData.quests[questId];
      if (quest != null) {
        final war = quest.war;
        if (quest.type == QuestType.main &&
            war != null &&
            war.lastQuestId != 0 &&
            mstData.isQuestCleared(war.lastQuestId)) {
          return false;
        }
        if (quest.flags.contains(QuestFlag.branch) || quest.flags.contains(QuestFlag.branchScenario)) {
          return false;
        }
      }
      final svt = svtQuests[questId];
      if (checkSvt && svt != null) {
        if (mstData.userSvtCollection[svt.id]?.isOwned != true) return false;
      }
      return true;
    }

    // interlude campaign
    final interludeCampaignIds = {
      for (final event in runtime.gameData.timerData.events.values)
        if (event.type == EventType.interludeCampaign && event.startedAt <= now && event.endedAt > now) event.id,
    };
    if (interludeCampaignIds.isNotEmpty) {
      for (final quest in db.gameData.quests.values) {
        if (quest.releaseOverwrites.every((e) => !interludeCampaignIds.contains(e.eventId))) continue;
        final userQuest = mstData.userQuest[quest.id];
        if (userQuest != null && userQuest.clearNum > 0) continue;
        final interludeSvt =
            db.gameData.servantsById[quest.releaseConditions
                .firstWhereOrNull((release) => const [CondType.svtGet, CondType.svtFriendship].contains(release.type))
                ?.targetId];
        // 谜之女主角X: 遭難者Ｘの帰還
        if (quest.id == 91601804 && const [94054830, 94041930].any(mstData.isQuestCleared)) {
          continue;
        }
        yield ListTile(
          dense: true,
          leading: interludeSvt?.iconBuilder(context: context),
          title: Text('[${S.current.interlude}] ${quest.lName.l}', maxLines: 1, overflow: TextOverflow.ellipsis),
          subtitle: Text('${quest.id}: phase ${userQuest?.questPhase ?? "-"} clear ${userQuest?.clearNum ?? "-"}'),
          trailing: IconButton(
            onPressed: () {
              copyToClipboard(quest.id.toString(), toast: true);
            },
            icon: Icon(Icons.copy),
          ),
          onTap: quest.routeTo,
        );
      }
    }

    // event quests
    for (final event in runtime.gameData.timerData.events.values) {
      if (event.startedAt > now || event.endedAt <= now) continue;
      final hasMap = event.warIds.where((e) => db.gameData.wars[e]?.maps.isNotEmpty == true).isNotEmpty;
      if (hasMap && event.endedAt > now + 7 * kSecsPerDay) continue;
      Set<int> questIds = {...?db.gameData.others.eventQuestGroups[event.id]};
      for (final warId in event.warIds) {
        final war = db.gameData.wars[warId];
        if (war == null) continue;
        for (final quest in war.quests) {
          questIds.add(quest.id);
        }
        for (final selection in war.questSelections) {
          questIds.add(selection.quest.id);
        }
      }
      questIds.retainWhere((questId) => _isQuestNeedClear(questId));
      if (questIds.isEmpty) continue;
      yield ListTile(
        dense: true,
        leading: Icon(Icons.flag),
        title: Text(event.lShortName.l, overflow: TextOverflow.ellipsis),
        subtitle: Text(
          '${questIds.length} uncleared quests, ${event.endedAt.sec2date().toCustomString(year: false, second: false)}',
        ),
        trailing: IconButton(
          onPressed: () => event.routeTo(region: runtime.region),
          icon: Icon(DirectionalIcons.keyboard_arrow_forward(context)),
        ),
        onTap: () {
          router.pushPage(QuestListPage.ids(ids: questIds.toList(), mstData: mstData));
        },
      );
    }

    // quest campaign
    for (final event in runtime.gameData.timerData.events.values) {
      if (event.startedAt > now || event.endedAt <= now) continue;
      for (final campaign in event.campaigns) {
        if (!const [
          CombineAdjustTarget.questAp,
          CombineAdjustTarget.questApFirstTime,
          CombineAdjustTarget.questItemFirstTime,
        ].contains(campaign.target)) {
          continue;
        }
        final questIds = [
          for (final campaignQuest in event.campaignQuests)
            if (!campaignQuest.isExcepted && campaignQuest.questId != 0) campaignQuest.questId,
        ];
        final uncleared = questIds.where((questId) {
          if (!_isQuestNeedClear(questId)) return false;
          final jpQuest = db.gameData.quests[questId];
          if (jpQuest != null) {
            if (jpQuest.warId == WarId.daily) return false;
          }
          return true;
        }).toList();
        // final uncleared = questIds.take(10).toList();
        if (uncleared.isEmpty) continue;

        yield ListTile(
          dense: true,
          leading: Icon(Icons.map),
          title: Text(event.lShortName.l, maxLines: 1, overflow: TextOverflow.ellipsis),
          subtitle: Text(
            '${uncleared.length}/${questIds.length} uncleared, ${event.endedAt.sec2date().toCustomString(year: false, second: false)}',
          ),
          trailing: IconButton(
            onPressed: () => event.routeTo(region: runtime.region),
            icon: Icon(DirectionalIcons.keyboard_arrow_forward(context)),
          ),
          onTap: () {
            router.pushPage(QuestListPage.ids(ids: uncleared, mstData: mstData));
          },
        );
      }
    }

    // no war event quests
    final timerQuests = runtime.gameData.timerData.quests.values
        .where((quest) => quest.openedAt <= now && quest.closedAt > now && !mstData.isQuestCleared(quest.id))
        .toList();
    if (timerQuests.isNotEmpty) {
      yield ListTile(
        dense: true,
        leading: Icon(Icons.flag),
        title: Text('Event quests', maxLines: 1, overflow: TextOverflow.ellipsis),
        subtitle: Text(
          '${timerQuests.length} uncleared quests, ${Maths.min(timerQuests.map((e) => e.closedAt)).sec2date().toCustomString(year: false, second: false)}',
        ),
        onTap: () {
          router.pushPage(QuestListPage(quests: timerQuests, mstData: mstData));
        },
      );
    }
  }

  List<Widget> getOthers(BuildContext context, int now) {
    List<Widget> children = [];

    final userCoinRoom = mstData.userCoinRoom.firstOrNull;
    const int maxCoinRoomNum = 2;
    if (userCoinRoom != null && userCoinRoom.num < maxCoinRoomNum) {
      children.add(
        ListTile(
          leading: Item.iconBuilder(context: context, item: Items.grail, width: 32),
          title: Text('聖杯鋳造'),
          trailing: Text(
            [
              '${userCoinRoom.num}/$maxCoinRoomNum/${userCoinRoom.totalNum}',
              if (userCoinRoom.cnt != 0) '${S.current.servant_coin_short} ${userCoinRoom.cnt}',
            ].join('\n'),
            textAlign: TextAlign.end,
          ),
        ),
      );
    }
    return children;
  }
}
