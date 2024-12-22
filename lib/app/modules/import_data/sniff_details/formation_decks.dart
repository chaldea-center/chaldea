import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import 'package:chaldea/app/app.dart';
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
  const UserFormationDecksPage(
      {super.key, required this.mstData, this.selectedDeckId, this.eventId, this.onSelected, this.onEventDeckSelected});

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
          final pos = scrollController.position.extentAfter * (index + 1) / mstData.userDeck.length;
          await scrollController.animateTo(pos, duration: kTabScrollDuration, curve: Curves.easeInOutSine);
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final decks = mstData.userDeck.list;
    final eventDecks = mstData.userEventDeck.list;
    eventDecks.sortByList((e) => [widget.eventId == e.eventId ? 0 : 1, -e.eventId, e.deckNo]);
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.eventId == null ? "User Decks" : "Event ${widget.eventId} Decks"),
      ),
      body: ListView.builder(
        controller: scrollController,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
        itemBuilder: (context, index) =>
            widget.eventId == null ? buildUserDeck(decks[index]) : buildEventDeck(eventDecks[index]),
        itemCount: widget.eventId == null ? decks.length : eventDecks.length,
      ),
    );
  }

  Widget buildUserDeck(UserDeckEntity deck) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        DividerWithTitle(title: '[${deck.id}] No.${deck.deckNo} ${deck.name}'),
        FormationCard(
          formation: UserDeckEntityX.toFormation(deckInfo: deck.deckInfo, mstData: mstData, userSvts: userSvts),
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
                  widget.onSelected!(deck);
                },
                child: Text(S.current.select),
              ),
            ),
          )
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
              title: '${widget.eventId == deck.eventId ? "※ " : ""}[${deck.eventId}] No.${deck.deckNo}'),
        ),
        FormationCard(
          formation: UserDeckEntityX.toFormation(deckInfo: deck.deckInfo, mstData: mstData, userSvts: userSvts),
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
          )
      ],
    );
  }

  late final userSvtCommandCards = {for (final card in mstData.userSvtCommandCard) card.svtId: card};
}

extension UserDeckEntityX on UserDeckEntity {
  static BattleTeamFormation toFormation(
      {required DeckServantEntity? deckInfo,
      required MasterDataManager mstData,
      Map<int, UserServantEntity>? userSvts}) {
    final userEquip = mstData.userEquip.firstWhereOrNull((e) => e.id == deckInfo?.userEquipId);
    final svts = deckInfo?.svts ?? [];
    final svtsMap = {for (final svt in svts) svt.id: svt};
    userSvts ??= {for (final svt in mstData.userSvt.followedBy(mstData.userSvtStorage)) svt.id: svt};

    SvtSaveData? cvtSvt(DeckServantData? svtData) {
      final userSvt = userSvts![svtData?.userSvtId];
      if (svtData == null || userSvt == null || svtData.isFollowerSvt == true) return null;
      final userCE = userSvts[svtData.userSvtEquipIds.firstOrNull];

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
        ceId: userCE?.svtId,
        ceLimitBreak: userCE?.limitCount == 4,
        ceLv: userCE?.lv ?? 1,
        supportType: SupportSvtType.none,
        cardStrengthens: null,
        commandCodeIds: null,
        //  disabledExtraSkills,
        //  customPassives,
        //  customPassiveLvs,
      );
    }

    return BattleTeamFormation(
      onFieldSvts: [1, 2, 3].map((idx) => cvtSvt(svtsMap[idx])).toList(),
      backupSvts: [4, 5, 6].map((idx) => cvtSvt(svtsMap[idx])).toList(),
      mysticCode: MysticCodeSaveData(
        mysticCodeId: userEquip?.equipId,
        level: userEquip?.lv ?? 1,
      ),
    );
  }
}
