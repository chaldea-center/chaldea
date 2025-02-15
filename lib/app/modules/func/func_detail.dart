import 'dart:async';

import 'package:auto_size_text/auto_size_text.dart';

import 'package:chaldea/app/api/atlas.dart';
import 'package:chaldea/app/app.dart';
import 'package:chaldea/app/modules/buff/buff_detail.dart';
import 'package:chaldea/app/modules/common/builders.dart';
import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/models/models.dart';
import 'package:chaldea/utils/utils.dart';
import 'package:chaldea/widgets/region_based.dart';
import 'package:chaldea/widgets/widgets.dart';
import '../common/misc.dart';
import 'func_list.dart';

class FuncDetailPage extends StatefulWidget {
  final int? id;
  final BaseFunction? func;
  final Region? region;
  const FuncDetailPage({super.key, this.id, this.func, this.region}) : assert(id != null || func != null);

  @override
  State<FuncDetailPage> createState() => _FuncDetailPageState();
}

class _FuncDetailPageState extends State<FuncDetailPage>
    with SingleTickerProviderStateMixin, RegionBasedState<BaseFunction, FuncDetailPage> {
  late final TabController _tabController = TabController(length: 3, vsync: this);
  int get id => widget.func?.funcId ?? widget.id ?? data?.funcId ?? -1;
  BaseFunction get func => data!;

  @override
  void initState() {
    super.initState();
    region = widget.region ?? (widget.func == null ? Region.jp : null);
    doFetchData();
  }

  @override
  Future<BaseFunction?> fetchData(Region? r, {Duration? expireAfter}) async {
    BaseFunction? v;
    if (r == null || r == widget.region) v = widget.func;
    if (r == Region.jp) {
      v ??= db.gameData.baseFunctions[id];
    }
    v ??= await AtlasApi.func(id, region: r ?? Region.jp, expireAfter: expireAfter);
    return v;
  }

  @override
  void dispose() {
    super.dispose();
    _tabController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: AutoSizeText(
          "Func $id ${data?.lPopupText.l ?? ""}",
          overflow: TextOverflow.fade,
          maxLines: 1,
          minFontSize: 14,
        ),
        actions: [dropdownRegion(shownNone: widget.func != null), popupMenu],
        bottom:
            data == null
                ? null
                : FixedHeight.tabBar(
                  TabBar(
                    controller: _tabController,
                    tabs: [const Tab(text: "Info"), Tab(text: S.current.skill), Tab(text: S.current.noble_phantasm)],
                  ),
                ),
      ),
      body: buildBody(context),
    );
  }

  Widget get popupMenu {
    return PopupMenuButton(
      itemBuilder: (context) => SharedBuilder.websitesPopupMenuItems(atlas: Atlas.dbFunc(id, region ?? Region.jp)),
    );
  }

  @override
  Widget buildContent(BuildContext context, BaseFunction func) {
    return TabBarView(
      controller: _tabController,
      children: [SingleChildScrollView(child: info), _SkillTab(func), _TdTab(func)],
    );
  }

  Widget get info {
    return CustomTable(
      selectable: true,
      children: [
        CustomTableRow(
          children: [
            TableCellData(
              child: Text.rich(
                TextSpan(
                  children: [
                    if (func.funcPopupIcon != null)
                      CenterWidgetSpan(child: db.getIconImage(func.funcPopupIcon, width: 24)),
                    TextSpan(text: ' ${func.lPopupText.l}'),
                  ],
                ),
                textAlign: TextAlign.center,
              ),
              isHeader: true,
            ),
          ],
        ),
        if (!Transl.isJP)
          CustomTableRow(children: [TableCellData(text: func.lPopupText.jp, textAlign: TextAlign.center)]),
        CustomTableRow(
          children: [
            TableCellData(text: 'ID', isHeader: true),
            TableCellData(text: func.funcId.toString(), flex: 3, alignment: AlignmentDirectional.centerEnd),
          ],
        ),
        CustomTableRow(
          children: [
            TableCellData(text: S.current.general_type, isHeader: true, textAlign: TextAlign.start),
            TableCellData(
              child: Text.rich(
                SharedBuilder.textButtonSpan(
                  context: context,
                  text: '[${func.funcType.value}] ${func.funcType.name}\n${Transl.funcType(func.funcType).l}',
                  onTap: () {
                    router.push(url: Routes.funcs, child: FuncListPage(type: func.funcType), detail: false);
                  },
                ),
                textAlign: TextAlign.end,
              ),
              flex: 3,
              alignment: AlignmentDirectional.centerEnd,
            ),
          ],
        ),
        CustomTableRow(
          children: [
            TableCellData(text: "Target", isHeader: true),
            TableCellData(
              text: Transl.funcTargetType(func.funcTargetType).l,
              flex: 3,
              alignment: AlignmentDirectional.centerEnd,
            ),
          ],
        ),
        CustomTableRow.fromTexts(texts: [S.current.effective_condition], isHeader: true),
        CustomTableRow(
          children: [
            TableCellData(text: "Actor", isHeader: true),
            TableCellData(
              text: [
                S.current.player,
                func.canBePlayerFunc ? '√' : '×',
                '   ',
                S.current.enemy,
                func.canBeEnemyFunc ? '√' : '×',
              ].join(' '),
              flex: 3,
              alignment: AlignmentDirectional.centerEnd,
            ),
          ],
        ),
        CustomTableRow(
          children: [
            TableCellData(text: "Target Team", isHeader: true),
            TableCellData(text: func.funcTargetTeam.name, flex: 3, alignment: AlignmentDirectional.centerEnd),
          ],
        ),
        CustomTableRow(
          children: [
            TableCellData(text: "Target Traits", isHeader: true),
            TableCellData(child: _buildTargetTraits(), flex: 3, alignment: AlignmentDirectional.centerEnd),
          ],
        ),
        if (func.funcquestTvals.isNotEmpty)
          CustomTableRow(
            children: [
              TableCellData(text: "Quest Traits", isHeader: true),
              TableCellData(
                child: SharedBuilder.traitList(context: context, traits: func.funcquestTvals),
                flex: 3,
                alignment: AlignmentDirectional.centerEnd,
              ),
            ],
          ),
        if (func.traitVals.isNotEmpty)
          CustomTableRow(
            children: [
              TableCellData(text: "Affects Traits", isHeader: true),
              TableCellData(
                child: SharedBuilder.traitList(context: context, traits: func.traitVals),
                flex: 3,
                alignment: AlignmentDirectional.centerEnd,
              ),
            ],
          ),
        ..._buildScript(),
        if (func.buffs.isNotEmpty) ...[
          CustomTableRow.fromTexts(texts: const ["Buff"], isHeader: true),
          SimpleAccordion(
            expanded: true,
            headerBuilder: (context, _) {
              final buff = func.buffs.first;
              return Padding(
                padding: const EdgeInsetsDirectional.only(start: 42),
                child: TextButton(
                  onPressed: () {
                    buff.routeTo(region: region);
                  },
                  style: kTextButtonDenseStyle,
                  child: Text(buff.lName.l),
                ),
              );
            },
            contentBuilder:
                (context) => Padding(
                  padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      border: Border.all(color: Theme.of(context).hintColor, width: 0.75),
                      borderRadius: BorderRadius.circular(5),
                    ),
                    position: DecorationPosition.foreground,
                    child: BuffInfoTable(buff: func.buffs.first),
                  ),
                ),
          ),
        ],
      ],
    );
  }

  Widget _buildTargetTraits() {
    final overwriteTvalsList = func.getOverwriteTvalsList();
    if (overwriteTvalsList.isNotEmpty) {
      return Text.rich(
        TextSpan(
          children: divideList([
            for (final traits in overwriteTvalsList)
              TextSpan(children: SharedBuilder.traitSpans(context: context, traits: traits, useAndJoin: true)),
          ], const TextSpan(text: '  /  ')),
        ),
      );
    } else {
      return func.functvals.isEmpty
          ? const Text('-')
          : SharedBuilder.traitList(context: context, traits: func.functvals);
    }
  }

  List<Widget> _buildScript() {
    List<Widget> children = [];
    final funcIndivs = func.script?.funcIndividuality ?? [], funcBaseIndivs = func.getCommonFuncIndividuality();
    if (funcIndivs.isNotEmpty || funcBaseIndivs.isNotEmpty) {
      children.add(
        CustomTableRow(
          children: [
            TableCellData(text: "funcIndividuality", isHeader: true),
            TableCellData(
              child: Text.rich(
                TextSpan(
                  children: divideList([
                    if (funcBaseIndivs.isNotEmpty)
                      TextSpan(children: SharedBuilder.traitSpans(context: context, traits: funcBaseIndivs)),
                    if (funcIndivs.isNotEmpty)
                      TextSpan(children: SharedBuilder.traitSpans(context: context, traits: funcIndivs)),
                  ], const TextSpan(text: ' + ')),
                ),
              ),
              flex: 3,
              alignment: AlignmentDirectional.centerEnd,
            ),
          ],
        ),
      );
    }
    if (children.isNotEmpty) {
      children.insert(0, CustomTableRow.fromTexts(texts: const ['Script'], isHeader: true));
    }
    return children;
  }
}

