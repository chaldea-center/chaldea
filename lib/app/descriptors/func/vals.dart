import 'package:chaldea/models/models.dart';
import 'package:chaldea/packages/json_viewer/json_viewer.dart';
import 'package:chaldea/utils/utils.dart';
import 'package:chaldea/widgets/widgets.dart';
import 'package:flutter/material.dart';

class ValListDsc extends StatelessWidget {
  final BaseFunction func;
  final List<DataVals> mutaingVals;
  final List<DataVals> originVals;
  final int? selected; // 1-10
  const ValListDsc({
    Key? key,
    required this.func,
    required this.mutaingVals,
    required this.originVals,
    this.selected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      int perLine =
          constraints.maxWidth > 600 && originVals.length > 5 ? 10 : 5;
      List<Widget> rows = [];
      int rowCount = (mutaingVals.length / perLine).ceil();
      for (int i = 0; i < rowCount; i++) {
        List<Widget> cols = [];
        for (int j = i * perLine; j < (i + 1) * perLine; j++) {
          final vals = mutaingVals.getOrNull(j);
          Widget child;
          if (vals == null) {
            child = const SizedBox();
          } else {
            child = ValDsc(
              func: func,
              vals: vals,
              originVals: originVals.getOrNull(j),
              color: j == 5 || j == 9
                  ? Theme.of(context).colorScheme.secondary
                  : null,
            );
          }
          if (selected != null && selected! - 1 == j) {
            child = DecoratedBox(
              decoration: BoxDecoration(
                border: Border.all(
                    color: Theme.of(context)
                        .colorScheme
                        .secondaryContainer
                        .withAlpha(180)),
                borderRadius: BorderRadius.circular(4),
              ),
              child: child,
            );
          }
          cols.add(child);
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
  final DataVals? originVals;
  final bool? ignoreRate;
  final Color? color;

  ValDsc({
    Key? key,
    required this.func,
    required this.vals,
    this.originVals,
    this.color,
    this.ignoreRate,
  }) : super(key: key);

  final List<String> parts = [];

  @override
  Widget build(BuildContext context) {
    describeFunc();
    TextStyle style = TextStyle(color: color);
    if (parts.isEmpty) {
      style = style.copyWith(
        fontStyle: FontStyle.italic,
        color: Theme.of(context).textTheme.caption?.color,
      );
    }
    return InkWell(
      child: Text(
        parts.isEmpty ? vals.Value?.toString() ?? empty : parts.join(', '),
        textAlign: TextAlign.center,
        style: style,
      ),
      onTap: () {
        showDialog(
          context: context,
          builder: (context) {
            return Theme(
              data: ThemeData.light(),
              child: SimpleCancelOkDialog(
                title: const Text('Data Vals'),
                content: JsonViewer((originVals ?? vals).toJson()),
                scrollable: true,
                hideCancel: true,
              ),
            );
          },
        );
      },
    );
  }

  void _addInt(int? value) {
    if (value == null) return;
    parts.add(value.toString());
  }

  void _addPercent(int? value, int base) {
    if (value == null) return;
    int _intValue = value ~/ base;
    double _floatValue = value / base;
    if (_intValue.toDouble() == _floatValue) {
      parts.add('$_intValue%');
    } else {
      parts.add(_floatValue.toString().trimCharRight('0') + '%');
    }
  }

  // return null if not processed
  void describeFunc() {
    parts.clear();

    if (func.funcType == FuncType.addState ||
        func.funcType == FuncType.addStateShort) {
      describeBuff(func.buffs.first);
    } else if (func.funcType == FuncType.absorbNpturn) {
      // return null;
    } else if (func.funcType == FuncType.gainHpFromTargets) {
      // return null;
    } else if (func.funcType == FuncType.gainNpFromTargets) {
      // return null;
    } else {
      if (vals.Value != null) {
        switch (func.funcType) {
          case FuncType.damageNp:
          case FuncType.damageNpHpratioLow:
          case FuncType.damageNpIndividual:
          case FuncType.damageNpIndividualSum:
          case FuncType.damageNpPierce:
          case FuncType.damageNpRare:
          case FuncType.damageNpStateIndividualFix:
          case FuncType.damageNpCounter:
          case FuncType.gainHpPer:
          case FuncType.qpDropUp:
            _addPercent(vals.Value, 10);
            break;
          case FuncType.gainNp:
          case FuncType.gainNpBuffIndividualSum:
          case FuncType.lossNp:
            _addPercent(vals.Value, 100);
            break;
          default:
            parts.add(vals.Value.toString());
            break;
        }
      }
      if (vals.Value2 != null) {
        if (func.funcType == FuncType.damageNpIndividualSum) {
          _addPercent(vals.Value2, 10);
        }
      }
      if (vals.Correction != null) {
        switch (func.funcType) {
          case FuncType.damageNpIndividual:
          case FuncType.damageNpRare:
          case FuncType.damageNpStateIndividualFix:
            _addPercent(vals.Correction, 10);
            break;
          case FuncType.damageNpIndividualSum:
            _addPercent(vals.Correction, 10);
            break;
          default:
            parts.add(vals.Correction.toString());
            break;
        }
      }
      if (vals.Target != null) {
        switch (func.funcType) {
          case FuncType.damageNpHpratioLow:
            _addPercent(vals.Target, 10);
            break;
          case FuncType.damageNpIndividual:
          case FuncType.damageNpRare:
          case FuncType.damageNpStateIndividualFix:
          case FuncType.damageNpIndividualSum:
          case FuncType.servantFriendshipUp:
            break;
          default:
            parts.join(vals.Target.toString());
            break;
        }
      }
      if (vals.AddCount != null) {
        parts.add(vals.AddCount.toString());
      }
      if (vals.UseRate != null) {
        _addPercent(vals.UseRate, 10);
      }
      if (vals.RateCount != null) {
        switch (func.funcType) {
          case FuncType.qpDropUp:
          case FuncType.servantFriendshipUp:
          case FuncType.userEquipExpUp:
          case FuncType.expUp:
            _addPercent(vals.RateCount, 10);
            break;
          default:
            _addInt(vals.RateCount);
        }
      }
      if (vals.DropRateCount != null) {
        _addPercent(vals.DropRateCount, 10);
      }
    }
    _maybeAddRate();
  }

  final empty = '';
  void describeBuff(Buff buff) {
    final base = _kBuffValuePercentTypes[buff.type];
    if (base != null) {
      if (vals.Value == 0 && vals.ParamAddValue != null) {
        _addPercent(vals.ParamAddValue, base);
      } else {
        _addPercent(vals.Value, base);
      }
      return;
    }
    final trigger = _kBuffValueTriggerTypes[buff.type];
    if (trigger != null) {
      final triggerVal = trigger(vals);
      if (triggerVal.skill != null && triggerVal.level != null) {
        parts.add('${triggerVal.skill}(${triggerVal.level})');
      } else if (triggerVal.skill != null) {
        parts.add(triggerVal.skill.toString());
      } else if (triggerVal.level != null) {
        parts.add(triggerVal.level.toString());
      }
      return;
    }
    if (buff.type == BuffType.changeCommandCardType) {
      parts.add(empty);
      return;
    }
    if (buff.type == BuffType.fieldIndividuality) {
      parts.add(Transl.trait(vals.Value!).l);
      return;
    }
    if (vals.ParamAddValue != null) {
      _addPercent(vals.Rate, 10);
    }
    _maybeAddRate();
    _addInt(vals.Value);
  }

  void _maybeAddRate() {
    if (ignoreRate == true) return;
    final _jsonVals = vals.toJson().keys.toSet();
    if (_jsonVals.length == 1 && _jsonVals.first == 'Rate') {
      _addPercent(vals.Rate, 10);
    }
  }
}

const _kBuffValuePercentTypes = {
  BuffType.upAtk: 10,
  BuffType.downAtk: 10,
  BuffType.upCommandall: 10,
  BuffType.downCommandall: 10,
  BuffType.upCommandatk: 10,
  BuffType.downCommandatk: 10,
  BuffType.upCriticaldamage: 10,
  BuffType.downCriticaldamage: 10,
  BuffType.upCriticalpoint: 10,
  BuffType.downCriticalpoint: 10,
  BuffType.upCriticalrate: 10,
  BuffType.downCriticalrate: 10,
  BuffType.upCriticalRateDamageTaken: 10,
  BuffType.downCriticalRateDamageTaken: 10,
  BuffType.upCriticalStarDamageTaken: 10,
  BuffType.downCriticalStarDamageTaken: 10,
  BuffType.upDamage: 10,
  BuffType.downDamage: 10,
  BuffType.upDamageIndividualityActiveonly: 10,
  BuffType.downDamageIndividualityActiveonly: 10,
  BuffType.upDamageEventPoint: 10,
  BuffType.upDamagedropnp: 10,
  BuffType.downDamagedropnp: 10,
  BuffType.upDefence: 10,
  BuffType.downDefence: 10,
  BuffType.upDefencecommandall: 10,
  BuffType.downDefencecommandall: 10,
  BuffType.upDropnp: 10,
  BuffType.downDropnp: 10,
  BuffType.upFuncHpReduce: 10,
  BuffType.downFuncHpReduce: 10,
  BuffType.upGainHp: 10,
  BuffType.downGainHp: 10,
  BuffType.upGrantstate: 10,
  BuffType.downGrantstate: 10,
  BuffType.upHate: 10,
  BuffType.upResistInstantdeath: 10,
  BuffType.upNonresistInstantdeath: 10,
  BuffType.upGrantInstantdeath: 10,
  BuffType.downGrantInstantdeath: 10,
  BuffType.upNpdamage: 10,
  BuffType.downNpdamage: 10,
  BuffType.upSpecialdefence: 10,
  BuffType.downSpecialdefence: 10,
  BuffType.upDamageSpecial: 10,
  BuffType.upStarweight: 10,
  BuffType.downStarweight: 10,
  BuffType.upTolerance: 10,
  BuffType.downTolerance: 10,
  BuffType.upToleranceSubstate: 10,
  BuffType.downToleranceSubstate: 10,
  BuffType.upGivegainHp: 10,
  BuffType.downGivegainHp: 10,
  BuffType.gutsRatio: 10,
  BuffType.buffRate: 10,
  BuffType.regainNp: 100,
};

class BuffValueTriggerType {
  final int? skill;
  final int? level;
  final int? rate;
  final int? position;
  BuffValueTriggerType({
    required this.skill,
    required this.level,
    this.rate,
    this.position,
  });
}

final Map<BuffType, BuffValueTriggerType Function(DataVals)>
    _kBuffValueTriggerTypes = {
  BuffType.reflectionFunction: (v) =>
      BuffValueTriggerType(skill: v.Value, level: v.Value2),
  BuffType.attackFunction: (v) =>
      BuffValueTriggerType(skill: v.Value, level: v.Value2),
  BuffType.commandattackFunction: (v) =>
      BuffValueTriggerType(skill: v.Value, level: v.Value2, rate: v.UseRate),
  BuffType.commandattackBeforeFunction: (v) =>
      BuffValueTriggerType(skill: v.Value, level: v.Value2),
  BuffType.damageFunction: (v) =>
      BuffValueTriggerType(skill: v.Value, level: v.Value2),
  BuffType.deadFunction: (v) =>
      BuffValueTriggerType(skill: v.Value, level: v.Value2),
  BuffType.delayFunction: (v) =>
      BuffValueTriggerType(skill: v.Value, level: v.Value2),
  BuffType.npattackPrevBuff: (v) => BuffValueTriggerType(
      skill: v.SkillID, level: v.SkillLV, position: v.Value),
  BuffType.selfturnendFunction: (v) =>
      BuffValueTriggerType(skill: v.Value, level: v.Value2, rate: v.UseRate),
  BuffType.wavestartFunction: (v) =>
      BuffValueTriggerType(skill: v.Value, level: v.Value2, rate: v.UseRate),
  BuffType.counterFunction: (v) =>
      BuffValueTriggerType(skill: v.CounterId, level: v.CounterLv),
};
