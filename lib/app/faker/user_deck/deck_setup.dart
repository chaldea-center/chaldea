import 'dart:convert';
import 'dart:math';

import 'package:flutter_easyloading/flutter_easyloading.dart';

import 'package:chaldea/app/app.dart';
import 'package:chaldea/app/modules/quest/breakdown/quest_phase.dart' show QuestRestrictionPage;
import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/models/db.dart';
import 'package:chaldea/models/gamedata/mst_data.dart';
import 'package:chaldea/models/gamedata/quest.dart';
import 'package:chaldea/models/models.dart' show GameCardMixin;
import 'package:chaldea/packages/json_viewer/json_viewer.dart';
import 'package:chaldea/packages/packages.dart';
import 'package:chaldea/utils/utils.dart';
import 'package:chaldea/widgets/widgets.dart';
import '../../modules/battle/formation/formation_card.dart';
import '../_shared/svt_equip_select.dart';
import '../_shared/svt_select.dart';
import '../combine/svt_combine.dart';
import '../runtime.dart';
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

typedef EventDeckRequestParam = ({int eventId, int questId, int phase, int deckNo, QuestPhase? questPhase});

class UserDeckSetupPage extends StatefulWidget {
  final FakerRuntime runtime;
  final int activeDeckId;
  final EventDeckRequestParam? eventDeckParam;
  final UserEventDeckEntity? newEventDeck;

  const UserDeckSetupPage({super.key, required this.runtime, required this.activeDeckId})
    : eventDeckParam = null,
      newEventDeck = null;
  const UserDeckSetupPage.event({
    super.key,
    required this.runtime,
    required EventDeckRequestParam this.eventDeckParam,
    this.newEventDeck,
  }) : activeDeckId = 0;

  @override
  State<UserDeckSetupPage> createState() => _UserDeckSetupPageState();
}

class _UserDeckSetupPageState extends State<UserDeckSetupPage> with FakerRuntimeStateMixin {
  @override
  late final FakerRuntime runtime = widget.runtime;

  late DeckServantEntity deckInfo;
  late final eventDeckParam = widget.eventDeckParam;
  // in mstData
  DeckServantEntity? _originalDeckInfo;
  UserDeckEntity? _userDeckEntity;
  UserEventDeckEntity? _userEventDeckEntity;

