import 'dart:convert';

import 'package:flutter_easyloading/flutter_easyloading.dart';

import 'package:chaldea/app/app.dart';
import 'package:chaldea/app/modules/faker/state.dart';
import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/models/db.dart';
import 'package:chaldea/models/gamedata/toplogin.dart';
import 'package:chaldea/models/models.dart' show GameCardMixin;
import 'package:chaldea/packages/packages.dart';
import 'package:chaldea/utils/utils.dart';
import 'package:chaldea/widgets/widgets.dart';
import '../../battle/formation/formation_card.dart';
import '../_shared/svt_equip_select.dart';
import '../_shared/svt_select.dart';
import '../card_enhance/svt_combine.dart';
import 'deck_list.dart';

const int _kMaxDeckNameLength = 20;

class _DragSvtData {
  final DeckServantData svt;

  _DragSvtData(this.svt);
}

class _DragCEData {
  final DeckServantData svt;

  _DragCEData(this.svt);
}

typedef EventDeckRequestParam = ({int eventId, int questId, int questPhase, int deckNo});

class UserDeckSetupPage extends StatefulWidget {
  final FakerRuntime runtime;
  final int activeDeckId;
  final EventDeckRequestParam? eventDeckParam;

  const UserDeckSetupPage({super.key, required this.runtime, required this.activeDeckId}) : eventDeckParam = null;
  const UserDeckSetupPage.event({super.key, required this.runtime, required EventDeckRequestParam this.eventDeckParam})
    : activeDeckId = 0;

  @override
  State<UserDeckSetupPage> createState() => _UserDeckSetupPageState();
}

class _UserDeckSetupPageState extends State<UserDeckSetupPage> with FakerRuntimeStateMixin {
  @override
  late final FakerRuntime runtime = widget.runtime;

  late DeckServantEntity deckInfo;
  // in mstData
  DeckServantEntity? _originalDeckInfo;
  UserDeckEntity? _userDeckEntity;
  UserEventDeckEntity? _userEventDeckEntity;

  late final bool isEventDeck = widget.activeDeckId == 0 && (widget.eventDeckParam?.deckNo ?? 0) != 0;

  @override
  void initState() {
    super.initState();
    initData();
  }

  void initData() {
    refreshDeckInfo();
    if (_originalDeckInfo != null) {
      deckInfo = DeckServantEntity.fromJson(Map.from(jsonDecode(jsonEncode(_originalDeckInfo!))));
    } else {
      deckInfo = DeckServantEntity();
    }
  }

  void refreshDeckInfo() {
    if (isEventDeck) {
      final param = widget.eventDeckParam!;
      _userEventDeckEntity = mstData.userEventDeck[UserEventDeckEntity.createPK(param.eventId, param.deckNo)];
      _originalDeckInfo = _userEventDeckEntity?.deckInfo;
    } else {
      _userDeckEntity = mstData.userDeck[widget.activeDeckId];
      _originalDeckInfo = _userDeckEntity?.deckInfo;
    }
  }

