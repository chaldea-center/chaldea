library userdata;

import 'package:chaldea/generated/l10n.dart';
import 'package:json_annotation/json_annotation.dart';

import '../../packages/language.dart';
import '../../utils/basic.dart';
import '../../utils/extension.dart';

part '../../generated/models/userdata/userdata.g.dart';

/// user data will be shared across devices and cloud
@JsonSerializable()
class UserData {
  static const int modelVersion = 1;

  final int version;

  int curUserKey;
  List<User> users;

  UserData({
    this.version = UserData.modelVersion,
    this.curUserKey = 0,
    List<User>? users,
  }) : users = users?.isNotEmpty == true ? users! : <User>[User()] {
    validate();
  }

  factory UserData.fromJson(Map<String, dynamic> json) =>
      _$UserDataFromJson(json);

  Map<String, dynamic> toJson() => _$UserDataToJson(this);

  void validate() {
    if (users.isEmpty) {
      users.add(User());
    }
    curUserKey = Maths.fixValidRange(curUserKey, 0, users.length - 1);
    for (final user in users) {
      user.validate();
    }
  }
}

@JsonSerializable()
class User {
  String name;
  bool isGirl;
  bool use6thDrops;

  Region region;
  Map<int, SvtStatus> servants;
  List<Map<int, SvtPlan>> svtPlanGroups;
  int curSvtPlanNo;
  Map<int, String> planNames;

  Map<int, int> items;

  //  events, main story, tickets
  Map<int, CraftStatus> craftEssences;
  Map<int, int> mysticCodes;

  User({
    this.name = 'Gudako',
    this.isGirl = true,
    this.use6thDrops = true,
    this.region = Region.jp,
    Map<int, SvtStatus>? servants,
    List<Map<int, SvtPlan>>? svtPlanGroups,
    this.curSvtPlanNo = 0,
    Map<int, String>? planNames,
    Map<int, int>? items,
    Map<int, CraftStatus?>? craftEssences,
    Map<int, int>? mysticCodes,
  })  : servants = servants ?? {},
        svtPlanGroups = svtPlanGroups ?? [],
        planNames = planNames ?? {},
        items = items ?? {},
        craftEssences = {
          if (craftEssences != null)
            for (final e in craftEssences.entries)
              if (e.value != null) e.key: e.value!
        },
        mysticCodes = mysticCodes ?? {};

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);

  Map<String, dynamic> toJson() => _$UserToJson(this);

  Map<int, SvtPlan> get curPlan => svtPlanGroups[curSvtPlanNo];

  void ensurePlanLarger() {
    curPlan.forEach((key, plan) {
      plan.validate(servants[key]?.cur);
    });
  }

  SvtPlan svtPlanOf(int no) =>
      curPlan.putIfAbsent(no, () => SvtPlan())..validate();

  SvtStatus svtStatusOf(int no) {
    final status = servants.putIfAbsent(no, () => SvtStatus())..cur.validate();
    return status;
  }

  void validate() {
    if (svtPlanGroups.isEmpty) {
      svtPlanGroups.add(<int, SvtPlan>{});
    }
    curSvtPlanNo =
        Maths.fixValidRange(curSvtPlanNo, 0, svtPlanGroups.length - 1);
    servants.values.forEach((e) => e.validate());
    for (final status in servants.values) {
      status.validate();
    }
    for (final group in svtPlanGroups) {
      for (final plan in group.entries) {
        plan.value.validate(servants[plan.key]?.cur);
      }
    }
  }

  String getFriendlyPlanName([int? planNo]) {
    planNo ??= curSvtPlanNo;
    String name = '${S.current.plan} ${planNo + 1}';
    String? customName = planNames[planNo];
    if (customName != null && customName.isNotEmpty) name += ' - $customName';
    return name;
  }
}

enum CraftStatus { owned, met, notMet }

@JsonSerializable()
class SvtStatus {
  SvtPlan cur;
  int coin;
  int priority; //1-5

  /// current bond, 5.5=5
  int bond;
  List<int?> equipCmdCodes;

