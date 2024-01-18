part of 'common.dart';

extension RegionX on Region {
  String get upper => name.toUpperCase();

  static Region? tryParse(String s) {
    return _$RegionEnumMap.entries.firstWhereOrNull((e) => e.value.toLowerCase() == s.toLowerCase())?.key;
  }

  String get localName {
    switch (this) {
      case Region.jp:
        return S.current.region_jp;
      case Region.cn:
        return S.current.region_cn;
      case Region.tw:
        return S.current.region_tw;
      case Region.na:
        return S.current.region_na;
      case Region.kr:
        return S.current.region_kr;
    }
  }
}

class RegionConverter extends JsonConverter<Region, String> {
  const RegionConverter();
  @override
  Region fromJson(String value) {
    for (final k in _$RegionEnumMap.keys) {
      final v = _$RegionEnumMap[k]!;
      if (v == value || v == value.toLowerCase()) {
        return k;
      }
    }
    return Region.jp;
  }

  @override
  String toJson(Region obj) => _$RegionEnumMap[obj] ?? obj.name;
}

class CondTypeConverter extends JsonConverter<CondType, String> {
  const CondTypeConverter();
  @override
  CondType fromJson(String? value) => decodeEnum(_$CondTypeEnumMap, value ?? "", CondType.none);
  @override
  String toJson(CondType obj) => _$CondTypeEnumMap[obj] ?? obj.name;
}

// utils
final kTraitIdMapping = <int, Trait>{for (final v in Trait.values) v.id: v};
