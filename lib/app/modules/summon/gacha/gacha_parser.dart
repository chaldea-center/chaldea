import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart' show kIsWeb;

import 'package:html/dom.dart' as htmldom;
import 'package:html/parser.dart' as htmlparser;

import 'package:chaldea/app/api/chaldea.dart';
import 'package:chaldea/app/tools/icon_cache_manager.dart';
import 'package:chaldea/models/models.dart';
import 'package:chaldea/packages/logger.dart';
import 'package:chaldea/utils/utils.dart';

import '../../mc/converter.dart';

const int _kJpNoticePages = 4;

/// Table roles are identified by the section heading right before each table,
/// because newer banners reorder or omit tables while keeping the headings.
enum _GachaTableKind { summary, svtPickup, cePickup, svtPool, cePool, excluded, unknown }

const Map<String, _GachaTableKind> _kGachaSectionKinds = {
  '■ピックアップサーヴァント一覧': _GachaTableKind.svtPickup,
  '■ピックアップ概念礼装': _GachaTableKind.cePickup,
  '■サーヴァント一覧': _GachaTableKind.svtPool,
  '■概念礼装': _GachaTableKind.cePool,
  '■召喚対象外のサーヴァント': _GachaTableKind.excluded,
  '提供割合': _GachaTableKind.summary,
};

enum GachaCardWarningReason { notFound, multipleFound }

/// A card listed in the raw gacha HTML that could not be resolved to a game card.
class GachaCardWarning {
  final bool isSvt;
  final bool pickup;
  final int rarity;
  final String indivProb;
  final String name;
  final String className;
  final GachaCardWarningReason reason;

  const GachaCardWarning({
    required this.isSvt,
    required this.pickup,
    required this.rarity,
    required this.indivProb,
    required this.name,
    required this.className,
    required this.reason,
  });

  String get display => '$name($className ${JpGachaParser.kStar}$rarity)';
}

class GachaProbData {
  final NiceGacha gacha;
  String htmlText = "";
  List<GachaProbRow> groups = [];
  final List<GachaCardWarning> cardWarnings;

  /// Official per-rarity totals from the banner's "提供割合" table, in percent.
  final Map<(bool isSvt, int rarity), double> summaryProbs = {};

  GachaProbData(this.gacha, this.htmlText, this.groups, {this.cardWarnings = const []});

  bool get isInvalid => htmlText.isEmpty || groups.isEmpty;

  /// Group by reason and card type so a batch of similar failures occupies one line.
  List<String> get warningLines {
    final grouped = <String, List<GachaCardWarning>>{};
    for (final warning in cardWarnings) {
      final type = warning.isSvt ? '从者' : '概念礼装';
      final label = warning.reason == GachaCardWarningReason.notFound ? '未匹配$type' : '匹配不唯一$type';
      grouped.putIfAbsent(label, () => []).add(warning);
    }
    return [for (final entry in grouped.entries) '${entry.key}: ${entry.value.map((e) => e.display).join(', ')}'];
  }

  Iterable<GachaCardWarning> warningsOf(GachaProbRow group) sync* {
    for (final warning in cardWarnings) {
      if (warning.isSvt == group.isSvt &&
          warning.pickup == group.pickup &&
          warning.rarity == group.rarity &&
          warning.indivProb == group.indivProb) {
        yield warning;
      }
    }
  }

  List<String> tableHeaders = ["type", "star", "weight", "display", "ids"];

  double getTotalProb() => Maths.sum(groups.map((e) => e.getTotalProb()));
  double guessTotalProb() => Maths.sum(groups.map((e) => e.guessTotalProb()));

  String toOutput() {
    List<List<String>> outputs = [tableHeaders.toList()];
    for (final group in groups) {
      outputs.add(group.toRow(warningsOf(group).toList()));
    }

    final output = outputs.map((e) => e.join('\t')).join('\n');
    return output;
  }

  SubSummon toSubSummon() {
    return SubSummon(
      title: gacha.name.setMaxLines(1),
      banner: AssetURL.i.summonBanner(gacha.imageId),
      probs: [
        for (final group in groups)
          // Groups with no resolved ids would violate ProbGroup's non-empty contract.
          if (group.ids.isNotEmpty)
            ProbGroup(
              isSvt: group.isSvt,
              rarity: group.rarity,
              weight: group.guessTotalProb(),
              display: group.pickup,
              ids: group.ids,
            ),
      ],
    );
  }

  LimitedSummon toSummon() {
    return LimitedSummon(
      isFromWiki: false,
      id: gacha.id.toString(),
      name: gacha.lName.setMaxLines(1),
      officialBanner: MappingBase(jp: AssetURL.i.summonBanner(gacha.imageId)),
      type: gacha.isLuckyBag ? SummonType.gssr : SummonType.limited,
      subSummons: [toSubSummon()],
    );
  }

