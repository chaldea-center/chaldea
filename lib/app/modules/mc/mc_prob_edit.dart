import 'dart:convert';

import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:html/dom.dart' as htmldom;
import 'package:html/parser.dart' as htmlparser;

import 'package:chaldea/app/api/chaldea.dart';
import 'package:chaldea/app/app.dart';
import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/models/gamedata/raw.dart';
import 'package:chaldea/models/models.dart';
import 'package:chaldea/packages/app_info.dart';
import 'package:chaldea/packages/logger.dart';
import 'package:chaldea/utils/utils.dart';
import 'package:chaldea/widgets/widgets.dart';
import '../summon/gacha/gacha_banner.dart';
import '../summon/summon_simulator_page.dart';

class MCGachaProbEditPage extends StatefulWidget {
  final MstGacha gacha;
  const MCGachaProbEditPage({super.key, required this.gacha});

  @override
  State<MCGachaProbEditPage> createState() => _MCGachaProbEditPageState();
}

class _MCGachaProbEditPageState extends State<MCGachaProbEditPage> {
  late final gacha = widget.gacha;
  late final url = gacha.getHtmlUrl(Region.jp);

  GachaParseResult? result;
  bool showIcon = false;

  @override
  void initState() {
    super.initState();
    parseHtml();
  }

  Future<void> parseHtml() async {
    if (url == null) return;
    final text = await showEasyLoading(() => CachedApi.cacheManager.getText(url!));
    if (text == null || text.isEmpty) {
      EasyLoading.showError(S.current.failed);
      return;
    }

    try {
      final parser = GachaParser();
      result = parser.parse(text, gacha);
    } catch (e, s) {
      if (mounted) {
        SimpleCancelOkDialog(
          title: Text(S.current.error),
          content: Text(e.toString()),
          scrollable: true,
          hideCancel: true,
        ).showDialog(context);
      }
      logger.e('parse prob failed', e, s);
    }
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(gacha.name.setMaxLines(1)),
        // actions: [
        //   IconButton(onPressed: parseHtml, icon: const Icon(Icons.search)),
        // ],
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
        children: [
          GachaBanner(imageId: gacha.imageId, region: Region.jp),
          Text(gacha.name, textAlign: TextAlign.center),
          if (url != null) TextButton(onPressed: () => launch(url!), child: Text(S.current.open_in_browser)),
          kDefaultDivider,
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: Text('[For Mooncell wiki Editor]\n'
                '检查并修改以下部分后再写入到“某某卡池/模拟器/data{X}”中: \n'
                '- 是否显示(1显示 0不显示)\n'
                '- 各行总概率是否正确\n'
                '- 行顺序是否需要调整'),
          ),
          const Divider(height: 16),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 8,
            children: [
              FilledButton(
                onPressed: result == null
                    ? null
                    : () {
                        copyToClipboard(result!.toOutput(), toast: true);
                      },
                child: Text(S.current.copy),
              ),
              FilledButton(
                onPressed: result == null
                    ? null
                    : () async {
                        final summon = result!.toSummon();
                        if (gacha.isLuckyBag) {
                          final type = await showDialog<SummonType>(
                            context: context,
                            useRootNavigator: false,
                            builder: (context) => SimpleDialog(
                              title: Text(S.current.lucky_bag),
                              children: [
                                for (final type in [SummonType.gssr, SummonType.gssrsr])
                                  SimpleDialogOption(
                                    child: Text(Transl.enums(type, (enums) => enums.summonType).l),
                                    onPressed: () {
                                      Navigator.pop(context, type);
                                    },
                                  )
                              ],
                            ),
                          );
                          if (type == null) return;
                          summon.type = type;
                        }
                        router.push(child: SummonSimulatorPage(summon: summon));
                      },
                child: Text(S.current.simulator),
              ),
            ],
          ),
          SwitchListTile(
            dense: true,
            value: showIcon,
            title: Text(S.current.icons),
            onChanged: result == null
                ? null
                : (v) {
                    setState(() {
                      showIcon = v;
                    });
                  },
          ),
          buildTable(),
          const SizedBox(height: 8),
          const SizedBox(height: 32),
          if (result != null && AppInfo.isDebugDevice)
            Card(
              child: Text(
                result!.getShownHtml(),
                style: kMonoStyle,
              ),
            ),
        ],
      ),
    );
  }

  Widget cell(String s) {
    return Padding(padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2), child: Text(s));
  }

  Widget buildTable() {
    final result = this.result;

    List<Widget> children = [];
    if (result == null) {
      children.add(const Text('Nothing'));
    } else {
      final totalProb = result.getTotalProb();
      final guessTotalProb = result.guessTotalProb();
      children.add(Text('${S.current.total}: $guessTotalProb% ($totalProb%)'));
      children.add(SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Table(
          defaultVerticalAlignment: TableCellVerticalAlignment.middle,
          defaultColumnWidth: const IntrinsicColumnWidth(),
          border: TableBorder.all(color: Theme.of(context).dividerColor),
          children: [
            TableRow(children: ['type', 'star', 'weight', 'display', 'ids'].map(cell).toList()),
            for (final group in result.groups) buildRow(group),
          ],
        ),
      ));
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Card(
        // margin: const EdgeInsets.all(8),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: children,
          ),
        ),
      ),
    );
  }

  TableRow buildRow(_ProbGroup group) {
    List<String> texts = group.toRow();
    texts.removeLast();
    List<Widget> children = texts.map(cell).toList();
    children[2] = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2),
      child: Text.rich(TextSpan(text: texts[2], children: [
        TextSpan(
          text: ' (${group.indivProb}×${group.cards.length}=${group.getTotalProb().toStringAsFixed(2)}%)',
          style: Theme.of(context).textTheme.bodySmall,
        )
      ])),
    );

    if (!showIcon) {
      children.add(cell(group.ids.join(", ")));
    } else {
      children.add(Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
        child: Text.rich(TextSpan(
          // text: '(${group.cards.length}) ',
          children: [
            for (final card in group.cards)
              CenterWidgetSpan(
                child: GameCardMixin.anyCardItemBuilder(
                  context: context,
                  width: 28,
                  id: card.id,
                ),
              ),
          ],
        )),
      ));
    }

    return TableRow(children: children);
  }
}

