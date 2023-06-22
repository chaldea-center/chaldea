// ignore_for_file: prefer_final_fields

import 'dart:async';
import 'dart:math';

import 'package:chaldea/models/models.dart';
import 'package:chaldea/utils/utils.dart';

enum SvtMatCostDetailType {
  consumed,
  demands,
  full,
  ;

  bool shouldCount(LockPlan? plan) {
    switch (this) {
      case SvtMatCostDetailType.consumed:
        return plan == LockPlan.full;
      case SvtMatCostDetailType.demands:
        return plan == LockPlan.planned;
      case SvtMatCostDetailType.full:
        return true;
    }
  }
}

class ItemCenter {
  final StreamController<ItemCenter> streamController = StreamController();

  void dispose() {
    streamController.close();
  }

  /// settings
  bool includingEvents = true;

  User get user => _user ?? db.curUser;
  final User? _user;

  ItemCenter([this._user]);

  List<int> _validItems = [];
  List<int> get validItems => List.unmodifiable(_validItems);
  late _MatrixManager<int, int, SvtMatCostDetail<int>> _svtCur; //0->cur
  late _MatrixManager<int, int, SvtMatCostDetail<int>> _svtDemands; //cur->target
  late _MatrixManager<int, int, SvtMatCostDetail<int>> _svtFull; //0->max
  late _MatrixManager<int, int, int> _eventItem;

  // statistics
  Map<int, int> _statSvtConsumed = {};
  Map<int, int> statSvtDemands = {};
  Map<int, int> _statSvtFull = {};

  Map<int, int> statClassBoard = {};

  Map<int, int> _statEvent = {};
  Map<int, int> _statMainStory = {};
  Map<int, int> _statTicket = {};
  Map<int, int> statObtain = {};

  Map<int, int> itemLeft = {};

  int demandOf(int itemId) {
    return (statSvtDemands[itemId] ?? 0) + (statClassBoard[itemId] ?? 0);
  }

  void init() {
    db.gameData.updateDupServants(db.curUser.dupServantMapping);
    _validItems.clear();
    final List<int> _svtIds = [];
    for (final item in db.gameData.items.values) {
      if (![ItemCategory.other, ItemCategory.event].contains(item.category)) {
        _validItems.add(item.id);
      }
    }
    _validItems.addAll(Items.specialItems);
    _validItems.addAll(Items.specialSvtMat);
    _validItems = _validItems.toSet().toList();
    // svt
    for (final svt in db.gameData.servantsWithDup.values) {
      if (svt.isUserSvt) _svtIds.add(svt.collectionNo);
    }
    _svtCur = _MatrixManager(dim1: _svtIds, dim2: _validItems, init: () => SvtMatCostDetail(() => 0));
    _svtDemands = _MatrixManager(dim1: _svtIds, dim2: _validItems, init: () => SvtMatCostDetail(() => 0));
    _svtFull = _MatrixManager(dim1: _svtIds, dim2: _validItems, init: () => SvtMatCostDetail(() => 0));
    // events
    _eventItem = _MatrixManager(
      dim1: db.gameData.events.keys.toList(),
      dim2: _validItems,
      init: () => 0,
    );
    calculate();
  }

  void calculate() {
    updateSvts(all: true, notify: false);
    updateEvents(all: true, notify: false);
    updateMainStory(notify: false);
    updateExchangeTickets(notify: false);
    updateClassBoard(notify: false);
    updateLeftItems();
  }

  void updateSvts({List<Servant> svts = const [], bool all = false, bool notify = true}) {
    for (final svt in svts) {
      _updateOneSvt(svt.collectionNo);
    }
    if (all) {
      for (int svtId in _svtCur.dim1) {
        _updateOneSvt(svtId, max: false);
        _updateOneSvt(svtId, max: true);
      }
      _updateSvtStat(_svtFull, _statSvtFull);
    }
    _updateSvtStat(_svtCur, _statSvtConsumed);
    _updateSvtStat(_svtDemands, statSvtDemands);
    if (notify) {
      updateLeftItems();
    }
  }

