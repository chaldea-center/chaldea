import 'dart:math';

import 'package:chaldea/components/input_manager.dart';
import 'package:flutter/material.dart';

//typedef
//const value
const String kUserDataFilename = 'userdata.json';
const String kGameDataFilename = 'dataset.json';
const String kSupportTeamEmailAddress = 'support@narumi.cc';
const String kDefaultDatasetAssetKey = 'res/data/dataset.zip';

//const value in class
class LangCode {
  // code must match S.of(context).language in every .arb file
  static const String chs = '简体中文';
  static const String cht = '繁體中文';
  static const String jpn = '日本語';
  static const String eng = 'English';

  static const Map<String, Locale> allEntries = {
    chs: Locale('zh', ''),
    cht: Locale('zh', 'TW'),
    jpn: Locale('ja', ''),
    eng: Locale('en', '')
  };

  static Locale getLocale(String code) =>
      allEntries.containsKey(code) ? allEntries[code] : allEntries.values.first;

  static List<String> get codes => allEntries.keys.toList();
}

class GameServer {
  static const jp = 'jp';
  static const cn = 'cn';
}

class MyColors {
  static const Color setting_bg = Color(0xFFF9F9F9);
  static const Color setting_tile = Colors.white;
}

class TextFilter {
  List<String> patterns;

  TextFilter([String filterString = '']) {
    setFilter(filterString);
  }

  void setFilter(String filterString) {
    patterns = (filterString ?? '').split(RegExp(r'\s+'));
    patterns.removeWhere((item) => item == '');
  }

  bool match(String string, {bool matchCase = false}) {
    if (patterns.length == 0) {
      return true;
    }
    if (!matchCase) {
      string = string.toLowerCase();
      patterns = patterns.map((p) => p.toLowerCase()).toList();
    }
    bool matched = false;
    for (String pattern in patterns) {
      pattern = pattern.toLowerCase();
      if (pattern[0] == '-' && pattern.length > 1) {
        if (string.contains(pattern.substring(1))) {
          matched = false;
          break;
        }
      } else if (pattern[0] == '+' && pattern.length > 1) {
        if (string.contains(pattern.substring(1))) {
          matched = true;
        } else {
          matched = false;
          break;
        }
      } else {
        if (string.contains(pattern)) {
          matched = true;
        }
      }
    }
    return matched;
  }
}

class ClassName {
  final String name;
  static const all = const ClassName('All');
  static const saber = const ClassName('Saber');
  static const archer = const ClassName('Archer');
  static const lancer = const ClassName('Lancer');
  static const rider = const ClassName('Rider');
  static const caster = const ClassName('Caster');
  static const assassin = const ClassName('Assassin');
  static const berserker = const ClassName('Berserker');
  static const shielder = const ClassName('Shielder');
  static const ruler = const ClassName('Ruler');
  static const avenger = const ClassName('Avenger');
  static const alterego = const ClassName('Alterego');
  static const mooncancer = const ClassName('MoonCancer');
  static const foreigner = const ClassName('Foreigner');
  static const beast = const ClassName('Beast');

  static List<ClassName> get values => const [
        saber,
        archer,
        lancer,
        rider,
        caster,
        assassin,
        berserker,
        shielder,
        ruler,
        avenger,
        alterego,
        mooncancer,
        foreigner,
        beast
      ];

  const ClassName(this.name);
}

//public functions
String formatNum<T>(T number, [String style, num minVal = 0]) {
  if (number is int) {
    int abs = number.abs();
    if (abs < minVal) return number.toString();
    String prefix = number >= 0 ? '' : '-';
    String body;
    switch (style) {
      case 'percent':
        // return percent of num/100, num=1230->return 12.3%
        body = abs % 100 == 0 ? '${abs ~/ 100}%' : '${abs / 100}%';
        break;
      case 'kilo':
        String _format(int number, int base) {
          String s = (number / base).toString();
          s = s.substring(0, min(5, s.length)).replaceAll(RegExp(r'\.0*$'), '');
          s = s.replaceAll(RegExp(r'(?<=\.\d*?)0+'), '');
          return s;
        }
        if (abs < 1000) {
          body = abs.toString();
        } else if (abs < 1000000) {
          body = _format(abs, 1000) + 'K';
        } else {
          body = _format(abs, 1000000) + 'M';
        }
        break;
      case 'decimal':
        body = kThousandFormatter.format(abs);
        break;
      default:
        body = abs.toString();
    }
    return prefix + body;
  }
//  return number.toString();
}

num sum(Iterable<num> x) => x.fold(0, (p, c) => (p ?? 0) + (c ?? 0));

/// sum multiple maps, if [inPlace], add into the first element.
/// throw error if sum in place of an empty list.
Map<K, V> sumDict<K, V extends num>(Iterable<Map<K, V>> operands,
    {bool inPlace = false}) {
  final _operands = operands.toList();
  Map<K, V> res = inPlace ? _operands.removeAt(0) : {};

  for (var m in _operands) {
    m?.forEach((k, v) {
      // use "+ (v??0)" to allow v=null
      res[k] = (res[k] ?? 0) + v;
    });
  }
  return res;
}

Map<K, V> multiplyDict<K, V extends num>(Map<K, V> d, V multiplier) {
  Map<K, V> res = {};
  d.forEach((k, v) {
    res[k] = v * multiplier;
  });
  return res;
}

T getListItem<T>(List<T> data, int index, [k()]) {
  if ((data?.length ?? 0) > index) {
    return data[index];
  } else {
    return k == null ? null : k();
  }
}
