import 'package:flutter/material.dart';

import 'package:chaldea/app/modules/common/filter_group.dart';
import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/models/gamedata/individuality.dart';
import 'package:chaldea/models/models.dart';
import 'package:chaldea/utils/utils.dart';

enum _SEScope {
  active,
  td,
  passive,
  // append, // 3rd skill's buff is upAtk
  tdSE,
  ce,
  cc,
}

class TraitSPDMGTab extends StatefulWidget {
  final List<int> ids;
  const TraitSPDMGTab(this.ids, {super.key});

  @override
  State<TraitSPDMGTab> createState() => _TraitSPDMGTabState();
}

class _TraitSPDMGTabState extends State<TraitSPDMGTab> {
  // int get id => widget.id;

  final filter = FilterGroupData<_SEScope>();

  @override
  Widget build(BuildContext context) {
    List<Widget> children = [];
    for (final svt in db.gameData.servantsNoDup.values.toList()..sort2((e) => e.collectionNo)) {
      if (filter.matchOne(_SEScope.active)) {
        children.addAll(checkSkills(svt, svt.skills));
      }
      if (filter.matchOne(_SEScope.td)) {
        children.addAll(checkSkills(svt, svt.noblePhantasms));
      }
      if (filter.matchOne(_SEScope.passive)) {
        children.addAll(checkSkills(svt, svt.classPassive));
      }
      // if (filter.matchOne(_SEScope.append)) {
      //   children.addAll(
      //       checkSkills(svt, svt.appendPassive.map((e) => e.skill).toList()));
      // }
      if (filter.matchOne(_SEScope.tdSE)) {
        children.addAll(checkTdSE(svt, svt.noblePhantasms));
      }
    }
    if (filter.matchOne(_SEScope.ce)) {
      for (final ce in db.gameData.craftEssences.values.toList()..sort2((e) => e.collectionNo)) {
        children.addAll(checkSkills(ce, ce.skills));
      }
    }
    if (filter.matchOne(_SEScope.cc)) {
      for (final cc in db.gameData.commandCodes.values.toList()..sort2((e) => e.collectionNo)) {
        children.addAll(checkSkills(cc, cc.skills));
      }
    }

    return Column(
      children: [
        Padding(padding: const EdgeInsets.symmetric(vertical: 4), child: buttons),
        Expanded(
          child:
              children.isEmpty
                  ? const Center(child: Text('No record'))
                  : ListView.builder(itemBuilder: (context, index) => children[index], itemCount: children.length),
        ),
      ],
    );
  }

  Widget get buttons {
    return Wrap(
      alignment: WrapAlignment.center,
      children: [
        for (final scopes in [
          [
            _SEScope.active,
            _SEScope.td,
            _SEScope.passive,
            // _BuffSEScope.append
          ],
          [_SEScope.tdSE],
          [_SEScope.ce, _SEScope.cc],
        ])
          FilterGroup<_SEScope>(
            options: scopes,
            values: filter,
            optionBuilder: (v) {
              switch (v) {
                case _SEScope.active:
                  return Text(S.current.active_skill_short);
                case _SEScope.td:
                  return Text(S.current.np_short);
                case _SEScope.passive:
                  return Text(S.current.passive_skill_short);
                // case _BuffSEScope.append:
                //   return Text(S.current.append_skill_short);
                case _SEScope.tdSE:
                  return Text(S.current.np_se);
                case _SEScope.ce:
                  return Text(S.current.craft_essence);
                case _SEScope.cc:
                  return Text(S.current.command_code);
              }
            },
            combined: true,
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            onFilterChanged: (v, _) {
              setState(() {});
            },
          ),
      ],
    );
  }

  List<Widget> checkSkills(GameCardMixin card, List<SkillOrTd> skills) {
    List<Widget> children = [];
    for (final skill in skills) {
      for (final func in skill.functions) {
        if (func.buffs.isEmpty) continue;
        final buff = func.buffs.first;
        if (![
          BuffType.upDamage,
          BuffType.upDamageIndividuality,
          BuffType.upDamageIndividualityActiveonly,
        ].contains(buff.type)) {
          continue;
        }
        if (Individuality.containsAllAB(buff.ckOpIndv, widget.ids, signed: false)) {
          children.add(_buildRow(card, skill));
        }
      }
    }
    return children;
  }

  List<Widget> checkTdSE(GameCardMixin card, List<NiceTd> tds) {
    List<Widget> children = [];
    for (final td in tds) {
      for (final func in td.functions) {
        if (![
          FuncType.damageNpIndividual,
          FuncType.damageNpAndOrCheckIndividuality,
          FuncType.damageNpIndividualSum,
          FuncType.damageNpStateIndividual,
          FuncType.damageNpStateIndividualFix,
        ].contains(func.funcType)) {
          continue;
        }
        final vals = func.svals.getOrNull(0);
        if (vals == null) continue;
        bool matched = false;
        switch (func.funcType) {
          case FuncType.damageNpIndividual:
          case FuncType.damageNpStateIndividualFix:
            matched = widget.ids.length == 1 && vals.Target == widget.ids.first;
            break;
          case FuncType.damageNpIndividualSum:
            matched = vals.TargetList?.toSet().containSubset(widget.ids.toSet()) == true;
            break;
          case FuncType.damageNpAndOrCheckIndividuality:
            matched = vals.AndCheckIndividualityList?.toSet().equalTo(widget.ids.toSet()) == true;
            break;
          case FuncType.damageNpStateIndividual:
            // not used
            break;
          default:
            break;
        }
        if (matched) {
          children.add(_buildRow(card, td));
        }
      }
    }
    return children;
  }

  Widget _buildRow(GameCardMixin card, SkillOrTd skill) {
    return ListTile(
      leading: card.iconBuilder(context: context, jumpToDetail: false),
      title: Text(skill.lName.l, textScaler: const TextScaler.linear(0.9)),
      subtitle: Text(skill.lDetail ?? '???', textScaler: const TextScaler.linear(0.9)),
      dense: true,
      onTap: () {
        card.routeTo();
      },
    );
  }
}
