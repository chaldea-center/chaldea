/// To be removed

import 'package:chaldea/packages/language.dart';

class LocalizedText {
  final String? _chs;
  final String? _jpn;
  final String? _eng;
  final String? _kor;

  String get chs => _chs ?? '';

  String get jpn => _jpn?.isNotEmpty == true ? _jpn! : chs;

  String get eng => _eng?.isNotEmpty == true ? _eng! : jpn;

  String get kor => _kor?.isNotEmpty == true ? _kor! : eng;

  const LocalizedText({
    required String? chs,
    required String? jpn,
    required String? eng,
    String? kor,
  })  : _chs = chs,
        _jpn = jpn,
        _eng = eng,
        _kor = kor;

  String get localized {
    return _values.first;
  }

  static String of({
    required String chs,
    required String? jpn,
    required String? eng,
    String? kor,
    Language? primary,
  }) {
    final text = LocalizedText(chs: chs, jpn: jpn, eng: eng, kor: kor);
    if (primary == null) {
      return text.localized;
    } else {
      return text.ofPrimary(primary);
    }
  }

  String ofPrimary(Language primary) {
    switch (primary) {
      case Language.jp:
        return jpn;
      case Language.en:
        return eng;
      case Language.ko:
        return kor;
      default:
        return chs;
    }
  }

  List<String> get _values {
    if (Language.isEN) return [eng, jpn, chs];
    if (Language.isKO) return [kor, eng, jpn, chs];
    if (Language.isJP) return [jpn, eng, chs];
    return [chs, jpn, eng];
  }

  String get primary => _values[0];

  String get secondary => _values[1];
}
