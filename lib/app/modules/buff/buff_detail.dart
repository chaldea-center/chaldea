import 'dart:async';

import 'package:auto_size_text/auto_size_text.dart';

import 'package:chaldea/app/api/atlas.dart';
import 'package:chaldea/app/modules/common/builders.dart';
import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/models/models.dart';
import 'package:chaldea/utils/utils.dart';
import 'package:chaldea/widgets/region_based.dart';
import 'package:chaldea/widgets/widgets.dart';
import '../../app.dart';
import 'buff_list.dart';

class BuffDetailPage extends StatefulWidget {
  final int? id;
  final Buff? buff;
  final Region? region;
  const BuffDetailPage({super.key, this.id, this.buff, this.region}) : assert(id != null || buff != null);

  @override
  State<BuffDetailPage> createState() => _BuffDetailPageState();
}

class _BuffDetailPageState extends State<BuffDetailPage>
    with SingleTickerProviderStateMixin, RegionBasedState<Buff, BuffDetailPage> {
  late final controller = TabController(length: 2, vsync: this);
  int get id => widget.buff?.id ?? widget.id ?? data?.id ?? 0;
  Buff get buff => data!;

  @override
  void initState() {
    super.initState();
    region = widget.region ?? (widget.buff == null ? Region.jp : null);
    doFetchData();
  }

  @override
  Future<Buff?> fetchData(Region? r, {Duration? expireAfter}) async {
    Buff? v;
    if (r == null || r == widget.region) v = widget.buff;
    if (r == Region.jp) {
      v ??= db.gameData.baseBuffs[id];
    }
    v ??= await AtlasApi.buff(id, region: r ?? Region.jp, expireAfter: expireAfter);
    return v;
  }

  @override
  void dispose() {
    super.dispose();
    controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
            AutoSizeText('Buff $id ${data?.lName.l ?? ""}', maxLines: 1, minFontSize: 10, overflow: TextOverflow.fade),
        actions: [
          dropdownRegion(shownNone: widget.buff != null),
          popupMenu,
        ],
        bottom: data == null
            ? null
            : FixedHeight.tabBar(TabBar(
                controller: controller,
                tabs: const [Tab(text: "Info"), Tab(text: 'Func')],
              )),
      ),
      body: buildBody(context),
    );
  }

  @override
  Widget buildContent(BuildContext context, Buff buff) {
    return TabBarView(
      controller: controller,
      children: [
        ListView(
          children: [
            BuffInfoTable(buff: buff),
            for (final buffAction in buff.buffActions) ...[
              const DividerWithTitle(
                title: '  ·   ·   ·  ',
                indent: 16,
                padding: EdgeInsets.only(top: 16, bottom: 8),
              ),
              // const SizedBox(height: 16),
              SimpleAccordion(
                expanded: true,
                headerBuilder: (context, _) {
                  return Padding(
                    padding: const EdgeInsetsDirectional.only(start: 42),
                    child: TextButton(
                      onPressed: () {
                        router.push(url: Routes.buffActionI(buffAction));
                      },
                      style: kTextButtonDenseStyle,
                      child: Text('Buff Action - ${buffAction.name}'),
                    ),
                  );
                },
                contentBuilder: (context) => Padding(
                  padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                        border: Border.all(color: Theme.of(context).hintColor, width: 0.75),
                        borderRadius: BorderRadius.circular(5)),
                    position: DecorationPosition.foreground,
                    child: BuffActionInfoTable(action: buffAction),
                  ),
                ),
              ),
            ]
          ],
        ),
        _FuncTab(buff),
      ],
    );
  }

  Widget get popupMenu {
    return PopupMenuButton(
      itemBuilder: (context) => SharedBuilder.websitesPopupMenuItems(atlas: Atlas.dbBuff(id, region ?? Region.jp)),
    );
  }
}

class BuffInfoTable extends StatelessWidget {
  final Buff buff;
  const BuffInfoTable({super.key, required this.buff});

