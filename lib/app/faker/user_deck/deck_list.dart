import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import 'package:chaldea/app/app.dart';
import 'package:chaldea/app/battle/models/user.dart';
import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/models/gamedata/mst_data.dart';
import 'package:chaldea/models/models.dart';
import 'package:chaldea/utils/utils.dart';
import 'package:chaldea/widgets/material.dart';
import '../../modules/battle/formation/formation_card.dart';
import '../runtime.dart';
import 'deck_setup.dart';

class UserDeckListPage extends StatefulWidget {
  final FakerRuntime? runtime;
  final MasterDataManager mstData;
  final int? activeDeckId;
  final EventDeckRequestParam? eventDeckParam;
  final ValueChanged<UserDeckEntity>? onSelected;
  final ValueChanged<UserEventDeckEntity>? onEventDeckSelected;
  final bool enableEdit;

  const UserDeckListPage({
    super.key,
    this.runtime,
    required this.mstData,
    this.activeDeckId,
    this.eventDeckParam,
    this.onSelected,
    this.onEventDeckSelected,
    this.enableEdit = false,
  });

  @override
  State<UserDeckListPage> createState() => UserDeckListPageState();
}

class UserDeckListPageState extends State<UserDeckListPage> {
  late final mstData = widget.mstData;
  final scrollController = ScrollController();

  bool get isUseEventDeck => widget.eventDeckParam != null;

  List<UserDeckEntityBase> getDecks() {
    if (isUseEventDeck) {
      final eventDecks = mstData.userEventDeck.toList();
      eventDecks.sortByList((e) => [widget.eventDeckParam?.eventId == e.eventId ? 0 : 1, -e.eventId, e.deckNo]);
      return eventDecks;
    } else {
      final decks = mstData.userDeck.toList();
      decks.sort2((e) => e.deckNo);
      if (mstData.userSvtGrand.isNotEmpty) {
        final grandDeck = UserDeckEntity(
          id: 0,
          userId: mstData.user?.userId,
          deckNo: 0,
          name: 'Grand Servant',
          deckInfo: DeckServantEntity(
            svts: [
              for (final svt in mstData.userSvtGrand.toList()..sort2((e) => e.grandGraphId))
                DeckServantData(
                  id: svt.grandGraphId % 100,
                  userSvtId: svt.userSvtId,
                  userId: svt.userId,
                  svtId: svt.svtId,
                  userSvtEquipIds: [
                    svt.equipTarget1?.userSvtId,
                    svt.equipTarget2?.userSvtId,
                    svt.equipTarget3?.userSvtId,
                  ],
                  isFollowerSvt: false,
                  npcFollowerSvtId: 0,
                  followerType: null,
                  initPos: null,
                ),
            ],
            userEquipId: 0,
            waveSvts: [],
          ),
          cost: 0,
        );
        decks.insert(0, grandDeck);
      }
      return decks;
    }
  }

  @override
  void initState() {
    super.initState();

    int index = 0;
    final decks = getDecks();
    if (isUseEventDeck) {
      index = decks.indexWhere(
        (e) =>
            (e as UserEventDeckEntity).eventId == widget.eventDeckParam!.eventId &&
            e.deckNo == widget.eventDeckParam!.deckNo,
      );
    } else {
      index = decks.indexWhere((e) => (e as UserDeckEntity).id == widget.activeDeckId);
    }
    if (decks.isNotEmpty) {
      SchedulerBinding.instance.addPostFrameCallback((_) async {
        if (!scrollController.hasClients) return;
        await scrollController.animateTo(
          scrollController.position.guessPixelsAt(index, decks.length),
          duration: kTabScrollDuration,
          curve: Curves.easeInOutSine,
        );
      });
    }
  }

  bool isActiveDeck(UserDeckEntityBase deck) {
    return switch (deck) {
      UserDeckEntity() => deck.id == widget.activeDeckId,
      UserEventDeckEntity() =>
        deck.eventId == widget.eventDeckParam?.eventId && deck.deckNo == widget.eventDeckParam?.deckNo,
    };
  }

