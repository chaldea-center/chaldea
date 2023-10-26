// ignore_for_file: non_constant_identifier_names

import 'package:flutter/material.dart';

import 'package:chaldea/app/modules/skill/skill_detail.dart';
import 'package:chaldea/app/modules/skill/td_detail.dart';
import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/utils/utils.dart';
import '../../app/app.dart';
import '../../app/tools/gamedata_loader.dart';
import '../db.dart';
import '_helper.dart';
import 'gamedata.dart';

export 'func.dart';
export 'vals.dart';
part '../../generated/models/gamedata/skill.g.dart';

const kActiveSkillNums = [1, 2, 3];
// actual num is 100,101,102
const kAppendSkillNums = [1, 2, 3];

abstract class SkillOrTd implements RouteInfo {
  int get id;
  String get name;
  Transl<String, String> get lName;
  String get ruby;
  String? get icon;
  String? get unmodifiedDetail;
  String? get lDetail;
  List<NiceFunction> get functions;
  SkillScript? get script;

  List<T> filteredFunction<T extends BaseFunction>({
    bool showPlayer = true,
    bool showEnemy = false,
    bool showNone = false,
    bool includeTrigger = false,
  }) {
    return NiceFunction.filterFuncs<T>(
      funcs: functions.cast(),
      showPlayer: showPlayer,
      showEnemy: showEnemy,
      showNone: showNone,
      includeTrigger: includeTrigger,
    ).toList();
  }

  String? get detail {
    if (unmodifiedDetail == null) return null;
    return unmodifiedDetail!.replaceAll(RegExp(r'\[/?[og]\]'), '');
  }
}

extension SkillOrTdX on SkillOrTd {
  String get dispName {
    final s = lName.l;
    if (s.isEmpty) return id.toString();
    return s;
  }
}

@JsonSerializable()
class BaseSkill extends SkillOrTd with RouteInfo {
  @override
  int id;
  @override
  String name;
  @override
  String ruby;
  @override
  String? unmodifiedDetail; // String? detail;
  SkillType type;
  @override
  String? icon;
  List<int> coolDown;
  List<NiceTrait> actIndividuality;
  @override
  SkillScript? script;
  List<SkillAdd> skillAdd;
  Map<AiType, List<int>>? aiIds;
  List<SkillGroupOverwrite>? groupOverwrites;
  @override
  List<NiceFunction> functions;
  List<SkillSvt> skillSvts;

  BaseSkill({
    required this.id,
    this.name = "",
    this.ruby = '',
    // this.detail,
    this.unmodifiedDetail,
    this.type = SkillType.active,
    this.icon,
    this.coolDown = const [0],
    this.actIndividuality = const [],
    this.script,
    this.skillAdd = const [],
    this.aiIds,
    this.groupOverwrites,
    this.functions = const [],
    this.skillSvts = const [],
  });

  factory BaseSkill.fromJson(Map<String, dynamic> json) {
    return GameDataLoader.instance.tmp.getBaseSkill(json["id"]!, () => _$BaseSkillFromJson(json));
  }

  SkillSvt get svt => skillSvts.firstOrNull ?? SkillSvt();

  @override
  Transl<String, String> get lName => Transl.skillNames(name);

  @override
  String? get lDetail {
    if (unmodifiedDetail == null) return null;
    String content = Transl.skillDetail(detail ?? '').l;
    if (db.runtimeData.showSkillOriginText) return content;
    return content.replaceAll('{0}', 'Lv.').replaceFirstMapped(
      RegExp(r'\[servantName (\d+)\]'),
      (match) {
        final svt = db.gameData.servantsById[int.parse(match.group(1)!)];
        if (svt != null) {
          return svt.lName.l;
        }
        return match.group(0).toString();
      },
    );
  }

  @override
  String get route => Routes.skillI(id);
  @override
  void routeTo({Widget? child, bool popDetails = false, Region? region}) {
    return super.routeTo(
      child: child ?? SkillDetailPage(skill: this, region: region),
      popDetails: popDetails,
    );
  }

  Map<String, dynamic> toJson() => _$BaseSkillToJson(this);
}

