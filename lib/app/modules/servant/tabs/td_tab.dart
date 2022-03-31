import 'package:chaldea/app/descriptors/effect_descriptor.dart';
import 'package:chaldea/app/modules/common/filter_group.dart';
import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/models/models.dart';
import 'package:chaldea/utils/utils.dart';
import 'package:chaldea/widgets/widgets.dart';
import 'package:flutter/material.dart';

class SvtTdTab extends StatelessWidget {
  final Servant svt;

  const SvtTdTab({Key? key, required this.svt}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    List<Widget> children = [];
    final status = db2.curUser.svtStatusOf(svt.collectionNo).cur;
    for (final tds in svt.groupedNoblePhantasms) {
      children
          .add(_buildTds(context, tds, status.favorite ? status.npLv : null));
    }
    return ListView(children: children);
  }

  Widget _buildTds(BuildContext context, List<NiceTd> tds, int? level) {
    if (tds.length == 1) return TdDescriptor(td: tds.first, level: level);
    return ValueStatefulBuilder<NiceTd>(
      initValue: tds.last,
      builder: (context, state) {
        final td = state.value;
        final toggle = Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: FilterGroup<NiceTd>(
                shrinkWrap: true,
                combined: true,
                options: tds,
                optionBuilder: (v) => Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
                  child: Text(Transl.tdNames(v.name).l),
                ),
                values: FilterRadioData(td),
                onFilterChanged: (v) {
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
            toggle,
            TdDescriptor(td: td, level: level),
          ],
        );
      },
    );
  }
}