  void _updateSvtStat(_MatrixManager<int, int, SvtMatCostDetail<int>> detail, Map<int, int> stat) {
    stat.clear();
    List<int> itemSum = List.generate(detail.dim2.length, (index) => 0);
    for (int itemIndex = 0; itemIndex < itemSum.length; itemIndex++) {
      for (int svtIndex = 0; svtIndex < detail.dim1.length; svtIndex++) {
        itemSum[itemIndex] += detail._matrix[svtIndex][itemIndex].all;
      }
    }
    stat.addAll(Map.fromIterables(detail.dim2, itemSum));
  }

  void _updateOneSvt(int svtId, {bool max = false}) {
    final svtIndex = _svtCur._dim1Map[svtId];
    final svt = db.gameData.servantsWithDup[svtId];
    if (svt == null || svtIndex == null) return;
    final cur = user.svtStatusOf(svtId).cur;
    final consumed = calcOneSvt(svt, SvtPlan.empty()..favorite = cur.favorite, cur, priorityFiltered: true);
    final demands = calcOneSvt(svt, cur, user.svtPlanOf(svtId), priorityFiltered: true);

    for (int itemIndex = 0; itemIndex < _validItems.length; itemIndex++) {
      _svtCur._matrix[svtIndex][itemIndex]
          .updateFrom<Map<int, int>>(consumed, (_, part) => part[_validItems[itemIndex]] ?? 0);
      _svtDemands._matrix[svtIndex][itemIndex]
          .updateFrom<Map<int, int>>(demands, (_, part) => part[_validItems[itemIndex]] ?? 0);
    }
    if (max) {
      final allDemands = calcOneSvt(svt, SvtPlan.empty()..favorite = true, SvtPlan.max(svt));
      for (int itemIndex = 0; itemIndex < _validItems.length; itemIndex++) {
        _svtFull._matrix[svtIndex][itemIndex]
            .updateFrom<Map<int, int>>(allDemands, (_, part) => part[_validItems[itemIndex]] ?? 0);
      }
    }
  }

  SvtMatCostDetail<Map<int, int>> calcOneSvt(Servant svt, SvtPlan cur, SvtPlan target,
      {bool priorityFiltered = false}) {
    final detail = SvtMatCostDetail<Map<int, int>>(() => {});
    if (!cur.favorite) {
      return detail;
    }
    if (priorityFiltered && !db.settings.svtFilterData.priority.matchOne(user.svtStatusOf(svt.collectionNo).priority)) {
      return detail;
    }
    detail.ascension = _sumMat(svt.ascensionMaterials, [for (int lv = cur.ascension; lv < target.ascension; lv++) lv]);

    for (int skill = 0; skill < 3; skill++) {
      Maths.sumDict([
        detail.activeSkill,
        _sumMat(svt.skillMaterials, [for (int lv = cur.skills[skill]; lv < target.skills[skill]; lv++) lv])
      ], inPlace: true);
    }

    for (int skill = 0; skill < 3; skill++) {
      Maths.sumDict([
        detail.appendSkill,
        _sumMat(svt.appendSkillMaterials,
            [for (int lv = cur.appendSkills[skill]; lv < target.appendSkills[skill]; lv++) lv])
      ], inPlace: true);
    }

    detail.costume = _sumMat(svt.costumeMaterials, [
      for (final charaId in target.costumes.keys)
        if (target.costumes[charaId]! > 0 && (cur.costumes[charaId] ?? 0) == 0) charaId
    ]);
    final coinId = svt.coin?.item.id;
    int coin = 0;
    if (coinId != null) {
      for (int skill = 0; skill < 3; skill++) {
        if (cur.appendSkills[skill] == 0 && target.appendSkills[skill] > 0) {
          coin += 120;
        }
      }
      final grailLvs = (svt.grailedLv(target.grail) - max(svt.grailedLv(cur.grail), 100));
      coin += (max(0, grailLvs) ~/ 2) * 30;
    }

    detail.special = {
      Items.hpFou4: max(0, target.fouHp - cur.fouHp),
      Items.atkFou4: max(0, target.fouAtk - cur.fouAtk),
      Items.hpFou3: max(0, target.fouHp3 - cur.fouHp3),
      Items.atkFou3: max(0, target.fouAtk3 - cur.fouAtk3),
      Items.grailId: max(0, target.grail - cur.grail),
      // Items.lanternId: max(0, target.bondLimit - cur.bondLimit),
      Items.qpId: QpCost.grail(svt.rarity, cur.grail, target.grail) + QpCost.bondLimit(cur.bondLimit, target.bondLimit),
      if (coinId != null) coinId: coin,
    };

    detail.all = Maths.sumDict(detail.parts);
    return detail;
  }

