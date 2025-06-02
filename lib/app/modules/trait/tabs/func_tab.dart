import 'package:flutter/material.dart';

import 'package:chaldea/app/modules/common/filter_group.dart';
import 'package:chaldea/models/gamedata/individuality.dart';
import 'package:chaldea/models/models.dart';
import 'package:chaldea/utils/utils.dart';

enum _FuncCheckPos { tvals, questtvals, traitVals, script }

class TraitFuncTab extends StatefulWidget {
  final List<int> ids;
  const TraitFuncTab(this.ids, {super.key});

  @override
  State<TraitFuncTab> createState() => _TraitFuncTabState();
}

class _TraitFuncTabState extends State<TraitFuncTab> {
  List<int> get ids => widget.ids;

  final filter = FilterRadioData<_FuncCheckPos>();

  @override
  Widget build(BuildContext context) {
    List<Widget> children = [];
    final funcs = db.gameData.baseFunctions.values.toList();
    funcs.sort2((e) => e.funcId);

    for (final func in funcs) {
      final positions = [
        if (Individuality.containsAllAB(func.functvals, ids, signed: false) ||
            Individuality.containsAllAB(
              func.script?.overwriteTvals?.expand((e) => e).toList() ?? [],
              ids,
              signed: false,
            ))
          _FuncCheckPos.tvals,
        if (Individuality.containsAllAB(func.funcquestTvals, ids, signed: false)) _FuncCheckPos.questtvals,
        if (Individuality.containsAllAB(func.traitVals, ids, signed: false)) _FuncCheckPos.traitVals,
        if (Individuality.containsAllAB(func.script?.funcIndividuality ?? [], ids, signed: false)) _FuncCheckPos.script,
      ];
      if (positions.isNotEmpty && filter.matchAny(positions)) {
        children.add(buildFunc(func, positions));
      }
    }

    return Column(
      children: [
        Padding(padding: const EdgeInsets.symmetric(vertical: 4), child: buttons),
        Expanded(
          child: children.isEmpty
              ? const Center(child: Text('No record'))
              : ListView.builder(itemBuilder: (context, index) => children[index], itemCount: children.length),
        ),
      ],
    );
  }

  Widget get buttons {
    return FilterGroup<_FuncCheckPos>(
      options: _FuncCheckPos.values,
      values: filter,
      optionBuilder: (v) {
        switch (v) {
          case _FuncCheckPos.tvals:
            return const Text("functvals");
          case _FuncCheckPos.questtvals:
            return const Text("questtvals");
          case _FuncCheckPos.traitVals:
            return const Text("traitVals");
          case _FuncCheckPos.script:
            return const Text("script");
        }
      },
      combined: true,
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      onFilterChanged: (v, _) {
        setState(() {});
      },
    );
  }

  Widget buildFunc(BaseFunction func, List<_FuncCheckPos> positions) {
    Widget _traits(String prefix, List<NiceTrait> traits) {
      return Text(
        '$prefix: ${traits.map((e) => Transl.trait(e.id).l).join("/")}',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      );
    }

    return ListTile(
      dense: true,
      leading: func.funcPopupIcon == null ? const SizedBox() : db.getIconImage(func.funcPopupIcon, height: 32),
      title: Text('${func.funcId} ${func.lPopupText.l}'),
      onTap: func.routeTo,
      subtitle: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('[${func.funcType.name}] ${Transl.funcType(func.funcType).l}'),
          if (positions.contains(_FuncCheckPos.tvals))
            _traits('functvals', [...func.functvals, ...?func.script?.overwriteTvals?.expand((e) => e)]),
          if (positions.contains(_FuncCheckPos.questtvals)) _traits('quest', func.funcquestTvals),
          if (positions.contains(_FuncCheckPos.traitVals)) _traits('traitVals', func.traitVals),
          if (positions.contains(_FuncCheckPos.script)) _traits('script', func.script?.funcIndividuality ?? []),
        ],
      ),
    );
  }
}
