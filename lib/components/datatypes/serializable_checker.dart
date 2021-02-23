//@dart=2.9
part of datatypes;

/// Replace the [$checkedNew] and [$checkedConvert] functions in json_annotation,
/// called in generated code if class is annotated [@JsonSerializable(checked=true)]
///
/// This checker:
///   return null if decode(new/convert) failed.
///   e.g. data structure changed when app upgrades
/// Default checker of json_serializable:
///   raise [CheckedFromJsonException] if decode failed.
///
/// Hints:
///   * set @JsonSerializable(checked=true) of userdata related classes,
///     it's important to retain more data when upgrade.
///   * free to apply check=true to game data related classes.
///   * update the function code if package json_annotation updated.
///     currently modified from json_annotation-3.0.1
T $checkedNew2<T>(String className, Map map, T Function() constructor,
    {Map<String, String> fieldKeyMap}) {
  fieldKeyMap ??= const {};
  try {
    // check non-null first, otherwise, every $checkedConvert calling
    // in constructor will throw error "[] called on null"
    if (map == null) {
      throw ArgumentError.notNull('map');
    }
    return constructor();
  } catch (error, stack) {
    String key;
    if (error is ArgumentError) {
      key = fieldKeyMap[error.name] ?? error.name;
    } else if (error is MissingRequiredKeysException) {
      key = error.missingKeys.first;
    } else if (error is DisallowedNullValueException) {
      key = error.keysWithNullValues.first;
    }
    logger.e(
        <String>[
          '============= Exception when decode $className =============',
          if (className != null) 'Could not create `$className`.',
          if (key != null) 'There is a problem with "$key".',
        ].join('\n'),
        error,
        stack);
    return null;
  }
}

T $checkedConvert2<T>(Map map, String key, T Function(Object) castFunc) {
  try {
    return castFunc(map[key]);
  } on CheckedFromJsonException {
    rethrow;
  } catch (error, stack) {
    print(<String>[
      '============= Exception when convert $key =============',
      'There is a problem with "$key".',
      '$error',
      '----- stack -----\n$stack\n--------------'
    ].join('\n'));
    return null;
  }
}