@JsonSerializable()
class NiceSkill extends SkillOrTd with RouteInfo implements BaseSkill {
  BaseSkill _base;
  BaseSkill get base => _base;

  List<ExtraPassive> extraPassive;

  @override
  @JsonKey(includeFromJson: false)
  SkillSvt svt;

  // for JsonSerializer
  @protected
  int get svtId => svt.svtId;
  @protected
  int get num => svt.num;
  @protected
  int get priority => svt.priority;
  // Map? script;
  int get strengthStatus => svt.strengthStatus;
  int get condQuestId => svt.condQuestId;
  int get condQuestPhase => svt.condQuestPhase;
  int get condLv => svt.condLv;
  int get condLimitCount => svt.condLimitCount;
  // int eventId;
  // int flag;
  List<SvtSkillRelease> get releaseConditions => svt.releaseConditions;

  NiceSkill({
    required int id,
    String name = "",
    String ruby = '',
    String? unmodifiedDetail,
    SkillType type = SkillType.active,
    String? icon,
    List<int> coolDown = const [0],
    List<NiceTrait> actIndividuality = const [],
    SkillScript? script,
    List<SkillAdd> skillAdd = const [],
    Map<AiType, List<int>>? aiIds,
    List<SkillGroupOverwrite>? groupOverwrites,
    List<NiceFunction> functions = const [],
    List<SkillSvt> skillSvts = const [],
    int svtId = 0,
    // ignore: avoid_types_as_parameter_names
    int num = 0,
    int priority = 0,
    // this.script,
    int strengthStatus = 0,
    int condQuestId = 0,
    int condQuestPhase = 0,
    int condLv = 0,
    int condLimitCount = 0,
    // int eventId = 0,
    // int flag = 0,
    // this.releaseConditions = const [],
    this.extraPassive = const [],
  })  : _base = GameDataLoader.instance.tmp.getBaseSkill(
            id,
            () => BaseSkill(
                  id: id,
                  name: name,
                  ruby: ruby,
                  unmodifiedDetail: unmodifiedDetail,
                  type: type,
                  icon: icon,
                  coolDown: coolDown,
                  actIndividuality: actIndividuality,
                  script: script,
                  skillAdd: skillAdd,
                  aiIds: aiIds,
                  groupOverwrites: groupOverwrites,
                  functions: functions,
                  skillSvts: skillSvts,
                )),
        svt = skillSvts.firstWhereOrNull((e) => e.svtId == svtId && e.num == num && e.priority == priority)?.copy() ??
            SkillSvt(
              svtId: svtId,
              num: num,
              priority: priority,
              // script: script,
              strengthStatus: strengthStatus,
              condQuestId: condQuestId,
              condQuestPhase: condQuestPhase,
              condLv: condLv,
              condLimitCount: condLimitCount,
              // eventId: eventId,
              // flag: flag,
              // releaseConditions: releaseConditions,
            );

  factory NiceSkill.fromJson(Map<String, dynamic> json) {
    if (json['type'] == null) {
      final baseSkill = GameDataLoader.instance.tmp.gameJson!['baseSkills']![json['id'].toString()]!;
      json.addAll(Map.from(baseSkill));
    }
    return _$NiceSkillFromJson(json);
  }

  bool isExtraPassiveEnabledForEvent(int eventId) {
    return extraPassive.any((e) {
      // ヨハンナさんと未確認の愛 ブレッシング・オブ・セイント EX 300NP
      if (id == 940274) return false;
      if (e.eventId == 0) {
        // 巡霊の祝祭
        if (e.endedAt - e.startedAt < 90 * kSecsPerDay || e.endedAt < kNeverClosedTimestamp) {
          return false;
        }
        return true;
      }
      if (e.eventId == eventId) return true;
      return false;
    });
  }

  @override
  Map<String, dynamic> toJson() => _$NiceSkillToJson(this);

