import 'package:chaldea/models/gamedata/gamedata.dart';
import 'package:chaldea/utils/utils.dart';
import '../db.dart';
import '_helper.dart';

part '../../generated/models/gamedata/mappings.g.dart';

class Transl<K, V> {
  final Map<K, MappingBase<V>> mappings;
  final MappingBase<V>? _m;
  final K key;
  final V _default;

  Transl(this.mappings, this.key, this._default) : _m = key is String ? mappings[key.trim()] : mappings[key];
  static Transl<String, String> string(Map<String, MappingBase<String>> mappings, String key) {
    return Transl(mappings, key, key);
  }

  V get default_ => _default;

  V get jp => mappings[key]?.jp ?? _default;

  V get cn => mappings[key]?.cn ?? _default;

  V get tw => mappings[key]?.tw ?? _default;

  V get na => mappings[key]?.na ?? _default;

  V get kr => mappings[key]?.kr ?? _default;

  MappingBase<V>? get m => mappings[key];

  static List<Region> get preferRegions => db.settings.resolvedPreferredRegions;
  static Region get current => preferRegions.first;

  static bool get isJP => current == Region.jp;

  static get isCN => current == Region.cn;

  static get isEN => current == Region.na;

  bool get matched => mappings.containsKey(key);

  V get l => maybeL ?? _default;

  V? get maybeL {
    for (final region in db.settings.resolvedPreferredRegions) {
      final v = mappings[key]?.ofRegion(region);
      if (v != null) return v;
    }
    return null;
  }

  V of(Region? region) {
    return maybeOf(region) ?? _default;
  }

  V? maybeOf(Region? region) {
    return mappings[key]?.ofRegion(region);
  }

  List<V?> get all => [_m?.jp, _m?.cn, _m?.tw, _m?.na, _m?.kr];

  @override
  String toString() {
    return '$runtimeType($key)';
  }

  static MappingData get md => db.gameData.mappingData;

  Transl.fromMapping(this.key, MappingBase<V> m, this._default)
      : _m = m,
        mappings = {key: m};

  static Transl<int, String> trait(int id, {bool addSvtId = true, bool field = false}) {
    final eventTrait = md.eventTrait[id];
    String cvt(String v) => v.replaceAll('/', '\u2060/\u2060');
    if (eventTrait != null) {
      return Transl({id: eventTrait.convert((v, r) => v == null ? v : '"${cvt(v)}"')}, id, '$id');
    }
    final fieldTrait = md.fieldTrait[id];
    if (field && fieldTrait != null) {
      if (fieldTrait.warIds.isNotEmpty && fieldTrait.values.every((e) => e == null)) {
        final warId = fieldTrait.warIds.first;
        final war = db.gameData.wars[warId];
        if (war != null) {
          final lWarName = war.lName.m;
          if (((warId > 8000 && warId < 9900) || warId < 1000)) {
            return Transl({if (lWarName != null) id: lWarName.convert((v, region) => v?.setMaxLines(1))}, id,
                war.name.setMaxLines(1));
          }
        }
      }
      return Transl(md.fieldTrait, id, '$id');
    }

    final tm = md.trait[id];
    if (tm != null) {
      return Transl({id: tm.convert((v, r) => v == null ? v : cvt(v))}, id, '$id');
    } else {
      final svt = db.gameData.servantsById[id] ?? db.gameData.entities[id];
      if (svt != null) {
        var nameMapping = md.svtNames[svt.name] ?? md.entityNames[svt.name] ?? MappingBase(jp: svt.name);
        if (addSvtId) {
          nameMapping = nameMapping.convert((v, _) => v == null ? null : '$v($id)');
        }
        return Transl({id: nameMapping}, id, '$id');
      }
      return Transl(md.trait, id, '$id');
    }
  }

  static Transl<String, String> itemNames(String jp) => Transl(md.itemNames, jp, jp);

  static Transl<String, String> mcNames(String jp) => Transl(md.mcNames, jp, jp);
  static Transl<int, String> mcDetail(int id) => Transl(md.mcDetail, id, db.gameData.mysticCodes[id]?.detail ?? '???');

  static Transl<String, String> costumeNames(String jp) => Transl(md.costumeNames, jp, jp);

  static Transl<int, String> costumeDetail(int id) =>
      Transl(md.costumeDetail, id, db.gameData.costumes[id]?.detail ?? '???');

  static Transl<String, String> cvNames(String jp) => Transl(md.cvNames, jp, jp);

