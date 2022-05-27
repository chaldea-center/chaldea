import 'package:flutter/material.dart';

import 'package:chaldea/app/descriptors/skill_descriptor.dart';
import 'package:chaldea/app/modules/common/filter_group.dart';
import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/models/models.dart';
import 'package:chaldea/utils/utils.dart';
import 'package:chaldea/widgets/widgets.dart';

class SvtTdTab extends StatelessWidget {
  final Servant svt;

  const SvtTdTab({Key? key, required this.svt}) : super(key: key);

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
    if (tds.length == 1) {
      return TdDescriptor.only(
        td: tds.first,
        isPlayer: svt.isUserSvt,
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
        final toggle = Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: FilterGroup<int>(
                shrinkWrap: true,
                combined: true,
                options: List.generate(tds.length, (index) => index),
                optionBuilder: (v) => Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
                  child: Text(Transl.tdNames(
                          overrideTds.getOrNull(v)?.tdName ?? tds[v].name)
                      .l),
                ),
                values: FilterRadioData(tdIndex),
                onFilterChanged: (v, _) {
                  state.value = v.radioValue!;
                  state.updateState();
                },
              ),
            ),
            IconButton(
              padding: const EdgeInsets.all(2),
              constraints: const BoxConstraints(
                minWidth: 48,
                minHeight: 24,
              ),
              onPressed: () {
                SimpleCancelOkDialog(
                  title: Text(Transl.tdNames(td.name).l),
                  hideCancel: true,
                  content: Text(
                    'TODO',
                    style: Theme.of(context).textTheme.caption,
                  ),
                ).showDialog(context);
              },
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
            TdDescriptor.only(
              td: td,
              isPlayer: svt.isUserSvt,
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
}