  String getShownHtml() {
    String text = htmlText.trim().replaceFirst(RegExp(r'\n<head>[\S\s]*\n</head>'), '\n<head>removed</head>');
    final lines = const LineSplitter().convert(text);
    lines.removeWhere((line) => line.trim().isEmpty);
    return lines
        .map(
          (e) => e.replaceFirstMapped(RegExp(r'^\s+'), (match) {
            final spaces = match.group(0)!;
            return ' ' * (spaces.length ~/ 4);
          }),
        )
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

  /// Declared row count in the HTML table. It differs from [cards] when some
  /// rows fail to resolve, and must drive probability math to stay accurate.
  int expectedCount = 0;

  /// Group total estimated from the banner's "提供割合" table. Per-card rates
  /// are truncated to 3 decimals, so their product underestimates the total.
  double? correctedTotal;

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
    return double.parse(indivProb.substring(0, indivProb.length - 1)) * expectedCount;
  }

  double guessTotalProb() {
    final source = correctedTotal ?? getTotalProb();
    double v = (source * 10).round() / 10;
    // Keep the legacy heuristic only when no summary total is available.
    if (correctedTotal == null && isSvt && rarity == 4 && expectedCount > 40 && v == 0.8) {
      v = 0.9;
    }
    return double.parse(v.toString());
  }

