// ignore_for_file: non_constant_identifier_names

import 'package:flutter/material.dart';

import 'package:chaldea/app/app.dart';
import 'package:chaldea/app/modules/func/func_detail.dart';
import 'package:chaldea/utils/utils.dart';
import '../../app/tools/gamedata_loader.dart';
import '../db.dart';
import '../userdata/filter_data.dart';
import '_helper.dart';
import 'gamedata.dart';

export 'buff.dart';

part '../../generated/models/gamedata/func.g.dart';

@JsonSerializable()
class NiceFunction with RouteInfo implements BaseFunction {
  BaseFunction _baseFunc;

  @override
  int get funcId => _baseFunc.funcId;
  @override
  FuncType get funcType => _baseFunc.funcType;
  @override
  FuncTargetType get funcTargetType => _baseFunc.funcTargetType;
  @override
  FuncApplyTarget get funcTargetTeam => _baseFunc.funcTargetTeam;
  @override
  String get funcPopupText => _baseFunc.funcPopupText;
  @override
  String? get funcPopupIcon => _baseFunc.funcPopupIcon;
  @override
  List<NiceTrait> get functvals => _baseFunc.functvals;
  @override
  List<NiceTrait> get funcquestTvals => _baseFunc.funcquestTvals;
  @override
  List<FuncGroup> get funcGroup => _baseFunc.funcGroup;
  @override
  List<NiceTrait> get traitVals => _baseFunc.traitVals;
  @override
  List<Buff> get buffs => _baseFunc.buffs;
  @override
  bool get isPlayerOnlyFunc => _baseFunc.isPlayerOnlyFunc;
  @override
  bool get isEnemyOnlyFunc => _baseFunc.isEnemyOnlyFunc;
  @override
  Transl<String, String> get lPopupText => _baseFunc.lPopupText;
  @override
  EffectTarget get effectTarget => _baseFunc.effectTarget;

  List<DataVals> svals;
  List<DataVals>? svals2;
  List<DataVals>? svals3;
  List<DataVals>? svals4;
  List<DataVals>? svals5;
  List<DataVals>? followerVals;

  NiceFunction({
    required int funcId,
    FuncType funcType = FuncType.unknown,
    required FuncTargetType funcTargetType,
    required FuncApplyTarget funcTargetTeam,
    String funcPopupText = '',
    String? funcPopupIcon,
    List<NiceTrait> functvals = const [],
    List<NiceTrait> funcquestTvals = const [],
    List<FuncGroup> funcGroup = const [],
    List<NiceTrait> traitVals = const [],
    List<Buff> buffs = const [],
    List<DataVals>? svals,
    this.svals2,
    this.svals3,
    this.svals4,
    this.svals5,
    this.followerVals,
  })  : _baseFunc = BaseFunction(
          funcId: funcId,
          funcType: funcType,
          funcTargetType: funcTargetType,
          funcTargetTeam: funcTargetTeam,
          funcPopupText: funcPopupText,
          funcPopupIcon: funcPopupIcon,
          functvals: functvals,
          funcquestTvals: funcquestTvals,
          funcGroup: funcGroup,
          traitVals: traitVals,
          buffs: buffs,
        ),
        svals = svals ?? [];

  @override
  String get route => _baseFunc.route;
  @override
  void routeTo({Widget? child, bool popDetails = false, Region? region}) =>
      _baseFunc.routeTo(child: child, popDetails: popDetails, region: region);

  List<List<DataVals>?> get svalsList =>
      [svals, svals2, svals3, svals4, svals5];

  Iterable<DataVals> get allDataVals sync* {
    yield* svals;
    if (svals2 != null) yield* svals2!;
    if (svals3 != null) yield* svals3!;
    if (svals4 != null) yield* svals4!;
    if (svals5 != null) yield* svals5!;
  }

  List<DataVals> get crossVals {
    if (svals.length != 5) return svals;
    return [
      for (int i = 0; i < svals.length; i++)
        svalsList.getOrNull(i)?[i] ?? svals[i]
    ];
  }

  DataVals getStaticVal({bool levelOnly = false, bool ocOnly = false}) {
    assert(!levelOnly || !ocOnly);
    final _vals = levelOnly
        ? svals
        : ocOnly
            ? ocVals(0)
            : allDataVals;

    List<Map<String, dynamic>> allVals = _vals.map((e) => e.toJson()).toList();
    if (allVals.isEmpty) return DataVals();

    Map<String, Set> x = {};
    for (final vals in allVals) {
      vals.forEach((key, value) {
        final l = x.putIfAbsent(key, () => {});
        if (value is List && l.any((e) => e.toString() == value.toString())) {
          //
        } else if (value is Map &&
            l.any((e) => e.toString() == value.toString())) {
        } else {
          l.add(value);
        }
      });
    }
    x.removeWhere((key, value) => value.length > 1);
    return DataVals.fromJson(x.map((key, value) => MapEntry(key, value.first)));
  }

