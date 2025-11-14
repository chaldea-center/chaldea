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

@JsonSerializable(converters: [FuncTypeConverter(), FuncApplyTargetConverter()])
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
  @TraitListConverter()
  List<int> get functvals => _baseFunc.functvals;
  @override
  @Trait2dListConverter()
  List<List<int>> get overWriteTvalsList => _baseFunc.overWriteTvalsList;
  @override
  @TraitListConverter()
  List<int> get funcquestTvals => _baseFunc.funcquestTvals;
  @override
  List<FuncGroup> get funcGroup => _baseFunc.funcGroup;
  @override
  @TraitListConverter()
  List<int> get traitVals => _baseFunc.traitVals;
  @override
  List<Buff> get buffs => _baseFunc.buffs;
  @override
  FuncScript? get script => _baseFunc.script;

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
    FuncApplyTarget funcTargetTeam = FuncApplyTarget.all,
    String funcPopupText = '',
    String? funcPopupIcon,
    List<int> functvals = const [],
    List<List<int>> overWriteTvalsList = const [],
    List<int> funcquestTvals = const [],
    List<FuncGroup> funcGroup = const [],
    List<int> traitVals = const [],
    List<Buff> buffs = const [],
    FuncScript? script,
    List<DataVals>? svals,
    this.svals2,
    this.svals3,
    this.svals4,
    this.svals5,
    this.followerVals,
  }) : _baseFunc = BaseFunction(
         funcId: funcId,
         funcType: funcType,
         funcTargetType: funcTargetType,
         funcTargetTeam: funcTargetTeam,
         funcPopupText: funcPopupText,
         funcPopupIcon: funcPopupIcon,
         functvals: functvals,
         overWriteTvalsList: overWriteTvalsList,
         funcquestTvals: funcquestTvals,
         funcGroup: funcGroup,
         traitVals: traitVals,
         buffs: buffs,
         script: script,
       ),
       svals = svals ?? [];

  static String normFuncPopupText(String text) {
    if (const <String>{'', '-', 'なし', 'None', 'none', '无', '無', '없음'}.contains(text)) {
      return '';
    }
    return text;
  }

  @override
  String get route => _baseFunc.route;
  @override
  void routeTo({Widget? child, bool popDetails = false, Region? region}) =>
      _baseFunc.routeTo(child: child, popDetails: popDetails, region: region);

  List<List<DataVals>?> get svalsList => [svals, svals2, svals3, svals4, svals5];

  Iterable<DataVals> get allDataVals sync* {
    yield* svals;
    if (svals2 != null) yield* svals2!;
    if (svals3 != null) yield* svals3!;
    if (svals4 != null) yield* svals4!;
    if (svals5 != null) yield* svals5!;
  }

  List<DataVals> get crossVals {
    if (svals.length != 5) return svals;
    return [for (int i = 0; i < svals.length; i++) svalsList.getOrNull(i)?[i] ?? svals[i]];
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
        } else if (value is Map && l.any((e) => e.toString() == value.toString())) {
        } else {
          l.add(value);
        }
      });
    }
    x.removeWhere((key, value) => value.length > 1);
    return DataVals.fromJson(x.map((key, value) => MapEntry(key, value.first)));
  }

  List<DataVals> getMutatingVals(DataVals? staticVals, {bool levelOnly = false, bool ocOnly = false}) {
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
        final valJson = val.toJson()..removeWhere((key, value) => staticKeys.contains(key));
        if (valJson.isEmpty) continue;
        valList.add(DataVals.fromJson(valJson));
      }
    }
    return valList;
  }

  List<DataVals> ocVals(int index) {
    assert(index >= 0 && index < svals.length, index);
    return [
      for (final sv in [svals, svals2, svals3, svals4, svals5])
        if (sv != null) sv[index],
    ];
  }

  /// updating if [_$NiceFunctionFromJson] changed
  factory NiceFunction.fromJson(Map<String, dynamic> json) {
    _$NiceFunctionFromJson; // avoid unused warning
    if (json['funcType'] == null) {
      final baseFunction = GameDataLoader.instance.tmp.gameJson!['baseFunctions']![json['funcId'].toString()]!;
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
          svals[index] = Map<String, dynamic>.from(first.deepCopy()..addAll(svals[index] as Map));
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
      funcType: $enumDecodeNullable(_$FuncTypeEnumMap, json['funcType']) ?? FuncType.unknown,
      funcTargetType: $enumDecode(_$FuncTargetTypeEnumMap, json['funcTargetType']),
      funcTargetTeam: const FuncApplyTargetConverter().fromJson(json['funcTargetTeam'] ?? FuncApplyTarget.all.name),
      funcPopupText: json['funcPopupText'] as String? ?? '',
      funcPopupIcon: json['funcPopupIcon'] as String?,
      functvals: const TraitListConverter().fromJsonNull(json['functvals'] as List<dynamic>?) ?? const [],
      overWriteTvalsList:
          const Trait2dListConverter().fromJsonNull(
            (json['overWriteTvalsList'] as List<dynamic>?)?.map((e) => e as List).toList(),
          ) ??
          const [],
      funcquestTvals: const TraitListConverter().fromJsonNull(json['funcquestTvals'] as List<dynamic>?) ?? const [],
      funcGroup:
          (json['funcGroup'] as List<dynamic>?)
              ?.map((e) => FuncGroup.fromJson(Map<String, dynamic>.from(e as Map)))
              .toList() ??
          const [],
      traitVals: const TraitListConverter().fromJsonNull(json['traitVals'] as List<dynamic>?) ?? const [],
      buffs:
          (json['buffs'] as List<dynamic>?)?.map((e) => Buff.fromJson(Map<String, dynamic>.from(e as Map))).toList() ??
          const [],
      script: json['script'] == null ? null : FuncScript.fromJson(Map<String, dynamic>.from(json['script'] as Map)),
      svals: (json['svals'] as List<dynamic>?)?.map(_toVals).toList(growable: false),
      svals2: (json['svals2'] as List<dynamic>?)?.map(_toVals).toList(growable: false),
      svals3: (json['svals3'] as List<dynamic>?)?.map(_toVals).toList(growable: false),
      svals4: (json['svals4'] as List<dynamic>?)?.map(_toVals).toList(growable: false),
      svals5: (json['svals5'] as List<dynamic>?)?.map(_toVals).toList(growable: false),
      followerVals: (json['followerVals'] as List<dynamic>?)?.map(_toVals).toList(growable: false),
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
          if (func.funcTargetTeam == FuncApplyTarget.all) {
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
      filteredFuncs.addAll(
        getTriggerFuncs<T>(
          func: func,
          showPlayer: showPlayer,
          showEnemy: showEnemy,
          showNone: showNone,
          gameData: gameData,
        ),
      );
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
        final dependFunc = db.gameData.baseFunctions[func.svals.first.DependFuncId];
        if (dependFunc != null) {
          yield dependFunc as T;
        }
      }
    }
    if (func.buffs.isEmpty) return;
    final triggers = kBuffValueTriggerTypes[func.buffs.first.type];
    if (triggers == null) return;
    for (final trigger in triggers) {
      final detail = trigger(func.svals.first);
      final SkillOrTd? skill = func.svals.first.UseTreasureDevice == 1
          ? gameData.baseTds[detail.skill]
          : gameData.baseSkills[detail.skill];
      if (skill == null) continue;
      yield* filterFuncs<T>(
        funcs: skill.functions.cast(),
        showPlayer: func.funcTargetType.isEnemy ? showEnemy : showPlayer,
        showEnemy: func.funcTargetType.isEnemy ? showPlayer : showEnemy,
        showNone: showNone,
        includeTrigger: false, // avoid regression
      );
    }
  }

  @override
  Map<String, dynamic> toJson() => _$NiceFunctionToJson(this);
}

