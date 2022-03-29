part of 'skill.dart';

@JsonSerializable()
class NiceFunction implements BaseFunction {
  @override
  int funcId;
  @override
  FuncType funcType;
  @override
  FuncTargetType funcTargetType;
  @override
  FuncApplyTarget funcTargetTeam;
  @override
  String funcPopupText;
  @override
  String? funcPopupIcon;
  @override
  List<NiceTrait> functvals;
  @override
  List<NiceTrait> funcquestTvals;
  @override
  List<FuncGroup> funcGroup;
  @override
  List<NiceTrait> traitVals;
  @override
  List<Buff> buffs;
  List<DataVals> svals;
  List<DataVals>? svals2;
  List<DataVals>? svals3;
  List<DataVals>? svals4;
  List<DataVals>? svals5;
  List<DataVals>? followerVals;

  NiceFunction({
    required this.funcId,
    this.funcType = FuncType.none,
    required this.funcTargetType,
    required this.funcTargetTeam,
    this.funcPopupText = '',
    this.funcPopupIcon,
    this.functvals = const [],
    this.funcquestTvals = const [],
    this.funcGroup = const [],
    this.traitVals = const [],
    this.buffs = const [],
    required this.svals,
    this.svals2,
    this.svals3,
    this.svals4,
    this.svals5,
    this.followerVals,
  });

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

  DataVals getStaticVal() {
    List<Map<String, dynamic>> allVals =
        allDataVals.map((e) => e.toJson()).toList();
    if (allVals.isEmpty) return DataVals();

    Map<String, Set> x = {};
    for (final v in allVals) {
      v.forEach((key, value) {
        x.putIfAbsent(key, () => {}).add(value);
      });
    }
    x.removeWhere((key, value) => value.length > 1);
    return DataVals.fromJson(x.map((key, value) => MapEntry(key, value.first)));
  }

  List<DataVals> getMutatingVals(DataVals? staticVals) {
    staticVals ??= getStaticVal();
    final staticKeys = staticVals.toJson().keys.toSet();
    List<DataVals> valList = [];
    for (int i = 0; i < svals.length; i++) {
      final val = (svalsList.getOrNull(i) ?? svals).getOrNull(i);
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

  factory NiceFunction.fromJson(Map<String, dynamic> json) {
    if (json['funcType'] == null) {
      final baseFunction = GameDataLoader
          .instance!.gameJson!['baseFunctions']![json['funcId'].toString()]!;
      json.addAll(Map.from(baseFunction));
    }

    return _$NiceFunctionFromJson(json);
  }
}

@JsonSerializable()
class Buff {
  int id;
  String name;
  String detail;
  String? icon;
  BuffType type;
  int buffGroup;
  BuffScript script;
  List<NiceTrait> vals;
  List<NiceTrait> tvals;
  List<NiceTrait> ckSelfIndv;
  List<NiceTrait> ckOpIndv;
  int maxRate;

  Buff({
    required this.id,
    required this.name,
    required this.detail,
    this.icon,
    this.type = BuffType.none,
    this.buffGroup = 0,
    BuffScript? script,
    this.vals = const [],
    this.tvals = const [],
    this.ckSelfIndv = const [],
    this.ckOpIndv = const [],
    required this.maxRate,
  }) : script = script ?? BuffScript();

  factory Buff.fromJson(Map<String, dynamic> json) => _$BuffFromJson(json);
}
