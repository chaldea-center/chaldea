import 'package:chaldea/models/models.dart';
import 'package:kana_kit/kana_kit.dart';
import 'package:lpinyin/lpinyin.dart';
import 'package:chaldea/packages/norm_string.dart';

const KanaKit kanaKit = KanaKit();

class SearchUtil {
  const SearchUtil._();

  static final Map<Region?, Map<String, String>> _cache = {};

  static final Map<String, String> _jpKana = {};
  static final Map<String, String> _zhPinyin = {};
  static final Map<String, String> _enNorm = {};

  static String? getJP(String? words) {
    if (words == null) return null;
    return _jpKana[words] ??= {
      // not support for Romaji of Chinese characters
      kanaKit.toRomaji(words).replaceAll(' ', ''),
      kanaKit.toHiragana(words),
      words,
    }.join('\t');
  }

  static String? getCN(String? words) {
    if (words == null) return null;
    return _zhPinyin[words] ??= {
      PinyinHelper.getPinyinE(words).replaceAll(' ', ''),
      PinyinHelper.getShortPinyin(words),
      words,
    }.join('\t');
  }

  static String? getEn(String? words) {
    if (words == null) return null;
    return _enNorm[words] ??= words.replaceAll(' ', '').normalize();
  }

  static Iterable<String?> getAllKeys(Transl<dynamic, String> transl) sync* {
    yield getJP(transl.m?.jp);
    yield getCN(transl.m?.cn);
    yield getCN(transl.m?.tw);
    yield getEn(transl.m?.na);
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
        return getJP(words)!.toLowerCase();
      case Region.cn:
      case Region.tw:
        return getCN(words)!.toLowerCase();
      case Region.na:
        return getEn(words)!.toLowerCase();
      case Region.kr:
        return words.toLowerCase();
    }
  }
}
