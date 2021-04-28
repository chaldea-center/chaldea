import 'package:chaldea/components/constants.dart' show Language;
import 'package:chaldea/components/extensions.dart';

export 'package:chaldea/components/constants.dart' show Language;

class LocalizedText {
  final String chs;
  final String? _jpn;
  final String? _eng;

  String get jpn => _jpn?.isNotEmpty == true ? _jpn! : chs;

  String get eng => _eng?.isNotEmpty == true ? _eng! : jpn;

  const LocalizedText({
    required this.chs,
    required String? jpn,
    required String? eng,
  })  : _jpn = jpn,
        _eng = eng;

  String get localized {
    return _values.first;
  }

  static String of({
    required String chs,
    required String? jpn,
    required String? eng,
  }) {
    return LocalizedText(chs: chs, jpn: jpn, eng: eng).localized;
  }

  String ofPrimary(Language primary) {
    switch (primary) {
      case Language.jpn:
        return jpn;
      case Language.eng:
        return eng;
      default:
        return chs;
    }
  }

  List<String> get _values {
    if (Language.isEN) return [eng, jpn, chs];
    if (Language.isJP) return [jpn, eng, chs];
    return [chs, jpn, eng];
  }

  String get primary => _values[0];

  String get secondary => _values[1];
}

class LocalizedGroup {
  final Language primaryLanguage;

  final List<LocalizedText> values;

  const LocalizedGroup(
    this.values, {
    this.primaryLanguage = Language.chs,
  });

  String of(String v) {
    return instanceOf(v)?.localized ?? v;
  }

  LocalizedText? instanceOf(String v, [Language? primary]) {
    primary ??= primaryLanguage;
    return values.firstWhereOrNull((e) => e.ofPrimary(primary!) == v);
  }
}