  /// getters and setters
  @override
  int get id => _base.id;
  @override
  set id(int v) => _base.id = v;
  @override
  String get name => _base.name;
  @override
  set name(String v) => _base.name = v;
  @override
  String get ruby => _base.ruby;
  @override
  set ruby(String v) => _base.ruby = v;
  @override
  String? get unmodifiedDetail => _base.unmodifiedDetail;
  @override
  set unmodifiedDetail(String? v) => _base.unmodifiedDetail = v;
  @override
  SkillType get type => _base.type;
  @override
  set type(SkillType v) => _base.type = v;
  @override
  String? get icon => _base.icon;
  @override
  set icon(String? v) => _base.icon = v;
  @override
  List<int> get coolDown => _base.coolDown;
  @override
  set coolDown(List<int> v) => _base.coolDown = v;
  @override
  List<NiceTrait> get actIndividuality => _base.actIndividuality;
  @override
  set actIndividuality(List<NiceTrait> v) => _base.actIndividuality = v;
  @override
  SkillScript? get script => _base.script;
  @override
  set script(SkillScript? v) => _base.script = v;
  @override
  List<SkillAdd> get skillAdd => _base.skillAdd;
  @override
  set skillAdd(List<SkillAdd> v) => _base.skillAdd = v;
  @override
  Map<AiType, List<int>>? get aiIds => _base.aiIds;
  @override
  set aiIds(Map<AiType, List<int>>? v) => _base.aiIds = v;
  @override
  List<SkillGroupOverwrite>? get groupOverwrites => _base.groupOverwrites;
  @override
  set groupOverwrites(List<SkillGroupOverwrite>? v) => _base.groupOverwrites = v;
  @override
  List<NiceFunction> get functions => _base.functions;
  @override
  set functions(List<NiceFunction> v) => _base.functions = v;
  @override
  List<SkillSvt> get skillSvts => _base.skillSvts;
  @override
  set skillSvts(List<SkillSvt> v) => _base.skillSvts = v;

  /// override methods
  @override
  String? get lDetail => _base.lDetail;
  @override
  Transl<String, String> get lName => _base.lName;
  @override
  String get route => _base.route;
  @override
  void routeTo({Widget? child, bool popDetails = false, Region? region}) => super.routeTo(
        child: child ?? SkillDetailPage(skill: this, region: region),
        popDetails: popDetails,
      );
}

extension BaseSkillMethods on BaseSkill {
  int get maxLv => functions.firstOrNull?.svals.length ?? 0;

  bool isEventSkill(Event event) {
    return functions.any((func) {
      if (func.svals.getOrNull(0)?.EventId == event.id) return true;
      if (event.warIds.isNotEmpty) {
        if (<int>{for (final trait in func.funcquestTvals) ...?db.gameData.mappingData.fieldTrait[trait.id]?.warIds}
            .intersection(event.warIds.toSet())
            .isNotEmpty) {
          return true;
        }
      }
      return false;
    });
  }

  NiceSkill toNice() {
    return NiceSkill(
      id: id,
      name: name,
      ruby: ruby,
      unmodifiedDetail: unmodifiedDetail,
      type: type,
      icon: icon,
      coolDown: coolDown,
      actIndividuality: actIndividuality,
      script: script,
      skillAdd: skillAdd,
      aiIds: aiIds,
      groupOverwrites: groupOverwrites,
      functions: functions,
      skillSvts: skillSvts,
    );
  }
}

abstract class SkillSvtBase {
  int get svtId;
  int get num;
  List<SvtSkillRelease> get releaseConditions;
}

@JsonSerializable()
class SkillSvt implements SkillSvtBase {
  @override
  int svtId;
  @override
  int num;
  int priority;
  Map? script; // "strengthStatusReleaseId": 40060301, (commonRelease)
  int strengthStatus;
  int condQuestId;
  int condQuestPhase;
  int condLv;
  int condLimitCount;
  int eventId;
  int flag;
  @override
  List<SvtSkillRelease> releaseConditions;

  SkillSvt({
    this.svtId = 0,
    this.num = 0,
    this.priority = 0,
    this.script,
    this.strengthStatus = 0,
    this.condQuestId = 0,
    this.condQuestPhase = 0,
    this.condLv = 0,
    this.condLimitCount = 0,
    this.eventId = 0,
    this.flag = 0,
    this.releaseConditions = const [],
  });

  static String getPrimaryKey(int? svtId, int? num, int? priority) => "${svtId ?? 0}:${num ?? 0}:${priority ?? 0}";

