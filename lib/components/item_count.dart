import 'package:chaldea/components/components.dart';

//class ClassifiedItemCost {
//  Map<String, int> ascension = {};
//  Map<String, int> skill = {};
//  Map<String, int> dress = {};
//  Map<String, int> all = {};
//
//  void calculate(ItemCost cost, ServantPlan plan) {
//    if (planned && (plan == null || plan.favorite == false)) {
//      return {};
//
//    }
//    Map<String, int> cost = {};
//    List<Map<String, int>> all = [
//      calAscensionCost(planned ? plan.ascensionLv : null),
//      calSkillCost(planned ? plan.skillLv : null),
//      calDressCost(planned ? plan.dressLv : null)
//    ];
//    all.forEach((e) => e.forEach((item, num) {
//          cost[item] = (cost[item] ?? 0) + num;
//        }));
//    return cost;
//  }
//
//  Map<String, int> calAscensionCost(
//      ItemCost itemCost, ServantPlan plan, bool full) {
//    ascension = {};
//    if (itemCost == null ||
//        itemCost.ascension == null ||
//        (!full && plan?.ascensionLv == null)) {
//      return ascension;
//    }
//    List<int> lv = full ? [1, 4] : plan.ascensionLv;
////    List<int> lv = plan.ascensionLv ?? [0, 4];
//    int start = lv[0], end = lv[1];
//    for (int i = start; i < end; i++) {
//      for (var item in itemCost.ascension[i]) {
//        ascension[item.name] = (ascension[item.name] ?? 0) + item.num;
//      }
//    }
//    return ascension;
//  }
//
//  Map<String, int> calSkillCost(
//      ItemCost itemCost, ServantPlan plan, bool full) {
//    skill = {};
//    if (itemCost == null ||
//        itemCost.skill == null ||
//        (!full && plan?.skillLv == null)) {
//      return skill;
//    }
//    List<List<int>> lv = full ? List.generate(3, (i) => [1, 10]) : plan.skillLv;
//    for (int i = 0; i < 3; i++) {
//      int start = lv[i][0], end = lv[i][1];
//      for (int j = start - 1; j < end - 1; j++) {
//        for (var item in itemCost.skill[j]) {
//          skill[item.name] = (skill[item.name] ?? 0) + item.num;
//        }
//      }
//    }
//    return skill;
//  }
//
//  Map<String, int> calDressCost(
//      ItemCost itemCost, ServantPlan plan, bool full) {
//    dress = {};
//    if (itemCost == null ||
//        itemCost.dress == null ||
//        (!full && plan?.dressLv == null)) {
//      return dress;
//    }
//    List<List<int>> lv = full
//        ? List.generate(itemCost.dress.length, (i) => [0, 1])
//        : plan.dressLv;
//    for (int i = 0; i < itemCost.dress.length; i++) {
//      int start = lv[i][0], end = lv[i][1];
//      for (int j = start; j < end; j++) {
//        for (var item in itemCost.dress[i]) {
//          dress[item.name] = (dress[item.name] ?? 0) + item.num;
//        }
//      }
//    }
//    return dress;
//  }
//
//  void sum() {
//    all = {};
//    [ascension, skill, dress].forEach((e) => e.forEach((item, num) {
//          all[item] = (all[item] ?? 0) + num;
//        }));
//  }
//
//  void add(ClassifiedItemCost other) {
//    other.ascension.forEach((name, num) {
//      ascension[name] = ascension[name] ?? 0 + num;
//    });
//    other.skill.forEach((name, num) {
//      skill[name] = skill[name] ?? 0 + num;
//    });
//    other.dress.forEach((name, num) {
//      dress[name] = dress[name] ?? 0 + num;
//    });
//    sum();
//  }
//
//  int getOneCost(String key) {
//    return (ascension[key] ?? 0) + (skill[key] ?? 0) + (dress[key] ?? 0);
//  }
//}
