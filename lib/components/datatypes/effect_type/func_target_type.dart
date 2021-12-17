import 'package:chaldea/components/localized/localized.dart';

class FuncTargetType {
  static const String self = 'self';
  static const String enemy = 'enemy';
  static const String enemyAll = 'enemyAll';
  static const String ptOne = 'ptOne';
  static const String ptAll = 'ptAll';
  static const String ptOther = 'ptOther';
  static const String ptFull = 'ptFull';
  static const String ptOtherFull = 'ptOtherFull';
  static const String otherTypes = 'otherTypes';

  static List<String> allTypes = [
    self,
    enemy,
    enemyAll,
    ptOne,
    ptAll,
    ptOther,
    ptFull,
    ptOtherFull,
    otherTypes,
  ];

  static String getType(String key) {
    if (allTypes.contains(key)) return key;
    return otherTypes;
  }

  static String localizedOf(String key) {
    return localizedMap[key]?.localized ?? key;
  }

  static Map<String, LocalizedText> get localizedMap => const {
        FuncTargetType.self:
            LocalizedText(chs: '自身', jpn: '自身', eng: 'Self', kor: '자신'),
        FuncTargetType.enemy: LocalizedText(
            chs: '敌方单体', jpn: '敵単体', eng: 'Single Enemy', kor: '적 한 명'),
        FuncTargetType.enemyAll: LocalizedText(
            chs: '敌方全体', jpn: '敵全体', eng: 'All Enemies', kor: '적 전체'),
        FuncTargetType.ptOne: LocalizedText(
            chs: '己方单体', jpn: '味方単体', eng: 'One Ally', kor: '아군 한 명'),
        FuncTargetType.ptAll: LocalizedText(
            chs: '己方全体', jpn: '味方全体', eng: 'All Allies', kor: '아군 전체'),
        FuncTargetType.ptOther: LocalizedText(
            chs: '除自身以外的己方全体',
            jpn: '自身を除く味方全体',
            eng: 'All Allies except Self',
            kor: '자신을 제외한 아군 전체'),
        FuncTargetType.ptFull: LocalizedText(
            chs: '己方全体<包括替补>',
            jpn: '味方全体<控え含む>',
            eng: 'All Allies <including sub-members>',
            kor: '아군 전체<후열포함>'),
        FuncTargetType.ptOtherFull: LocalizedText(
            chs: '除自身以外的己方全体<包括替补>',
            jpn: '自身を除く味方全体<控え含む>',
            eng: 'All Allies except Self <including sub-members>',
            kor: '자신을 제외한 아군 전체<후열 포함>'),
        FuncTargetType.otherTypes: LocalizedText(
          chs: '其他类型',
          jpn: '他のタイプ',
          eng: 'Other Types',
          kor: '그 외 타입',
        ),
      };
}