  @override
  Widget build(BuildContext context) {
    final decks = getDecks();
    final eventParam = widget.eventDeckParam;
    final noEventDeckFound = eventParam != null && !decks.any(isActiveDeck);
    return Scaffold(
      appBar: AppBar(title: Text(isUseEventDeck ? "Event ${eventParam!.eventId} Decks" : "User Decks")),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: scrollController,
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
              itemBuilder: (context, index) => switch (decks[index]) {
                UserDeckEntity deck => buildUserDeck(deck),
                UserEventDeckEntity deck => buildEventDeck(deck),
              },
              itemCount: decks.length,
            ),
          ),
          if (noEventDeckFound)
            SafeArea(
              child: OverflowBar(
                alignment: MainAxisAlignment.center,
                children: [
                  FilledButton(
                    onPressed: () async {
                      await router.pushPage(
                        UserDeckSetupPage.event(
                          runtime: widget.runtime!,
                          eventDeckParam: widget.eventDeckParam!,
                          newEventDeck: UserEventDeckEntity(
                            userId: mstData.user?.userId ?? 0,
                            eventId: eventParam.eventId,
                            deckNo: eventParam.deckNo,
                            deckInfo: DeckServantEntity.empty(
                              userEquipId: mstData.user?.userEquipId ?? mstData.userEquip.last.id,
                              eventDeckNoSupport:
                                  eventParam.questPhase?.flags.contains(QuestFlag.eventDeckNoSupport) == true,
                            ),
                          ),
                        ),
                      );
                      if (mounted) setState(() {});
                    },
                    child: Text('New Event Deck ${widget.eventDeckParam?.deckNo}'),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget buildUserDeck(UserDeckEntity deck) {
    final bool isGrand = deck.id == 0;
    List<Widget> buttons = [
      if (widget.enableEdit && widget.runtime != null && deck.id > 0 && !isGrand)
        FilledButton.tonal(
          onPressed: () async {
            await router.pushPage(UserDeckSetupPage(runtime: widget.runtime!, activeDeckId: deck.id));
            if (mounted) setState(() {});
          },
          child: Text(S.current.edit),
        ),
      if (widget.onSelected != null && deck.id > 0 && !isGrand)
        FilledButton(
          onPressed: () {
            Navigator.pop(context);
            widget.onSelected!(deck);
          },
          child: Text(S.current.select),
        ),
    ];
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        DividerWithTitle(
          titleWidget: Text(
            '[${deck.id}] No.${deck.deckNo} ${deck.name}',
            style: isActiveDeck(deck)
                ? TextStyle(color: Theme.of(context).colorScheme.errorContainer)
                : TextStyle(fontSize: Theme.of(context).textTheme.bodySmall?.fontSize),
          ),
        ),
        FormationCard(
          formation: BattleTeamFormationX.fromUserDeck(
            deckInfo: deck.deckInfo,
            mstData: mstData,
            maxSvtCount: isGrand ? 8 : null,
            questPhase: widget.eventDeckParam?.questPhase,
          ),
          userSvtCollections: mstData.userSvtCollection.lookup,
          showBond: true,
          maxSvtCount: isGrand ? 8 : null,
        ),
        if (buttons.isNotEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Wrap(spacing: 8, alignment: WrapAlignment.center, children: buttons),
          ),
      ],
    );
  }

  Widget buildEventDeck(UserEventDeckEntity deck) {
    final param = widget.eventDeckParam;
    List<Widget> buttons = [
      if (widget.enableEdit &&
          widget.runtime != null &&
          param != null &&
          deck.eventId == param.eventId &&
          deck.deckNo == param.deckNo)
        FilledButton.tonal(
          onPressed: () async {
            await router.pushPage(UserDeckSetupPage.event(runtime: widget.runtime!, eventDeckParam: param));
            if (mounted) setState(() {});
          },
          child: Text(S.current.edit),
        ),
      if (widget.onSelected != null)
        FilledButton(
          onPressed: () {
            Navigator.pop(context);
            widget.onEventDeckSelected!(deck);
          },
          child: Text(S.current.select),
        ),
    ];

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onTap: deck.eventId == 0
              ? null
              : () {
                  router.push(url: Routes.eventI(deck.eventId));
                },
          child: DividerWithTitle(
            titleWidget: Text(
              '${param?.eventId == deck.eventId ? "※ " : ""}[${deck.eventId}] No.${deck.deckNo}',
              style: isActiveDeck(deck)
                  ? TextStyle(color: Theme.of(context).colorScheme.errorContainer)
                  : TextStyle(fontSize: Theme.of(context).textTheme.bodySmall?.fontSize),
            ),
          ),
        ),
        FormationCard(
          formation: BattleTeamFormationX.fromUserDeck(
            deckInfo: deck.deckInfo,
            mstData: mstData,
            questPhase: widget.eventDeckParam?.questPhase,
          ),
          userSvtCollections: mstData.userSvtCollection.lookup,
          showBond: true,
        ),
        if (buttons.isNotEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Wrap(spacing: 8, alignment: WrapAlignment.center, children: buttons),
          ),
      ],
    );
  }
}

