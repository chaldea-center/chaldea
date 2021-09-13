import 'package:chaldea/components/datatypes/datatypes.dart';

import 'func_buff_type_base.dart';

class BuffType extends FuncBuffTypeBase<NiceBuff> {
  static final Map<String, BuffType> all = {};

  BuffType._(
      int index, String type, String nameCn, String nameJp, String nameEn,
      [bool Function(NiceBuff)? test])
      : super(false, index, type, nameCn, nameJp, nameEn, test) {
    FuncBuffTypeBase? _one = all[type];
    if (_one != null) {
      assert(_one.index == index &&
          _one.type == type &&
          _one.nameCn == nameCn &&
          _one.nameJp == nameJp &&
          _one.nameEn == nameEn &&
          _one.test == test);
    }
    all[type] = this;
  }
}

class _BuffTypes {
  static _BuffTypes? _instance;

  _BuffTypes._();

  factory _BuffTypes._singleton() => _instance ?? _BuffTypes._();

  Map<String, BuffType> get all => BuffType.all;

  // BuffType upCommandatk = BuffType._(1, 'upCommandatk', '', 'Quickアップ<攻撃力>', '');
  // BuffType upCommandatk = BuffType._(1, 'upCommandatk', '', 'Artsアップ<攻撃力>', '');
  // BuffType upCommandatk = BuffType._(1, 'upCommandatk', '', 'Busterアップ<攻撃力>', '');
  // BuffType upCommandatk = BuffType._(1, 'upCommandatk', '', 'Extra威力アップ', '');
  BuffType upStarweight =
      BuffType._(2, 'upStarweight', '暴击星集中度提升', 'スター集中アップ', '');
  BuffType upCriticalpoint =
      BuffType._(3, 'upCriticalpoint', '暴击星掉落率提升', 'スター発生アップ', '');
  BuffType downCriticalpoint =
  BuffType._(4, 'downCriticalpoint', '暴击星掉落率降低', 'スター発生ダウン', '');
  BuffType regainNp = BuffType._(5, 'regainNp', '每回合NP获得', '毎ターンNP獲得', '');
  BuffType regainStar =
  BuffType._(6, 'regainStar', '每回合暴击星获得', '毎ターンスター獲得', '');
  BuffType regainHp = BuffType._(7, 'regainHp', '每回合HP回复', '毎ターンHP回復', '');
  BuffType reduceHp = BuffType._(8, 'reduceHp', '减少HP(灼/咒/毒)', 'やけど/呪い/毒', '');
  BuffType upAtk = BuffType._(9, 'upAtk', '攻击力提升', '攻撃力アップ', '');
  BuffType downAtk = BuffType._(10, 'downAtk', '攻击力降低', '攻撃力ダウン', '');
  BuffType upDamage = BuffType._(11, 'upDamage', '威力提升', '威力アップ', '');
  BuffType addDamage = BuffType._(13, 'addDamage', '附加伤害', 'ダメージプラス', '');
  BuffType upNpdamage = BuffType._(15, 'upNpdamage', '宝具威力提升', '宝具威力アップ', '');
  BuffType downNpdamage =
  BuffType._(16, 'downNpdamage', '宝具威力降低', '宝具威力ダウン', '');
  BuffType upDropnp = BuffType._(17, 'upDropnp', 'NP获得率增加', 'NP獲得アップ', '');
  BuffType upCriticaldamage =
  BuffType._(18, 'upCriticaldamage', '暴击威力提升', 'クリティカル威力アップ', '');
  BuffType downCriticaldamage =
  BuffType._(19, 'downCriticaldamage', '暴击威力降低', 'クリティカル威力ダウン', '');
  BuffType addSelfdamage =
  BuffType._(22, 'addSelfdamage', '自身被伤害增加', '被ダメージアップ', '');
  BuffType subSelfdamage =
  BuffType._(23, 'subSelfdamage', '自身被伤害降低', '被ダメージカット', '');
  BuffType avoidance = BuffType._(24, 'avoidance', '回避', '回避', ''); //確率で回避
  BuffType breakAvoidance = BuffType._(25, 'breakAvoidance', '必中', '必中', '');
  BuffType invincible = BuffType._(26, 'invincible', '无敌', '無敵', '');
  BuffType upGrantstate =
  BuffType._(27, 'upGrantstate', '状态赋予成功率提升', '状態付与アップ', '');
  BuffType upTolerance = BuffType._(29, 'upTolerance', '耐性提升', '耐性アップ', '');
  BuffType downTolerance = BuffType._(30, 'downTolerance', '耐性降低', '耐性ダウン', '');
  BuffType avoidState = BuffType._(31, 'avoidState', '状态赋予无效', '状態付与無効', '');
  BuffType donotAct = BuffType._(32, 'donotAct', '行动不能', '行動不能', '');
  BuffType donotSkill = BuffType._(33, 'donotSkill', '技能封印', 'スキル封印', '');
  BuffType donotNoble = BuffType._(34, 'donotNoble', '宝具封印', '宝具封印', '');
  BuffType guts = BuffType._(37, 'guts', '毅力', 'ガッツ', '');
  BuffType upHate = BuffType._(38, 'upHate', '目标集中度提升', 'タゲ集中アップ', '');
  BuffType addIndividuality =
  BuffType._(40, 'addIndividuality', '赋予特性', '特性付与', '');
  BuffType upDefence = BuffType._(42, 'upDefence', '防御力提升', '防御力アップ', '');
  BuffType downDefence = BuffType._(43, 'downDefence', '防御力降低', '防御力ダウン', '');
  BuffType upCommandall = BuffType._(52, 'upCommandall', '指令卡性能提升', 'カード性能アップ',
      ''); // Arts, Quick, Buster, Extra
  // BuffType upCommandallArts = BuffType._(-5201, 'upCommandall',
  //     'Arts指令卡性能提升', 'Artsカード性能アップ', ''); // Arts, Quick, Buster, Extra
  // BuffType upCommandallQuick = BuffType._(-5202, 'upCommandall',
  //     'Quick指令卡性能提升', 'Quickカード性能アップ', ''); // Arts, Quick, Buster, Extra
  // BuffType upCommandallBuster = BuffType._(-5203, 'upCommandall',
  //     'Buster指令卡性能提升', 'Busterカード性能アップ', ''); // Arts, Quick, Buster, Extra
  BuffType downCommandall =
  BuffType._(60, 'downCommandall', '指令卡性能降低', 'カード性能ダウン', '');
  BuffType downStarweight =
  BuffType._(61, 'downStarweight', '暴击星集中度降低', 'スター集中ダウン', '');
  BuffType downDropnp = BuffType._(63, 'downDropnp', 'NP获得率降低', 'NP獲得ダウン', '');
  BuffType upGainHp = BuffType._(64, 'upGainHp', 'HP回复量提升', 'HP回復量アップ', '');
  BuffType downGainHp = BuffType._(65, 'downGainHp', 'HP回复量降低', 'HP回復量ダウン', '');
  BuffType pierceInvincible =
  BuffType._(72, 'pierceInvincible', '无敌贯通', '無敵貫通', '');
  BuffType avoidInstantdeath =
  BuffType._(73, 'avoidInstantdeath', '即死无效', '即死無効', '');
  BuffType upResistInstantdeath =
  BuffType._(74, 'upResistInstantdeath', '即死耐性提升', '即死耐性アップ', '');
  BuffType upNonresistInstantdeath =
  BuffType._(75, 'upNonresistInstantdeath', '即死耐性降低', '即死耐性ダウン', '');
  BuffType delayFunction = BuffType._(76, 'delayFunction', '延迟发动', '遅延発動', '');
  BuffType deadFunction = BuffType._(78, 'deadFunction', '死亡时发动', '死亡時発動', '');
  BuffType addMaxhp = BuffType._(81, 'addMaxhp', '最大HP提升', '最大HPプラス', '');
  BuffType subMaxhp = BuffType._(82, 'subMaxhp', '最大HP降低', '最大HPマイナス', '');
  BuffType selfturnendFunction =
  BuffType._(85, 'selfturnendFunction', '每回合发动', '毎ターン発動', '');
  BuffType damageFunction =
  BuffType._(86, 'damageFunction', '被攻击时发动', '被ダメージ時発動', '');
  BuffType upGivegainHp =
  BuffType._(87, 'upGivegainHp', '提供的HP回复量提升', '与HP回復量アップ', '');
  BuffType commandattackFunction =
  BuffType._(89, 'commandattackFunction', '攻击时发动', '攻撃時発動', '');
  BuffType upDamagedropnp =
  BuffType._(93, 'upDamagedropnp', '受到伤害时NP获得量提升', '被ダメージ時NP獲得アップ', '');
  BuffType entryFunction =
  BuffType._(95, 'entryFunction', '登场时发动', '登場時発動', 'Skills on entry');
  BuffType upChagetd =
  BuffType._(96, 'upChagetd', 'OC阶段提升', 'オーバーチャージ段階UP', '');

