import 'dart:async';

import 'package:flutter/material.dart';

import 'package:chaldea/app/api/atlas.dart';
import 'package:chaldea/app/app.dart';
import 'package:chaldea/app/modules/buff/buff_detail.dart';
import 'package:chaldea/app/modules/common/builders.dart';
import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/models/models.dart';
import 'package:chaldea/utils/utils.dart';
import 'package:chaldea/widgets/widgets.dart';
import '../common/misc.dart';
import 'func_list.dart';

class FuncDetailPage extends StatefulWidget {
  final int? id;
  final BaseFunction? func;
  const FuncDetailPage({Key? key, this.id, this.func})
      : assert(id != null || func != null),
        super(key: key);

  @override
  State<FuncDetailPage> createState() => _FuncDetailPageState();
}

class _FuncDetailPageState extends State<FuncDetailPage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController =
      TabController(length: 3, vsync: this);
  bool loading = false;
  BaseFunction? _func;
  int get id => widget.func?.funcId ?? widget.id ?? _func?.funcId ?? -1;
  BaseFunction get func => _func!;

  @override
  void initState() {
    super.initState();
    fetchFunc();
  }

  @override
  void dispose() {
    super.dispose();
    _tabController.dispose();
  }

  Future<void> fetchFunc() async {
    _func = null;
    loading = true;
    if (mounted) setState(() {});
    _func = widget.func ??
        db.gameData.baseFunctions[widget.id] ??
        await AtlasApi.func(id);
    loading = false;
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    if (_func == null) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Func $id'),
          actions: [if (id >= 0) popupMenu],
        ),
        body: Center(
          child: loading
              ? const CircularProgressIndicator()
              : RefreshButton(onPressed: fetchFunc),
        ),
      );
    }
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Func ${func.funcId} ${func.lPopupText.l}",
          overflow: TextOverflow.fade,
        ),
        actions: [popupMenu],
        bottom: FixedHeight.tabBar(TabBar(controller: _tabController, tabs: [
          const Tab(text: "Info"),
          Tab(text: S.current.skill),
          Tab(text: S.current.noble_phantasm),
        ])),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          SingleChildScrollView(child: FuncInfoTable(func: func)),
          _SkillTab(func),
          _TdTab(func),
        ],
      ),
    );
  }

  Widget get popupMenu {
    return PopupMenuButton(
      itemBuilder: (context) =>
          SharedBuilder.websitesPopupMenuItems(atlas: Atlas.dbFunc(id)),
    );
  }
}

class FuncInfoTable extends StatelessWidget {
  final BaseFunction func;
  const FuncInfoTable({Key? key, required this.func}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CustomTable(children: [
      CustomTableRow(children: [
        TableCellData(
          child: Text.rich(TextSpan(children: [
            if (func.funcPopupIcon != null)
              CenterWidgetSpan(
                  child: db.getIconImage(func.funcPopupIcon, width: 24)),
            TextSpan(text: ' ${func.lPopupText.l}'),
          ])),
          isHeader: true,
        )
      ]),
      if (!Transl.isJP) CustomTableRow.fromTexts(texts: [func.lPopupText.jp]),
      CustomTableRow(children: [
        TableCellData(
          text: 'ID',
          isHeader: true,
        ),
        TableCellData(
          text: func.funcId.toString(),
          flex: 3,
          alignment: AlignmentDirectional.centerEnd,
        ),
      ]),
      CustomTableRow(children: [
        TableCellData(
          text: S.current.general_type,
          isHeader: true,
          textAlign: TextAlign.start,
        ),
        TableCellData(
          child: Text.rich(
            SharedBuilder.textButtonSpan(
              context: context,
              text:
                  '(${func.funcType.name}) ${Transl.funcType(func.funcType).l}',
              onTap: () {
                router.push(
                    url: Routes.funcs,
                    child: FuncListPage(type: func.funcType));
              },
            ),
            textAlign: TextAlign.end,
          ),
          flex: 3,
          alignment: AlignmentDirectional.centerEnd,
        ),
      ]),
      CustomTableRow(children: [
        TableCellData(
          text: "Target",
          isHeader: true,
        ),
        TableCellData(
          text: Transl.funcTargetType(func.funcTargetType).l,
          flex: 3,
          alignment: AlignmentDirectional.centerEnd,
        ),
      ]),
      CustomTableRow.fromTexts(
          texts: [S.current.effective_condition], isHeader: true),
      CustomTableRow(children: [
        TableCellData(
          text: "Target Team",
          isHeader: true,
        ),
        TableCellData(
          text: func.funcTargetTeam.name,
          flex: 3,
          alignment: AlignmentDirectional.centerEnd,
        ),
      ]),
      CustomTableRow(children: [
        TableCellData(
          text: "Target Traits",
          isHeader: true,
        ),
        TableCellData(
          child: func.functvals.isEmpty
              ? const Text('-')
              : SharedBuilder.traitList(
                  context: context, traits: func.functvals),
          flex: 3,
          alignment: AlignmentDirectional.centerEnd,
        )
      ]),
      if (func.funcquestTvals.isNotEmpty)
        CustomTableRow(children: [
          TableCellData(
            text: "Quest Traits",
            isHeader: true,
          ),
          TableCellData(
            child: SharedBuilder.traitList(
                context: context, traits: func.funcquestTvals),
            flex: 3,
            alignment: AlignmentDirectional.centerEnd,
          )
        ]),
      if (func.traitVals.isNotEmpty)
        CustomTableRow(children: [
          TableCellData(
            text: "Affects Traits",
            isHeader: true,
          ),
          TableCellData(
            child: SharedBuilder.traitList(
                context: context, traits: func.traitVals),
            flex: 3,
            alignment: AlignmentDirectional.centerEnd,
          )
        ]),
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
                  buff.routeTo(child: BuffDetailPage(buff: buff));
                },
                style: kTextButtonDenseStyle,
                child: Text(buff.lName.l),
              ),
            );
          },
          contentBuilder: (context) => Padding(
            padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
            child: DecoratedBox(
              decoration: BoxDecoration(
                  border: Border.all(
                      color: Theme.of(context).hintColor, width: 0.75),
                  borderRadius: BorderRadius.circular(5)),
              position: DecorationPosition.foreground,
              child: BuffInfoTable(buff: func.buffs.first),
            ),
          ),
        ),
      ],
    ]);
  }
}