  factory SkillSvt.fromJson(Map<String, dynamic> json) {
    return GameDataLoader.instance.tmp
        .getSkillSvt(getPrimaryKey(json["svtId"], json["num"], json["priority"]), () => _$SkillSvtFromJson(json));
  }

  Map<String, dynamic> toJson() => _$SkillSvtToJson(this);

  SkillSvt copy() => SkillSvt.fromJson(toJson());
}

@JsonSerializable()
class BaseTd extends SkillOrTd with RouteInfo {
  @override
  int id;
  @override
  String name;
  @override
  String ruby;
  @override
  String? icon;
  String rank;
  String type;
  // The support flag is not accurate
  @protected
  List<TdEffectFlag> effectFlags;
  @override
  String? unmodifiedDetail;
  NpGain npGain;
  List<NiceTrait> individuality;
  @override
  SkillScript? script;
  @override
  List<NiceFunction> functions;
  List<TdSvt> npSvts; // Not full list

  BaseTd({
    required this.id,
    this.name = "",
    this.ruby = "",
    this.icon,
    this.rank = "",
    this.type = "",
    this.effectFlags = const [],
    // this.detail,
    this.unmodifiedDetail,
    NpGain? npGain,
    this.individuality = const [],
    this.script,
    this.functions = const [],
    List<TdSvt>? npSvts,
  })  : npGain = npGain ?? NpGain(),
        npSvts = npSvts ?? [];

  factory BaseTd.fromJson(Map<String, dynamic> json) {
    return GameDataLoader.instance.tmp.getBaseTd(json["id"]!, () => _$BaseTdFromJson(json));
  }

  TdSvt get svt => npSvts.firstOrNull ?? TdSvt();

  @override
  Transl<String, String> get lName => Transl.tdNames(name);

  @override
  String? get lDetail {
    if (unmodifiedDetail == null) return null;
    final content = Transl.tdDetail(detail ?? '').l;
    if (db.runtimeData.showSkillOriginText) return content;
    return content.replaceAll('{0}', 'Lv.');
  }

  @override
  String get route => Routes.tdI(id);
  @override
  void routeTo({Widget? child, bool popDetails = false, Region? region}) {
    return super.routeTo(
      child: child ?? TdDetailPage(td: this, region: region),
      popDetails: popDetails,
    );
  }

  Map<String, dynamic> toJson() => _$BaseTdToJson(this);
}

// public enum ServantTreasureDvcEntity.Flag
// {
// 	public int value__;
// 	public const ServantTreasureDvcEntity.Flag NONE = 1;
// 	public const ServantTreasureDvcEntity.Flag WITH_PLAYER_PROGRESS = 2;
// 	public const ServantTreasureDvcEntity.Flag NONE_TREASURE_DEVICE_EFFECT = 4;
// 	public const ServantTreasureDvcEntity.Flag SECRET_TREASURE_DEVICE = 8;
// 	public const ServantTreasureDvcEntity.Flag NOT_DISPLAY_SKILL_ICON = 16;
// }

@JsonSerializable()
class TdSvt implements SkillSvtBase {
  @override
  int svtId;
  @override
  int num;
  int npNum;
  int priority;
  List<int> damage;
  int strengthStatus;
  int flag;
  int imageIndex;
  int condQuestId;
  int condQuestPhase;
  int condLv;
  int condFriendshipRank;
  // int motion;
  CardType card;
  @override
  List<SvtSkillRelease> releaseConditions;

  TdSvt({
    this.svtId = 0,
    this.num = 1,
    this.npNum = 1,
    this.priority = 0,
    this.damage = const [],
    this.strengthStatus = 0,
    this.flag = 0,
    this.imageIndex = 0,
    this.condQuestId = 0,
    this.condQuestPhase = 0,
    this.condLv = 0,
    this.condFriendshipRank = 0,
    // this.motion = 0,
    this.card = CardType.none,
    this.releaseConditions = const [],
  });

  static String getPrimaryKey(int? svtId, int? num, int? priority) => "${svtId ?? 0}:${num ?? 1}:${priority ?? 0}";

