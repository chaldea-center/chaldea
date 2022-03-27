import 'package:auto_size_text/auto_size_text.dart';
import 'package:chaldea/app/modules/common/misc.dart';
import 'package:chaldea/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:chaldea/models/models.dart';

import 'func/vals.dart';

class SkillDescriptor extends StatelessWidget {
  final BaseSkill skill;
  final FuncApplyTarget targetTeam;

  const SkillDescriptor({
    Key? key,
    required this.skill,
    this.targetTeam = FuncApplyTarget.player,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    int cd0 = 0, cd1 = 0;
    if (skill.coolDown.isNotEmpty) {
      cd0 = skill.coolDown.first;
      cd1 = skill.coolDown.last;
    }
    final header = CustomTile(
      contentPadding: const EdgeInsetsDirectional.fromSTEB(16, 6, 16, 6),
      leading: db2.getIconImage(skill.icon, width: 33, aspectRatio: 1),
      title: Text(skill.lName.l),
      subtitle: Transl.isJP ? null : Text(skill.name),
      trailing: cd0 <= 0 && cd1 <= 0
          ? null
          : cd0 == cd1
              ? Text('   CD: $cd0')
              : Text('   CD: $cd0→$cd1'),
    );
    final divider = Divider(
      indent: 16,
      endIndent: 16,
      height: 2,
      thickness: 1,
      color: Theme.of(context).scaffoldBackgroundColor.withAlpha(150),
    );
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
            EffectDescriptor(func: func),
      ],
    );
  }
}

class TdDescriptor extends StatelessWidget {
  final NiceTd td;
  final FuncApplyTarget targetTeam;

  const TdDescriptor({
    Key? key,
    required this.td,
    this.targetTeam = FuncApplyTarget.player,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final divider = Divider(
      indent: 16,
      endIndent: 16,
      height: 2,
      thickness: 1,
      color: Theme.of(context).scaffoldBackgroundColor.withAlpha(150),
    );
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
            EffectDescriptor(func: func),
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
  const EffectDescriptor({Key? key, required this.func}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    StringBuffer funcText = StringBuffer();
    if (func.funcType == FuncType.addState ||
        func.funcType == FuncType.addStateShort) {
      funcText.write(Transl.buffNames(func.buffs.first.name).l);
    } else {
      if (['', '-', 'なし'].contains(func.funcPopupText)) {
        funcText.write(func.funcType.name);
      } else {
        funcText.write(Transl.funcPopuptext(func.funcPopupText).l);
      }
    }
    int turn = func.svals.first.Turn ?? -1,
        count = func.svals.first.Count ?? -1;
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
      ].join(M.of(jp: '・', na: ', ')));
      funcText.write(')');
    }

    return LayoutBuilder(builder: (context, constraints) {
      int perLine = constraints.maxWidth > 600 ? 10 : 5;
      Widget? trailing;
      List<Widget> levels = [];
      final lvVals = func.svals;
      final ocVals = func.ocVals(0);
      final int lvNum = lvVals.toSet().length, ocNum = ocVals.toSet().length;
      if (lvNum == 0 && ocNum == 0) {
        //
      } else if (lvNum == 1 && ocNum == 1) {
        trailing = ValDsc(func: func, vals: lvVals[0]);
      }
      if (lvNum > 1) {
        funcText.write('<Lv>');
        levels.add(ValListDsc(func: func, svals: lvVals));
      }
      if (ocNum > 1) {
        funcText.write('<OC>');
        levels.add(ValListDsc(func: func, svals: ocVals));
      }
      Widget child =
          Text(funcText.toString(), style: Theme.of(context).textTheme.caption);
      if (trailing != null) {
        child = Row(
          children: [
            Expanded(child: child, flex: perLine - 1),
            Expanded(child: trailing),
          ],
        );
      }
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