  // BuffType reflectionFunction = BuffType._(97, 'reflectionFunction', '', '被ダメージ反射', '');//小安
  BuffType upToleranceSubstate =
  BuffType._(100, 'upToleranceSubstate', '强化解除耐性提升', '強化解除耐性アップ', '');
  BuffType upGrantInstantdeath =
  BuffType._(102, 'upGrantInstantdeath', '即死付与成功率提升', '即死付与率アップ', '');
  BuffType gutsRatio = BuffType._(104, 'gutsRatio', '毅力(%)', 'ガッツ(%)', '');
  BuffType downDefencecommandall =
  BuffType._(106, 'downDefencecommandall', '指令卡耐性降低', 'カード耐性ダウン', '');
  BuffType upDamageIndividualityActiveonly =
  BuffType._(112, 'upDamageIndividualityActiveonly', '威力提升', '威力アップ', '');
  BuffType multiattack =
  BuffType._(116, 'multiattack', 'Hit数增加', 'ヒット数アップ', '');
  BuffType pierceDefence = BuffType._(121, 'pierceDefence', '无视防御', '防御無視', '');
  BuffType upFuncHpReduce =
  BuffType._(126, 'upFuncHpReduce', '呪厄/延焼/蝕毒', '呪厄/延焼/蝕毒', '');

