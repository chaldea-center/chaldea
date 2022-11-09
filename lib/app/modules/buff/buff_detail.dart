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
  const BuffDetailPage({super.key, this.id, this.buff, this.region})
      : assert(id != null || buff != null);

  @override
  State<BuffDetailPage> createState() => _BuffDetailPageState();
}

class _BuffDetailPageState extends State<BuffDetailPage>
    with
        SingleTickerProviderStateMixin,
        RegionBasedState<Buff, BuffDetailPage> {
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
  Future<Buff?> fetchData(Region? r) async {
    Buff? v;
    if (r == null || r == widget.region) v = widget.buff;
    if (r == Region.jp) {
      v ??= db.gameData.baseBuffs[id];
    }
    v ??= await AtlasApi.buff(id, region: r ?? Region.jp);
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
        title: Text('Buff $id ${data?.lName.l ?? ""}',
            overflow: TextOverflow.fade),
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
        SingleChildScrollView(child: BuffInfoTable(buff: buff)),
        _FuncTab(buff),
      ],
    );
  }

  Widget get popupMenu {
    return PopupMenuButton(
      itemBuilder: (context) => SharedBuilder.websitesPopupMenuItems(
          atlas: Atlas.dbBuff(id, region ?? Region.jp)),
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
            if (buff.icon != null)
              CenterWidgetSpan(child: db.getIconImage(buff.icon, width: 24)),
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
        buff.maxRate.toString()
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
                  url: Routes.funcs,
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
        TableCellData(text: "Detail", isHeader: true),
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
        buff.vals.isEmpty
            ? const Text('-')
            : SharedBuilder.traitList(context: context, traits: buff.vals)
      ]),
      CustomTableRow.fromTexts(
        texts: [S.current.effective_condition],
        isHeader: true,
      ),
      CustomTableRow(children: [
        TableCellData(text: "Self", isHeader: true),
        TableCellData(
          child: buff.ckSelfIndv.isEmpty
              ? const Text('-')
              : SharedBuilder.traitList(
                  context: context,
                  traits: buff.ckSelfIndv,
                  useAndJoin: buff.script?.checkIndvType == 1,
                ),
          flex: 3,
        )
      ]),
      CustomTableRow(children: [
        TableCellData(text: "Opponent", isHeader: true),
        TableCellData(
          child: buff.ckOpIndv.isEmpty
              ? const Text('-')
              : SharedBuilder.traitList(
                  context: context,
                  traits: buff.ckOpIndv,
                  useAndJoin: buff.script?.checkIndvType == 1,
                ),
          flex: 3,
        )
      ]),
      if (buff.script?.INDIVIDUALITIE != null)
        CustomTableRow(children: [
          TableCellData(text: "Owner", isHeader: true),
          TableCellData(
            child: SharedBuilder.trait(
                context: context, trait: buff.script!.INDIVIDUALITIE!),
            flex: 3,
          )
        ]),
      if (buff.script?.UpBuffRateBuffIndiv?.isNotEmpty == true)
        CustomTableRow(children: [
          TableCellData(text: "Buff Boost", isHeader: true),
          TableCellData(
            child: SharedBuilder.traitList(
                context: context, traits: buff.script!.UpBuffRateBuffIndiv!),
            flex: 3,
          )
        ]),
      if (buff.script?.DamageRelease == 1)
        CustomTableRow(children: [
          TableCellData(text: "Damage Release", isHeader: true),
          TableCellData(
            text: buff.script?.ReleaseText ?? '-',
            flex: 3,
          )
        ]),
      if (buff.script?.HP_LOWER != null)
        CustomTableRow(children: [
          TableCellData(text: "HP ≤", isHeader: true),
          TableCellData(
            text: buff.script!.HP_LOWER!.format(percent: true, base: 10),
            flex: 3,
          )
        ]),
      if (buff.script?.CheckOpponentBuffTypes?.isNotEmpty == true)
        CustomTableRow(children: [
          TableCellData(text: "Opp Buff Types", isHeader: true),
          TableCellData(
            child: Text.rich(TextSpan(
              children: divideList(
                buff.script!.CheckOpponentBuffTypes!
                    .map((e) => SharedBuilder.textButtonSpan(
                          context: context,
                          text: Transl.buffType(e).l,
                          onTap: () {
                            router.push(
                                url: Routes.buffs,
                                child: BuffListPage(type: e));
                          },
                        )),
                const TextSpan(text: ' / '),
              ),
            )),
            flex: 3,
          )
        ]),
      if (buff.script?.relationId != null) ...[
        CustomTableRow.fromTexts(
          texts: const ['Class Affinity Change'],
          isHeader: true,
        ),
        if (buff.script!.relationId!.atkSide.isNotEmpty) ...[
          CustomTableRow.fromTexts(texts: const ['Attacking']),
          relationId(context, buff.script!.relationId!.atkSide),
        ],
        if (buff.script!.relationId!.defSide.isNotEmpty) ...[
          CustomTableRow.fromTexts(texts: const ['Defending']),
          relationId(context, buff.script!.relationId!.defSide),
        ]
      ]
    ]);
  }

  Widget relationId(BuildContext context,
      Map<SvtClass, Map<SvtClass, RelationOverwriteDetail>> data) {
    // data[attacker][defender]
    final attackers = data.keys.toList();
    final defenders = {for (final v in data.values) ...v.keys};
    if (attackers.isEmpty || defenders.isEmpty) return const Text('None');
    String _fmt(int? rate) {
      if (rate == null) return '';
      return (rate / 1000).format();
    }

    Widget clsIcon(SvtClass cls) {
      return Padding(
        padding: const EdgeInsets.all(2),
        child: Tooltip(
          message: cls.lName,
          child: db.getIconImage(cls.icon(5), height: 24, aspectRatio: 1),
        ),
      );
    }

    return Table(
      children: [
        TableRow(children: [
          const AutoSizeText(
            'Attack→',
            textAlign: TextAlign.center,
            maxLines: 1,
            minFontSize: 12,
          ),
          for (final a in attackers) clsIcon(a),
        ]),
        for (final d in defenders)
          TableRow(children: [
            clsIcon(d),
            for (final a in attackers)
              AutoSizeText(
                _fmt(data[a]?[d]?.damageRate),
                textAlign: TextAlign.center,
                maxLines: 1,
                minFontSize: 12,
              )
          ])
      ],
      border: TableBorder.all(
          color: kHorizontalDivider.color ?? Theme.of(context).hintColor),
      defaultVerticalAlignment: TableCellVerticalAlignment.middle,
    );
  }
}

class _FuncTab extends StatelessWidget {
  final Buff buff;
  const _FuncTab(this.buff);

  @override
  Widget build(BuildContext context) {
    final funcs = db.gameData.baseFunctions.values
        .where((e) => e.buffs.any((e) => e.id == buff.id))
        .toList();
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
              leading: func.funcPopupIcon == null
                  ? const SizedBox()
                  : db.getIconImage(func.funcPopupIcon, width: 28),
              horizontalTitleGap: 6,
              contentPadding:
                  const EdgeInsetsDirectional.only(start: 10, end: 16),
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
