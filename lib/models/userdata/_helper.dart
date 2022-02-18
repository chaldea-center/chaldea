import 'package:chaldea/packages/logger.dart';
import 'package:json_annotation/json_annotation.dart' hide $checkedCreate;

export 'package:json_annotation/json_annotation.dart' hide $checkedCreate;

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
      return $checkedConvert<Q>(map, key, convertFunction,
          readValue: readValue);
    } catch (e, s) {
      logger.e('checkedConvert error, return null', e, s);
      return null as Q;
    }
  }

  return $checkedNew(
    className,
    map,
    () => constructor(_checkedConvert),
    fieldKeyMap: fieldKeyMap,
  );
}
