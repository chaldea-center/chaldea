import 'package:chaldea/app/tools/localized_base.dart';

class SaintLocalized {
  static String get loginBonus => LocalizedText.of(chs: '登陆奖励', jpn: 'ログイン報酬', eng: 'Login Bonus', kor: '로그인 보너스');

  static String get date => LocalizedText.of(chs: '日期', jpn: '日', eng: 'Date', kor: '일');

  static String get accLogin => LocalizedText.of(chs: '累计登陆', jpn: '累積ログイン', eng: 'Cumulative login', kor: '누적 로그인');

  static String get continuousLogin =>
      LocalizedText.of(chs: '连续登陆', jpn: '連続ログイン', eng: 'Continuous login', kor: '연속 로그인');

  static String get accLoginShort => LocalizedText.of(chs: '累计', jpn: '累積', eng: 'Cumulative', kor: '누적');

  static String get continuousLoginShort => LocalizedText.of(chs: '连续', jpn: '連続', eng: 'Continuous', kor: '연속');

  static String get startDate => LocalizedText.of(chs: '起始日期', jpn: '開始日', eng: 'Start Date', kor: '시작일');
}