  SvtStatus({
    SvtPlan? cur,
    this.coin = 0,
    this.priority = 1,
    this.bond = 0,
    List<int?>? equipCmdCodes,
  })  : cur = cur ?? SvtPlan(),
        equipCmdCodes =
            List.generate(5, (index) => equipCmdCodes?.getOrNull(index));

  factory SvtStatus.fromJson(Map<String, dynamic> json) =>
      _$SvtStatusFromJson(json);

  Map<String, dynamic> toJson() => _$SvtStatusToJson(this);

  void validate() {
    bond = Maths.fixValidRange(bond, 0, 15);
    coin = Maths.fixValidRange(coin, 0);
    priority = Maths.fixValidRange(priority, 1, 5);
    cur.bondLimit = Maths.fixValidRange(cur.bondLimit, bond, 15);
    cur.validate();
    // equipCmdCodes
  }
}

@JsonSerializable()
class SvtPlan {
  /// for cur status favorite=owned
  bool favorite;
  int ascension;
  List<int> skills;
  List<int> appendSkills;
  List<int> costumes; // costume id

  int grail;

  // 0-50, only ★4 fou-kun planned
  int fouHp;
  int fouAtk;

  // bond's upper limit, 5.5=6
  int bondLimit;

  // set it later according to rarity and event svt?
  int? npLv;

  SvtPlan({
    this.favorite = false,
    this.ascension = 0,
    List<int>? skills,
    List<int>? appendSkills,
    List<int>? costumes,
    this.grail = 0,
    this.fouHp = 0,
    this.fouAtk = 0,
    this.bondLimit = 0,
    this.npLv,
  })  : skills = List.generate(3, (index) => skills?.getOrNull(index) ?? 1,
            growable: false),
        costumes = costumes ?? [],
        appendSkills = List.generate(
            3, (index) => appendSkills?.getOrNull(index) ?? 0,
            growable: false);

  factory SvtPlan.fromJson(Map<String, dynamic> json) =>
      _$SvtPlanFromJson(json);

  Map<String, dynamic> toJson() => _$SvtPlanToJson(this);

  void validate([SvtPlan? lower]) {
    ascension = Maths.fixValidRange(ascension, lower?.ascension ?? 0, 4);
    for (int i = 0; i < skills.length; i++) {
      skills[i] = Maths.fixValidRange(skills[i], lower?.skills[i] ?? 1, 10);
    }
    for (int i = 0; i < appendSkills.length; i++) {
      appendSkills[i] =
          Maths.fixValidRange(appendSkills[i], lower?.appendSkills[i] ?? 0, 10);
    }
    // if (lower != null) {
    //   for (final id in lower.costumes.keys.toList()) {
    //     costumes[id] = lower.costumes[id]! ? true : costumes[id] ?? false;
    //   }
    // }
    grail = Maths.fixValidRange(grail, 0);
    fouHp = Maths.fixValidRange(fouHp, lower?.fouHp ?? 0, 50);
    fouAtk = Maths.fixValidRange(fouAtk, lower?.fouAtk ?? 0, 50);
    bondLimit = Maths.fixValidRange(bondLimit, lower?.bondLimit ?? 10, 15);
  }

  void reset() {
    favorite = false;
    ascension = 0;
    skills.fillRange(0, 3, 1);
    costumes.fillRange(0, costumes.length, 0);
    appendSkills.fillRange(0, 3, 0);
    grail = 0;
    fouHp = fouAtk = -20;
    bondLimit = 0;
  }

  void setMax({int skill = 10}) {
    // not change grail lv
    favorite = true;
    ascension = 4;
    skills.fillRange(0, 3, skill);
    costumes.fillRange(0, costumes.length, 1);
    // appendSkills.fillRange(0, 3, skill);
    // grail = grail;
    // fouHp, fouAtk
  }
}

enum Region {
  jp,
  cn,
  tw,
  na,
  kr,
}

const _regionLanguage = {
  Region.jp: Language.jp,
  Region.cn: Language.chs,
  Region.tw: Language.cht,
  Region.na: Language.en,
  Region.kr: Language.ko,
};

extension RegionX on Region {
  String toUpperCase() {
    return EnumUtil.upperCase(this);
  }

  Language toLanguage() => _regionLanguage[this]!;
}
