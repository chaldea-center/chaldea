import 'package:auto_size_text/auto_size_text.dart';

import 'package:chaldea/app/app.dart';
import 'package:chaldea/app/modules/common/builders.dart';
import 'package:chaldea/app/modules/common/extra_assets_page.dart';
import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/models/models.dart';
import 'package:chaldea/utils/utils.dart';
import 'package:chaldea/widgets/widgets.dart';

class SvtClassInfoPage extends StatefulWidget {
  final int clsId;
  const SvtClassInfoPage({super.key, required this.clsId});

  @override
  State<SvtClassInfoPage> createState() => _SvtClassInfoPageState();
}

class _SvtClassInfoPageState extends State<SvtClassInfoPage> {
  bool showIcon = true;

  int get clsId => widget.clsId;
  late SvtClass? cls = kSvtClassIds[clsId];

  @override
  Widget build(BuildContext context) {
    final info = db.gameData.constData.classInfo[clsId];
    final rarities =
        cls == null ? [5] : [if (cls == SvtClass.avenger) 0, 1, 3, 5];
    Set<String> cardImages = {};
    if (info != null) {
      cardImages.addAll(rarities.map((e) => Atlas.classCard(e, info.imageId)));
    }
    if (cls == SvtClass.moonCancer) {
      cardImages.addAll([
        Atlas.classCard(5, 123),
        Atlas.classCard(5, 223),
      ]);
    }
    return Scaffold(
      appBar: AppBar(
        title: Text('${S.current.filter_sort_class}: ${cls?.lName ?? clsId}'),
      ),
      body: ListView(
        children: [
          CustomTable(children: [
            CustomTableRow(
              children: [
                TableCellData(
                  child: Wrap(
                    alignment: WrapAlignment.center,
                    children: rarities
                        .map((e) => SvtClassX.clsIcon(e, info?.iconImageId))
                        .toSet()
                        .map((e) => db.getIconImage(e, height: 24))
                        .toList(),
                  ),
                )
              ],
            ),
            CustomTableRow.fromTexts(
                texts: const ['ID', 'Class'], isHeader: true),
            CustomTableRow(children: [
              TableCellData(text: clsId.toString()),
              TableCellData(text: cls?.lName ?? clsId.toString()),
            ]),
            CustomTableRow.fromTexts(
                texts: const ['Attack Rate', 'Trait'], isHeader: true),
            CustomTableRow(children: [
              TableCellData(text: _fmt(info?.attackRate)),
              TableCellData(
                child: info == null || info.individuality == 0
                    ? const Text('')
                    : Text.rich(
                        SharedBuilder.textButtonSpan(
                            context: context,
                            text: Transl.trait(info.individuality).l,
                            onTap: () => router.push(
                                url: Routes.traitI(info.individuality))),
                      ),
              )
            ]),
            CustomTableRow.fromTexts(texts: const ['Affinity'], isHeader: true),
          ]),
          clsAffinity(),
          if (cardImages.isNotEmpty)
            Padding(
              padding: const EdgeInsetsDirectional.only(start: 16),
              child: ExtraAssetsPage.oneGroup(
                'Class Card',
                cardImages,
                300,
                expanded: true,
                showMerge: true,
              )!,
            )
        ],
      ),
    );
  }

  String _fmt(int? rate) {
    if (rate == null) return '';
    return (rate / 1000).format();
  }

  Text? _fmtColor(int? rate) {
    if (rate == null) return null;
    Color? color;
    if (rate > 1000) {
      color = Theme.of(context).colorScheme.error;
    } else if (rate < 1000) {
      color = Theme.of(context).colorScheme.primaryContainer;
    }
    return Text(
      _fmt(rate),
      style: color == null ? null : TextStyle(color: color),
    );
  }

  Widget clsIcon(int _clsId) {
    final cls = kSvtClassIds[_clsId];
    final info = db.gameData.constData.classInfo[_clsId];
    return InkWell(
      onTap: () {
        // setState(() {
        //   showIcon = !showIcon;
        // });
        router.push(url: Routes.svtClassI(_clsId));
      },
      child: Padding(
        padding: const EdgeInsets.all(2),
        child: showIcon
            ? Tooltip(
                message: cls?.lName ?? 'Class $_clsId',
                child: db.getIconImage(
                  SvtClassX.clsIcon(5, info?.iconImageId),
                  height: 24,
                  aspectRatio: 1,
                  errorWidget: (context, url, error) => Text(_clsId.toString()),
                ),
              )
            : Text(cls?.lName ?? '$_clsId'),
      ),
    );
  }

  Widget clsAffinity() {
    final relations = db.gameData.constData.classRelation;
    final attackRates = Map<int, int>.of(relations[clsId] ?? {});
    final defenseRates = <int, int>{
      for (final key in relations.keys)
        if (relations[key]![clsId] != null) key: relations[key]![clsId]!
    };
    final allClasses = <int>{
      ...attackRates.keys,
      ...defenseRates.keys,
      ...SvtClassX.regularAll.map((e) => e.id)
    }.toList();
    allClasses
        .sort2((e) => -(db.gameData.constData.classInfo[e]?.priority ?? -1));
    return LayoutBuilder(builder: (context, constraints) {
      int crossCount = constraints.maxWidth ~/ 42;
      if (crossCount < 8) crossCount = 8;
      final int clsCountPerLine = crossCount - 1;
      List<Widget> children = [];
      int rowCount = (allClasses.length / clsCountPerLine).ceil();
      for (int row = 0; row < rowCount; row++) {
        List<List<Widget?>> rows = [[], [], []];
        for (int col = 0; col < crossCount; col++) {
          if (col == 0) {
            rows[0].add(null);
            rows[1]
                .add(const AutoSizeText('Attack', maxLines: 1, minFontSize: 6));
            rows[2].add(
                const AutoSizeText('Defense', maxLines: 1, minFontSize: 6));
          } else {
            final oppCls =
                allClasses.getOrNull(row * clsCountPerLine + col - 1);
            rows[0].add(oppCls == null ? null : clsIcon(oppCls));
            final atk = attackRates[oppCls], def = defenseRates[oppCls];
            rows[1].add(_fmtColor(atk));
            rows[2].add(_fmtColor(def));
          }
        }
        for (int row = 0; row < rows.length; row++) {
          for (int col = 0; col < crossCount; col++) {
            children.add(Container(
              decoration: BoxDecoration(
                border:
                    Border.fromBorderSide(Divider.createBorderSide(context)),
                color: row == 0 || col == 0
                    ? Theme.of(context).highlightColor
                    : null,
              ),
              child: Center(child: rows[row][col] ?? const SizedBox()),
            ));
          }
        }
      }

      return GridView.count(
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        crossAxisCount: crossCount,
        childAspectRatio: constraints.maxWidth / crossCount / 32.0,
        children: children,
      );
    });
  }
}
