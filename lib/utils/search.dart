import 'package:kana_kit/kana_kit.dart';
import 'package:lpinyin/lpinyin.dart';

import 'package:chaldea/models/models.dart';
import 'package:chaldea/packages/norm_string.dart';

const KanaKit kanaKit = KanaKit();

class SearchUtil {
  const SearchUtil._();

  static final Map<Region?, Map<String, String>> _cache = {};

  static final Map<String, String> _jpKana = {};
  static final Map<String, String> _zhPinyin = {};
  static final Map<String, String> _enNorm = {};
  static final Map<String, String> _krNorm = {};

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

  static String? getKr(String? words) {
    if (words == null) return null;
    return _krNorm[words] ??= words.replaceAll(' ', '');
  }

  static Iterable<String?> getAllKeys(Transl<dynamic, String> transl, {Region? dft = Region.jp}) sync* {
    String? keyJP, keyCN, keyTW, keyNA, keyKR;
    String key = transl.default_.toString();
    switch (dft) {
      case Region.jp:
        keyJP = key;
        break;
      case Region.cn:
        keyCN = key;
        break;
      case Region.tw:
        keyTW = key;
        break;
      case Region.na:
        keyNA = key;
        break;
      case Region.kr:
        keyKR = key;
        break;
      case null:
        yield key;
        break;
    }
    yield getJP(transl.m?.jp ?? keyJP);
    yield getCN(transl.m?.cn ?? transl.m?.jp ?? keyCN ?? keyJP);
    yield getCN(transl.m?.tw ?? keyTW);
    yield getEn(transl.m?.na ?? keyNA);
    yield getKr(transl.m?.kr ?? keyKR);
  }

  static Iterable<String?> getSkillKeys(SkillOrTd skill) sync* {
    yield* getAllKeys(skill.lName);
    final detail = skill.detail;
    if (skill is BaseSkill) {
      if (detail != null) {
        yield* getAllKeys(Transl.skillDetail(detail));
      }
      yield SearchUtil.getJP(skill.ruby);
      for (final skillAdd in skill.skillAdd) {
        yield* getAllKeys(Transl.skillNames(skillAdd.name));
      }
    } else if (skill is BaseTd) {
      if (detail != null) {
        yield* getAllKeys(Transl.tdDetail(detail));
      }
      yield* SearchUtil.getAllKeys(Transl.tdRuby(skill.ruby));
    }
    for (final func in skill.functions) {
      if (Transl.md.funcPopuptext.containsKey(func.funcType.name)) {
        yield* getAllKeys(Transl.funcPopuptextBase(func.funcType.name));
      } else {
        yield* getAllKeys(func.lPopupText);
      }
      for (final buff in func.buffs) {
        yield* getAllKeys(Transl.buffNames(buff.name));
      }
    }
  }

  static String getCache(String words, Region? region, String Function() callback) {
    return _cache.putIfAbsent(region, () => {})[words] ??= callback();
  }

  static String getSortAlphabet(String words, [Region? region]) {
    region ??= db.settings.resolvedPreferredRegions.first;
    switch (region) {
      case Region.jp:
        return getJP(words)!.toLowerCase();
      case Region.cn:
      case Region.tw:
        return getCN(words)!.toLowerCase();
      case Region.na:
        return getEn(words)!.toLowerCase();
      case Region.kr:
        return getKr(words.toLowerCase())!.toLowerCase();
    }
  }

  static String getLocalizedSort<K>(Transl<K, String> transl) {
    for (final region in Transl.preferRegions) {
      final v = transl.m?.ofRegion(region);
      if (v != null) {
        return getSortAlphabet(v, region);
      }
    }
    return transl.key.toString();
  }
}