@JsonSerializable(converters: [FuncTypeConverter(), FuncApplyTargetConverter()])
class BaseFunction with RouteInfo {
  final int funcId;
  final FuncType funcType;
  final FuncTargetType funcTargetType;
  final FuncApplyTarget funcTargetTeam;
  final String funcPopupText;
  final String? funcPopupIcon;
  @TraitListConverter()
  final List<int> functvals;
  @Trait2dListConverter()
  final List<List<int>> overWriteTvalsList;
  @TraitListConverter()
  final List<int> funcquestTvals;
  final List<FuncGroup> funcGroup;
  @TraitListConverter()
  final List<int> traitVals;
  final List<Buff> buffs;
  final FuncScript? script;

  const BaseFunction.create({
    required this.funcId,
    this.funcType = FuncType.unknown,
    required this.funcTargetType,
    this.funcTargetTeam = FuncApplyTarget.all,
    this.funcPopupText = "",
    this.funcPopupIcon,
    this.functvals = const [],
    this.overWriteTvalsList = const [],
    this.funcquestTvals = const [],
    this.funcGroup = const [],
    this.traitVals = const [],
    this.buffs = const [],
    this.script,
  });

  factory BaseFunction({
    required int funcId,
    FuncType funcType = FuncType.unknown,
    required FuncTargetType funcTargetType,
    required FuncApplyTarget funcTargetTeam,
    String funcPopupText = '',
    String? funcPopupIcon,
    List<int> functvals = const [],
    List<List<int>> overWriteTvalsList = const [],
    List<int> funcquestTvals = const [],
    List<FuncGroup> funcGroup = const [],
    List<int> traitVals = const [],
    List<Buff> buffs = const [],
    FuncScript? script,
  }) => GameDataLoader.instance.tmp.getFunc(
    funcId,
    () => BaseFunction.create(
      funcId: funcId,
      funcType: funcType,
      funcTargetType: funcTargetType,
      funcTargetTeam: funcTargetTeam,
      funcPopupText: funcPopupText,
      funcPopupIcon: funcPopupIcon,
      functvals: functvals,
      overWriteTvalsList: overWriteTvalsList,
      funcquestTvals: funcquestTvals,
      funcGroup: funcGroup,
      traitVals: traitVals,
      buffs: buffs,
      script: script,
    ),
  );

