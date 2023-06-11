import '_helper.dart';
import 'common.dart';
import 'item.dart';
import 'skill.dart';

part '../../generated/models/gamedata/class_board.g.dart';

@JsonSerializable(converters: [CondTypeConverter()])
class ClassBoard {
  int id;
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
    this.icon,
    this.dispItems = const [],
    this.condType = CondType.none,
    this.condTargetId = 0,
    this.condNum = 0,
    this.classes = const [],
    this.squares = const [],
    this.lines = const [],
  });

  factory ClassBoard.fromJson(Map<String, dynamic> json) => _$ClassBoardFromJson(json);

  Map<String, dynamic> toJson() => _$ClassBoardToJson(this);
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

  factory ClassBoardSquare.fromJson(Map<String, dynamic> json) => _$ClassBoardSquareFromJson(json);

  Map<String, dynamic> toJson() => _$ClassBoardSquareToJson(this);
}

@JsonSerializable()
class ClassBoardCommandSpell {
  int commandSpellId;
  // int lv;
  String name;
  String detail;
  List<NiceFunction> functions;

  ClassBoardCommandSpell({
    required this.commandSpellId,
    this.name = "",
    this.detail = "",
    this.functions = const [],
  });

  factory ClassBoardCommandSpell.fromJson(Map<String, dynamic> json) => _$ClassBoardCommandSpellFromJson(json);

  Map<String, dynamic> toJson() => _$ClassBoardCommandSpellToJson(this);
}

@JsonSerializable(converters: [CondTypeConverter()])
class ClassBoardLock {
  List<ItemAmount> items;
  // String closedMessage;
  CondType condType;
  int condTargetId;
  int condNum;

  ClassBoardLock({
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
