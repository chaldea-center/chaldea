import 'package:flutter/material.dart';

//typedef
//const value
const String userDataFilename = 'userdata.json';

//const value in class
class LangCode {
  // code must match S.of(context).language in every .arb file
  static const String chs = '简体中文';
  static const String cht = '繁體中文';
  static const String jpn = '日本語';
  static const String eng = 'English';

  static const Map<String, Locale> values = {
    chs: Locale('zh', ''),
    cht: Locale('zh', 'TW'),
    jpn: Locale('ja', ''),
    eng: Locale('en', '')
  };

  static Locale getLocale(String code) => code == null ? null : values[code];

  static List<String> get codes => values.keys.toList();
}

class GameServer {
  static const jp = 'jp';
  static const cn = 'cn';
}

class MyColors {
  static const Color setting_bg = Color(0xFFF9F9F9);
  static const Color setting_tile = Colors.white;
}

class GalleryItem {
  static const String servant = 'servant';
  static const String item = 'item';
  static const String event = 'event';
  static const String plan = 'plan';
  static const String craft = 'craft';
  static const String cmd_code = 'cmd_code';
  static const String gacha = 'gacha';
  static const String calculator = 'calculator';
  static const String master_equip = 'master_equip';
  static const String backup = 'backup';
  static const String more = 'more';

//  static Map<String, GalleryItem> allItems;

  // instant part
  String name;
  String Function(BuildContext context) titleBuilder;
  final IconData icon;
  final WidgetBuilder builder;
  final bool isDetail;

  GalleryItem(
      {@required this.name,
      @required this.titleBuilder,
      @required this.icon,
      @required this.builder,
      this.isDetail = false})
      : assert(titleBuilder != null),
        assert(icon != null),
        assert(builder != null);

  @override
  String toString() {
    return '$runtimeType($name)';
  }
}

class TextFilter {
  List<String> patterns;

  TextFilter(filterString) {
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
String formatNumToString<T>(T number, [String style]) {
  if (number is String || number is double) {
    return '$number';
  } else if (number is int) {
    int num = number;
    String prefix = num >= 0 ? '' : '-';
    num = num >= 0 ? num : -num;
    String body;
    switch (style) {
      case 'percent':
        // return percent of num/100, num=1230->return 12.3%
        body = num % 100 == 0 ? '${num ~/ 100}%' : '${num / 100.0}%';
        break;
      case 'kilo':
        if (num == 0) {
          body = num.toString();
        } else if (num % 1000000000 == 0) {
          body = formatNumToString(num ~/ 1000000000, 'decimal') + 'G';
        } else if (num % 1000000 == 0) {
          body = formatNumToString(num ~/ 1000000, 'decimal') + 'M';
        } else if (num % 1000 == 0) {
          body = formatNumToString(num ~/ 1000, 'decimal') + 'K';
        } else {
          body = formatNumToString(num, 'decimal');
        }
        break;
      case 'decimal':
        String s = '';
        if (num == 0) {
          body = num.toString();
        } else {
          List<String> list = [];
          while (num > 0) {
            list.insert(0, '${num % 1000}'.padLeft(3, '0'));
            s = '${num % 1000}'.padLeft(3, '0') + ',$s';
            num = num ~/ 1000;
          }
          list[0] = int.parse(list[0]).toString();
          body = list.join(',');
        }
        break;
      default:
        body = '$num';
    }
    return prefix + body;
  } else {
    throw TypeError();
  }
}

num sum(Iterable<num> x) => x.fold(0, (p, c) => p + c);

Map<K, V> sumDict<K, V extends num>(List<Map<K, V>> list) {
  Map<K, V> res = {};
  for (var m in list) {
    m.forEach((k, v) {
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
