import 'package:json_annotation/json_annotation.dart';

import 'package:chaldea/models/gamedata/common.dart';
import '../db.dart';
import '../userdata/userdata.dart';
import 'servant.dart';
import 'skill.dart';
import 'wiki_data.dart';

part '../../generated/models/gamedata/mappings.g.dart';

class Transl<K, V> {
  final Map<K, MappingBase<V>> mappings;
  final MappingBase<V>? _m;
  final K key;
  final V _default;

  Transl(this.mappings, this.key, this._default) : _m = mappings[key];

  V get jp => mappings[key]?.jp ?? _default;

  V get cn => mappings[key]?.cn ?? _default;

  V get tw => mappings[key]?.tw ?? _default;

  V get na => mappings[key]?.na ?? _default;

  V get kr => mappings[key]?.kr ?? _default;

  MappingBase<V>? get m => mappings[key];

  static Region get current => db.settings.resolvedPreferredRegions.first;

  static bool get isJP => current == Region.jp;

  static get isCN => current == Region.cn;

  static get isEN => current == Region.na;

  V get l => maybeL ?? _default;

  V? get maybeL {
    for (final region in db.settings.resolvedPreferredRegions) {
      final v = mappings[key]?.ofRegion(region);
      if (v != null) return v;
    }
    return null;
  }

  List<V?> get all => [_m?.jp, _m?.cn, _m?.tw, _m?.na, _m?.kr];

  @override
  String toString() {
    return '$runtimeType($key)';
  }

  static MappingData get _md => db.gameData.mappingData;

  Transl.fromMapping(this.key, MappingBase<V> m, this._default)
      : _m = m,
        mappings = {key: m};

  static Transl<int, String> trait(int id) {
    if (!_md.trait.containsKey(id)) {
      id = _md.traitRedirect[id] ?? id;
    }
    return Transl(_md.trait, id, '$id');
  }

  static Transl<String, String> itemNames(String jp) =>
      Transl(_md.itemNames, jp, jp);

  static Transl<String, String> mcNames(String jp) =>
      Transl(_md.mcNames, jp, jp);

  static Transl<String, String> costumeNames(String jp) =>
      Transl(_md.costumeNames, jp, jp);

  static Transl<int, String> costumeDetail(int id) =>
      Transl(_md.costumeDetail, id, db.gameData.costumes[id]?.detail ?? '???');

  static Transl<String, String> cvNames(String jp) =>
      Transl(_md.cvNames, jp, jp);

  static Transl<String, String> illustratorNames(String jp) =>
      Transl(_md.illustratorNames, jp, jp);

  static Transl<String, String> ccNames(String jp) =>
      Transl(_md.ccNames, jp, jp);

  static Transl<String, String> svtNames(String jp) =>
      Transl(_md.svtNames, jp, jp);

  static Transl<String, String> ceNames(String jp) =>
      Transl(_md.ceNames, jp, jp);

  static Transl<String, String> eventNames(String jp) =>
      Transl(_md.eventNames, jp, jp);

  static Transl<String, String> warNames(String jp) =>
      Transl(_md.warNames, jp, jp);

  static Transl<String, String> questNames(String jp) =>
      Transl(_md.questNames, jp, jp);

  static Transl<String, String> spotNames(String jp) =>
      Transl(_md.spotNames, jp, jp);

  static Transl<String, String> entityNames(String jp) =>
      Transl(_md.entityNames, jp, jp);

  static Transl<String, String> tdTypes(String jp) =>
      Transl(_md.tdTypes, jp, jp);

  static Transl<String, String> bgmNames(String jp) =>
      Transl(_md.bgmNames, jp, jp);

  static Transl<String, String> summonNames(String jp) =>
      Transl(_md.summonNames, jp, jp);

  static Transl<String, String> charaNames(String cn) =>
      Transl(_md.charaNames, cn, cn);

  static Transl<String, String> buffNames(String jp) =>
      Transl(_md.buffNames, jp, jp);

  static Transl<String, String> buffDetail(String jp) =>
      Transl(_md.buffDetail, jp, jp);

