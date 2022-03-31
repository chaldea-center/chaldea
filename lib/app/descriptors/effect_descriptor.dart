import 'package:auto_size_text/auto_size_text.dart';
import 'package:chaldea/app/modules/common/misc.dart';
import 'package:chaldea/packages/json_viewer/json_viewer.dart';
import 'package:chaldea/utils/utils.dart';
import 'package:chaldea/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:chaldea/models/models.dart';

import 'func/vals.dart';

class SkillDescriptor extends StatelessWidget {
  final BaseSkill skill;
  final FuncApplyTarget targetTeam;
  final int? level; // 1-10

  const SkillDescriptor({
    Key? key,
    required this.skill,
    this.targetTeam = FuncApplyTarget.player,
    this.level,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    int cd0 = 0, cd1 = 0;
    if (skill.coolDown.isNotEmpty) {
      cd0 = skill.coolDown.first;
      cd1 = skill.coolDown.last;
    }
    Widget? _wrapSkillAdd(Widget? child, bool translate) {
      if (child == null) return null;
      if (skill.skillAdd.isEmpty) return child;
      return Tooltip(
        child: child,
        message: skill.skillAdd
            .map((e) => translate ? Transl.skillNames(e.name).l : e.name)
            .join('/'),
      );
    }

    final header = CustomTile(
      contentPadding: const EdgeInsetsDirectional.fromSTEB(16, 6, 16, 6),
      leading: db2.getIconImage(skill.icon, width: 33, aspectRatio: 1),
      title: _wrapSkillAdd(Text(skill.lName.l), true),
      subtitle: Transl.isJP ? null : _wrapSkillAdd(Text(skill.name), false),
      trailing: cd0 <= 0 && cd1 <= 0
          ? null
          : cd0 == cd1
              ? Text('   CD: $cd0')
              : Text('   CD: $cd0→$cd1'),
    );
    const divider = Divider(indent: 16, endIndent: 16, height: 2, thickness: 1);
    return TileGroup(
      children: [
        header,
        Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(16, 0, 16, 4),
          child: Text(skill.lDetail ?? '???',
              style: Theme.of(context).textTheme.caption),
        ),
        divider,
        for (final func in skill.functions)
          if (func.funcTargetTeam == FuncApplyTarget.playerAndEnemy ||
              func.funcTargetTeam == targetTeam)
            EffectDescriptor(func: func, level: level),
      ],
    );
  }
}

class TdDescriptor extends StatelessWidget {
  final NiceTd td;
  final FuncApplyTarget targetTeam;
  final int? level;

  const TdDescriptor({
    Key? key,
    required this.td,
    this.targetTeam = FuncApplyTarget.player,
    this.level,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    const divider = Divider(indent: 16, endIndent: 16, height: 2, thickness: 1);
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
        Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(16, 0, 16, 4),
          child: Text(td.lDetail ?? '???',
              style: Theme.of(context).textTheme.caption),
        ),
        divider,
        for (final func in td.functions)
          if (func.funcTargetTeam == FuncApplyTarget.playerAndEnemy ||
              func.funcTargetTeam == targetTeam)
            EffectDescriptor(func: func, level: level),
        CustomTable(children: [
          CustomTableRow(children: [
            TableCellData(text: 'Hits', isHeader: true),
            TableCellData(
              text: td.npDistribution.isEmpty
                  ? '   -'
                  : '   ${td.npDistribution.length} Hits '
                      '(${td.npDistribution.join(', ')})',
              flex: 5,
              alignment: Alignment.centerLeft,
            )
          ]),
          CustomTableRow.fromTexts(
              texts: const ['Buster', 'Arts', 'Quick', 'Extra', 'NP', 'Def'],
              defaults: TableCellData(isHeader: true, maxLines: 1)),
          CustomTableRow.fromTexts(
            texts: [
              td.npGain.buster,
              td.npGain.arts,
              td.npGain.quick,
              td.npGain.extra,
              td.npGain.np,
              td.npGain.defence,
            ].map((e) => '${e.first / 100}%').toList(),
          ),
        ]),
      ],
    );
  }
}

