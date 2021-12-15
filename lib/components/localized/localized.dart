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

  static LocalizedGroup get craftFilter => const LocalizedGroup([
        LocalizedText(
            chs: '兑换', jpn: 'ショップ交換', eng: 'Mana Prism Shop', kor: '마나프리즘 상점'),
        LocalizedText(
            chs: '活动奖励', jpn: 'イベント', eng: 'Event Reward', kor: '이벤트 보상'),
        LocalizedText(chs: 'EXP卡', jpn: 'EXP', eng: 'EXP', kor: '경험치'),
        LocalizedText(chs: '剧情限定', jpn: 'ストーリー限定', eng: 'Story', kor: '스토리'),
        LocalizedText(chs: '情人节', jpn: 'バレンタイン', eng: 'Valentine', kor: '발렌타인'),
        LocalizedText(chs: '羁绊', jpn: '絆', eng: 'Bond', kor: '인연'),
        LocalizedText(chs: '纪念', jpn: '記念', eng: 'Gift', kor: '기념'),
        LocalizedText(chs: '卡池常驻', jpn: '恒常', eng: 'Permanent', kor: '상시'),
        LocalizedText(chs: '期间限定', jpn: '期間限定', eng: 'Limited', kor: '한정'),
        LocalizedText(
            chs: '友情池常驻', jpn: 'フレンドポイント', eng: 'Friendship', kor: '친구포인트'),
        LocalizedText(chs: '普通概念礼装', jpn: '', eng: 'General CE', kor: '일반 예장'),
        LocalizedText(chs: '纪念概念礼装', jpn: '', eng: 'Gift CE', kor: '기념 예장'),
        LocalizedText(chs: '概念礼装EXP卡', jpn: '', eng: 'EXP CE', kor: 'EXP용 예장'),
        LocalizedText(
            chs: '魔力棱镜兑换概念礼装',
            jpn: '',
            eng: 'Mana Prism Shop CE',
            kor: '마나프리즘 예장'),
        LocalizedText(
            chs: '情人节概念礼装', jpn: '', eng: 'Valentine CE', kor: '발렌타인 예장'),
        LocalizedText(chs: '羁绊概念礼装', jpn: '', eng: 'Bond CE', kor: '인연 예장'),
        LocalizedText(
            chs: '未遭遇', jpn: '未遭遇', eng: 'Not Encountered', kor: '미실장'),
        LocalizedText(chs: '已遭遇', jpn: '遭遇済', eng: 'Uncontracted', kor: '미소환'),
        LocalizedText(chs: '已契约', jpn: '契約済', eng: 'Contracted', kor: '소환'),
      ]);

  static LocalizedGroup get enemy => _enemy;

  static LocalizedGroup get chapter => const LocalizedGroup([
        LocalizedText(
            chs: '幕间物语', jpn: '幕間の物語', eng: 'Interlude', kor: '막간의 이야기'),
        LocalizedText(
            chs: '强化任务', jpn: '強化クエスト', eng: 'Strengthening', kor: '강화 퀘스트'),
        LocalizedText(
            chs: '强化关卡', jpn: '強化クエスト', eng: 'Strengthening', kor: '강화 퀘스트'),
        LocalizedText(
            chs: '迦勒底之门/每日任务',
            jpn: 'カルデアゲート/曜日クエスト',
            eng: 'Chaldea Gate/Daily Quests',
            kor: '칼데아 게이트/일일 퀘스트'),
        LocalizedText(
            chs: '特异点F 燃烧污染都市 冬木',
            jpn: '特異点F 炎上汚染都市 冬木',
            eng: 'Prologue: Fuyuki',
            kor: '특이점F 염상오염도시 후유키'),
        LocalizedText(
            chs: '第一特异点 邪龙百年战争 奥尔良',
            jpn: '第一特異点 邪竜百年戦争 オルレアン',
            eng: '1st Singularity: Orleans',
            kor: '제1특이점 사룡백년전쟁 오를레앙'),
        LocalizedText(
            chs: '第二特异点 永续疯狂帝国 七丘之城',
            jpn: '第二特異点 永続狂気帝国 セプテム',
            eng: '2nd Singularity: Septem',
            kor: '제2특이점 영속광기제국 세프템'),
        LocalizedText(
            chs: '第三特异点 封锁终局四海 俄刻阿诺斯',
            jpn: '第三特異点 封鎖終局四海オケアノス',
            eng: '3rd Singularity: Okeanos',
            kor: '제3특이점 봉쇄종국사해 오케아노스'),
        LocalizedText(
            chs: '第四特异点 死界魔雾都市 伦敦',
            jpn: '第四特異点 死界魔霧都市 ロンドン',
            eng: '4th Singularity: London',
            kor: '제4특이점 사계마무도시 런던'),
        LocalizedText(
            chs: '第五特异点 北美神话大战 合众为一',
            jpn: '第五特異点 北米神話大戦 イ・プルーリバス・ウナム',
            eng: '5th Singularity: E Pluribus Unum',
            kor: '제5특이점 북미신화대전 에 플루리부스 우눔'),
        LocalizedText(
            chs: '第六特异点 神圣圆桌领域 卡美洛',
            jpn: '第六特異点 神聖円卓領域 キャメロット',
            eng: '6th Singularity: Camelot',
            kor: '제6특이점 신성원탁영역 카멜롯'),
        LocalizedText(
            chs: '第七特异点 绝对魔兽战线 巴比伦尼亚',
            jpn: '第七特異点 絶対魔獣戦線 バビロニア',
            eng: '7th Singularity: Babylonia',
            kor: '제7특이점 절대마수전선 바빌로니아'),
        LocalizedText(
            chs: '终局特异点 冠位时间神殿',
            jpn: '終局特異点 冠位時間神殿',
            eng: 'Final Singularity: Solomon',
            kor: '종국특이점 관위시간신전'),
        LocalizedText(
            chs: '终局特异点 冠位时间神殿 所罗门',
            jpn: '終局特異点 冠位時間神殿 ソロモン',
            eng: 'Final Singularity: Solomon',
            kor: '종국특이점 관위시간신전 솔로몬'),
        LocalizedText(
            chs: '亚种特异点Ⅰ 恶性隔绝魔境 新宿',
            jpn: '亜種特異点Ⅰ 悪性隔絶魔境 新宿',
            eng:
                'Pseudo Singularity I: Quarantined Territory of Malice, Shinjuku',
            kor: '아종특이점 I: 악성결절마경 신주쿠'),
        LocalizedText(
            chs: '亚种特异点Ⅱ 传承地底世界 雅戈泰',
            jpn: '亜種特異点Ⅱ 伝承地底世界 アガルタ',
            eng:
                'Pseudo Singularity II: Subterranean World of Folklore, Agartha',
            kor: '아종특이점 II: 전승지저세계 아가르타'),
        LocalizedText(
            chs: '亚种特异点Ⅲ 尸山血河舞台 下总国',
            jpn: '亜種特異点Ⅲ 屍山血河舞台 下総国',
            eng:
                'Pseudo Singularity III: The Stage of Blood Rivers and Corpse Mountains, Shimousa',
            kor: '아종특이점 III: 시산혈하무대 시모사노쿠니'),
        LocalizedText(
            chs: '亚种特异点Ⅳ 禁忌降临庭园 塞勒姆',
            jpn: '亜種特異点Ⅳ 禁忌降臨庭園 セイレム',
            eng: 'Pseudo Singularity IV: The Forbidden Advent Garden, Salem',
            kor: '아종특이점 IV: 금기강림정원 세일럼'),
        LocalizedText(
            chs: '亚种特异点Ⅰ 恶性隔绝魔境 新宿 新宿幻灵事件',
            jpn: '亜種特異点Ⅰ 悪性隔絶魔境 新宿 新宿幻霊事件',
            eng:
                'Pseudo Singularity I: Quarantined Territory of Malice, Shinjuku',
            kor: '아종특이점 I: 악성결절마경 신주쿠 환령 사건'),
        LocalizedText(
            chs: '亚种特异点Ⅱ 传承地底世界 雅戈泰 雅戈泰之女',
            jpn: '亜種特異点Ⅱ 伝承地底世界 アガルタ アガルタの女',
            eng:
                'Pseudo Singularity II: Subterranean World of Folklore, Agartha',
            kor: '아종특이점 II: 전승지저세계 아가르타 아가르타의 여자'),
        LocalizedText(
            chs: '亚种特异点Ⅲ 尸山血河舞台 下总国 英灵剑豪七番决胜',
            jpn: '亜種特異点Ⅲ 屍山血河舞台 下総国  英霊剣豪七番勝負',
            eng:
                'Pseudo Singularity III: The Stage of Blood Rivers and Corpse Mountains, Shimousa',
            kor: '아종특이점 III: 시산혈하무대 시모사노쿠니 영령검호칠번승부'),
        LocalizedText(
            chs: '亚种特异点Ⅳ 禁忌降临庭园 塞勒姆 异端塞勒姆',
            jpn: '亜種特異点Ⅳ 禁忌降臨庭園 セイレム 異端なるセイレム',
            eng: 'Pseudo-Singularity IV: The Forbidden Advent Garden, Salem',
            kor: '아종특이점 IV: 금기강림정원 세일럼 이단의 세일럼'),
        LocalizedText(
            chs: '序／2018年 12月26日',
            jpn: '序／2017年 12月26日',
            eng: 'Lostbelt Prologue: Opening / December 26, 2019',
            kor: '2부 프롤로그 서/2019년 12월 26일'),
        LocalizedText(
            chs: '序／2018年 12月31日',
            jpn: '序／2017年 12月31日',
            eng: 'Lostbelt Prologue: Opening / December 31, 2019',
            kor: '2부 프롤로그 서/2019년 12월 31일'),
        LocalizedText(
            chs: 'Lostbelt No.1 永久冻土帝国 阿纳斯塔西娅',
            jpn: 'Lostbelt No.1 永久凍土帝国 アナスタシア',
            eng: 'Lostbelt No.1: Permafrost Empire, Anastasia',
            kor: 'Lostbelt No.1 영구동토제국 아나스타샤'),
        LocalizedText(
            chs: 'Lostbelt No.1 永久冻土帝国 阿纳斯塔西娅 兽国的皇女',
            jpn: 'Lostbelt No.1 永久凍土帝国 アナスタシア 獣国の皇女',
            eng:
                'Lostbelt No.1: Permafrost Empire, Anastasia, The Grand Duchess of the Beast Nation',
            kor: 'Lostbelt No.1: 영구동토제국 아나스타샤 짐승나라의 황녀'),
        LocalizedText(
            chs: 'Lostbelt No.2 无间冰焰世纪 诸神黄昏',
            jpn: 'Lostbelt No.2 無間氷焔世紀 ゲッテルデメルング',
            eng: 'Lostbelt No.2: Eternal Frozen Fire Century, Götterdämmerung',
            kor: 'Lostbelt No.2: 무간빙염세기 괴터데머룽'),
        LocalizedText(
            chs: 'Lostbelt No.2 无间冰焰世纪 诸神黄昏 不灭火焰的好男儿',
            jpn: 'Lostbelt No.2 無間氷焔世紀 ゲッテルデメルング 消えぬ炎の快男児',
            eng:
                'Lostbelt No.2: Eternal Frozen Fire Century, Götterdämmerung, The Good Fellow of Everlasting Flame',
            kor: 'Lostbelt No.2: 무간빙염세기 괴터데머룽 꺼지지않는 불꽃의 쾌남아'),
        LocalizedText(
            chs: 'Lostbelt No.3 － intro －',
            jpn: 'Lostbelt No.3 － intro －',
            eng: 'Lostbelt No.3 － intro －',
            kor: 'Lostbelt No.3 － intro －'),
        LocalizedText(
            chs: 'Lostbelt No.3 人智统合真国 SIN',
            jpn: 'Lostbelt No.3 人智統合真国 シン',
            eng: 'Lostbelt No.3: The Synchronized Intellect Nation, SIN',
            kor: 'Lostbelt No.3 인지통합진국 신'),
        LocalizedText(
            chs: 'Lostbelt No.3 人智统合真国 SIN 红之月下美人',
            jpn: 'Lostbelt No.3 人智統合真国 シン 紅の月下美人',
            eng:
                'Lostbelt No.3: The Synchronized Intellect Nation, SIN, The Crimson Beauty Under the Moon',
            kor: 'Lostbelt No.3 인지통합진국 신 홍색의 월하미인'),
        LocalizedText(
            chs: 'Lostbelt No.4 创世灭亡轮回 由伽·刹多罗',
            jpn: 'Lostbelt No.4 創世滅亡輪廻 ユガ･クシェートラ',
            eng: 'Lostbelt No.4: Genesis Destruction Cycle, Yuga Kshetra',
            kor: 'lostbelt No.4: 창세멸망윤회 유가 크셰트라'),
        LocalizedText(
            chs: 'Lostbelt No.4 创世灭亡轮回 由伽·刹多罗 黑色最后之神',
            jpn: 'Lostbelt No.4 創世滅亡輪廻 ユガ･クシェートラ 黒き最後の神',
            eng:
                'Lostbelt No.4: Genesis Destruction Cycle, Yuga Kshetra, The Final Dark God',
            kor: 'lostbelt No.4: 창세멸망윤회 유가 크셰트라 검은 최후의 신'),
        LocalizedText(
            chs: 'Lostbelt No.5 神代巨神海洋 亚特兰蒂斯',
            jpn: 'Lostbelt No.5 神代巨神海洋 アトランティス',
            eng:
                'Lostbelt No.5: Ancient Titans\' Ocean, Atlantis: The Day a God was Shot Down',
            kor: 'Lostbelt No.5: 신대거신해양 아틀란티스'),
        LocalizedText(
            chs: 'Lostbelt No.5 神代巨神海洋 亚特兰蒂斯 击坠神明之日',
            jpn: 'Lostbelt No.5 神代巨神海洋 アトランティス 神を撃ち落とす日',
            eng:
                'Lostbelt No.5: Ancient Titans\' Ocean, Atlantis, The Day a God was Shot Down',
            kor: 'Lostbelt No.5: 신대거신해양 아틀란티스 신을 쏘아 떨어트리는 날'),
        LocalizedText(
            chs: 'Lostbelt No.5 星间都市山脉 奥林波斯',
            jpn: 'Lostbelt No.5 星間都市山脈 オリュンポス',
            eng:
                'Lostbelt No.5: Interstellar City on a Mountain Range, Olympus',
            kor: 'Lostbelt No.5: 성간도시산맥 올림포스'),
        LocalizedText(
            chs: 'Lostbelt No.5 星间都市山脉 奥林波斯 击坠神明之日',
            jpn: 'Lostbelt No.5 星間都市山脈 オリュンポス 神を撃ち落とす日',
            eng:
                'Lostbelt No.5: Interstellar City on a Mountain Range, Olympus, The Day a God is Shot Down',
            kor: 'Lostbelt No.5: 성간도시산맥 올림포스 신을 쏘아 떨어트리는 날'),
        LocalizedText(
            chs: '地狱界曼荼罗 平安京',
            jpn: '地獄界曼荼羅 平安京',
            eng: 'Lostbelt No.5.5: Realm of Hell Mandala, Heian-kyō',
            kor: 'Lostbelt No.5.5: 지옥계만다라 헤이안쿄'),
        LocalizedText(
            chs: '地狱界曼荼罗 平安京 轰雷一闪',
            jpn: '地獄界曼荼羅 平安京 轟雷一閃',
            eng:
                'Lostbelt No.5.5: Realm of Hell Mandala, Heian-kyō, Thundering Flash',
            kor: 'Lostbelt No.5.5: 지옥계만다라 헤이안쿄 굉뢰일섬'),
        LocalizedText(
            chs: 'Lostbelt No.6 妖精圆桌领域 阿瓦隆·勒·菲',
            jpn: 'Lostbelt No.6 妖精円卓領域 アヴァロン･ル･フェ',
            eng: 'Lostbelt No.6: Fairy Realm of the Round Table, Avalon le Fae',
            kor: 'Lostbelt No.6: 요정원탁영역 아발론･르･페이'),
        LocalizedText(
            chs: 'Lostbelt No.6 妖精圆桌领域 阿瓦隆·勒·菲 星辰诞生之刻',
            jpn: 'Lostbelt No.6 妖精円卓領域 アヴァロン･ル･フェ 星の生まれる刻',
            eng:
                'Lostbelt No.6: Fairy Realm of the Round Table, Avalon le Fae, The Moment a Star is Born',
            kor: 'Lostbelt No.6: 요정원탁영역 아발론･르･페이 별이 태어나는 때'),
        LocalizedText(
            chs: 'Lostbelt No.6 妖精圆桌领域 阿瓦隆·勒·菲(前篇)',
            jpn: 'Lostbelt No.6 妖精円卓領域 アヴァロン･ル･フェ(前編)',
            eng:
                'Lostbelt No.6: Fairy Realm of the Round Table, Avalon le Fae, The Moment a Star is Born, Part I',
            kor: 'Lostbelt No.6 요정원탁영역 아발론･르･페이(전편)'),
        LocalizedText(
            chs: 'Lostbelt No.6 妖精圆桌领域 阿瓦隆·勒·菲(后篇)',
            jpn: 'Lostbelt No.6 妖精円卓領域 アヴァロン･ル･フェ(後編)',
            eng:
                'Lostbelt No.6: Fairy Realm of the Round Table, Avalon le Fae, The Moment a Star is Born, Part II',
            kor: 'Lostbelt No.6 요정원탁영역 아발론･르･페이(후편)'),
        LocalizedText(
            chs: 'Lostbelt No.6 妖精圆桌领域 阿瓦隆·勒·菲 星辰诞生之刻(前篇)',
            jpn: 'Lostbelt No.6 妖精円卓領域 アヴァロン･ル･フェ 星の生まれる刻(前編)',
            eng:
                'Lostbelt No.6: Fairy Realm of the Round Table, Avalon le Fae, The Moment a Star is Born, Part I',
            kor: 'Lostbelt No.6 요정원탁영역 아발론･르･페이(전편) 별이 태어나는 때'),
        LocalizedText(
            chs: 'Lostbelt No.6 妖精圆桌领域 阿瓦隆·勒·菲 星辰诞生之刻(后篇)',
            jpn: 'Lostbelt No.6 妖精円卓領域 アヴァロン･ル･フェ 星の生まれる刻(後編)',
            eng:
                'Lostbelt No.6: Fairy Realm of the Round Table, Avalon le Fae, The Moment a Star is Born, Part II',
            kor: 'Lostbelt No.6 요정원탁영역 아발론･르･페이(후편) 별이 태어나는 때'),
      ]);

  // temp
  static LocalizedText freeDropRateChangedHint = const LocalizedText(
    chs: '注意: 日服于六周年之际略微调高了free本的素材掉率，可在设置中选择是否使用新数据。旧数据截至2.5.5的Free本。',
    jpn:
        'ご注意：FGO6周年の時、フリークエストのドロップ率が若干調整されたため、設定で新しいデータを使用するかどうかを選択できます。古いデータは2.5.5のフリークエストまでです。',
    eng:
        'Note: At the 6th anniversary of JP server, the item drop rate of free quest has been slightly adjusted. You can choose whether to use the new data in the settings. The old data is up to the Free quests of 2.5.5.',
    kor:
        '주의: FGO 6주년 때 프리 퀘스트의 드랍률이 약간 조정되었기 때문에 설정에서 새로운 데이터를 사용할지 어쩔지를 선택하여주세요. 이전 데이터는 2.5.5의 프리퀘스트까지 입니다.',
  );
}