class _SkillTab extends StatelessWidget {
  final BaseFunction func;
  const _SkillTab(this.func, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final skills = db.gameData.baseSkills.values
        .where((e) => e.functions.any((f) => f.funcId == func.funcId))
        .toList();
    skills.sort2((e) => e.id);
    if (skills.isEmpty) {
      return const Center(child: Text('No local record'));
    }
    Map<int, List<GameCardMixin>> allCards = {
      for (final skill in skills)
        skill.id: ReverseGameData.skill2All(skill.id).toList()
    };

    return ScrollControlWidget(
      builder: (context, controller) {
        return ListView.builder(
          itemBuilder: (context, index) {
            final skill = skills[index];
            final cards = allCards[skill.id] ?? [];
            return ListTile(
              dense: true,
              leading: skill.icon == null
                  ? const SizedBox()
                  : db.getIconImage(skill.icon, width: 28),
              horizontalTitleGap: 0,
              title: Text('${skill.id} ${skill.lName.l}'),
              trailing: cards.isEmpty
                  ? null
                  : Wrap(
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        ...cards.take(3).map(
                            (e) => e.iconBuilder(context: context, width: 32)),
                        if (cards.length > 3)
                          Text(
                            '+${cards.length - 3}',
                            style: Theme.of(context).textTheme.caption,
                          )
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
  const _TdTab(this.func, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final tds = db.gameData.baseTds.values
        .where((e) => e.functions.any((f) => f.funcId == func.funcId))
        .toList();
    tds.sort2((e) => e.id);
    if (tds.isEmpty) {
      return const Center(child: Text('No local record'));
    }
    Map<int, List<GameCardMixin>> allCards = {
      for (final td in tds) td.id: ReverseGameData.td2Svt(td.id).toList()
    };

    return ScrollControlWidget(
      builder: (context, controller) {
        return ListView.builder(
          itemBuilder: (context, index) {
            final td = tds[index];
            final cards = allCards[td.id] ?? [];
            cards.sort2((e) => e.collectionNo);
            return ListTile(
              dense: true,
              leading: CommandCardWidget(card: td.card, width: 32),
              horizontalTitleGap: 6,
              contentPadding:
                  const EdgeInsetsDirectional.only(start: 10, end: 16),
              title: Text('${td.id} ${td.lName.l}'),
              trailing: cards.isEmpty
                  ? null
                  : Wrap(
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        ...cards.take(3).map(
                            (e) => e.iconBuilder(context: context, width: 32)),
                        if (cards.length > 3)
                          Text(
                            '+${cards.length - 3}',
                            style: Theme.of(context).textTheme.caption,
                          )
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
