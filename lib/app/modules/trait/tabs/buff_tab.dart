import 'package:flutter/material.dart';

import 'package:chaldea/app/modules/common/filter_group.dart';
import 'package:chaldea/models/gamedata/individuality.dart';
import 'package:chaldea/models/models.dart';
import 'package:chaldea/utils/utils.dart';

enum _BuffCheckPos {
  vals,
  ckSelf,
  ckOpp,
  script,
}

class TraitBuffTab extends StatefulWidget {
  final List<int> ids;
  const TraitBuffTab(this.ids, {super.key});

  @override
  State<TraitBuffTab> createState() => _TraitBuffTabState();
}

class _TraitBuffTabState extends State<TraitBuffTab> {
  // int get id => widget.id;

  final filter = FilterGroupData<_BuffCheckPos>();

  @override
  Widget build(BuildContext context) {
    List<Widget> children = [];
    final buffs = db.gameData.baseBuffs.values.toList();
    buffs.sort2((e) => e.id);

    for (final buff in buffs) {
      final positions = [
        if (Individuality.containsAllAB(buff.vals, widget.ids)) _BuffCheckPos.vals,
        if (Individuality.containsAllAB(buff.ckSelfIndv, widget.ids)) _BuffCheckPos.ckSelf,
        if (Individuality.containsAllAB(buff.ckOpIndv, widget.ids)) _BuffCheckPos.ckOpp,
        if (Individuality.containsAllAB(
            <NiceTrait?>[
              buff.script?.INDIVIDUALITIE,
              ...?buff.script?.INDIVIDUALITIE_AND,
              ...?buff.script?.INDIVIDUALITIE_OR,
              ...buff.script?.UpBuffRateBuffIndiv ?? [],
            ].whereType<NiceTrait>().toList(),
            widget.ids))
          _BuffCheckPos.script,
      ];
      if (positions.isNotEmpty && filter.matchAny(positions)) {
        children.add(buildBuff(buff, positions));
      }
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: buttons,
        ),
        Expanded(
          child: children.isEmpty
              ? const Center(child: Text('No record'))
              : ListView.builder(
                  itemBuilder: (context, index) => children[index],
                  itemCount: children.length,
                ),
        ),
      ],
    );
  }

  Widget get buttons {
    return FilterGroup<_BuffCheckPos>(
      options: _BuffCheckPos.values,
      values: filter,
      optionBuilder: (v) {
        switch (v) {
          case _BuffCheckPos.vals:
            return const Text("vals");
          case _BuffCheckPos.ckSelf:
            return const Text("Check Self");
          case _BuffCheckPos.ckOpp:
            return const Text("Check Opposite");
          case _BuffCheckPos.script:
            return const Text("Script");
        }
      },
      combined: true,
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      onFilterChanged: (v, _) {
        setState(() {});
      },
    );
  }

  Widget buildBuff(Buff buff, List<_BuffCheckPos> positions) {
    Widget _traits(String prefix, List<NiceTrait> traits, {bool useAnd = false}) {
      return Text(
        '$prefix: ${traits.map((e) => Transl.trait(e.id).l).join(useAnd ? "&" : "/")}',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      );
    }

    return ListTile(
      dense: true,
      leading: buff.icon == null ? const SizedBox() : db.getIconImage(buff.icon, height: 32),
      title: Text('${buff.id} ${Transl.buffNames(buff.name).l}'),
      subtitle: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('[${buff.type.name}] ${Transl.buffType(buff.type).l}'),
          Text(Transl.buffDetail(buff.detail).l),
          if (positions.contains(_BuffCheckPos.vals)) _traits('vals', buff.vals),
          if (positions.contains(_BuffCheckPos.ckSelf)) _traits('ckSelf', buff.ckSelfIndv),
          if (positions.contains(_BuffCheckPos.ckOpp)) _traits('ckOpp', buff.ckOpIndv),
          if (widget.ids.length == 1 && buff.script?.INDIVIDUALITIE?.id == widget.ids.firstOrNull)
            _traits('owner', [buff.script!.INDIVIDUALITIE!]),
          if (Individuality.containsAllAB(buff.script?.INDIVIDUALITIE_AND ?? [], widget.ids))
            _traits('owner', buff.script?.INDIVIDUALITIE_AND ?? [], useAnd: true),
          if (Individuality.containsAllAB(buff.script?.INDIVIDUALITIE_OR ?? [], widget.ids))
            _traits('owner', buff.script?.INDIVIDUALITIE_OR ?? []),
          if (buff.script?.UpBuffRateBuffIndiv?.isNotEmpty == true)
            _traits('UpBuffRate', buff.script!.UpBuffRateBuffIndiv!),
        ],
      ),
      onTap: () => buff.routeTo(),
    );
  }
}
