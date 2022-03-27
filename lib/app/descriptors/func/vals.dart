import 'package:chaldea/models/models.dart';
import 'package:chaldea/packages/json_viewer/json_viewer.dart';
import 'package:chaldea/utils/utils.dart';
import 'package:chaldea/widgets/widgets.dart';
import 'package:flutter/material.dart';

class ValListDsc extends StatelessWidget {
  final BaseFunction func;
  final List<DataVals> svals;
  final int? selected;
  const ValListDsc(
      {Key? key, required this.func, required this.svals, this.selected})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      int perLine = constraints.maxWidth > 600 ? 10 : 5;
      List<Widget> rows = [];
      int rowCount = (svals.length / perLine).ceil();
      for (int i = 0; i < rowCount; i++) {
        List<Widget> cols = [];
        for (int j = i * perLine; j < (i + 1) * perLine; j++) {
          final vals = svals.getOrNull(j);
          if (vals == null) {
            cols.add(const SizedBox());
          } else {
            cols.add(ValDsc(func: func, vals: vals));
          }
        }
        rows.add(Row(children: cols.map((e) => Expanded(child: e)).toList()));
      }
      if (rows.isEmpty) return const SizedBox();
      if (rows.length == 1) return rows.first;
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: rows,
      );
    });
  }
}

