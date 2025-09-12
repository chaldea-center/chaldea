// ignore_for_file: non_constant_identifier_names

import 'package:flutter/material.dart';

import 'package:chaldea/app/modules/skill/skill_detail.dart';
import 'package:chaldea/app/modules/skill/td_detail.dart';
import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/utils/utils.dart';
import 'package:chaldea/widgets/widget_builders.dart' show CenterWidgetSpan;
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
const kAppendSkillNums = [1, 2, 3, 4, 5];
// const kAppendSkillFullNums = [100, 101, 102, 103, 104];

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

  @override
  void routeTo({Widget? child, bool popDetails = false, Region? region}) {
    router.popDetailAndPush(url: route, child: child, popDetail: popDetails);
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
class BaseSkill extends SkillOrTd {
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
  @TraitListConverter()
  List<int> actIndividuality;
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
    content = content.replaceAll('{0}', 'Lv.');
    content = content.replaceFirstMapped(RegExp(r'\[servantName (\d+)\]'), (match) {
      final svt = db.gameData.servantsById[int.parse(match.group(1)!)];
      if (svt != null) {
        return svt.lName.l;
      }
      return match.group(0).toString();
    });
    content = content.replaceAllMapped(RegExp(r'\{\{(\d+):([^:]+):(m)\}\}'), (m) {
      final index = int.parse(m.group(1)!) - 1;
      final key = m.group(2)!;
      final fmt = m.group(3)!;
      String? text;
      dynamic value = functions.getOrNull(index)?.svals.getOrNull(0)?.get(key);
      if (fmt == 'm' && value is int) {
        text = (value / 10).format(compact: false);
      }
      // other cases here
      return text ?? m.group(0)!;
    });
    return content;
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
class NiceSkill extends SkillOrTd implements BaseSkill {
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
    List<int> actIndividuality = const [],
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
  }) : _base = GameDataLoader.instance.tmp.getBaseSkill(
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
         ),
       ),
       svt =
           skillSvts.firstWhereOrNull((e) => e.svtId == svtId && e.num == num && e.priority == priority)?.copy() ??
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

  bool shouldActiveSvtEventSkill({
    required int eventId,
    required int? svtId,
    required bool includeZero,
    bool includeHidden = false,
  }) {
    final hidePassives = ConstData.getSvtLimitHides(svtId ?? 0, null).expand((e) => e.addPassives).toList();
    if (!includeHidden && hidePassives.contains(id)) return false;
    if (extraPassive.isEmpty && includeZero) return true;
    for (final passive in extraPassive) {
      if (passive.eventId == 0) {
        // 巡霊の祝祭, 3000日纪念
        if (passive.endedAt - passive.startedAt < 90 * kSecsPerDay || passive.endedAt < kNeverClosedTimestamp) {
          continue;
        }
        if (eventId == 0 || includeZero) return true;
      }
      if (passive.eventId == eventId) return true;
    }
    return false;
  }

  bool isCraftEventSkill({required int svtId, required int eventId}) {
    for (final skillSvt in skillSvts) {
      if (skillSvt.svtId == svtId && skillSvt.eventId == eventId) {
        return true;
      }
    }
    return false;
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
  @TraitListConverter()
  List<int> get actIndividuality => _base.actIndividuality;
  @override
  set actIndividuality(List<int> v) => _base.actIndividuality = v;
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

  NiceSkill toNice() {
    return NiceSkill.fromJson(toJson());
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
    return GameDataLoader.instance.tmp.getSkillSvt(
      getPrimaryKey(json["svtId"], json["num"], json["priority"]),
      () => _$SkillSvtFromJson(json),
    );
  }

  Map<String, dynamic> toJson() => _$SkillSvtToJson(this);

  SkillSvt copy() => SkillSvt.fromJson(toJson());
}

