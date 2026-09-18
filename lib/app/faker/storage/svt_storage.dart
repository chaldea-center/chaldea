import 'dart:math';

import 'package:chaldea/app/app.dart';
import 'package:chaldea/app/modules/common/filter_group.dart';
import 'package:chaldea/app/modules/common/filter_page_base.dart';
import 'package:chaldea/app/routes/delegate.dart';
import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/models/gamedata/mst_data.dart';
import 'package:chaldea/models/models.dart';
import 'package:chaldea/utils/basic.dart';
import 'package:chaldea/utils/constants.dart';
import 'package:chaldea/utils/extension.dart';
import 'package:chaldea/widgets/widgets.dart';

import '../../modules/craft_essence/filter.dart';
import '../../modules/servant/filter.dart';
import '../_shared/user_svt_filter_data.dart';
import '../runtime.dart';

/// Which kind of cards the page manages: servants/embers/fous or craft essences.
enum SvtStorageMode { svt, equip }

/// The two card slots: main inventory (userSvt) and storage (userSvtStorage).
enum SvtSlot { main, storage }

typedef SvtStorageGetStatus = String? Function(List<UserServantEntity> cards, SvtStorageStatusOptions options);

/// Non-card context handed to [SvtStoragePage.getStatus].
class SvtStorageStatusOptions {
  final MasterDataManager mstData;
  final Set<int> selectedUserSvtIds;

  const SvtStorageStatusOptions({required this.mstData, required this.selectedUserSvtIds});
}

class SvtStoragePage extends StatefulWidget {
  final FakerRuntime runtime;

  /// Fixed svt/equip mode. Null = default svt mode with a TabBar toggle.
  final SvtStorageMode? fixedMode;

  /// Fixed slot. Null = default main slot, switchable between main and storage.
  final SvtSlot? fixedSlot;

  /// Overrides for filter data; null = fallback to this router's cached data.
  final SvtFilterData? svtFilterData;
  final CraftFilterData? ceFilterData;

  /// Picker mode: bottom bar only shows a confirm button which pops the page
  /// with the selected cards and calls [onSelected].
  final ValueChanged<List<UserServantEntity>>? onSelected;

  /// Max cards the picker confirm button accepts.
  final int? maxSelectionCount;

  /// Per-cell status text. Cards is a single card, or a merged group of
  /// embers/fous sharing one svtId. Null = default status text.
  final SvtStorageGetStatus? getStatus;

  /// Non-null reason = card cannot be selected, reason shown centered on the
  /// cell instead of the status text.
  final String? Function(UserServantEntity userSvt)? disableSelectionReason;

  /// Extra list filter, also validated against the selection on every build.
  final bool Function(UserServantEntity userSvt)? extraFilter;

  const SvtStoragePage({
    super.key,
    required this.runtime,
    this.fixedMode,
    this.fixedSlot,
    this.svtFilterData,
    this.ceFilterData,
    this.onSelected,
    this.maxSelectionCount,
    this.getStatus,
    this.disableSelectionReason,
    this.extraFilter,
  });

  @override
  State<SvtStoragePage> createState() => _SvtStoragePageState();
}

class _SvtStoragePageState extends State<SvtStoragePage> with FakerRuntimeStateMixin, SingleTickerProviderStateMixin {
  @override
  late final runtime = widget.runtime;

  static const int kMaxSelectCount = 999;
  static const int kMaxSellCount = 100;
  static final _kCellTextOption = ImageWithTextOption(padding: EdgeInsets.fromLTRB(4, 0, 4, 2), fontSize: 12);

  // NPC-only entity types never shown in svt mode
  static const _kHiddenSvtTypes = {
    SvtType.svtMaterialTd,
    SvtType.enemy,
    SvtType.enemyCollection,
    SvtType.enemyCollectionDetail,
  };

  static final _svtFilters = RouterValues<SvtFilterData>(
    () => SvtFilterData(sortKeys: [SvtCompare.bondLv, ...SvtCompare.kRarityFirstKeys], sortReversed: [false]),
  );
  static final _ceFilters = RouterValues<CraftFilterData>(
    () => CraftFilterData(sortKeys: CraftCompare.kRarityFirstKeys),
  );
  static final _userSvtFilters = RouterValues(() => UserServantFilterData());
  // management page wants all CEs by default, not locked-only like combine pages
  static final _userEquipFilters = RouterValues(() => UserSvtEquipFilterData()..locked.reset());