  static Transl<String, String> illustratorNames(String jp) => Transl(md.illustratorNames, jp, jp);

  static Transl<String, String> ccNames(String jp) => Transl(md.ccNames, jp, jp);

  static Transl<String, String> svtNames(String jp) {
    for (final names in [md.svtNames, md.entityNames, md.ceNames]) {
      if (names.containsKey(jp)) return Transl(names, jp, jp);
      String jp2 = jp.replaceAll('･', '・');
      if (names.containsKey(jp2)) return Transl(names, jp2, jp);
    }
    return Transl(md.svtNames, jp, jp);
  }

  static Transl<String, String> ceNames(String jp) => Transl(md.ceNames, jp, jp);

  static Transl<String, String> eventNames(String jp) {
    if (md.warNames.containsKey(jp)) return Transl(md.warNames, jp, jp);
    return Transl(md.eventNames, jp, jp);
  }

  static Transl<String, String> warNames(String jp) {
    if (md.eventNames.containsKey(jp)) return eventNames(jp);
    return Transl(md.warNames, jp, jp);
  }

  static Transl<String, String> questNames(String jp) => Transl(md.questNames, jp, jp);

  static Transl<String, String> spotNames(String jp) {
    if (md.warNames.containsKey(jp)) return Transl(md.warNames, jp, jp);
    return Transl(md.spotNames, jp, jp);
  }

  static Transl<String, String> entityNames(String jp) {
    return svtNames(jp);
  }

  static Transl<String, String> tdTypes(String jp) => Transl(md.tdTypes, jp, jp);

  static Transl<String, String> bgmNames(String jp) => Transl(md.bgmNames, jp, jp);

  static Transl<String, String> summonNames(String jp) {
    if (!md.summonNames.containsKey(jp)) {
      final jp2 = jp.replaceAll('･', '・');
      return Transl(md.summonNames, jp2, jp);
    }
    return Transl(md.summonNames, jp, jp);
  }

  static Transl<String, String> charaNames(String cn) => Transl(md.charaNames, cn, cn);

  static Transl<String, String> buffNames(String jp) => Transl(md.buffNames, jp, jp);

  static Transl<String, String> buffDetail(String jp) => Transl(md.buffDetail, jp, jp);

  static Transl<String, String> funcPopuptext(BaseFunction func) =>
      funcPopuptextBase(func.funcPopupText, func.funcType);

  static Transl<String, String> funcPopuptextBase(String jp, [FuncType? type]) {
    jp = NiceFunction.normFuncPopupText(jp);
    if (jp.isEmpty && type != null) {
      if (md.funcPopuptext.containsKey(type.name)) {
        return Transl(md.funcPopuptext, type.name, type.name);
      } else {
        return Transl.enums(type, (enums) => enums.funcType);
      }
    }
    if (!md.funcPopuptext.containsKey(jp)) {
      if (md.buffNames.containsKey(jp)) {
        return Transl(md.buffNames, jp, jp);
      } else if (md.enums.buffType.containsKey(jp)) {
        return Transl(md.enums.buffType, jp, jp);
      }
    }
    return Transl(md.funcPopuptext, jp, jp);
  }

  static Transl<String, String> skillNames(String jp) {
    jp = jp.trim();
    if (md.skillNames.containsKey(jp)) {
      return Transl(md.skillNames, jp, jp);
    } else if (md.ceNames.containsKey(jp)) {
      return ceNames(jp);
    } else {
      return ccNames(jp);
    }
  }

  static Transl<String, String> skillDetail(String jp) => Transl(md.skillDetail, jp, jp);

  static Transl<String, String> tdNames(String jp) => Transl(md.tdNames, jp, jp);

  static Transl<String, String> tdRuby(String jp) => Transl(md.tdRuby, jp, jp);

  static Transl<String, String> tdDetail(String jp) => Transl(md.tdDetail, jp, jp);

  static Transl<int, String> svtClassId(int id) {
    String? dftName = ConstData.classInfo[id]?.name;
    if (const ['', '?', '？'].contains(dftName)) {
      dftName = null;
    }
    return Transl(md.enums.svtClass, id, dftName ?? kSvtClassIds[id]?.name ?? id.toString());
  }

  static Transl<String, String> svtClassName(String jpName) {
    for (final clsId in kSvtClassIdsPlayableAll) {
      final clsInfo = ConstData.classInfo[clsId];
      if (clsInfo != null && clsInfo.name == jpName) {
        return Transl({jpName: md.enums.svtClass[clsId] ?? MappingBase()}, jpName, jpName);
      }
    }
    return Transl.string({}, jpName);
  }