  List<String> toRow(List<GachaCardWarning> warnings) {
    return [
      isSvt ? 'svt' : 'ce',
      rarity.toString(),
      formatProb(getTotalProb()),
      pickup ? '1' : '0',
      [for (final id in ids) id.toString(), for (final warning in warnings) '${warning.name}<!--未匹配-->'].join(', '),
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
  final String? link;
  final String? title;
  final String? fullTitle;
  final String lastUpdate;
  final String? topBanner;

  JpGachaNotice({
    required this.link,
    required this.title,
    required this.fullTitle,
    required this.lastUpdate,
    required this.topBanner,
  });
}

class JpGachaParser {
  static const String kStar = '★';

  Future<List<GachaProbData>> parseMultiple(List<NiceGacha> gachas, {bool refresh = false}) async {
    final futures = gachas.map((gacha) async {
      try {
        return await parseProb(gacha, refresh: refresh);
      } catch (e, s) {
        logger.e('parse gacha prob failed', e, s);
        return GachaProbData(gacha, '', []);
      }
    }).toList();
    final allData = await Future.wait(futures);
    allData.sort2((e) => e.gacha.openedAt);
    return allData;
  }

  Future<String?> _getCachedText(String url, {required bool refresh}) async {
    if (refresh) {
      await AtlasIconLoader.i.deleteFromDisk(url);
    }
    final fp = await AtlasIconLoader.i.get(url);
    if (fp == null) return null;
    try {
      return await File(fp).readAsString();
    } catch (e, s) {
      logger.e('read cached gacha html failed', e, s);
      await AtlasIconLoader.i.deleteFromDisk(url);
      return null;
    }
  }

  Future<GachaProbData> parseProb(NiceGacha gacha, {bool refresh = false}) async {
    final data = GachaProbData(gacha, '', [], cardWarnings: []);
    final url = gacha.getHtmlUrl(Region.jp);
    if (url == null) return data;
    final text = kIsWeb
        ? await CachedApi.cacheManager.getText(url, expireAfter: refresh ? Duration.zero : null)
        : await _getCachedText(url, refresh: refresh);
    if (text == null) return data;

    final doc = htmlparser.parse(text);
    final tables = doc.getElementsByTagName('table');
    final tableOffsets = <int>[];
    var searchFrom = 0;
    for (var i = 0; i < tables.length; i++) {
      final offset = text.indexOf('<table', searchFrom);
      if (offset < 0) break;
      tableOffsets.add(offset);
      searchFrom = offset + '<table'.length;
    }
    if (tableOffsets.length != tables.length) {
      throw FormatException('Table offset mismatch: ${tables.length} tables, ${tableOffsets.length} offsets');
    }

    final svtTables = <(bool pickup, List<List<String>> table)>[];
    final ceTables = <(bool pickup, List<List<String>> table)>[];
    for (var i = 0; i < tables.length; i++) {
      final kind = _classifyTable(text, tableOffsets[i]);
      if (kind == _GachaTableKind.summary) {
        for (final row in _getProbTable(doc, i + 1, 4)) {
          final rarity = row[0].count(kStar);
          final svt = _parsePercent(row[1]), ce = _parsePercent(row[3]);
          if (svt != null) data.summaryProbs[(true, rarity)] = svt;
          if (ce != null) data.summaryProbs[(false, rarity)] = ce;
        }
      } else if (kind == _GachaTableKind.svtPickup || kind == _GachaTableKind.svtPool) {
        svtTables.add((kind == _GachaTableKind.svtPickup, _getProbTable(doc, i + 1, 4)));
      } else if (kind == _GachaTableKind.cePickup || kind == _GachaTableKind.cePool) {
        ceTables.add((kind == _GachaTableKind.cePickup, _getProbTable(doc, i + 1, 3)));
      }
    }
    if (svtTables.isEmpty && ceTables.isEmpty) {
      throw FormatException('No probability table found: ${tables.length} tables');
    }

    final classNameMap = <String, List<int>>{};
    for (final v in ConstData.classInfo.values) {
      if (v.supportGroup < 20) {
        classNameMap.putIfAbsent(v.name, () => []).add(v.id);
      }
    }

    Map<String, GachaProbRow> groupMap = {};

    for (final (pickup, table) in svtTables) {
      for (final row in table) {
        final List<int> classIds = classNameMap[row[0]]!;
        final int rarity = row[1].count(kStar);
        final String name = row[2];
        final String probStr = row[3];
        final key = 'svt-$pickup-$rarity-$probStr';
        final group = groupMap[key] ??= GachaProbRow(
          isSvt: true,
          pickup: pickup,
          rarity: rarity,
          indivProb: probStr,
          cards: [],
          isLuckyBag: gacha.isLuckyBag,
        );
        group.expectedCount += 1;
        final (svt, reason) = _findCard(name, rarity, classIds);
        if (svt != null) {
          group.cards.add(svt);
        } else {
          data.cardWarnings.add(
            GachaCardWarning(
              isSvt: true,
              pickup: pickup,
              rarity: rarity,
              indivProb: probStr,
              name: name,
              className: row[0],
              reason: reason!,
            ),
          );
        }
      }
    }
    for (final (pickup, table) in ceTables) {
      for (final row in table) {
        final int rarity = row[0].count(kStar);
        final String name = row[1];
        final String probStr = row[2];
        final key = 'ce-$pickup-$rarity-$probStr';
        final group = groupMap[key] ??= GachaProbRow(
          isSvt: false,
          pickup: pickup,
          rarity: rarity,
          indivProb: probStr,
          cards: [],
          isLuckyBag: gacha.isLuckyBag,
        );
        group.expectedCount += 1;
        final (ce, reason) = _findCard(name, rarity, [1001]);
        if (ce != null) {
          group.cards.add(ce);
        } else {
          data.cardWarnings.add(
            GachaCardWarning(
              isSvt: false,
              pickup: pickup,
              rarity: rarity,
              indivProb: probStr,
              name: name,
              className: '概念礼装',
              reason: reason!,
            ),
          );
        }
      }
    }

    final groups = groupMap.values.toList();
    _applySummaryCorrection(data, groups);
    groups.sortByList((e) => [e.isSvt ? 0 : 1, e.pickup ? 0 : 1, -e.rarity, e.expectedCount]);

    data.htmlText = text;
    data.groups = groups;
    return data;
  }

  /// Per-card rates are truncated, so distribute each rarity's official total
  /// to the non-pickup group. Pickup totals are clean values and stay untouched.
  void _applySummaryCorrection(GachaProbData data, List<GachaProbRow> groups) {
    if (data.summaryProbs.isEmpty) return;
    for (final entry in data.summaryProbs.entries) {
      final (isSvt, rarity) = entry.key;
      final target = entry.value;
      final keyGroups = groups.where((e) => e.isSvt == isSvt && e.rarity == rarity).toList();
      if (keyGroups.isEmpty) continue;
      final rawSum = keyGroups.fold<double>(0, (sum, e) => sum + e.getTotalProb());
      final residual = target - rawSum;
      // A larger gap means the table is not explained by truncation; keep raw values.
      if (residual.abs() > 0.2) continue;
      final poolGroups = keyGroups.where((e) => !e.pickup).toList();
      final targets = poolGroups.isNotEmpty ? poolGroups : keyGroups;
      final base = targets.fold<double>(0, (sum, e) => sum + e.getTotalProb());
      for (final group in targets) {
        final share = base > 0 ? residual * group.getTotalProb() / base : residual / targets.length;
        group.correctedTotal = group.getTotalProb() + share;
      }
    }
  }

  double? _parsePercent(String text) {
    final value = text.trim();
    if (!value.endsWith('%')) return null;
    return double.tryParse(value.substring(0, value.length - 1));
  }

  /// Resolves a table role from the nearest section heading before it.
  _GachaTableKind _classifyTable(String text, int tableOffset) {
    final start = tableOffset > 2000 ? tableOffset - 2000 : 0;
    final before = text.substring(start, tableOffset).replaceAll(RegExp(r'<[^>]+>'), '');
    var kind = _GachaTableKind.unknown;
    var lastIndex = -1;
    for (final entry in _kGachaSectionKinds.entries) {
      final index = before.lastIndexOf(entry.key);
      if (index > lastIndex) {
        lastIndex = index;
        kind = entry.value;
      }
    }
    return kind;
  }

  List<List<String>> _getProbTable(htmldom.Document document, int tableIndex, int colCount) {
    List<List<String>> tableData = [];
    final table = document.getElementsByTagName('table')[tableIndex - 1];
    final body = table.getElementsByTagName('tbody').firstOrNull ?? table;
    final trs = body.getElementsByTagName('tr');
    for (final tr in trs) {
      final tds = tr.getElementsByTagName('td');
      if (tds.isEmpty) continue;
      final cells = tds.map((e) => e.text.trim()).toList();
      if (cells.length < colCount) {
        throw FormatException('Unexpected columns: expected $colCount, got ${cells.length}');
      }
      tableData.add(cells.sublist(0, colCount));
    }
    assert(tableData.isEmpty || tableData.map((e) => e.length).toSet().length == 1);
    return tableData;
  }

  /// The raw HTML mixes halfwidth and fullwidth parentheses for alternate names,
  /// while the generated alias strings always use fullwidth ones.
  String _normalizeName(String name) => name.replaceAll('（', '(').replaceAll('）', ')').trim();

  (BasicServant?, GachaCardWarningReason?) _findCard(String name, int rarity, List<int> classIds) {
    Map<int, BasicServant> targets = {};
    final normalizedName = _normalizeName(name);
    for (final card in db.gameData.entities.values) {
      if (card.collectionNo <= 0 || card.rarity != rarity || !classIds.contains(card.classId)) continue;

      final svt = db.gameData.servantsById[card.id];
      final names = <String>{
        card.name,
        ?svt?.ascensionAdd.overWriteServantName.ascension[0],
        for (final change in svt?.svtChange ?? <ServantChange>[]) ...[change.name, '${card.name}（${change.name}）'],
      };

      if (names.any((e) => _normalizeName(e) == normalizedName)) {
        targets[card.id] = card;
      }
    }

    final className = Transl.svtClassId(classIds.first).l;
    if (targets.length == 1) {
      return (targets.values.single, null);
    } else if (targets.isEmpty) {
      logger.w('Gacha card not found: $name-R$rarity-$className');
      return (null, GachaCardWarningReason.notFound);
    } else {
      logger.w('Gacha card ambiguous: $name-R$rarity-$className: ${targets.keys.toList()}');
      return (null, GachaCardWarningReason.multipleFound);
    }
  }

  Future<List<JpGachaNotice>> parseNotices() async {
    List<JpGachaNotice> notices = [];
    List<Future> futures = [];
    for (final baseUri in [
      Uri.parse('https://news.fate-go.jp/'),
      for (final pageId in range(2, _kJpNoticePages + 1)) Uri.parse('https://news.fate-go.jp/page/$pageId/'),
    ]) {
      final htmlText = await CachedApi.cacheManager.getText(baseUri.toString());
      if (htmlText == null) continue;

      final doc = htmlparser.parse(htmlText);
      final newsList = doc.getElementsByClassName('list_news').firstOrNull?.getElementsByTagName('li') ?? [];

      futures.addAll(
        newsList.map((node) async {
          try {
            final notice = await _parseNoticeNode(baseUri, node);
            if (notice != null) notices.add(notice);
          } catch (e, s) {
            logger.e('parse notice node failed', e, s);
          }
        }).toList(),
      );
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
    if (!fullTitle.contains('召喚')) return null;
    String? title = [
      r'「(.+召喚)」',
      r'『(.+召喚)』',
      r'「(.*福袋召喚.*)」！',
      r'『(.*福袋召喚.*)』！',
    ].map((e) => RegExp(e).firstMatch(fullTitle)?.group(1)).firstWhereOrNull((e) => e != null);
    // if (title == null) return null;

    String? topBanner;
    String? link = node.children[2].attributes['href'];
    if (link != null) {
      link = baseUri.resolve(link).toString();
      String? noticeHtml = await CachedApi.cacheManager.getText(link);
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

    return JpGachaNotice(link: link, title: title, fullTitle: fullTitle, lastUpdate: lastUpdate, topBanner: topBanner);
  }
}

class McGachaConverter extends McConverter {
  //
}
