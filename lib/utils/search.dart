import 'package:chaldea/models/models.dart';
import 'package:kana_kit/kana_kit.dart';
import 'package:lpinyin/lpinyin.dart';

const KanaKit kanaKit = KanaKit();

class SearchUtil {
  const SearchUtil._();

  static final Map<Region, Map<String, String>> _cache = {};

  static String getCache(
      String words, Region region, String Function() callback) {
    return _cache.putIfAbsent(region, () => {})[words] ??= callback();
  }

  static String getSortAlphabet(String words, [Region? region]) {
    region ??= db2.settings.resolvedPreferredRegions.first;
    switch (region) {
      case Region.jp:
        return getCache(
            words, region, () => kanaKit.toRomaji(words).toLowerCase());
      case Region.cn:
      case Region.tw:
        return getCache(
            words,
            region,
            () =>
                PinyinHelper.getPinyinE(words) +
                ' ' +
                PinyinHelper.getShortPinyin(words));
      case Region.na:
        return words.toLowerCase();
      case Region.kr:
        return words.toLowerCase();
    }
  }
}
