import 'package:flutter/material.dart';

import 'package:chaldea/app/descriptors/cond_target_value.dart';
import 'package:chaldea/app/modules/summon/gacha/gacha_banner.dart';
import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/models/gamedata/mst_data.dart';
import 'package:chaldea/models/models.dart';
import 'package:chaldea/utils/utils.dart';

class SelectGachaSubPage extends StatefulWidget {
  final Region region;
  final MasterDataManager mstData;
  final NiceGacha gacha;
  final ValueChanged<GachaSub?>? onSelected;
  const SelectGachaSubPage({
    super.key,
    required this.region,
    required this.mstData,
    required this.gacha,
    this.onSelected,
  });

  @override
  State<SelectGachaSubPage> createState() => _SelectGachaSubPageState();
}

class _SelectGachaSubPageState extends State<SelectGachaSubPage> {
  bool timeValidOnly = true;

  @override
  Widget build(BuildContext context) {
    final subs = timeValidOnly ? widget.gacha.getValidGachaSubs() : widget.gacha.gachaSubs.toList();
    subs.sort2((e) => -e.priority);
    return Scaffold(
      appBar: AppBar(
        title: Text("Subs: ${widget.gacha.lName}", maxLines: 1, overflow: TextOverflow.ellipsis),
        actions: [
          IconButton(
            onPressed: () {
              setState(() {
                timeValidOnly = !timeValidOnly;
              });
            },
            icon: Icon(timeValidOnly ? Icons.timer : Icons.timer_off),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: subs.length,
              itemBuilder: (context, index) => buildSub(context, subs[index]),
            ),
          ),
          if (widget.onSelected != null)
            SafeArea(
              child: OverflowBar(
                children: [
                  FilledButton(
                    onPressed: () {
                      Navigator.pop(context);
                      widget.onSelected!(null);
                    },
                    child: Text('Set Base 0'),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget buildSub(BuildContext context, GachaSub sub) {
    final imageId = sub.imageId == 0 ? widget.gacha.imageId : sub.imageId;
    final now = DateTime.now().timestamp;
    bool hasFailed = sub.openedAt > now || sub.closedAt <= now;

    List<Widget> releases = [];
    final showCondGroup = sub.releaseConditions.map((e) => e.condGroup).toSet().length != 1;
    Map<int, Set<bool?>> condMatches = {};
    for (final release in sub.releaseConditions) {
      List<InlineSpan> leading = [];
      if (showCondGroup) {
        leading.add(TextSpan(text: '[${release.condGroup}]'));
      }
      bool? matchCond;
      if (release.condType == CondType.questClear) {
        matchCond = (widget.mstData.userQuest[release.condId]?.clearNum ?? 0) > 0;
      } else if (release.condType == CondType.questNotClear) {
        matchCond = (widget.mstData.userQuest[release.condId]?.clearNum ?? 0) <= 0;
      } else if (release.condType == CondType.eventScriptPlay) {
        final scriptFlag = widget.mstData.userEvent[release.condId]?.scriptFlag;
        matchCond = scriptFlag != null && (scriptFlag & (1 << release.condNum) != 0);
      }
      if (matchCond == null) {
        leading.add(
          TextSpan(
            text: '? ',
            style: TextStyle(color: Colors.red),
          ),
        );
      } else if (matchCond) {
        leading.add(
          TextSpan(
            text: '⎷ ',
            style: TextStyle(color: Colors.green),
          ),
        );
      } else {
        leading.add(
          TextSpan(
            text: '× ',
            style: TextStyle(color: Colors.red),
          ),
        );
      }
      condMatches.putIfAbsent(release.condGroup, () => {}).add(matchCond);
      releases.add(
        CondTargetValueDescriptor.commonRelease(
          padding: EdgeInsets.symmetric(horizontal: 16),
          commonRelease: release,
          leading: TextSpan(children: leading),
        ),
      );
    }
    if (condMatches.isNotEmpty && condMatches.values.every((e) => e.contains(false))) {
      hasFailed = true;
    }
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        GachaBanner(region: widget.region, imageId: imageId),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: Wrap(
            spacing: 4,
            alignment: WrapAlignment.center,
            children: [
              Text('sub ${sub.id}  priority ${sub.priority}', textAlign: TextAlign.center),
              Text(
                [sub.openedAt, sub.closedAt].map((e) => e.sec2date().toStringShort(omitSec: true)).join(' ~ '),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
        ...releases,
        if (widget.onSelected != null)
          FilledButton(
            onPressed: hasFailed
                ? null
                : () {
                    Navigator.pop(context, sub);
                    widget.onSelected!(sub);
                  },
            child: Text(S.current.select),
          ),
        const SizedBox(height: 8),
      ],
    );
  }
}
