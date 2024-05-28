import 'package:flutter/material.dart';

import 'package:chaldea/models/gamedata/toplogin.dart';
import 'package:chaldea/models/models.dart';
import 'package:chaldea/utils/extension.dart';
import 'package:chaldea/widgets/material.dart';
import '../../battle/formation/formation_card.dart';

class UserFormationDecksPage extends StatefulWidget {
  final MasterDataManager mstData;
  const UserFormationDecksPage({super.key, required this.mstData});

  @override
  State<UserFormationDecksPage> createState() => UserFormationDecksPageState();
}

class UserFormationDecksPageState extends State<UserFormationDecksPage> {
  late final mstData = widget.mstData;
  late final userSvts = {for (final svt in mstData.userSvt.followedBy(mstData.userSvtStorage)) svt.id: svt};

  @override
  Widget build(BuildContext context) {
    final decks = mstData.userDeck.list;
    return Scaffold(
      appBar: AppBar(
        title: const Text("User Formation Decks"),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
        itemBuilder: (context, index) => buildOne(decks[index]),
        separatorBuilder: (context, index) => const Divider(indent: 16, endIndent: 16, height: 16),
        itemCount: decks.length,
      ),
    );
  }

  Widget buildOne(UserDeckEntity deck) {
    final userEquip = mstData.userEquip.firstWhereOrNull((e) => e.id == deck.deckInfo?.userEquipId);
    final svts = deck.deckInfo?.svts ?? [];
    final svtsMap = {for (final svt in svts) svt.id: svt};
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        DividerWithTitle(title: '[${deck.id}] No.${deck.deckNo} ${deck.name}'),
        FormationCard(
          formation: BattleTeamFormation(
            onFieldSvts: [1, 2, 3].map((idx) => cvtSvt(svtsMap[idx])).toList(),
            backupSvts: [4, 5, 6].map((idx) => cvtSvt(svtsMap[idx])).toList(),
            mysticCode: MysticCodeSaveData(
              mysticCodeId: userEquip?.equipId,
              level: userEquip?.lv ?? 1,
            ),
          ),
        ),
      ],
    );
  }

  late final userSvtCommandCards = {for (final card in mstData.userSvtCommandCard) card.svtId: card};

  SvtSaveData? cvtSvt(DeckServantData? svtData) {
    final userSvt = userSvts[svtData?.userSvtId];
    if (svtData == null || userSvt == null || svtData.isFollowerSvt == true) return null;
    final userCE = userSvts[svtData.userSvtEquipIds.firstOrNull];

    return SvtSaveData(
      svtId: userSvt.svtId,
      limitCount: userSvt.dispLimitCount,
      skillLvs: [userSvt.skillLv1, userSvt.skillLv2, userSvt.skillLv3],
      skillIds: [null, null, null],
      appendLvs: userSvt.appendLvs,
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
}
