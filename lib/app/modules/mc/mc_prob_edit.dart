import 'package:flutter_easyloading/flutter_easyloading.dart';

import 'package:chaldea/app/app.dart';
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
  const MCGachaProbEditPage({super.key, required this.gacha});

  @override
  State<MCGachaProbEditPage> createState() => _MCGachaProbEditPageState();
}

class _MCGachaProbEditPageState extends State<MCGachaProbEditPage> {
  late final gacha = widget.gacha;
  late final url = gacha.getHtmlUrl(Region.jp);
  late GachaProbData result = GachaProbData(widget.gacha, '', []);

  final converter = JpGachaParser();

  bool showIcon = false;

  @override
  void initState() {
    super.initState();
    parseHtml();
  }

  Future<void> parseHtml() async {
    try {
      result = await showEasyLoading(() => converter.parseProb(gacha));
      if (result.isInvalid) {
        EasyLoading.showError(S.current.failed);
        return;
      }
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
                onPressed: result.isInvalid
                    ? null
                    : () {
                        copyToClipboard(result.toOutput(), toast: true);
                      },
                child: Text(S.current.copy),
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
            onChanged: result.isInvalid
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
          if (!result.isInvalid && AppInfo.isDebugDevice)
            Card(
              child: Text(
                result.getShownHtml(),
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
    if (result.isInvalid) {
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

  TableRow buildRow(GachaProbRow group) {
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