  SvtFilterData get svtFilterData => widget.svtFilterData ?? _svtFilters.of(context);
  CraftFilterData get ceFilterData => widget.ceFilterData ?? _ceFilters.of(context);
  UserServantFilterData get userSvtFilterData => _userSvtFilters.of(context);
  UserSvtEquipFilterData get userEquipFilterData => _userEquipFilters.of(context);

  late SvtStorageMode mode = widget.fixedMode ?? SvtStorageMode.svt;
  late SvtSlot slot = widget.fixedSlot ?? SvtSlot.main;
  bool mergeStackable = true; // merged display of embers/fous, default on
  final selectedUserSvtIds = <int>{};

  TabController? _tabController;

  @override
  void initState() {
    super.initState();
    if (widget.fixedMode == null) {
      _tabController = TabController(length: 2, vsync: this);
      _tabController!.addListener(() {
        if (_tabController!.indexIsChanging) return;
        final newMode = _tabController!.index == 1 ? SvtStorageMode.equip : SvtStorageMode.svt;
        if (newMode == mode) return;
        // spec: switching svt/equip mode clears the selection
        setState(() {
          mode = newMode;
          selectedUserSvtIds.clear();
        });
      });
    }
  }

  @override
  void dispose() {
    _tabController?.dispose();
    super.dispose();
  }

  // ---------------------------------------------------------------------------
  // data & filters
  // -----------------------------------------------------------------------------

  BasicServant? _entity(UserServantEntity card) => db.gameData.entities[card.svtId];
  Servant? _dbSvt(UserServantEntity card) => db.gameData.servantsById[card.svtId];
  CraftEssence? _dbCE(UserServantEntity card) => db.gameData.craftEssencesById[card.svtId];

  bool _isEquip(UserServantEntity card) {
    // entities covers all known cards; craftEssencesById also holds region-specific CEs
    return _entity(card)?.type == SvtType.servantEquip || _dbCE(card) != null;
  }

  bool _modeFilter(UserServantEntity card) {
    switch (mode) {
      case SvtStorageMode.svt:
        if (_isEquip(card)) return false;
        final type = _entity(card)?.type;
        // unknown entities stay manageable in svt mode
        return type == null || !_kHiddenSvtTypes.contains(type);
      case SvtStorageMode.equip:
        return _isEquip(card);
    }
  }

  bool _isStackable(UserServantEntity card) {
    final type = _entity(card)?.type;
    return type == SvtType.combineMaterial || type == SvtType.statusUp;
  }

  bool _isMergedCell(List<UserServantEntity> cards) {
    return mode == SvtStorageMode.svt && mergeStackable && _isStackable(cards.first);
  }

  /// Spec: on every build and before confirming, the selection must be valid:
  /// in current slot + current mode + no disable reason + extraFilter passes.
  void _validateSelection() {
    final slotCards = slot == SvtSlot.main ? mstData.userSvt : mstData.userSvtStorage;
    selectedUserSvtIds.retainWhere((id) {
      final card = slotCards[id];
      if (card == null) return false;
      if (!_modeFilter(card)) return false;
      if (widget.disableSelectionReason?.call(card) != null) return false;
      if (widget.extraFilter != null && widget.extraFilter!(card) != true) return false;
      return true;
    });
  }

  List<UserServantEntity> get _selectedCards {
    final slotCards = slot == SvtSlot.main ? mstData.userSvt : mstData.userSvtStorage;
    return [
      for (final id in selectedUserSvtIds)
        if (slotCards[id] != null) slotCards[id]!,
    ];
  }

