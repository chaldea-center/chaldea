import 'package:auto_size_text/auto_size_text.dart';

import 'package:chaldea/app/app.dart';
import 'package:chaldea/app/modules/common/builders.dart';
import 'package:chaldea/app/modules/common/extra_assets_page.dart';
import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/models/models.dart';
import 'package:chaldea/utils/utils.dart';
import 'package:chaldea/widgets/widgets.dart';

class ClassInfoPage extends StatefulWidget {
  final SvtClass cls;
  const ClassInfoPage({super.key, required this.cls});

  @override
  State<ClassInfoPage> createState() => _ClassInfoPageState();
}

class _ClassInfoPageState extends State<ClassInfoPage> {
  bool showIcon = true;
  SvtClass get cls => widget.cls;

  @override
  Widget build(BuildContext context) {
    final info = db.gameData.constData.classInfo[cls.id];
    final rarities = [if (cls == SvtClass.avenger) 0, 1, 3, 5];
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
        title: Text('${S.current.filter_sort_class}: ${widget.cls.lName}'),
      ),
      body: ListView(
        children: [
          CustomTable(children: [
            CustomTableRow(
              children: [
                TableCellData(
                  child: Wrap(
                    alignment: WrapAlignment.center,
                    children: [
                      for (final rarity in rarities)
                        db.getIconImage(
                          cls.icon(rarity),
                          height: 24,
                          // width: 24,
                        ),
                    ],
                  ),
                )
              ],
            ),
            CustomTableRow.fromTexts(
                texts: const ['ID', 'Class'], isHeader: true),
            CustomTableRow(children: [
              TableCellData(text: cls.id.toString()),
              TableCellData(text: cls.lName),
            ]),
            CustomTableRow.fromTexts(
                texts: const ['Attack Rate', 'Trait'], isHeader: true),
            CustomTableRow(children: [
              TableCellData(text: _fmt(info?.attackRate)),
              TableCellData(
                child: info == null
                    ? null
                    : Text.rich(
                        SharedBuilder.textButtonSpan(
                            context: context,
                            text: Transl.trait(info.individuality.id).l,
                            onTap: () => router.push(
                                url: Routes.traitI(info.individuality.id))),
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

  Widget clsIcon(SvtClass cls) {
    return InkWell(
      onTap: () {
        // setState(() {
        //   showIcon = !showIcon;
        // });
        cls.routeTo();
      },
      child: Padding(
        padding: const EdgeInsets.all(2),
        child: showIcon
            ? Tooltip(
                message: cls.lName,
                child: db.getIconImage(cls.icon(5), height: 24, aspectRatio: 1),
              )
            : Text(cls.lName),
      ),
    );
  }

  Widget clsAffinity() {
    final data = db.gameData.constData.classRelation;
    final attackRates = Map<SvtClass, int?>.of(data[cls] ?? {});
    final defenseRates = data.map((key, value) => MapEntry(key, value[cls]));
    final allClasses = {...attackRates.keys, ...defenseRates.keys}.toList();
    allClasses
        .sort2((e) => -(db.gameData.constData.classInfo[e.id]?.priority ?? -1));
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