class EffectDescriptor extends StatelessWidget {
  final NiceFunction func;
  final int? level; // 1-10
  const EffectDescriptor({Key? key, required this.func, this.level})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    StringBuffer funcText = StringBuffer();
    if (func.funcType == FuncType.addState ||
        func.funcType == FuncType.addStateShort) {
      funcText.write(Transl.buffNames(func.buffs.first.name).l);
    } else {
      funcText.write(Transl.funcPopuptext(func.funcPopupText, func.funcType).l);
    }

    final staticVal = func.getStaticVal();
    final crossVals = func.crossVals;
    final mutatingVals = func.getMutatingVals(staticVal);

    int turn = staticVal.Turn ?? -1, count = staticVal.Count ?? -1;
    if (turn > 0 || count > 0) {
      funcText.write(' (');
      funcText.write([
        if (count > 0)
          M.of(
            jp: '$count回',
            cn: '$count次',
            na: '$count Times',
          ),
        if (turn > 0)
          M.of(
            jp: '$turnターン',
            cn: '$turn回合',
            na: '$turn Turns',
          ),
      ].join(M.of(jp: '·', na: ', ')));
      funcText.write(')');
    }
    final lvVals = func.svals;
    final ocVals = func.ocVals(0);
    final int lvNum = lvVals.toSet().length, ocNum = ocVals.toSet().length;

    if (func.svals.length == 5) {
      if (lvNum > 1) {
        funcText.write('<Lv>');
      }
      if (ocNum > 1) {
        funcText.write('<OC>');
      }
    }
    return LayoutBuilder(builder: (context, constraints) {
      int perLine =
          constraints.maxWidth > 600 && func.svals.length > 5 ? 10 : 5;
      Widget trailing;
      List<Widget> levels = [];
      trailing = ValDsc(
        func: func,
        vals: staticVal,
        originVals: func.svals.getOrNull(0),
        ignoreRate: true,
      );

      if (mutatingVals.isNotEmpty) {
        levels.add(ValListDsc(
          func: func,
          mutaingVals: mutatingVals,
          originVals: crossVals,
          selected: level,
        ));
      }
      Widget child = Text(
        funcText.toString(),
        style: Theme.of(context).textTheme.caption,
      );
      if (func.funcPopupIcon != null) {
        child = Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            db2.getIconImage(func.funcPopupIcon, width: 18),
            const SizedBox(width: 4),
            child
          ],
        );
      }
      child = InkWell(
        child: child,
        onTap: () {
          showDialog(
            context: context,
            builder: (context) {
              List<String> _traitList(List<NiceTrait> traits) {
                return traits.map((e) => Transl.trait(e.id).l).toList();
              }

              return Theme(
                data: ThemeData.light(),
                child: SimpleCancelOkDialog(
                  title: const Text('Func Detail'),
                  content: JsonViewer({
                    "ID": func.funcId,
                    "Type": func.funcType.name,
                    "Target": func.funcTargetType.name,
                    "Team": func.funcTargetTeam.name,
                    if (func.functvals.isNotEmpty)
                      "TargetTraits": _traitList(func.functvals),
                    if (func.funcquestTvals.isNotEmpty)
                      "FieldTraits": _traitList(func.funcquestTvals),
                    if (func.traitVals.isNotEmpty)
                      "RemovalTraits": _traitList(func.traitVals),
                    if (func.buffs.isNotEmpty) ...{
                      "BuffId": func.buffs.first.id,
                      "BuffName": func.buffs.first.name,
                      "BuffType": func.buffs.first.type.name
                    }
                  }),
                  scrollable: true,
                  hideCancel: true,
                ),
              );
            },
          );
        },
      );
      child = Row(
        children: [
          Expanded(child: child, flex: perLine - 1),
          Expanded(child: trailing),
        ],
      );
      if (levels.isNotEmpty) {
        child = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [child, ...levels],
        );
      }
      child = Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        child: child,
      );
      return child;
    });
  }
}