  static Transl<String, String> funcPopuptext(String jp, [FuncType? type]) {
    if ({'', '-', 'なし', 'None', 'none'}.contains(jp) && type != null) {
      return Transl(_md.funcPopuptext, type.name, type.name);
    }
    return Transl(_md.funcPopuptext, jp, jp);
  }

  static Transl<String, String> skillNames(String jp) =>
      Transl(_md.skillNames, jp, jp);

  static Transl<String, String> skillDetail(String jp) =>
      Transl(_md.skillDetail, jp, jp);

  static Transl<String, String> tdNames(String jp) =>
      Transl(_md.tdNames, jp, jp);

  static Transl<String, String> tdRuby(String jp) => Transl(_md.tdRuby, jp, jp);

  static Transl<String, String> tdDetail(String jp) =>
      Transl(_md.tdDetail, jp, jp);

  static Transl<String, String> svtClass(SvtClass key) =>
      Transl(_md.enums.svtClass, key.name, key.name);
  static Transl<String, String> svtClassId(int id) {
    final key = kSvtClassIds[id]?.name ?? id.toString();
    return Transl(_md.enums.svtClass, key, key);
  }

  // enums
  static Transl<String, String> enums(Enum value,
      Map<String, MappingBase<String>> Function(EnumMapping enums) mapping) {
    return Transl(
        mapping(db.gameData.mappingData.enums), value.name, value.name);
  }

  static Transl<String, String> svtAttribute(Attribute key) =>
      Transl(_md.enums.attribute, key.name, key.name);
  static Transl<String, String> servantPolicy(ServantPolicy key) =>
      Transl(_md.enums.servantPolicy, key.name, key.name);
  static Transl<String, String> servantPersonality(ServantPersonality key) =>
      Transl(_md.enums.servantPersonality, key.name, key.name);
  static Transl<String, String> gender(Gender key) =>
      Transl(_md.enums.gender, key.name, key.name);
  static Transl<String, String> funcTargetType(FuncTargetType key) =>
      Transl(_md.enums.funcTargetType, key.name, key.name);
  static Transl<String, String> svtObtain(SvtObtain key) =>
      Transl(_md.enums.svtObtain, key.name, key.name);
  static Transl<String, String> ceObtain(CEObtain key) =>
      Transl(_md.enums.ceObtain, key.name, key.name);
}

@JsonSerializable(fieldRename: FieldRename.snake)
class MappingData {
  final Map<String, MappingBase<String>> itemNames;
  final Map<String, MappingBase<String>> mcNames;
  final Map<String, MappingBase<String>> costumeNames;
  final Map<String, MappingBase<String>> cvNames;
  final Map<String, MappingBase<String>> illustratorNames;
  final Map<String, MappingBase<String>> ccNames;
  final Map<String, MappingBase<String>> svtNames;
  final Map<String, MappingBase<String>> ceNames;
  final Map<String, MappingBase<String>> eventNames;
  final Map<String, MappingBase<String>> warNames;
  final Map<String, MappingBase<String>> questNames;
  final Map<String, MappingBase<String>> spotNames;
  final Map<String, MappingBase<String>> entityNames;
  final Map<String, MappingBase<String>> tdTypes;
  final Map<String, MappingBase<String>> bgmNames;
  final Map<String, MappingBase<String>> summonNames; //
  final Map<String, MappingBase<String>> charaNames; // key: cn
  final Map<String, MappingBase<String>> buffNames;
  final Map<String, MappingBase<String>> buffDetail;
  final Map<String, MappingBase<String>> funcPopuptext;
  final Map<String, MappingBase<String>> skillNames;
  final Map<String, MappingBase<String>> skillDetail;
  final Map<String, MappingBase<String>> tdNames;
  final Map<String, MappingBase<String>> tdRuby;
  final Map<String, MappingBase<String>> tdDetail;
  final Map<int, MappingBase<String>> trait; // key: trait id
  final Map<int, int> traitRedirect; // key: trait id
  final Map<int, MappingBase<String>> mcDetail; // key: mc id
  final Map<int, MappingBase<String>> costumeDetail; // costume collectionNo
  final Map<int, MappingDict<int>> skillState;
  final Map<int, MappingDict<int>> tdState;
  final MappingList<int> svtRelease;
  final MappingList<int> ceRelease;
  final MappingList<int> ccRelease;
  final EnumMapping enums;