class ValDsc extends StatelessWidget {
  final BaseFunction func;
  final DataVals vals;
  const ValDsc({Key? key, required this.func, required this.vals})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      child: Text(
        vals.Value.toString(),
        textAlign: TextAlign.center,
        style: const TextStyle(fontStyle: FontStyle.italic),
      ),
      onTap: () {
        showDialog(
          context: context,
          builder: (context) {
            return Theme(
              data: ThemeData.light(),
              child: SimpleCancelOkDialog(
                title: const Text('Data Vals'),
                content: JsonViewer(vals.toJson()),
                scrollable: true,
                hideCancel: true,
              ),
            );
          },
        );
      },
    );
  }

  String getText() {
    switch (func.funcType) {
      case FuncType.none:
        break;
      case FuncType.addState:
      case FuncType.addStateShort:
        // TODO: Handle this case.
        break;
      case FuncType.subState:
        // TODO: Handle this case.
        break;
      case FuncType.damage:
        // TODO: Handle this case.
        break;
      case FuncType.damageNp:
        // TODO: Handle this case.
        break;
      case FuncType.gainStar:
        // TODO: Handle this case.
        break;
      case FuncType.gainHp:
        // TODO: Handle this case.
        break;
      case FuncType.gainNp:
        // TODO: Handle this case.
        break;
      case FuncType.lossNp:
        // TODO: Handle this case.
        break;
      case FuncType.shortenSkill:
        // TODO: Handle this case.
        break;
      case FuncType.extendSkill:
        // TODO: Handle this case.
        break;
      case FuncType.releaseState:
        // TODO: Handle this case.
        break;
      case FuncType.lossHp:
        // TODO: Handle this case.
        break;
      case FuncType.instantDeath:
        // TODO: Handle this case.
        break;
      case FuncType.damageNpPierce:
        // TODO: Handle this case.
        break;
      case FuncType.damageNpIndividual:
        // TODO: Handle this case.
        break;
      case FuncType.gainHpPer:
        // TODO: Handle this case.
        break;
      case FuncType.damageNpStateIndividual:
        // TODO: Handle this case.
        break;
      case FuncType.hastenNpturn:
        // TODO: Handle this case.
        break;
      case FuncType.delayNpturn:
        // TODO: Handle this case.
        break;
      case FuncType.damageNpHpratioHigh:
        // TODO: Handle this case.
        break;
      case FuncType.damageNpHpratioLow:
        // TODO: Handle this case.
        break;
      case FuncType.cardReset:
        // TODO: Handle this case.
        break;
      case FuncType.replaceMember:
        // TODO: Handle this case.
        break;
      case FuncType.lossHpSafe:
        // TODO: Handle this case.
        break;
      case FuncType.damageNpCounter:
        // TODO: Handle this case.
        break;
      case FuncType.damageNpStateIndividualFix:
        // TODO: Handle this case.
        break;
      case FuncType.damageNpSafe:
        // TODO: Handle this case.
        break;
      case FuncType.callServant:
        // TODO: Handle this case.
        break;
      case FuncType.ptShuffle:
        // TODO: Handle this case.
        break;
      case FuncType.lossStar:
        // TODO: Handle this case.
        break;
      case FuncType.changeServant:
        // TODO: Handle this case.
        break;
      case FuncType.changeBg:
        // TODO: Handle this case.
        break;
      case FuncType.damageValue:
        // TODO: Handle this case.
        break;
      case FuncType.withdraw:
        // TODO: Handle this case.
        break;
      case FuncType.fixCommandcard:
        // TODO: Handle this case.
        break;
      case FuncType.shortenBuffturn:
        // TODO: Handle this case.
        break;
      case FuncType.extendBuffturn:
        // TODO: Handle this case.
        break;
      case FuncType.shortenBuffcount:
        // TODO: Handle this case.
        break;
      case FuncType.extendBuffcount:
        // TODO: Handle this case.
        break;
      case FuncType.changeBgm:
        // TODO: Handle this case.
        break;
      case FuncType.displayBuffstring:
        // TODO: Handle this case.
        break;
      case FuncType.resurrection:
        // TODO: Handle this case.
        break;
      case FuncType.gainNpBuffIndividualSum:
        // TODO: Handle this case.
        break;
      case FuncType.setSystemAliveFlag:
        // TODO: Handle this case.
        break;
      case FuncType.forceInstantDeath:
        // TODO: Handle this case.
        break;
      case FuncType.damageNpRare:
        // TODO: Handle this case.
        break;
      case FuncType.gainNpFromTargets:
        // TODO: Handle this case.
        break;
      case FuncType.gainHpFromTargets:
        // TODO: Handle this case.
        break;
      case FuncType.lossHpPer:
        // TODO: Handle this case.
        break;
      case FuncType.lossHpPerSafe:
        // TODO: Handle this case.
        break;
      case FuncType.shortenUserEquipSkill:
        // TODO: Handle this case.
        break;
      case FuncType.quickChangeBg:
        // TODO: Handle this case.
        break;
      case FuncType.shiftServant:
        // TODO: Handle this case.
        break;
      case FuncType.damageNpAndCheckIndividuality:
        // TODO: Handle this case.
        break;
      case FuncType.absorbNpturn:
        // TODO: Handle this case.
        break;
      case FuncType.overwriteDeadType:
        // TODO: Handle this case.
        break;
      case FuncType.forceAllBuffNoact:
        // TODO: Handle this case.
        break;
      case FuncType.breakGaugeUp:
        // TODO: Handle this case.
        break;
      case FuncType.breakGaugeDown:
        // TODO: Handle this case.
        break;
      case FuncType.moveToLastSubmember:
        // TODO: Handle this case.
        break;
      case FuncType.expUp:
        // TODO: Handle this case.
        break;
      case FuncType.qpUp:
        // TODO: Handle this case.
        break;
      case FuncType.dropUp:
        // TODO: Handle this case.
        break;
      case FuncType.friendPointUp:
        // TODO: Handle this case.
        break;
      case FuncType.eventDropUp:
        // TODO: Handle this case.
        break;
      case FuncType.eventDropRateUp:
        // TODO: Handle this case.
        break;
      case FuncType.eventPointUp:
        // TODO: Handle this case.
        break;
      case FuncType.eventPointRateUp:
        // TODO: Handle this case.
        break;
      case FuncType.transformServant:
        // TODO: Handle this case.
        break;
      case FuncType.qpDropUp:
        // TODO: Handle this case.
        break;
      case FuncType.servantFriendshipUp:
        // TODO: Handle this case.
        break;
      case FuncType.userEquipExpUp:
        // TODO: Handle this case.
        break;
      case FuncType.classDropUp:
        // TODO: Handle this case.
        break;
      case FuncType.enemyEncountCopyRateUp:
        // TODO: Handle this case.
        break;
      case FuncType.enemyEncountRateUp:
        // TODO: Handle this case.
        break;
      case FuncType.enemyProbDown:
        // TODO: Handle this case.
        break;
      case FuncType.getRewardGift:
        // TODO: Handle this case.
        break;
      case FuncType.sendSupportFriendPoint:
        // TODO: Handle this case.
        break;
      case FuncType.movePosition:
        // TODO: Handle this case.
        break;
      case FuncType.revival:
        // TODO: Handle this case.
        break;
      case FuncType.damageNpIndividualSum:
        // TODO: Handle this case.
        break;
      case FuncType.damageValueSafe:
        // TODO: Handle this case.
        break;
      case FuncType.friendPointUpDuplicate:
        // TODO: Handle this case.
        break;
      case FuncType.moveState:
        // TODO: Handle this case.
        break;
      case FuncType.changeBgmCostume:
        // TODO: Handle this case.
        break;
      case FuncType.func126:
        // TODO: Handle this case.
        break;
      case FuncType.func127:
        // TODO: Handle this case.
        break;
      case FuncType.updateEntryPositions:
        // TODO: Handle this case.
        break;
      case FuncType.buddyPointUp:
        // TODO: Handle this case.
        break;
    }
    return vals.Value.toString();
  }
}