  // enums
  static Transl<String, String> enums(
      Enum value, Map<String, MappingBase<String>> Function(EnumMapping enums) mapping) {
    return Transl(mapping(db.gameData.mappingData.enums), value.name, value.name);
  }

  static Transl<String, String> svtSubAttribute(ServantSubAttribute key) {
    String name = key.name2;
    return Transl(md.enums.attribute, name, name);
  }

  static Transl<String, String> servantPolicy(ServantPolicy key) => Transl(md.enums.servantPolicy, key.name, key.name);
  static Transl<String, String> servantPersonality(ServantPersonality key) =>
      Transl(md.enums.servantPersonality, key.name, key.name);
  static Transl<String, String> gender(Gender key) => Transl(md.enums.gender, key.name, key.name);
  static Transl<String, String> funcTargetType(FuncTargetType key) =>
      Transl(md.enums.funcTargetType, key.name, key.name);
  static Transl<String, String> svtObtain(SvtObtain key) => Transl(md.enums.svtObtain, key.name, key.name);
  static Transl<String, String> ceObtain(CEObtain key) => Transl(md.enums.ceObtain, key.name, key.name);
  static Transl<String, String> buffType(BuffType key) => Transl(md.enums.buffType, key.name, key.name);
  static Transl<String, String> funcType(FuncType key) => Transl(md.enums.funcType, key.name, key.name);

  static Transl<String, String> misc(String key) => Transl<String, String>(md.misc[r'$default'] ?? {}, key, key);

  static Transl<String, String> Function(String key) miscScope(String scope) =>
      (key) => Transl<String, String>(md.misc[scope] ?? {}, key, key);

  static String misc2(String scope, String key) => Transl<String, String>(md.misc[scope] ?? {}, key, key).l;

  static final _SpecialTransl special = _SpecialTransl();
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
  final Map<String, MappingBase<String>> voiceLineNames;
  final Map<int, MappingBase<String>> trait; // key: trait id
  // final Map<int, int> traitRedirect; // key: trait id
  final Map<int, EventTraitMapping> eventTrait; // key: trait id
  final Map<int, FieldTraitMapping> fieldTrait; // trait: warId[]
  final Map<int, MappingBase<String>> mcDetail; // key: mc id
  final Map<int, MappingBase<String>> costumeDetail; // costume collectionNo
  final Map<int, MappingDict<int>> skillPriority; // <svtId, <skillId, priority>>
  final Map<int, MappingDict<int>> tdPriority; // <svtId, <tdId, priority>>
  final MappingList<int> entityRelease;
  final MappingList<int> ccRelease;
  final MappingList<int> mcRelease;
  final MappingList<int> warRelease;
  final Map<int, MappingBase<int>> questRelease; // only svt related quests
  final EnumMapping enums;
  final Map<String, Map<String, MappingBase<String>>> misc;

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
    this.skillNames = const {},
    this.skillDetail = const {},
    this.tdNames = const {},
    this.tdRuby = const {},
    this.tdDetail = const {},
    this.voiceLineNames = const {},
    this.trait = const {},
    this.eventTrait = const {},
    this.fieldTrait = const {},
    this.mcDetail = const {},
    this.costumeDetail = const {},
    this.skillPriority = const {},
    this.tdPriority = const {},
    MappingList<int>? entityRelease,
    MappingList<int>? ccRelease,
    MappingList<int>? mcRelease,
    MappingList<int>? warRelease,
    this.questRelease = const {},
    EnumMapping? enums,
    this.misc = const {},
  })  : entityRelease = entityRelease ?? MappingList(),
        ccRelease = ccRelease ?? MappingList(),
        mcRelease = mcRelease ?? MappingList(),
        warRelease = warRelease ?? MappingList(),
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
    _updateRegion(charaNames, Region.cn);
    _updateRegion(buffDetail, Region.jp);
    _updateRegion(skillNames, Region.jp);
    _updateRegion(skillDetail, Region.jp);
    _updateRegion(tdNames, Region.jp);
    _updateRegion(tdRuby, Region.jp);
    _updateRegion(tdDetail, Region.jp);
    _updateRegion(voiceLineNames, Region.jp);
    final excludes = {...BuffType.values.map((e) => e.name), ...FuncType.values.map((e) => e.name)};
    _updateRegion(buffNames, Region.jp, excludes: excludes);
    _updateRegion(funcPopuptext, Region.jp, excludes: excludes);

    final baseSummonsName = Map.of(summonNames);
    for (final (nameJp, names) in baseSummonsName.items) {
      final match = RegExp(r'ピックアップ(\d+)召喚$').firstMatch(nameJp);
      if (match != null) {
        final idx = match.group(1)!;
        String jp2 = nameJp.replaceAll('ピックアップ$idx召喚', 'ピックアップ召喚');
        if (baseSummonsName.containsKey(jp2)) continue;
        summonNames[jp2] = names
            .convert((v, region) => v != null && v.endsWith(idx) ? v.substring(0, v.length - idx.length).trim() : null);
      }
    }
    _updateRegion(summonNames, Region.jp);
  }

  static void _updateRegion<T>(Map<T, MappingBase<T>> mapping, Region region, {Set<T>? excludes}) {
    mapping.forEach((key, value) {
      if (excludes?.contains(key) == true) return;
      value.update(key, region, true);
    });
  }

  factory MappingData.fromJson(Map<String, dynamic> json) {
    // _addStrMappingValues(json, 'buff_names', {
    // });
    return _$MappingDataFromJson(json);
  }

  Map<String, dynamic> toJson() => _$MappingDataToJson(this);
}

