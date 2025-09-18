import 'dart:async';

import 'package:auto_size_text/auto_size_text.dart';

import 'package:chaldea/app/api/atlas.dart';
import 'package:chaldea/app/modules/common/builders.dart';
import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/models/gamedata/raw.dart';
import 'package:chaldea/models/models.dart';
import 'package:chaldea/utils/utils.dart';
import 'package:chaldea/widgets/region_based.dart';
import 'package:chaldea/widgets/widgets.dart';

class QuestDateRangePage extends StatefulWidget {
  final int? id;
  final List<QuestDateRange>? ranges;
  final Region? region;
  @protected
  const QuestDateRangePage({super.key, required List<QuestDateRange> this.ranges, this.region}) : id = null;
  const QuestDateRangePage.id({super.key, required int this.id, this.region}) : ranges = null;

  @override
  State<QuestDateRangePage> createState() => _QuestDateRangePageState();
}

class _QuestDateRangePageState extends State<QuestDateRangePage>
    with RegionBasedState<List<QuestDateRange>, QuestDateRangePage> {
  bool get useId => widget.id != null;

  @override
  void initState() {
    super.initState();
    region = widget.region ?? Region.jp;
    if (useId) {
      doFetchData();
    } else {
      data = widget.ranges?.toList() ?? [];
      assert(data!.map((e) => e.id).toSet().length <= 1);
    }
  }

  @override
  Future<List<QuestDateRange>?> fetchData(Region? r, {Duration? expireAfter}) {
    return AtlasApi.questDateRange(widget.id ?? 0, region: r ?? Region.jp, expireAfter: expireAfter);
  }

  @override
  Widget build(BuildContext context) {
    return InheritSelectionArea(
      child: Scaffold(
        appBar: AppBar(
          title: AutoSizeText(
            useId ? 'Date Range ${widget.id}' : 'Date Range',
            overflow: TextOverflow.fade,
            maxLines: 1,
            minFontSize: 6,
          ),
          actions: [if (useId) dropdownRegion(), popupMenu],
        ),
        body: buildBody(context),
      ),
    );
  }

  @override
  Widget buildContent(BuildContext context, List<QuestDateRange> ranges) {
    ranges = ranges.toList();
    Map<int, List<QuestDateRange>> grouped = {};
    for (final range in ranges) {
      grouped.putIfAbsent(range.id, () => []).add(range);
    }

    List<Widget> children = [];
    for (final groupId in grouped.keys.toList()..sort()) {
      final rs = grouped[groupId]!;
      children.add(buildRange(context, rs));
    }
    children.add(SafeArea(child: grouped.length > 1 ? SFooter(S.current.common_release_group_hint) : const SizedBox()));

    return ListView(children: divideTiles(children));
  }

  Widget buildRange(BuildContext context, List<QuestDateRange> ranges) {
    ranges = ranges.toList()..sort((a, b) => a.idx - b.idx);
    final now = DateTime.now().timestamp;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final range in ranges)
          ListTile(
            title: Text('${range.id}   idx ${range.idx}'),
            subtitle: Text(
              [range.openedAt, range.closedAt].map((e) => e.sec2date().toStringShort()).join(' ~ '),
              style: range.openedAt <= now && now <= range.closedAt ? TextStyle(color: Colors.blue) : null,
            ),
            leading: const Icon(Icons.group_work),
            minLeadingWidth: 28,
          ),
      ],
    );
  }

  Widget get popupMenu {
    final ids = <int>{if (widget.id != null) widget.id!, ...?data?.map((e) => e.id)};
    return PopupMenuButton(
      itemBuilder: (context) => [
        for (final id in ids)
          ...SharedBuilder.websitesPopupMenuItems(
            atlas: 'https://api.atlasacademy.io/raw/${(region ?? Region.jp).upper}/quest-date-range/$id',
          ),
      ],
    );
  }
}
