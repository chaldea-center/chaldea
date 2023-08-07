import 'package:flutter_test/flutter_test.dart';

import 'package:chaldea/app/battle/utils/buff_utils.dart';
import 'package:chaldea/models/gamedata/const_data.dart';

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
}
