import 'package:chaldea/app/battle/utils/buff_utils.dart';
import 'package:chaldea/models/gamedata/common.dart';
import 'package:chaldea/models/gamedata/const_data.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Test capBuffValue', () {
    const maxRate = 5000;
    final actionDetail = BuffActionDetail(
      limit: BuffLimit.normal,
      plusTypes: [],
      minusTypes: [],
      baseParam: 1500,
      baseValue: 25,
      isRec: false,
      plusAction: 0,
      maxRate: [maxRate],
    );

    test('value default to base param - base value', () {
      expect(capBuffValue(actionDetail, 0, maxRate), actionDetail.baseParam - actionDetail.baseValue);
    });

    test('value bound on normal', () {
      actionDetail.limit = BuffLimit.normal;
      expect(capBuffValue(actionDetail, -100000, maxRate), -actionDetail.baseValue);
      expect(capBuffValue(actionDetail, 100000, maxRate), maxRate);
    });

    test('value bound on limit', () {
      actionDetail.limit = BuffLimit.lower;
      expect(capBuffValue(actionDetail, -100000, maxRate), -actionDetail.baseValue);
      expect(capBuffValue(actionDetail, 100000, maxRate), 100000 + actionDetail.baseParam - actionDetail.baseValue);
    });

    test('value bound on upper', () {
      actionDetail.limit = BuffLimit.upper;
      expect(capBuffValue(actionDetail, -100000, maxRate), -100000 + actionDetail.baseParam - actionDetail.baseValue);
      expect(capBuffValue(actionDetail, 100000, maxRate), maxRate);
    });

    test('value bound on none', () {
      actionDetail.limit = BuffLimit.none;
      expect(capBuffValue(actionDetail, -100000, maxRate), -100000 + actionDetail.baseParam - actionDetail.baseValue);
      expect(capBuffValue(actionDetail, 100000, maxRate), 100000 + actionDetail.baseParam - actionDetail.baseValue);
    });
  });

  group('Test containsAnyTraits & containsAllTraits', () {
    test('default value', () {
      expect(containsAnyTraits([], []), isTrue);
      expect(containsAllTraits([], []), isTrue);
    });

    test('requires signed', () {
      final List<NiceTrait> myTraits = [
        NiceTrait(id: 100, negative: true),
        NiceTrait(id: 101),
        NiceTrait(id: 102),
      ];

      final List<NiceTrait> require100 = [NiceTrait(id: 100)];
      expect(containsAnyTraits(myTraits, require100), isFalse);
      expect(containsAllTraits(myTraits, require100), isFalse);

      final List<NiceTrait> require101 = [NiceTrait(id: 101)];
      expect(containsAnyTraits(myTraits, require101), isTrue);
      expect(containsAllTraits(myTraits, require101), isTrue);

      final List<NiceTrait> require100_101 = [NiceTrait(id: 100), NiceTrait(id: 101)];
      expect(containsAnyTraits(myTraits, require100_101), isTrue);
      expect(containsAllTraits(myTraits, require100_101), isFalse);

      final List<NiceTrait> requireNo103 = [NiceTrait(id: 103, negative: true)];
      expect(containsAnyTraits(myTraits, requireNo103), isTrue);
      expect(containsAllTraits(myTraits, requireNo103), isTrue);

      final List<NiceTrait> requireNo100 = [NiceTrait(id: 100, negative: true)];
      expect(containsAnyTraits(myTraits, requireNo100), isTrue);
      expect(containsAllTraits(myTraits, requireNo100), isTrue);

      final List<NiceTrait> require101No100 = [NiceTrait(id: 100, negative: true), NiceTrait(id: 101)];
      expect(containsAnyTraits(myTraits, require101No100), isTrue);
      expect(containsAllTraits(myTraits, require101No100), isTrue);

      final List<NiceTrait> require101No102 = [NiceTrait(id: 102, negative: true), NiceTrait(id: 101)];
      expect(containsAnyTraits(myTraits, require101No102), isTrue);
      expect(containsAllTraits(myTraits, require101No102), isFalse);

      final List<NiceTrait> require100_101_102 = [NiceTrait(id: 100), NiceTrait(id: 101), NiceTrait(id: 102)];
      expect(containsAnyTraits(myTraits, require100_101_102), isTrue);
      expect(containsAllTraits(myTraits, require100_101_102), isFalse);
    });
  });
}