  factory BaseFunction.fromJson(Map<String, dynamic> json) => _$BaseFunctionFromJson(json);

  @override
  String get route => Routes.funcI(funcId);

  @override
  void routeTo({Widget? child, bool popDetails = false, Region? region}) {
    return super.routeTo(
      child: child ?? FuncDetailPage(func: this, region: region),
      popDetails: popDetails,
    );
  }

  Map<String, dynamic> toJson() => _$BaseFunctionToJson(this);
}

extension BaseFunctionX on BaseFunction {
  Buff? get buff => buffs.isEmpty ? null : buffs.first;

  Transl<String, String> get lPopupText => Transl.funcPopuptextBase(funcPopupText, funcType);

  bool get canBePlayerFunc =>
      funcTargetTeam == FuncApplyTarget.all ||
      (funcTargetTeam == FuncApplyTarget.enemy && funcTargetType.canTargetEnemy) ||
      (funcTargetTeam == FuncApplyTarget.player && funcTargetType.canTargetAlly);
  bool get canBeEnemyFunc =>
      funcTargetTeam == FuncApplyTarget.all ||
      (funcTargetTeam == FuncApplyTarget.enemy && funcTargetType.canTargetAlly) ||
      (funcTargetTeam == FuncApplyTarget.player && funcTargetType.canTargetEnemy);

  bool get isPlayerOnlyFunc =>
      (funcTargetTeam == FuncApplyTarget.enemy && funcTargetType.isEnemy) ||
      (funcTargetTeam == FuncApplyTarget.player && funcTargetType.isAlly);
  bool get isEnemyOnlyFunc =>
      (funcTargetTeam == FuncApplyTarget.enemy && funcTargetType.isAlly) ||
      (funcTargetTeam == FuncApplyTarget.player && funcTargetType.isEnemy);
  EffectTarget get effectTarget => EffectTarget.fromFunc(funcTargetType);

  List<int> getCommonFuncIndividuality() {
    return ConstData.funcTypeDetail[funcType.value]?.individuality ?? [];
  }

  List<int> getFuncIndividuality() {
    return [...getCommonFuncIndividuality(), ...?script?.funcIndividuality];
  }

  List<List<int>> getOverwriteTvalsList() {
    final valsList = [overWriteTvalsList, script?.overwriteTvals];
    for (final tvals in valsList) {
      if (tvals == null || tvals.isEmpty) continue;
      final tvals2 = tvals.where((e) => e.isNotEmpty).toList();
      if (tvals2.isNotEmpty) return tvals2;
    }
    return [];
  }

  bool get isEventOnlyEffect {
    if (this is NiceFunction) {
      final vals = (this as NiceFunction).svals.firstOrNull;
      if ((vals?.EventId ?? 0) != 0) return true;
    }
    if (funcquestTvals.any(Trait.isEventField)) return true;
    return false;
  }
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

  factory FuncGroup.fromJson(Map<String, dynamic> json) => _$FuncGroupFromJson(json);

  Map<String, dynamic> toJson() => _$FuncGroupToJson(this);
}

@JsonSerializable()
class FuncScript {
  @Trait2dListConverter()
  List<List<int>>? overwriteTvals;
  @TraitListConverter()
  List<int>? funcIndividuality;

  FuncScript({this.overwriteTvals, this.funcIndividuality});

  factory FuncScript.fromJson(Map<String, dynamic> json) => _$FuncScriptFromJson(json);

  Map<String, dynamic> toJson() => _$FuncScriptToJson(this);
}

