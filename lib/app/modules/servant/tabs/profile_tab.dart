import 'package:flutter/material.dart';

import 'package:chaldea/app/api/atlas.dart';
import 'package:chaldea/app/modules/common/filter_group.dart';
import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/models/models.dart';
import 'package:chaldea/utils/utils.dart';
import 'package:chaldea/widgets/widgets.dart';

class SvtLoreTab extends StatefulWidget {
  final Servant svt;

  const SvtLoreTab({Key? key, required this.svt}) : super(key: key);

  @override
  State<SvtLoreTab> createState() => _SvtLoreTabState();
}

class _SvtLoreTabState extends State<SvtLoreTab> {
  late Region _region;
  Set<Region> releasedRegions = {};

  Servant? svt;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    releasedRegions.add(Region.jp);
    for (final r in Region.values) {
      if (isReleased(r)) {
        releasedRegions.add(r);
      }
    }
    if (releasedRegions.isEmpty) releasedRegions.add(Region.jp);
    _region =
        releasedRegions.contains(Transl.current) ? Transl.current : Region.jp;
    fetchSvt();
  }

  bool isReleased(Region r) {
    return db.gameData.mappingData.svtRelease
            .ofRegion(r)
            ?.contains(widget.svt.collectionNo) ==
        true;
  }

  void fetchSvt() async {
    _loading = true;
    svt = null;
    if (mounted) setState(() {});
    svt = await AtlasApi.svt(widget.svt.id, region: _region);
    _loading = false;
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> children = [];
    List<LoreComment> comments = List.of(svt?.profile.comments ?? []);
    comments.sort2((e) => e.id * 100 + e.priority);
    for (final lore in comments) {
      String title;
      if ([168, 240].contains(svt?.collectionNo)) {
        title = S.current.svt_profile_n(lore.id);
      } else {
        title = lore.id == 1
            ? S.current.svt_profile_info
            : S.current.svt_profile_n(lore.id - 1);
      }
      children.add(_profileCard(
        title: Text(title),
        subtitle: lore.condMessage.isEmpty ? null : Text(lore.condMessage),
        comment: lore.comment,
      ));
    }
    if (comments.isEmpty) {
      children.add(Center(
        child: Padding(
          padding: const EdgeInsets.all(48),
          child:
              _loading ? const CircularProgressIndicator() : const Text('???'),
        ),
      ));
    }

    if (!_loading) {
      for (final region in Region.values) {
        final text = widget.svt.extra.aprilFoolProfile.ofRegion(region);
        if (text == null) continue;
        children.add(_profileCard(
          title: Text(S.current.april_fool),
          subtitle: Text(region.toUpper()),
          comment: text,
        ));
      }
    }

    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            itemCount: children.length,
            itemBuilder: (context, index) => children[index],
          ),
        ),
        SafeArea(
          child: ButtonBar(
            alignment: MainAxisAlignment.center,
            children: [
              FilterGroup<Region>(
                combined: true,
                options: releasedRegions.toList(),
                optionBuilder: (v) => Text(v.name.toUpperCase()),
                values: FilterRadioData(_region),
                onFilterChanged: (v, _) {
                  if (v.radioValue != null) {
                    _region = v.radioValue!;
                    fetchSvt();
                  }
                  setState(() {});
                },
              )
            ],
          ),
        )
      ],
    );
  }

  Widget _profileCard(
      {required Widget title, Widget? subtitle, required String comment}) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      color: Theme.of(context).cardColor.withOpacity(0.975),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          CustomTile(
            title: title,
            subtitle: subtitle,
          ),
          CustomTile(subtitle: Text(comment)),
        ],
      ),
    );
  }
}
