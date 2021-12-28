part of localized;

const _localizedGender = LocalizedGroup([
  LocalizedText(chs: '男性', jpn: '男性', eng: 'Male', kor: '남성'),
  LocalizedText(chs: '女性', jpn: '女性', eng: 'Female', kor: '여성'),
  LocalizedText(
      chs: '其他性别', jpn: 'その他の性別', eng: 'Unknown gender', kor: '성별 불명'),
  LocalizedText(chs: '其他', jpn: 'その他の性別', eng: 'Unknown gender', kor: '성별 불명'),
]);

const localizedGameClass = LocalizedGroup([
  LocalizedText(chs: '剑阶', jpn: 'セイバー', eng: 'Saber', kor: '세이버'),
  LocalizedText(chs: '弓阶', jpn: 'アーチャー', eng: 'Archer', kor: '아처'),
  LocalizedText(chs: '枪阶', jpn: 'ランサー', eng: 'Lancer', kor: '랜서'),
  LocalizedText(chs: '骑阶', jpn: 'ライダー', eng: 'Rider', kor: '라이더'),
  LocalizedText(chs: '术阶', jpn: 'チャスター', eng: 'Caster', kor: '캐스터'),
  LocalizedText(chs: '杀阶', jpn: 'アサシン', eng: 'Assassin', kor: '어새신'),
  LocalizedText(chs: '狂阶', jpn: 'バーサーカー', eng: 'Berserker', kor: '버서커'),
  LocalizedText(chs: '裁阶', jpn: 'ルーラー', eng: 'Ruler', kor: '룰러'),
  LocalizedText(chs: '仇阶', jpn: 'アヴェンジャー', eng: 'Avenger', kor: '어벤저'),
  LocalizedText(chs: '他人格', jpn: '', eng: 'Alterego', kor: '얼터에고'),
  LocalizedText(chs: '月癌', jpn: '', eng: 'MoonCancer', kor: '문캔서'),
  LocalizedText(chs: '外阶', jpn: '', eng: 'Foreigner', kor: '포리너'),
  LocalizedText(chs: '盾阶', jpn: '', eng: 'Shielder', kor: '실더'),
  LocalizedText(chs: '兽阶', jpn: '', eng: 'Beast', kor: '비스트'),
]);

