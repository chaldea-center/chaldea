/// combine all JsonSerializable classes in one library.
/// run in terminal [flutter packages pub run build_runner build/watch]
///
/// hints:
/// define default value of params in both @JsonKey() and default constructor,
/// non-constant value are set after default constructor(e.g. Test({a,this.b}):a=a).
library datatypes;

import 'package:chaldea/components/constants.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:meta/meta.dart';

/// data-type classes, part of [datatypes].
part 'model.dart';

part 'gamedata.dart';
part 'userdata.dart';

/// generated file by JsonSerializableGenerator
part 'datatypes.g.dart';