  factory TdSvt.fromJson(Map<String, dynamic> json) {
    return GameDataLoader.instance.tmp
        .getTdSvt(getPrimaryKey(json["svtId"], json["num"], json["priority"]), () => _$TdSvtFromJson(json));
  }

  Map<String, dynamic> toJson() => _$TdSvtToJson(this);

  TdSvt copy() => TdSvt.fromJson(toJson());
}

@JsonSerializable()
class NiceTd extends SkillOrTd with RouteInfo implements BaseTd {
  BaseTd _base;
  BaseTd get base => _base;

  @override
  @JsonKey(includeFromJson: false)
  TdSvt svt;
  // for JsonSerializer
  int get svtId => svt.svtId;
  int get num => svt.num;
  int get npNum => svt.npNum;
  int get priority => svt.priority;
  @JsonKey(name: "npDistribution")
  List<int> get damage => svt.damage;
  int get strengthStatus => svt.strengthStatus;
  int get flag => svt.flag;
  int get imageIndex => svt.imageIndex;
  int get condQuestId => svt.condQuestId;
  int get condQuestPhase => svt.condQuestPhase;
  int get condLv => svt.condLv;
  int get condFriendshipRank => svt.condFriendshipRank;
  // int motion;
  CardType get card => svt.card;
  List<SvtSkillRelease> get releaseConditions => svt.releaseConditions;

  NiceTd({
    required int id,
    String name = "",
    String ruby = "",
    String? icon,
    String rank = "",
    String type = "",
    List<TdEffectFlag> effectFlags = const [],
    // this.detail,
    String? unmodifiedDetail,
    NpGain? npGain,
    List<NiceTrait> individuality = const [],
    SkillScript? script,
    List<NiceFunction> functions = const [],
    List<TdSvt>? npSvts,
    int svtId = 0,
    int num = 1,
    int npNum = 1,
    int priority = 0,
    List<int> damage = const [],
    int strengthStatus = 0,
    int flag = 0,
    int imageIndex = 0,
    int condQuestId = 0,
    int condQuestPhase = 0,
    int condLv = 0,
    int condFriendshipRank = 0,
    // this.motion = 0,
    CardType card = CardType.none,
    List<SvtSkillRelease> releaseConditions = const [],
  })  : _base = GameDataLoader.instance.tmp.getBaseTd(
            id,
            () => BaseTd(
                  id: id,
                  name: name,
                  ruby: ruby,
                  icon: icon,
                  rank: rank,
                  type: type,
                  effectFlags: effectFlags,
                  unmodifiedDetail: unmodifiedDetail,
                  npGain: npGain,
                  individuality: individuality,
                  script: script,
                  functions: functions,
                  npSvts: npSvts,
                )),
        svt = TdSvt(
          svtId: svtId,
          num: num,
          npNum: npNum,
          priority: priority,
          damage: damage,
          strengthStatus: strengthStatus,
          flag: flag,
          imageIndex: imageIndex,
          condQuestId: condQuestId,
          condQuestPhase: condQuestPhase,
          condLv: condLv,
          condFriendshipRank: condFriendshipRank,
          card: card,
          releaseConditions: releaseConditions,
        ) {
    if (svtId > 0 && num > 0 && !_base.npSvts.any((e) => e.svtId == svtId && e.num == num && e.priority == priority)) {
      // recreate instance in case of wrong reference
      _base.npSvts.add(TdSvt(
        svtId: svtId,
        num: num,
        npNum: npNum,
        priority: priority,
        damage: damage,
        strengthStatus: strengthStatus,
        flag: flag,
        imageIndex: imageIndex,
        condQuestId: condQuestId,
        condQuestPhase: condQuestPhase,
        condLv: condLv,
        condFriendshipRank: condFriendshipRank,
        card: card,
        releaseConditions: releaseConditions,
      ));
    }
  }

  factory NiceTd.fromJson(Map<String, dynamic> json) {
    if (json['type'] == null) {
      final baseTd = GameDataLoader.instance.tmp.gameJson!['baseTds']![json['id'].toString()]!;
      json = Map.from(baseTd)..addAll(json);
    }
    return _$NiceTdFromJson(json);
  }

  @override
  Map<String, dynamic> toJson() => _$NiceTdToJson(this);