class GachaParser {
  static const String kStar = '★';

  GachaParseResult parse(String text, MstGacha gacha) {
    final doc = htmlparser.parse(text);
    final tableCount = text.split("<table").length - 1;
    List<List<String>> svtTable, ceTable;
    if (tableCount == 4) {
      // svt_class, rarity, name, prob
      svtTable = getProbTable(doc, 2, 4);
      // rarity, name, prob
      ceTable = getProbTable(doc, 3, 3);
    } else if (tableCount == 6) {
      // 1, svt, ce, svt, ce, 6
      svtTable = [...getProbTable(doc, 2, 4), ...getProbTable(doc, 4, 4)];
      ceTable = [...getProbTable(doc, 3, 3), ...getProbTable(doc, 5, 3)];
    } else if (tableCount == 5) {
      const svtTitle = '■ピックアップサーヴァント一覧', ceTitle = '■ピックアップ概念礼装';
      if (text.contains(svtTitle) && !text.contains(ceTitle)) {
        // 1, svt, svt, ce, 5
        svtTable = [...getProbTable(doc, 2, 4), ...getProbTable(doc, 3, 4)];
        ceTable = [...getProbTable(doc, 4, 3)];
      } else if (!text.contains(svtTitle) && text.contains(ceTitle)) {
        // 1, ce, svt, ce, 5
        svtTable = [...getProbTable(doc, 3, 4)];
        ceTable = [...getProbTable(doc, 2, 3), ...getProbTable(doc, 4, 3)];
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

    Map<String, _ProbGroup> groupMap = {};

    for (final row in svtTable) {
      final int classId = classMap[row[0]]!;
      final int rarity = row[1].count(kStar);
      final String name = row[2];
      final String probStr = row[3];
      final svt = findCard(name, rarity, classId);
      final key = 'svt-$rarity-$probStr';
      final group = groupMap[key] ??=
          _ProbGroup(isSvt: true, rarity: rarity, indivProb: probStr, cards: [], isLuckyBag: gacha.isLuckyBag);
      group.cards.add(svt);
    }

    for (final row in ceTable) {
      final int rarity = row[0].count(kStar);
      final ce = findCard(row[1], rarity, 1001);
      final probStr = row[2];
      final key = 'ce-$rarity-$probStr';
      final group = groupMap[key] ??=
          _ProbGroup(isSvt: false, rarity: rarity, indivProb: probStr, cards: [], isLuckyBag: gacha.isLuckyBag);
      group.cards.add(ce);
    }

    final groups = groupMap.values.toList();
    groups.sortByList((e) => [e.isSvt ? 0 : 1, e.display ? 0 : 1, -e.rarity, e.cards.length]);

    return GachaParseResult(gacha, text, groups);
  }

  List<List<String>> getProbTable(htmldom.Document document, int tableIndex, int colCount) {
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

  BasicServant findCard(String name, int rarity, int classId) {
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
}

class GachaParseResult {
  final MstGacha gacha;
  final String htmlText;
  List<_ProbGroup> groups;
  GachaParseResult(this.gacha, this.htmlText, this.groups);

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
      name: gacha.name.setMaxLines(1),
      officialBanner: MappingBase(jp: AssetURL.i.summonBanner(gacha.imageId)),
      type: gacha.isLuckyBag ? SummonType.gssr : SummonType.limited,
      subSummons: [
        SubSummon(title: gacha.name.setMaxLines(1), probs: [
          for (final group in groups)
            ProbGroup(
              isSvt: group.isSvt,
              rarity: group.rarity,
              weight: group.guessTotalProb(),
              display: group.display,
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

class _ProbGroup {
  bool isSvt;
  int rarity;
  String indivProb;
  List<GameCardMixin> cards;
  bool isLuckyBag;

  _ProbGroup({
    required this.isSvt,
    required this.rarity,
    required this.indivProb,
    required this.cards,
    required this.isLuckyBag,
  });

  bool get display => !isLuckyBag && cards.length <= 3;

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
      display ? '1' : '0',
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
