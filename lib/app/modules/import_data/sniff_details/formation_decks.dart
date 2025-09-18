import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import 'package:chaldea/app/app.dart';
import 'package:chaldea/app/battle/models/user.dart';
import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/models/gamedata/toplogin.dart';
import 'package:chaldea/models/models.dart';
import 'package:chaldea/utils/extension.dart';
import 'package:chaldea/widgets/material.dart';
import '../../battle/formation/formation_card.dart';

class UserFormationDecksPage extends StatefulWidget {
  final MasterDataManager mstData;
  final int? selectedDeckId;
  final int? eventId;
  final ValueChanged<UserDeckEntity>? onSelected;
  final ValueChanged<UserEventDeckEntity>? onEventDeckSelected;
  const UserFormationDecksPage({
    super.key,
    required this.mstData,
    this.selectedDeckId,
    this.eventId,
    this.onSelected,
    this.onEventDeckSelected,
  });

  @override
  State<UserFormationDecksPage> createState() => UserFormationDecksPageState();
}

class UserFormationDecksPageState extends State<UserFormationDecksPage> {
  late final mstData = widget.mstData;
  late final userSvts = {for (final svt in mstData.userSvt.followedBy(mstData.userSvtStorage)) svt.id: svt};
  final scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    if (widget.selectedDeckId != null && widget.eventId == null) {
      final index = mstData.userDeck.list.indexWhere((e) => e.id == widget.selectedDeckId);
      if (index > 0) {
        SchedulerBinding.instance.addPostFrameCallback((_) async {
          double pos = scrollController.position.extentAfter * (index + 1) / mstData.userDeck.length - 16;
          if (pos > 0) {
            await scrollController.animateTo(pos, duration: kTabScrollDuration, curve: Curves.easeInOutSine);
          }
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final decks = mstData.userDeck.list;
    final eventDecks = mstData.userEventDeck.list;
    eventDecks.sortByList((e) => [widget.eventId == e.eventId ? 0 : 1, -e.eventId, e.deckNo]);
    UserDeckEntity? grandDeck;
    if (widget.eventId == null && mstData.userSvtGrand.isNotEmpty) {
      grandDeck = UserDeckEntity(
        id: 0,
        userId: mstData.user?.userId,
        deckNo: 0,
        name: 'Grand Servant',
        deckInfo: DeckServantEntity(
          svts: [
            for (final svt in mstData.userSvtGrand.list..sort2((e) => e.grandGraphId))
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
    }
    if (grandDeck != null) decks.insert(0, grandDeck);
    return Scaffold(
      appBar: AppBar(title: Text(widget.eventId == null ? "User Decks" : "Event ${widget.eventId} Decks")),
      body: ListView.builder(
        controller: scrollController,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
        itemBuilder: (context, index) => widget.eventId == null
            ? buildUserDeck(decks[index], decks[index] == grandDeck)
            : buildEventDeck(eventDecks[index]),
        itemCount: widget.eventId == null ? decks.length : eventDecks.length,
      ),
    );
  }

  Widget buildUserDeck(UserDeckEntity deck, bool isGrand) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        DividerWithTitle(title: '[${deck.id}] No.${deck.deckNo} ${deck.name}'),
        FormationCard(
          formation: BattleTeamFormationX.fromUserDeck(
            deckInfo: deck.deckInfo,
            mstData: mstData,
            userSvts: userSvts,
            maxSvtCount: isGrand ? 8 : null,
          ),
          userSvtCollections: mstData.userSvtCollection.dict,
          showBond: true,
          maxSvtCount: isGrand?8:null,
        ),
        if (widget.onSelected != null && deck.id > 0)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Center(
              child: FilledButton(
                onPressed: () {
                  Navigator.pop(context);
                  widget.onSelected!(deck);
                },
                child: Text(S.current.select),
              ),
            ),
          ),
      ],
    );
  }

  Widget buildEventDeck(UserEventDeckEntity deck) {
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
            title: '${widget.eventId == deck.eventId ? "※ " : ""}[${deck.eventId}] No.${deck.deckNo}',
          ),
        ),
        FormationCard(
          formation: BattleTeamFormationX.fromUserDeck(deckInfo: deck.deckInfo, mstData: mstData, userSvts: userSvts),
          userSvtCollections: mstData.userSvtCollection.dict,
          showBond: true,
        ),
        if (widget.onSelected != null)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Center(
              child: FilledButton(
                onPressed: () {
                  Navigator.pop(context);
                  widget.onEventDeckSelected!(deck);
                },
                child: Text(S.current.select),
              ),
            ),
          ),
      ],
    );
  }

  late final userSvtCommandCards = {for (final card in mstData.userSvtCommandCard) card.svtId: card};
}

extension BattleTeamFormationX on BattleTeamFormation {
  static BattleTeamFormation fromBattleEntity({
    required BattleEntity battleEntity,
    required MasterDataManager mstData,
  }) {
    final userSvts = {for (final svt in battleEntity.battleInfo?.userSvt ?? <BattleUserServantData>[]) svt.id: svt};
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
    Map<int, UserServantEntity>? userSvts,
    int posOffset = 0,
    int? maxSvtCount,
  }) {
    final userEquip = mstData.userEquip.firstWhereOrNull((e) => e.id == deckInfo?.userEquipId);
    final svts = deckInfo?.svts ?? [];
    final svtsMap = {for (final svt in svts) svt.id: svt};
    userSvts ??= {for (final svt in mstData.userSvt.followedBy(mstData.userSvtStorage)) svt.id: svt};

    SvtSaveData? cvtSvt(DeckServantData? svtData) {
      final userSvt = userSvts![svtData?.userSvtId];
      if (svtData == null || userSvt == null || svtData.isFollowerSvt == true) return null;

      SvtEquipSaveData? getEquipData(SvtEquipTarget equipTarget) {
        final userCE = userSvts?[svtData.userSvtEquipIds.getOrNull(equipTarget.value)];
        if (userCE == null) return null;
        return SvtEquipSaveData(id: userCE.svtId, lv: userCE.lv, limitBreak: userCE.limitCount == 4);
      }

      return SvtSaveData(
        svtId: userSvt.svtId,
        limitCount: userSvt.dispLimitCount,
        skillLvs: [userSvt.skillLv1, userSvt.skillLv2, userSvt.skillLv3],
        skillIds: [null, null, null],
        appendLvs: mstData.getSvtAppendSkillLv(userSvt),
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
