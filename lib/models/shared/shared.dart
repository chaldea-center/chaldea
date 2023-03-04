import 'package:json_annotation/json_annotation.dart' as json_annotation;

import 'package:chaldea/packages/logger.dart';

typedef _CastFunction<R> = R Function(Object?);

/// Override build-in [checkedCreate], catch error and return null instead.
/// Make sure the params [constructor] are nullable or have default value.
T $checkedCreate<T>(
  String className,
  Map map,
  T Function(
    S Function<S>(
      String,
      _CastFunction<S>, {
      Object? Function(Map, String)? readValue,
    }),
  )
      constructor, {
  Map<String, String> fieldKeyMap = const {},
}) {
  Q _checkedConvert<Q>(
    String key,
    _CastFunction<Q> convertFunction, {
    Object? Function(Map, String)? readValue,
  }) {
    try {
      return json_annotation.$checkedConvert<Q>(map, key, convertFunction, readValue: readValue);
    } catch (e, s) {
      logger.e('[$className.$key] checkedConvert error, return null', e, s);
      return null as Q;
    }
  }

  return json_annotation.$checkedNew(
    className,
    map,
    () => constructor(_checkedConvert),
    fieldKeyMap: fieldKeyMap,
  );
}

K? $enumDecodeNullable<K extends Enum, V>(
  Map<K, V> enumValues,
  Object? source, {
  Enum? unknownValue,
}) {
  return json_annotation.$enumDecodeNullable(
    enumValues,
    source,
    unknownValue: unknownValue ?? json_annotation.JsonKey.nullForUndefinedEnumValue,
  );
}

K decodeEnum<K, V>(Map<K, V> map, V value, K unknown) {
  for (final k in map.keys) {
    if (map[k] == value) return k;
  }
  return unknown;
}

void jsonMigrated(Map<String, dynamic> json, String key, String keyTemp) {
  json[key] = json[keyTemp] ?? json[key];
}