class _SkillTab extends StatelessWidget {
  final BaseFunction func;
  const _SkillTab(this.func);

  @override
  Widget build(BuildContext context) {
    final skills = db.gameData.baseSkills.values.where((e) => e.functions.any((f) => f.funcId == func.funcId)).toList();
    skills.sort2((e) => e.id);
    if (skills.isEmpty) {
      return const Center(child: Text('No local record'));
    }
    Map<int, List<GameCardMixin>> allCards = {
      for (final skill in skills) skill.id: ReverseGameData.skill2All(skill.id).toList(),
    };

    return ScrollControlWidget(
      builder: (context, controller) {
        return ListView.builder(
          itemBuilder: (context, index) {
            final skill = skills[index];
            final cards = allCards[skill.id] ?? [];
            return ListTile(
              dense: true,
              leading: skill.icon == null ? const SizedBox() : db.getIconImage(skill.icon, width: 28),
              title: Text('${skill.id} ${skill.lName.l}'),
              trailing:
                  cards.isEmpty
                      ? null
                      : Wrap(
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          ...cards.take(3).map((e) => e.iconBuilder(context: context, width: 32)),
                          if (cards.length > 3)
                            Text('+${cards.length - 3}', style: Theme.of(context).textTheme.bodySmall),
                        ],
                      ),
              onTap: skill.routeTo,
            );
          },
          itemCount: skills.length,
        );
      },
    );
  }
}

