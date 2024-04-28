import 'dart:convert';

import 'package:html/dom.dart' as htmldom;
import 'package:html/parser.dart' as htmlparser;

import 'package:chaldea/app/api/chaldea.dart';
import 'package:chaldea/models/models.dart';
import 'package:chaldea/packages/logger.dart';
import 'package:chaldea/utils/utils.dart';
import 'converter.dart';

class GachaProbData {
  final NiceGacha gacha;
  String htmlText = "";
  List<GachaProbRow> groups = [];

  GachaProbData(this.gacha, this.htmlText, this.groups);

  bool get isInvalid => htmlText.isEmpty || groups.isEmpty;

  List<String> tableHeaders = ["type", "star", "weight", "display", "ids"];

  double getTotalProb() => Maths.sum(groups.map((e) => e.getTotalProb()));
  double guessTotalProb() => Maths.sum(groups.map((e) => e.guessTotalProb()));

  String toOutput() {
    List<List<String>> outputs = [tableHeaders.toList()];
    for (final group in groups) {
      outputs.add(group.toRow());
    }

    final output = outputs.map((e) => e.join('\t')).join('\n');
    return output;
  }

  LimitedSummon toSummon() {
    return LimitedSummon(
      id: '0',
      name: gacha.lName.setMaxLines(1),
      officialBanner: MappingBase(jp: AssetURL.i.summonBanner(gacha.imageId)),
      type: gacha.isLuckyBag ? SummonType.gssr : SummonType.limited,
      subSummons: [
        SubSummon(title: gacha.name.setMaxLines(1), probs: [
          for (final group in groups)
            ProbGroup(
              isSvt: group.isSvt,
              rarity: group.rarity,
              weight: group.guessTotalProb(),
              display: group.pickup,
              ids: group.ids,
            ),
        ])
      ],
    );
  }

  String getShownHtml() {
    String text = htmlText.trim().replaceFirst(RegExp(r'\n<head>[\S\s]*\n</head>'), '\n<head>removed</head>');
    final lines = const LineSplitter().convert(text);
    lines.removeWhere((line) => line.trim().isEmpty);
    return lines
        .map((e) => e.replaceFirstMapped(RegExp(r'^\s+'), (match) {
              final spaces = match.group(0)!;
              return ' ' * (spaces.length ~/ 4);
            }))
        .join('\n');
  }
}

class GachaProbRow {
  final bool isSvt;
  final bool pickup;
  final int rarity;
  final String indivProb;
  final List<GameCardMixin> cards;
  final bool isLuckyBag;

  GachaProbRow({
    required this.isSvt,
    required this.pickup,
    required this.rarity,
    required this.indivProb,
    required this.cards,
    required this.isLuckyBag,
  });

  // bool get display => !isLuckyBag && cards.length <= 3;

  List<int> get ids => cards.map((e) => e.collectionNo).toList()..sort();

  double getTotalProb() {
    assert(indivProb.endsWith('%'), indivProb);
    return double.parse(indivProb.substring(0, indivProb.length - 1)) * cards.length;
  }

  double guessTotalProb() {
    double v = (getTotalProb() * 10).round() / 10;
    if (isSvt && rarity == 4 && cards.length > 40 && v == 0.8) {
      v = 0.9;
    }
    return double.parse(v.toString());
  }

  List<String> toRow() {
    return [
      isSvt ? 'svt' : 'ce',
      rarity.toString(),
      formatProb(getTotalProb()),
      pickup ? '1' : '0',
      ids.join(', '),
    ];
  }

  String formatProb(double v) {
    final s = guessTotalProb().toString();
    if (s.endsWith('.0')) {
      return s.substring(0, s.length - 2);
    }
    return s;
  }
}

class JpGachaNotice {
  final String link;
  final String title;
  final String lastUpdate;
  final String? topBanner;

  JpGachaNotice({
    required this.link,
    required this.title,
    required this.lastUpdate,
    required this.topBanner,
  });
}

class JpGachaParser {
  static const String kStar = '★';

