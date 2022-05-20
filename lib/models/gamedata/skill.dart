// ignore_for_file: non_constant_identifier_names

import 'dart:ui';

import 'package:json_annotation/json_annotation.dart';

import 'package:chaldea/utils/utils.dart';
import '../../app/tools/gamedata_loader.dart';
import '../db.dart';
import 'common.dart';
import 'mappings.dart';

part 'func.dart';
part 'vals.dart';
part '../../generated/models/gamedata/skill.g.dart';

abstract class SkillOrTd {
  String get name;
  Transl<String, String> get lName;
  String get ruby;
  String? get unmodifiedDetail;
  String? get lDetail;
  List<NiceFunction> get functions;

  List<NiceFunction> filteredFunction({
    bool showPlayer = true,
    bool showEnemy = false,
    bool showNone = false,
    bool includeTrigger = false,
  }) {
    return NiceFunction.filterFuncs(
      funcs: functions,
      showPlayer: showPlayer,
      showEnemy: showEnemy,
      showNone: showNone,
      includeTrigger: includeTrigger,
    ).toList();
  }
}

@JsonSerializable()
class BaseSkill extends SkillOrTd {
  int id;
  @override
  String name;
  @override
  String ruby;
  @override
  String? unmodifiedDetail; // String? detail;
  SkillType type;
  String? icon;
  List<int> coolDown;
  List<NiceTrait> actIndividuality;
  SkillScript script;
  List<ExtraPassive> extraPassive;
  List<SkillAdd> skillAdd;
  Map<AiType, List<int>>? aiIds;
  @override
  List<NiceFunction> functions;

  BaseSkill({
    required this.id,
    required this.name,
    this.ruby = '',
    // this.detail,
    this.unmodifiedDetail,
    required this.type,
    this.icon,
    this.coolDown = const [],
    this.actIndividuality = const [],
    SkillScript? script,
    this.extraPassive = const [],
    this.skillAdd = const [],
    this.aiIds,
    required this.functions,
  }) : script = script ?? SkillScript();

  factory BaseSkill.fromJson(Map<String, dynamic> json) =>
      _$BaseSkillFromJson(json);

  @override
  Transl<String, String> get lName => Transl.skillNames(name);

  @override
  String? get lDetail {
    if (unmodifiedDetail == null) return null;
    String content = Transl.skillDetail(
            unmodifiedDetail!.replaceAll(RegExp(r'\[/?[og]\]'), ''))
        .l;
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

  bool isEventSkill(int eventId) {
    return functions.any((func) => func.svals.getOrNull(0)?.EventId == eventId);
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
      extraPassive: extraPassive,
      skillAdd: skillAdd,
      aiIds: aiIds,
      functions: functions,
      num: -1,
      strengthStatus: 0,
      priority: 0,
      condQuestId: 0,
      condQuestPhase: 0,
      condLv: 0,
      condLimitCount: 0,
    );
  }
}

@JsonSerializable()
class NiceSkill extends BaseSkill {
  int num;
  int strengthStatus;
  int priority;
  int condQuestId;
  int condQuestPhase;
  int condLv;
  int condLimitCount;

  NiceSkill({
    required int id,
    required String name,
    String ruby = '',
    String? unmodifiedDetail,
    required SkillType type,
    String? icon,
    List<int> coolDown = const [],
    List<NiceTrait> actIndividuality = const [],
    SkillScript? script,
    List<ExtraPassive> extraPassive = const [],
    List<SkillAdd> skillAdd = const [],
    Map<AiType, List<int>>? aiIds,
    List<NiceFunction> functions = const [],
    this.num = 0,
    this.strengthStatus = 0,
    this.priority = 0,
    this.condQuestId = 0,
    this.condQuestPhase = 0,
    this.condLv = 0,
    this.condLimitCount = 0,
  }) : super(
          id: id,
          name: name,
          ruby: ruby,
          unmodifiedDetail: unmodifiedDetail,
          type: type,
          icon: icon,
          coolDown: coolDown,
          actIndividuality: actIndividuality,
          script: script ?? SkillScript(),
          extraPassive: extraPassive,
          skillAdd: skillAdd,
          aiIds: aiIds,
          functions: functions,
        );

  factory NiceSkill.fromJson(Map<String, dynamic> json) {
    if (json['type'] == null) {
      final baseSkill = GameDataLoader
          .instance!.gameJson!['baseSkills']![json['id'].toString()]!;
      json.addAll(Map.from(baseSkill));
    }
    return _$NiceSkillFromJson(json);
  }
}

@JsonSerializable()
class BaseTd extends SkillOrTd {
  int id;
  CardType card;
  @override
  String name;
  @override
  String ruby;
  String? icon;
  String rank;
  String type;

  // String? detail;
  @override
  String? unmodifiedDetail;
  NpGain npGain;
  List<int> npDistribution;
  List<NiceTrait> individuality;
  SkillScript script;
  @override
  List<NiceFunction> functions;

  BaseTd({
    required this.id,
    required this.card,
    required this.name,
    this.ruby = "",
    this.icon,
    required this.rank,
    required this.type,
    // this.detail,
    this.unmodifiedDetail,
    required this.npGain,
    required this.npDistribution,
    required this.individuality,
    SkillScript? script,
    required this.functions,
  }) : script = script ?? SkillScript();

  factory BaseTd.fromJson(Map<String, dynamic> json) => _$BaseTdFromJson(json);

  NpDamageType? _damageType;