  void _updateOneEvent(int eventId) {
    final eventIndex = _eventItem._dim1Map[eventId];
    final event = db.gameData.events[eventId];
    if (eventIndex == null || event == null) return;
    final eventItems = calcOneEvent(event, user.limitEventPlanOf(event.id));
    for (int itemIndex = 0; itemIndex < _validItems.length; itemIndex++) {
      _eventItem._matrix[eventIndex][itemIndex] = eventItems[_validItems[itemIndex]] ?? 0;
    }
  }

  void updateEvents({List<Event> events = const [], bool all = false, bool notify = true}) {
    for (final event in events) {
      _updateOneEvent(event.id);
    }
    if (all) {
      for (int eventId in _eventItem.dim1) {
        _updateOneEvent(eventId);
      }
    }
    _statEvent.clear();
    List<int> itemSum = List.generate(_eventItem.dim2.length, (index) => 0);
    for (int itemIndex = 0; itemIndex < itemSum.length; itemIndex++) {
      for (int eventIndex = 0; eventIndex < _eventItem.dim1.length; eventIndex++) {
        itemSum[itemIndex] += _eventItem._matrix[eventIndex][itemIndex];
      }
    }
    _statEvent.addAll(Map.fromIterables(_eventItem.dim2, itemSum));
    if (notify) {
      updateLeftItems();
    }
  }

  /// shop/point rewards/mission rewards/Tower rewards/lottery/treasureBox/fixedDrop/wars rewards
  Map<int, int> calcOneEvent(Event event, LimitEventPlan plan, {bool includingGrailToLore = true}) {
    Map<int, int> result = {};
    // shop
    if (!plan.enabled) return result;
    if (plan.shop) {
      for (final shop in event.shop) {
        final counts = event.itemShop[shop.id]?.multiple(plan.shopBuyCount[shop.id] ?? shop.limitNum);
        if (counts != null) {
          result.addDict(counts);
        }
      }
    }
    if (plan.point) {
      result.addDict(event.itemPointReward);
    }
    if (plan.mission) {
      result.addDict(event.itemMission);
    }
    if (plan.tower) {
      result.addDict(event.itemTower);
    }
    for (final lottery in event.lotteries) {
      int planBoxNum = plan.lotteries[lottery.id] ?? 0;
      if (planBoxNum <= 0) continue;
      final boxItems = event.itemLottery[lottery.id] ?? {};
      for (int boxIndex in boxItems.keys) {
        if (boxIndex < planBoxNum) {
          result.addDict(boxItems[boxIndex] ?? {});
        }
      }
      int maxBoxIndex = Maths.max(boxItems.keys, 0); //0-9,10
      if (!lottery.limited && planBoxNum > maxBoxIndex) {
        result.addDict(boxItems[maxBoxIndex]?.multiple(planBoxNum - maxBoxIndex - 1) ?? {});
      }
    }
    for (final box in event.treasureBoxes) {
      event.itemTreasureBox[box.id]?.forEach((itemId, setNum) {
        result.addNum(itemId, setNum * (plan.treasureBoxItems[box.id]?[itemId] ?? 0));
      });
    }
    if (plan.fixedDrop) {
      result.addDict(event.itemWarDrop);
    }
    if (plan.questReward) {
      result.addDict(event.itemWarReward);
    }
    for (final extraItems in event.extra.extraFixedItems) {
      if (plan.extraFixedItems[extraItems.id] == true) {
        result.addDict(extraItems.items);
      }
    }
    for (final extraItems in event.extra.extraItems) {
      result.addDict({
        for (final itemId in extraItems.items.keys) itemId: plan.extraItems[extraItems.id]?[itemId] ?? 0,
      });
    }
    if (!event.isEmpty) {
      result.addDict(plan.customItems);
    }
    int grailToCrystal = result[Items.grailToCrystalId] ?? 0;
    if (grailToCrystal > 0 && includingGrailToLore) {
      plan.rerunGrails = plan.rerunGrails.clamp(0, grailToCrystal);
      result.addNum(Items.grailId, plan.rerunGrails);
      result.addNum(Items.crystalId, grailToCrystal - plan.rerunGrails);
      result.remove(Items.grailToCrystalId);
    }
    return result;
  }