  /// getters and setters

  @override
  int get id => _base.id;
  @override
  set id(int v) => _base.id = v;
  @override
  String get name => _base.name;
  @override
  set name(String v) => _base.name = v;
  @override
  String get ruby => _base.ruby;
  @override
  set ruby(String v) => _base.ruby = v;
  @override
  String? get icon => _base.icon;
  @override
  set icon(String? v) => _base.icon = v;
  @override
  String get rank => _base.rank;
  @override
  set rank(String v) => _base.rank = v;
  @override
  String get type => _base.type;
  @override
  set type(String v) => _base.type = v;
  @override
  List<TdEffectFlag> get effectFlags => _base.effectFlags;
  @override
  set effectFlags(List<TdEffectFlag> v) => _base.effectFlags = v;
  @override
  String? get unmodifiedDetail => _base.unmodifiedDetail;
  @override
  set unmodifiedDetail(String? v) => _base.unmodifiedDetail = v;
  @override
  NpGain get npGain => _base.npGain;
  @override
  set npGain(NpGain v) => _base.npGain = v;
  @override
  List<NiceTrait> get individuality => _base.individuality;
  @override
  set individuality(List<NiceTrait> v) => _base.individuality = v;
  @override
  SkillScript? get script => _base.script;
  @override
  set script(SkillScript? v) => _base.script = v;
  @override
  List<NiceFunction> get functions => _base.functions;
  @override
  set functions(List<NiceFunction> v) => _base.functions = v;
  @override
  List<TdSvt> get npSvts => _base.npSvts;
  @override
  set npSvts(List<TdSvt> v) => _base.npSvts = v;

  /// override methods
  @override
  String? get lDetail => _base.lDetail;
  @override
  Transl<String, String> get lName => _base.lName;
  @override
  String get route => _base.route;
  @override
  void routeTo({Widget? child, bool popDetails = false, Region? region}) => super.routeTo(
        child: child ?? TdDetailPage(td: this, region: region),
        popDetails: popDetails,
      );
}

extension TdMethods on BaseTd {
  int get maxLv => functions.firstOrNull?.svals.length ?? 0;
  int get maxOC => functions.firstOrNull?.ocVals(0).length ?? 0;

  String get nameWithRank {
    if (['なし', '无', 'None', '無', '없음'].contains(rank)) return lName.l;
    return '${lName.l} $rank';
  }

  TdEffectFlag get damageType {
    for (var func in functions) {
      // if (func.funcTargetTeam == FuncApplyTarget.enemy) continue;
      if (func.funcType.isDamageNp) {
        if ([
          FuncTargetType.enemyAll,
          FuncTargetType.enemyFull,
          FuncTargetType.enemyOtherFull,
          FuncTargetType.enemyOther
        ].contains(func.funcTargetType)) {
          return TdEffectFlag.attackEnemyAll;
        } else if ([
          FuncTargetType.enemy,
          FuncTargetType.enemyRandom,
          FuncTargetType.enemyOneAnotherRandom,
          FuncTargetType.enemyOneNoTargetNoAction,
          FuncTargetType.enemyAnother,
        ].contains(func.funcTargetType)) {
          return TdEffectFlag.attackEnemyOne;
        } else {
          assert(() {
            throw 'Unknown damageType: ${func.funcTargetType}';
          }());
        }
      }
    }
    return TdEffectFlag.support;
  }

  int get dmgNpFuncCount => functions.where((func) => func.funcType.isDamageNp).length;
}

@JsonSerializable()
class ExtraPassive {
  int num;
  int priority;
  int condQuestId;
  int condQuestPhase;
  int condLv;
  int condLimitCount;
  int condFriendshipRank;
  int eventId;
  int flag;
  List<CommonRelease> releaseConditions;
  int startedAt;
  int endedAt;

  ExtraPassive({
    required this.num,
    required this.priority,
    this.condQuestId = 0,
    this.condQuestPhase = 0,
    this.condLv = 0,
    this.condLimitCount = 0,
    this.condFriendshipRank = 0,
    this.eventId = 0,
    this.flag = 0,
    this.releaseConditions = const [],
    required this.startedAt,
    required this.endedAt,
  });

