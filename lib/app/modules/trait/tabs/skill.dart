import 'package:flutter/material.dart';

import 'package:chaldea/models/models.dart';
import 'package:chaldea/utils/utils.dart';

class TraitSkillTab extends StatefulWidget {
  final int id;
  const TraitSkillTab(this.id, {super.key});

  @override
  State<TraitSkillTab> createState() => _TraitSkillTabState();
}

class _TraitSkillTabState extends State<TraitSkillTab> {
  int get id => widget.id;

  @override
  Widget build(BuildContext context) {
    List<Widget> children = [];
    for (final skill in [
      ...db.gameData.baseSkills.values,
      ...db.gameData.baseTds.values
    ]) {
      List<NiceFunction> funcs = [];
      for (final func in skill.functions) {
        if (func.funcType == FuncType.eventFortificationPointUp) continue;
        final sval = func.svals.getOrNull(0);
        if (sval == null) continue;
        for (final val in [
          ...<int?>[
            sval.Individuality,
            sval.AddIndividualty,
            sval.AddIndividualityEx,
            sval.CardIndividuality,
            sval.FieldIndividuality,
            sval.GainNpTargetPassiveIndividuality,
          ],
          ...<List<int>?>[
            sval.ParamAddOpIndividuality,
            sval.ParamAddSelfIndividuality,
            sval.ParamAddFieldIndividuality,
          ],
        ]) {
          if ((val is List && val.contains(id)) || val == id) {
            funcs.add(func);
            break;
          }
        }
      }
      if (funcs.isNotEmpty) {
        children.add(ListTile(
          dense: true,
          leading: skill.icon == null
              ? const SizedBox()
              : db.getIconImage(skill.icon, height: 28),
          title: Text(skill.lName.l),
          onTap: skill.routeTo,
          subtitle: Text(funcs.map((e) => e.lPopupText.l).join('\n')),
        ));
      }
    }

    return ListView.builder(
      itemBuilder: (context, index) => children[index],
      itemCount: children.length,
    );
  }
}