  List<DataVals> getMutatingVals(DataVals? staticVals,
      {bool levelOnly = false, bool ocOnly = false}) {
    assert(!levelOnly || !ocOnly);
    staticVals ??= getStaticVal(levelOnly: levelOnly, ocOnly: ocOnly);
    final staticKeys = staticVals.toJson().keys.toSet();
    List<DataVals> valList = [];
    final _svals = levelOnly
        ? svals
        : ocOnly
            ? ocVals(0)
            : crossVals;
    for (int i = 0; i < svals.length; i++) {
      final val = _svals.getOrNull(i);
      if (val != null) {
        final valJson = val.toJson()
          ..removeWhere((key, value) => staticKeys.contains(key));
        if (valJson.isEmpty) continue;
        valList.add(DataVals.fromJson(valJson));
      }
    }
    return valList;
  }

  List<DataVals> ocVals(int lv) {
    assert(lv >= 0 && lv < svals.length, lv);
    return [
      for (final sv in [svals, svals2, svals3, svals4, svals5])
        if (sv != null) sv[lv]
    ];
  }

  /// updating if [_$NiceFunctionFromJson] changed
  factory NiceFunction.fromJson(Map<String, dynamic> json) {
    _$NiceFunctionFromJson; // avoid unused warning
    if (json['funcType'] == null) {
      final baseFunction = GameDataLoader
          .instance.tmp.gameJson!['baseFunctions']![json['funcId'].toString()]!;
      json.addAll(Map.from(baseFunction));
    }
    final first = (json['svals'] as List?)?.getOrNull(0);
    DataVals? firstVals;
    if (first is Map) {
      for (final key1 in ['svals', 'svals2', 'svals3', 'svals4', 'svals5']) {
        final svals = json[key1];
        if (svals is! List) continue;
        for (int index = 0; index < svals.length; index++) {
          if (key1 == 'svals' && index == 0) continue;
          svals[index] = first.deepCopy()..addAll(svals[index] as Map);
        }
      }
      firstVals = DataVals.fromJson(Map<String, dynamic>.from(first));
    }
    DataVals _toVals(dynamic e) {
      if ((e as Map).isEmpty && firstVals != null) return firstVals;
      return DataVals.fromJson(Map<String, dynamic>.from(e));
    }

    return NiceFunction(
      funcId: json['funcId'] as int,
      funcType: $enumDecodeNullable(_$FuncTypeEnumMap, json['funcType']) ??
          FuncType.unknown,
      funcTargetType:
          $enumDecode(_$FuncTargetTypeEnumMap, json['funcTargetType']),
      funcTargetTeam:
          $enumDecode(_$FuncApplyTargetEnumMap, json['funcTargetTeam']),
      funcPopupText: json['funcPopupText'] as String? ?? '',
      funcPopupIcon: json['funcPopupIcon'] as String?,
      functvals: (json['functvals'] as List<dynamic>?)
              ?.map((e) =>
                  NiceTrait.fromJson(Map<String, dynamic>.from(e as Map)))
              .toList(growable: false) ??
          const [],
      funcquestTvals: (json['funcquestTvals'] as List<dynamic>?)
              ?.map((e) =>
                  NiceTrait.fromJson(Map<String, dynamic>.from(e as Map)))
              .toList(growable: false) ??
          const [],
      funcGroup: (json['funcGroup'] as List<dynamic>?)
              ?.map((e) =>
                  FuncGroup.fromJson(Map<String, dynamic>.from(e as Map)))
              .toList(growable: false) ??
          const [],
      traitVals: (json['traitVals'] as List<dynamic>?)
              ?.map((e) =>
                  NiceTrait.fromJson(Map<String, dynamic>.from(e as Map)))
              .toList(growable: false) ??
          const [],
      buffs: (json['buffs'] as List<dynamic>?)
              ?.map((e) => Buff.fromJson(Map<String, dynamic>.from(e as Map)))
              .toList(growable: false) ??
          const [],
      svals: (json['svals'] as List<dynamic>?)
          ?.map(_toVals)
          .toList(growable: false),
      svals2: (json['svals2'] as List<dynamic>?)
          ?.map(_toVals)
          .toList(growable: false),
      svals3: (json['svals3'] as List<dynamic>?)
          ?.map(_toVals)
          .toList(growable: false),
      svals4: (json['svals4'] as List<dynamic>?)
          ?.map(_toVals)
          .toList(growable: false),
      svals5: (json['svals5'] as List<dynamic>?)
          ?.map(_toVals)
          .toList(growable: false),
      followerVals: (json['followerVals'] as List<dynamic>?)
          ?.map(_toVals)
          .toList(growable: false),
    );
  }

