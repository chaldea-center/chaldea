import 'dart:convert';

import 'package:flutter_easyloading/flutter_easyloading.dart';

import 'package:chaldea/app/app.dart';
import 'package:chaldea/app/modules/faker/state.dart';
import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/models/db.dart';
import 'package:chaldea/models/gamedata/toplogin.dart';
import 'package:chaldea/models/models.dart' show GameCardMixin;
import 'package:chaldea/packages/packages.dart';
import 'package:chaldea/utils/atlas.dart';
import 'package:chaldea/utils/constants.dart';
import 'package:chaldea/utils/extension.dart';
import 'package:chaldea/widgets/widgets.dart';
import '../../battle/formation/formation_card.dart';
import '../_shared/svt_equip_select.dart';
import '../_shared/svt_select.dart';
import 'deck_list.dart';

class _DragSvtData {
  final DeckServantData svt;

  _DragSvtData(this.svt);
}

class _DragCEData {
  final DeckServantData svt;

  _DragCEData(this.svt);
}

// TODO: check grand board battle
// TODO: change svt dispLimitCount
class UserDeckSetupPage extends StatefulWidget {
  final FakerRuntime runtime;
  final int activeDeckId;
  const UserDeckSetupPage({super.key, required this.runtime, required this.activeDeckId});

  @override
  State<UserDeckSetupPage> createState() => _UserDeckSetupPageState();
}

class _UserDeckSetupPageState extends State<UserDeckSetupPage> with FakerRuntimeStateMixin {
  @override
  late final FakerRuntime runtime = widget.runtime;

  late UserDeckEntity userDeckEntity;

  @override
  void initState() {
    super.initState();
    initData();
  }

  void initData() {
    final entity = mstData.userDeck[widget.activeDeckId];
    if (entity != null) {
      userDeckEntity = makeCopy(entity);
    } else {
      userDeckEntity = UserDeckEntity(id: 0);
    }
  }