  factory ExtraPassive.fromJson(Map<String, dynamic> json) => _$ExtraPassiveFromJson(json);

  Map<String, dynamic> toJson() => _$ExtraPassiveToJson(this);
}

@JsonSerializable(includeIfNull: false)
class SkillScript with DataScriptBase {
  // skill script, all are lv dependent
  final List<int>? NP_HIGHER; // lv, 50->50%
  final List<int>? NP_LOWER;
  final List<int>? STAR_HIGHER;
  final List<int>? STAR_LOWER;
  final List<int>? HP_VAL_HIGHER;
  final List<int>? HP_VAL_LOWER;
  final List<int>? HP_PER_HIGHER; // 500->50%
  final List<int>? HP_PER_LOWER;
  final List<List<int>>? actRarity;
  // ↑ conditions
  final List<int>? battleStartRemainingTurn;
  final List<int>? additionalSkillId;
  final List<int>? additionalSkillLv;
  final List<int>? additionalSkillActorType; // BattleLogicTask.ACTORTYPE
  final List<SkillSelectAddInfo>? SelectAddInfo;
  // TD script
  final List<int>? tdTypeChangeIDs;
  final List<int>? excludeTdChangeTypes;

  bool get isNotEmpty =>
      NP_HIGHER?.isNotEmpty == true ||
      NP_LOWER?.isNotEmpty == true ||
      STAR_HIGHER?.isNotEmpty == true ||
      STAR_LOWER?.isNotEmpty == true ||
      HP_VAL_HIGHER?.isNotEmpty == true ||
      HP_VAL_LOWER?.isNotEmpty == true ||
      HP_PER_HIGHER?.isNotEmpty == true ||
      HP_PER_LOWER?.isNotEmpty == true ||
      actRarity?.isNotEmpty == true ||
      battleStartRemainingTurn?.isNotEmpty == true ||
      additionalSkillId?.isNotEmpty == true ||
      additionalSkillLv?.isNotEmpty == true ||
      additionalSkillActorType?.isNotEmpty == true ||
      SelectAddInfo?.isNotEmpty == true ||
      tdTypeChangeIDs?.isNotEmpty == true ||
      excludeTdChangeTypes?.isNotEmpty == true;

  SkillScript({
    this.NP_HIGHER,
    this.NP_LOWER,
    this.STAR_HIGHER,
    this.STAR_LOWER,
    this.HP_VAL_HIGHER,
    this.HP_VAL_LOWER,
    this.HP_PER_HIGHER,
    this.HP_PER_LOWER,
    this.actRarity,
    this.battleStartRemainingTurn,
    this.additionalSkillId,
    this.additionalSkillLv,
    this.additionalSkillActorType,
    this.SelectAddInfo,
    this.tdTypeChangeIDs,
    this.excludeTdChangeTypes,
  });

  factory SkillScript.fromJson(Map<String, dynamic> json) => _$SkillScriptFromJson(json)..setSource(json);

  Map<String, dynamic> toJson() => _$SkillScriptToJson(this);
}

@JsonSerializable()
class SkillSelectAddInfo {
  final String title;
  final List<SkillSelectAddInfoBtn> btn;

  SkillSelectAddInfo({
    this.title = '',
    this.btn = const [],
  });

  factory SkillSelectAddInfo.fromJson(Map<String, dynamic> json) => _$SkillSelectAddInfoFromJson(json);

  Map<String, dynamic> toJson() => _$SkillSelectAddInfoToJson(this);
}

@JsonSerializable()
class SkillSelectAddInfoBtn {
  final String name;
  final List<SkillSelectAddInfoBtnCond> conds;

  SkillSelectAddInfoBtn({
    this.name = '',
    this.conds = const [],
  });

  factory SkillSelectAddInfoBtn.fromJson(Map<String, dynamic> json) => _$SkillSelectAddInfoBtnFromJson(json);

  Map<String, dynamic> toJson() => _$SkillSelectAddInfoBtnToJson(this);
}

@JsonSerializable()
class SkillSelectAddInfoBtnCond {
  final SkillScriptCond cond;
  final int? value;

