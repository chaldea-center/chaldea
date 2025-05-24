// GENERATED CODE - DO NOT MODIFY BY HAND

part of '../../../models/gamedata/class_board.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ClassBoard _$ClassBoardFromJson(Map json) => ClassBoard(
  id: (json['id'] as num).toInt(),
  name: json['name'] as String? ?? "",
  icon: json['icon'] as String?,
  condType: json['condType'] == null ? CondType.none : const CondTypeConverter().fromJson(json['condType'] as String),
  condTargetId: (json['condTargetId'] as num?)?.toInt() ?? 0,
  condNum: (json['condNum'] as num?)?.toInt() ?? 0,
  classes:
      (json['classes'] as List<dynamic>?)
          ?.map((e) => ClassBoardClass.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList() ??
      const [],
  squares:
      (json['squares'] as List<dynamic>?)
          ?.map((e) => ClassBoardSquare.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList() ??
      const [],
  lines:
      (json['lines'] as List<dynamic>?)
          ?.map((e) => ClassBoardLine.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList() ??
      const [],
  parentClassBoardBaseId: (json['parentClassBoardBaseId'] as num?)?.toInt() ?? 0,
);

Map<String, dynamic> _$ClassBoardToJson(ClassBoard instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'icon': instance.icon,
  'condType': const CondTypeConverter().toJson(instance.condType),
  'condTargetId': instance.condTargetId,
  'condNum': instance.condNum,
  'parentClassBoardBaseId': instance.parentClassBoardBaseId,
  'classes': instance.classes.map((e) => e.toJson()).toList(),
  'squares': instance.squares.map((e) => e.toJson()).toList(),
  'lines': instance.lines.map((e) => e.toJson()).toList(),
};

ClassBoardClass _$ClassBoardClassFromJson(Map json) => ClassBoardClass(
  classId: (json['classId'] as num).toInt(),
  condType: json['condType'] == null ? CondType.none : const CondTypeConverter().fromJson(json['condType'] as String),
  condTargetId: (json['condTargetId'] as num?)?.toInt() ?? 0,
  condNum: (json['condNum'] as num?)?.toInt() ?? 0,
);

Map<String, dynamic> _$ClassBoardClassToJson(ClassBoardClass instance) => <String, dynamic>{
  'classId': instance.classId,
  'condType': const CondTypeConverter().toJson(instance.condType),
  'condTargetId': instance.condTargetId,
  'condNum': instance.condNum,
};

ClassBoardSquare _$ClassBoardSquareFromJson(Map json) => ClassBoardSquare(
  id: (json['id'] as num).toInt(),
  icon: json['icon'] as String?,
  items:
      (json['items'] as List<dynamic>?)
          ?.map((e) => ItemAmount.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList() ??
      const [],
  posX: (json['posX'] as num?)?.toInt() ?? 0,
  posY: (json['posY'] as num?)?.toInt() ?? 0,
  skillType: $enumDecodeNullable(_$ClassBoardSkillTypeEnumMap, json['skillType']) ?? ClassBoardSkillType.none,
  targetSkill:
      json['targetSkill'] == null ? null : NiceSkill.fromJson(Map<String, dynamic>.from(json['targetSkill'] as Map)),
  upSkillLv: (json['upSkillLv'] as num?)?.toInt() ?? 0,
  targetCommandSpell:
      json['targetCommandSpell'] == null
          ? null
          : ClassBoardCommandSpell.fromJson(Map<String, dynamic>.from(json['targetCommandSpell'] as Map)),
  lock: json['lock'] == null ? null : ClassBoardLock.fromJson(Map<String, dynamic>.from(json['lock'] as Map)),
  flags:
      (json['flags'] as List<dynamic>?)
          ?.map((e) => $enumDecode(_$ClassBoardSquareFlagEnumMap, e, unknownValue: ClassBoardSquareFlag.none))
          .toList() ??
      const [],
  priority: (json['priority'] as num?)?.toInt() ?? 0,
);

Map<String, dynamic> _$ClassBoardSquareToJson(ClassBoardSquare instance) => <String, dynamic>{
  'id': instance.id,
  'icon': instance.icon,
  'items': instance.items.map((e) => e.toJson()).toList(),
  'posX': instance.posX,
  'posY': instance.posY,
  'skillType': _$ClassBoardSkillTypeEnumMap[instance.skillType]!,
  'targetSkill': instance.targetSkill?.toJson(),
  'upSkillLv': instance.upSkillLv,
  'targetCommandSpell': instance.targetCommandSpell?.toJson(),
  'lock': instance.lock?.toJson(),
  'flags': instance.flags.map((e) => _$ClassBoardSquareFlagEnumMap[e]!).toList(),
  'priority': instance.priority,
};

const _$ClassBoardSkillTypeEnumMap = {
  ClassBoardSkillType.none: 'none',
  ClassBoardSkillType.passive: 'passive',
  ClassBoardSkillType.commandSpell: 'commandSpell',
};

const _$ClassBoardSquareFlagEnumMap = {
  ClassBoardSquareFlag.none: 'none',
  ClassBoardSquareFlag.start: 'start',
  ClassBoardSquareFlag.blank: 'blank',
};

ClassBoardCommandSpell _$ClassBoardCommandSpellFromJson(Map json) => ClassBoardCommandSpell(
  id: (json['id'] as num).toInt(),
  commandSpellId: (json['commandSpellId'] as num).toInt(),
  name: json['name'] as String? ?? "",
  detail: json['detail'] as String? ?? "",
  functions:
      (json['functions'] as List<dynamic>?)
          ?.map((e) => NiceFunction.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList() ??
      const [],
);

Map<String, dynamic> _$ClassBoardCommandSpellToJson(ClassBoardCommandSpell instance) => <String, dynamic>{
  'id': instance.id,
  'commandSpellId': instance.commandSpellId,
  'name': instance.name,
  'detail': instance.detail,
  'functions': instance.functions.map((e) => e.toJson()).toList(),
};

ClassBoardLock _$ClassBoardLockFromJson(Map json) => ClassBoardLock(
  id: (json['id'] as num).toInt(),
  items:
      (json['items'] as List<dynamic>?)
          ?.map((e) => ItemAmount.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList() ??
      const [],
  condType: json['condType'] == null ? CondType.none : const CondTypeConverter().fromJson(json['condType'] as String),
  condTargetId: (json['condTargetId'] as num?)?.toInt() ?? 0,
  condNum: (json['condNum'] as num?)?.toInt() ?? 0,
);

Map<String, dynamic> _$ClassBoardLockToJson(ClassBoardLock instance) => <String, dynamic>{
  'id': instance.id,
  'items': instance.items.map((e) => e.toJson()).toList(),
  'condType': const CondTypeConverter().toJson(instance.condType),
  'condTargetId': instance.condTargetId,
  'condNum': instance.condNum,
};

ClassBoardLine _$ClassBoardLineFromJson(Map json) => ClassBoardLine(
  id: (json['id'] as num).toInt(),
  prevSquareId: (json['prevSquareId'] as num).toInt(),
  nextSquareId: (json['nextSquareId'] as num).toInt(),
);

Map<String, dynamic> _$ClassBoardLineToJson(ClassBoardLine instance) => <String, dynamic>{
  'id': instance.id,
  'prevSquareId': instance.prevSquareId,
  'nextSquareId': instance.nextSquareId,
};

GrandGraph _$GrandGraphFromJson(Map json) => GrandGraph(
  id: (json['id'] as num).toInt(),
  name: json['name'] as String? ?? "",
  nameShort: json['nameShort'] as String? ?? "",
  nameShortEnglish: json['nameShortEnglish'] as String? ?? "",
  classBoardBaseId: (json['classBoardBaseId'] as num?)?.toInt() ?? 0,
  nextSquareId: (json['nextSquareId'] as num?)?.toInt() ?? 0,
  condSvtLv: (json['condSvtLv'] as num?)?.toInt() ?? 0,
  condSkillLv: (json['condSkillLv'] as num?)?.toInt() ?? 0,
  condType: json['condType'] == null ? CondType.none : const CondTypeConverter().fromJson(json['condType'] as String),
  condTargetId: (json['condTargetId'] as num?)?.toInt() ?? 0,
  condNum: (json['condNum'] as num?)?.toInt() ?? 0,
  removeItems:
      (json['removeItems'] as List<dynamic>?)
          ?.map((e) => ItemAmount.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList() ??
      const [],
  details:
      (json['details'] as List<dynamic>?)
          ?.map((e) => GrandGraphDetail.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList() ??
      const [],
);

Map<String, dynamic> _$GrandGraphToJson(GrandGraph instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'nameShort': instance.nameShort,
  'nameShortEnglish': instance.nameShortEnglish,
  'classBoardBaseId': instance.classBoardBaseId,
  'nextSquareId': instance.nextSquareId,
  'condSvtLv': instance.condSvtLv,
  'condSkillLv': instance.condSkillLv,
  'condType': const CondTypeConverter().toJson(instance.condType),
  'condTargetId': instance.condTargetId,
  'condNum': instance.condNum,
  'removeItems': instance.removeItems.map((e) => e.toJson()).toList(),
  'details': instance.details.map((e) => e.toJson()).toList(),
};

GrandGraphDetail _$GrandGraphDetailFromJson(Map json) => GrandGraphDetail(
  baseClassId: (json['baseClassId'] as num?)?.toInt() ?? 0,
  grandClassId: (json['grandClassId'] as num?)?.toInt() ?? 0,
  adjustHp: (json['adjustHp'] as num?)?.toInt() ?? 0,
  adjustAtk: (json['adjustAtk'] as num?)?.toInt() ?? 0,
  condType: json['condType'] == null ? CondType.none : const CondTypeConverter().fromJson(json['condType'] as String),
  condTargetId: (json['condTargetId'] as num?)?.toInt() ?? 0,
  condNum: (json['condNum'] as num?)?.toInt() ?? 0,
);

Map<String, dynamic> _$GrandGraphDetailToJson(GrandGraphDetail instance) => <String, dynamic>{
  'baseClassId': instance.baseClassId,
  'grandClassId': instance.grandClassId,
  'adjustHp': instance.adjustHp,
  'adjustAtk': instance.adjustAtk,
  'condType': const CondTypeConverter().toJson(instance.condType),
  'condTargetId': instance.condTargetId,
  'condNum': instance.condNum,
};
