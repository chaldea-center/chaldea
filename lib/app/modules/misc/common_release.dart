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
  @protected
  const CommonReleasesPage({super.key, required List<CommonRelease> this.releases, this.region}) : id = null;
  const CommonReleasesPage.id({super.key, required int this.id, this.region}) : releases = null;

  @override
  State<CommonReleasesPage> createState() => _CommonReleasesPageState();
}

class _CommonReleasesPageState extends State<CommonReleasesPage>
    with RegionBasedState<List<CommonRelease>, CommonReleasesPage> {
  bool get useId => widget.id != null;

  @override
  void initState() {
    super.initState();
    region = widget.region ?? Region.jp;
    if (useId) {
      doFetchData();
    } else {
      data = widget.releases?.toList() ?? [];
      assert(data!.map((e) => e.id).toSet().length <= 1);
    }
  }

  @override
  Future<List<CommonRelease>?> fetchData(Region? r, {Duration? expireAfter}) {
    return AtlasApi.commonRelease(widget.id ?? 0, region: r ?? Region.jp, expireAfter: expireAfter);
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
    releases = releases.toList();
    Map<int, List<CommonRelease>> grouped = {};
    for (final release in releases) {
      grouped.putIfAbsent(release.condGroup, () => []).add(release);
    }

    List<Widget> children = [];
    for (final groupId in grouped.keys.toList()..sort()) {
      final rs = grouped[groupId]!;
      children.add(buildRelease(context, rs));
    }
    children.add(SafeArea(child: grouped.length > 1 ? SFooter(S.current.common_release_group_hint) : const SizedBox()));

    return ListView(children: divideTiles(children));
  }

  Widget buildRelease(BuildContext context, List<CommonRelease> releases) {
    final group = releases.first.condGroup;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ListTile(
          title: Text('Group $group'),
          leading: const Icon(Icons.group_work),
          minLeadingWidth: 28,
        ),
        for (final (index, release) in releases.enumerate)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: CondTargetValueDescriptor.commonRelease(
              commonRelease: release,
              leading: TextSpan(text: '${index + 1}. '),
            ),
          ),
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
          atlas: 'https://api.atlasacademy.io/nice/JP/common-release/${widget.id}'),
    );
  }
}
