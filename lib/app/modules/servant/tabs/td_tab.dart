import 'package:flutter/material.dart';

import 'package:chaldea/app/descriptors/skill_descriptor.dart';
import 'package:chaldea/app/modules/common/filter_group.dart';
import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/models/models.dart';
import 'package:chaldea/utils/utils.dart';
import 'package:chaldea/widgets/widgets.dart';
import '../../../descriptors/cond_target_value.dart';

class SvtTdTab extends StatelessWidget {
  final Servant svt;

  const SvtTdTab({super.key, required this.svt});

  @override
  Widget build(BuildContext context) {
    List<Widget> children = [];
    final status = db.curUser.svtStatusOf(svt.collectionNo).cur;
    final overrideData = OverrideTDData.fromAscensionAdd(svt.ascensionAdd);
    for (final tds in svt.groupedNoblePhantasms) {
      List<NiceTd> shownTds = [];
      List<OverrideTDData?> overrideTds = [];
      for (final td in tds) {
        if (shownTds.every((e) => e.id != td.id)) {
          // ?
          shownTds.add(td);
          overrideTds.add(null);
        }
      }
      // not secure
      if (overrideData.isNotEmpty && tds.isNotEmpty) {
        for (final oTd in overrideData) {
          shownTds.add(tds.last);
          overrideTds.add(oTd);
        }
      }
      children.add(_buildTds(context, shownTds,
          status.favorite ? status.npLv : null, overrideTds));
    }

    return ListView.builder(
      itemCount: children.length,
      itemBuilder: (context, index) => children[index],
    );
  }

  Widget _buildTds(BuildContext context, List<NiceTd> tds, int? level,
      List<OverrideTDData?> overrideTds) {
    assert(tds.length == overrideTds.length);
    if (tds.length == 1 && tds.first.condQuestId <= 0) {
      return TdDescriptor(
        td: tds.first,
        showEnemy: !svt.isUserSvt,
        level: level,
        overrideData: overrideTds.getOrNull(0),
      );
    }
    NiceTd initTd = _getDefaultTd(tds) ?? tds.last;
    return ValueStatefulBuilder<int>(
      initValue: tds.indexOf(initTd),
      builder: (context, state) {
        final tdIndex = state.value;
        final td = tds[tdIndex];
        final oTdData = overrideTds.getOrNull(tdIndex);

        final toggle = Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: FilterGroup<int>(
                shrinkWrap: true,
                combined: true,
                options: List.generate(tds.length, (index) => index),
                optionBuilder: (v) {
                  String name = overrideTds.getOrNull(v)?.tdName ?? tds[v].name;
                  name = Transl.tdNames(name).l;
                  final rank = overrideTds.getOrNull(v)?.tdRank ?? tds[v].rank;
                  if (!['なし', '无', 'None', '無', '없음'].contains(rank)) {
                    name = '$name $rank';
                  }
                  return Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
                    child: Text(name),
                  );
                },
                values: FilterRadioData.nonnull(tdIndex),
                onFilterChanged: (v, _) {
                  state.value = v.radioValue!;
                  state.updateState();
                },
              ),
            ),
            if (td.condQuestId > 0 || oTdData != null)
              IconButton(
                padding: const EdgeInsets.all(2),
                constraints: const BoxConstraints(
                  minWidth: 48,
                  minHeight: 24,
                ),
                onPressed: () => showDialog(
                  context: context,
                  useRootNavigator: false,
                  builder: (context) => releaseCondition(context, td, oTdData),
                ),
                icon: const Icon(Icons.info_outline),
                color: Theme.of(context).hintColor,
                tooltip: S.current.open_condition,
              ),
          ],
        );
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 4),
            toggle,
            TdDescriptor(
              td: td,
              showEnemy: !svt.isUserSvt,
              level: level,
              overrideData: overrideTds.getOrNull(tdIndex),
            ),
          ],
        );
      },
    );
  }

  NiceTd? _getDefaultTd(List<NiceTd> tds) {
    tds = tds.where((e) => e.num > 0).toList();
    final priorities =
        db.gameData.mappingData.tdPriority[svt.id]?.ofRegion(db.curUser.region);
    if (svt.collectionNo == 1) {
      tds = tds.where((e) => priorities?[e.id] != null).toList();
    }
    if (tds.isEmpty) return null;
    if (db.curUser.region == Region.jp) {
      return Maths.findMax<NiceTd, int>(tds, (e) => e.priority);
    } else {
      return Maths.findMax<NiceTd, int>(tds, (e) => priorities?[e.id] ?? -1);
    }
  }

  Widget releaseCondition(
      BuildContext context, NiceTd td, OverrideTDData? overrideTDData) {
    bool notMain = ['91', '94']
        .contains(td.condQuestId.toString().padRight(2).substring(0, 2));
    final quest = db.gameData.quests[td.condQuestId];
    final jpTime = quest?.openedAt,
        localTime = db.gameData.mappingData.questRelease[td.condQuestId]
            ?.ofRegion(db.curUser.region);
    final keys = overrideTDData?.keys ?? [];
    List<int> ascensions = [], costumes = [];
    for (final key in keys) {
      key < 10 ? ascensions.add(key) : costumes.add(key);
    }
    return SimpleCancelOkDialog(
      title: Text(td.lName.l),
      hideCancel: true,
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (td.condQuestId > 0)
            CondTargetValueDescriptor(
              condType:
                  notMain ? CondType.questClear : CondType.questClearPhase,
              target: td.condQuestId,
              value: td.condQuestPhase,
            ),
          if (ascensions.isNotEmpty)
            Text('${S.current.ascension_short} ${ascensions.join('&')}'),
          if (costumes.isNotEmpty)
            Text([
              '${S.current.costume}:',
              for (final c in costumes)
                svt.profile.costume[c]?.lName.l ?? c.toString()
            ].join(' ')),
          if (jpTime != null) Text('JP: ${jpTime.sec2date().toDateString()}'),
          if (db.curUser.region != Region.jp && localTime != null)
            Text(
                '${db.curUser.region.upper}: ${localTime.sec2date().toDateString()}'),
        ],
      ),
    );
  }
}
