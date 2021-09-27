import 'package:auto_size_text/auto_size_text.dart';
import 'package:chaldea/components/components.dart';
import 'package:chaldea/modules/shared/common_builders.dart';
import 'package:chaldea/modules/shared/filter_page.dart';

import '../servant_detail_page.dart';
import 'svt_tab_base.dart';

class SvtNoblePhantasmTab extends SvtTabBaseWidget {
  const SvtNoblePhantasmTab({
    Key? key,
    ServantDetailPageState? parent,
    Servant? svt,
    ServantStatus? status,
  }) : super(key: key, parent: parent, svt: svt, status: status);

  @override
  _SvtNoblePhantasmTabState createState() => _SvtNoblePhantasmTabState();
}

class _SvtNoblePhantasmTabState extends SvtTabBaseState<SvtNoblePhantasmTab> {
  List<NoblePhantasm> get noblePhantasms => svt.lNoblePhantasm;

  @override
  Widget build(BuildContext context) {
    if (noblePhantasms.isEmpty) {
      return const Center(child: Text('No NoblePhantasm Data'));
    }
    status.validate(svt);

    final td = noblePhantasms[status.npIndex];

    return ListView(
      children: <Widget>[
        TileGroup(
          children: <Widget>[
            buildToggle(status.npIndex, td),
            buildHeader(td),
            for (Effect effect in td.effects)
              ...CommonBuilder.buildEffect(
                context: context,
                effect: effect,
                curLv: null, // over change should not
              ),
          ],
        )
      ],
    );
  }

  Widget buildToggle(int npIndex, NoblePhantasm td) {
    if (noblePhantasms.length <= 1) {
      return Container();
    }
    final filter = FilterGroup(
      options:
          List.generate(noblePhantasms.length, (index) => index.toString()),
      values: FilterGroupData.radio(npIndex.toString()),
      optionBuilder: (s) {
        String state = noblePhantasms[int.parse(s)].state ?? 'NP';
        Widget button;
        if (state.contains('强化前') || state.contains('强化后')) {
          final iconKey = state.contains('强化前') ? '宝具未强化' : '宝具强化';
          button = Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              db.getIconImage(iconKey, height: 22),
              Text(state)
            ],
          );
        } else {
          button = Text(state);
        }
        return button;
      },
      combined: true,
      useRadio: true,
      onFilterChanged: (v) {
        setState(() {
          status.npIndex = int.parse(v.options.keys.first);
        });
      },
    );
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (td.openCondition?.isNotEmpty == true) const SizedBox(width: 48),
          Expanded(child: Center(child: filter)),
          if (td.openCondition?.isNotEmpty == true)
            SizedBox(
              width: 48,
              child: IconButton(
                padding: const EdgeInsets.all(2),
                constraints: const BoxConstraints(
                  minWidth: 48,
                  minHeight: 24,
                ),
                onPressed: () {
                  SimpleCancelOkDialog(
                    title: Text(td.lName),
                    hideCancel: true,
                    content: Text(
                      td.openCondition!,
                      style: Theme.of(context).textTheme.caption,
                    ),
                  ).showDialog(context);
                },
                icon: const Icon(Icons.info_outline),
                color: Theme.of(context).hintColor,
                tooltip: S.current.open_condition,
              ),
            )
        ],
      ),
    );
  }

  Widget buildHeader(NoblePhantasm td) {
    return CustomTile(
      leading: Column(
        children: <Widget>[
          db.getIconImage(td.color?.toLowerCase().toTitle(), width: 99),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 110 * 0.9),
            child: Text(
              '${td.typeText} ${td.rank}',
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
            td.upperName,
            style: TextStyle(
                fontSize: 16,
                color: Theme.of(context).textTheme.caption?.color),
            maxLines: 1,
          ),
          AutoSizeText(
            td.name,
            style: const TextStyle(fontWeight: FontWeight.w600),
            maxLines: Language.isEN ? 2 : 1,
          ),
          if (td.upperNameJp?.isNotEmpty == true)
            AutoSizeText(
              td.upperNameJp!,
              style: TextStyle(
                  fontSize: 16,
                  color: Theme.of(context).textTheme.caption?.color),
              maxLines: 1,
            ),
          if (td.nameJp?.isNotEmpty == true)
            AutoSizeText(
              td.nameJp!,
              style: const TextStyle(fontWeight: FontWeight.w600),
              maxLines: 1,
            ),
        ],
      ),
    );
  }
}
