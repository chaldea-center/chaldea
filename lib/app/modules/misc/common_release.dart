import 'dart:async';

import 'package:flutter/foundation.dart';

import 'package:auto_size_text/auto_size_text.dart';

import 'package:chaldea/app/api/atlas.dart';
import 'package:chaldea/app/descriptors/cond_target_value.dart';
import 'package:chaldea/app/modules/common/builders.dart';
import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/models/models.dart';
import 'package:chaldea/utils/utils.dart';
import 'package:chaldea/widgets/region_based.dart';
import 'package:chaldea/widgets/widgets.dart';

class CommonReleasesPage extends StatefulWidget {
  final int? id;
  final List<CommonRelease>? releases;
  final Region? region;
  const CommonReleasesPage(
      {super.key, required List<CommonRelease> this.releases, this.region})
      : id = null;
  const CommonReleasesPage.id({super.key, required int this.id, this.region})
      : releases = null;

  @override
  State<CommonReleasesPage> createState() => _CommonReleasesPageState();
}

class _CommonReleasesPageState extends State<CommonReleasesPage>
    with RegionBasedState<List<CommonRelease>, CommonReleasesPage> {
  List<CommonRelease> get skill => data!;

  bool get useId => widget.id != null;

  @override
  void initState() {
    super.initState();
    region = widget.region ?? Region.jp;
    if (useId) doFetchData();
  }

  @override
  Future<List<CommonRelease>?> fetchData(Region? r) {
    return AtlasApi.commonRelease(widget.id ?? 0, region: r ?? Region.jp);
  }

  @override
  Widget build(BuildContext context) {
    return InheritSelectionArea(
      child: Scaffold(
        appBar: AppBar(
          title: AutoSizeText(
            useId ? 'Common Release ${widget.id}' : 'Common Release',
            overflow: TextOverflow.fade,
            maxLines: 1,
            minFontSize: 6,
          ),
          actions: [
            if (useId) dropdownRegion(),
            if (useId && kDebugMode) popupMenu,
          ],
        ),
        body: buildBody(context),
      ),
    );
  }

  @override
  Widget buildContent(BuildContext context, List<CommonRelease> releases) {
    if (useId) {
      releases = releases.toList();
      releases.sort2((e) => e.priority);
    }
    return ListView.separated(
      itemBuilder: (context, index) =>
          buildRelease(context, index, releases[index], !useId),
      separatorBuilder: (context, index) => const DividerWithTitle(
        height: 36,
        title: '·  ·  ·  ·  ·  ·',
        indent: 16,
        thickness: 1,
      ),
      itemCount: releases.length,
    );
  }

  Widget buildRelease(
      BuildContext context, int index, CommonRelease release, bool enableLink) {
    final title = '$index  -  ${release.id}';
    return CustomTable(children: [
      enableLink
          ? CustomTableRow(children: [
              TableCellData(
                child: SizedBox(
                  width: double.infinity,
                  child: TextButton(
                    onPressed: release.routeTo,
                    style: kTextButtonDenseStyle,
                    child: Text(title),
                  ),
                ),
                isHeader: true,
              )
            ])
          : CustomTableRow.fromTexts(texts: [title], isHeader: true),
      CustomTableRow(children: [
        TableCellData(
          child: CondTargetValueDescriptor.commonRelease(
            commonRelease: release,
            leading: const TextSpan(text: kULLeading),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        )
      ]),
      CustomTableRow.fromTexts(texts: [S.current.general_type], isHeader: true),
      CustomTableRow.fromTexts(texts: [release.condType.name]),
      CustomTableRow.fromTexts(
        texts: const ['Group', 'Priority', 'CondId', 'CondNum'],
        isHeader: true,
      ),
      CustomTableRow.fromTexts(
        texts: [
          release.condGroup.toString(),
          release.priority.toString(),
          release.condId.toString(),
          release.condNum.toString()
        ],
      ),
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
      itemBuilder: (context) => SharedBuilder.websitesPopupMenuItems(
          atlas:
              'https://api.atlasacademy.io/nice/JP/common-release/${widget.id}'),
    );
  }
}