  @override
  Widget build(BuildContext context) {
    return CustomTable(selectable: true, children: [
      CustomTableRow(children: [
        TableCellData(
          child: Text.rich(TextSpan(children: [
            if (buff.icon != null) CenterWidgetSpan(child: db.getIconImage(buff.icon, width: 24)),
            TextSpan(text: ' ${buff.lName.l}')
          ])),
          isHeader: true,
        )
      ]),
      if (!Transl.isJP) CustomTableRow.fromTexts(texts: [buff.name]),
      CustomTableRow.fromTexts(
        texts: const ["ID", "Buff Group", "Max Rate"],
        isHeader: true,
      ),
      CustomTableRow.fromTexts(texts: [
        buff.id.toString(),
        buff.buffGroup.toString(),
        Buff.formatRate(buff.type, buff.maxRate),
      ]),
      CustomTableRow(children: [
        TableCellData(text: S.current.general_type, isHeader: true),
        TableCellData(
          child: Text.rich(
            SharedBuilder.textButtonSpan(
              context: context,
              text: '${buff.type.name}\n${Transl.buffType(buff.type).l}',
              onTap: () {
                router.push(
                  url: Routes.buffs,
                  child: BuffListPage(type: buff.type),
                  detail: false,
                );
              },
            ),
            textAlign: TextAlign.center,
          ),
          flex: 3,
        ),
      ]),
      CustomTableRow(children: [
        TableCellData(text: S.current.details, isHeader: true),
        TableCellData(
          text: buff.lDetail.l,
          flex: 3,
          textAlign: TextAlign.center,
        )
      ]),
      CustomTableRow.fromTexts(
        texts: const ["Buff Traits"],
        isHeader: true,
      ),
      CustomTableRow.fromChildren(children: [
        buff.vals.isEmpty ? const Text('-') : SharedBuilder.traitList(context: context, traits: buff.vals)
      ]),
      CustomTableRow.fromTexts(
        texts: [S.current.effective_condition],
        isHeader: true,
      ),
      CustomTableRow(children: [
        TableCellData(text: S.current.buff_check_self, isHeader: true),
        TableCellData(
          child: buff.ckSelfIndv.isEmpty
              ? const Text('-')
              : SharedBuilder.traitList(
                  context: context,
                  traits: buff.ckSelfIndv,
                  useAndJoin: buff.script.checkIndvTypeAnd == true,
                ),
          flex: 3,
        )
      ]),
      CustomTableRow(children: [
        TableCellData(text: S.current.buff_check_opponent, isHeader: true),
        TableCellData(
          child: buff.ckOpIndv.isEmpty
              ? const Text('-')
              : SharedBuilder.traitList(
                  context: context,
                  traits: buff.ckOpIndv,
                  useAndJoin: buff.script.checkIndvTypeAnd == true,
                ),
          flex: 3,
        )
      ]),
      if (buff.script.INDIVIDUALITIE != null)
        CustomTableRow(children: [
          TableCellData(text: "Owner", isHeader: true),
          TableCellData(
            child: Text.rich(TextSpan(children: [
              SharedBuilder.traitSpan(context: context, trait: buff.script.INDIVIDUALITIE!),
              if (buff.script.INDIVIDUALITIE_COUNT_ABOVE != null)
                TextSpan(text: '≥${buff.script.INDIVIDUALITIE_COUNT_ABOVE}'),
            ])),
            flex: 3,
          )
        ]),
      if (buff.script.INDIVIDUALITIE_AND != null)
        CustomTableRow(children: [
          TableCellData(text: "Owner", isHeader: true),
          TableCellData(
            child: SharedBuilder.traitList(context: context, traits: buff.script.INDIVIDUALITIE_AND!, useAndJoin: true),
            flex: 3,
          )
        ]),
      if (buff.script.INDIVIDUALITIE_OR != null)
        CustomTableRow(children: [
          TableCellData(text: "Owner", isHeader: true),
          TableCellData(
            child: SharedBuilder.traitList(context: context, traits: buff.script.INDIVIDUALITIE_OR!, useAndJoin: false),
            flex: 3,
          )
        ]),
      if (buff.script.UpBuffRateBuffIndiv?.isNotEmpty == true)
        CustomTableRow(children: [
          TableCellData(text: "Buff Boost", isHeader: true),
          TableCellData(
            child: SharedBuilder.traitList(context: context, traits: buff.script.UpBuffRateBuffIndiv!),
            flex: 3,
          )
        ]),
      if (buff.script.DamageRelease == 1)
        CustomTableRow(children: [
          TableCellData(text: "Damage Release", isHeader: true),
          TableCellData(
            text: buff.script.ReleaseText ?? '-',
            flex: 3,
          )
        ]),
      if (buff.script.HP_LOWER != null || buff.script.HP_HIGHER != null)
        CustomTableRow(children: [
          TableCellData(text: "HP", isHeader: true),
          TableCellData(
            text: [
              buff.script.HP_HIGHER?.format(percent: true, base: 10),
              'HP',
              buff.script.HP_LOWER?.format(percent: true, base: 10),
            ].where((e) => e != null).join(" ≤ "),
            flex: 3,
          )
        ]),
      if (buff.script.CheckOpponentBuffTypes?.isNotEmpty == true)
        CustomTableRow(children: [
          TableCellData(text: "Opp Buff Types", isHeader: true),
          TableCellData(
            child: Text.rich(TextSpan(
              children: divideList(
                buff.script.CheckOpponentBuffTypes!.map((e) => SharedBuilder.textButtonSpan(
                      context: context,
                      text: Transl.buffType(e).l,
                      onTap: () {
                        router.push(url: Routes.buffs, child: BuffListPage(type: e));
                      },
                    )),
                const TextSpan(text: ' / '),
              ),
            )),
            flex: 3,
          )
        ]),
      if (buff.script.relationId != null) ...[
        CustomTableRow.fromTexts(
          texts: const ['Class Affinity Change'],
          isHeader: true,
        ),
        if (buff.script.relationId!.atkSide2.isNotEmpty) ...[
          CustomTableRow.fromTexts(texts: const ['Attacking']),
          relationId(context, buff.script.relationId!.atkSide2),
        ],
        if (buff.script.relationId!.defSide2.isNotEmpty) ...[
          CustomTableRow.fromTexts(texts: const ['Defending']),
          relationId(context, buff.script.relationId!.defSide2),
        ],
      ],
      if (buff.script.convert != null) ...buildBuffConvert(context, buff.script.convert!),
      if (buff.script.source.isNotEmpty == true) ..._sourceScript(context, buff.script),
    ]);
  }