  // BuffType npattackPrevBuff = BuffType._(130, 'npattackPrevBuff', '', '雅号・異星蛸', '');
  // BuffType fixCommandcard = BuffType._(131, 'fixCommandcard', '', 'コマンドカード固定', '');
  BuffType fieldIndividuality =
  BuffType._(133, 'fieldIndividuality', '场地特性赋予', 'フィールドセット', '');

  // BuffType upDamageEventPoint = BuffType._(135, 'upDamageEventPoint', '', 'Arts攻撃の威力アップ', '');
  BuffType attackFunction =
  BuffType._(137, 'attackFunction', '攻击时追加效果', '攻撃時追加効果', '');
  BuffType commandcodeattackFunction = BuffType._(
      138, 'commandcodeattackFunction', '指令纹章攻击时追加效果', 'コマンドコード攻撃時追加効果', '');

  // BuffType donotSelectCommandcard = BuffType._(140, 'donotSelectCommandcard', '', '', '');
  BuffType tdTypeChange =
  BuffType._(143, 'tdTypeChange', '宝具类型切换', '宝具タイプチェンジ', '');
  BuffType overwriteClassRelation =
  BuffType._(144, 'overwriteClassRelation', '职阶相性变更', 'クラス相性変更', '');
  BuffType commandattackBeforeFunction = BuffType._(
      148, 'commandattackBeforeFunction', '造成伤害前追加效果', '攻撃ダメージ前追加効果', '');
  BuffType gutsFunction =
  BuffType._(149, 'gutsFunction', '毅力触发时发动', 'ガッツ時発動', '');
  BuffType downCriticalRateDamageTaken = BuffType._(
      151, 'downCriticalRateDamageTaken', '被暴击发生耐性提升', '被クリティカル発生耐性アップ', '');
  BuffType changeCommandCardType =
      BuffType._(156, 'changeCommandCardType', '指令卡类型变更', 'コマンドカードタイプチェンジ', '');
  BuffType specialInvincible =
      BuffType._(157, 'specialInvincible', '对肃正防御', '対粛正防御', '');
  BuffType buffRate =
      BuffType._(162, 'buffRate', '宝具威力提升增大', '宝具威力アップブースト', '');
}

// ignore: non_constant_identifier_names
final BuffTypes = _BuffTypes._singleton();