  static Iterable<T> filterFuncs<T extends BaseFunction>({
    required Iterable<T> funcs,
    bool showPlayer = true,
    bool showEnemy = false,
    bool showNone = false,
    bool includeTrigger = false,
    GameData? gameData,
  }) {
    gameData ??= db.gameData;
    List<T> filteredFuncs = funcs
        .where((func) {
          if (!showNone && func.funcType == FuncType.none) return false;
          if (func.funcTargetTeam == FuncApplyTarget.playerAndEnemy) {
            return true;
          }
          bool player = func.funcTargetTeam == FuncApplyTarget.player;
          if (func.funcTargetType.isEnemy) {
            player = !player;
          }
          return player ? showPlayer : showEnemy;
        })
        .toList()
        .cast<T>()
        .toList(); // avoid type cast error
    if (!includeTrigger) return filteredFuncs;
    for (final func in List.of(filteredFuncs)) {
      if (func is! NiceFunction) continue;
      filteredFuncs.addAll(getTriggerFuncs<T>(
        func: func,
        showPlayer: showPlayer,
        showEnemy: showEnemy,
        showNone: showNone,
        gameData: gameData,
      ));
    }

    return filteredFuncs;
  }

  static Iterable<T> getTriggerFuncs<T extends BaseFunction>({
    required NiceFunction func,
    bool showPlayer = true,
    bool showEnemy = false,
    bool showNone = false,
    GameData? gameData,
  }) sync* {
    if (func.svals.isEmpty) return;
    gameData ??= db.gameData;
    if (T == BaseFunction) {
      if (func.svals.first.DependFuncId != null) {
        final dependFunc =
            db.gameData.baseFunctions[func.svals.first.DependFuncId];
        if (dependFunc != null) {
          yield dependFunc as T;
        }
      }
    }
    if (func.buffs.isEmpty) return;
    final trigger =
        kBuffValueTriggerTypes[func.buffs.first.type]?.call(func.svals.first);
    if (trigger == null) return;
    final SkillOrTd? skill = func.svals.first.UseTreasureDevice == 1
        ? gameData.baseTds[trigger.skill]
        : gameData.baseSkills[trigger.skill];
    if (skill == null) return;
    yield* filterFuncs<T>(
      funcs: skill.functions.cast(),
      showPlayer: func.funcTargetType.isEnemy ? showEnemy : showPlayer,
      showEnemy: func.funcTargetType.isEnemy ? showPlayer : showEnemy,
      showNone: showNone,
      includeTrigger: false, // avoid regression
    );
  }
}

@JsonSerializable()
class BaseFunction with RouteInfo {
  final int funcId;
  final FuncType funcType;
  final FuncTargetType funcTargetType;
  final FuncApplyTarget funcTargetTeam;
  final String funcPopupText;
  final String? funcPopupIcon;
  final List<NiceTrait> functvals;
  final List<NiceTrait> funcquestTvals;
  final List<FuncGroup> funcGroup;
  final List<NiceTrait> traitVals;
  final List<Buff> buffs;

  const BaseFunction.create({
    required this.funcId,
    this.funcType = FuncType.unknown,
    required this.funcTargetType,
    required this.funcTargetTeam,
    this.funcPopupText = "",
    this.funcPopupIcon,
    this.functvals = const [],
    this.funcquestTvals = const [],
    this.funcGroup = const [],
    this.traitVals = const [],
    this.buffs = const [],
  });

  factory BaseFunction({
    required int funcId,
    FuncType funcType = FuncType.unknown,
    required FuncTargetType funcTargetType,
    required FuncApplyTarget funcTargetTeam,
    String funcPopupText = '',
    String? funcPopupIcon,
    List<NiceTrait> functvals = const [],
    List<NiceTrait> funcquestTvals = const [],
    List<FuncGroup> funcGroup = const [],
    List<NiceTrait> traitVals = const [],
    List<Buff> buffs = const [],
  }) =>
      GameDataLoader.instance.tmp.getFunc(
          funcId,
          () => BaseFunction.create(
                funcId: funcId,
                funcType: funcType,
                funcTargetType: funcTargetType,
                funcTargetTeam: funcTargetTeam,
                funcPopupText: funcPopupText,
                funcPopupIcon: funcPopupIcon,
                functvals: functvals,
                funcquestTvals: funcquestTvals,
                funcGroup: funcGroup,
                traitVals: traitVals,
                buffs: buffs,
              ));

  factory BaseFunction.fromJson(Map<String, dynamic> json) =>
      _$BaseFunctionFromJson(json);

  @override
  String get route => Routes.funcI(funcId);

  @override
  void routeTo({Widget? child, bool popDetails = false, Region? region}) {
    return super.routeTo(
      child: child ?? FuncDetailPage(func: this, region: region),
      popDetails: popDetails,
    );
  }

