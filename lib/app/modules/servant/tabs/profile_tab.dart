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

enum _WikiSource {
  mc,
  fandom,
  aprilFool,
}

class _SvtLoreTabState extends State<SvtLoreTab> {
  _WikiSource? _wikiSource;
  Region? _region;
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
    fetchSvt(_region!);
  }

  bool isReleased(Region r) {
    final released = db.gameData.mappingData.svtRelease.ofRegion(r);
    return released?.contains(widget.svt.collectionNo) == true;
  }

  void fetchSvt(Region r) async {
    _loading = true;
    svt = null;
    if (mounted) setState(() {});
    final result = await AtlasApi.svt(widget.svt.id, region: r);
    if (r == _region) {
      svt = result;
    }
    _loading = false;
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> children = [];
    if (_region != null) {
      children.addAll(_addRegionProfile());
    } else if (_wikiSource == _WikiSource.mc) {
      children.addAll(_addWikiProfile(widget.svt.extra.mcProfiles));
    } else if (_wikiSource == _WikiSource.fandom) {
      children.addAll(_addWikiProfile(widget.svt.extra.fandomProfiles));
    } else if (_wikiSource == _WikiSource.aprilFool) {
      children.addAll(_addAprilFool());
    }

    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            itemCount: children.length,
            itemBuilder: (context, index) => children[index],
          ),
        ),
        SafeArea(child: buttonBar)
      ],
    );
  }

  Widget get buttonBar {
    final hasMC = widget.svt.extra.mcProfiles.isNotEmpty,
        hasFandom = widget.svt.extra.fandomProfiles.isNotEmpty,
        hasApril =
            widget.svt.extra.aprilFoolProfile.values.any((e) => e != null);
    return ButtonBar(
      alignment: MainAxisAlignment.center,
      children: [
        FilterGroup<Region>(
          combined: true,
          padding: EdgeInsets.zero,
          options: releasedRegions.toList(),
          optionBuilder: (v) => Text(v.toUpper()),
          values: FilterRadioData(_region),
          onFilterChanged: (v, _) {
            if (v.radioValue != null) {
              _region = v.radioValue!;
              _wikiSource = null;
              fetchSvt(_region!);
            }
            setState(() {});
          },
        ),
        if (hasMC || hasFandom || hasApril)
          FilterGroup<_WikiSource>(
            combined: true,
            padding: EdgeInsets.zero,
            options: [
              if (hasMC) _WikiSource.mc,
              if (hasFandom) _WikiSource.fandom,
              if (hasApril) _WikiSource.aprilFool,
            ],
            optionBuilder: (v) {
              switch (v) {
                case _WikiSource.mc:
                  return const Text('MC');
                case _WikiSource.fandom:
                  return const Text('Fandom');
                case _WikiSource.aprilFool:
                  return Text(S.current.april_fool);
              }
            },
            values: FilterRadioData(_wikiSource),
            onFilterChanged: (v, _) {
              if (v.radioValue != null) {
                _wikiSource = v.radioValue!;
                _region = null;
              }
              setState(() {});
            },
          ),
      ],
    );
  }

  List<Widget> _addRegionProfile() {
    List<Widget> children = [];
    List<LoreComment> comments = List.of(svt?.profile.comments ?? []);
    Map<int, List<LoreComment>> grouped = {};
    for (final lore in comments) {
      grouped.putIfAbsent(lore.priority, () => []).add(lore);
    }
    comments.clear();
    for (final priority in grouped.keys.toList()..sort()) {
      comments.addAll(grouped[priority]!..sort2((e) => e.id));
    }
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
          child: _loading
              ? const CircularProgressIndicator()
              : RefreshButton(
                  text: '???',
                  onPressed: () {
                    if (_region != null) {
                      fetchSvt(_region!);
                    }
                  },
                ),
        ),
      ));
    }
    return children;
  }

  List<Widget> _addWikiProfile(Map<int, List<String>> profiles) {
    List<Widget> children = [];
    final keys = profiles.keys.toList()..sort();
    int maxLength = Maths.max(profiles.values.map((e) => e.length), 0);
    for (int priority = 0; priority < maxLength; priority++) {
      for (final index in keys) {
        final profile = profiles[index]?.getOrNull(priority);
        if (profile == null) continue;
        String title;
        if ([168, 240].contains(svt?.collectionNo)) {
          title = S.current.svt_profile_n(index + 1);
        } else {
          title = index == 0
              ? S.current.svt_profile_info
              : S.current.svt_profile_n(index);
        }
        children.add(_profileCard(title: Text(title), comment: profile));
      }
    }
    return children;
  }

  List<Widget> _addAprilFool() {
    List<Widget> children = [];
    for (final region in Region.values) {
      final text = widget.svt.extra.aprilFoolProfile.ofRegion(region);
      if (text == null) continue;
      children.add(_profileCard(
        title: Text(S.current.april_fool),
        subtitle: Text(region.toUpper()),
        comment: text,
      ));
    }
    return children;
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
