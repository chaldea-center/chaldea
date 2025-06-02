import 'dart:async';

import 'package:auto_size_text/auto_size_text.dart';

import 'package:chaldea/app/api/atlas.dart';
import 'package:chaldea/app/descriptors/cond_target_value.dart';
import 'package:chaldea/app/modules/common/builders.dart';
import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/models/models.dart';
import 'package:chaldea/utils/utils.dart';
import 'package:chaldea/widgets/region_based.dart';
import 'package:chaldea/widgets/widgets.dart';

class MstGiftPage extends StatefulWidget {
  final int? id;
  // final List<Gift>? gifts;
  final Region? region;
  const MstGiftPage({super.key, this.id, this.region});

  @override
  State<MstGiftPage> createState() => _MstGiftPageState();
}

class _MstGiftPageState extends State<MstGiftPage> with RegionBasedState<List<Gift>, MstGiftPage> {
  int get id => widget.id ?? data?.firstOrNull?.id ?? 0;
  // List<Gift> get gifts => data!;

  @override
  void initState() {
    super.initState();
    region = widget.region ?? Region.jp;
    doFetchData();
  }

  @override
  Future<List<Gift>?> fetchData(Region? r, {Duration? expireAfter}) async {
    return AtlasApi.gift(id, region: r ?? Region.jp, expireAfter: expireAfter);
  }

  @override
  Widget build(BuildContext context) {
    return InheritSelectionArea(
      child: Scaffold(
        appBar: AppBar(
          title: AutoSizeText('Gift $id', overflow: TextOverflow.fade, maxLines: 1, minFontSize: 14),
          actions: [dropdownRegion(shownNone: false), popupMenu],
        ),
        body: buildBody(context),
      ),
    );
  }

  @override
  Widget buildContent(BuildContext context, List<Gift> gifts) {
    List<Widget> children = [
      CustomTable(
        children: [
          CustomTableRow.fromTexts(texts: ['Gift $id'], isHeader: true),
          CustomTableRow.fromChildren(
            children: [
              Wrap(
                spacing: 2,
                runSpacing: 2,
                alignment: WrapAlignment.center,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [for (final gift in gifts) gift.iconBuilder(context: context, width: 36)],
              ),
            ],
          ),
        ],
      ),
    ];

    final giftAdds = gifts.firstOrNull?.giftAdds ?? [];
    for (final (index, giftAdd) in giftAdds.indexed) {
      children.add(
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          decoration: BoxDecoration(
            border: Border.fromBorderSide(Divider.createBorderSide(context)),
            borderRadius: BorderRadius.circular(8),
          ),
          child: buildGiftAdd(index, giftAdd),
        ),
      );
    }
    return ListView(children: children);
  }

  Widget buildGiftAdd(int index, GiftAdd giftAdd) {
    return CustomTable(
      children: [
        CustomTableRow.fromTexts(texts: ['>>> Replacement ${index + 1} <<<'], isHeader: true),
        CustomTableRow.fromChildren(
          children: [
            Text.rich(
              TextSpan(
                children: [
                  CenterWidgetSpan(child: CachedImage(imageUrl: giftAdd.replacementGiftIcon, width: 36)),
                  TextSpan(text: ' priority ${giftAdd.priority}'),
                ],
              ),
            ),
          ],
        ),
        CustomTableRow.fromTexts(texts: [S.current.condition], isHeader: true),
        CustomTableRow.fromChildren(
          children: [
            CondTargetValueDescriptor(condType: giftAdd.condType, target: giftAdd.targetId, value: giftAdd.targetNum),
          ],
        ),
        CustomTableRow.fromTexts(
          texts: ['Replacement Gift ${giftAdd.replacementGifts.firstOrNull?.id}'],
          isHeader: true,
        ),
        CustomTableRow.fromChildren(
          children: [
            Wrap(
              spacing: 2,
              runSpacing: 2,
              alignment: WrapAlignment.center,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [for (final gift in giftAdd.replacementGifts) gift.iconBuilder(context: context, width: 36)],
            ),
          ],
        ),
      ],
    );
  }

  Widget get popupMenu {
    return PopupMenuButton(
      itemBuilder: (context) => [
        ...SharedBuilder.websitesPopupMenuItems(
          atlas: '${AtlasApi.atlasApiHost}/nice/${region?.upper ?? "JP"}/gift/$id',
        ),
      ],
    );
  }
}
