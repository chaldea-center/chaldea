import 'dart:async';

import 'package:flutter/material.dart';

import 'package:chaldea/app/api/atlas.dart';
import 'package:chaldea/app/app.dart';
import 'package:chaldea/app/modules/common/builders.dart';
import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/models/models.dart';
import 'package:chaldea/widgets/widgets.dart';
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

class _FuncDetailPageState extends State<FuncDetailPage> {
  bool loading = false;
  BaseFunction? _func;
  int get id => widget.func?.funcId ?? widget.id ?? _func?.funcId ?? 0;
  BaseFunction get func => _func!;

  @override
  void initState() {
    super.initState();
    fetchFunc();
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
        appBar: AppBar(title: Text('Func $id')),
        body: Center(
          child: loading
              ? const CircularProgressIndicator()
              : RefreshButton(onPressed: fetchFunc),
        ),
      );
    }
    return Scaffold(
      appBar: AppBar(title: Text("Func ${func.funcId} ${func.lPopupText.l}")),
      body: SingleChildScrollView(child: body),
    );
  }

  Widget get body {
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
      if (func.buffs.isNotEmpty)
        CustomTableRow(children: [
          TableCellData(
            text: "Buff",
            isHeader: true,
          ),
          TableCellData(
            child: Text.rich(SharedBuilder.textButtonSpan(
              context: context,
              text: func.buffs.first.lName.l,
              onTap: func.buffs.first.routeTo,
            )),
            flex: 3,
            alignment: AlignmentDirectional.centerEnd,
          )
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
    ]);
  }
}