const _localizedSvtFilter = LocalizedGroup([
  LocalizedText(
      chs: '充能(技能)',
      jpn: 'NPチャージ(スキル)',
      eng: 'NP Charge(Skill)',
      kor: 'NP 차지(스킬)'),
  LocalizedText(
      chs: '充能(宝具)', jpn: 'NPチャージ(宝具)', eng: 'NP Charge(NP)', kor: 'NP 차지(보구)'),
  //['未遭遇', '已遭遇', '已契约']
  LocalizedText(chs: '初号机', jpn: '初号機', eng: 'Primary', kor: '1호기'),
  LocalizedText(chs: '2号机', jpn: '2号機', eng: 'Replica', kor: 'n호기'),
  // obtain
  LocalizedText(chs: '剧情', jpn: 'ストーリー', eng: 'Story', kor: '스토리'),
  LocalizedText(chs: '活动', jpn: 'イベント', eng: 'Event', kor: '이벤트'),
  LocalizedText(chs: '无法召唤', jpn: '召唤できない', eng: 'Unsummon', kor: '소환할 수 없음'),
  LocalizedText(chs: '常驻', jpn: '恒常', eng: 'Permanent', kor: '상시'),
  LocalizedText(chs: '限定', jpn: '限定', eng: 'Limited', kor: '한정'),
  LocalizedText(
      chs: '友情点召唤', jpn: 'フレンドポイント', eng: 'Friendship', kor: '프렌드 포인트'),
  //obtains
  LocalizedText(chs: '事前登录赠送', jpn: '', eng: '', kor: '사전 등록 보상'),
  LocalizedText(chs: '活动赠送', jpn: 'イベント', eng: 'Event', kor: '이벤트'),
  LocalizedText(
      chs: '友情点召唤', jpn: 'フレンドポイント', eng: 'Friendship', kor: '프렌드 포인트'),
  LocalizedText(chs: '初始获得', jpn: '初期入手', eng: 'Initial', kor: '초기 입수'),
  LocalizedText(
      chs: '无法获得', jpn: '召唤できない', eng: 'Unavailable', kor: '소환할 수 없음'),
  LocalizedText(chs: '期间限定', jpn: '期間限定', eng: 'Limited', kor: '기간한정'),
  LocalizedText(chs: '通关报酬', jpn: 'クリア報酬', eng: 'Reward', kor: '클리어 보상'),
  LocalizedText(chs: '剧情限定', jpn: 'ストーリー限定', eng: 'Story', kor: '스토리 한정'),
  LocalizedText(chs: '圣晶石常驻', jpn: '恒常召唤', eng: 'Permanent', kor: '상시소환'),
  //
  LocalizedText(chs: '单体', jpn: '单体', eng: 'Single', kor: '대인'),
  LocalizedText(chs: '全体', jpn: '全体', eng: 'AoE', kor: '대군'),
  LocalizedText(chs: '辅助', jpn: '辅助', eng: 'Support', kor: '서포트'),
  //
  LocalizedText(chs: '天', jpn: '天', eng: 'Sky', kor: '천'),
  LocalizedText(chs: '地', jpn: '地', eng: 'Earth', kor: '지'),
  LocalizedText(chs: '人', jpn: '人', eng: 'Man', kor: '인'),
  LocalizedText(chs: '星', jpn: '星', eng: 'Star', kor: '별'),
  LocalizedText(chs: '兽', jpn: '獣', eng: 'Beast', kor: '짐승'),
  //
  LocalizedText(chs: '秩序', jpn: '秩序', eng: 'Lawful', kor: '질서'),
  LocalizedText(chs: '混沌', jpn: '混沌', eng: 'Chaotic', kor: '혼돈'),
  LocalizedText(chs: '中立', jpn: '中立', eng: 'Neutral', kor: '중립'),
  LocalizedText(chs: '善', jpn: '善', eng: 'Good', kor: '선'),
  LocalizedText(chs: '恶', jpn: '悪', eng: 'Evil', kor: '악'),
  LocalizedText(chs: '中庸', jpn: '中庸', eng: 'Balanced', kor: '중용'),
  LocalizedText(chs: '新娘', jpn: '花嫁', eng: 'Bride', kor: '신부'),
  LocalizedText(chs: '狂', jpn: '狂', eng: 'Mad', kor: '광'),
  LocalizedText(chs: '夏', jpn: '夏', eng: 'Summer', kor: '여름'),
  //

  LocalizedText(chs: '龙', jpn: '龍', eng: 'Dragon', kor: '용'),
  LocalizedText(chs: '骑乘', jpn: '騎乗', eng: 'Riding', kor: '기승'),
  LocalizedText(chs: '神性', jpn: '神性', eng: 'Divine', kor: '신성'),
  LocalizedText(chs: '猛兽', jpn: '猛獸', eng: 'Wild Beast', kor: '맹수'),
  LocalizedText(chs: '王', jpn: '王', eng: 'King', kor: '왕'),
  LocalizedText(chs: '罗马', jpn: 'ローマ', eng: 'Roman', kor: '로마'),
  LocalizedText(chs: '亚瑟', jpn: 'アーサー', eng: 'Arthur', kor: '아서'),
  LocalizedText(
      chs: '阿尔托莉雅脸', jpn: 'アルトリア顔', eng: 'Altria Face', kor: '알트리아 얼굴'),
  LocalizedText(chs: '呆毛脸', jpn: 'アルトリア顔', eng: 'Altria Face', kor: '알트리아 얼굴'),
  LocalizedText(
      chs: 'EA不特攻', jpn: '', eng: 'NOT Weak to Enuma Elish', kor: '특별한 별'),
  LocalizedText(
      chs: '所爱之人', jpn: '愛する者', eng: 'Brynhildr\'s Beloved', kor: '사랑하는 자'),
  LocalizedText(
      chs: '希腊神话系男性',
      jpn: 'ギリシャ神話系男性',
      eng: 'Greek Mythology Males',
      kor: '그리스 신화계 남성'),
  LocalizedText(
      chs: '人类的威胁', jpn: '人類の脅威', eng: 'Threat to Humanity', kor: '인류의 위협'),
  LocalizedText(
      chs: '阿耳戈船相关人员',
      jpn: 'アルゴー号ゆかりの者',
      eng: 'Argo-Related',
      kor: '아르고 호 관계자'),
  LocalizedText(chs: '魔性', jpn: '魔性', eng: 'Demonic', kor: '마성'),
  LocalizedText(chs: '超巨大', jpn: '超巨大', eng: 'Super Large', kor: '초거대'),
  LocalizedText(chs: '天地从者', jpn: '', eng: 'Earth or Sky', kor: '천 혹은 지속성'),
  LocalizedText(
      chs: '天地(拟似除外)',
      jpn: '天または地の力を持つサーヴァント',
      eng: 'Earth or Sky',
      kor: '천 혹은 지속성 서번트'),
  LocalizedText(chs: '人型', jpn: '人型', eng: 'Humanoid', kor: '인간형'),
  LocalizedText(chs: '人科', jpn: 'ヒト科', eng: 'Hominidae Servant', kor: '사람과'),
  LocalizedText(
      chs: '魔兽型', jpn: '魔獣型', eng: 'Demonic Beast Servant', kor: '마수형'),
  LocalizedText(
      chs: '活在当下的人类', jpn: '', eng: 'Living Human', kor: '지금을 살아가는 인류'),
  LocalizedText(chs: '巨人', jpn: '', eng: 'Giant', kor: '거인'),
  LocalizedText(chs: '孩童从者', jpn: '', eng: 'Children Servants', kor: '어린이'),
  LocalizedText(
      chs: '领域外生命',
      jpn: '',
      eng: 'Existence Outside the Domain',
      kor: '영역 외의 생명'),
  LocalizedText(chs: '鬼', jpn: '鬼', eng: 'Oni', kor: '오니'),
  LocalizedText(chs: '源氏', jpn: '', eng: 'Genji', kor: '겐지'),
  LocalizedText(
      chs: '持有灵衣者', jpn: '霊衣を持つ者', eng: 'Costume-Owning', kor: '영의를 가진 자'),
  LocalizedText(chs: '机械', jpn: '機械', eng: 'Mechanical', kor: '기계'),
  LocalizedText(chs: '妖精', jpn: '妖精', eng: 'Fairy', kor: '요정'),
  LocalizedText(
      chs: '圆桌骑士', jpn: '円卓の騎士', eng: 'Round Table Knight', kor: '원탁의 기사'),
  LocalizedText(
      chs: '童话特性从者', jpn: '童話特性のサーヴァント', eng: 'Fairy Tale Servant', kor: '동화'),
  LocalizedText(chs: '神灵', jpn: '神霊', eng: 'Divine Spirit', kor: '신령'),

  LocalizedText(chs: '伊莉雅', jpn: 'イリヤ', eng: 'Illya', kor: '이리야'),
  LocalizedText(chs: '织田信长', jpn: '', eng: 'Nobunaga', kor: '노부나가'),
  LocalizedText(chs: '酒吞童子', jpn: '', eng: 'Shuten Dōji ', kor: '슈텐도지'),
  LocalizedText(
      chs: '拟似从者和半从者',
      jpn: '擬似サーヴァント、デミ・サーヴァント',
      eng: 'Pseudo-Servants and Demi-Servants',
      kor: '의사서번트, 데미서번트'),
  // Localized(chs: '死灵和恶魔', jpn: '死霊と悪魔', eng: 'Undead & Daemon', kor: ''),

  // Enemy filter
  LocalizedText(chs: '人类', jpn: '人間', eng: 'Human', kor: '인간'),
  LocalizedText(chs: '女性', jpn: '', eng: 'Gender:Female', kor: '여성'),
  LocalizedText(chs: '男性', jpn: '', eng: 'Gender:Male', kor: '남성'),
  LocalizedText(chs: '野兽', jpn: '', eng: 'Beast', kor: '맹수'),
  LocalizedText(chs: '恶魔', jpn: '', eng: 'Demon', kor: '악마'),
  LocalizedText(chs: '死灵', jpn: '', eng: 'Undead', kor: '사령'),
]);