class _TdTab extends StatelessWidget {
  final BaseFunction func;
  const _TdTab(this.func);

  @override
  Widget build(BuildContext context) {
    final tds = db.gameData.baseTds.values.where((e) => e.functions.any((f) => f.funcId == func.funcId)).toList();
    tds.sort2((e) => e.id);
    if (tds.isEmpty) {
      return const Center(child: Text('No local record'));
    }
    Map<int, List<GameCardMixin>> allCards = {for (final td in tds) td.id: ReverseGameData.td2Svt(td.id).toList()};

    return ScrollControlWidget(
      builder: (context, controller) {
        return ListView.builder(
          itemBuilder: (context, index) {
            final td = tds[index];
            final cards = allCards[td.id] ?? [];
            cards.sort2((e) => e.collectionNo);
            return ListTile(
              dense: true,
              leading: CommandCardWidget(card: td.svt.card, width: 32),
              horizontalTitleGap: 6,
              contentPadding: const EdgeInsetsDirectional.only(start: 10, end: 16),
              title: Text('${td.id} ${td.lName.l}'),
              trailing:
                  cards.isEmpty
                      ? null
                      : Wrap(
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          ...cards.take(3).map((e) => e.iconBuilder(context: context, width: 32)),
                          if (cards.length > 3)
                            Text('+${cards.length - 3}', style: Theme.of(context).textTheme.bodySmall),
                        ],
                      ),
              onTap: td.routeTo,
            );
          },
          itemCount: tds.length,
        );
      },
    );
  }
}