/// Shortcut for [MappingBase]
class M {
  const M._();

  static T of<T>({T? jp, T? cn, T? tw, T? na, T? kr, T? k}) {
    return MappingBase(jp: jp, cn: cn, tw: tw, na: na, kr: kr).l ?? k!;
  }
}

T _fromJsonT<T>(Object? obj) => obj as T;

Object? _toJsonT<T>(T value) => value;

// ignore: unused_element
void _addStrMappingValues(Map<String, dynamic> json, String field, Map<String, Map<String, String?>> values) {
  print('patching $field with ${values.length} values, ${json.keys.firstOrNull}, ${values.keys.firstOrNull}');
  json[field] = {
    ...?(json[field] as Map?),
    ...values,
  };
}

@JsonSerializable(genericArgumentFactories: true, createToJson: true, includeIfNull: false)
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

  Iterable<(Region, T?)> get indexed sync* {
    yield (Region.jp, jp);
    yield (Region.cn, cn);
    yield (Region.tw, tw);
    yield (Region.na, na);
    yield (Region.kr, kr);
  }

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

  T? lOf(Region region) {
    final v = ofRegion(region);
    if (v != null) return v;
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

  MappingBase<T> merge(MappingBase<T>? other) {
    if (other == null) return this;
    if (other.values.every((e) => e == null)) return this;
    return MappingBase(
      jp: other.jp ?? jp,
      cn: other.cn ?? cn,
      tw: other.tw ?? tw,
      na: other.na ?? na,
      kr: other.kr ?? kr,
    );
  }

  factory MappingBase.fromJson(Map<String, dynamic> json) => _$MappingBaseFromJson(json, _fromJsonT);

  Map<String, dynamic> toJson() => _$MappingBaseToJson(this, _toJsonT);

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

  MappingBase<S> convert<S>(S? Function(T? v, Region region) cvt) {
    return MappingBase(
      jp: cvt(jp, Region.jp),
      cn: cvt(cn, Region.cn),
      tw: cvt(tw, Region.tw),
      na: cvt(na, Region.na),
      kr: cvt(kr, Region.kr),
    );
  }

  @override
  String toString() {
    return 'MappingBase<$T>(jp: $jp, cn: $cn, tw: $tw, na: $na, kr: $kr)';
  }
}

@JsonSerializable(genericArgumentFactories: true)
class MappingList<T> extends MappingBase<List<T>> {
  MappingList({
    super.jp,
    super.cn,
    super.tw,
    super.na,
    super.kr,
  });

  factory MappingList.fromJson(Map<String, dynamic> json) => _$MappingListFromJson(json, _fromJsonT);

  @override
  Map<String, dynamic> toJson() => _$MappingListToJson(this, _toJsonT);
}

@JsonSerializable(genericArgumentFactories: true)
class MappingDict<V> extends MappingBase<Map<int, V>> {
  MappingDict({
    super.jp,
    super.cn,
    super.tw,
    super.na,
    super.kr,
  });

  factory MappingDict.fromJson(Map<String, dynamic> json) => _$MappingDictFromJson(json, _fromJsonT);

  @override
  Map<String, dynamic> toJson() => _$MappingDictToJson(this, _toJsonT);
}