  Transl<String, String> get lPopupText =>
      Transl.funcPopuptextBase(funcPopupText, funcType);

  bool get isPlayerOnlyFunc =>
      (funcTargetTeam == FuncApplyTarget.enemy && funcTargetType.isEnemy) ||
      (funcTargetTeam == FuncApplyTarget.player && !funcTargetType.isEnemy);
  bool get isEnemyOnlyFunc =>
      (funcTargetTeam == FuncApplyTarget.enemy && !funcTargetType.isEnemy) ||
      (funcTargetTeam == FuncApplyTarget.player && funcTargetType.isEnemy);
  EffectTarget get effectTarget => EffectTarget.fromFunc(funcTargetType);
}

@JsonSerializable()
class FuncGroup {
  int eventId;
  int baseFuncId;
  String nameTotal;
  String name;
  String? icon;
  int priority;
  bool isDispValue;

  FuncGroup({
    required this.eventId,
    required this.baseFuncId,
    required this.nameTotal,
    required this.name,
    this.icon,
    required this.priority,
    required this.isDispValue,
  });

  factory FuncGroup.fromJson(Map<String, dynamic> json) =>
      _$FuncGroupFromJson(json);
}

const kEventFuncTypes = [
  FuncType.eventDropUp,
  FuncType.eventDropRateUp,
  FuncType.eventPointUp,
  FuncType.eventPointRateUp,
  FuncType.eventFortificationPointUp,
];

enum FuncType {
  unknown,
  none,
  addState,
  subState,
  damage,
  damageNp,
  gainStar,
  gainHp,
  gainNp,
  lossNp,
  shortenSkill,
  extendSkill,
  releaseState,
  lossHp,
  instantDeath,
  damageNpPierce,
  damageNpIndividual,
  addStateShort,
  gainHpPer,
  damageNpStateIndividual,
  hastenNpturn,
  delayNpturn,
  damageNpHpratioHigh,
  damageNpHpratioLow,
  cardReset,
  replaceMember,
  lossHpSafe,
  damageNpCounter,
  damageNpStateIndividualFix,
  damageNpSafe,
  callServant,
  ptShuffle,
  lossStar,
  changeServant,
  changeBg,
  damageValue,
  withdraw,
  fixCommandcard,
  shortenBuffturn,
  extendBuffturn,
  shortenBuffcount,
  extendBuffcount,
  changeBgm,
  displayBuffstring,
  resurrection,
  gainNpBuffIndividualSum,
  setSystemAliveFlag,
  forceInstantDeath,
  damageNpRare,
  gainNpFromTargets,
  gainHpFromTargets,
  lossHpPer,
  lossHpPerSafe,
  shortenUserEquipSkill,
  quickChangeBg,
  shiftServant,
  damageNpAndCheckIndividuality,
  absorbNpturn,
  overwriteDeadType,
  forceAllBuffNoact,
  breakGaugeUp,
  breakGaugeDown,
  moveToLastSubmember,
  expUp,
  qpUp,
  dropUp,
  friendPointUp,
  eventDropUp,
  eventDropRateUp,
  eventPointUp,
  eventPointRateUp,
  transformServant,
  qpDropUp,
  servantFriendshipUp,
  userEquipExpUp,
  classDropUp,
  enemyEncountCopyRateUp,
  enemyEncountRateUp,
  enemyProbDown,
  getRewardGift,
  sendSupportFriendPoint,
  movePosition,
  revival,
  damageNpIndividualSum,
  damageValueSafe,
  friendPointUpDuplicate,
  moveState,
  changeBgmCostume,
  func126,
  func127,
  updateEntryPositions,
  buddyPointUp,
  addFieldChangeToField,
  subFieldBuff,
  eventFortificationPointUp,
  gainNpIndividualSum,
  setQuestRouteFlag,
  lastUsePlayerSkillCopy,
}

extension FuncTargetTypeX on FuncTargetType {
  bool get isEnemy => name.toLowerCase().contains('enemy');
}

enum FuncTargetType {
  self,
  ptOne,
  ptAnother,
  ptAll,
  enemy,
  enemyAnother,
  enemyAll,
  ptFull,
  enemyFull,
  ptOther,
  ptOneOther,
  ptRandom,
  enemyOther,
  enemyRandom,
  ptOtherFull,
  enemyOtherFull,
  ptselectOneSub,
  ptselectSub,
  ptOneAnotherRandom,
  ptSelfAnotherRandom,
  enemyOneAnotherRandom,
  ptSelfAnotherFirst,
  ptSelfBefore,
  ptSelfAfter,
  ptSelfAnotherLast,
  commandTypeSelfTreasureDevice,
  fieldOther,
  enemyOneNoTargetNoAction,
  ptOneHpLowestValue,
  ptOneHpLowestRate,
}

enum FuncApplyTarget {
  player,
  enemy,
  playerAndEnemy,
}