  Future<List<GachaProbData>> parseMultiple(List<NiceGacha> gachas) async {
    final futures = gachas.map((gacha) async {
      try {
        return await parseProb(gacha);
      } catch (e, s) {
        logger.e('parse gacha prob failed', e, s);
        return GachaProbData(gacha, '', []);
      }
    }).toList();
    final allData = await Future.wait(futures);
    allData.sort2((e) => e.gacha.openedAt);
    return allData;
  }

  Future<GachaProbData> parseProb(NiceGacha gacha) async {
    final data = GachaProbData(gacha, '', []);
    final url = gacha.getHtmlUrl(Region.jp);
    if (url == null) return data;
    final text = await CachedApi.cacheManager.getText(url);
    if (text == null) return data;

    final doc = htmlparser.parse(text);
    final tableCount = text.split("<table").length - 1;
    List<(bool pickup, List<List<String>> table)> svtTables, ceTables;
    if (tableCount == 4) {
      // svt_class, rarity, name, prob
      svtTables = [(false, _getProbTable(doc, 2, 4))];
      // rarity, name, prob
      ceTables = [(false, _getProbTable(doc, 3, 3))];
    } else if (tableCount == 6) {
      // 1, svt, ce, svt, ce, 6
      svtTables = [(true, _getProbTable(doc, 2, 4)), (false, _getProbTable(doc, 4, 4))];
      ceTables = [(true, _getProbTable(doc, 3, 3)), (false, _getProbTable(doc, 5, 3))];
    } else if (tableCount == 5) {
      const svtTitle = '■ピックアップサーヴァント一覧', ceTitle = '■ピックアップ概念礼装';
      if (text.contains(svtTitle) && !text.contains(ceTitle)) {
        // 1, svt, svt, ce, 5
        svtTables = [(true, _getProbTable(doc, 2, 4)), (false, _getProbTable(doc, 3, 4))];
        ceTables = [(false, _getProbTable(doc, 4, 3))];
      } else if (!text.contains(svtTitle) && text.contains(ceTitle)) {
        // 1, ce, svt, ce, 5
        svtTables = [(false, _getProbTable(doc, 3, 4))];
        ceTables = [(true, _getProbTable(doc, 2, 3)), (false, _getProbTable(doc, 4, 3))];
      } else {
        throw FormatException('Unexpected table count(5): $tableCount');
      }
    } else {
      throw FormatException('Unexpected table count: $tableCount');
    }

    final classMap = {
      for (final v in ConstData.classInfo.values)
        if (v.supportGroup < 20) v.name: v.id,
    };

    Map<String, GachaProbRow> groupMap = {};

    for (final (pickup, table) in svtTables) {
      for (final row in table) {
        final int classId = classMap[row[0]]!;
        final int rarity = row[1].count(kStar);
        final String name = row[2];
        final String probStr = row[3];
        final svt = _findCard(name, rarity, classId);
        final key = 'svt-$pickup-$rarity-$probStr';
        final group = groupMap[key] ??= GachaProbRow(
            isSvt: true, pickup: pickup, rarity: rarity, indivProb: probStr, cards: [], isLuckyBag: gacha.isLuckyBag);
        group.cards.add(svt);
      }
    }
    for (final (pickup, table) in ceTables) {
      for (final row in table) {
        final int rarity = row[0].count(kStar);
        final ce = _findCard(row[1], rarity, 1001);
        final probStr = row[2];
        final key = 'ce-$pickup-$rarity-$probStr';
        final group = groupMap[key] ??= GachaProbRow(
            isSvt: false, pickup: pickup, rarity: rarity, indivProb: probStr, cards: [], isLuckyBag: gacha.isLuckyBag);
        group.cards.add(ce);
      }
    }

    final groups = groupMap.values.toList();
    groups.sortByList((e) => [e.isSvt ? 0 : 1, e.pickup ? 0 : 1, -e.rarity, e.cards.length]);

    return GachaProbData(gacha, text, groups);
  }