  // port of the combine-availability check in select_svt.dart
  List<UserSvtCombineType> _combineTypes(UserServantEntity card) {
    final svt = _dbSvt(card);
    if (svt == null || svt.collectionNo <= 0) return const [];
    final coinNum = mstData.userSvtCoin[card.svtId]?.num ?? 0;
    final appendLvs = mstData.getSvtAppendSkillLvs(card);
    final collection = mstData.userSvtCollection[card.svtId];
    return [
      if (card.lv < (card.maxLv ?? svt.lvMax)) UserSvtCombineType.level,
      if (card.adjustAtk < 100 || card.adjustHp < 100) UserSvtCombineType.fou3,
      if (card.limitCount < Maths.max<int>(svt.limits.keys, 0)) UserSvtCombineType.ascension,
      if (card.lv >= 100 && card.lv < 120 && coinNum >= 30) UserSvtCombineType.grail,
      if (card.skillLvs.any((e) => e < 9)) UserSvtCombineType.skill,
      if (appendLvs[1] == 0 && coinNum >= 120 || (appendLvs[1] > 0 && appendLvs[1] < 9)) UserSvtCombineType.append2,
      if (appendLvs.any((lv) => lv == 0 && coinNum >= 120 || (lv > 0 && lv < 9))) UserSvtCombineType.appendAny,
      if (collection != null &&
          collection.friendshipRank < kBondLvMax &&
          collection.friendshipRank == collection.maxFriendshipRank)
        UserSvtCombineType.bondLimit,
      if (collection != null && collection.friendshipRank < kBondLvDefaultMax) UserSvtCombineType.bondLessThan10,
      if (mstData.userSvtCommandCode[card.svtId]?.userCommandCodeIds.any((e) => e == -1) ?? true)
        UserSvtCombineType.ccUnlock,
    ];
  }

  bool _pageFilter(UserServantEntity card, User userData) {
    if (card.isWithdraw()) return false;
    switch (mode) {
      case SvtStorageMode.svt:
        final entity = _entity(card);
        if (entity != null) {
          final svtType = entity.type == .heroine ? SvtType.normal : entity.type;
          if (!userSvtFilterData.svtType.matchOne(svtType)) return false;
        }
        if (entity != null && const <SvtType>{.combineMaterial, .statusUp}.contains(entity.type)) {
          if (!svtFilterData.rarity.matchOne(entity.rarity)) return false;
          if (entity.className != .ALL && !svtFilterData.svtClass.matchOne(entity.className)) {
            return false;
          }
        }
        final svt = _dbSvt(card);
        // embers/fous/unknown cards bypass servant filters
        if (svt == null || svt.collectionNo <= 0) return true;
        if (userSvtFilterData.availableCombines.isNotEmpty) {
          if (!userSvtFilterData.availableCombines.matchAny(_combineTypes(card))) return false;
        }
        return ServantFilterPage.filter(
          svtFilterData,
          svt,
          svtStat: userData.servants[svt.collectionNo] ??= mstData.getSvtStatus(card),
          useCostumeTraitForRegion: runtime.region,
        );

      case SvtStorageMode.equip:
        if (!userEquipFilterData.locked.matchOne(card.isLocked())) return false;
        if (!userEquipFilterData.maxLimitBreak.matchOne(card.limitCount == 4)) return false;
        final ce = _dbCE(card);
        if (ce == null || ce.collectionNo <= 0) return true;
        return CraftFilterPage.filter(ceFilterData, ce, status: mstData.getSvtEquipStatus(card));
    }
  }

  int _cardTypeOrder(UserServantEntity card) {
    final type = _entity(card)?.type;
    if (type == SvtType.normal || type == SvtType.heroine) return 0;
    if (type == SvtType.combineMaterial) return 1;
    if (type == SvtType.statusUp) return 2;
    return 3;
  }

  int _compareGroups(List<UserServantEntity> a, List<UserServantEntity> b, User userData) {
    final r = _cardTypeOrder(a.first).compareTo(_cardTypeOrder(b.first));
    if (r != 0) return r;
    switch (mode) {
      case SvtStorageMode.svt:
        return SvtFilterData.compareId(
          a.first.svtId,
          b.first.svtId,
          keys: svtFilterData.sortKeys,
          reversed: svtFilterData.sortReversed,
          user: userData,
        );
      case SvtStorageMode.equip:
        final cea = _dbCE(a.first), ceb = _dbCE(b.first);
        if (cea != null && ceb != null) {
          return CraftFilterData.compare(cea, ceb, keys: ceFilterData.sortKeys, reversed: ceFilterData.sortReversed);
        }
        return a.first.svtId.compareTo(b.first.svtId);
    }
  }

