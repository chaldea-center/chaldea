import 'dart:math';

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
  int get clsId => widget.clsId;
  late SvtClass? cls = kSvtClassIds[clsId];

  static const beyondTheTaleClasses = <SvtClass>[
    SvtClass.saber,
    SvtClass.lancer,
    SvtClass.archer,
    SvtClass.rider,
    SvtClass.caster,
    SvtClass.assassin,
    SvtClass.berserker,
    SvtClass.avenger,
    SvtClass.alterEgo,
    SvtClass.moonCancer,
    SvtClass.foreigner,
    SvtClass.ruler,
    SvtClass.pretender,
  ];

  @override
  Widget build(BuildContext context) {
    final info = db.gameData.constData.classInfo[clsId];
    final rarities = info == null ? [5] : [if (SvtClassX.regularAll.any((e) => e.value == cls?.value)) 0, 1, 3, 5];
    Set<String> cardImages = {};
    if (info != null) {
      cardImages.addAll(rarities.map((e) => Atlas.classCard(e, info.imageId)));
    }
    if (cls == SvtClass.moonCancer) {
      cardImages.addAll([Atlas.classCard(5, 123), Atlas.classCard(5, 223)]);
    }
    // https://beyond.fate-go.jp/assets/img/teaser/card/01_saber.jpg
    if (cls != null && beyondTheTaleClasses.contains(cls)) {
      final index = (beyondTheTaleClasses.indexOf(cls!) + 1).toString().padLeft(2, '0');
      cardImages.add("https://beyond.fate-go.jp/assets/img/teaser/card/${index}_${cls!.name.toLowerCase()}.jpg");
    }
    return Scaffold(
      appBar: AppBar(title: Text('${S.current.svt_class}: ${Transl.svtClassId(clsId).l}')),
      body: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
            child: Wrap(
              alignment: WrapAlignment.center,
              children: rarities
                  .map((e) => SvtClassX.clsIcon(clsId, e, info?.iconImageId))
                  .toSet()
                  .map(
                    (e) => CachedImage(
                      imageUrl: e,
                      height: 48,
                      showSaveOnLongPress: true,
                      placeholder: (context, url) => const SizedBox.shrink(),
                    ),
                  )
                  .toList(),
            ),
          ),
          CustomTable(
            children: [
              CustomTableRow.fromTexts(texts: const ['ID', 'Class'], isHeader: true),
              CustomTableRow(
                children: [
                  TableCellData(text: clsId.toString()),
                  TableCellData(text: Transl.svtClassId(clsId).l),
                ],
              ),
              CustomTableRow.fromTexts(texts: const ['Attack Rate', 'Trait'], isHeader: true),
              CustomTableRow(
                children: [
                  TableCellData(text: _fmt(info?.attackRate)),
                  TableCellData(
                    child: info == null || info.individuality == 0
                        ? const Text('')
                        : Text.rich(
                            SharedBuilder.textButtonSpan(
                              context: context,
                              text: Transl.trait(info.individuality).l,
                              onTap: () => router.push(url: Routes.traitI(info.individuality)),
                            ),
                          ),
                  ),
                ],
              ),
              CustomTableRow.fromTexts(texts: const ['Affinity'], isHeader: true),
            ],
          ),
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
                transform: (child, url) {
                  if (url.contains('beyond.fate-go.jp')) {
                    return Transform.rotate(
                      angle: pi / 2,
                      child: AspectRatio(aspectRatio: 1, child: child),
                    );
                  }
                  return child;
                },
              )!,
            ),
        ],
      ),
    );
  }

  String _fmt(int? rate) {
    if (rate == null) return '';
    return (rate / 1000).format();
  }

  Widget? _fmtColor(int? rate, int? attacker, int? defender) {
    if (rate == null) return null;
    Color? color;
    if (rate > 1000) {
      color = Colors.red;
    } else if (rate < 1000) {
      color = Colors.blue;
    } else {
      color = Theme.of(context).textTheme.bodySmall?.color?.withAlpha(128);
    }
    final text = _fmt(rate);
    Widget child = Text(text, style: color == null ? null : TextStyle(color: color));
    if (attacker != null && defender != null) {
      child = Tooltip(
        message: '${[attacker, defender].map((e) => Transl.svtClassId(e).l).join("→")}: $text',
        child: child,
      );
    }
    return child;
  }

  Widget clsIcon(int _clsId) {
    final clsName = Transl.svtClassId(_clsId).l;
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
        child: Tooltip(
          message: clsName,
          child: db.getIconImage(
            SvtClassX.clsIcon(clsId, 5, info?.iconImageId),
            height: 24,
            aspectRatio: 1,
            errorWidget: (context, url, error) =>
                Text(_clsId.toString(), style: TextStyle(fontSize: 10), textAlign: TextAlign.center),
          ),
        ),
      ),
    );
  }

  Widget clsAffinity() {
    final clsInfos = db.gameData.constData.classInfo;
    final relations = db.gameData.constData.classRelation;

    final relationId = clsInfos[clsId]?.relationId;
    final attackRates = Map<int, int>.of(relations[relationId] ?? {});
    final defenseRates = <int, int>{
      for (final key in relations.keys)
        if (relations[key]![relationId] != null) key: relations[key]![relationId]!,
    };
    final _allRelationIds = {...attackRates.keys, ...defenseRates.keys};
    final allClasses = <int>{
      ...clsInfos.values.where((e) => _allRelationIds.contains(e.relationId)).map((e) => e.id),
      ...SvtClassX.regularAll.map((e) => e.value),
    }.toList();
    allClasses.sort2((e) => -(db.gameData.constData.classInfo[e]?.priority ?? -1));
    allClasses.sortByList((e) => [clsInfos[e]?.supportGroup ?? 999, -(clsInfos[e]?.priority ?? -1), e]);
    return LayoutBuilder(
      builder: (context, constraints) {
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
              rows[1].add(const AutoSizeText('Attack', maxLines: 1, minFontSize: 6));
              rows[2].add(const AutoSizeText('Defense', maxLines: 1, minFontSize: 6));
            } else {
              final oppCls = allClasses.getOrNull(row * clsCountPerLine + col - 1);
              rows[0].add(oppCls == null ? null : clsIcon(oppCls));
              final _oppRelationId = clsInfos[oppCls]?.relationId;
              final atk = attackRates[_oppRelationId], def = defenseRates[_oppRelationId];
              rows[1].add(_fmtColor(atk, clsId, oppCls));
              rows[2].add(_fmtColor(def, oppCls, clsId));
            }
          }
          for (int row = 0; row < rows.length; row++) {
            for (int col = 0; col < crossCount; col++) {
              children.add(
                Container(
                  decoration: BoxDecoration(
                    border: Border.fromBorderSide(Divider.createBorderSide(context)),
                    color: row == 0 || col == 0 ? Theme.of(context).highlightColor : null,
                  ),
                  child: Center(child: rows[row][col] ?? const SizedBox()),
                ),
              );
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
      },
    );
  }
}