  NpDamageType get damageType {
    if (_damageType != null) return _damageType!;
    for (var func in functions) {
      if (func.funcTargetTeam == FuncApplyTarget.enemy) continue;
      if (func.funcType.name.startsWith('damageNp')) {
        if (func.funcTargetType == FuncTargetType.enemyAll) {
          _damageType = NpDamageType.aoe;
        } else if (func.funcTargetType == FuncTargetType.enemy) {
          _damageType = NpDamageType.singleTarget;
        } else {
          throw 'Unknown damageType: ${func.funcTargetType}';
        }
      }
    }
    return _damageType ??= NpDamageType.support;
  }

  @override
  Transl<String, String> get lName => Transl.tdNames(name);

  @override
  String? get lDetail {
    if (unmodifiedDetail == null) return null;
    return Transl.tdDetail(
            unmodifiedDetail!.replaceAll(RegExp(r'\[/?[og]\]'), ''))
        .l
        .replaceAll('{0}', 'Lv.');
  }
}

@JsonSerializable()
class NiceTd extends BaseTd {
  int num;
  int strengthStatus;
  int priority;
  int condQuestId;
  int condQuestPhase;

  NiceTd({
    required int id,
    required this.num,
    required CardType card,
    required String name,
    String ruby = "",
    String? icon,
    required String rank,
    required String type,
    // this.detail,
    String? unmodifiedDetail,
    required NpGain npGain,
    required List<int> npDistribution,
    this.strengthStatus = 0,
    required this.priority,
    this.condQuestId = 0,
    this.condQuestPhase = 0,
    required List<NiceTrait> individuality,
    SkillScript? script,
    required List<NiceFunction> functions,
  }) : super(
          id: id,
          card: card,
          name: name,
          ruby: ruby,
          icon: icon,
          rank: rank,
          type: type,
          unmodifiedDetail: unmodifiedDetail,
          npGain: npGain,
          npDistribution: npDistribution,
          individuality: individuality,
          script: script,
          functions: functions,
        );

  factory NiceTd.fromJson(Map<String, dynamic> json) {
    if (json['type'] == null) {
      final baseTd = GameDataLoader
          .instance!.gameJson!['baseTds']![json['id'].toString()]!;
      json.addAll(Map.from(baseTd));
    }
    return _$NiceTdFromJson(json);
  }
}

enum NpDamageType { support, singleTarget, aoe }

@JsonSerializable()
class CommonRelease {
  int id;
  int priority;
  int condGroup;
  @JsonKey(fromJson: toEnumCondType)
  CondType condType;
  int condId;
  int condNum;

  CommonRelease({
    required this.id,
    required this.priority,
    required this.condGroup,
    required this.condType,
    required this.condId,
    required this.condNum,
  });

  factory CommonRelease.fromJson(Map<String, dynamic> json) =>
      _$CommonReleaseFromJson(json);
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
    required this.startedAt,
    required this.endedAt,
  });

  factory ExtraPassive.fromJson(Map<String, dynamic> json) =>
      _$ExtraPassiveFromJson(json);
}

@JsonSerializable()
class SkillScript {
  List<int>? NP_HIGHER;
  List<int>? NP_LOWER;
  List<int>? STAR_HIGHER;
  List<int>? STAR_LOWER;
  List<int>? HP_VAL_HIGHER;
  List<int>? HP_VAL_LOWER;
  List<int>? HP_PER_HIGHER;
  List<int>? HP_PER_LOWER;
  List<int>? additionalSkillId;
  List<int>? additionalSkillActorType;

  SkillScript({
    this.NP_HIGHER,
    this.NP_LOWER,
    this.STAR_HIGHER,
    this.STAR_LOWER,
    this.HP_VAL_HIGHER,
    this.HP_VAL_LOWER,
    this.HP_PER_HIGHER,
    this.HP_PER_LOWER,
    this.additionalSkillId,
    this.additionalSkillActorType,
  });

  factory SkillScript.fromJson(Map<String, dynamic> json) =>
      _$SkillScriptFromJson(json);
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

  factory SkillAdd.fromJson(Map<String, dynamic> json) =>
      _$SkillAddFromJson(json);
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
    required this.buster,
    required this.arts,
    required this.quick,
    required this.extra,
    required this.np,
    required this.defence,
  });

  List<int?> get firstValues => [
        buster.getOrNull(0),
        arts.getOrNull(0),
        quick.getOrNull(0),
        extra.getOrNull(0),
        defence.getOrNull(0),
        np.getOrNull(0),
      ];

  factory NpGain.fromJson(Map<String, dynamic> json) => _$NpGainFromJson(json);
}

@JsonSerializable()
class BuffRelationOverwrite {
  Map<SvtClass, Map<SvtClass, dynamic>> atkSide;
  Map<SvtClass, Map<SvtClass, dynamic>> defSide;

  BuffRelationOverwrite({
    required this.atkSide,
    required this.defSide,
  });

  factory BuffRelationOverwrite.fromJson(Map<String, dynamic> json) =>
      _$BuffRelationOverwriteFromJson(json);
}

@JsonSerializable()
class RelationOverwriteDetail {
  int damageRate;
  ClassRelationOverwriteType type;

  RelationOverwriteDetail({
    required this.damageRate,
    required this.type,
  });

  factory RelationOverwriteDetail.fromJson(Map<String, dynamic> json) =>
      _$RelationOverwriteDetailFromJson(json);
}

List<BuffType> toEnumListBuffType(List<dynamic> json) {
  return json.map((e) => $enumDecode(_$BuffTypeEnumMap, e)).toList();
}

enum SkillType {
  active,
  passive,
}

enum ClassRelationOverwriteType {
  overwriteForce,
  overwriteMoreThanTarget,
  overwriteLessThanTarget,
}

enum AiType {
  svt,
  field,
}
