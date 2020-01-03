/// statistics of items
part of datatypes;

class ItemStatistics {
  SvtCostItems svtItemDetail = SvtCostItems();

  Map<String, int> get svtItems => svtItemDetail.planItemCounts.summation;
  Map<String, int> eventItems;
  Map<String, int> leftItems;

  ItemStatistics();

  void update([User user]) {
    user ??= db.curUser;
    updateSvtItems(user);
    updateEventItems(user);
    // print('$runtimeType all updated.');
  }

  void updateSvtItems([User user]) {
    user ??= db.curUser;
    svtItemDetail.update(curStat: user.servants, targetPlan: user.curSvtPlan);
    updateLeftItems(user);
    // print('$runtimeType svt part updated.');
  }

  void updateEventItems([User user]) {
    user ??= db.curUser;
    eventItems = db.gameData.events.getAllItems(user.events);
    updateLeftItems(user);
    // print('$runtimeType event part updated.');
  }

  void updateLeftItems([User user]) {
    user ??= db.curUser;
    leftItems = sumDict([eventItems, user.items, multiplyDict(svtItems, -1)]);
  }
}

class SvtCostItems {
  //Map<SvtNo, List<Map<ItemKey,num>>>
//  Map<int, SvtParts<Map<String, int>>> planCountBySvt, allCountBySvt;
  SvtParts<Map<int, Map<String, int>>> planCountBySvt, allCountBySvt;

  // Map<ItemKey, List<Map<SvtNo, num>>>
//  Map<String, SvtParts<Map<int, int>>> planCountByItem, allCountByItem;
  SvtParts<Map<String, Map<int, int>>> planCountByItem, allCountByItem;

//  Map<String, SvtParts<int>> planItemCounts, allItemCounts;
  SvtParts<Map<String, int>> planItemCounts, allItemCounts;

  void update(
      {Map<int, ServantStatus> curStat, Map<int, ServantPlan> targetPlan}) {
    planCountBySvt = SvtParts(k: () => {});
    allCountBySvt = SvtParts(k: () => {});
    planCountByItem = SvtParts(k: () => {});
    allCountByItem = SvtParts(k: () => {});
    planItemCounts = SvtParts(k: () => {});
    allItemCounts = SvtParts(k: () => {});
    // bySvt
    db.gameData.servants.forEach((no, svt) {
      final cur = curStat[no]?.curVal, target = targetPlan[no];
      // planned
      SvtParts<Map<String, int>> a, b;
      if (cur?.favorite == true && target?.favorite == true) {
        a = svt.getAllCostParts(cur: cur, target: target);
      } else {
        a = SvtParts(k: () => {});
      }
      a.summation = sumDict(a.values);
      b = svt.getAllCostParts(all: true);
      b.summation = sumDict(b.values);
      for (var i = 0; i < 4; i++) {
        planCountBySvt.valuesWithSum[i][no] = a.valuesWithSum[i];
        allCountBySvt.valuesWithSum[i][no] = b.valuesWithSum[i];
      }
    });

    // byItem
    for (String itemKey in db.gameData.items.keys) {
      for (var i = 0; i < 3; i++) {
        planCountBySvt.values[i].forEach((svtNo, cost) {
          planCountByItem.values[i].putIfAbsent(itemKey, () => {})[svtNo] =
              cost[itemKey] ?? 0;
        });
        allCountBySvt.values[i].forEach((svtNo, cost) {
          allCountByItem.values[i].putIfAbsent(itemKey, () => {})[svtNo] =
              cost[itemKey] ?? 0;
        });
      }
      planCountByItem.summation[itemKey] =
          sumDict(planCountByItem.values.map((e) => e[itemKey]));
      allCountByItem.summation[itemKey] =
          sumDict(allCountByItem.values.map((e) => e[itemKey]));
    }

    // itemCounts
    for (var i = 0; i < 4; i++) {
      for (String itemKey in db.gameData.items.keys) {
        planItemCounts.valuesWithSum[i][itemKey] =
            sum(planCountByItem.valuesWithSum[i][itemKey].values);
        allItemCounts.valuesWithSum[i][itemKey] =
            sum(allCountByItem.valuesWithSum[i][itemKey].values);
      }
    }
  }
}

/// replace with List(3)
class SvtParts<T> {
  /// used only if [T] extends [num]
  T summation;

  T ascension;
  T skill;
  T dress;

  SvtParts({this.ascension, this.skill, this.dress, T k()}) {
    if (k != null) {
      ascension ??= k();
      skill ??= k();
      dress ??= k();
      summation ??= k();
    }
  }

  SvtParts<T2> copyWith<T2>([T2 f(T e)]) {
    return SvtParts<T2>(
      ascension: f == null ? ascension : f(ascension),
      skill: f == null ? skill : f(skill),
      dress: f == null ? dress : f(dress),
    );
  }

  List<T> get values => [ascension, skill, dress];

  List<T> get valuesWithSum => [ascension, skill, dress, summation];

  @override
  String toString() {
    return '$runtimeType<$T>(\n  ascension:$ascension,\n  skill:$skill,\n  dress:$dress)';
  }
}
