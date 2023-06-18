import 'dart:ui' show Offset;

import 'package:chaldea/generated/l10n.dart';
import '../../app/app.dart';
import '../db.dart';
import '_helper.dart';
import 'common.dart';
import 'item.dart';
import 'mappings.dart';
import 'skill.dart';

part '../../generated/models/gamedata/class_board.g.dart';

@JsonSerializable(converters: [CondTypeConverter()])
class ClassBoard with RouteInfo {
  int id;
  String name;
  String? icon;
  List<Item> dispItems;
  // String closedMessage;
  CondType condType;
  int condTargetId;
  int condNum;
  List<ClassBoardClass> classes;
  List<ClassBoardSquare> squares;
  List<ClassBoardLine> lines;

  ClassBoard({
    required this.id,
    this.name = "",
    this.icon,
    this.dispItems = const [],
    this.condType = CondType.none,
    this.condTargetId = 0,
    this.condNum = 0,
    this.classes = const [],
    this.squares = const [],
    this.lines = const [],
  });

  String get uiIcon =>
      "https://static.atlasacademy.io/file/aa-fgo-extract-jp/ClassBoard/UI/DownloadClassBoardUIAtlas/DownloadClassBoardUIAtlas1/img_class_$id.png";

  String get dispName {
    if (id >= 1 && id <= 7) {
      if (classes.length == 1 && classes.single.classId == id) {
        return Transl.svtClassId(id).l;
      }
    }
    if (classes.isEmpty) {
      if (id == 8) return 'EXTRA Ⅰ';
      if (id == 9) return 'EXTRA Ⅱ';
    }
    return name;
  }

  factory ClassBoard.fromJson(Map<String, dynamic> json) => _$ClassBoardFromJson(json);

  Map<String, dynamic> toJson() => _$ClassBoardToJson(this);

  @override
  String get route => Routes.classBoardI(id);
}

@JsonSerializable(converters: [CondTypeConverter()])
class ClassBoardClass {
  int classId;
  // SvtClass className;
  CondType condType;
  int condTargetId;
  int condNum;

  ClassBoardClass({
    required this.classId,
    this.condType = CondType.none,
    this.condTargetId = 0,
    this.condNum = 0,
  });

  factory ClassBoardClass.fromJson(Map<String, dynamic> json) => _$ClassBoardClassFromJson(json);

  Map<String, dynamic> toJson() => _$ClassBoardClassToJson(this);
}

@JsonSerializable()
class ClassBoardSquare {
  int id;
  String? icon;
  List<ItemAmount> items;
  int posX;
  int posY;
  ClassBoardSkillType skillType;
  NiceSkill? targetSkill;
  int upSkillLv;
  ClassBoardCommandSpell? targetCommandSpell;
  ClassBoardLock? lock;
  @JsonKey(unknownEnumValue: ClassBoardSquareFlag.none)
  List<ClassBoardSquareFlag> flags;
  int priority;

  ClassBoardSquare({
    required this.id,
    this.icon,
    this.items = const [],
    this.posX = 0,
    this.posY = 0,
    this.skillType = ClassBoardSkillType.none,
    this.targetSkill,
    this.upSkillLv = 0,
    this.targetCommandSpell,
    this.lock,
    this.flags = const [],
    this.priority = 0,
  });

  static String csIcon(bool isGirl) {
    return "https://static.atlasacademy.io/JP/ClassBoard/Icon/cs_0386${isGirl ? 2 : 1}.png";
  }

  Offset get offset => Offset(posX.toDouble(), -posY.toDouble());

  String? get dispIcon {
    if (skillType == ClassBoardSkillType.passive) {
      return icon;
    } else if (skillType == ClassBoardSkillType.commandSpell) {
      return csIcon(db.curUser.isGirl);
    }
    return null;
  }

  String get skillTypeStr {
    switch (skillType) {
      case ClassBoardSkillType.passive:
        return S.current.skill;
      case ClassBoardSkillType.commandSpell:
        if (targetCommandSpell != null) {
          return '${S.current.command_spell} ${targetCommandSpell!.commandSpellId}';
        }
        return S.current.command_spell;
      case ClassBoardSkillType.none:
        return "???";
    }
  }

  factory ClassBoardSquare.fromJson(Map<String, dynamic> json) => _$ClassBoardSquareFromJson(json);

  Map<String, dynamic> toJson() => _$ClassBoardSquareToJson(this);
}

@JsonSerializable()
class ClassBoardCommandSpell {
  int id;
  int commandSpellId;
  // int lv;
  String name;
  String detail;
  List<NiceFunction> functions;

  ClassBoardCommandSpell({
    required this.id,
    required this.commandSpellId,
    this.name = "",
    this.detail = "",
    this.functions = const [],
  });

  factory ClassBoardCommandSpell.fromJson(Map<String, dynamic> json) => _$ClassBoardCommandSpellFromJson(json);

  Map<String, dynamic> toJson() => _$ClassBoardCommandSpellToJson(this);

  NiceSkill toSkill({String? icon}) {
    return NiceSkill(
      id: -commandSpellId,
      name: name,
      unmodifiedDetail: detail,
      icon: icon ?? ClassBoardSquare.csIcon(db.curUser.isGirl),
      coolDown: functions.map((_) => 0).toList(),
      functions: functions.toList(),
    );
  }
}

@JsonSerializable(converters: [CondTypeConverter()])
class ClassBoardLock {
  int id;
  List<ItemAmount> items;
  // String closedMessage;
  CondType condType;
  int condTargetId;
  int condNum;

  ClassBoardLock({
    required this.id,
    this.items = const [],
    this.condType = CondType.none,
    this.condTargetId = 0,
    this.condNum = 0,
  });

  factory ClassBoardLock.fromJson(Map<String, dynamic> json) => _$ClassBoardLockFromJson(json);

  Map<String, dynamic> toJson() => _$ClassBoardLockToJson(this);
}

@JsonSerializable()
class ClassBoardLine {
  int id;
  int prevSquareId;
  int nextSquareId;

  ClassBoardLine({
    required this.id,
    required this.prevSquareId,
    required this.nextSquareId,
  });

  factory ClassBoardLine.fromJson(Map<String, dynamic> json) => _$ClassBoardLineFromJson(json);

  Map<String, dynamic> toJson() => _$ClassBoardLineToJson(this);
}

enum ClassBoardSkillType {
  none,
  passive,
  commandSpell,
}

enum ClassBoardSquareFlag {
  none,
  start,
  blank,
}