  @override
  Widget build(BuildContext context) {
    refreshDeckInfo();
    return Scaffold(
      appBar: AppBar(
        title: Text(
          isEventDeck
              ? 'Event Deck ${widget.eventDeckParam?.eventId}-${widget.eventDeckParam?.deckNo}'
              : 'Deck ${_userDeckEntity?.deckNo ?? widget.activeDeckId} ${_userDeckEntity?.name ?? ""}',
        ),
        actions: [runtime.buildMenuButton(context)],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              children: [
                if (_userDeckEntity != null)
                  ListTile(
                    dense: true,
                    title: Text('Deck Name'),
                    trailing: TextButton(
                      onPressed: () {
                        InputCancelOkDialog(
                          title: 'Deck Name',
                          initValue: _userDeckEntity?.name,
                          maxLength: _kMaxDeckNameLength,
                          validate: isDeckNameValid,
                          onSubmit: (value) {
                            runtime.runTask(() => doDeckEditName(value));
                          },
                        ).showDialog(context);
                      },
                      child: Text(_userDeckEntity!.name),
                    ),
                  ),
                DividerWithTitle(title: 'Original'),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: FormationCard(
                    formation: BattleTeamFormationX.fromUserDeck(deckInfo: _originalDeckInfo, mstData: mstData),
                    userSvtCollections: mstData.userSvtCollection.lookup,
                    showBond: true,
                  ),
                ),
                DividerWithTitle(title: S.current.preview),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: FormationCard(
                    formation: BattleTeamFormationX.fromUserDeck(deckInfo: deckInfo, mstData: mstData),
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
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      for (final svt in deckInfo.svts) Flexible(flex: 10, child: buildSvt(svt)),
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
                    if (!isEventDeck && _userDeckEntity != null)
                      TextButton(
                        onPressed: () {
                          router.pushPage(
                            UserDeckListPage(
                              runtime: runtime,
                              mstData: mstData,
                              onSelected: (selectedDeck) {
                                if (selectedDeck.id == _userDeckEntity?.id) {
                                  EasyLoading.showToast('Do not select same deck');
                                  return;
                                }
                                final _deckInfo = makeUserDeckCopy(selectedDeck).deckInfo;
                                if (_deckInfo != null) deckInfo = _deckInfo;
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
                isEventDeck
                    ? FilledButton.tonal(
                        onPressed: () {
                          SimpleConfirmDialog(
                            title: Text(
                              'Setup event deck ${widget.eventDeckParam?.eventId}-${widget.eventDeckParam?.deckNo}',
                            ),
                            onTapOk: () {
                              runtime.runTask(doUserEventDeckSetup);
                            },
                          ).showDialog(context);
                        },
                        child: Text('Setup'),
                      )
                    : FilledButton.tonal(
                        onPressed: () {
                          SimpleConfirmDialog(
                            title: Text('Setup deck ${_userDeckEntity?.deckNo ?? widget.activeDeckId}'),
                            onTapOk: () {
                              runtime.runTask(doUserDeckSetup);
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
                  inUseUserSvtIds: deckInfo.svts.map((e) => e.userSvtId).toList(),
                  onSelected: (selectedUserSvt) {
                    deckSvt.userSvtId = selectedUserSvt.id;
                    for (final _deckSvt in deckInfo.svts) {
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
          router.showDialog(
            builder: (context) => SimpleDialog(
              title: Text(svt?.lName.l ?? 'svt ${userSvt.svtId}'),
              children: [
                SimpleDialogOption(
                  child: Text.rich(
                    TextSpan(
                      children: [
                        if (svt != null) CenterWidgetSpan(child: svt.iconBuilder(context: context, width: 24)),
                        TextSpan(text: ' pos ${deckSvt.id}  Lv.${userSvt.lv}'),
                      ],
                    ),
                  ),
                ),
                kDefaultDivider,
                ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 24),
                  title: Text('从者强化'),
                  trailing: Icon(DirectionalIcons.keyboard_arrow_forward(context)),
                  onTap: () {
                    Navigator.pop(context);
                    runtime.agent.user.svtCombine.baseUserSvtId = userSvt.id;
                    router.pushPage(SvtCombinePage(runtime: runtime));
                  },
                ),
                ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 24),
                  title: Text('Clear Servant'),
                  onTap: () {
                    Navigator.pop(context);
                    deckSvt.userSvtId = 0;
                    deckSvt.userSvtEquipIds.fillRange(0, deckSvt.userSvtEquipIds.length, 0);
                    if (mounted) setState(() {});
                  },
                ),
              ],
            ),
          );
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

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.start,
      spacing: 1,
      children: [svtIcon, for (final (index, _) in deckSvt.userSvtEquipIds.indexed) buildSvtEquip(deckSvt, index)],
    );
  }

  Widget buildSvtEquip(DeckServantData deckSvt, int position) {
    final userSvtEquip = mstData.userSvt[deckSvt.userSvtEquipIds[position]];
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
      onTap: deckSvt.isFollowerSvt || deckSvt.isGrandSvt()
          ? null
          : () {
              router.pushBuilder(
                builder: (context) => SelectUserSvtEquipPage(
                  runtime: runtime,
                  inUseUserSvtIds: deckInfo.svts.expand((e) => e.userSvtEquipIds).toList(),
                  onSelected: (selectedSvtEquip) {
                    if (deckSvt.userSvtEquipIds.isEmpty) deckSvt.userSvtEquipIds = [0];
                    final grandSvtUserEquipIds = deckInfo.svts
                        .where((e) => e.isGrandSvt())
                        .expand((e) => e.userSvtEquipIds)
                        .toList();
                    if (grandSvtUserEquipIds.contains(selectedSvtEquip.id)) {
                      EasyLoading.showInfo('Already in-use by Grand Svt');
                      return;
                    }
                    deckSvt.userSvtEquipIds[0] = selectedSvtEquip.id;
                    for (final _deckSvt in deckInfo.svts) {
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
          if (deckSvt.userSvtEquipIds.firstOrNull == 0) return;
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
    return svtEquipIcon;
  }

  void onDrag(DeckServantData from, DeckServantData to, bool isCE) {
    final allSvts = deckInfo.svts;

    final fromIndex = allSvts.indexOf(from), toIndex = allSvts.indexOf(to);

    if (fromIndex < 0 || toIndex < 0 || fromIndex == toIndex) return;
    if (isCE) {
      if (from.isFollowerSvt || to.isFollowerSvt) return;
      if (from.userSvtId == 0 || to.userSvtId == 0) return;
      if (from.isGrandSvt() || to.isGrandSvt()) {
        EasyLoading.showInfo('Do edit grand svt inside game');
        return;
      }
      assert(from.userSvtEquipIds.isNotEmpty && to.userSvtEquipIds.isNotEmpty);
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
    final userEquip = mstData.userEquip[deckInfo.userEquipId];
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

  UserDeckEntity makeUserDeckCopy(UserDeckEntity entity) {
    final entity2 = UserDeckEntity.fromJson(Map.from(jsonDecode(jsonEncode(entity))));
    entity2.userId = 0;
    return entity2;
  }

  Future<void> doUserDeckSetup() async {
    refreshDeckInfo();
    final userDeckEntity = _userDeckEntity == null ? null : makeUserDeckCopy(_userDeckEntity!);
    if (widget.activeDeckId == 0 || userDeckEntity == null || userDeckEntity.id == 0 || deckInfo.svts.isEmpty) {
      throw SilentException('No user deck');
    }
    if (deckInfo.waveSvts.isNotEmpty) {
      throw SilentException('waveSvts not supported');
    }
    for (final (index, svt) in deckInfo.svts.sublist(0, 3).indexed) {
      if (!svt.isFollowerSvt && svt.userSvtId == 0) {
        throw SilentException('Frontline svt must exist: pos ${index + 1}');
      }
    }
    if (deckInfo.svts.where((e) => e.isFollowerSvt).length != 1) {
      throw SilentException('Should be only 1 support svt');
    }
    for (final (index, svt) in deckInfo.svts.indexed) {
      if (svt.id != index + 1) {
        throw SilentException('pos=${index + 1} id=${svt.id} not equal');
      }
    }
    if (getTotalCost() > (mstData.user?.costMax ?? 0)) {
      throw SilentException('COST ${getTotalCost()}>${mstData.user?.costMax}');
    }
    final newUserDeck = userDeckEntity..deckInfo = deckInfo;
    await runtime.agent.deckSetup(activeDeckId: widget.activeDeckId, userDeck: newUserDeck);
    initData();
    if (mounted) setState(() {});
  }

  Future<void> doUserEventDeckSetup() async {
    refreshDeckInfo();
    final param = widget.eventDeckParam;
    if (param == null || param.deckNo == 0) {
      throw SilentException('Invalid event deck id');
    }
    if (_userEventDeckEntity == null) {
      throw SilentException('No event deck found, init event inside game first');
    }
    if (deckInfo.svts.isEmpty) {
      throw SilentException('Empty deck svts');
    }
    if (deckInfo.waveSvts.isNotEmpty) {
      throw SilentException('waveSvts not supported');
    }
    for (final (index, svt) in deckInfo.svts.indexed) {
      if (svt.id != index + 1) {
        throw SilentException('pos=${index + 1} id=${svt.id} not equal');
      }
    }
    if (getTotalCost() > (mstData.user?.costMax ?? 0)) {
      throw SilentException('COST ${getTotalCost()}>${mstData.user?.costMax}');
    }
    await runtime.agent.eventDeckSetup(
      userEventDeck: null,
      deckInfo: deckInfo,
      eventId: param.eventId,
      questId: param.questId,
      phase: param.questPhase,
    );
    initData();
    if (mounted) setState(() {});
  }

  Future<void> doDeckEditName(String name) async {
    final deck = _userDeckEntity;
    if (deck == null) {
      throw SilentException('UserDeck is null');
    }
    if (!isDeckNameValid(name)) {
      throw SilentException('Invalid name: "$name"');
    }
    await agent.deckEditName(deckId: deck.id, deckName: name);
    initData();
    if (mounted) setState(() {});
  }

  bool isDeckNameValid(String name) {
    name = name.trim();
    if (name.isEmpty) return false;
    if (name == _userDeckEntity?.name) return false;
    if (kEmojiRegExp.hasMatch(name)) return false;
    if (name.length > _kMaxDeckNameLength) return false; // PARTY_ORGANIZATION_INPUT_DECK_NAME_EXPLANATION
    // LocalizationManager.ReplaceNameTag(name)
    return true;
  }

  int getTotalCost() {
    int cost = 0;
    for (final deckSvt in deckInfo.svts) {
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