  /// Build the displayed card groups: single cards, or one group per svtId for
  /// embers/fous when merged display is on (sorted by createdAt asc).
  List<List<UserServantEntity>> _buildGroups() {
    final userData = User();
    final cards = (slot == SvtSlot.main ? mstData.userSvt : mstData.userSvtStorage)
        .where(_modeFilter)
        .where((card) => widget.extraFilter?.call(card) ?? true)
        .where((card) => _pageFilter(card, userData))
        .toList();

    final groups = <List<UserServantEntity>>[];
    if (mode == SvtStorageMode.svt && mergeStackable) {
      final stacked = <int, List<UserServantEntity>>{};
      for (final card in cards) {
        if (_isStackable(card)) {
          stacked.putIfAbsent(card.svtId, () => []).add(card);
        } else {
          groups.add([card]);
        }
      }
      for (final group in stacked.values) {
        // earliest first: merged selection picks from the oldest card
        group.sort2((e) => e.createdAt);
        groups.add(group);
      }
    } else {
      groups.addAll([
        for (final card in cards) [card],
      ]);
    }
    groups.sort((a, b) => _compareGroups(a, b, userData));
    return groups;
  }

  // -----------------------------------------------------------------------------
  // sell whitelist
  // -----------------------------------------------------------------------------

  bool _isSellable(UserServantEntity card) {
    if (card.isLocked() || card.isChoice()) return false;
    final entity = _entity(card);
    if (entity == null) return false;
    switch (entity.type) {
      case SvtType.combineMaterial:
        return true;
      case SvtType.statusUp:
        return entity.rarity <= 3;
      case SvtType.servantEquip:
        if (entity.rarity > 3) return false;
        if (card.lv > 1 || card.limitCount > 1) return false;
        if (!mstData.userSvtAndStorage.any((e) => e.svtId == card.svtId && e.limitCount == 4)) return false;
        // Eat it, don't sell
        return false;
      case SvtType.normal:
      case SvtType.heroine:
        if (entity.rarity > 4) return false;
        final pristine =
            card.limitCount == 0 &&
            card.lv == 1 &&
            card.skillLvs.every((e) => e == 1) &&
            card.adjustAtk == 0 &&
            card.adjustHp == 0;
        if (!pristine) return false;
        return mstData.userSvtAndStorage.any((e) => e.svtId == card.svtId && e.treasureDeviceLv1 == 5);
      default:
        return false;
    }
  }

  // -----------------------------------------------------------------------------
  // capacity
  // -----------------------------------------------------------------------------

  ({int capacity, int used}) _slotCapacity(SvtSlot targetSlot) {
    final isStorage = targetSlot == SvtSlot.storage;
    final counts = mstData.countSvtKeep(isStorage: isStorage);
    final user = mstData.user;
    final int capacity;
    if (isStorage) {
      // (base + per-side adjust is inferred from UserGameEntity fields)
      final adjust = mode == SvtStorageMode.svt ? user?.svtStorageAdjust ?? 0 : user?.svtEquipStorageAdjust ?? 0;
      capacity = runtime.gameData.timerData.constants.maxUserSvtStorage + adjust;
    } else {
      capacity = mode == SvtStorageMode.svt ? user?.svtKeep ?? 0 : user?.svtEquipKeep ?? 0;
    }
    final used = mode == SvtStorageMode.svt ? counts.svtCount : counts.svtEquipCount;
    return (capacity: capacity, used: used);
  }

  int _moveRemainingCapacity() {
    final target = _slotCapacity(slot == SvtSlot.main ? SvtSlot.storage : SvtSlot.main);
    return target.capacity - target.used;
  }

  String _slotName(SvtSlot slot) => slot == SvtSlot.main ? '所持栏位' : '保管室';