extension BattleTeamFormationX on BattleTeamFormation {
  static BattleTeamFormation fromBattleEntity({
    required BattleEntity battleEntity,
    required MasterDataManager mstData,
  }) {
    final userSvts = battleEntity.battleInfo?.userSvtMap ?? {};
    final userEquip = mstData.userEquip[battleEntity.battleInfo?.userEquipId];
    return BattleTeamFormation.fromList(
      mysticCode: MysticCodeSaveData(mysticCodeId: userEquip?.equipId, level: userEquip?.lv ?? 0),
      svts: List.generate(6, (i) {
        final svt = battleEntity.battleInfo?.myDeck?.svts.getOrNull(i);
        final userSvt = userSvts[svt?.userSvtId];
        final dbSvt = db.gameData.servantsById[userSvt?.svtId];
        if (userSvt == null) return null;

        final appendId2Num = {
          for (final passive in dbSvt?.appendPassive ?? <ServantAppendPassiveSkill>[]) passive.skill.id: passive.num,
        };
        final appendPassive2Lvs = <int, int>{
          for (final (index, skillId) in (userSvt.appendPassiveSkillIds ?? <int>[]).indexed)
            if (appendId2Num.containsKey(skillId))
              appendId2Num[skillId]!: userSvt.appendPassiveSkillLvs?.getOrNull(index) ?? 0,
        };

        SvtEquipSaveData? getEquipData(SvtEquipTarget equipTarget) {
          final userCE = userSvts[svt?.userSvtEquipIds?.getOrNull(equipTarget.value)];
          if (userCE == null) return null;
          bool limitBreak = false;

          if (userCE.limitCount == 0) {
            // may be zero even if MLB for support svt
            final skill = db.gameData.craftEssencesById[userCE.svtId]?.skills.firstWhereOrNull(
              (e) => e.id == userCE.skillId1,
            );
            if (skill != null && skill.condLimitCount == 4) {
              limitBreak = true;
            }
          } else {
            limitBreak = userCE.limitCount == 4;
          }
          return SvtEquipSaveData(id: userCE.svtId, lv: userCE.lv, limitBreak: limitBreak);
        }

        return SvtSaveData(
          svtId: userSvt.svtId,
          limitCount: userSvt.dispLimitCount,
          skillLvs: [userSvt.skillLv1, userSvt.skillLv2, userSvt.skillLv3],
          skillIds: [userSvt.skillId1, userSvt.skillId2, userSvt.skillId3],
          appendLvs: kAppendSkillNums.map((skillNum) => appendPassive2Lvs[skillNum + 99] ?? 0).toList(),
          tdId: userSvt.treasureDeviceId,
          tdLv: userSvt.treasureDeviceLv ?? 0,
          lv: userSvt.lv,
          // atkFou,
          // hpFou,
          // fixedAtk,
          // fixedHp,
          equip1: getEquipData(SvtEquipTarget.normal),
          equip2: getEquipData(SvtEquipTarget.bond),
          equip3: getEquipData(SvtEquipTarget.reward),
          supportType: SupportSvtType.fromFollowerType(svt?.followerType ?? 0),
          cardStrengthens: null,
          commandCodeIds: null,
          grandSvt: userSvt.grandSvt == 1,
        );
      }),
    );
  }