  SkillSelectAddInfoBtnCond({
    this.cond = SkillScriptCond.none,
    this.value,
  });

  factory SkillSelectAddInfoBtnCond.fromJson(Map<String, dynamic> json) => _$SkillSelectAddInfoBtnCondFromJson(json);

  Map<String, dynamic> toJson() => _$SkillSelectAddInfoBtnCondToJson(this);
}

@JsonSerializable()
class SkillAdd {
  int priority;
  List<CommonRelease> releaseConditions;
  String name;
  String ruby;

  SkillAdd({
    required this.priority,
    required this.releaseConditions,
    required this.name,
    required this.ruby,
  });

  factory SkillAdd.fromJson(Map<String, dynamic> json) => _$SkillAddFromJson(json);

  Map<String, dynamic> toJson() => _$SkillAddToJson(this);
}

@JsonSerializable(converters: [CondTypeConverter()])
class SvtSkillRelease {
  // int svtId;
  // int num;
  // int priority;
  int idx;

  /// [CondType.equipWithTargetCostume] for Mash and Melusine
  /// [CondType.questClear] or [CondType.questClearPhase] for 151-154 servants and Mysterious X, ignore.
  /// [CondType.svtLimit] max servant limit (0-4), not current display limitCount, ignore.
  CondType condType;
  int condTargetId; // svtId for equipWithTargetCostume
  int condNum; // display limitCount for equipWithTargetCostume
  int condGroup;

  SvtSkillRelease({
    // this.svtId = 0,
    // this.num = 0,
    // this.priority = 0,
    this.idx = 1,
    this.condType = CondType.none,
    this.condTargetId = 0,
    this.condNum = 0,
    this.condGroup = 0,
  });

  factory SvtSkillRelease.fromJson(Map<String, dynamic> json) => _$SvtSkillReleaseFromJson(json);

  Map<String, dynamic> toJson() => _$SvtSkillReleaseToJson(this);
}

@JsonSerializable()
class SkillGroupOverwrite {
  int level;
  int skillGroupId;
  int startedAt;
  int endedAt;
  String? icon;
  // String detail;
  String unmodifiedDetail;
  // Since each skill level has their own group overwrite, the svals field only contains data for 1 level.
  List<NiceFunction> functions;

  SkillGroupOverwrite({
    required this.level,
    required this.skillGroupId,
    required this.startedAt,
    required this.endedAt,
    this.icon,
    this.unmodifiedDetail = '',
    this.functions = const [],
  });

  factory SkillGroupOverwrite.fromJson(Map<String, dynamic> json) => _$SkillGroupOverwriteFromJson(json);

  Map<String, dynamic> toJson() => _$SkillGroupOverwriteToJson(this);
}

@JsonSerializable()
class NpGain {
  List<int> buster;
  List<int> arts;
  List<int> quick;
  List<int> extra;
  List<int> np;
  List<int> defence;

  NpGain({
    this.buster = const [],
    this.arts = const [],
    this.quick = const [],
    this.extra = const [],
    this.np = const [],
    this.defence = const [],
  });

  List<int?> get firstValues => [
        buster.getOrNull(0),
        arts.getOrNull(0),
        quick.getOrNull(0),
        extra.getOrNull(0),
        np.getOrNull(0),
        defence.getOrNull(0),
      ];

  factory NpGain.fromJson(Map<String, dynamic> json) => _$NpGainFromJson(json);

  Map<String, dynamic> toJson() => _$NpGainToJson(this);
}

enum SkillType {
  active,
  passive,
  ;

  String get shortName {
    switch (this) {
      case SkillType.active:
        return S.current.active_skill_short;
      case SkillType.passive:
        return S.current.passive_skill_short;
    }
  }
}

enum TdEffectFlag {
  support,
  attackEnemyAll,
  attackEnemyOne,
}

@JsonEnum(fieldRename: FieldRename.screamingSnake)
enum SkillScriptCond {
  none,
  npHigher,
  npLower,
  starHigher,
  starLower,
  hpValHigher,
  hpValLower,
  hpPerHigher,
  hpPerLower,
  ;

  String get rawName => _$SkillScriptCondEnumMap[this] ?? name;
}
