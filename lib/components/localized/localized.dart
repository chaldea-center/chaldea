library localized;

import 'localized_base.dart';

export 'localized_base.dart';

part 'groups/localized_basic.dart';

part 'groups/localized_enemy.dart';

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
        LocalizedText(chs: '普通概念礼装', jpn: '', eng: 'General CE'),
        LocalizedText(chs: '纪念概念礼装', jpn: '', eng: 'Gift CE'),
        LocalizedText(chs: '概念礼装EXP卡', jpn: '', eng: 'EXP CE'),
        LocalizedText(chs: '魔力棱镜兑换概念礼装', jpn: '', eng: 'Mana Prism Shop CE'),
        LocalizedText(chs: '情人节概念礼装', jpn: '', eng: 'Valentine CE'),
        LocalizedText(chs: '羁绊概念礼装', jpn: '', eng: 'Bond CE'),
      ]);

  static LocalizedGroup get enemy => _enemy;

  static LocalizedGroup get chapter => LocalizedGroup([
        LocalizedText(chs: '幕间物语', jpn: '幕間の物語', eng: 'Interlude'),
        LocalizedText(chs: '强化任务', jpn: '強化クエスト', eng: 'Strengthening'),
        LocalizedText(
            chs: '特异点F 燃烧污染都市 冬木',
            jpn: '特異点F 炎上汚染都市 冬木',
            eng: 'Prologue: Fuyuki'),
        LocalizedText(
            chs: '第一特异点 邪龙百年战争 奥尔良',
            jpn: '第一特異点 邪竜百年戦争 オルレアン',
            eng: '1st Singularity: Orleans'),
        LocalizedText(
            chs: '第二特异点 永续疯狂帝国 七丘之城',
            jpn: '第二特異点 永続狂気帝国 セプテム',
            eng: '2nd Singularity: Septem'),
        LocalizedText(
            chs: '第三特异点 封锁终局四海 俄刻阿诺斯',
            jpn: '第三特異点 封鎖終局四海オケアノス',
            eng: '3rd Singularity: Okeanos'),
        LocalizedText(
            chs: '第四特异点 死界魔雾都市 伦敦',
            jpn: '第四特異点 死界魔霧都市 ロンドン',
            eng: '4th Singularity: London'),
        LocalizedText(
            chs: '第五特异点 北美神话大战 合众为一',
            jpn: '第五特異点 北米神話大戦 イ・プルーリバス・ウナム',
            eng: '5th Singularity: E Pluribus Unum'),
        LocalizedText(
            chs: '第六特异点 神圣圆桌领域 卡美洛',
            jpn: '第六特異点 神聖円卓領域 キャメロット',
            eng: '6th Singularity: Camelot'),
        LocalizedText(
            chs: '第七特异点 绝对魔兽战线 巴比伦尼亚',
            jpn: '第七特異点 絶対魔獣戦線 バビロニア',
            eng: '7th Singularity: Babylonia'),
        LocalizedText(
            chs: '终局特异点 冠位时间神殿',
            jpn: '終局特異点 冠位時間神殿',
            eng: 'Final Singularity: Solomon'),
        LocalizedText(
            chs: '终局特异点 冠位时间神殿 所罗门',
            jpn: '終局特異点 冠位時間神殿 ソロモン',
            eng: 'Final Singularity: Solomon'),
        LocalizedText(
            chs: '亚种特异点Ⅰ 恶性隔绝魔境 新宿',
            jpn: '亜種特異点Ⅰ 悪性隔絶魔境 新宿',
            eng:
                'Pseudo Singularity I: Quarantined Territory of Malice, Shinjuku'),
        LocalizedText(
            chs: '亚种特异点Ⅱ 传承地底世界 雅戈泰',
            jpn: '亜種特異点Ⅱ 伝承地底世界 アガルタ',
            eng:
                'Pseudo Singularity II: Subterranean World of Folklore, Agartha'),
        LocalizedText(
            chs: '亚种特异点Ⅲ 尸山血河舞台 下总国',
            jpn: '亜種特異点Ⅲ 屍山血河舞台 下総国',
            eng:
                'Pseudo Singularity III: The Stage of Blood Rivers and Corpse Mountains, Shimousa'),
        LocalizedText(
            chs: '亚种特异点Ⅳ 禁忌降临庭园 塞勒姆',
            jpn: '亜種特異点Ⅳ 禁忌降臨庭園 セイレム',
            eng: 'Pseudo Singularity IV: The Forbidden Advent Garden, Salem'),
        LocalizedText(
            chs: '亚种特异点Ⅰ 恶性隔绝魔境 新宿 新宿幻灵事件',
            jpn: '亜種特異点Ⅰ 悪性隔絶魔境 新宿 新宿幻霊事件',
            eng:
                'Pseudo Singularity I: Quarantined Territory of Malice, Shinjuku'),
        LocalizedText(
            chs: '亚种特异点Ⅱ 传承地底世界 雅戈泰 雅戈泰之女',
            jpn: '亜種特異点Ⅱ 伝承地底世界 アガルタ アガルタの女',
            eng:
                'Pseudo Singularity II: Subterranean World of Folklore, Agartha'),
        LocalizedText(
            chs: '亚种特异点Ⅲ 尸山血河舞台 下总国 英灵剑豪七番决胜',
            jpn: '亜種特異点Ⅲ 屍山血河舞台 下総国  英霊剣豪七番勝負',
            eng:
                'Pseudo Singularity III: The Stage of Blood Rivers and Corpse Mountains, Shimousa'),
        LocalizedText(
            chs: '亚种特异点Ⅳ 禁忌降临庭园 塞勒姆 异端塞勒姆',
            jpn: '亜種特異点Ⅳ 禁忌降臨庭園 セイレム 異端なるセイレム',
            eng: 'Pseudo-Singularity IV: The Forbidden Advent Garden, Salem'),
        LocalizedText(
            chs: '序／2018年 12月26日',
            jpn: '序／2017年 12月26日',
            eng: 'Lostbelt Prologue: Opening / December 26, 2017'),
        LocalizedText(
            chs: '序／2018年 12月31日',
            jpn: '序／2017年 12月31日',
            eng: 'Lostbelt Prologue: Opening / December 31, 2017'),
        LocalizedText(
            chs: 'Lostbelt No.1 永久冻土帝国 阿纳斯塔西娅',
            jpn: 'Lostbelt No.1 永久凍土帝国 アナスタシア',
            eng: 'Lostbelt No.1: Permafrost Empire, Anastasia'),
        LocalizedText(
            chs: 'Lostbelt No.1 永久冻土帝国 阿纳斯塔西娅 兽国的皇女',
            jpn: 'Lostbelt No.1 永久凍土帝国 アナスタシア 獣国の皇女',
            eng:
                'Lostbelt No.1: Permafrost Empire, Anastasia, The Grand Duchess of the Beast Nation'),
        LocalizedText(
            chs: 'Lostbelt No.2 无间冰焰世纪 诸神黄昏',
            jpn: 'Lostbelt No.2 無間氷焔世紀 ゲッテルデメルング',
            eng: 'Lostbelt No.2: Eternal Frozen Fire Century, Götterdämmerung'),
        LocalizedText(
            chs: 'Lostbelt No.2 无间冰焰世纪 诸神黄昏 不灭火焰的好男儿',
            jpn: 'Lostbelt No.2 無間氷焔世紀 ゲッテルデメルング 消えぬ炎の快男児',
            eng:
                'Lostbelt No.2: Eternal Frozen Fire Century, Götterdämmerung, The Good Fellow of Everlasting Flame'),
        LocalizedText(
            chs: 'Lostbelt No.3 － intro －',
            jpn: 'Lostbelt No.3 － intro －',
            eng: 'Lostbelt No.3 － intro －'),
        LocalizedText(
            chs: 'Lostbelt No.3 人智统合真国 SIN',
            jpn: 'Lostbelt No.3 人智統合真国 シン',
            eng: 'Lostbelt No.3: The Synchronized Intellect Nation, SIN'),
        LocalizedText(
            chs: 'Lostbelt No.3 人智统合真国 SIN 红之月下美人',
            jpn: 'Lostbelt No.3 人智統合真国 シン 紅の月下美人',
            eng:
                'Lostbelt No.3: The Synchronized Intellect Nation, SIN, The Crimson Beauty Under the Moon'),
        LocalizedText(
            chs: 'Lostbelt No.4 创世灭亡轮回 由伽·刹多罗',
            jpn: 'Lostbelt No.4 創世滅亡輪廻 ユガ･クシェートラ',
            eng: "Lostbelt No.4: Genesis Destruction Cycle, Yuga Kshetra"),
        LocalizedText(
            chs: 'Lostbelt No.4 创世灭亡轮回 由伽·刹多罗 黑色最后之神',
            jpn: 'Lostbelt No.4 創世滅亡輪廻 ユガ･クシェートラ 黒き最後の神',
            eng:
                "Lostbelt No.4: Genesis Destruction Cycle, Yuga Kshetra, The Final Dark God"),
        LocalizedText(
            chs: 'Lostbelt No.5 神代巨神海洋 亚特兰蒂斯',
            jpn: 'Lostbelt No.5 神代巨神海洋 アトランティス',
            eng:
                "Lostbelt No.5: Ancient Titans' Ocean, Atlantis: The Day a God was Shot Down"),
        LocalizedText(
            chs: 'Lostbelt No.5 神代巨神海洋 亚特兰蒂斯 击坠神明之日',
            jpn: 'Lostbelt No.5 神代巨神海洋 アトランティス 神を撃ち落とす日',
            eng:
                "Lostbelt No.5: Ancient Titans' Ocean, Atlantis, The Day a God was Shot Down"),
        LocalizedText(
            chs: 'Lostbelt No.5 星间都市山脉 奥林波斯',
            jpn: 'Lostbelt No.5 星間都市山脈 オリュンポス',
            eng:
                "Lostbelt No.5: Interstellar City on a Mountain Range, Olympus"),
        LocalizedText(
            chs: 'Lostbelt No.5 星间都市山脉 奥林波斯 击坠神明之日',
            jpn: 'Lostbelt No.5 星間都市山脈 オリュンポス 神を撃ち落とす日',
            eng:
                "Lostbelt No.5: Interstellar City on a Mountain Range, Olympus, The Day a God is Shot Down"),
        LocalizedText(
            chs: '地狱界曼荼罗 平安京',
            jpn: '地獄界曼荼羅 平安京',
            eng: "Lostbelt No.5.5: Realm of Hell Mandala, Heian-kyō"),
        LocalizedText(
            chs: '地狱界曼荼罗 平安京 轰雷一闪',
            jpn: '地獄界曼荼羅 平安京 轟雷一閃',
            eng:
                "Lostbelt No.5.5: Realm of Hell Mandala, Heian-kyō, Thundering Flash"),
      ]);
}
