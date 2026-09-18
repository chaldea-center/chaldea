import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/models/models.dart';

/// Extra filter data shared by faker pages that list/select user servants
/// (svt mode). Extracted from the former private `_UserSvtFilterData` in
/// select_svt.dart so storage/management pages can reuse the same state.
class UserServantFilterData with FilterDataMixin {
  final svtType = FilterGroupData<SvtType>();
  final availableCombines = FilterGroupData<UserSvtCombineType>();
  int eventId = 0;

  @override
  List<FilterGroupData> get groups => [svtType, availableCombines];

  @override
  void reset() {
    super.reset();
    eventId = 0;
  }
}

enum UserSvtCombineType {
  level,
  fou3,
  ascension,
  grail,
  skill,
  append2,
  appendAny,
  bondLimit,
  bondLessThan10,
  ccUnlock;

  String get dispName {
    return switch (this) {
      .level => 'Lv',
      .fou3 => 'Fou3',
      .ascension => S.current.ascension_short,
      .grail => S.current.grail,
      .skill => S.current.skill,
      .append2 => '${S.current.append_skill_short}2',
      .appendAny => S.current.append_skill_short,
      .bondLimit => S.current.bond,
      .bondLessThan10 => '${S.current.bond}＜10',
      .ccUnlock => S.current.command_code_short,
    };
  }
}

/// Extra filter data shared by faker pages that list/select user craft
/// essences (equip mode). Extracted from the former private
/// `_UserSvtFilterData` in select_svt_equip.dart.
class UserSvtEquipFilterData with FilterDataMixin {
  final maxLimitBreak = FilterGroupData<bool>();
  final locked = FilterGroupData<bool>(options: {true});
  int eventId = 0;

  @override
  List<FilterGroupData> get groups => [maxLimitBreak, locked];

  @override
  void reset() {
    super.reset();
    eventId = 0;
  }
}