  // -----------------------------------------------------------------------------
  // build
  // -----------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    _validateSelection();
    final groups = _buildGroups();
    return Scaffold(
      appBar: AppBar(
        title: Text('灵基保管室${selectedUserSvtIds.isEmpty ? "" : " (${selectedUserSvtIds.length})"}'),
        actions: [
          if (mode == SvtStorageMode.svt)
            IconButton(
              tooltip: '合并种火/芙芙',
              onPressed: () => setState(() => mergeStackable = !mergeStackable),
              icon: Icon(mergeStackable ? Icons.auto_awesome_motion : Icons.grid_view_outlined),
            ),
          IconButton(icon: const Icon(Icons.filter_alt), tooltip: S.current.filter, onPressed: _showFilterPage),
          runtime.buildMenuButton(context),
        ],
        bottom: _tabController == null
            ? null
            : FixedHeight.tabBar(
                TabBar(
                  controller: _tabController,
                  tabs: const [
                    Tab(text: '从者'),
                    Tab(text: '礼装'),
                  ],
                ),
              ),
      ),
      body: Column(
        children: [
          if (widget.fixedSlot == null) _buildSlotRow(),
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 64,
                mainAxisSpacing: 2,
                crossAxisSpacing: 2,
                childAspectRatio: 132 / 144,
              ),
              itemCount: groups.length,
              itemBuilder: (context, index) => _buildCell(groups[index]),
            ),
          ),
          kDefaultDivider,
          SafeArea(child: _buildButtonBar()),
        ],
      ),
    );
  }

  Widget _buildSlotRow() {
    final main = _slotCapacity(SvtSlot.main);
    final storage = _slotCapacity(SvtSlot.storage);
    final typeLabel = mode == SvtStorageMode.svt ? S.current.servant : S.current.craft_essence_short;
    return Padding(
      padding: const EdgeInsetsDirectional.only(start: 12, end: 12, top: 8, bottom: 2),
      child: Row(
        spacing: 8,
        children: [
          SegmentedButton<SvtSlot>(
            segments: const [
              ButtonSegment(value: SvtSlot.main, label: Text('所持')),
              ButtonSegment(value: SvtSlot.storage, label: Text('保管')),
            ],
            selected: {slot},
            showSelectedIcon: false,
            style: const ButtonStyle(visualDensity: VisualDensity.compact),
            onSelectionChanged: (v) => setState(() => slot = v.first),
          ),
          Expanded(
            child: Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: '$typeLabel ${main.used}/${main.capacity}',
                    style: slot == .main ? const TextStyle(fontWeight: .bold) : const TextStyle(fontWeight: .normal),
                  ),
                  const TextSpan(text: ' · '),
                  TextSpan(
                    text: '保管 ${storage.used}/${storage.capacity}',
                    style: slot == .storage ? const TextStyle(fontWeight: .bold) : const TextStyle(fontWeight: .normal),
                  ),
                ],
              ),
              style: Theme.of(context).textTheme.bodySmall,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCell(List<UserServantEntity> cards) {
    final first = cards.first;
    final svt = _dbSvt(first);
    final ce = _dbCE(first);
    final entity = _entity(first);
    final reason = _disableReason(cards);
    final selectedCount = cards.where((c) => selectedUserSvtIds.contains(c.id)).length;

    final String? status = reason == null
        ? widget.getStatus?.call(
                cards,
                SvtStorageStatusOptions(mstData: mstData, selectedUserSvtIds: selectedUserSvtIds),
              ) ??
              _defaultStatus(cards)
        : null;

    Widget child;
    if (svt != null) {
      child = svt.iconBuilder(
        context: context,
        text: status,
        overrideIcon: first.icon,
        jumpToDetail: false,
        option: _kCellTextOption,
      );
    } else if (ce != null) {
      child = ce.iconBuilder(context: context, text: status, jumpToDetail: false, option: _kCellTextOption);
    } else if (entity != null) {
      child = entity.iconBuilder(context: context, text: status, jumpToDetail: false, option: _kCellTextOption);
    } else {
      child = Text('${first.svtId}');
    }

    child = Stack(
      fit: StackFit.passthrough,
      children: [
        child,
        if (reason != null)
          Center(
            child: Padding(
              padding: const EdgeInsets.all(2),
              child: Text(
                reason,
                textAlign: TextAlign.center,
                textScaler: const TextScaler.linear(0.7),
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ),
          ),
        if (selectedCount > 0)
          Positioned(
            top: 0,
            right: 0,
            child: Icon(Icons.check_circle, size: 16, color: Theme.of(context).colorScheme.primary),
          ),
      ],
    );

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: reason == null ? () => _onTapCell(cards) : null,
      onLongPress: () {
        if (svt != null) {
          router.push(url: Routes.servantI(first.svtId));
        } else if (ce != null) {
          router.push(url: Routes.craftEssenceI(first.svtId));
        }
      },
      child: child,
    );
  }

  String? _disableReason(List<UserServantEntity> cards) {
    if (widget.disableSelectionReason == null) return null;
    for (final card in cards) {
      final reason = widget.disableSelectionReason!(card);
      if (reason != null) return reason;
    }
    return null;
  }

  String? _defaultStatus(List<UserServantEntity> cards) {
    final first = cards.first;
    if (_isMergedCell(cards)) {
      final x = cards.where((c) => selectedUserSvtIds.contains(c.id)).length;
      return x > 0 ? '$x/${cards.length}' : 'x${cards.length}';
    }
    final entity = _entity(first);
    if (entity == null) return '${first.svtId}';
    final prefix = [if (first.isLocked()) '🔐 ', if (first.isChoice()) '✴️ '].join();
    if (entity.type == SvtType.combineMaterial || entity.type == SvtType.statusUp) {
      return prefix.isEmpty ? null : prefix;
    }
    if (entity.type == SvtType.servantEquip) {
      return '$prefix\nLv${first.lv}/${first.maxLv ?? "?"}\n ${first.limitCount}/4';
    }
    return [
      '$prefix NP${first.treasureDeviceLv1}',
      'Lv${first.lv}/${first.maxLv ?? "?"} ${first.limitCount}',
      '${first.skillLv1}/${first.skillLv2}/${first.skillLv3}',
      mstData.getSvtAppendSkillLvs(first).map((e) => e == 0 ? "-" : e).join("/"),
    ].join('\n');
  }

  void _onTapCell(List<UserServantEntity> cards) {
    if (_isMergedCell(cards) && cards.length > 1) {
      _pickMergedCount(cards);
      return;
    }
    final card = cards.first;
    setState(() {
      if (selectedUserSvtIds.contains(card.id)) {
        selectedUserSvtIds.remove(card.id);
      } else if (selectedUserSvtIds.length < kMaxSelectCount) {
        selectedUserSvtIds.add(card.id);
      }
    });
  }

  void _pickMergedCount(List<UserServantEntity> cards) {
    final current = cards.where((c) => selectedUserSvtIds.contains(c.id)).length;
    final maxSelectable = min(cards.length, kMaxSelectCount - (selectedUserSvtIds.length - current));
    if (maxSelectable <= 0) return;
    final entity = _entity(cards.first);
    InputCancelOkDialog.number(
      title: '$kStarChar2${entity?.rarity ?? ""} ${entity?.lName.l ?? cards.first.svtId} ×${cards.length}',
      initValue: current,
      validate: (v) => v >= 0 && v <= maxSelectable,
      onSubmit: (v) {
        setState(() {
          selectedUserSvtIds.removeAll(cards.map((e) => e.id));
          // cards are sorted by createdAt asc: pick from the earliest
          selectedUserSvtIds.addAll(cards.take(v).map((e) => e.id));
        });
      },
    ).showDialog(context);
  }

  void _showFilterPage() {
    switch (mode) {
      case SvtStorageMode.svt:
        FilterPage.show(
          context: context,
          builder: (context) => ServantFilterPage(
            filterData: svtFilterData,
            onChanged: (_) {
              if (mounted) setState(() {});
            },
            planMode: false,
            extraFilters: (_, update) => [
              FilterGroup<SvtType>(
                title: Text(S.current.general_type),
                options: const <SvtType>[.normal, .combineMaterial, .statusUp],
                values: userSvtFilterData.svtType,
                optionBuilder: (v) => Text(v == .normal ? S.current.servant : Transl.enums(v, (e) => e.svtType).l),
                onFilterChanged: (value, _) {
                  if (mounted) setState(() {});
                  update();
                },
              ),
              FilterGroup<UserSvtCombineType>(
                title: const Text('Available Combine Type'),
                showMatchAll: true,
                showInvert: true,
                options: UserSvtCombineType.values,
                values: userSvtFilterData.availableCombines,
                optionBuilder: (v) => Text(v.dispName),
                onFilterChanged: (value, _) {
                  if (mounted) setState(() {});
                  update();
                },
              ),
            ],
          ),
        );
      case SvtStorageMode.equip:
        FilterPage.show(
          context: context,
          builder: (context) => CraftFilterPage(
            filterData: ceFilterData,
            onChanged: (_) {
              if (mounted) setState(() {});
            },
            extraFilters: (_, update) => [
              FilterGroup<bool>(
                title: const Text('Lock status'),
                options: const [false, true],
                values: userEquipFilterData.locked,
                optionBuilder: (v) => Text(v ? '🔐 Locked' : 'Unlocked'),
                onFilterChanged: (value, _) {
                  if (mounted) setState(() {});
                  update();
                },
              ),
              FilterGroup<bool>(
                title: Text(S.current.max_limit_break),
                showMatchAll: true,
                options: const [false, true],
                values: userEquipFilterData.maxLimitBreak,
                optionBuilder: (v) => Text(v ? 'YES' : 'NO'),
                onFilterChanged: (value, _) {
                  if (mounted) setState(() {});
                  update();
                },
              ),
            ],
          ),
        );
    }
  }

  // -----------------------------------------------------------------------------
  // bottom bar
  // -----------------------------------------------------------------------------

  Widget _buildButtonBar() {
    final selected = _selectedCards;
    final List<Widget> buttons = [];

    if (widget.onSelected != null) {
      // picker mode: only the confirm button
      final maxCount = widget.maxSelectionCount;
      final valid = selected.isNotEmpty && (maxCount == null || selected.length <= maxCount);
      buttons.add(buildCompactButton(enabled: valid, onPressed: _confirmPick, text: '确认 ×${selected.length}'));
    } else {
      final remaining = _moveRemainingCapacity();
      buttons.add(
        buildCompactButton(
          enabled: selected.isNotEmpty && selected.length <= remaining,
          onPressed: () => _confirmMove(selected, remaining),
          text: '移动到${_slotName(slot == SvtSlot.main ? SvtSlot.storage : SvtSlot.main)}(剩余$remaining)',
        ),
      );
      if (slot == SvtSlot.main) {
        buttons.add(
          buildCompactButton(
            enabled: selected.isNotEmpty && selected.length <= kMaxSellCount && selected.every(_isSellable),
            onPressed: () => _confirmSell(selected),
            text: '变卖 ×${selected.length}',
          ),
        );
      }
      buttons.add(
        buildCompactButton(
          enabled: selected.isNotEmpty,
          onPressed: () => setState(() {
            selectedUserSvtIds.clear();
          }),
          text: S.current.clear,
        ),
      );
    }

    if (buttons.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Wrap(alignment: WrapAlignment.center, spacing: 8, runSpacing: 2, children: buttons),
    );
  }

  String _cardsSummary(List<UserServantEntity> cards) {
    int servants = 0, embers = 0, fous = 0, equips = 0, others = 0;
    for (final card in cards) {
      switch (_entity(card)?.type) {
        case SvtType.combineMaterial:
          embers++;
        case SvtType.statusUp:
          fous++;
        case SvtType.servantEquip:
          equips++;
        case SvtType.normal:
        case SvtType.heroine:
          servants++;
        default:
          others++;
      }
    }
    return [
      if (servants > 0) '${S.current.servant} $servants',
      if (embers > 0) '种火 $embers',
      if (fous > 0) '芙芙 $fous',
      if (equips > 0) '${S.current.craft_essence} $equips',
      if (others > 0) '${S.current.unknown} $others',
    ].join(' / ');
  }

  void _confirmPick() {
    _validateSelection();
    final cards = _selectedCards;
    if (cards.isEmpty) return;
    Navigator.pop(context, cards);
    widget.onSelected!(cards);
  }

  void _confirmMove(List<UserServantEntity> selected, int remaining) {
    _validateSelection();
    final cards = _selectedCards;
    if (cards.isEmpty || cards.length > remaining) return;
    final targetSlot = slot == SvtSlot.main ? SvtSlot.storage : SvtSlot.main;
    SimpleConfirmDialog(
      title: Text('移动到${_slotName(targetSlot)}'),
      content: Text('共 ${cards.length} 张\n${_cardsSummary(cards)}\n目标剩余容量 $remaining'),
      onTapOk: () {
        final ids = cards.map((e) => e.id).toList();
        runtime.runTask(() {
          if (slot == SvtSlot.main) {
            return agent.storageTakein(userSvtIds: ids);
          } else {
            return agent.storageTakeout(userSvtIds: ids);
          }
        });
      },
    ).showDialog(context);
  }

  void _confirmSell(List<UserServantEntity> selected) {
    _validateSelection();
    final cards = _selectedCards;
    if (cards.isEmpty || cards.length > kMaxSellCount || !cards.every(_isSellable)) return;
    SimpleConfirmDialog(
      title: const Text('变卖'),
      content: Text('共 ${cards.length} 张\n${_cardsSummary(cards)}\n变卖后不可恢复'),
      onTapOk: () {
        runtime.runTask(() {
          return agent.sellServant(servantUserIds: cards.map((e) => e.id).toList(), commandCodeUserIds: const []);
        });
      },
    ).showDialog(context);
  }
}
