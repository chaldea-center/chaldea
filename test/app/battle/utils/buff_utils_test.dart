import 'package:flutter_test/flutter_test.dart';

import 'package:chaldea/app/battle/utils/buff_utils.dart';
import 'package:chaldea/models/gamedata/common.dart';
import 'package:chaldea/models/gamedata/const_data.dart';

void main() {
  group('Test capBuffValue', () {
    const maxRate = 5000;
    final actionDetail = BuffActionInfo(
      limit: BuffLimit.normal,
      plusTypes: [],
      minusTypes: [],
      baseParam: 1500,
      baseValue: 25,
      isRec: false,
      plusAction: BuffAction.none,
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
      expect(capBuffValue(actionDetail, 100000, null), 100000 + actionDetail.baseParam - actionDetail.baseValue);
    });

    test('value bound on none', () {
      actionDetail.limit = BuffLimit.none;
      expect(capBuffValue(actionDetail, -100000, maxRate), -100000 + actionDetail.baseParam - actionDetail.baseValue);
      expect(capBuffValue(actionDetail, 100000, maxRate), 100000 + actionDetail.baseParam - actionDetail.baseValue);
    });
  });

  group('checkSignedIndividualities2', () {
    test('partialMatch positive only', () {
      final requiredTraits = [NiceTrait(id: 300), NiceTrait(id: 100)];

      final myTraits1 = [NiceTrait(id: 300), NiceTrait(id: 100)];
      final result1 = checkSignedIndividualities2(
        myTraits: myTraits1,
        requiredTraits: requiredTraits,
        positiveMatchFunc: partialMatch,
        negativeMatchFunc: partialMatch,
      );
      expect(result1, true);

      final myTraits2 = [NiceTrait(id: 100), NiceTrait(id: 200)];
      final result2 = checkSignedIndividualities2(
        myTraits: myTraits2,
        requiredTraits: requiredTraits,
        positiveMatchFunc: partialMatch,
        negativeMatchFunc: partialMatch,
      );
      expect(result2, true);

      final myTraits3 = [NiceTrait(id: 300), NiceTrait(id: 200)];
      final result3 = checkSignedIndividualities2(
        myTraits: myTraits3,
        requiredTraits: requiredTraits,
        positiveMatchFunc: partialMatch,
        negativeMatchFunc: partialMatch,
      );
      expect(result3, true);

      final myTraits4 = [NiceTrait(id: 400), NiceTrait(id: 200)];
      final result4 = checkSignedIndividualities2(
        myTraits: myTraits4,
        requiredTraits: requiredTraits,
        positiveMatchFunc: partialMatch,
        negativeMatchFunc: partialMatch,
      );
      expect(result4, false);
    });

    test('partialMatch mix', () {
      // OR on positive, AND on negative
      final requiredTraits = [
        NiceTrait(id: 300),
        NiceTrait(id: 100),
        NiceTrait(id: 200, negative: true),
        NiceTrait(id: 400, negative: true),
      ];

      final myTraits1 = [NiceTrait(id: 300), NiceTrait(id: 100)];
      final result1 = checkSignedIndividualities2(
        myTraits: myTraits1,
        requiredTraits: requiredTraits,
        positiveMatchFunc: partialMatch,
        negativeMatchFunc: partialMatch,
      );
      expect(result1, true);

      final myTraits2 = [NiceTrait(id: 100), NiceTrait(id: 200)];
      final result2 = checkSignedIndividualities2(
        myTraits: myTraits2,
        requiredTraits: requiredTraits,
        positiveMatchFunc: partialMatch,
        negativeMatchFunc: partialMatch,
      );
      expect(result2, false);

      final myTraits3 = [NiceTrait(id: 300), NiceTrait(id: 400)];
      final result3 = checkSignedIndividualities2(
        myTraits: myTraits3,
        requiredTraits: requiredTraits,
        positiveMatchFunc: partialMatch,
        negativeMatchFunc: partialMatch,
      );
      expect(result3, false);

      final myTraits4 = [NiceTrait(id: 500), NiceTrait(id: 600)];
      final result4 = checkSignedIndividualities2(
        myTraits: myTraits4,
        requiredTraits: requiredTraits,
        positiveMatchFunc: partialMatch,
        negativeMatchFunc: partialMatch,
      );
      expect(result4, false);
    });

    test('allMatch positive only', () {
      final requiredTraits = [NiceTrait(id: 300), NiceTrait(id: 100)];

      final myTraits1 = [NiceTrait(id: 300), NiceTrait(id: 100), NiceTrait(id: 200)];
      final result1 = checkSignedIndividualities2(
        myTraits: myTraits1,
        requiredTraits: requiredTraits,
        positiveMatchFunc: allMatch,
        negativeMatchFunc: allMatch,
      );
      expect(result1, true);

      final myTraits2 = [NiceTrait(id: 100), NiceTrait(id: 200)];
      final result2 = checkSignedIndividualities2(
        myTraits: myTraits2,
        requiredTraits: requiredTraits,
        positiveMatchFunc: allMatch,
        negativeMatchFunc: allMatch,
      );
      expect(result2, false);

      final myTraits3 = [NiceTrait(id: 300), NiceTrait(id: 200)];
      final result3 = checkSignedIndividualities2(
        myTraits: myTraits3,
        requiredTraits: requiredTraits,
        positiveMatchFunc: allMatch,
        negativeMatchFunc: allMatch,
      );
      expect(result3, false);

      final myTraits4 = [NiceTrait(id: 400), NiceTrait(id: 200)];
      final result4 = checkSignedIndividualities2(
        myTraits: myTraits4,
        requiredTraits: requiredTraits,
        positiveMatchFunc: allMatch,
        negativeMatchFunc: allMatch,
      );
      expect(result4, false);
    });

    test('allMatch mix', () {
      // AND on positive, OR on negative
      final requiredTraits = [
        NiceTrait(id: 300),
        NiceTrait(id: 100),
        NiceTrait(id: 200, negative: true),
        NiceTrait(id: 400, negative: true),
      ];

      final myTraits1 = [NiceTrait(id: 300), NiceTrait(id: 100), NiceTrait(id: 600)];
      final result1 = checkSignedIndividualities2(
        myTraits: myTraits1,
        requiredTraits: requiredTraits,
        positiveMatchFunc: allMatch,
        negativeMatchFunc: allMatch,
      );
      expect(result1, true);

      final myTraits2 = [NiceTrait(id: 100), NiceTrait(id: 200)];
      final result2 = checkSignedIndividualities2(
        myTraits: myTraits2,
        requiredTraits: requiredTraits,
        positiveMatchFunc: allMatch,
        negativeMatchFunc: allMatch,
      );
      expect(result2, false);

      final myTraits3 = [NiceTrait(id: 100), NiceTrait(id: 300), NiceTrait(id: 400)];
      final result3 = checkSignedIndividualities2(
        myTraits: myTraits3,
        requiredTraits: requiredTraits,
        positiveMatchFunc: allMatch,
        negativeMatchFunc: allMatch,
      );
      expect(result3, true);

      final myTraits4 = [NiceTrait(id: 500), NiceTrait(id: 600)];
      final result4 = checkSignedIndividualities2(
        myTraits: myTraits4,
        requiredTraits: requiredTraits,
        positiveMatchFunc: allMatch,
        negativeMatchFunc: allMatch,
      );
      expect(result4, false);
    });
  });

  group('checkSignedIndividualitiesPartialMatch', () {
    test('partialMatch', () {
      // AND on positive, OR on negative
      final requiredTraits = [
        NiceTrait(id: 300),
        NiceTrait(id: 100),
        NiceTrait(id: 200, negative: true),
        NiceTrait(id: 400, negative: true),
      ];

      final myTraits1 = [NiceTrait(id: 300), NiceTrait(id: 100), NiceTrait(id: 600)];
      final result1 = checkSignedIndividualitiesPartialMatch(
        myTraits: myTraits1,
        requiredTraits: requiredTraits,
        positiveMatchFunc: partialMatch,
        negativeMatchFunc: partialMatch,
      );
      expect(result1, true);

      final myTraits2 = [NiceTrait(id: 100), NiceTrait(id: 200)];
      final result2 = checkSignedIndividualitiesPartialMatch(
        myTraits: myTraits2,
        requiredTraits: requiredTraits,
        positiveMatchFunc: partialMatch,
        negativeMatchFunc: partialMatch,
      );
      expect(result2, true);

      final myTraits4 = [NiceTrait(id: 500), NiceTrait(id: 600)];
      final result4 = checkSignedIndividualitiesPartialMatch(
        myTraits: myTraits4,
        requiredTraits: requiredTraits,
        positiveMatchFunc: partialMatch,
        negativeMatchFunc: partialMatch,
      );
      expect(result4, true);
    });
  });
}