  Widget relationId(BuildContext context, Map<int, Map<int, RelationOverwriteDetail>> data) {
    // data[attacker][defender]
    final attackers = data.keys.toList();
    final defenders = {for (final v in data.values) ...v.keys};
    if (attackers.isEmpty || defenders.isEmpty) return const Text('None');
    String _fmt(int? rate) {
      if (rate == null) return '';
      return (rate / 1000).format();
    }

    Widget clsIcon(int clsId) {
      return Padding(
        padding: const EdgeInsets.all(2),
        child: Tooltip(
          message: Transl.svtClassId(clsId).l,
          child: db.getIconImage(SvtClassX.clsIcon(clsId, 5), height: 24, aspectRatio: 1),
        ),
      );
    }

    Widget _buildCell(int attacker, int defender, RelationOverwriteDetail? detail) {
      List<InlineSpan> spans = [];
      String tooltip = [attacker, defender].map((e) => Transl.svtClassId(e).l).join("→");
      if (detail != null) {
        String value = _fmt(detail.damageRate);
        spans.add(TextSpan(
          text: value,
          style: detail.damageRate > 1000
              ? const TextStyle(color: Colors.red)
              : detail.damageRate < 1000
                  ? const TextStyle(color: Colors.blue)
                  : null,
        ));
        tooltip += ': $value';
        final suffix = {
          // ClassRelationOverwriteType.overwriteForce: '',
          ClassRelationOverwriteType.overwriteMoreThanTarget: '↑',
          ClassRelationOverwriteType.overwriteLessThanTarget: '↓',
        }[detail.type];
        if (suffix != null) {
          spans.add(TextSpan(
              text: suffix,
              style: TextStyle(
                fontSize: 12,
                color: Theme.of(context).textTheme.bodySmall?.color,
              )));
          tooltip += suffix;
        }
        if (detail.type != ClassRelationOverwriteType.overwriteForce) {
          tooltip += '\n${detail.type.name.substring(9)}';
        }
      }

      return Tooltip(
        message: tooltip,
        textAlign: TextAlign.center,
        child: Text.rich(
          TextSpan(children: spans),
          textAlign: TextAlign.center,
          maxLines: 1,
        ),
      );
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Table(
        children: [
          TableRow(children: [
            const Text(
              'Attack→',
              textAlign: TextAlign.center,
              maxLines: 1,
              // minFontSize: 12,
            ),
            for (final a in attackers) clsIcon(a),
          ]),
          for (final d in defenders)
            TableRow(children: [
              clsIcon(d),
              for (final a in attackers) _buildCell(a, d, data[a]?[d]),
            ])
        ],
        border: TableBorder.all(color: kHorizontalDivider.color ?? Theme.of(context).hintColor),
        defaultVerticalAlignment: TableCellVerticalAlignment.middle,
        defaultColumnWidth: const IntrinsicColumnWidth(),
      ),
    );
  }

