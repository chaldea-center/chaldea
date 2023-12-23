import 'package:chaldea/models/models.dart';
import 'package:chaldea/packages/language.dart';
import 'package:chaldea/utils/utils.dart';

class McConverter {
  List<String> errors = [];
  String result = '';

  void checkLanguageError() {
    final e = getLanguageError();
    if (e.isNotEmpty) errors.add(e);
  }

  String getLanguageError() {
    List<String> _errors = [];
    if (!Language.isCHS) {
      _errors.add('App语言需设置为 简体中文');
    }
    final langs = Transl.preferRegions;
    if (!(langs.length >= 3 &&
        langs.first == Region.cn &&
        (langs[1] == Region.jp || (langs[1] == Region.tw && langs[2] == Region.jp)))) {
      _errors.add('首选翻译 需设置为: 1国服 2日服. 当前: ${langs.map((e) => e.localName).join("-")}');
    }
    if (_errors.isEmpty) return '';
    return '应用设置不符合要求:\n${_errors.map((e) => "* $e").join('\n')}\n';
  }

  String getLocalTime(int timestamp, int tz) {
    final utc = DateTime.fromMillisecondsSinceEpoch(timestamp * 1000, isUtc: true);
    final jst = utc.add(Duration(hours: tz));
    String pad(int v) => v.toString().padLeft(2, '0');
    return '${jst.year}-${pad(jst.month)}-${pad(jst.day)} ${pad(jst.hour)}:${pad(jst.minute)}';
  }

  String getJpTime(int timestamp) => getLocalTime(timestamp, 9);

  String getCnTime(int timestamp) => getLocalTime(timestamp, 8);

  static final kNormAlphabet = <String, String>{
    for (int index = 0; index < 26; index++) String.fromCharCode(0xff21 + index): String.fromCharCode(65 + index),
  };

  String normAlphaBet(String s) {
    for (final k in kNormAlphabet.keys) {
      s = s.replaceAll(k, kNormAlphabet[k]!);
    }
    return s;
  }

  static const kCnNums = ['零', '一', '二', '三', '四', '五', '六', '七', '八', '九', '十'];
  String getZhNum(int n) {
    assert(n >= 0 && n <= 10, n);
    return kCnNums.getOrNull(n) ?? n.toString();
  }

  String getWikiDaoju(int itemId, {int setNum = 1, String size = ''}) {
    if (itemId == Items.grailToCrystalId) {
      return '{{道具|圣杯传承结晶}}';
    }
    final item = db.gameData.items[itemId];
    if (item != null) {
      String text = '{{道具|${item.lName.maybeOf(Region.cn) ?? item.name}';
      if (setNum != 1 || size.isNotEmpty) {
        if (setNum != 1) {
          if (itemId == Items.qpId) {
            text += '|${setNum.format()}';
          } else {
            text += '|$setNum';
          }
        }
        if (size.isNotEmpty) text += '|$size';
      }
      text += '}}';
      return text;
    }

    final ce = db.gameData.craftEssencesById[itemId];
    if (ce != null) {
      return '{{礼装小图标|${ce.extra.mcLink ?? ce.lName.l}}}';
    }
    final svt = db.gameData.entities[itemId];
    if (svt != null) {
      if (svt.type == SvtType.combineMaterial) {
        String text = '{{道具|${svt.lName.l}';
        if (svt.className != SvtClass.ALL) {
          text += '(${getSvtClass(svt.classId)})';
        }
        text += '}}';
        return text;
      } else if (svt.type == SvtType.statusUp) {
        return '{{道具|${svt.lName.l}}}';
      } else if (svt.type == SvtType.svtMaterialTd) {
        final baseSvt = db.gameData.servantsById[svt.id ~/ 10 * 10];
        return '{{从者小图标|${baseSvt?.extra.mcLink ?? svt.lName.l}}}（宝具强化专用）';
      } else if (svt.type == SvtType.normal && svt.collectionNo > 0) {
        final baseSvt = db.gameData.servantsById[svt.id];
        return '{{从者小图标|${baseSvt?.extra.mcLink ?? svt.lName.l}}}';
      }
    }
    final cc = db.gameData.commandCodesById[itemId];
    if (cc != null) {
      return '{{纹章小图标|${cc.extra.mcLink ?? cc.lName.l}}}';
    }
    errors.add('无法解析ID为$itemId的素材');
    return '{{道具|$itemId}}';
  }

  static const kSvtClassNames = {
    SvtClass.saber: "剑",
    SvtClass.archer: "弓",
    SvtClass.lancer: "枪",
    SvtClass.rider: "骑",
    SvtClass.caster: "术",
    SvtClass.assassin: "杀",
    SvtClass.berserker: "狂",
    SvtClass.shielder: "盾",
    SvtClass.ruler: "裁",
    SvtClass.avenger: "仇",
    SvtClass.alterEgo: "他",
    SvtClass.moonCancer: "月",
    SvtClass.foreigner: "降",
    SvtClass.pretender: "披",
  };

  String getSvtClass(int classId) {
    return kSvtClassNames[kSvtClassIds[classId]] ?? Transl.svtClassId(classId).l;
  }
}
