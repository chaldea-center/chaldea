/// combine all JsonSerializable classes in one library.
/// run in terminal [flutter packages pub run build_runner watch/build]
library datatypes;

import 'package:chaldea/components/constants.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:meta/meta.dart';

/// data-type classes, part of [datatypes].
part 'model.dart';
part 'servant.dart';

/// generated file by JsonSerializableGenerator
part 'datatypes.g.dart';
