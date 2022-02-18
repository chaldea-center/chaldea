import 'package:auto_size_text/auto_size_text.dart';
import 'package:chaldea/app/modules/common/filter_group.dart';
import 'package:chaldea/app/modules/common/misc.dart';
import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/utils/atlas.dart';
import 'package:chaldea/utils/utils.dart';
import 'package:chaldea/widgets/tile_items.dart';
import 'package:chaldea/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:chaldea/models/models.dart';

class SvtTdTab extends StatelessWidget {
  final Servant svt;
  const SvtTdTab({Key? key, required this.svt}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    List<Widget> children = [];
    for (final tds in svt.groupedNoblePhantasms) {
      children.add(_buildTds(context, tds));
    }
    return ListView(children: children);
  }

  Widget _buildTds(BuildContext context, List<NiceTd> tds) {
    if (tds.length == 1) return _buildOneTd(context, tds.first);
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
            _buildOneTd(context, td),
          ],
        );
      },
    );
  }

  Widget _buildOneTd(BuildContext context, NiceTd td) {
    final card = EnumUtil.shortString(td.card);
    final header = CustomTile(
      leading: Column(
        children: <Widget>[
          CommandCardWidget(card: td.card, width: 90),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 110 * 0.9),
            child: Text(
              '${td.type} ${td.rank}',
              style: const TextStyle(fontSize: 14),
              textAlign: TextAlign.center,
            ),
          )
        ],
      ),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          AutoSizeText(
            Transl.tdRuby(td.ruby).l,
            style: TextStyle(
                fontSize: 16,
                color: Theme.of(context).textTheme.caption?.color),
            maxLines: 1,
          ),
          AutoSizeText(
            Transl.tdNames(td.name).l,
            style: const TextStyle(fontWeight: FontWeight.w600),
            maxLines: 2,
          ),
          AutoSizeText(
            td.ruby,
            style: TextStyle(
                fontSize: 16,
                color: Theme.of(context).textTheme.caption?.color),
            maxLines: 1,
          ),
          AutoSizeText(
            td.name,
            style: const TextStyle(fontWeight: FontWeight.w600),
            maxLines: 1,
          ),
        ],
      ),
    );
    return TileGroup(
      children: [
        header,
        SFooter(
          td.lDetail ?? '???',
          padding: const EdgeInsetsDirectional.fromSTEB(16, 0, 16, 4),
        )
      ],
    );
  }
}