  List<List<String>> _getProbTable(htmldom.Document document, int tableIndex, int colCount) {
    List<List<String>> tableData = [];
    final table = document.getElementsByTagName('table')[tableIndex - 1];
    final trs = table.getElementsByTagName('tbody')[0].getElementsByTagName('tr');
    for (final tr in trs) {
      final tds = tr.getElementsByTagName('td');
      if (tds.isEmpty) continue;
      tableData.add(tds.map((e) => e.text.trim()).toList().sublist(0, colCount));
    }
    assert(tableData.isEmpty || tableData.map((e) => e.length).toSet().length == 1);
    return tableData;
  }

  BasicServant _findCard(String name, int rarity, int classId) {
    Map<int, BasicServant> targets = {};
    for (final card in db.gameData.entities.values) {
      if (card.collectionNo <= 0 || card.rarity != rarity || card.classId != classId) continue;

      final svt = db.gameData.servantsById[card.id];
      final names = <String?>{
        card.name,
        svt?.ascensionAdd.overWriteServantName.ascension[0],
        ...?svt?.svtChange.map((e) => e.name),
      }.whereType<String>().toList();

      if (names.contains(name)) {
        targets[card.id] = card;
      }
    }

    final className = Transl.svtClassId(classId).l;
    if (targets.length == 1) {
      return targets.values.single;
    } else if (targets.isNotEmpty) {
      throw FormatException('NotFound: $name-R$rarity-$className');
    } else {
      throw FormatException("Multiple Found: $name-R$rarity-$className: ${targets.keys.toList()}");
    }
  }

  Future<List<JpGachaNotice>> parseNotices() async {
    List<JpGachaNotice> notices = [];
    List<Future> futures = [];
    for (final baseUri in [Uri.parse('https://news.fate-go.jp/'), Uri.parse('https://news.fate-go.jp/page/2/')]) {
      final htmlText = await CachedApi.cacheManager.getText(baseUri.toString());
      if (htmlText == null) continue;

      final doc = htmlparser.parse(htmlText);
      final newsList = doc.getElementsByClassName('list_news')[0].getElementsByTagName('li');

      futures.addAll(newsList.map((node) async {
        try {
          final notice = await _parseNoticeNode(baseUri, node);
          if (notice != null) notices.add(notice);
        } catch (e, s) {
          logger.e('parse notice node failed', e, s);
        }
      }).toList());
    }
    await Future.wait(futures);

    notices.sort2((e) => e.lastUpdate, reversed: true);
    return notices;
  }

  Future<JpGachaNotice?> _parseNoticeNode(Uri baseUri, htmldom.Element node) async {
    if (node.children.length < 3) {
      return null;
    }
    String lastUpdate = node.children[0].text;

    final fullTitle = node.children[1].text;
    String? title = [r'「(.+召喚)」', r'『(.+召喚)』', r'「(.*福袋召喚.*)」！', r'『(.*福袋召喚.*)』！']
        .map((e) => RegExp(e).firstMatch(fullTitle)?.group(1))
        .firstWhereOrNull((e) => e != null);
    if (title == null) return null;

    String? link = node.children[2].attributes['href'];
    if (link == null) return null;
    link = baseUri.resolve(link).toString();

    String? topBanner;
    final noticeHtml = await CachedApi.cacheManager.getText(link);
    if (noticeHtml != null) {
      final detailDoc = htmlparser.parse(noticeHtml);
      final imgs = detailDoc.getElementsByClassName('article').firstOrNull?.getElementsByTagName('img') ?? [];
      for (final img in imgs) {
        final src = img.attributes['src'];
        if (src != null && RegExp(r'/wp-content/uploads/.*/top_banner.png').hasMatch(src)) {
          topBanner = baseUri.resolve(src).toString();
          break;
        }
      }
    }

    return JpGachaNotice(
      link: link,
      title: title,
      lastUpdate: lastUpdate,
      topBanner: topBanner,
    );
  }
}

class McGachaConverter extends McConverter {
  //
}