@JsonSerializable()
class BaseTd extends SkillOrTd {
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
  @TraitListConverter()
  List<int> individuality;
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
  }) : npGain = npGain ?? NpGain(),
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
  @CardTypeConverter()
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
    return GameDataLoader.instance.tmp.getTdSvt(
      getPrimaryKey(json["svtId"], json["num"], json["priority"]),
      () => _$TdSvtFromJson(json),
    );
  }

  Map<String, dynamic> toJson() => _$TdSvtToJson(this);

  TdSvt copy() => TdSvt.fromJson(toJson());
}

@JsonSerializable(converters: [CardTypeConverter()])
class NiceTd extends SkillOrTd implements BaseTd {
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
    List<int> individuality = const [],
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
  }) : _base = GameDataLoader.instance.tmp.getBaseTd(
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
         ),
       ),
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
      _base.npSvts.add(
        TdSvt(
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
        ),
      );
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
  @TraitListConverter()
  List<int> get individuality => _base.individuality;
  @override
  set individuality(List<int> v) => _base.individuality = v;
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
    if (ConstData.constantStr.overwriteToNpIndividualityDamageOneByTreasureDeviceIds.contains(id)) {
      return TdEffectFlag.attackEnemyOne;
    } else if (ConstData.constantStr.overwriteToNpIndividualityDamageAllByTreasureDeviceIds.contains(id)) {
      return TdEffectFlag.attackEnemyAll;
    }
    for (var func in functions) {
      // if (func.funcTargetTeam == FuncApplyTarget.enemy) continue;
      if (func.funcType.isDamageNp) {
        if ([
          FuncTargetType.enemyAll,
          FuncTargetType.enemyFull,
          FuncTargetType.enemyOtherFull,
          FuncTargetType.enemyOther,
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

  List<int> getIndividuality() {
    return [
      ...individuality,
      ...switch (damageType) {
        TdEffectFlag.support => ConstData.constantStr.npIndividualityNotDamage,
        TdEffectFlag.attackEnemyAll => ConstData.constantStr.npIndividualityDamageAll,
        TdEffectFlag.attackEnemyOne => ConstData.constantStr.npIndividualityDamageOne,
      },
    ];
  }
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

  bool get isLimited => endedAt - startedAt < 700 * kSecsPerDay;

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
  // mstSkill.script
  // int? cutInId;

  // mstSkillLv.script
  List<int>? get NP_HIGHER => toList('NP_HIGHER'); // lv, 50->50%
  List<int>? get NP_LOWER => toList('NP_LOWER');
  List<int>? get STAR_HIGHER => toList('STAR_HIGHER');
  List<int>? get STAR_LOWER => toList('STAR_LOWER');
  List<int>? get HP_VAL_HIGHER => toList('HP_VAL_HIGHER');
  List<int>? get HP_VAL_LOWER => toList('HP_VAL_LOWER');
  List<int>? get HP_PER_HIGHER => toList('HP_PER_HIGHER'); // 500->50%
  List<int>? get HP_PER_LOWER => toList('HP_PER_LOWER');
  final List<List<int>>? actRarity;
  // ↑ conditions
  List<int>? get battleStartRemainingTurn => toList('battleStartRemainingTurn');
  List<int>? get additionalSkillId => toList('additionalSkillId');
  List<int>? get additionalSkillLv => toList('additionalSkillLv');
  List<int>? get additionalSkillActorType => toList('additionalSkillActorType'); // BattleLogicTask.ACTORTYPE
  final List<SkillSelectAddInfo>? SelectAddInfo;
  // TD script
  List<int>? get tdTypeChangeIDs => toList('tdTypeChangeIDs');
  List<int>? get excludeTdChangeTypes => toList('excludeTdChangeTypes');
  final List<SelectTreasureDeviceInfo>? selectTreasureDeviceInfo;
  final List<CondBranchSkillInfo>? condBranchSkillInfo;

  // skill.script, not in skillLv.script
  final bool? IgnoreValueUp;
  final List<int>? IgnoreBattlePointUp;

  // td.script, not in tdLv.script;
  final List<TdChangeByBattlePoint>? tdChangeByBattlePoint;

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
      selectTreasureDeviceInfo?.isNotEmpty == true ||
      condBranchSkillInfo?.isNotEmpty == true ||
      tdTypeChangeIDs?.isNotEmpty == true ||
      excludeTdChangeTypes?.isNotEmpty == true ||
      IgnoreValueUp != null ||
      IgnoreBattlePointUp != null ||
      tdChangeByBattlePoint != null;

  SkillScript({
    // this.NP_HIGHER,
    // this.NP_LOWER,
    // this.STAR_HIGHER,
    // this.STAR_LOWER,
    // this.HP_VAL_HIGHER,
    // this.HP_VAL_LOWER,
    // this.HP_PER_HIGHER,
    // this.HP_PER_LOWER,
    this.actRarity,
    // this.battleStartRemainingTurn,
    // this.additionalSkillId,
    // this.additionalSkillLv,
    // this.additionalSkillActorType,
    this.SelectAddInfo,
    // this.tdTypeChangeIDs,
    // this.excludeTdChangeTypes,
    this.selectTreasureDeviceInfo,
    this.condBranchSkillInfo,
    dynamic IgnoreValueUp,
    List? IgnoreBattlePointUp,
    this.tdChangeByBattlePoint,
  }) : IgnoreValueUp = _parseBaseScript(IgnoreValueUp),
       IgnoreBattlePointUp = IgnoreBattlePointUp == null
           ? null
           : (IgnoreBattlePointUp.isNotEmpty && IgnoreBattlePointUp.first is List)
           ? List<int>.from(IgnoreBattlePointUp.first)
           : List<int>.from(IgnoreBattlePointUp);

  static T? _parseBaseScript<T>(dynamic value) {
    if (value == null) return null;
    if (value is T) {
      return value;
    }
    if (value is List) {
      if (value.isEmpty) return null;
      return value.first as T;
    }
    assert(() {
      throw ArgumentError.value(value, 'type ${value.runtimeType} is not $T or List<$T>');
    }());
    return null;
  }

  factory SkillScript.fromJson(Map<String, dynamic> json) => _$SkillScriptFromJson(json)..setSource(json);

  Map<String, dynamic> toJson() => Map.from(source)..addAll(_$SkillScriptToJson(this));
}

@JsonSerializable()
class SkillSelectAddInfo {
  final String title;
  final List<SkillSelectAddInfoBtn> btn;

  SkillSelectAddInfo({this.title = '', this.btn = const []});

  factory SkillSelectAddInfo.fromJson(Map<String, dynamic> json) => _$SkillSelectAddInfoFromJson(json);

  Map<String, dynamic> toJson() => _$SkillSelectAddInfoToJson(this);
}

@JsonSerializable()
class SkillSelectAddInfoBtn {
  final String name;
  final List<SkillSelectAddInfoBtnCond> conds;
  @protected
  final String? image;
  final String? imageUrl;

  String? get imageLink {
    if (imageUrl != null) return imageUrl;
    final image = this.image;
    if (image == null) return null;
    if (image.toLowerCase().contains('http')) return image;
    return 'https://static.atlasacademy.io/JP/Battle/Common/BattleAssetUIAtlas/$image.png';
  }

  SkillSelectAddInfoBtn({String name = '', this.conds = const [], this.image, this.imageUrl})
    : name = checkName(name, image);

  factory SkillSelectAddInfoBtn.fromJson(Map<String, dynamic> json) => _$SkillSelectAddInfoBtnFromJson(json);

  Map<String, dynamic> toJson() => _$SkillSelectAddInfoBtnToJson(this);

  static String checkName(String title, String? image) {
    if (title.trim().isNotEmpty || image == null) return title;
    return fallbackNames[image] ?? title;
  }

  static Map<String, String> fallbackNames = {"btn_select_003": "月下(全体タイプ)", "btn_select_004": "日輪(単体タイプ)"};

  TextSpan buildSpan(int index) {
    final transl = Transl.miscScope('SelectAddInfo');
    return TextSpan(
      children: [
        TextSpan(text: '${transl('Option').l} ${index + 1}: '),
        if (imageLink != null) CenterWidgetSpan(child: db.getIconImage(imageLink, height: 24)),
        TextSpan(text: transl(name).l),
      ],
    );
  }
}

@JsonSerializable()
class SkillSelectAddInfoBtnCond {
  final SkillScriptCond cond;
  final int? value;

  SkillSelectAddInfoBtnCond({this.cond = SkillScriptCond.none, this.value});

  factory SkillSelectAddInfoBtnCond.fromJson(Map<String, dynamic> json) => _$SkillSelectAddInfoBtnCondFromJson(json);

  Map<String, dynamic> toJson() => _$SkillSelectAddInfoBtnCondToJson(this);
}

@JsonSerializable()
class SelectTreasureDeviceInfo {
  final int dialogType;
  final String title;
  final String messageOnSelected;
  final List<SelectTdInfoTdChangeParam> treasureDevices;

  SelectTreasureDeviceInfo({
    this.dialogType = 0,
    this.title = "",
    this.messageOnSelected = "",
    this.treasureDevices = const [],
  });

  factory SelectTreasureDeviceInfo.fromJson(Map<String, dynamic> json) => _$SelectTreasureDeviceInfoFromJson(json);

  Map<String, dynamic> toJson() => _$SelectTreasureDeviceInfoToJson(this);
}

@JsonSerializable()
class SelectTdInfoTdChangeParam {
  final int id;
  @CardTypeConverter()
  final CardType type;
  final String message;

  SelectTdInfoTdChangeParam({this.id = 0, this.type = CardType.none, this.message = ""});

  factory SelectTdInfoTdChangeParam.fromJson(Map<String, dynamic> json) => _$SelectTdInfoTdChangeParamFromJson(json);

  Map<String, dynamic> toJson() => _$SelectTdInfoTdChangeParamToJson(this);
}

@JsonSerializable()
class TdChangeByBattlePoint {
  int battlePointId;
  int phase;
  int noblePhantasmId;

  TdChangeByBattlePoint({required this.battlePointId, required this.phase, required this.noblePhantasmId});

  factory TdChangeByBattlePoint.fromJson(Map<String, dynamic> json) => _$TdChangeByBattlePointFromJson(json);

  Map<String, dynamic> toJson() => _$TdChangeByBattlePointToJson(this);
}

@JsonSerializable()
class CondBranchSkillInfo {
  BattleBranchSkillCondBranchType condType;
  List<int> condValue;
  int skillId;
  String detailText;
  int iconBuffId;

  CondBranchSkillInfo({
    this.condType = BattleBranchSkillCondBranchType.none,
    this.condValue = const [],
    this.skillId = 0,
    this.detailText = '',
    this.iconBuffId = 0,
  });

  String? get icon => db.gameData.baseBuffs[iconBuffId]?.icon;

  factory CondBranchSkillInfo.fromJson(Map<String, dynamic> json) => _$CondBranchSkillInfoFromJson(json);

  Map<String, dynamic> toJson() => _$CondBranchSkillInfoToJson(this);
}

enum BattleBranchSkillCondBranchType { none, isSelfTarget, individuality }

@JsonSerializable()
class SkillAdd {
  int priority;
  List<CommonRelease> releaseConditions;
  String name;
  String ruby;

  SkillAdd({required this.priority, required this.releaseConditions, required this.name, required this.ruby});

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
  passive;

  String get shortName {
    switch (this) {
      case SkillType.active:
        return S.current.active_skill_short;
      case SkillType.passive:
        return S.current.passive_skill_short;
    }
  }
}

enum TdEffectFlag { support, attackEnemyAll, attackEnemyOne }

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
  hpPerLower;

  String get rawName => _$SkillScriptCondEnumMap[this] ?? name;
}
