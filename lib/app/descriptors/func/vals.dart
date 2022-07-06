import 'package:flutter/material.dart';

import 'package:chaldea/models/models.dart';
import 'package:chaldea/packages/json_viewer/json_viewer.dart';
import 'package:chaldea/utils/utils.dart';
import 'package:chaldea/widgets/widgets.dart';
import '../../../packages/logger.dart';

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
          child = Padding(
            padding: const EdgeInsets.symmetric(vertical: 2),
            child: child,
          );
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
  final bool ignoreCount;
  final Color? color;

  ValDsc({
    Key? key,
    required this.func,
    required this.vals,
    this.originVals,
    this.color,
    this.ignoreRate,
    this.ignoreCount = false,
  }) : super(key: key);

  final List<String> parts = [];

  @override
  Widget build(BuildContext context) {
    describeFunc();
    TextStyle style = TextStyle(color: color, fontSize: 13);
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
          useRootNavigator: false,
          builder: (context) {
            return Theme(
              data: ThemeData.light(),
              child: SimpleCancelOkDialog(
                title: const Text('Data Vals'),
                content: JsonViewer((originVals ?? vals).toJson(),
                    defaultOpen: true),
                scrollable: true,
                hideCancel: true,
                contentPadding: const EdgeInsetsDirectional.fromSTEB(
                    10.0, 10.0, 12.0, 24.0),
              ),
            );
          },
        );
      },
    );
  }

  void _addInt(int? value, [String Function(String)? post]) {
    if (value == null || value == 0) return;
    if (value == 966756) {
      logger.e(value.toString());
    }
    String text = value.toString();
    if (post != null) text = post(text);
    parts.add(text);
  }

  String? _toPercent(int? value, [int base = 1]) {
    if (value == null) return null;
    int _intValue = value ~/ base;
    double _floatValue = value / base;
    if (_intValue.toDouble() == _floatValue) {
      return '$_intValue';
    } else {
      return _floatValue.toString().trimCharRight('0');
    }
  }

  void _addPercent(int? value, int base, [String Function(String)? post]) {
    if (value == null || value == 0) return;
    if (value == 966756) {
      logger.e(value.toString());
    }
    String text = '${_toPercent(value, base)!}%';
    if (post != null) {
      text = post(text);
    }
    parts.add(text);
  }

  // return null if not processed
  void describeFunc() {
    parts.clear();

    if (func.funcType == FuncType.addState ||
        func.funcType == FuncType.addStateShort) {
      describeBuff(func.buffs.first);
      if (vals.UseRate != null) {
        _addPercent(vals.UseRate, 10, (v) => Transl.special.funcValChance(v));
      }
      _maybeAddRate();
    } else if (func.funcType == FuncType.absorbNpturn) {
      // enemy
      // return null;
    } else if (func.funcType == FuncType.gainHpFromTargets) {
      _addInt(vals.DependFuncVals?.Value);
    } else if (func.funcType == FuncType.gainNpFromTargets) {
      // Absorb Value, charge Value2
      _addPercent(
          vals.DependFuncVals?.Value2 ?? vals.DependFuncVals?.Value, 100);
    } else if (func.funcType == FuncType.subState) {
      if (vals.Value2 != null) {
        _addInt(vals.Value2);
      } else {
        parts.add('All');
      }
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
      if (!ignoreCount && vals.Count != null && vals.Count! > 0) {
        _addInt(
            vals.Count, (v) => Transl.special.funcValCountTimes(vals.Count!));
      }
      if (vals.AddCount != null) {
        _addInt(vals.AddCount);
      }
      if (vals.UseRate != null) {
        Transl.spotNames;
        _addPercent(vals.UseRate, 10, (v) => Transl.special.funcValChance(v));
      }
      if (vals.RateCount != null) {
        switch (func.funcType) {
          case FuncType.qpDropUp:
          case FuncType.servantFriendshipUp:
          case FuncType.userEquipExpUp:
          case FuncType.eventPointUp:
          case FuncType.expUp:
            _addPercent(vals.RateCount, 10);
            break;
          case FuncType.enemyEncountRateUp:
          case FuncType.enemyEncountCopyRateUp:
            _addPercent(vals.RateCount, 10);
            break;
          default:
            _addInt(vals.RateCount);
        }
      }
      if (vals.DropRateCount != null) {
        _addPercent(vals.DropRateCount, 10);
      }
      if (vals.Individuality != null) {
        // if ([].contains(func.funcType)) {
        //   parts.add(Transl.trait(vals.Individuality!).l);
        // }
      }
      _maybeAddRate();
    }
  }

  final empty = '';
  void describeBuff(Buff buff) {
    final base = _kBuffValuePercentTypes[buff.type];
    final trigger = kBuffValueTriggerTypes[buff.type];
    if (base != null) {
      _addPercent(vals.Value, base);
      if (vals.ParamAddValue != null) {
        _addPercent(vals.ParamAddValue, base);
      }
      if (vals.ParamAdd != null) {
        _addPercent(vals.ParamAdd, base);
      }
      // return;
    } else if (trigger != null) {
      final triggerVal = trigger(vals);
      if (triggerVal.skill != null && triggerVal.level != null) {
        parts.add(triggerVal.skill.toString());
      } else if (triggerVal.skill != null) {
        parts.add(triggerVal.skill.toString());
      } else if (triggerVal.level != null) {
        parts.add('Lv.${triggerVal.level}');
      }
      return;
    } else if (buff.type == BuffType.changeCommandCardType) {
      parts.add(empty);
      return;
    } else if ([
      BuffType.fieldIndividuality,
      BuffType.addIndividuality,
      BuffType.subIndividuality
    ].contains(buff.type)) {
      parts.add(Transl.trait(vals.Value!).l);
      return;
    } else {
      _addInt(vals.Value);
      if (vals.ParamAddValue != null) {
        _addInt(vals.ParamAddValue);
      }
      if (vals.ParamAdd != null) {
        _addInt(vals.ParamAdd);
      }
    }
    if (vals.RatioHPLow != null || vals.RatioHPHigh != null) {
      final ratios =
          [vals.RatioHPLow, vals.RatioHPHigh].whereType<int>().toList()..sort();
      final ratioStrings = ratios.map((e) => _toPercent(e, base ?? 1)).toList();
      parts.add('${ratioStrings.join('-')}%');
    }
    if (!ignoreCount && vals.Count != null && vals.Count! > 0) {
      _addInt(vals.Count, (v) => Transl.special.funcValCountTimes(vals.Count!));
    }
  }

  void _maybeAddRate() {
    final _jsonVals = vals.toJson().keys.toSet();
    // _jsonVals.removeAll(['Turn', 'Count']);
    if ((_jsonVals.length == 1 &&
            _jsonVals.first == 'Rate' &&
            ignoreRate != true) ||
        (vals.Rate != null && vals.Rate != 1000)) {
      _addPercent(vals.Rate, 10, (v) => Transl.special.funcValChance(v));
    }
    if (vals.ActSetWeight != null) {
      _addPercent(vals.ActSetWeight, 1, (v) => Transl.special.funcValWeight(v));
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