  MappingData({
    this.itemNames = const {},
    this.mcNames = const {},
    this.costumeNames = const {},
    this.cvNames = const {},
    this.illustratorNames = const {},
    this.ccNames = const {},
    this.svtNames = const {},
    this.ceNames = const {},
    this.eventNames = const {},
    this.warNames = const {},
    this.questNames = const {},
    this.spotNames = const {},
    this.entityNames = const {},
    this.tdTypes = const {},
    this.bgmNames = const {},
    this.summonNames = const {},
    this.charaNames = const {},
    this.buffNames = const {},
    this.buffDetail = const {},
    this.funcPopuptext = const {},
    Map<String, MappingBase<String>>? skillNames,
    this.skillDetail = const {},
    this.tdNames = const {},
    this.tdRuby = const {},
    this.tdDetail = const {},
    this.trait = const {},
    this.traitRedirect = const {},
    this.mcDetail = const {},
    this.costumeDetail = const {},
    this.skillState = const {},
    this.tdState = const {},
    MappingList<int>? svtRelease,
    MappingList<int>? ceRelease,
    MappingList<int>? ccRelease,
    EnumMapping? enums,
  })  : skillNames = skillNames ?? {},
        svtRelease = svtRelease ?? MappingList(),
        ceRelease = ceRelease ?? MappingList(),
        ccRelease = ccRelease ?? MappingList(),
        enums = enums ?? EnumMapping() {
    _updateRegion(itemNames, Region.jp);
    _updateRegion(mcNames, Region.jp);
    _updateRegion(costumeNames, Region.jp);
    _updateRegion(cvNames, Region.jp);
    _updateRegion(illustratorNames, Region.jp);
    _updateRegion(ccNames, Region.jp);
    _updateRegion(svtNames, Region.jp);
    _updateRegion(ceNames, Region.jp);
    _updateRegion(eventNames, Region.jp);
    _updateRegion(warNames, Region.jp);
    _updateRegion(questNames, Region.jp);
    _updateRegion(spotNames, Region.jp);
    _updateRegion(entityNames, Region.jp);
    _updateRegion(tdTypes, Region.jp);
    _updateRegion(bgmNames, Region.jp);
    _updateRegion(summonNames, Region.cn);
    _updateRegion(charaNames, Region.cn);
    _updateRegion(buffNames, Region.jp);
    _updateRegion(buffDetail, Region.jp);
    _updateRegion(funcPopuptext, Region.jp);

    this.skillNames
      ..addAll(ceNames)
      ..addAll(ccNames);
    _updateRegion(this.skillNames, Region.jp);
    _updateRegion(skillDetail, Region.jp);
    _updateRegion(tdNames, Region.jp);
    _updateRegion(tdRuby, Region.jp);
    _updateRegion(tdDetail, Region.jp);
  }

  static void _updateRegion<T>(Map<T, MappingBase<T>> mapping, Region region) {
    mapping.forEach((key, value) {
      value.update(key, region, true);
    });
  }

  factory MappingData.fromJson(Map<String, dynamic> json) =>
      _$MappingDataFromJson(json);
}

/// Shortcut for [MappingBase]
class M {
  const M._();

  static T of<T>({T? jp, T? cn, T? tw, T? na, T? kr, T? k}) {
    return MappingBase(jp: jp, cn: cn, tw: tw, na: na, kr: kr).l ?? k!;
  }
}

T _fromJsonT<T>(Object? obj) {
  return obj as T;
}

@JsonSerializable(genericArgumentFactories: true)
class MappingBase<T> {
  @JsonKey(name: 'JP')
  T? jp;
  @JsonKey(name: 'CN')
  T? cn;
  @JsonKey(name: 'TW')
  T? tw;
  @JsonKey(name: 'NA')
  T? na;
  @JsonKey(name: 'KR')
  T? kr;

  List<T?> get values => [jp, cn, tw, na, kr];

  MappingBase({
    this.jp,
    this.cn,
    this.tw,
    this.na,
    this.kr,
  });