  @override
  Widget build(BuildContext context) {
    final svts = userDeckEntity.deckInfo?.svts ?? [];
    return Scaffold(
      appBar: AppBar(
        title: Text('Deck ${userDeckEntity.deckNo} ${userDeckEntity.name}'),
        actions: [runtime.buildMenuButton(context)],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              children: [
                DividerWithTitle(title: 'Original'),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: FormationCard(
                    formation: BattleTeamFormationX.fromUserDeck(
                      deckInfo: mstData.userDeck[widget.activeDeckId]?.deckInfo,
                      mstData: mstData,
                    ),
                    userSvtCollections: mstData.userSvtCollection.lookup,
                    showBond: true,
                  ),
                ),
                DividerWithTitle(title: S.current.preview),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: FormationCard(
                    formation: BattleTeamFormationX.fromUserDeck(deckInfo: userDeckEntity.deckInfo, mstData: mstData),
                    userSvtCollections: mstData.userSvtCollection.lookup,
                    showBond: true,
                  ),
                ),
                DividerWithTitle(title: '${S.current.edit} (COST ${getTotalCost()}/${mstData.user?.costMax})'),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    spacing: 4,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      for (final svt in svts) Flexible(flex: 10, child: buildSvt(svt)),
                      Flexible(flex: 8, child: buildMasterEquip()),
                    ],
                  ),
                ),
                kDefaultDivider,
                Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 8,
                  children: [
                    TextButton(
                      onPressed: () {
                        initData();
                        if (mounted) setState(() {});
                      },
                      child: Text(S.current.reset),
                    ),
                    TextButton(
                      onPressed: () {
                        router.pushPage(
                          UserDeckListPage(
                            runtime: runtime,
                            mstData: mstData,
                            onSelected: (selectedDeck) {
                              if (selectedDeck.id == userDeckEntity.id) {
                                EasyLoading.showToast('Do not select same deck');
                                return;
                              }
                              final deckCopy = makeCopy(selectedDeck);
                              userDeckEntity
                                ..deckInfo = deckCopy.deckInfo
                                ..cost = deckCopy.cost;
                              if (mounted) setState(() {});
                            },
                            enableEdit: false,
                          ),
                        );
                      },
                      child: Text('Copy from'),
                    ),
                  ],
                ),
              ],
            ),
          ),
          kDefaultDivider,
          SafeArea(
            child: OverflowBar(
              alignment: MainAxisAlignment.center,
              children: [
                runtime.buildCircularProgress(context: context, padding: EdgeInsets.symmetric(horizontal: 8)),
                FilledButton.tonal(
                  onPressed: () {
                    SimpleConfirmDialog(
                      title: Text('Setup deck ${userDeckEntity.deckNo}'),
                      onTapOk: () {
                        runtime.runTask(doDeckSetup);
                      },
                    ).showDialog(context);
                  },
                  child: Text('Setup'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildSvt(DeckServantData deckSvt) {
    final userSvt = mstData.userSvt[deckSvt.userSvtId];
    final userSvtCollection = mstData.userSvtCollection[userSvt?.svtId];
    final svt = db.gameData.servantsById[userSvt?.svtId];

    Widget baseSvtWidget = GameCardMixin.cardIconBuilder(
      context: context,
      icon: svt?.ascendIcon(userSvt?.dispLimitCount ?? -1) ?? Atlas.common.emptySvtIcon,
      width: 56,
      aspectRatio: 132 / 144,
      option: ImageWithTextOption(
        textAlign: TextAlign.left,
        // fontSize: 14,
        alignment: Alignment.bottomLeft,
        errorWidget: (context, url, error) => CachedImage(imageUrl: Atlas.common.unknownEnemyIcon),
      ),
      text: userSvt == null
          ? null
          : ' ◈ ${userSvtCollection?.friendshipRank}\n Lv.${userSvt.lv} NP${userSvt.treasureDeviceLv1}',
      onTap: deckSvt.isFollowerSvt
          ? null
          : () {
              router.pushBuilder(
                builder: (context) => SelectUserSvtPage(
                  runtime: runtime,
                  onSelected: (selectedUserSvt) {
                    deckSvt.userSvtId = selectedUserSvt.id;
                    final svts = userDeckEntity.deckInfo?.svts ?? [];
                    for (final _deckSvt in svts) {
                      if (_deckSvt != deckSvt && _deckSvt.userSvtId == deckSvt.userSvtId) {
                        _deckSvt.userSvtId = 0;
                        _deckSvt.userSvtEquipIds = [0];
                      }
                    }
                    if (mounted) setState(() {});
                  },
                ),
              );
            },
    );
    if (!deckSvt.isFollowerSvt && userSvt != null) {
      baseSvtWidget = GestureDetector(
        onLongPress: () {
          SimpleConfirmDialog(
            title: Text('Clear Svt'),
            content: Text.rich(
              TextSpan(
                text: 'pos ${deckSvt.id} ',
                children: [
                  if (svt != null) CenterWidgetSpan(child: svt.iconBuilder(context: context, width: 24)),
                  TextSpan(text: svt?.lName.l ?? 'No.${userSvt.svtId}. '),
                  TextSpan(text: 'Lv.${userSvt.lv}'),
                ],
              ),
            ),
            onTapOk: () {
              deckSvt.userSvtId = 0;
              deckSvt.userSvtEquipIds.fillRange(0, deckSvt.userSvtEquipIds.length, 0);
              if (mounted) setState(() {});
            },
          ).showDialog(context);
        },
        child: baseSvtWidget,
      );
    }

    Widget svtIcon = DragTarget<_DragSvtData>(
      builder: (context, candidateData, rejectedData) => baseSvtWidget,
      onAcceptWithDetails: (detail) {
        onDrag(detail.data.svt, deckSvt, false);
      },
    );
    svtIcon = Draggable<_DragSvtData>(data: _DragSvtData(deckSvt), feedback: svtIcon, child: svtIcon);

    final userSvtEquip = mstData.userSvt[deckSvt.userSvtEquipIds.firstOrNull];
    final svtEquip = db.gameData.craftEssencesById[userSvtEquip?.svtId];

    Widget baseSvtEquipWidget = GameCardMixin.cardIconBuilder(
      context: context,
      icon: svtEquip?.extraAssets.equipFace.equip?.values.firstOrNull ?? Atlas.common.emptyCeIcon,
      width: 56,
      aspectRatio: 150 / 68,
      text: userSvtEquip == null
          ? null
          : [' Lv.${userSvtEquip.lv}', if (userSvtEquip.limitCount == 4) ' $kStarChar2'].join(),
      option: ImageWithTextOption(
        textAlign: TextAlign.left,
        // fontSize: 14,
        alignment: Alignment.bottomLeft,
      ),
      onTap: deckSvt.isFollowerSvt
          ? null
          : () {
              router.pushBuilder(
                builder: (context) => SelectUserSvtEquipPage(
                  runtime: runtime,
                  onSelected: (selectedSvtEquip) {
                    if (deckSvt.userSvtEquipIds.isEmpty) deckSvt.userSvtEquipIds = [0];
                    deckSvt.userSvtEquipIds[0] = selectedSvtEquip.id;
                    final svts = userDeckEntity.deckInfo?.svts ?? [];
                    for (final _deckSvt in svts) {
                      if (_deckSvt != deckSvt && _deckSvt.userSvtEquipIds.firstOrNull == selectedSvtEquip.id) {
                        _deckSvt.userSvtEquipIds[0] = 0;
                      }
                    }
                    if (mounted) setState(() {});
                  },
                ),
              );
            },
    );
    if (!deckSvt.isFollowerSvt && userSvtEquip != null) {
      baseSvtEquipWidget = GestureDetector(
        onLongPress: () {
          SimpleConfirmDialog(
            title: Text('Clear CE'),
            content: Text.rich(
              TextSpan(
                text: 'pos ${deckSvt.id} ',
                children: [
                  if (svtEquip != null) CenterWidgetSpan(child: svtEquip.iconBuilder(context: context, width: 24)),
                  TextSpan(text: svtEquip?.lName.l ?? 'No.${userSvtEquip.id}. '),
                  TextSpan(text: 'Lv.${userSvtEquip.lv}, limit ${userSvtEquip.limitCount}'),
                ],
              ),
            ),
            onTapOk: () {
              deckSvt.userSvtEquipIds[0] = 0;
              if (mounted) setState(() {});
            },
          ).showDialog(context);
        },
        child: baseSvtEquipWidget,
      );
    }
    Widget svtEquipIcon = DragTarget<_DragCEData>(
      builder: (context, candidateData, rejectedData) => baseSvtEquipWidget,
      onAcceptWithDetails: (detail) {
        onDrag(detail.data.svt, deckSvt, true);
      },
    );
    svtEquipIcon = Draggable<_DragCEData>(data: _DragCEData(deckSvt), feedback: svtEquipIcon, child: svtEquipIcon);

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      spacing: 1,
      children: [svtIcon, svtEquipIcon],
    );
  }

  void onDrag(DeckServantData from, DeckServantData to, bool isCE) {
    final allSvts = userDeckEntity.deckInfo!.svts;

    final fromIndex = allSvts.indexOf(from), toIndex = allSvts.indexOf(to);

    if (fromIndex < 0 || toIndex < 0 || fromIndex == toIndex) return;
    if (isCE) {
      if (from.isFollowerSvt || to.isFollowerSvt) return;
      if (from.userSvtEquipIds.isEmpty) from.userSvtEquipIds.add(0);
      if (to.userSvtEquipIds.isEmpty) to.userSvtEquipIds.add(0);
      int fromId = from.userSvtEquipIds[0];
      int toId = to.userSvtEquipIds[0];
      from.userSvtEquipIds[0] = toId;
      to.userSvtEquipIds[0] = fromId;
    } else {
      int fromId = from.id;
      int toId = to.id;
      allSvts[fromIndex] = to..id = fromId;
      allSvts[toIndex] = from..id = toId;
    }
    if (mounted) setState(() {});
  }

  Widget buildMasterEquip() {
    final userEquip = mstData.userEquip[userDeckEntity.deckInfo?.userEquipId];
    final equip = db.gameData.mysticCodes[userEquip?.equipId];
    final cost = getTotalCost(), maxCost = mstData.user?.costMax ?? 0;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        db.getIconImage(equip?.icon, width: 56, aspectRatio: 1),
        Text("Lv.${userEquip?.lv ?? '-'}", textScaler: const TextScaler.linear(0.9)),
        Text(
          cost.toString(),
          style: TextStyle(
            color: cost > maxCost ? Theme.of(context).colorScheme.error : Theme.of(context).textTheme.bodySmall?.color,
          ),
          textScaler: const TextScaler.linear(0.9),
        ),
      ],
    );
  }

  UserDeckEntity makeCopy(UserDeckEntity entity) {
    final entity2 = UserDeckEntity.fromJson(Map.from(jsonDecode(jsonEncode(entity))));
    entity2.userId = 0;
    return entity2;
  }

  Future<void> doDeckSetup() async {
    final userDeckEntity = this.userDeckEntity;
    if (widget.activeDeckId == 0 || userDeckEntity.id == 0) {
      throw SilentException('No user deck');
    }
    if (userDeckEntity.deckInfo!.waveSvts.isNotEmpty) {
      throw SilentException('waveSvts not supported');
    }
    final svts = userDeckEntity.deckInfo!.svts;
    for (final (index, svt) in svts.sublist(0, 3).indexed) {
      if (!svt.isFollowerSvt && svt.userSvtId == 0) {
        throw SilentException('Frontline svt must exist: pos ${index + 1}');
      }
    }
    if (svts.where((e) => e.isFollowerSvt).length != 1) {
      throw SilentException('Should be only 1 support svt');
    }
    for (final (index, svt) in svts.indexed) {
      if (svt.id != index + 1) {
        throw SilentException('pos=${index + 1} id=${svt.id} not equal');
      }
    }
    if (getTotalCost() > (mstData.user?.costMax ?? 0)) {
      throw SilentException('COST ${getTotalCost()}>${mstData.user?.costMax}');
    }
    await runtime.agent.deckSetup(activeDeckId: widget.activeDeckId, userDeck: userDeckEntity);
    initData();
    if (mounted) setState(() {});
  }

  int getTotalCost() {
    final svts = userDeckEntity.deckInfo?.svts ?? const [];
    int cost = 0;
    for (final deckSvt in svts) {
      if (deckSvt.isFollowerSvt) continue;
      final userSvt = mstData.userSvt[deckSvt.userSvtId];
      final svt = db.gameData.servantsById[userSvt?.svtId];
      if (svt != null) {
        cost += svt.getAscended(userSvt?.dispLimitCount ?? -1, (v) => v.overwriteCost) ?? svt.cost;
      }

      final userSvtEquip = mstData.userSvt[deckSvt.userSvtEquipIds.firstOrNull];
      final svtEquip = db.gameData.craftEssencesById[userSvtEquip?.svtId];
      if (svtEquip != null) {
        cost += svtEquip.cost;
      }
    }
    return cost;
  }
}