@JsonSerializable()
class EventTraitMapping extends MappingBase<String> {
  int? eventId;
  int? relatedTrait; // the similar normal trait, not used yet.

  EventTraitMapping({
    this.eventId,
    this.relatedTrait,
    super.jp,
    super.cn,
    super.tw,
    super.na,
    super.kr,
  });

  factory EventTraitMapping.fromJson(Map<String, dynamic> json) => _$EventTraitMappingFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$EventTraitMappingToJson(this);
}

@JsonSerializable()
class FieldTraitMapping extends MappingBase<String> {
  List<int> warIds;

  FieldTraitMapping({
    this.warIds = const [],
    super.jp,
    super.cn,
    super.tw,
    super.na,
    super.kr,
  });

  factory FieldTraitMapping.fromJson(Map<String, dynamic> json) => _$FieldTraitMappingFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$FieldTraitMappingToJson(this);
}

@JsonSerializable()
class SvtClassMapping extends MappingBase<String> {
  /// name of [SvtClass]
  String? name;

  SvtClassMapping({
    this.name,
    super.jp,
    super.cn,
    super.tw,
    super.na,
    super.kr,
  });

  factory SvtClassMapping.fromJson(Map<String, dynamic> json) => _$SvtClassMappingFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$SvtClassMappingToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake)
class EnumMapping {
  final Map<int, SvtClassMapping> svtClass;
  final Map<String, MappingBase<String>> attribute;
  final Map<String, MappingBase<String>> servantPolicy;
  final Map<String, MappingBase<String>> servantPersonality;
  final Map<String, MappingBase<String>> gender;
  final Map<String, MappingBase<String>> funcTargetType;
  final Map<String, MappingBase<String>> svtObtain;
  final Map<String, MappingBase<String>> ceObtain;
  final Map<String, MappingBase<String>> missionProgressType;
  final Map<String, MappingBase<String>> missionType;
  final Map<String, MappingBase<String>> tdEffectFlag;
  final Map<String, MappingBase<String>> eventType;
  final Map<String, MappingBase<String>> combineAdjustTarget;
  final Map<String, MappingBase<String>> itemCategory;
  final Map<String, MappingBase<String>> customMissionType;
  final Map<String, MappingBase<String>> effectType;
  final Map<String, MappingBase<String>> funcType;
  final Map<String, MappingBase<String>> buffType;
  final Map<String, MappingBase<String>> svtVoiceType;
  final Map<String, MappingBase<String>> svtType;
  final Map<String, MappingBase<String>> summonType;
  final Map<String, MappingBase<String>> eventWorkType;
  final Map<String, MappingBase<String>> shopType;
  final Map<String, MappingBase<String>> purchaseType;
  final Map<String, MappingBase<String>> restrictionType;
  // ai
  final Map<int, MappingBase<String>> aiActNum;
  final Map<int, MappingBase<String>> aiTiming;
  final Map<String, MappingBase<String>> aiCond;
  final Map<String, MappingBase<String>> aiActType;
  final Map<String, MappingBase<String>> aiActTarget;

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
    this.tdEffectFlag = const {},
    this.eventType = const {},
    this.combineAdjustTarget = const {},
    this.itemCategory = const {},
    this.customMissionType = const {},
    this.effectType = const {},
    this.funcType = const {},
    this.buffType = const {},
    this.svtVoiceType = const {},
    this.svtType = const {},
    this.summonType = const {},
    this.eventWorkType = const {},
    this.shopType = const {},
    this.purchaseType = const {},
    this.restrictionType = const {},
    this.aiActNum = const {},
    this.aiTiming = const {},
    this.aiCond = const {},
    this.aiActType = const {},
    this.aiActTarget = const {},
  });

  factory EnumMapping.fromJson(Map<String, dynamic> json) {
    // _addStrMappingValues(json, 'buff_type', {
    // });
    return _$EnumMappingFromJson(json);
  }

  Map<String, dynamic> toJson() => _$EnumMappingToJson(this);
}

class _SpecialTransl {
  String not() => M.of(
        jp: null,
        cn: '非',
        tw: null,
        na: 'Not',
        kr: null,
      );