  T? get l {
    for (final region in db.settings.resolvedPreferredRegions) {
      final v = ofRegion(region);
      if (v != null) return v;
    }
    return null;
  }

  T? ofRegion([Region? region]) {
    region ??= Transl.current;
    switch (region) {
      case Region.jp:
        return jp;
      case Region.cn:
        return cn;
      case Region.tw:
        return tw;
      case Region.na:
        return na;
      case Region.kr:
        return kr;
    }
  }

  static T? of<T>({T? jp, T? cn, T? tw, T? na, T? kr}) {
    return MappingBase(jp: jp, cn: cn, tw: tw, na: na, kr: kr).l;
  }

  void update(T? value, Region region, [bool skipExist = false]) {
    switch (region) {
      case Region.jp:
        jp = skipExist ? jp ?? value : value;
        break;
      case Region.cn:
        cn = skipExist ? cn ?? value : value;
        break;
      case Region.tw:
        tw = skipExist ? tw ?? value : value;
        break;
      case Region.na:
        na = skipExist ? na ?? value : value;
        break;
      case Region.kr:
        kr = skipExist ? kr ?? value : value;
        break;
    }
  }

  factory MappingBase.fromJson(Map<String, dynamic> json) =>
      _$MappingBaseFromJson(json, _fromJsonT);

  MappingBase<T> copyWith({
    T? jp,
    T? cn,
    T? tw,
    T? na,
    T? kr,
  }) {
    return MappingBase<T>(
      jp: jp ?? this.jp,
      cn: cn ?? this.cn,
      tw: tw ?? this.tw,
      na: na ?? this.na,
      kr: kr ?? this.kr,
    );
  }
}

@JsonSerializable(genericArgumentFactories: true)
class MappingList<T> extends MappingBase<List<T>> {
  MappingList({
    List<T>? jp,
    List<T>? cn,
    List<T>? tw,
    List<T>? na,
    List<T>? kr,
  }) : super(jp: jp, cn: cn, tw: tw, na: na, kr: kr);

  factory MappingList.fromJson(Map<String, dynamic> json) =>
      _$MappingListFromJson(json, _fromJsonT);
}

@JsonSerializable(genericArgumentFactories: true)
class MappingDict<V> extends MappingBase<Map<int, V>> {
  MappingDict({
    Map<int, V>? jp,
    Map<int, V>? cn,
    Map<int, V>? tw,
    Map<int, V>? na,
    Map<int, V>? kr,
  }) : super(jp: jp, cn: cn, tw: tw, na: na, kr: kr);

  factory MappingDict.fromJson(Map<String, dynamic> json) =>
      _$MappingDictFromJson(json, _fromJsonT);
}

@JsonSerializable(fieldRename: FieldRename.snake)
class EnumMapping {
  final Map<String, MappingBase<String>> svtClass;
  final Map<String, MappingBase<String>> attribute;
  final Map<String, MappingBase<String>> servantPolicy;
  final Map<String, MappingBase<String>> servantPersonality;
  final Map<String, MappingBase<String>> gender;
  final Map<String, MappingBase<String>> funcTargetType;
  final Map<String, MappingBase<String>> svtObtain;
  final Map<String, MappingBase<String>> ceObtain;
  final Map<String, MappingBase<String>> missionProgressType;
  final Map<String, MappingBase<String>> missionType;
  final Map<String, MappingBase<String>> itemCategory;
  final Map<String, MappingBase<String>> customMissionType;
  final Map<String, MappingBase<String>> npDamageType;

  EnumMapping({
    this.svtClass = const {},
    this.attribute = const {},
    this.servantPolicy = const {},
    this.servantPersonality = const {},
    this.gender = const {},
    this.funcTargetType = const {},
    this.svtObtain = const {},
    this.ceObtain = const {},
    this.missionProgressType = const {},
    this.missionType = const {},
    this.itemCategory = const {},
    this.customMissionType = const {},
    this.npDamageType = const {},
  });

  factory EnumMapping.fromJson(Map<String, dynamic> json) =>
      _$EnumMappingFromJson(json);
}
