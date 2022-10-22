import 'dart:async';

import 'package:chaldea/app/api/atlas.dart';
import 'package:chaldea/app/descriptors/skill_descriptor.dart';
import 'package:chaldea/app/modules/common/builders.dart';
import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/models/models.dart';
import 'package:chaldea/utils/utils.dart';
import 'package:chaldea/widgets/region_based.dart';
import 'package:chaldea/widgets/widgets.dart';

class TdDetailPage extends StatefulWidget {
  final int? id;
  final BaseTd? td;
  final Region? region;
  const TdDetailPage({super.key, this.id, this.td, this.region})
      : assert(id != null || td != null);

  @override
  State<TdDetailPage> createState() => _TdDetailPageState();
}

class _TdDetailPageState extends State<TdDetailPage>
    with RegionBasedState<BaseTd, TdDetailPage> {
  int get id => widget.td?.id ?? widget.id ?? data?.id ?? -1;
  BaseTd get td => data!;

  @override
  void initState() {
    super.initState();
    region = widget.region ?? (widget.td == null ? Region.jp : null);
    doFetchData();
  }

  @override
  Future<BaseTd?> fetchData(Region? r) async {
    BaseTd? v;
    if (r == null || r == widget.region) v = widget.td;
    if (r == Region.jp) {
      v ??= db.gameData.baseTds[id];
    }
    v ??= await AtlasApi.td(id, region: r ?? Region.jp);
    return v;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          data?.lName.l ?? '${S.current.noble_phantasm} $id',
          overflow: TextOverflow.fade,
        ),
        actions: [
          dropdownRegion(shownNone: widget.td != null),
          popupMenu,
        ],
      ),
      body: buildBody(context),
    );
  }

  @override
  Widget buildContent(BuildContext context, BaseTd td) {
    final svts = ReverseGameData.td2Svt(id).toList()
      ..sort2((e) => e.collectionNo);

    return ListView(
      children: [
        CustomTable(children: [
          CustomTableRow.fromTexts(texts: ['No.${td.id}'], isHeader: true),
          TdDescriptor(
            td: td,
            showEnemy: true,
            showNone: true,
            jumpToDetail: false,
            region: region,
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
        if (svts.isNotEmpty) cardList(S.current.servant, svts),
      ],
    );
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
      itemBuilder: (context) => SharedBuilder.websitesPopupMenuItems(
          atlas: Atlas.dbTd(id, region ?? Region.jp)),
    );
  }
}