  String funcValChance(String v) => M.of(
        jp: '$v確率',
        cn: '$v概率',
        tw: '$v概率',
        na: '$v Chance',
        kr: '$v 확률',
      );
  String funcValActChance(String v) => M.of(
        jp: '$v確率発動',
        cn: '$v概率发动',
        tw: '$v概率發動',
        na: '$v Act Chance',
        kr: null,
      );
  String funcValWeight(String v) => M.of(
        jp: null,
        cn: '$v权重',
        tw: '$v權重',
        na: '$v Weight',
        kr: '$v 무게',
      );
  String funcValCountTimes(Object count) => M.of(
        jp: '$count回',
        cn: '$count次',
        tw: '$count次',
        na: '$count Times',
        kr: '$count 회',
      );
  String funcValTurns(Object turn) => M.of(
        jp: '$turnターン',
        cn: '$turn回合',
        tw: '$turn回合',
        na: '$turn Turns',
        kr: '$turn 턴',
      );
  String get funcTraitRemoval => M.of(
        jp: '解除: ',
        cn: '解除: ',
        tw: '解除: ',
        na: 'Remove: ',
        kr: '해제: ',
      );
  String funcTraitPerBuff({
    // only one of them can be true
    bool isSelf = false,
    bool isOpp = false,
    bool isField = false,
  }) {
    String? target;
    if (isSelf) {
      target = self;
    } else if (isOpp) {
      target = opposite;
    } else if (isField) {
      target = field;
    }
    return M.of(
      jp: '【${target ?? ""}〔{0}〕状態の数によって】',
      cn: '【根据${target ?? ""}〔{0}〕状态的数量】',
      tw: "【根據${target ?? ""}〔{0}〕狀態的數量】",
      na: ' (Based on the amount of [{0}]${target == null ? "" : " on $target"})',
      kr: null,
    );
  }

  String get self => M.of(jp: '自身', cn: '自身', tw: '自身', na: 'self', kr: '자신');
  String get opposite => M.of(jp: '対象', cn: '对方', tw: '對方', na: 'opposite', kr: '대상');
  String get field => M.of(jp: 'フィールド', cn: '场地', tw: '場地', na: 'Field', kr: null);

  String get funcTraitOnField => M.of(
        jp: '〔{0}〕のあるフィールドにおいてのみ',
        cn: '仅在〔{0}〕场地上时',
        tw: '僅在〔{0}〕場地上時',
        na: 'When on [{0}] field',
        kr: '〔{0}〕 있는 필드에서만',
      );
  String get actorOnField => M.of(
        jp: '〔{0}〕がフィールドにいる間',
        cn: '仅当〔{0}〕在场时',
        tw: '僅在〔{0}〕在場時',
        na: 'When [{0}] is on the field',
        kr: null,
      );
  String get funcTargetVals => M.of(
        jp: '目標特性: ',
        cn: '目标特性: ',
        tw: '目標特性: ',
        na: 'Target Trait: ',
        kr: '목표의 특성: ',
      );
  String get buffCheckSelf => M.of(
        jp: '自身特性: ',
        cn: '自身特性: ',
        tw: '自身特性: ',
        na: 'Self Trait: ',
        kr: '자신의 특성: ',
      );
  String get buffCheckOpposite => M.of(
        jp: 'バフ目標: ',
        cn: 'Buff目标: ',
        tw: 'Buff目標: ',
        na: 'Buff Target: ',
        kr: '버프 목표: ',
      );
  String get buffOwnerIndiv => M.of(
        jp: '{0}を所持で有効',
        cn: '拥有{0}时生效',
        tw: null,
        na: 'Active when having {0}',
        kr: null,
      );
  String get funcEventOnly => M.of(
        jp: '『{0}』イベント期間限定',
        cn: '『{0}』活动期间限定',
        tw: '『{0}』活動限定',
        na: '『{0}』Event Only',
        kr: '『{0}』 이벤트 기간한정',
      );
  String get funcAbsorbFrom => M.of(
        jp: '(ターゲットごとに)',
        cn: '(每个目标)',
        tw: "(每個目標)",
        na: '(per target)',
        kr: '(목표당)',
      );
  String get funcSupportOnly => M.of(
        jp: '[サポート時]',
        cn: '[助战时]',
        tw: "[支援时]",
        na: '[Support Only]',
        kr: '[서포트 시는]',
      );
  String get variousPositiveBuffs => M.of(
        jp: "さまざまな強化状態",
        cn: '各种强化状态',
        tw: "各種強化狀態",
        na: 'Various Positive Buffs',
        kr: null,
      );
  String get succeed => M.of(
        jp: "成功",
        cn: '成功',
        tw: '成功',
        na: 'succeed',
        kr: null,
      );
  String get fail => M.of(
        jp: "失敗",
        cn: '失败',
        tw: '失敗',
        na: 'fail',
        kr: null,
      );
}
