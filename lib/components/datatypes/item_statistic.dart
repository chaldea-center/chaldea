/// statistics of items
part of datatypes;

class ItemStatistics {
  SvtCostItems svtItemDetail = SvtCostItems();

  Map<String, int> get svtItems => svtItemDetail.planItemCounts.summation!;
  Map<String, int> eventItems = {};
  Map<String, int> leftItems = {};

  ItemStatistics();

  /// Clear statistic data, all data will be calculated again next calling.
  /// After importing dataset, we should call this to clear, then call
  /// [update] to refresh data.
  void clear() {
    svtItemDetail = SvtCostItems();
    eventItems = {};
    leftItems = {};
  }

  Timer? _topTimer;
  Timer? _svtTimer;
  Timer? _eventTimer;

  Timer? _setTimer(Duration? lapse, VoidCallback callback) {
    if (lapse == null) {
      // don't use Timer(Duration.zero,callback), maybe next microtask
      callback();
      return null;
    } else {
      return Timer(lapse, callback);
    }
  }

  Future<void> update({bool shouldBroadcast = true, Duration? lapse}) async {
    VoidCallback callback = () async {
      await updateSvtItems(shouldBroadcast: false, lapse: null);
      await updateEventItems(shouldBroadcast: false, lapse: null);
      await updateLeftItems(shouldBroadcast: shouldBroadcast, lapse: null);
    };
    _topTimer?.cancel();
    _svtTimer?.cancel();
    _eventTimer?.cancel();

    _topTimer = _setTimer(lapse, callback);
  }

  Future<void> updateSvtItems(
      {bool shouldBroadcast = true, Duration? lapse}) async {
    _svtTimer?.cancel();
    VoidCallback callback = () async {
      // priority is shared cross users!
      final Map<int, ServantStatus> priorityFiltered = Map.fromEntries(db
          .curUser.servants.entries
          .where((entry) => db.userData.svtFilter.priority
              .singleValueFilter(entry.value.priority.toString())));
      svtItemDetail.update(
          curStat: priorityFiltered, targetPlan: db.curUser.curSvtPlan);
      await updateLeftItems(shouldBroadcast: shouldBroadcast);
    };
    _svtTimer = _setTimer(lapse, callback);
  }

  Future<void> updateEventItems(
      {bool shouldBroadcast = true, Duration? lapse}) async {
    VoidCallback callback = () async {
      eventItems = db.gameData.events.getAllItems(db.curUser.events);
      await updateLeftItems(shouldBroadcast: shouldBroadcast);
    };
    _eventTimer = _setTimer(lapse, callback);
  }

  Future<void> updateLeftItems(
      {bool shouldBroadcast = true, Duration? lapse}) async {
    if (lapse != null) {
      await Future.delayed(lapse);
    }
    leftItems =
        sumDict([eventItems, db.curUser.items, multiplyDict(svtItems, -1)]);
    if (shouldBroadcast) {
      db.notifyDbUpdate();
    }
  }
}

class SvtCostItems {
  //Map<SvtNo, List<Map<ItemKey,num>>>
  SvtParts<Map<int, Map<String, int>>> planCountBySvt = SvtParts(k: () => {}),
      allCountBySvt = SvtParts(k: () => {});

  SvtParts<Map<int, Map<String, int>>> getCountBySvt([bool planned = true]) =>
      planned ? planCountBySvt : allCountBySvt;

  // Map<ItemKey, List<Map<SvtNo, num>>>
  SvtParts<Map<String, Map<int, int>>> planCountByItem = SvtParts(k: () => {}),
      allCountByItem = SvtParts(k: () => {});

  SvtParts<Map<String, Map<int, int>>> getCountByItem([bool planned = true]) =>
      planned ? planCountByItem : allCountByItem;

  // Map<ItemKey, num>
  SvtParts<Map<String, int>> planItemCounts = SvtParts(k: () => {}),
      allItemCounts = SvtParts(k: () => {});

  SvtParts<Map<String, int>> getItemCounts([bool planned = true]) =>
      planned ? planItemCounts : allItemCounts;
  bool _needUpdateAll = true;