  Iterable<Widget> buildBuffConvert(BuildContext context, BuffConvert convert) sync* {
    for (int index = 0; index < convert.convertBuffs.length; index++) {
      final cvtBuff = convert.convertBuffs[index];
      final text = convert.script?.OverwritePopupText?.getOrNull(index);
      final header = StringBuffer('Buff Convert');
      if (convert.convertBuffs.length > 1) {
        header.write(' ${index + 1}');
      }
      if (text != null && text.isNotEmpty) {
        header.write(': $text');
      }
      yield CustomTableRow.fromTexts(texts: [header.toString()], isHeader: true);

      List<Widget> children = [];
      switch (convert.convertType) {
        case BuffConvertType.none:
          children.add(const Text('NONE ?_?'));
          break;
        case BuffConvertType.buff:
          final target = convert.targetBuffs.getOrNull(index);
          children.add(_describeBuff(context, target));
          break;
        case BuffConvertType.individuality:
          final trait = convert.targetIndividualities.getOrNull(index);
          children.add(_describeTrait(context, trait));
          break;
      }
      children.addAll([
        const Text(' → '),
        _describeBuff(context, cvtBuff),
      ]);
      yield Wrap(
        alignment: WrapAlignment.center,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: children,
      );
    }
  }

  Widget _describeBuff(BuildContext context, Buff? buff) {
    List<InlineSpan> spans = [];
    if (buff == null) {
      spans.add(const TextSpan(text: 'Buff ???'));
    } else {
      spans.addAll([
        if (buff.icon != null) CenterWidgetSpan(child: db.getIconImage(buff.icon, width: 18, aspectRatio: 1)),
        TextSpan(text: '[${buff.id}] ${buff.lName.l}')
      ]);
    }
    return InkWell(
      onTap: buff?.routeTo,
      child: Text.rich(
        TextSpan(children: spans),
        style: TextStyle(color: Theme.of(context).colorScheme.secondaryContainer),
      ),
    );
  }

  Widget _describeTrait(BuildContext context, NiceTrait? trait) {
    return InkWell(
      onTap: trait?.routeTo,
      child: Text.rich(
        TextSpan(text: 'Buff with ', children: [
          trait == null ? const TextSpan(text: 'Trait ???') : SharedBuilder.traitSpan(context: context, trait: trait)
        ]),
      ),
    );
  }

  Iterable<Widget> _sourceScript(BuildContext context, BuffScript script) sync* {
    yield CustomTableRow.fromTexts(
      texts: const ['Source Script'],
      isHeader: true,
    );
    for (final key in script.source.keys) {
      if (key == 'relationOverwrite') continue;
      yield CustomTableRow(children: [
        TableCellData(text: key, isHeader: true)..maxLines = null,
        TableCellData(
          text: key == 'relationId' || key == 'convert' ? '↑...↑' : script.source[key].toString(),
          flex: 3,
        ),
      ]);
    }
  }
}

class _FuncTab extends StatelessWidget {
  final Buff buff;
  const _FuncTab(this.buff);

  @override
  Widget build(BuildContext context) {
    final funcs = db.gameData.baseFunctions.values.where((e) => e.buffs.any((e) => e.id == buff.id)).toList();
    funcs.sort2((e) => e.funcId);
    if (funcs.isEmpty) {
      return const Center(child: Text('No local record'));
    }

    return ScrollControlWidget(
      builder: (context, controller) {
        return ListView.builder(
          itemBuilder: (context, index) {
            final func = funcs[index];
            return ListTile(
              dense: true,
              leading: func.funcPopupIcon == null ? const SizedBox() : db.getIconImage(func.funcPopupIcon, width: 28),
              horizontalTitleGap: 6,
              contentPadding: const EdgeInsetsDirectional.only(start: 10, end: 16),
              title: Text('${func.funcId} ${func.lPopupText.l}'),
              onTap: func.routeTo,
            );
          },
          itemCount: funcs.length,
        );
      },
    );
  }
}

class BuffActionPage extends StatelessWidget {
  final BuffAction action;
  const BuffActionPage({super.key, required this.action});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('BuffAction ${action.name}')),
      body: SingleChildScrollView(child: BuffActionInfoTable(action: action)),
    );
  }
}

class BuffActionInfoTable extends StatelessWidget {
  final BuffAction action;

  const BuffActionInfoTable({super.key, required this.action});