const kEventFuncTypes = [
  FuncType.eventDropUp,
  FuncType.eventDropRateUp,
  FuncType.eventPointUp,
  FuncType.eventPointRateUp,
  FuncType.eventFortificationPointUp,
];

const kAddStateFuncTypes = [FuncType.addState, FuncType.addStateShort, FuncType.addFieldChangeToField];

@JsonEnum(alwaysCreate: true)
enum FuncType {
  unknown(-1),
  none(0),
  addState(1),
  subState(2),
  damage(3),
  damageNp(4),
  gainStar(5),
  gainHp(6),
  gainNp(7),
  lossNp(8),
  shortenSkill(9),
  extendSkill(10),
  releaseState(11),
  lossHp(12),
  instantDeath(13),
  damageNpPierce(14),
  damageNpIndividual(15),
  addStateShort(16),
  gainHpPer(17),
  damageNpStateIndividual(18),
  hastenNpturn(19),
  delayNpturn(20),
  damageNpHpratioHigh(21),
  damageNpHpratioLow(22),
  cardReset(23),
  replaceMember(24),
  lossHpSafe(25),
  damageNpCounter(26),
  damageNpStateIndividualFix(27),
  damageNpSafe(28),
  callServant(29),
  ptShuffle(30),
  lossStar(31),
  changeServant(32),
  changeBg(33),
  damageValue(34),
  withdraw(35),
  fixCommandcard(36),
  shortenBuffturn(37),
  extendBuffturn(38),
  shortenBuffcount(39),
  extendBuffcount(40),
  changeBgm(41),
  displayBuffstring(42),
  resurrection(43),
  gainNpBuffIndividualSum(44),
  setSystemAliveFlag(45),
  forceInstantDeath(46),
  damageNpRare(47),
  gainNpFromTargets(48),
  gainHpFromTargets(49),
  lossHpPer(50),
  lossHpPerSafe(51),
  shortenUserEquipSkill(52),
  quickChangeBg(53),
  shiftServant(54),
  damageNpAndOrCheckIndividuality(55),
  absorbNpturn(56),
  overwriteDeadType(57),
  forceAllBuffNoact(58),
  breakGaugeUp(59), // DataVals.ChangeMaxBreakGauge? restore hpbar : insert new hpbar
  breakGaugeDown(60),
  moveToLastSubmember(61),
  extendUserEquipSkill(62),
  updateEnemyEntryMaxCountEachTurn(63),
  expUp(101),
  qpUp(102),
  dropUp(103),
  friendPointUp(104),
  eventDropUp(105),
  eventDropRateUp(106),
  eventPointUp(107),
  eventPointRateUp(108),
  transformServant(109),
  qpDropUp(110),
  servantFriendshipUp(111),
  userEquipExpUp(112),
  classDropUp(113),
  enemyEncountCopyRateUp(114),
  enemyEncountRateUp(115),
  enemyProbDown(116),
  getRewardGift(117),
  sendSupportFriendPoint(118),
  movePosition(119), // Zeus battle
  revival(120),
  damageNpIndividualSum(121),
  damageValueSafe(122),
  friendPointUpDuplicate(123),
  moveState(124),
  changeBgmCostume(125),
  lossCommandSpell(126),
  gainCommandSpell(127),
  updateEntryPositions(128),
  buddyPointUp(129),
  addFieldChangeToField(130),
  subFieldBuff(131),
  eventFortificationPointUp(132),
  gainNpIndividualSum(133),
  setQuestRouteFlag(134),
  lastUsePlayerSkillCopy(135),
  changeEnemyMasterFace(136),
  damageValueSafeOnce(137),
  addBattleValue(138),
  setBattleValue(139),
  gainMultiplyNp(140),
  lossMultiplyNp(141),
  addBattlePoint(142),
  damageNpBattlePointPhase(143),
  setNpExecutedState(144),
  hideOverGauge(145),
  gainNpTargetSum(146),
  enemyCountChange(147),
  displayBattleMessage(148),
  generateBattleSkillDrop(149),
  changeMasterFace(150),
  enableMasterSkill(151),
  enableMasterCommandSpell(152),
  battleModelChange(153),
  gainNpCriticalstarSum(154),
  addBattleMissionValue(155),
  setBattleMissionValue(156),
  changeEnemyStatusUiType(157),
  swapFieldPosition(158),
  setDisplayDirectBattleMessageInFsm(159),
  addStateToField(160),
  addStateShortToField(161);

  final int value;
  const FuncType(this.value);