  static BattleTeamFormation fromUserDeck({
    required DeckServantEntity? deckInfo,
    required MasterDataManager mstData,
    int posOffset = 0,
    int? maxSvtCount,
    QuestPhase? questPhase,
  }) {
    final userEquip = mstData.userEquip.firstWhereOrNull((e) => e.id == deckInfo?.userEquipId);
    final svts = deckInfo?.svts ?? [];
    final svtsMap = {for (final svt in svts) svt.id: svt};

    SvtSaveData? cvtSvt(DeckServantData? svtData) {
      if (svtData == null) return null;
      if (svtData.userSvtId == 0) {
        final npc = questPhase?.supportServants.firstWhereOrNull((support) {
          if (svtData.npcFollowerSvtId != 0 && support.npcSvtFollowerId == svtData.npcFollowerSvtId) return true;
          // fixed NPC only shown in edit mode?
          if (support.script?.eventDeckIndex == svtData.id) return true;
          return false;
        });
        // is npc
        if (npc != null) {
          final npcEquip = npc.equips.firstOrNull;
          return SvtSaveData(
            svtId: npc.svt.id,
            limitCount: npc.limit.limitCount,
            lv: npc.lv,
            skillIds: npc.skills.skillIds.toList(),
            skillLvs: npc.skills.skillLvs.map((e) => e ?? 0).toList(),
            tdLv: npc.noblePhantasm.noblePhantasmLv,
            supportType: SupportSvtType.npc,
            equip1: SvtEquipSaveData(
              id: npcEquip?.equip.id,
              lv: npcEquip?.lv ?? 1,
              limitBreak: npcEquip?.limitCount == 4,
            ),
          );
        }

        // is fiend support
        if (svtData.isFollowerSvt) {
          // assert(svtData.npcFollowerSvtId == 0);
          return SvtSaveData(
            supportType: SupportSvtType.friend,
            svtId: svtData.svtId,
            equip1: SvtEquipSaveData(id: svtData.svtEquipIds?.firstOrNull),
          );
        }
      }

      final userSvt = mstData.userSvt[svtData.userSvtId];
      if (userSvt == null) return null;

      SvtEquipSaveData? getEquipData(SvtEquipTarget equipTarget) {
        final userCE = mstData.userSvt[svtData.userSvtEquipIds.getOrNull(equipTarget.value)];
        if (userCE != null) {
          return SvtEquipSaveData(id: userCE.svtId, lv: userCE.lv, limitBreak: userCE.limitCount == 4);
        }
        return null;
      }

      return SvtSaveData(
        svtId: userSvt.svtId,
        limitCount: userSvt.dispLimitCount,
        skillLvs: [userSvt.skillLv1, userSvt.skillLv2, userSvt.skillLv3],
        skillIds: [null, null, null],
        appendLvs: mstData.getSvtAppendSkillLvs(userSvt),
        tdId: 0,
        tdLv: userSvt.treasureDeviceLv1,
        lv: userSvt.lv,
        atkFou: userSvt.adjustAtk * 10,
        hpFou: userSvt.adjustHp * 10,
        // fixedAtk,
        // fixedHp,
        equip1: getEquipData(SvtEquipTarget.normal),
        equip2: getEquipData(SvtEquipTarget.bond),
        equip3: getEquipData(SvtEquipTarget.reward),
        supportType: SupportSvtType.none,
        cardStrengthens: null,
        commandCodeIds: null,
        //  disabledExtraSkills,
        //  customPassives,
        //  customPassiveLvs,
        grandSvt: mstData.userSvtGrand.any((e) => e.userSvtId == userSvt.id),
      );
    }

    return BattleTeamFormation(
      svts: List.generate(maxSvtCount ?? deckInfo?.svts.length ?? 6, (index) => cvtSvt(svtsMap[index + 1 + posOffset])),
      mysticCode: MysticCodeSaveData(mysticCodeId: userEquip?.equipId, level: userEquip?.lv ?? 1),
    );
  }
}
