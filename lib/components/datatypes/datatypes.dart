/// combine all JsonSerializable classes in one library.
/// run in terminal [flutter packages pub run build_runner build/watch]
///
/// hints:
/// define default value of params in both @JsonKey() and default constructor,
/// non-constant value are set after default constructor(e.g. Test({a,this.b}):a=a).
library datatypes;

import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:meta/meta.dart';

import '../config.dart' show db;
import '../constants.dart';
import '../logger.dart';

part 'cmd_code.dart';

part 'craft_essential.dart';

part 'datatypes.g.dart';

part 'event.dart';

part 'gamedata.dart';

part 'glpk.dart';

part 'item_statistic.dart';

part 'quest.dart';

part 'serializable_checker.dart';

part 'servant.dart';

part 'user.dart';

part 'userdata.dart';