  void updateMainStory({bool notify = true}) {
    _statMainStory.clear();
    for (final war in db.gameData.wars.values) {
      if (war.isMainStory) {
        final plan = user.mainStoryOf(war.id);
        if (plan.fixedDrop) _statMainStory.addDict(war.itemDrop);
        if (plan.questReward) _statMainStory.addDict(war.itemReward);
      }
    }
    if (notify) {
      updateLeftItems();
    }
  }

  void updateExchangeTickets({bool notify = true}) {
    _statTicket.clear();
    for (final ticket in db.gameData.exchangeTickets.values) {
      final plan = user.ticketOf(ticket.id);
      final items = ticket.of(user.region);
      for (int i = 0; i < items.length; i++) {
        _statTicket.addNum(items[i], plan[i] * ticket.multiplier);
      }
    }
    if (notify) {
      updateLeftItems();
    }
  }

  void updateClassBoard({bool notify = true}) {
    statClassBoard.clear();
    statClassBoard.addAll(calcClassBoardCost(SvtMatCostDetailType.demands));
    if (notify) {
      updateLeftItems();
    }
  }

  Map<int, int> calcClassBoardCost(SvtMatCostDetailType type) {
    Map<int, int> items = {};
    for (final board in db.gameData.classBoards.values) {
      final boardPlan = user.classBoards[board.id] ?? ClassBoardPlan();
      for (final square in board.squares) {
        final lock = square.lock;
        if (lock != null) {
          final plan = boardPlan.unlockSquares[square.id];
          if (type.shouldCount(plan)) {
            for (final itemAmount in lock.items) {
              items.addNum(itemAmount.itemId, itemAmount.amount);
            }
          }
        }
        if (type.shouldCount(boardPlan.enhancedSquares[square.id])) {
          for (final itemAmount in square.items) {
            items.addNum(itemAmount.itemId, itemAmount.amount);
          }
        }
      }
    }
    return items;
  }

  void updateLeftItems() {
    itemLeft.clear();
    if (includingEvents) {
      statObtain = Maths.sumDict([_statEvent, _statMainStory, _statTicket]);
    } else {
      statObtain = {};
    }
    itemLeft
      ..addDict(user.items)
      ..addDict(statObtain)
      ..addDict(statSvtDemands.multiple(-1))
      ..addDict(statClassBoard.multiple(-1));
    streamController.sink.add(this);
    db.notifyUserdata();
  }

  Map<int, SvtMatCostDetail<int>> getItemCostDetail(int itemId, SvtMatCostDetailType type) {
    Map<int, SvtMatCostDetail<int>> details = {};
    final target = getSvtMatrix(type);
    int? itemIndex = target._dim2Map[itemId];
    if (itemIndex == null) return details;
    for (int i = 0; i < target.dim1.length; i++) {
      final v = target._matrix[i][itemIndex];
      if (v.all > 0) {
        details[target.dim1[i]] = v.copy();
      }
    }
    return details;
  }

  _MatrixManager<int, int, SvtMatCostDetail<int>> getSvtMatrix(SvtMatCostDetailType type) {
    return type == SvtMatCostDetailType.consumed
        ? _svtCur
        : type == SvtMatCostDetailType.demands
            ? _svtDemands
            : _svtFull;
  }

  SvtMatCostDetail<Map<int, int>> getSvtCostDetail(int svtId, SvtMatCostDetailType type) {
    final target = getSvtMatrix(type);
    final svtIndex = target._dim1Map[svtId];
    final details = SvtMatCostDetail<Map<int, int>>(() => {});
    if (svtIndex == null) return details;
    for (int i = 0; i < target.dim2.length; i++) {
      final v = target._matrix[svtIndex][i];
      if (v.all <= 0) continue;
      final item = target.dim2[i];
      details.updateFrom<int>(v, (p1, p2) => p1..addNum(item, p2));
    }
    return details;
  }
}

class _MatrixManager<K1, K2, V> {
  final List<K1> dim1; // svt, event
  final List<K2> dim2; // item
  final Map<K1, int> _dim1Map;
  final Map<K2, int> _dim2Map;
  final List<List<V>> _matrix;
  final V Function() init;

