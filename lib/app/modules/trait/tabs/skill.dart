import 'package:flutter/material.dart';

import 'package:chaldea/models/models.dart';
import 'package:chaldea/utils/utils.dart';

class TraitSkillTab extends StatefulWidget {
  final List<int> ids;
  const TraitSkillTab(this.ids, {super.key});

  @override
  State<TraitSkillTab> createState() => _TraitSkillTabState();
}

class _TraitSkillTabState extends State<TraitSkillTab> {
  @override
  Widget build(BuildContext context) {
    List<Widget> children = [];
    for (final skill in [...db.gameData.baseSkills.values, ...db.gameData.baseTds.values]) {
      List<NiceFunction> funcs = [];
      for (final func in skill.functions) {
        if (func.funcType == FuncType.eventFortificationPointUp) continue;
        final sval = func.svals.getOrNull(0);
        if (sval == null) continue;
        for (final val in <List<int>?>[
          ...<int?>[
            sval.Individuality,
            sval.AddIndividualty,
            sval.AddIndividualityEx,
            sval.CardIndividuality,
            sval.GainNpTargetPassiveIndividuality,
          ].whereType<int>().map((e) => [e]),
          ...<List<int>?>[
            sval.ParamAddOpIndividuality,
            sval.ParamAddSelfIndividuality,
            sval.ParamAddFieldIndividuality,
            sval.FieldIndividuality,
          ],
        ]) {
          if (val != null && val.toSet().containSubset(widget.ids.toSet())) {
            funcs.add(func);
            break;
          }
        }
      }
      if (funcs.isNotEmpty) {
        children.add(
          ListTile(
            dense: true,
            leading: skill.icon == null ? const SizedBox() : db.getIconImage(skill.icon, height: 28),
            title: Text(skill.lName.l),
            onTap: skill.routeTo,
            subtitle: Text(funcs.map((e) => e.lPopupText.l).join('\n')),
          ),
        );
      }
    }

    return ListView.builder(itemBuilder: (context, index) => children[index], itemCount: children.length);
  }
}