  @override
  Widget build(BuildContext context) {
    final detail = db.gameData.constData.buffActions[action];

    if (action == BuffAction.unknown || detail == null) {
      return CustomTable(children: [
        CustomTableRow.fromTexts(texts: const ['Unknown BuffAction'], isHeader: true)
      ]);
    }

    final plusAction = BuffAction.values.firstWhereOrNull((e) => e.id == detail.plusAction);

    int? valueBase = kBuffActionPercentTypes[action];

    String fmtBuffValue(int value) {
      if (valueBase == null) return value.toString();
      return value.format(percent: true, base: valueBase.toDouble());
    }

    String limitText = detail.limit == BuffLimit.none ? 'no limit' : 'v';
    String formula = 'buffs + baseParam';
    if (const [BuffLimit.normal, BuffLimit.lower].contains(detail.limit)) {
      limitText = '${fmtBuffValue(-detail.baseParam)} ≤ $limitText';
      formula = 'max($formula, 0)';
    }
    formula = '$formula - baseValue';
    if (const [BuffLimit.normal, BuffLimit.upper].contains(detail.limit)) {
      limitText += ' ≤ ${detail.maxRate.map((e) => fmtBuffValue(e)).join(' or ')}';
      formula = 'min($formula, maxRate)';
    }

    return CustomTable(selectable: true, children: [
      CustomTableRow.fromTexts(texts: const ['BuffAction'], isHeader: true),
      CustomTableRow.fromTexts(texts: ['${action.id} - ${action.name}']),
      ...buffTypes(context, 'Plus Buffs', detail.plusTypes),
      ...buffTypes(context, 'Minus Buffs', detail.minusTypes),
      if (plusAction != null && plusAction != BuffAction.none && plusAction != BuffAction.unknown) ...[
        CustomTableRow.fromTexts(texts: const ['Plus Buff Action'], isHeader: true),
        CustomTableRow.fromChildren(children: [
          Text.rich(SharedBuilder.textButtonSpan(
            context: context,
            text: '${plusAction.id} - ${plusAction.name}',
            onTap: () {
              router.push(url: Routes.buffActionI(plusAction));
            },
          ))
        ])
      ],
      CustomTableRow.fromTexts(
        texts: const ['Base Param', 'Base Value', 'Max Rates', "Limit Type"],
        isHeader: true,
      ),
      CustomTableRow.fromTexts(
        texts: [
          fmtBuffValue(detail.baseParam),
          fmtBuffValue(detail.baseValue),
          detail.maxRate.length == 1
              ? fmtBuffValue(detail.maxRate.first)
              : detail.maxRate.map((e) => fmtBuffValue(e)).join(','),
          detail.limit.name,
        ],
      ),
      CustomTableRow(children: [
        TableCellData(text: 'Default Value', isHeader: true),
        TableCellData(text: 'Limit', isHeader: true, flex: 3),
      ]),
      CustomTableRow(children: [
        TableCellData(text: fmtBuffValue(detail.baseParam - detail.baseValue)),
        TableCellData(text: limitText, flex: 3),
      ]),
      CustomTableRow.fromChildren(children: [
        Text(
          'v=$formula',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodySmall,
        )
      ]),
    ]);
  }

  Iterable<Widget> buffTypes(BuildContext context, String header, List<BuffType> buffTypes) sync* {
    if (buffTypes.isEmpty) return;
    yield CustomTableRow.fromTexts(texts: [header], isHeader: true);
    List<InlineSpan> spans = [];
    for (final type in buffTypes) {
      final icons = getBuffIcons(type);
      spans.add(TextSpan(children: [
        for (final icon in icons) CenterWidgetSpan(child: db.getIconImage(icon, width: 18)),
        SharedBuilder.textButtonSpan(
          context: context,
          text: ' [${type.name}] ${Transl.buffType(type).l}',
          onTap: () {
            router.push(
              url: Routes.buffs,
              child: BuffListPage(type: type),
              detail: false,
            );
          },
        )
      ]));
    }
    yield CustomTableRow.fromChildren(children: [
      Text.rich(
        TextSpan(children: divideList(spans, const TextSpan(text: '\n'))),
        textAlign: TextAlign.center,
      )
    ]);
  }

  List<String> getBuffIcons(BuffType type) {
    Map<String, int> counts = {};
    for (final buff in db.gameData.baseBuffs.values) {
      if (buff.type == type && buff.icon != null) counts.addNum(buff.icon!, 1);
    }
    if (counts.isEmpty) return [];
    final entries = counts.entries.toList()..sort2((e) => -e.value);
    return entries.take(3).map((e) => e.key).toList();
  }
}