  _MatrixManager({required this.dim1, required this.dim2, required this.init})
      : assert(dim1.toSet().length == dim1.length),
        assert(dim2.toSet().length == dim2.length),
        _dim1Map = {
          for (int index = 0; index < dim1.length; index++) dim1[index]: index,
        },
        _dim2Map = {
          for (int index = 0; index < dim2.length; index++) dim2[index]: index,
        },
        _matrix = List.generate(dim1.length, (_) => List.generate(dim2.length, (__) => init()));

  void addDim1(K1 k1) {
    if (dim1.contains(k1)) return;
    dim1.add(k1);
    _dim1Map[k1] = dim1.length - 1;
    _matrix.add(List.generate(dim2.length, (index) => init()));
  }

  void removeDim1(K1 k1) {
    final index = _dim1Map.remove(k1);
    if (index != null) {
      _matrix.removeAt(index);
    }
  }

  V loc(int x, int y) {
    return _matrix[x][y];
  }
}

class SvtMatCostDetail<T> {
  T ascension;
  T activeSkill;
  T appendSkill;
  T costume;
  T special;
  T all;

  SvtMatCostDetail(T Function() k)
      : ascension = k(),
        activeSkill = k(),
        appendSkill = k(),
        costume = k(),
        special = k(),
        all = k();

  SvtMatCostDetail._({
    required this.ascension,
    required this.activeSkill,
    required this.appendSkill,
    required this.costume,
    required this.special,
    required this.all,
  });

  List<T> get parts => [ascension, activeSkill, appendSkill, costume, special];

  void updateFrom<S>(SvtMatCostDetail<S> other, T Function(T p1, S p2) converter) {
    ascension = converter(ascension, other.ascension);
    activeSkill = converter(activeSkill, other.activeSkill);
    appendSkill = converter(appendSkill, other.appendSkill);
    costume = converter(costume, other.costume);
    special = converter(special, other.special);
    all = converter(all, other.all);
  }

  @override
  String toString() {
    return '$runtimeType(\n'
        '  ascension  : $ascension,\n'
        '  activeSkill: $activeSkill,\n'
        '  appendSkill: $appendSkill,\n'
        '  costume    : $costume,\n'
        '  special    : $special,\n'
        '  all        : $all,\n'
        ')';
  }

  SvtMatCostDetail<T> copy() {
    return SvtMatCostDetail._(
      ascension: ascension,
      activeSkill: activeSkill,
      appendSkill: appendSkill,
      costume: costume,
      special: special,
      all: all,
    );
  }
}

extension SvtMatCostDetailInt on SvtMatCostDetail<int> {
  void add(SvtMatCostDetail<int> other) {
    ascension += other.ascension;
    activeSkill += other.activeSkill;
    appendSkill += other.appendSkill;
    costume += other.costume;
    special += other.special;
    all += other.all;
  }
}

/// shop/point rewards/mission rewards/Tower rewards/lottery/treasureBox/fixedDrop/wars rewards
class EventMatCostDetail<T> {
  T shop;
  T point;
  T mission;
  T tower;
  T lottery;
  T treasureBox;
  T fixedDrop;
  T questReward;

  EventMatCostDetail(T Function() init)
      : shop = init(),
        point = init(),
        mission = init(),
        tower = init(),
        lottery = init(),
        treasureBox = init(),
        fixedDrop = init(),
        questReward = init();
}

Map<int, int> _sumMat(Map<int, LvlUpMaterial> matDetail, List<int> lvs) {
  Map<int, int> mats = {};
  for (int lv in lvs) {
    final lvMat = matDetail[lv];
    if (lvMat != null) {
      mats.addNum(Items.qpId, lvMat.qp);
      for (final itemAmount in lvMat.items) {
        final itemId = itemAmount.item?.id;
        if (itemId == null) continue;
        mats.addNum(itemId, itemAmount.amount);
      }
    }
  }
  return mats;
}

class QpCost {
  const QpCost._();

  static int grail(int rarity, int cur, int target) {
    int qp = 0;
    for (int grail = cur + 1; grail <= target; grail++) {
      qp += db.gameData.constData.svtGrailCost[rarity]![grail]?.qp ?? 0;
    }
    return qp;
  }

  static int bondLimit(int cur, int target) {
    int qp = 0;
    for (int lv = cur; lv < target; lv++) {
      qp += db.gameData.constData.bondLimitQp[lv] ?? 0;
    }
    return qp;
  }
}
