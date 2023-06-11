// GENERATED CODE - DO NOT MODIFY BY HAND

part of '../../../models/gamedata/class_board.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ClassBoard _$ClassBoardFromJson(Map json) => ClassBoard(
      id: json['id'] as int,
      icon: json['icon'] as String?,
      dispItems: (json['dispItems'] as List<dynamic>?)
              ?.map((e) => Item.fromJson(Map<String, dynamic>.from(e as Map)))
              .toList() ??
          const [],
      condType:
          json['condType'] == null ? CondType.none : const CondTypeConverter().fromJson(json['condType'] as String),
      condTargetId: json['condTargetId'] as int? ?? 0,
      condNum: json['condNum'] as int? ?? 0,
      classes: (json['classes'] as List<dynamic>?)
              ?.map((e) => ClassBoardClass.fromJson(Map<String, dynamic>.from(e as Map)))
              .toList() ??
          const [],
      squares: (json['squares'] as List<dynamic>?)
              ?.map((e) => ClassBoardSquare.fromJson(Map<String, dynamic>.from(e as Map)))
              .toList() ??
          const [],
      lines: (json['lines'] as List<dynamic>?)
              ?.map((e) => ClassBoardLine.fromJson(Map<String, dynamic>.from(e as Map)))
              .toList() ??
          const [],
    );

Map<String, dynamic> _$ClassBoardToJson(ClassBoard instance) => <String, dynamic>{
      'id': instance.id,
      'icon': instance.icon,
      'dispItems': instance.dispItems.map((e) => e.toJson()).toList(),
      'condType': const CondTypeConverter().toJson(instance.condType),
      'condTargetId': instance.condTargetId,
      'condNum': instance.condNum,
      'classes': instance.classes.map((e) => e.toJson()).toList(),
      'squares': instance.squares.map((e) => e.toJson()).toList(),
      'lines': instance.lines.map((e) => e.toJson()).toList(),
    };

ClassBoardClass _$ClassBoardClassFromJson(Map json) => ClassBoardClass(
      classId: json['classId'] as int,
      condType:
          json['condType'] == null ? CondType.none : const CondTypeConverter().fromJson(json['condType'] as String),
      condTargetId: json['condTargetId'] as int? ?? 0,
      condNum: json['condNum'] as int? ?? 0,
    );

Map<String, dynamic> _$ClassBoardClassToJson(ClassBoardClass instance) => <String, dynamic>{
      'classId': instance.classId,
      'condType': const CondTypeConverter().toJson(instance.condType),
      'condTargetId': instance.condTargetId,
      'condNum': instance.condNum,
    };

ClassBoardSquare _$ClassBoardSquareFromJson(Map json) => ClassBoardSquare(
      id: json['id'] as int,
      icon: json['icon'] as String?,
      items: (json['items'] as List<dynamic>?)
              ?.map((e) => ItemAmount.fromJson(Map<String, dynamic>.from(e as Map)))
              .toList() ??
          const [],
      posX: json['posX'] as int? ?? 0,
      posY: json['posY'] as int? ?? 0,
      skillType: $enumDecodeNullable(_$ClassBoardSkillTypeEnumMap, json['skillType']) ?? ClassBoardSkillType.none,
      targetSkill: json['targetSkill'] == null
          ? null
          : NiceSkill.fromJson(Map<String, dynamic>.from(json['targetSkill'] as Map)),
      upSkillLv: json['upSkillLv'] as int? ?? 0,
      targetCommandSpell: json['targetCommandSpell'] == null
          ? null
          : ClassBoardCommandSpell.fromJson(Map<String, dynamic>.from(json['targetCommandSpell'] as Map)),
      lock: json['lock'] == null ? null : ClassBoardLock.fromJson(Map<String, dynamic>.from(json['lock'] as Map)),
      flags: (json['flags'] as List<dynamic>?)?.map((e) => $enumDecode(_$ClassBoardSquareFlagEnumMap, e)).toList() ??
          const [],
      priority: json['priority'] as int? ?? 0,
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
      commandSpellId: json['commandSpellId'] as int,
      name: json['name'] as String? ?? "",
      detail: json['detail'] as String? ?? "",
      functions: (json['functions'] as List<dynamic>?)
              ?.map((e) => NiceFunction.fromJson(Map<String, dynamic>.from(e as Map)))
              .toList() ??
          const [],
    );

Map<String, dynamic> _$ClassBoardCommandSpellToJson(ClassBoardCommandSpell instance) => <String, dynamic>{
      'commandSpellId': instance.commandSpellId,
      'name': instance.name,
      'detail': instance.detail,
      'functions': instance.functions.map((e) => e.toJson()).toList(),
    };

ClassBoardLock _$ClassBoardLockFromJson(Map json) => ClassBoardLock(
      items: (json['items'] as List<dynamic>?)
              ?.map((e) => ItemAmount.fromJson(Map<String, dynamic>.from(e as Map)))
              .toList() ??
          const [],
      condType:
          json['condType'] == null ? CondType.none : const CondTypeConverter().fromJson(json['condType'] as String),
      condTargetId: json['condTargetId'] as int? ?? 0,
      condNum: json['condNum'] as int? ?? 0,
    );

Map<String, dynamic> _$ClassBoardLockToJson(ClassBoardLock instance) => <String, dynamic>{
      'items': instance.items.map((e) => e.toJson()).toList(),
      'condType': const CondTypeConverter().toJson(instance.condType),
      'condTargetId': instance.condTargetId,
      'condNum': instance.condNum,
    };

ClassBoardLine _$ClassBoardLineFromJson(Map json) => ClassBoardLine(
      id: json['id'] as int,
      prevSquareId: json['prevSquareId'] as int,
      nextSquareId: json['nextSquareId'] as int,
    );

Map<String, dynamic> _$ClassBoardLineToJson(ClassBoardLine instance) => <String, dynamic>{
      'id': instance.id,
      'prevSquareId': instance.prevSquareId,
      'nextSquareId': instance.nextSquareId,
    };