  void update(
      {required Map<int, ServantStatus> curStat,
      required Map<int, ServantPlan> targetPlan}) {
    planCountBySvt = SvtParts(k: () => {});
    planCountByItem = SvtParts(k: () => {});
    planItemCounts = SvtParts(k: () => {});
    if (_needUpdateAll) {
      allCountBySvt = SvtParts(k: () => {});
      allCountByItem = SvtParts(k: () => {});
      allItemCounts = SvtParts(k: () => {});
    }
    // bySvt
    db.gameData.servantsWithUser.forEach((no, svt) {
      final cur = curStat[no]?.curVal, target = targetPlan[no];
      // planned
      SvtParts<Map<String, int>> a, b;
      if (cur?.favorite == true) {
        a = svt.getAllCostParts(cur: cur, target: target);
      } else {
        a = SvtParts(k: () => {});
      }
      a.summation = sumDict(a.values);
      b = svt.getAllCostParts(all: true);
      b.summation = sumDict(b.values);
      for (var i = 0; i < planCountBySvt.valuesWithSum.length; i++) {
        planCountBySvt.valuesWithSum[i][no] = a.valuesWithSum[i];
        if (_needUpdateAll) {
          allCountBySvt.valuesWithSum[i][no] = b.valuesWithSum[i];
        }
      }
    });

    // byItem
    for (String itemKey in db.gameData.items.keys) {
      for (var i = 0; i < planCountBySvt.values.length; i++) {
        planCountBySvt.values[i].forEach((svtNo, cost) {
          planCountByItem.values[i].putIfAbsent(itemKey, () => {})[svtNo] =
              cost[itemKey] ?? 0;
        });
        if (_needUpdateAll) {
          allCountBySvt.values[i].forEach((svtNo, cost) {
            allCountByItem.values[i].putIfAbsent(itemKey, () => {})[svtNo] =
                cost[itemKey] ?? 0;
          });
        }
      }
      planCountByItem.summation![itemKey] =
          sumDict(planCountByItem.values.map((e) => e[itemKey]));
      if (_needUpdateAll) {
        allCountByItem.summation![itemKey] =
            sumDict(allCountByItem.values.map((e) => e[itemKey]));
      }
    }

    // itemCounts
    for (var i = 0; i < planItemCounts.valuesWithSum.length; i++) {
      for (String itemKey in db.gameData.items.keys) {
        planItemCounts.valuesWithSum[i][itemKey] =
            sum(planCountByItem.valuesWithSum[i][itemKey]?.values ?? <int>[]);
        allItemCounts.valuesWithSum[i][itemKey] =
            sum(allCountByItem.valuesWithSum[i][itemKey]?.values ?? <int>[]);
      }
    }
    _needUpdateAll = false;
  }
}

/// replace with List(3)
class SvtParts<T> {
  /// used only if [T] extends [num]
  T? summation;

  T ascension;
  T skill;
  T dress;
  T grailAscension;

  SvtParts({
    T? ascension,
    T? skill,
    T? dress,
    T? grailAscension,
    T? summation,
    T k()?,
  })  : assert(ascension != null &&
                skill != null &&
                dress != null &&
                grailAscension != null ||
            k != null),
        ascension = ascension ?? k!(),
        skill = skill ?? k!(),
        dress = dress ?? k!(),
        grailAscension = grailAscension ?? k!(),
        summation = summation ?? k?.call();

  SvtParts<T2> copyWith<T2>([T2 f(T e)?]) {
    return SvtParts<T2>(
      ascension: f == null ? ascension as T2 : f(ascension),
      skill: f == null ? skill as T2 : f(skill),
      dress: f == null ? dress as T2 : f(dress),
      grailAscension: f == null ? grailAscension as T2 : f(grailAscension),
      summation: f == null
          ? summation as T2?
          : summation != null
          ? f(summation!)
          : null,
    );
  }

  List<T> get values => [ascension, skill, dress, grailAscension];

  List<T> valuesIfGrail(String key) {
    return key == Item.grail ? [grailAscension] : [ascension, skill, dress];
  }

  /// calculate [summation] before using!!!
  List<T> get valuesWithSum =>
      [ascension, skill, dress, grailAscension, summation!];

  @override
  String toString() {
    return '$runtimeType<$T>(\n  ascension:$ascension,\n  skill:$skill,\n'
        '  dress:$dress)\n  grailAscension:$grailAscension';
  }
}
