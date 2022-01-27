import 'package:chaldea/packages/packages.dart';
import 'package:dio/dio.dart';

import '../packages/app_info.dart';
import '../packages/language.dart';

export '../packages/language.dart';
export '../utils/constants.dart';

class ClassName {
  final String name;

  const ClassName(this.name);

  static const all = ClassName('All');
  static const saber = ClassName('Saber');
  static const archer = ClassName('Archer');
  static const lancer = ClassName('Lancer');
  static const rider = ClassName('Rider');
  static const caster = ClassName('Caster');
  static const assassin = ClassName('Assassin');
  static const berserker = ClassName('Berserker');
  static const shielder = ClassName('Shielder');
  static const ruler = ClassName('Ruler');
  static const avenger = ClassName('Avenger');
  static const alterego = ClassName('Alterego');
  static const mooncancer = ClassName('MoonCancer');
  static const foreigner = ClassName('Foreigner');
  static const beast = ClassName('Beast');

  static List<ClassName> get values => const [
        saber,
        archer,
        lancer,
        rider,
        caster,
        assassin,
        berserker,
        ruler,
        avenger,
        alterego,
        mooncancer,
        foreigner,
        shielder,
        beast,
      ];
}

T localizeNoun<T>(T? nameCn, T? nameJp, T? nameEn,
    {T Function()? k, Language? primary, bool Function(T)? test}) {
  // convert '' to null
  T? _check(T? v) {
    if (v == null) return null;
    if (test != null) return test(v) ? v : null;
    if (v is String) return v.isNotEmpty ? v : null;
    return v;
  }

  nameCn = _check(nameCn);
  nameJp = _check(nameJp);
  nameEn = _check(nameEn);

  primary ??= Language.current;
  List<T?> names = primary == Language.chs || primary == Language.cht
      ? [nameCn, nameJp, nameEn]
      : primary == Language.en || primary == Language.ko
          ? [nameEn, nameJp, nameCn]
          : [nameJp, nameCn, nameEn];
  T? name = names[0] ?? names[1] ?? names[2] ?? k?.call();
  // assert(name != null,
  //     'null for every localized value: $nameCn,$nameJp,$nameEn,$k');
  if (T == String) {
    return name ?? '' as T;
  }
  return name!;
}

class HttpUtils {
  HttpUtils._();

  static const usernameKey = 'username';
  static const passwordKey = 'password';
  static const newPasswordKey = 'newPassword';
  static const bodyKey = 'body';

  static Dio get defaultDio => Dio(BaseOptions(headers: headersWithUA()));

  static String get userAgentChaldea => 'Chaldea/${AppInfo.versionString}';

  static String get userAgentMacOS =>
      'Mozilla/5.0 (Macintosh; Intel Mac OS X) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/88.0.4324.146 Safari/537.36 $userAgentChaldea';

  static String get userAgentWindows =>
      ' Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/89.0.4389.90 Safari/537.36 Edg/89.0.774.54 $userAgentChaldea';

  static String get userAgentIOS =>
      'Mozilla/5.0 (iPhone; CPU iPhone OS 12_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) CriOS/69.0.3497.105 Mobile/15E148 Safari/605.1 $userAgentChaldea';

  static String get userAgentAndroid =>
      'Mozilla/5.0 (Linux; Android 8.0.0; SM-G960F Build/R16NW) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/62.0.3202.84 Mobile Safari/537.36 $userAgentChaldea';

  static String get userAgentPlatform {
    if (PlatformU.isAndroid) return userAgentAndroid;
    if (PlatformU.isIOS) return userAgentIOS;
    if (PlatformU.isWindows) return userAgentWindows;
    if (PlatformU.isMacOS) return userAgentMacOS;
    return userAgentIOS;
  }

  static Map<String, dynamic> headersWithUA([String? ua]) {
    return {
      if (!PlatformU.isWeb) "user-agent": ua ?? userAgentPlatform,
    };
  }
}
