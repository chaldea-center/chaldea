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
  Timer? _leftTimer;

  Timer? _setTimer(Duration? lapse, VoidCallback callback) {
    if (lapse == null) {
      // don't use Timer(Duration.zero,callback), maybe next microtask
      callback();
      return null;
    } else {
      return Timer(lapse, callback);
    }
  }

  /// Update [itemState] after duration [lapse]
  ///
  Future<void> update(
      {bool shouldBroadcast = true, Duration? lapse, bool withFuture = false}) {
    void callback() {
      updateSvtItems(shouldBroadcast: false);
      updateEventItems(shouldBroadcast: false);
      updateLeftItems(shouldBroadcast: shouldBroadcast);
    }

    // usually await this future to notify app update
    if (lapse != null && withFuture) {
      return Future.delayed(lapse, callback);
    } else {
      _topTimer?.cancel();
      _svtTimer?.cancel();
      _eventTimer?.cancel();
      _topTimer = _setTimer(lapse, callback);
      return Future.value();
    }
  }

  void updateSvtItems({bool shouldBroadcast = true, Duration? lapse}) {
    void callback() {
      // priority is shared cross users!
      final Map<int, ServantStatus> priorityFiltered = Map.fromEntries(db
          .curUser.servants.entries
          .where((entry) => db.userData.svtFilter.priority
              .singleValueFilter(entry.value.priority.toString())));
      svtItemDetail.update(
          curStat: priorityFiltered, targetPlan: db.curUser.curSvtPlan);
      updateLeftItems(shouldBroadcast: shouldBroadcast);
    }

    _svtTimer?.cancel();
    _leftTimer?.cancel();
    _svtTimer = _setTimer(lapse, callback);
  }

  void updateEventItems({bool shouldBroadcast = true, Duration? lapse}) {
    void callback() {
      eventItems = db.gameData.events.getAllItems(db.curUser.events);
      updateLeftItems(shouldBroadcast: shouldBroadcast);
    }

    _eventTimer?.cancel();
    _leftTimer?.cancel();
    _eventTimer = _setTimer(lapse, callback);
  }

  void updateLeftItems({bool shouldBroadcast = true, Duration? lapse}) {
    void callback() {
      leftItems =
          sumDict([eventItems, db.curUser.items, multiplyDict(svtItems, -1)]);
      if (shouldBroadcast) {
        db.notifyDbUpdate();
      }
    }

    _leftTimer?.cancel();
    _leftTimer = _setTimer(lapse, callback);
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
  T appendSkill;
  T extra;

  SvtParts({
    T? ascension,
    T? skill,
    T? dress,
    T? appendSkill,
    T? extra,
    T? summation,
    T k()?,
  })  : assert(ascension != null &&
                skill != null &&
                dress != null &&
                appendSkill != null &&
                extra != null ||
            k != null),
        ascension = ascension ?? k!(),
        skill = skill ?? k!(),
        dress = dress ?? k!(),
        appendSkill = appendSkill ?? k!(),
        extra = extra ?? k!(),
        summation = summation ?? k?.call();

  SvtParts<T2> copyWith<T2>([T2 f(T e)?]) {
    return SvtParts<T2>(
      ascension: f == null ? ascension as T2 : f(ascension),
      skill: f == null ? skill as T2 : f(skill),
      dress: f == null ? dress as T2 : f(dress),
      appendSkill: f == null ? appendSkill as T2 : f(skill),
      extra: f == null ? extra as T2 : f(extra),
      summation: f == null
          ? summation as T2?
          : summation != null
              ? f(summation!)
              : null,
    );
  }

  List<T> get values => [ascension, skill, dress, appendSkill, extra];

  List<T> valuesIfExtra(String key) {
    return Items.extraPlanningItems.contains(key)
        ? [extra]
        : [ascension, skill, dress, appendSkill];
  }

  /// calculate [summation] before using!!!
  List<T> get valuesWithSum =>
      [ascension, skill, dress, appendSkill, extra, summation!];

  @override
  String toString() {
    return '$runtimeType<$T>(\n  ascension:$ascension,\n  skill:$skill,\n'
        '  dress:$dress,\n  appendSkill:$appendSkill,\n  extra:$extra)';
  }
}
