import 'dart:ui' show Offset;

import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/utils/extension.dart';
import '../../app/app.dart';
import '../db.dart';
import '../userdata/userdata.dart';
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
  // List<Item> dispItems;
  // String closedMessage;
  CondType condType;
  int condTargetId;
  int condNum;
  int parentClassBoardBaseId;
  List<ClassBoardClass> classes;
  List<ClassBoardSquare> squares;
  List<ClassBoardLine> lines;

  ClassBoard({
    required this.id,
    this.name = "",
    this.icon,
    // this.dispItems = const [],
    this.condType = CondType.none,
    this.condTargetId = 0,
    this.condNum = 0,
    this.classes = const [],
    this.squares = const [],
    this.lines = const [],
    this.parentClassBoardBaseId = 0,
  });

  bool get isGrand => parentClassBoardBaseId > 0 || id > 10000;

  String get uiIcon =>
      isGrand
          ? "https://static.atlasacademy.io/file/aa-fgo-extract-jp/ClassBoard/Bg/GrandClassIcon$id.png"
          : "https://static.atlasacademy.io/file/aa-fgo-extract-jp/ClassBoard/UI/DownloadClassBoardUIAtlas/DownloadClassBoardUIAtlas1/img_class_$id.png";

  String get btnIcon =>
      isGrand && classes.length == 1
          ? SvtClassX.clsIcon(classes.first.classId, 5)
          : "https://static.atlasacademy.io/JP/ClassIcons/btn_tab_$id.png";

  String get dispName {
    if (id >= 1 && id <= 7) {
      if (classes.length == 1 && classes.single.classId == id) {
        return Transl.svtClassId(id).l;
      }
    }
    if (id == 8) return 'EXTRA Ⅰ';
    if (id == 9) return 'EXTRA Ⅱ';
    return name;
  }

  int getSkillLv(int id, ClassBoardSkillType type) {
    int lv = 0;
    for (final square in squares) {
      if (square.skillType == type && square.targetSkill?.id == id) {
        lv += square.upSkillLv;
      }
    }
    return lv;
  }

  ClassBoardPlan get status => db.curUser.classBoardStatusOf(id);
  ClassBoardPlan get plan_ => db.curPlan_.classBoardPlan(id);
  LockPlan unlockedOf(int squareId) =>
      LockPlan.from(status.unlockedSquares.contains(squareId), plan_.unlockedSquares.contains(squareId));
  LockPlan enhancedOf(int squareId) =>
      LockPlan.from(status.enhancedSquares.contains(squareId), plan_.enhancedSquares.contains(squareId));

  factory ClassBoard.fromJson(Map<String, dynamic> json) => _$ClassBoardFromJson(json);

  Map<String, dynamic> toJson() => _$ClassBoardToJson(this);

  @override
  String get route => Routes.classBoardI(id);

  NiceSkill? toSkill(ClassBoardPlan v) {
    Map<int, NiceSkill> skills = {};
    Map<int, int> skillLvs = {};
    Map<int, ClassBoardCommandSpell> spells = {};
    Map<int, int> spellLvs = {};
    for (final square in squares) {
      final targetSkill = square.targetSkill;
      final targetCommandSpell = square.targetCommandSpell;
      if (targetSkill != null) {
        if (v.enhancedSquares.contains(square.id)) {
          skills.putIfAbsent(targetSkill.id, () => targetSkill);
          skillLvs.addNum(targetSkill.id, square.upSkillLv);
        }
      } else if (targetCommandSpell != null) {
        if (v.enhancedSquares.contains(square.id)) {
          spells.putIfAbsent(targetCommandSpell.id, () => targetCommandSpell);
          spellLvs.addNum(targetCommandSpell.id, square.upSkillLv);
        }
      }
    }
    List<NiceFunction> functions = [];
    for (final skillId in skillLvs.keys) {
      final skill = skills[skillId]!;
      final lv = skillLvs[skillId]!.clamp(0, skill.maxLv);
      if (lv == 0) continue;
      for (final func in skill.functions) {
        final func2 = NiceFunction.fromJson(func.toJson());
        func2.svals = [func.svals[lv - 1]];
        functions.add(func2);
      }
    }
    for (final spellId in spellLvs.keys) {
      final spell = spells[spellId]!;
      final lv = spellLvs[spellId]!.clamp(0, spell.functions.firstOrNull?.svals.length ?? 0);
      if (lv == 0 || spell.functions.isEmpty) continue;
      final func = spell.functions.first;
      functions.add(
        NiceFunction(
          funcId: -spellId,
          funcType: FuncType.addState,
          funcTargetType: FuncTargetType.self,
          funcPopupText: spell.name,
          funcPopupIcon: func.funcPopupIcon,
          buffs: [
            Buff(
              id: -spellId,
              type: BuffType.classboardCommandSpellAfterFunction,
              name: spell.name,
              detail: spell.detail,
              icon: func.funcPopupIcon,
            ),
          ],
          svals: [
            DataVals({
              "Turn": -1,
              "Count": -1,
              "Rate": 5000,
              // "ClassBoardId": id,
              "Value": spellId,
              "Value2": lv,
            }),
          ],
        ),
      );
    }
    if (functions.isEmpty) return null;
    return NiceSkill(
      id: -(1000000 + DateTime.now().timestamp % 1000000),
      type: SkillType.passive,
      name: "${S.current.class_board} $dispName",
      icon: btnIcon,
      num: 0,
      coolDown: [0],
      functions: functions,
      actIndividuality:
          classes
              .map((e) => ConstData.classInfo[e.classId]?.individuality ?? 0)
              .where((e) => e > 0)
              .map((e) => NiceTrait(id: e))
              .toList(),
    );
  }
}

@JsonSerializable(converters: [CondTypeConverter()])
class ClassBoardClass {
  int classId;
  // SvtClass className;
  CondType condType;
  int condTargetId;
  int condNum;

  ClassBoardClass({required this.classId, this.condType = CondType.none, this.condTargetId = 0, this.condNum = 0});

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
    } else if (lock != null) {
      for (final itemAmount in lock!.items) {
        if (itemAmount.itemId >= 51 && itemAmount.itemId <= 53) {
          return "https://static.atlasacademy.io/JP/ClassBoard/Icon/lock_${itemAmount.itemId}.png";
        }
      }
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
  int commandSpellId; // current only dump csId=1 one, but not csId=9. They are the same, but should always check csId
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
      id: -id,
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

  ClassBoardLine({required this.id, required this.prevSquareId, required this.nextSquareId});

  factory ClassBoardLine.fromJson(Map<String, dynamic> json) => _$ClassBoardLineFromJson(json);

  Map<String, dynamic> toJson() => _$ClassBoardLineToJson(this);
}

enum ClassBoardSkillType { none, passive, commandSpell }

enum ClassBoardSquareFlag { none, start, blank }
