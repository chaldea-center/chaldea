/// combine all JsonSerializable classes in one library.
/// run in terminal [flutter packages pub run build_runner build/watch]
///
/// hints:
/// define default value of params in both @JsonKey() and default constructor,
/// non-constant value are set after default constructor(e.g. Test({a,this.b}):a=a).
library datatypes;

import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/modules/item/item_detail_page.dart' show ItemDetailPage;
import 'package:chaldea/modules/servant/servant_detail_page.dart'
    show ServantDetailPage;
import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart'
    hide $checkedNew, $checkedConvert, CheckedFromJsonException;
import 'package:json_annotation/src/allowed_keys_helpers.dart'; // ignore: implementation_imports

import '../config.dart' show db;
import '../constants.dart';
import '../custom_tile.dart' show ImageWithText;
import '../extensions.dart';
import '../git_tool.dart';
import '../localized/localized.dart';
import '../logger.dart';
import '../split_route/split_route.dart';
import '../utils.dart';

part 'bili_response.dart';

part 'checked_helpers.dart';

part 'cmd_code.dart';

part 'craft_essence.dart';

part 'datatypes.g.dart';

part 'event.dart';

part 'gamedata.dart';

part 'glpk.dart';

part 'item_statistic.dart';

part 'mystic_code.dart';

part 'quest.dart';

part 'servant.dart';

part 'summon.dart';

part 'user.dart';

part 'userdata.dart';
