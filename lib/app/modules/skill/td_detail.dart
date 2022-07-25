import 'dart:async';

import 'package:flutter/material.dart';

import 'package:chaldea/app/api/atlas.dart';
import 'package:chaldea/app/descriptors/skill_descriptor.dart';
import 'package:chaldea/app/modules/common/builders.dart';
import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/models/models.dart';
import 'package:chaldea/utils/utils.dart';
import 'package:chaldea/widgets/widgets.dart';

class TdDetailPage extends StatefulWidget {
  final int? id;
  final BaseTd? td;
  const TdDetailPage({Key? key, this.id, this.td})
      : assert(id != null || td != null),
        super(key: key);

  @override
  State<TdDetailPage> createState() => _TdDetailPageState();
}

class _TdDetailPageState extends State<TdDetailPage> {
  bool loading = false;
  BaseTd? _td;
  int get id => widget.td?.id ?? widget.id ?? _td?.id ?? -1;
  BaseTd get td => _td!;

  @override
  void initState() {
    super.initState();
    fetchTd();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> fetchTd() async {
    _td = null;
    loading = true;
    if (mounted) setState(() {});
    _td = widget.td ?? db.gameData.baseTds[widget.id] ?? await AtlasApi.td(id);
    loading = false;
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    if (_td == null) {
      return Scaffold(
        appBar: AppBar(
          title: Text('${S.current.noble_phantasm} $id'),
          actions: [if (id >= 0) popupMenu],
        ),
        body: Center(
          child: loading
              ? const CircularProgressIndicator()
              : RefreshButton(onPressed: fetchTd),
        ),
      );
    }
    final svts = ReverseGameData.td2Svt(id).toList()
      ..sort2((e) => e.collectionNo);

    return Scaffold(
      appBar: AppBar(
        title: Text(td.lName.l, overflow: TextOverflow.fade),
        actions: [popupMenu],
      ),
      body: ListView(
        children: [
          CustomTable(children: [
            CustomTableRow.fromTexts(texts: ['No.${td.id}'], isHeader: true),
            TdDescriptor(
              td: td,
              showEnemy: true,
              showNone: true,
              jumpToDetail: false,
            ),
            CustomTableRow(children: [
              TableCellData(text: S.current.info_trait, isHeader: true),
              TableCellData(
                flex: 3,
                child: SharedBuilder.traitList(
                    context: context, traits: td.individuality),
              )
            ]),
          ]),
          // info,
          // TdDescriptor(
          //   td: td,
          //   showEnemy: true,
          //   showNone: true,
          //   jumpToDetail: false,
          // ),
          if (svts.isNotEmpty) cardList(S.current.servant, svts),
        ],
      ),
    );
  }

  Widget get info {
    return CustomTable(children: [
      CustomTableRow.fromTexts(texts: ['No.${td.id}'], isHeader: true),
      CustomTableRow(children: [
        TableCellData(text: S.current.info_trait, isHeader: true),
        TableCellData(
            child: SharedBuilder.traitList(
                context: context, traits: td.individuality))
      ])
    ]);
  }

  Widget cardList(String header, List<GameCardMixin> cards) {
    return TileGroup(
      header: header,
      children: [
        for (final card in cards)
          ListTile(
            dense: true,
            leading: card.iconBuilder(context: context),
            title: Text(card.lName.l),
            onTap: card.routeTo,
          )
      ],
    );
  }

  Widget get popupMenu {
    return PopupMenuButton(
      itemBuilder: (context) =>
          SharedBuilder.websitesPopupMenuItems(atlas: Atlas.dbTd(id)),
    );
  }
}
