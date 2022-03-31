import 'package:chaldea/models/models.dart';
import 'package:kana_kit/kana_kit.dart';
import 'package:lpinyin/lpinyin.dart';

const KanaKit kanaKit = KanaKit();

class SearchUtil {
  const SearchUtil._();

  static final Map<Region?, Map<String, String>> _cache = {};

  static final Map<String, String> _jpKana = {};
  static final Map<String, String> _zhPinyin = {};

  static String? getJP(String? words) {
    if (words == null) return null;
    return _jpKana[words] ??= [
      words,
      kanaKit.toRomaji(words),
      kanaKit.toHiragana(words),
    ].join('\t');
  }

  static String? getCN(String? words) {
    if (words == null) return null;
    return _zhPinyin[words] ??= [
      // return [
      words,
      PinyinHelper.getPinyinE(words),
      PinyinHelper.getShortPinyin(words),
    ].join('\t');
  }

  static Iterable<String?> getAllRegion(Transl<dynamic, String> transl) sync* {
    yield getJP(transl.m?.jp);
    yield getCN(transl.m?.cn);
    yield getCN(transl.m?.tw);
    yield transl.m?.na;
    yield transl.m?.kr;
  }

  static String getCache(
      String words, Region? region, String Function() callback) {
    return _cache.putIfAbsent(region, () => {})[words] ??= callback();
  }

  static String getSortAlphabet(String words, [Region? region]) {
    region ??= db2.settings.resolvedPreferredRegions.first;
    switch (region) {
      case Region.jp:
        return getJP(words)!;
      case Region.cn:
      case Region.tw:
        return getCN(words)!;
      case Region.na:
        return words.toLowerCase();
      case Region.kr:
        return words.toLowerCase();
    }
  }
}
