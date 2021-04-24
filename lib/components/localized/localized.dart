library localized;

import 'localized_base.dart';

part 'groups/localized_basic.dart';

part 'groups/localized_master_mission.dart';

class Localized {
  Localized._();

  static LocalizedGroup get gender => _localizedGender;

  static LocalizedGroup get masterMission => _localizedMasterMission;

  static LocalizedGroup get svtFilter => _localizedSvtFilter;

  static LocalizedGroup get craftFilter => LocalizedGroup([
        LocalizedText(chs: '兑换', jpn: 'ショップ交換', eng: 'Mana Prism Shop'),
        LocalizedText(chs: '活动奖励', jpn: 'イベント', eng: 'Event Reward'),
        LocalizedText(chs: 'EXP卡', jpn: 'EXP', eng: 'EXP'),
        LocalizedText(chs: '剧情限定', jpn: 'ストーリー限定', eng: 'Story'),
        LocalizedText(chs: '情人节', jpn: 'バレンタイン', eng: 'Valentine'),
        LocalizedText(chs: '羁绊', jpn: '絆', eng: 'Bond'),
        LocalizedText(chs: '纪念', jpn: '記念', eng: 'Gift'),
        LocalizedText(chs: '卡池常驻', jpn: '恒常', eng: 'Permanent'),
        LocalizedText(chs: '期间限定', jpn: '期間限定', eng: 'Limited'),
        LocalizedText(chs: '友情池常驻', jpn: 'フレンドポイント', eng: 'Friendship'),
        LocalizedText(chs: '未遭遇', jpn: '', eng: ''),
        LocalizedText(chs: '已遭遇', jpn: '', eng: ''),
        LocalizedText(chs: '已契约', jpn: '', eng: ''),
      ]);
}