  bool get isDamageNp => name.startsWith('damageNp') && !ConstData.constantStr.functionTypeNotNpDamage.contains(value);

  bool get isAddState => kAddStateFuncTypes.contains(this);
}

enum FuncTargetType {
  self(0),
  ptOne(1),
  ptAnother(2),
  ptAll(3),
  enemy(4),
  enemyAnother(5),
  enemyAll(6),
  ptFull(7),
  enemyFull(8),
  ptOther(9),
  ptOneOther(10),
  ptRandom(11),
  enemyOther(12),
  enemyRandom(13),
  ptOtherFull(14),
  enemyOtherFull(15),
  ptselectOneSub(16), // 1+1
  ptselectSub(17), // ?
  ptOneAnotherRandom(18),
  ptSelfAnotherRandom(19),
  enemyOneAnotherRandom(20),
  ptSelfAnotherFirst(21),
  ptSelfBefore(22),
  ptSelfAfter(23),
  ptSelfAnotherLast(24),
  commandTypeSelfTreasureDevice(25),
  fieldOther(26),
  enemyOneNoTargetNoAction(27),
  ptOneHpLowestValue(28),
  ptOneHpLowestRate(29),
  enemyRange(30),
  handCommandcardRandomOne(31),
  fieldAll(32),
  noTarget(33),
  fieldRandom(34);

  const FuncTargetType(this.value);
  final int value;

  static FuncTargetType? fromId(int value) {
    return FuncTargetType.values.firstWhereOrNull((e) => e.value == value);
  }

  bool get isEnemy => name.toLowerCase().startsWith('enemy') && this != FuncTargetType.enemyOneNoTargetNoAction;
  bool get isAlly =>
      name.toLowerCase().startsWith('pt') ||
      const [FuncTargetType.self, FuncTargetType.commandTypeSelfTreasureDevice].contains(this);
  bool get isField => this == FuncTargetType.fieldOther || this == fieldAll || this == fieldRandom;
  bool get isDynamic => this == FuncTargetType.enemyOneNoTargetNoAction;

  bool get canTargetAlly => isAlly || isField || isDynamic || this == noTarget;
  bool get canTargetEnemy => isEnemy || isField || isDynamic || this == noTarget;

  bool get needNormalOneTarget => const [ptOne, ptAnother, ptOneOther].contains(this);

  bool get needRadomTarget => const [
    ptRandom,
    enemyRandom,
    ptOneAnotherRandom,
    ptSelfAnotherRandom,
    enemyOneAnotherRandom,
    fieldRandom,
  ].contains(this);
}

@JsonEnum(alwaysCreate: true)
enum FuncApplyTarget {
  player,
  enemy,
  all;

  static FuncApplyTarget fromBool({required bool showPlayer, required bool showEnemy}) {
    if (showPlayer && !showEnemy) return player;
    if (!showPlayer && showEnemy) return enemy;
    return all;
  }
}

enum GainNpIndividualSumTarget {
  target(0), // func TARGET! original enum name is `self`
  player(1),
  enemy(2),
  all(3),
  otherAll(4);

  const GainNpIndividualSumTarget(this.value);
  final int value;
}

enum TriggeredFieldCountTarget {
  ally(0),
  enemy(1),
  all(2);

  const TriggeredFieldCountTarget(this.value);
  final int value;
}

class FuncTypeConverter extends JsonConverter<FuncType, String> {
  const FuncTypeConverter();

  @override
  FuncType fromJson(String value) {
    return decodeEnumNullable(_$FuncTypeEnumMap, value) ??
        deprecatedTypes[value] ??
        decodeEnum(_$FuncTypeEnumMap, value, FuncType.unknown);
  }

  @override
  String toJson(FuncType obj) => _$FuncTypeEnumMap[obj] ?? obj.name;

  static Map<String, FuncType> deprecatedTypes = {
    "damageNpAndCheckIndividuality": FuncType.damageNpAndOrCheckIndividuality,
  };
}

class FuncApplyTargetConverter extends JsonConverter<FuncApplyTarget, String> {
  const FuncApplyTargetConverter();

  @override
  FuncApplyTarget fromJson(String value) {
    return decodeEnumNullable(_$FuncApplyTargetEnumMap, value) ?? deprecatedTypes[value] ?? FuncApplyTarget.all;
  }

  @override
  String toJson(FuncApplyTarget obj) => _$FuncApplyTargetEnumMap[obj] ?? obj.name;

  static Map<String, FuncApplyTarget> deprecatedTypes = {"playerAndEnemy": FuncApplyTarget.all};
}