  late final bool isEventDeck = widget.activeDeckId == 0 && (eventDeckParam?.deckNo ?? 0) != 0;

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
      deckInfo = DeckServantEntity.empty(
        userEquipId: mstData.user?.userEquipId ?? 0,
        eventDeckNoSupport: eventDeckParam?.questPhase?.flags.contains(QuestFlag.eventDeckNoSupport) == true,
      );
    }
  }

  void refreshDeckInfo() {
    if (isEventDeck) {
      final param = widget.eventDeckParam!;
      _userEventDeckEntity =
          mstData.userEventDeck[UserEventDeckEntity.createPK(param.eventId, param.deckNo)] ?? widget.newEventDeck;
      _originalDeckInfo = _userEventDeckEntity?.deckInfo;
    } else {
      _userDeckEntity = mstData.userDeck[widget.activeDeckId];
      _originalDeckInfo = _userDeckEntity?.deckInfo;
    }
  }

  @override
  Widget build(BuildContext context) {
    refreshDeckInfo();
    final eventParam = widget.eventDeckParam;
    final questPhase = eventParam?.questPhase;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          isEventDeck
              ? 'Event Deck ${eventParam?.eventId}-${eventParam?.deckNo}'
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
                    formation: BattleTeamFormationX.fromUserDeck(
                      deckInfo: _originalDeckInfo,
                      mstData: mstData,
                      questPhase: questPhase,
                    ),
                    userSvtCollections: mstData.userSvtCollection.lookup,
                    showBond: true,
                  ),
                ),
                DividerWithTitle(title: S.current.preview),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: FormationCard(
                    formation: BattleTeamFormationX.fromUserDeck(
                      deckInfo: deckInfo,
                      mstData: mstData,
                      questPhase: questPhase,
                    ),
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
                        router.pushPage(JsonViewerPage(jsonDecode(jsonEncode(deckInfo))));
                      },
                      child: Text('JSON'),
                    ),
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
                              if (isEventDeck) {
                                //
                              } else {
                                if (selectedDeck.id == _userDeckEntity?.id) {
                                  EasyLoading.showToast('Do not select same deck');
                                  return;
                                }
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
                if (questPhase != null) ...[
                  kDefaultDivider,
                  ListTile(
                    dense: true,
                    title: Text(questPhase.lNameWithChapter),
                    subtitle: Text('phase ${questPhase.phase}/${Maths.max(questPhase.phases)}'),
                    trailing: Icon(DirectionalIcons.keyboard_arrow_forward(context)),
                    onTap: questPhase.routeTo,
                  ),
                  if (questPhase.restrictions.isNotEmpty)
                    ListTile(
                      dense: true,
                      title: Text('${questPhase.restrictions.length} ${S.current.quest_restriction}'),
                      trailing: Icon(DirectionalIcons.keyboard_arrow_forward(context)),
                      onTap: () {
                        router.pushPage(QuestRestrictionPage(restrictions: questPhase.restrictions));
                      },
                    ),
                  if (questPhase.flags.isNotEmpty)
                    ListTile(
                      dense: true,
                      title: const Text('flags'),
                      subtitle: Text.rich(
                        TextSpan(
                          children: divideList([
                            for (final flag in questPhase.flags)
                              TextSpan(
                                text: flag.name,
                                style: flag.name.toLowerCase().contains('support')
                                    ? TextStyle(color: Colors.blue)
                                    : null,
                              ),
                          ], const TextSpan(text: ' / ')),
                        ),
                      ),
                    ),
                ],
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
    final questPhase = widget.eventDeckParam?.questPhase;
    final userSvt = mstData.userSvt[deckSvt.userSvtId];
    final userSvtCollection = mstData.userSvtCollection[userSvt?.svtId];
    final mySvt = db.gameData.servantsById[userSvt?.svtId];
    final npc = deckSvt.npcFollowerSvtId == 0
        ? null
        : questPhase?.supportServants.firstWhereOrNull(
            (support) => support.npcSvtFollowerId == deckSvt.npcFollowerSvtId,
          );
    final fixedSupport = questPhase?.supportServants.firstWhereOrNull(
      (e) => deckSvt.initPos != null && e.script?.eventDeckIndex == deckSvt.initPos,
    );

    Widget baseSvtWidget = GameCardMixin.cardIconBuilder(
      context: context,
      icon:
          mySvt?.ascendIcon(userSvt?.dispLimitCount ?? -1) ??
          (npc ?? fixedSupport)?.svt.icon ??
          Atlas.common.emptySvtIcon,
      width: 56,
      aspectRatio: 132 / 144,
      option: ImageWithTextOption(
        textAlign: TextAlign.left,
        // fontSize: 14,
        alignment: Alignment.bottomLeft,
        errorWidget: (context, url, error) => CachedImage(imageUrl: Atlas.common.unknownEnemyIcon),
      ),
      text: userSvt != null
          ? ' ◈ ${userSvtCollection?.friendshipRank}\n Lv.${userSvt.lv} NP${userSvt.treasureDeviceLv1}'
          : deckSvt.npcFollowerSvtId != 0 && npc == null
          ? ' NPC ${deckSvt.npcFollowerSvtId}'
          : null,
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

    baseSvtWidget = GestureDetector(
      onLongPress: () {
        void _setDeckSvt(DeckServantData newDeck) {
          final index = deckInfo.svts.indexOf(deckSvt);
          if (index < 0) {
            EasyLoading.showError('not found in deck list');
            return;
          }
          deckInfo.svts[index] = newDeck;
          if (mounted) setState(() {});
        }

        router.showDialog(
          builder: (context) => SimpleDialog(
            title: Text(mySvt?.lName.l ?? npc?.lName.l ?? fixedSupport?.lName.l ?? 'svt ${deckSvt.svtId}'),
            children: [
              ListTile(
                dense: true,
                contentPadding: const EdgeInsets.symmetric(horizontal: 24),
                leading:
                    mySvt?.iconBuilder(context: context) ?? (npc ?? fixedSupport)?.svt.iconBuilder(context: context),
                title: Text(mySvt?.lName.l ?? (npc ?? fixedSupport)?.svt.lName.l ?? 'svt ${deckSvt.userSvtId}'),
                subtitle: Text(
                  <String>[
                    'pos ${deckSvt.id}',
                    if (mySvt != null) "mySvt ${deckSvt.userSvtId}(No.${mySvt.collectionNo})",
                    if (npc != null) "npc ${npc.npcSvtFollowerId}(No.${npc.svt.shownId})",
                    if (fixedSupport != null)
                      "fixedSupport ${fixedSupport.npcSvtFollowerId}(No.${fixedSupport.svt.shownId})",
                    if (deckSvt.isFollowerSvt) "isFollower",
                  ].join(', '),
                ),
              ),
              kDefaultDivider,
              ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 24),
                title: Text(S.current.clear),
                onTap: () {
                  Navigator.pop(context);
                  _setDeckSvt(DeckServantData.user(pos: deckSvt.id, initPos: deckSvt.initPos));
                },
              ),
              ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 24),
                title: Text('Set Support'),
                onTap: () {
                  Navigator.pop(context);
                  _setDeckSvt(DeckServantData.support(pos: deckSvt.id, initPos: deckSvt.initPos));
                },
              ),
              if (questPhase != null && questPhase.supportServants.isNotEmpty)
                ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 24),
                  title: Text('Choose NPC'),
                  onTap: () {
                    Navigator.pop(context);
                    if (!mounted) return;
                    router.showDialog(
                      builder: (context) {
                        return SimpleDialog(
                          title: Text('Choose NPC'),
                          children: [
                            for (final support in questPhase.supportServants)
                              ListTile(
                                dense: true,
                                contentPadding: const EdgeInsets.symmetric(horizontal: 24),
                                leading: support.svt.iconBuilder(context: context),
                                title: Text(support.lName.l),
                                subtitle: Text('npcId ${support.npcSvtFollowerId}'),
                                onTap: () {
                                  Navigator.pop(context);
                                  _setDeckSvt(
                                    DeckServantData.npc(pos: deckSvt.id, npcFollowerSvtId: support.npcSvtFollowerId),
                                  );
                                },
                              ),
                          ],
                        );
                      },
                    );
                  },
                ),
              if (userSvt != null) kDefaultDivider,
              if (userSvt != null)
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
            ],
          ),
        );
      },
      child: baseSvtWidget,
    );
    if (deckSvt.isFollowerSvt || deckSvt.isFollowerNPC) {
      baseSvtWidget = Stack(
        clipBehavior: Clip.none,
        children: [
          baseSvtWidget,
          Positioned(
            top: -5,
            right: -5,
            child: Opacity(
              opacity: deckSvt.isFollowerNPC ? 0.6 : 1,
              child: db.getIconImage(AssetURL.i.items(12), width: deckSvt.isFollowerNPC ? 18 : 24, aspectRatio: 1),
            ),
          ),
        ],
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
      children: [
        Text.rich(TextSpan(text: deckSvt.initPos.toString()), style: Theme.of(context).textTheme.bodySmall),
        svtIcon,
        for (final index in range(max(1, deckSvt.userSvtEquipIds.length))) buildSvtEquip(deckSvt, index),
      ],
    );
  }

  Widget buildSvtEquip(DeckServantData deckSvt, int position) {
    if (deckSvt.userSvtEquipIds.length <= position) deckSvt.userSvtEquipIds.fixLength(position + 1, () => 0);
    final userSvtEquip = mstData.userSvt[deckSvt.userSvtEquipIds[position]];
    final svtEquip = db.gameData.craftEssencesById[userSvtEquip?.svtId];
    final npc = deckSvt.npcFollowerSvtId == 0
        ? null
        : widget.eventDeckParam?.questPhase?.supportServants.firstWhereOrNull(
            (support) => support.npcSvtFollowerId == deckSvt.npcFollowerSvtId,
          );
    final fixedSupport = widget.eventDeckParam?.questPhase?.supportServants.firstWhereOrNull(
      (e) => deckSvt.initPos != null && e.script?.eventDeckIndex == deckSvt.initPos,
    );

    Widget baseSvtEquipWidget = GameCardMixin.cardIconBuilder(
      context: context,
      icon:
          svtEquip?.equipFace ?? (npc ?? fixedSupport)?.equips.firstOrNull?.equip.equipFace ?? Atlas.common.emptyCeIcon,
      width: 56,
      aspectRatio: 150 / 68,
      text: userSvtEquip != null
          ? [' Lv.${userSvtEquip.lv}', if (userSvtEquip.limitCount == 4) ' $kStarChar2'].join()
          : null,
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
    final fixedPositions = widget.eventDeckParam?.questPhase?.supportServants
        .map((e) => e.script?.eventDeckIndex)
        .whereType<int>()
        .toList();
    bool hasFixedSupport =
        fixedPositions != null &&
        fixedPositions.isNotEmpty &&
        (fixedPositions.contains(from.initPos) || fixedPositions.contains(to.initPos));
    if (hasFixedSupport &&
        widget.eventDeckParam?.questPhase?.flags.contains(QuestFlag.supportSvtEditablePosition) != true) {
      return;
    }
    if (isCE) {
      if (from.isFollowerSvt || to.isFollowerSvt) return;
      if (from.userSvtId == 0 || to.userSvtId == 0) return;
      if (from.isGrandSvt() || to.isGrandSvt()) {
        EasyLoading.showInfo('Do edit grand svt inside game');
        return;
      }
      if (hasFixedSupport) return;
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
    int cost = getTotalCost(), maxCost = mstData.user?.costMax ?? 0;
    if ((widget.eventDeckParam?.questPhase?.extraDetail?.isInfinityCost ?? 0) != 0) {
      maxCost = 9999;
    }
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(' ', style: Theme.of(context).textTheme.bodySmall),
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
      phase: param.phase,
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
