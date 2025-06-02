import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

import 'package:chaldea/app/app.dart';
import 'package:chaldea/app/descriptors/cond_target_value.dart';
import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/models/models.dart';
import 'package:chaldea/packages/app_info.dart';
import 'package:chaldea/packages/logger.dart';
import 'package:chaldea/utils/utils.dart';
import 'package:chaldea/widgets/widgets.dart';
import '../summon/gacha/gacha_banner.dart';
import '../summon/summon_simulator_page.dart';
import 'gacha_parser.dart';

class MCGachaProbEditPage extends StatefulWidget {
  final NiceGacha gacha;
  final Region region;
  const MCGachaProbEditPage({super.key, required this.gacha, required this.region});

  @override
  State<MCGachaProbEditPage> createState() => _MCGachaProbEditPageState();
}

class _MCGachaProbEditPageState extends State<MCGachaProbEditPage> {
  late final gacha = widget.gacha;
  late final url = gacha.getHtmlUrl(widget.region);
  late GachaProbData result = GachaProbData(widget.gacha, '', []);

  final converter = JpGachaParser();

  bool showIcon = false;
  bool get allowParse => widget.region == Region.jp;

  @override
  void initState() {
    super.initState();
    parseHtml();
  }

  Future<void> parseHtml() async {
    try {
      if (!allowParse || gacha.openedAt > DateTime.now().timestamp) return;
      result = await showEasyLoading(() => converter.parseProb(gacha));
      if (result.isInvalid) {
        EasyLoading.showError(S.current.failed);
        return;
      }
    } catch (e, s) {
      if (mounted) {
        SimpleConfirmDialog(
          title: Text(S.current.error),
          content: Text(e.toString()),
          scrollable: true,
          showCancel: false,
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
        title: AutoSizeText(gacha.lName.setMaxLines(1), maxLines: 1, minFontSize: 14),
        // actions: [
        //   IconButton(onPressed: parseHtml, icon: const Icon(Icons.search)),
        // ],
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 8),
        children: [
          GachaBanner(imageId: gacha.imageId, region: widget.region),
          CustomTable(
            children: [
              for (final name in {gacha.lName, gacha.name})
                CustomTableRow.fromTexts(
                  texts: [name],
                  defaults: TableCellData(
                    textAlign: TextAlign.center,
                    color: TableCellData.resolveHeaderColor(context),
                  ),
                ),
              CustomTableRow.fromTexts(texts: ['No.${gacha.id}', gacha.type.shownName]),
              CustomTableRow.fromTexts(
                texts: [
                  [gacha.openedAt, gacha.closedAt].map((e) => e.sec2date().toStringShort(omitSec: true)).join(' ~ '),
                ],
              ),
              // if (gacha.featuredSvtIds.isNotEmpty)
              //   CustomTableRow.fromChildren(children: [
              //     Wrap(
              //       spacing: 4,
              //       runSpacing: 4,
              //       children: [
              //         for (final svtId in gacha.featuredSvtIds)
              //           db.gameData.servantsById[svtId]?.iconBuilder(context: context, width: 48) ?? Text('No.$svtId'),
              //       ],
              //     )
              //   ]),
            ],
          ),
          for (final adjust in gacha.storyAdjusts) ...[
            DividerWithTitle(title: "Case ${adjust.idx}"),
            CondTargetValueDescriptor(
              condType: adjust.condType,
              target: adjust.targetId,
              value: adjust.value,
              padding: const EdgeInsets.symmetric(horizontal: 16),
            ),
            if (adjust.imageId != gacha.imageId)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: GachaBanner(imageId: adjust.imageId, region: widget.region),
              ),
          ],
          const Divider(height: 16),
          Wrap(
            spacing: 6,
            alignment: WrapAlignment.center,
            children: [
              if (url != null)
                TextButton(
                  onPressed: gacha.openedAt < DateTime.now().timestamp ? () => launch(url!) : null,
                  child: Text(S.current.open_in_browser),
                ),
              FilledButton(
                onPressed: result.isInvalid
                    ? null
                    : () async {
                        final summon = result.toSummon();
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
                                  ),
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
          if (widget.region != Region.jp)
            Text(
              'Only JP supports simulator',
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
          if (allowParse) ...[
            const Divider(height: 16),
            SwitchListTile(
              dense: true,
              value: showIcon,
              title: Text(S.current.icons),
              onChanged: result.isInvalid
                  ? null
                  : (v) {
                      setState(() {
                        showIcon = v;
                      });
                    },
            ),
            buildTable(),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text(
                '[For Mooncell wiki Editor]\n'
                '检查后再写入到“某某卡池/模拟器/data{X}”中:\n'
                '- 是否显示(1显示 0不显示)\n'
                '- 各行总概率是否正确',
                style: TextStyle(fontSize: 14),
              ),
            ),
            Center(
              child: FilledButton(
                onPressed: result.isInvalid
                    ? null
                    : () {
                        copyToClipboard(result.toOutput(), toast: true);
                      },
                child: Text('${S.current.copy} Mooncell wikitext'),
              ),
            ),
          ],
          const SizedBox(height: 32),
          if (!result.isInvalid && AppInfo.isDebugOn) Card(child: Text(result.getShownHtml(), style: kMonoStyle)),
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
    if (result.isInvalid) {
      children.add(const Text('Nothing'));
    } else {
      final totalProb = result.getTotalProb();
      final guessTotalProb = result.guessTotalProb();
      children.add(Text('${S.current.total}: $guessTotalProb% ($totalProb%)'));
      children.add(
        SingleChildScrollView(
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
        ),
      );
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

  TableRow buildRow(GachaProbRow group) {
    List<String> texts = group.toRow();
    texts.removeLast();
    List<Widget> children = texts.map(cell).toList();
    children[2] = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2),
      child: Text.rich(
        TextSpan(
          text: texts[2],
          children: [
            TextSpan(
              text: ' (${group.indivProb}×${group.cards.length}=${group.getTotalProb().toStringAsFixed(2)}%)',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );

    Widget svtCell;
    if (!showIcon) {
      svtCell = cell(group.ids.join(", "));
    } else {
      svtCell = Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
        child: Text.rich(
          TextSpan(
            // text: '(${group.cards.length}) ',
            children: [
              for (final card in group.cards)
                CenterWidgetSpan(
                  child: GameCardMixin.anyCardItemBuilder(context: context, width: 28, id: card.id),
                ),
            ],
          ),
        ),
      );
    }
    children.add(ConstrainedBox(constraints: BoxConstraints(maxWidth: 500), child: svtCell));

    return TableRow(children: children);
  }
}
